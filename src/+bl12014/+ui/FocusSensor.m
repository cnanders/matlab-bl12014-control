classdef FocusSensor < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 620
        dHeight     = 510
        
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
       
    end
    
    properties (SetAccess = private)
        
        hFigure
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
        
        function build(this)
                        
            % Figure
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name', 'Focus Sensor',...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onCloseRequestFcn ...
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

            
            
            
            this.uiCommDeltaTauPowerPmac.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommKeithley6482.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommSmarActRotary.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            this.uiCoarseStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiCoarseStage.dHeight + dPad;
            
            this.uiFineStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiFineStage.dHeight + dPad;
            
            this.uiFocusSensor.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiFocusSensor.dHeight + dPad;
            
                        
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
        end
               
        
        
        
    end
    
    methods (Access = private)
        
        function init(this)
            
            this.msg('init()');
            
            this.uiCoarseStage = bl12014.ui.WaferCoarseStage(...
                'cName', sprintf('%s-wafer-coarse-stage', this.cName), ...
                'clock', this.clock ...
            );
            this.uiFineStage = bl12014.ui.WaferFineStage(...
                'cName', sprintf('%s-wafer-fine-stage', this.cName), ...
                'clock', this.clock ...
            );

            this.uiFocusSensor = bl12014.ui.WaferFocusSensor( ...
                'cName', sprintf('%s-wafer-focus-sensor', this.cName), ...
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