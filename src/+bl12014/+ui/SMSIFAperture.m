classdef SMSIFAperture < mic.Base
    
    properties
        
        
        
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiStageWheel
        
        uiButtonWheelLeft
        uiButtonWheelRight
        
        dWidth = 400;
        dHeight = 55;
        
                
    end
    
    properties (Access = private)
        
        clock
        
        hParent
        hPanel
        
        dWidthVal = 50
        dWidthName = 100
        dWidthPadName = 5
        dWidthPadUnit = 120
        
        % {bl12014.Hardware 1x1}
        hardware

        dColorLeft  = [245, 120, 120]/256
        dColorRight = [245, 184, 120]/256

        
    end
    
    properties (SetAccess = private)
        
        cName = 'sms-if-aperture'
    end
    
    methods
        
        function this = SMSIFAperture(varargin)
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
        
        
        function build(this, hParent, dLeft, dTop)
            
            
            
            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', 'SMS IRIS', ...
                'Clipping', 'on', ...
                ...%'BackgroundColor', [200 200 200]./255, ...
                ...%'BorderType', 'none', ...
                ...%'BorderWidth',0, ... 
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent)...
            );
        
        
            dSep = 30;
            dTop = 20;
            dLeft = 10;
                        
            dLeftButton = dLeft + 160;
            dWidthButton = 50;
            
            this.uiStageWheel.build(this.hPanel, dLeft, dTop);
            this.uiButtonWheelLeft.build(this.hPanel, dLeftButton, dTop, dWidthButton, 24);
            this.uiButtonWheelRight.build(this.hPanel, dLeftButton + dWidthButton, dTop, dWidthButton, 24);
            
            
            
            
                        
        end
        
        function delete(this)
            
            this.msg('delete');
            
            this.uiStageWheel.delete()
            this.uiButtonWheelLeft.delete()
            this.uiButtonWheelRight.delete()
                        
            
        end    
        

        
       function cec = getPropsSaved(this)
           
            cec = {...
                'uiStageWheel', ...
             };
            
        end
        
        
        function st = save(this)
             cecProps = this.getPropsSaved();
            
            st = struct();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                if this.hasProp( cProp)
                    st.(cProp) = this.(cProp).save();
                end
            end

             
        end
        
        function load(this, st)
                        
            cecProps = this.getPropsSaved();
            for n = 1 : length(cecProps)
               cProp = cecProps{n};
               if isfield(st, cProp)
                   if this.hasProp( cProp )
                        this.(cProp).load(st.(cProp))
                   end
               end
            end
            
        end
        
        
    end
    
    methods (Access = private)
        
        %{
         function onFigureCloseRequest(this, src, evt)
            this.msg('SMSIFApertureControl.closeRequestFcn()');
            delete(this.hParent);
            this.hParent = [];
         end
        %}
        
         

         
        
        
        
        function initUiStageWheel(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-smsif-aperture-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            u8Axis = 4;
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
                'lShowZero', false, ...
                'lShowRel', false, ...
                'cName', sprintf('%s-aperture', this.cName), ...
                'config', uiConfig, ...
                'fhGet', @() this.hardware.getNewFocus8742MA().getPosition(u8Axis), ...
                'fhSet', @(dVal) this.hardware.getNewFocus8742MA().moveToTargetPosition(u8Axis, dVal), ...
                'fhIsReady', @() this.hardware.getNewFocus8742MA().getMotionDoneStatus(u8Axis), ...
                'fhStop', @() this.hardware.getNewFocus8742MA().stop(u8Axis), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'IRIS (Opn <--> Cls)' ...
            );
        end
        
                
        
        
        

        function init(this)
            this.msg('init');
            
            this.initUiStageWheel();
            

        
            u8Axis = 4;
            this.uiButtonWheelLeft = mic.ui.common.Button(...
                'cText', '<<', ...
                'fhOnPress', @(src, evt)this.hardware.getNewFocus8742MA().moveIndefinitely(u8Axis, -1), ...
                'fhOnRelease', @(src, evt) this.hardware.getNewFocus8742MA().stop(u8Axis) ...
            );
                
            this.uiButtonWheelRight = mic.ui.common.Button(...
                'cText', '>>', ...
                'fhOnPress', @(src, evt)this.hardware.getNewFocus8742MA().moveIndefinitely(u8Axis, 1), ...
                'fhOnRelease', @(src, evt) this.hardware.getNewFocus8742MA().stop(u8Axis) ...
            );

            this.uiButtonWheelLeft.setColor(this.dColorLeft);
            this.uiButtonWheelRight.setColor(this.dColorRight);
            
        end
        
        
    end
    
    
end

