classdef FocusSensor < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 620
        dHeight     = 510
        
        ceScanAxisLabels = {...
                        'Ret Crs X', ...
                        'Ret Crs Y', ...
                        'Ret Crs Z', ...
                        'Waf Crs X', ...
                        'Waf Crs Y', ...
                        'Waf Crs Z', ...
                        'FM Rz', ...
                        'Do Nothing'};
        ceScanOutputLabels = {'Image capture', 'Image intensity', ...
            'Background diff', 'Line Pitch', 'Pause 2s', 'Wafer Diode', 'HS Simple Z', ...
            'HS Cal Z', 'HS Cal Rx', 'HS Cal Ry', 'Image caputure lock conjugate'};
        
        
    end
    
	properties
        
        
        % UI for activating the hardware that gives the 
        % software real data
        
        % { mic.ui.device.GetSetLogical 1x1}
        uiCommDeltaTauPowerPmac
                
        % { mic.ui.device.GetSetLogical 1x1}
        uiCommKeithley6482
        
        % { mic.ui.device.GetSetLogical 1x1}
        uiCommSmarActRotary
             
        
        % UI general
        uiCoarseStage
        uiFineStage
        uiFocusSensor
        
        % Scan setups
        uitgScan
        ceTabList = {'1D-scan', '2D-scan', '3D-scan'}
        
        scanHandler
        ss1D
        ss2D
        ss3D
        
        ssCurrentScanSetup %pointer to current scan setup
        lSaveImagesInScan = false
        dImageSeriesNumber = 0 %Used to keep track of the number of series 
        
        % Scan progress text elements
        uiTextStatus
        uiTextTimeElapsed
        uiTextTimeRemaining
        uiTextTimeComplete
        
        % Keep track of initial state of last scan
        stLastScanState
        
        lAutoSaveImage
        lIsScanAcquiring = false % whether we're currently in a "scan acquire"
        lIsScanning = false
        
        lIsConjugateLockEnabled = false
        dInitialHSSZValue = 0
        dInitialRetZValue = 0
        
        % Scan ouput:
        stLastScan
        
        dNumScanOutputAxes
        ceScanCoordinates
        dLinearScanOutput
        dScanOutput
        
       
    end
    
    properties (SetAccess = private)
        
        hPanel
        cName = 'focus-sensor'
        
    end
    
    properties (Access = private)
                      
        clock
        
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = FocusSensor(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            
            this.init();
            
        end
        
        
        function connectSmarActRotary(this, comm)
            device = bl12014.device.GetSetNumberFromStage(comm, 1);
            this.uiFocusSensor.uiTiltZ.setDevice(device);
            this.uiFocusSensor.uiTiltZ.turnOn();
        end
        
        function disconnectSmarActRotary(this)
            this.uiFocusSensor.uiTiltZ.turnOff();
            this.uiFocusSensor.uiTiltZ.setDevice([]);
            
        end
        
        function build(this, hParent, dLeft, dTop)
                        
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Focus Sensor',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
            
            % There is a bug in the default 'painters' renderer when
            % drawing stacked patches.  This is required to make ordering
            % work as expected
            
            % set(this.hFigure, 'renderer', 'OpenGL');
            
            drawnow;

            dTop = 10;
            dPad = 10;
            dLeft = 10;
            dSep = 30;

            
            
            
            this.uiCommDeltaTauPowerPmac.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommKeithley6482.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommSmarActRotary.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            this.uiCoarseStage.build(this.hPanel, dLeft, dTop);
            dTop = dTop + this.uiCoarseStage.dHeight + dPad;
            
            this.uiFineStage.build(this.hPanel, dLeft, dTop);
            dTop = dTop + this.uiFineStage.dHeight + dPad;
            
            this.uiFocusSensor.build(this.hPanel, dLeft, dTop);
            dTop = dTop + this.uiFocusSensor.dHeight + dPad;
            
                        
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            
            
            
        end
               
        
        
        
    end
    
    methods (Access = private)
        
        function init(this)
            
            this.msg('init()');
            
            this.uiCoarseStage = bl12014.ui.WaferCoarseStage(...
                'cName', sprintf('%s-wafer-coarse-stage', this.cName), ...
                'hardware', this.hardware, ...
                'clock', this.clock ...
            );
            this.uiFineStage = bl12014.ui.WaferFineStage(...
                'cName', sprintf('%s-wafer-fine-stage', this.cName), ...
                'hardware', this.hardware, ...
                'clock', this.clock ...
            );

            this.uiFocusSensor = bl12014.ui.WaferFocusSensor( ...
                'cName', sprintf('%s-wafer-focus-sensor', this.cName), ...
                'hardware', this.hardware, ...
                'clock', this.clock ...
            );
        
            this.initUiCommDeltaTauPowerPmac();
            this.initUiCommSmarActRotary();
            this.initUiCommKeithley6482();
        

        end
        
        function initUiCommSmarActRotary(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommSmarActRotary = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-smar-act-rotary-stage', this.cName), ...
                'cLabel', 'SmarAct Rotary Stage' ...
            );
        
        end
        
        function initUiCommDeltaTauPowerPmac(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommDeltaTauPowerPmac = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'fhGet', @() this.hardware.getIsConnectedDeltaTauPowerPmac(), ...
                'fhSet', @(lVal) this.hardware.setIsConnectedDeltaTauPowerPmac(lVal), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', sprintf('%s-delta-tau-power-pmac-wafer-stage', this.cName), ...
                'cLabel', 'DeltaTau Power PMAC' ...
            );
        
        end
        
        function initUiCommKeithley6482(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommKeithley6482 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'fhGet', @() this.hardware.getIsConnectedKeithley6482Wafer(), ...
                'fhSet', @(lVal) this.hardware.setIsConnectedKeithley6482Wafer(lVal), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, '-keithley-6482-wafer'], ...
                'cLabel', 'Keithley 6482 (Wafer)' ...
            );
        
        end
        
        
        function onCloseRequestFcn(this, src, evt)
            
            delete(this.hFigure);
            this.hFigure = [];
            % this.saveState();
            
        end
        
        
    end % private
    
    
end