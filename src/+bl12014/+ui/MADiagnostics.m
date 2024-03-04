classdef MADiagnostics < mic.Base
    
    properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
                
        uiCommKeithley6482

        % {mic.ui.device.GetSetNumber 1x1}
        uiStageMAYag
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiStageWheel
        % {mic.ui.device.GetNumber 1x1}
        uiCurrent
        
        uiButtonMALeft
        uiButtonMARight
        uiButtonWheelLeft
        uiButtonWheelRight
        
        dWidth = 480;
        dHeight = 155;
        
                
    end
    
    properties (Access = private)
        
        clock
        
        hParent
        hPanel
        
        dWidthVal = 50
        dWidthName = 140
        dWidthPadName = 5
        dWidthPadUnit = 120
        
        configStageY
        configMeasPointVolts
        
        lActive = false
        
        % {newfocus.Model8742 1x1}
        comm
        
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    properties (SetAccess = private)
        
        cName = 'ma-diagnostics'
    end
    
    methods
        
        function this = MADiagnostics(varargin)
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
        
        function syncDestinations(this)
            
            
        end
        
        %{
        function connectNewFocusModel8742(this, comm)
            
            this.lActive = true;
            this.comm = comm;
            
            device = bl12014.device.GetSetNumberFromNewFocusModel8742(comm, 1); 
            this.uiStageMAYag.setDevice(device);
            this.uiStageMAYag.turnOn()
            this.uiStageMAYag.syncDestination();
            
            device = bl12014.device.GetSetNumberFromNewFocusModel8742(comm, 2); 
            this.uiStageWheel.setDevice(device);
            this.uiStageWheel.turnOn()
            this.uiStageWheel.syncDestination();
            
            this.setColorOfBackgroundToDefault();
            
        end
        
        
        function disconnectNewFocusModel8742(this)
            
            this.uiStageMAYag.turnOff()
            this.uiStageMAYag.setDevice([]);
            
            this.uiStageWheel.turnOff()
            this.uiStageWheel.setDevice([]);
            
            this.lActive = false;
            
            this.setColorOfBackgroundToWarning();
        end
        %}
        
        function build(this, hParent, dLeft, dTop)
            
            
            
            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', 'MA Diagnostics', ...
                'Clipping', 'on', ...
                ...%'BackgroundColor', [200 200 200]./255, ...
                ...%'BorderType', 'none', ...
                ...%'BorderWidth',0, ... 
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent)...
            );
        
        
            dSep = 30;
            dTop = 20;
            dLeft = 10;
            
            
            this.uiCommKeithley6482.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 24 + 10;
                        
            this.uiStageMAYag.build(this.hPanel, dLeft, dTop);
            
            dLeftButton = dLeft + 210;
            dWidthButton = 50;
            this.uiButtonMALeft.build(this.hPanel, dLeftButton, dTop, dWidthButton, 24);
            this.uiButtonMARight.build(this.hPanel, dLeftButton + dWidthButton, dTop, dWidthButton, 24);
            dTop = dTop + dSep;
            
            this.uiStageWheel.build(this.hPanel, dLeft, dTop);
            this.uiButtonWheelLeft.build(this.hPanel, dLeftButton, dTop, dWidthButton, 24);
            this.uiButtonWheelRight.build(this.hPanel, dLeftButton + dWidthButton, dTop, dWidthButton, 24);
            
            
            dTop = dTop + dSep;
            
            this.uiCurrent.build(this.hPanel, dLeft, dTop);
            
            
                        
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            
        end    
        
        
        function st = save(this)
            st = struct();
            st.uiStageMAYag = this.uiStageMAYag.save();
            st.uiStageWheel = this.uiStageWheel.save();
            
        end
        
        function load(this, st)
            
            
            if isfield(st, 'uiStageMAYag')
                this.uiStageMAYag.load(st.uiStageMAYag)
            end
            
            if isfield(st, 'uiStageWheel')
                this.uiStageWheel.load(st.uiStageWheel)
            end
                        
        end
        
        
    end
    
    methods (Access = private)
        
        %{
         function onFigureCloseRequest(this, src, evt)
            this.msg('MADiagnosticsControl.closeRequestFcn()');
            delete(this.hParent);
            this.hParent = [];
         end
        %}
        
         
         function setColorOfBackgroundToWarning(this)
            this.setColorOfBackground([1 1 0.85]);
        end
        
        function setColorOfBackgroundToDefault(this)
            this.setColorOfBackground([0.94 0.94 0.94]);
        end
        
        function setColorOfBackground(this, dColor)
            if ishandle(this.hPanel)
                set(this.hPanel, 'BackgroundColor', dColor);
                
            end
            
        end
         
        
        
        function initUiStageMAYag(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-ma-yag-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            u8Axis = 1;
            this.uiStageMAYag = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthName', this.dWidthName, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowStores', false, ...
                'lShowLabels', false, ...
                'lShowStepNeg', false, ...
                'lShowStep', false, ...
                'lShowStepPos', false, ...
                'cName', sprintf('%s-ma-yag', this.cName), ...
                'config', uiConfig, ...
                'fhGet', @() this.hardware.getNewFocus8742MA().getPosition(u8Axis), ...
                'fhSet', @(dVal) this.hardware.getNewFocus8742MA().moveToTargetPosition(u8Axis, dVal), ...
                'fhIsReady', @() this.hardware.getNewFocus8742MA().getMotionDoneStatus(u8Axis), ...
                'fhStop', @() this.hardware.getNewFocus8742MA().stop(u8Axis), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'MA YAG (In <--> Out)' ...
            );
        end
        
        function initUiStageWheel(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-subframe-wheel-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            u8Axis = 2;
            this.uiStageWheel = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowLabels', false, ...
                'lShowStores', false, ...
                'lShowStepNeg', false, ...
                'lShowStep', false, ...
                'lShowStepPos', false, ...
                'cName', sprintf('%s-subframe-wheel', this.cName), ...
                'config', uiConfig, ...
                'fhGet', @() this.hardware.getNewFocus8742MA().getPosition(u8Axis), ...
                'fhSet', @(dVal) this.hardware.getNewFocus8742MA().moveToTargetPosition(u8Axis, dVal), ...
                'fhIsReady', @() this.hardware.getNewFocus8742MA().getMotionDoneStatus(u8Axis), ...
                'fhStop', @() this.hardware.getNewFocus8742MA().stop(u8Axis), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'SF Whl (Di <==> YAG)' ...
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
                'dWidthName', 180, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', [this.cName, 'comm-keithley-6482-reticle'], ...
                'fhGet', @() this.hardware.getIsConnectedKeithley6482Reticle(), ...
                'fhSet', @(lVal) this.hardware.setIsConnectedKeithley6482Reticle(lVal), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Keithley 6482 (Reticle)' ...
            );
        
        end
                
        function initUiCurrent(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-reticle-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCurrent = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', 115, ...
                'dWidthPadUnit', 120, ...
                'fhGet', @() this.hardware.getKeithley6482Reticle().read(2), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'keithley-6482-reticle'], ...
                'config', uiConfig, ...
                'cLabel', 'SF Diode' ...
            );
        end
        
        
        

        function init(this)
            this.msg('init');
            
            this.initUiCommKeithley6482();
            this.initUiStageMAYag();
            this.initUiStageWheel();
            this.initUiCurrent();
            
            this.uiButtonMALeft = mic.ui.common.Button(...
                'cText', '<<', ...
                'fhOnPress', @(src, evt) this.hardware.getNewFocus8742MA().moveIndefinitely(1, -1), ...
                'fhOnRelease', @(src, evt) this.hardware.getNewFocus8742MA().stop(1) ...
            );
                
            this.uiButtonMARight = mic.ui.common.Button(...
                'cText', '>>', ...
                'fhOnPress', @(src, evt)this.hardware.getNewFocus8742MA().moveIndefinitely(1, 1), ...
                'fhOnRelease', @(src, evt) this.hardware.getNewFocus8742MA().stop(1) ...
            );
        
            this.uiButtonWheelLeft = mic.ui.common.Button(...
                'cText', '<<', ...
                'fhOnPress', @(src, evt)this.hardware.getNewFocus8742MA().moveIndefinitely(2, -1), ...
                'fhOnRelease', @(src, evt) this.hardware.getNewFocus8742MA().stop(2) ...
            );
                
            this.uiButtonWheelRight = mic.ui.common.Button(...
                'cText', '>>', ...
                'fhOnPress', @(src, evt)this.hardware.getNewFocus8742MA().moveIndefinitely(2, 1), ...
                'fhOnRelease', @(src, evt) this.hardware.getNewFocus8742MA().stop(2) ...
            );
            
        end
        
        
    end
    
    
end

