classdef MADiagnostics < mic.Base
    
    properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommNewFocusModel8742

        % {mic.ui.device.GetSetNumber 1x1}
        uiStageMAYag
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiStageWheel
        
        uiButtonMALeft
        uiButtonMARight
        uiButtonWheelLeft
        uiButtonWheelRight
        
                
    end
    
    properties (Access = private)
        
        clock
        dWidth = 710
        dHeight = 160
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
            
            this.init();
        
        end
        
        
        
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
        
        function build(this, hParent, dLeft, dTop)
            
            
            dWidthPanel = 480;
            dHeightPanel = 120;
            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', 'MA Diagnostics', ...
                'Clipping', 'on', ...
                ...%'BackgroundColor', [200 200 200]./255, ...
                ...%'BorderType', 'none', ...
                ...%'BorderWidth',0, ... 
                'Position', mic.Utils.lt2lb([dLeft dTop dWidthPanel dHeightPanel], hParent)...
            );
        
        
            dSep = 30;
            dTop = 20;
            dLeft = 10;
            
            this.uiCommNewFocusModel8742.build(this.hPanel, dLeft, dTop);
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
            
            if this.uiCommNewFocusModel8742.get() == true
                this.setColorOfBackgroundToDefault();
            else
                this.setColorOfBackgroundToWarning();
            end
                        
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
                'cLabel', 'MA YAG (neg=down)' ...
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
                'cLabel', 'SF Wheel (Pos = CW)' ...
            );
        end
        
        
        
        
        function initUiCommNewFocusModel8742(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommNewFocusModel8742 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 180, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-newfocus-model-8742', this.cName), ...
                'cLabel', 'NewFocus 8742' ...
            );
        
        end
        
        

        function init(this)
            this.msg('init');
            
            this.initUiCommNewFocusModel8742();
            this.initUiStageMAYag();
            this.initUiStageWheel();
            
            this.uiButtonMALeft = mic.ui.common.Button(...
                'cText', '<<', ...
                'fhOnPress', @this.onPressMALeft, ...
                'fhOnRelease', @this.onReleaseMALeft ...
            );
                
            this.uiButtonMARight = mic.ui.common.Button(...
                'cText', '>>', ...
                'fhOnPress', @this.onPressMARight, ...
                'fhOnRelease', @this.onReleaseMARight ...
            );
        
            this.uiButtonWheelLeft = mic.ui.common.Button(...
                'cText', '<<', ...
                'fhOnPress', @this.onPressWheelLeft, ...
                'fhOnRelease', @this.onReleaseWheelLeft ...
            );
                
            this.uiButtonWheelRight = mic.ui.common.Button(...
                'cText', '>>', ...
                'fhOnPress', @this.onPressWheelRight, ...
                'fhOnRelease', @this.onReleaseWheelRight ...
            );
            
        end
        
        
        function onPressMALeft(this, src, evt)
            if this.lActive
                this.comm.moveIndefinitely(1, -1);
            else
                this.uiStageMAYag.getDevice().moveIndefinitely(-1);
            end
            
        end
        
        function onReleaseMALeft(this, src, evt)
            if this.lActive
                this.comm.stop(1);
            else
                this.uiStageMAYag.getDevice().stop()
            end
        end
        
        function onPressMARight(this, src, evt)
            if this.lActive
                this.comm.moveIndefinitely(1, 1);
            else
                this.uiStageMAYag.getDevice().moveIndefinitely(1);
            end
        end
        
        function onReleaseMARight(this, src, evt)
            if this.lActive
                this.comm.stop(1);
            else
                this.uiStageMAYag.getDevice().stop();
            end
        end
        
        
        function onPressWheelLeft(this, src, evt)
            if this.lActive
                this.comm.moveIndefinitely(2, -1);
            else
                this.uiStageWheel.getDevice().moveIndefinitely(-1);
            end
        end
        
        function onReleaseWheelLeft(this, src, evt)
            if this.lActive
                this.comm.stop(2);
            else
                this.uiStageWheel.getDevice().stop();
            end
        end
        
        function onPressWheelRight(this, src, evt)
            if this.lActive
                this.comm.moveIndefinitely(2, 1);
            else
                this.uiStageWheel.getDevice().moveIndefinitely(1);
            end
        end
        
        function onReleaseWheelRight(this, src, evt)
            if this.lActive
                this.comm.stop(2);
            else
                this.uiStageWheel.getDevice().stop();
            end
        end
        
        
        
        
        
    end
    
    
end

