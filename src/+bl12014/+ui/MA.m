classdef MA < mic.Base
    
    properties (Constant)
        
        
    end
    properties (SetAccess = private)
        
        % {bl12014.ui.Scanner 1x1}
        uiScanner
        
        % {bl12014.ui.GigECamera 1x1}
        uiGigECamera
        
        % {bl12014.ui.MADiagnostics 1x1}
        uiDiagnostics
        
        % {bl12014.ui.SMSIFDiagnostics 1x1}
        uiSMSIFDiagnostics
        
        uiStateWaferNearPrint
        
        % {bl12014.ui.VPFM 1x1}
        uiVPFM
        
        
        
        
        
        % {bl12014.ui.Shutter 1x1}
        uiShutter
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiUndulatorGap
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiSwitch2Outlet2
        
        
        

        
    end
    
    properties (Access = protected)
        
        % {mic.Clock 1x1} must be provided
        clock
        % {mic.ui.Clock 1x1}
        uiClock
        
        
        % {bl12014.Hardware 1x1}
        hardware
                
    end
    
    properties (SetAccess = protected)
        
        cName = 'MA'
    end
    
    methods
        
        function this = MA(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
 
            
             if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
                       
            this.init();
        
        end
        
        function d = processImageFrame(this, dData)
            d = rot90(dData);
            d = rot90(d);
        end
                
        function build(this, hParent, dLeft, dTop)
            
            this.uiScanner.build(hParent, dLeft, dTop);
            
            % this.uiGigECamera.build(hParent, dLeft + 1250, dTop, 480);
            
            dTop = 300;
            dLeft = dLeft + 1250;
            
            this.uiStateWaferNearPrint.build(hParent, dLeft, dTop, 400);
            dTop = dTop + 30;
            
            this.uiSwitch2Outlet2.build(hParent, dLeft, dTop);
            dTop = dTop + 30;
            
            this.uiSMSIFDiagnostics.build(hParent, dLeft, dTop);
            dTop = dTop + this.uiSMSIFDiagnostics.dHeight + 10;
            
            
            this.uiDiagnostics.build(hParent, dLeft, dTop);
            dTop = dTop + this.uiDiagnostics.dHeight + 10;
                        
            
            
            this.uiVPFM.build(hParent, dLeft, dTop);
            dTop = dTop + this.uiVPFM.dHeight + 10;
            
            this.uiShutter.build(hParent, dLeft, dTop);
            dTop = dTop + this.uiShutter.dHeight + 10;
            
            this.uiUndulatorGap.build(hParent, dLeft, dTop);
            
        end
        
        
        function cec = getPropsDelete(this)
            cec = {
                'uiScanner', ...
                'uiDiagnostics', ...
                'uiSMSIFDiagnostics', ...
                'uiStateWaferNearPrint', ...
                'uiVPFM', ...
                'uiGigECamera', ...
                'uiShutter', ...
                'uiUndulatorGap', ...
                'uiSwitch2Outlet2', ...
            };
        end
        
        function delete(this)
            
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);  
            cecProps = this.getPropsDelete();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                this.(cProp).delete();
            end
            
        end  
        
        
        function st = save(this)
            st = struct();
            st.uiScanner = this.uiScanner.save();
        end
        
        function load(this, st)
            if isfield(st, 'uiScanner') 
                this.uiScanner.load(st.uiScanner);
            end
        end
        
    end
    
    methods (Access = protected)
        
        function initUiDeviceUndulatorGap(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-undulator-gap.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiUndulatorGap = mic.ui.device.GetSetNumber(...
                'clock', this.uiClock, ...
                'lShowLabels', false, ...
                ...'fhGet', @() this.hardware.getBL1201CorbaProxy().SCA_getIDGap(), ...
                ...'fhSet', @(dVal) this.hardware.getBL1201CorbaProxy().SCA_setIDGap(dVal), ...
                ...'fhIsReady', @() ~this.hardware.getBL1201CorbaProxy().SCA_getIDMotionComplete(), ...
                ... Channel Access
                'fhGet', @() this.hardware.getALS().getGapOfUndulator12(), ...
                'fhSet', @(dVal) this.hardware.getALS().setGapOfUndulator12(dVal), ...
                'fhIsReady', @() true, ... FIX ME
                'fhStop', @() [], ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, '-undulator-gap'], ...
                'config', uiConfig, ...
                'cLabel', 'Undulator Gap' ...
            );
        
        end
        
        
        function init(this)
            
            
            [cDir, cName, cExt] = fileparts(mfilename('fullpath'));
            cDirSave = mic.Utils.path2canonical(fullfile(...
                cDir, ...
                '..', ...
                '..', ...
                'save', ...
                'scanner-ma' ...
            ));
                    
            this.uiScanner = bl12014.ui.Scanner(...
                'fhGetNPoint', @() this.hardware.getNPointMA(), ...
                'cName', 'MA Scanner', ...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                'cDirSave', cDirSave, ...
                'dScale', 0.67 ... % 0.67 rel amp = sig 1
            );
        
            this.uiShutter = bl12014.ui.Shutter(...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                'hardware', this.hardware ...
            );
            this.uiVPFM = bl12014.ui.VPFM(...
                'clock', this.uiClock, ...
                'hardware', this.hardware ...
            );
            
            %{
            'dOffsetX', 370, ...
                'dOffsetY', 0, ...
                'dSizeX', 500, ...
                'dSizeY', 500, ...
            %}
            
            dSizeX = 1288;
            dSizeY = 728;
            dOffsetX = 100 ; % 350;
            dOffsetY = 0;
            this.uiGigECamera = bl12014.ui.GigECamera( ...
                'fhProcess', @this.processImageFrame, ...
                'dOffsetX', dOffsetX, ...
                'dOffsetY', dOffsetY, ...
                'dSizeX', 700, ... % dSizeX - dOffsetX, ...
                'dSizeY', dSizeY - dOffsetY, ...
                'cIp', '192.168.30.26' ...
            );
        
            this.uiDiagnostics = bl12014.ui.MADiagnostics( ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        
        this.uiSMSIFDiagnostics = bl12014.ui.SMSIFDiagnostics( ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        
        
            this.uiStateWaferNearPrint = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-wafer-near-print'], ...
                'task', bl12014.Tasks.createStateWaferStageNearPrint(...
                    [this.cName, 'state-wafer-near-print'], ...
                    this.hardware, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
            
            this.initUiDeviceUndulatorGap();
            
            this.initUiEndstationLEDs();
            
        end
        
        function initUiEndstationLEDs(this)
            
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-logical', ...
                'config-3gstore-remote-power-switch.json' ...
            );
        
            uiConfig = mic.config.GetSetLogical(...
                'cPath',  cPathConfig ...
            );
            
            this.uiSwitch2Outlet2 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                 'config', uiConfig, ...
                'lShowLabels', false, ...
                'ceVararginCommandToggle', this.getCommandToggleParams(), ...
                'cName', sprintf('%s-end-station-outlet-2', this.cName), ...
                'lShowInitButton', false, ...
                'fhGet', @() this.hardware.getWebSwitchEndstation().isOnRelay2(), ...
                'fhSet', @(lVal) mic.Utils.ternEval(...
                   lVal, ...
                   @() this.hardware.getWebSwitchEndstation().turnOnRelay2(), ...
                   @() this.hardware.getWebSwitchEndstation().turnOffRelay2() ...
                ), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'End Station LEDs' ...
            );
        
        end
        
        function ce = getCommandToggleParams(this) 
             
             ce = {...
                'cTextTrue', 'Turn Off', ...
                'cTextFalse', 'Turn On' ...
            };

         end
          
        
    end
    
    
end

