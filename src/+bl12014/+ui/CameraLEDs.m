classdef CameraLEDs < mic.Base
    
    properties
        
        % {mic.ui.device.GetSetLogical 1x1}}
        uiSwitch1Outlet1
        uiSwitch1Outlet2
        uiSwitch2Outlet1
        uiSwitch2Outlet2
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 610
        dHeight = 230
        hParent
        
        % {bl12014.Hardware 1x1}
        hardware
        
        
    end
    
    properties (SetAccess = private)
        
        cName = 'camera-leds'
    end
    
    methods
        
        function this = CameraLEDs(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
        
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            this.hParent = hParent;
            dSep = 30;
            
            %{
            this.uiSwitch1Outlet1.build(this.hParent, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            %}
            
            this.uiSwitch1Outlet2.build(this.hParent, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiSwitch2Outlet1.build(this.hParent, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiSwitch2Outlet2.build(this.hParent, dLeft, dTop);
            dTop = dTop + dSep;
            
            

            
        end
        
        
        function cec = getPropsDelete(this)
            cec = {...
                'uiSwitch1Outlet1', ...
                'uiSwitch1Outlet2', ... references FluxDensity
                'uiSwitch2Outlet1', ...
                'uiSwitch2Outlet2', ...
            };
        end
                    
        function delete(this)
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_INIT_DELETE);  
            cecProps = this.getPropsDelete();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                cMsg = sprintf('delete() deleting %s', cProp);
                this.msg(cMsg, this.u8_MSG_TYPE_CLASS_INIT_DELETE); 
                this.(cProp).delete();
            end
        end  
        
        function st = save(this)
            %st = struct();
            %st.uiSwitch1Outlet1 = this.uiSwitch1Outlet1.save();
        end
        
        function load(this, st)
            %{
            if isfield(st, 'uiStageY')
                this.uiSwitch1Outlet1.load(st.uiSwitch1Outlet1)
            end
            %}
        end
        
        
    end
    
    methods (Access = private)
        
         
         
         function ce = getCommandToggleParams(this) 
             
             ce = {...
                'cTextTrue', 'Turn Off', ...
                'cTextFalse', 'Turn On' ...
            };

         end
         
        function initUiSwitch1Outlet1(this)
               
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-logical', ...
                'config-3gstore-remote-power-switch.json' ...
            );
        
            uiConfig = mic.config.GetSetLogical(...
                'cPath',  cPathConfig ...
            );
            
            this.uiSwitch1Outlet1 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'config', uiConfig, ...
                'ceVararginCommandToggle', this.getCommandToggleParams(), ...
                'cName', sprintf('%s-branch-outlet-1', this.cName), ...
                'lShowInitButton', false, ...
                'fhGet', @() this.hardware.getWebSwitchBeamline().isOnRelay1(), ...
                'fhSet', @(lVal) mic.Utils.ternEval(...
                   lVal, ...
                   @() this.hardware.getWebSwitchBeamline().turnOnRelay1(), ...
                   @() this.hardware.getWebSwitchBeamline().turnOffRelay1() ...
                ), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Branch Cameras' ...
            );
        end
        
        function initUiSwitch1Outlet2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-logical', ...
                'config-3gstore-remote-power-switch.json' ...
            );
        
            uiConfig = mic.config.GetSetLogical(...
                'cPath',  cPathConfig ...
            );
        
            this.uiSwitch1Outlet2 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                 'config', uiConfig, ...
                'lShowLabels', false, ...
                'ceVararginCommandToggle', this.getCommandToggleParams(), ...
                'cName', sprintf('%s-branch-outlet-2', this.cName), ...
                'lShowInitButton', false, ...
                'fhGet', @() this.hardware.getWebSwitchBeamline().isOnRelay2(), ...
                'fhSet', @(lVal) mic.Utils.ternEval(...
                   lVal, ...
                   @() this.hardware.getWebSwitchBeamline().turnOnRelay2(), ...
                   @() this.hardware.getWebSwitchBeamline().turnOffRelay2() ...
                ), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Branch LEDs' ...
            );
        end
        
        function initUiSwitch2Outlet1(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-logical', ...
                'config-3gstore-remote-power-switch.json' ...
            );
        
            uiConfig = mic.config.GetSetLogical(...
                'cPath',  cPathConfig ...
            );
        
            this.uiSwitch2Outlet1 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                 'config', uiConfig, ...
                'lShowLabels', false, ...
                'ceVararginCommandToggle', this.getCommandToggleParams(), ...
                'cName', sprintf('%s-end-station-outlet-1', this.cName), ...
                'lShowInitButton', false, ...
                'fhGet', @() this.hardware.getWebSwitchEndstation().isOnRelay1(), ...
                'fhSet', @(lVal) mic.Utils.ternEval(...
                   lVal, ...
                   @() this.hardware.getWebSwitchEndstation().turnOnRelay1(), ...
                   @() this.hardware.getWebSwitchEndstation().turnOffRelay1() ...
                ), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'End Station Cameras' ...
            );
        end
        
        function initUiSwitch2Outlet2(this)
            
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
        
        
        
        
        
       
        function init(this)
            
            this.msg('init');
            this.initUiSwitch1Outlet1();
            this.initUiSwitch1Outlet2();
            this.initUiSwitch2Outlet1();
            this.initUiSwitch2Outlet2();
            
            
        end
        
        
        
    end
    
    
end

