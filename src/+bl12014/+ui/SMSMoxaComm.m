classdef SMSMoxaComm < mic.Base
    
    properties
        
                
    end
    
    properties (SetAccess = private)
        
        dHeight = 60 
        cName = 'sms-moxa-com'

                
    end
    
    properties (Access = private)
        
        clock
        uiClock

        dWidthName = 120
        lShowDevice = false
        lShowLabels = false
        lShowInitButton = false        
        
        dWidth = 270
    
        
        % {bl12014.Hardware 1x1}
        hardware
        uiWorkingMode

        
    end
    
    methods
        
        function this = SMSMoxaComm(varargin)
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
            
            
              if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
              end
            
            if ~isa(this.clock, 'mic.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
                        
            this.init();
        
        end
        
        
        
            
        
        function build(this, hParent, dLeft, dTop)
            

            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wobble Working Mode',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
            dLeft = 0;
            dTop = 15;
            dSep = 30;
            
            this.uiWorkingMode.build(hPanel, dLeft, dTop);
           
                        
        end
        
        
        
        
        function delete(this)
            
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);

            
        end    
        
        
    end
    
    
    methods (Access = private)
        
        
        function init(this)
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Enable', ...
                'cTextFalse', 'Disable' ...
            };

            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-logical', ...
                'config-sms-moxa.json' ...
            );
        
            config = mic.config.GetSetLogical(...
                'cPath',  cPathConfig ...
            );

            this.uiWorkingMode =  mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hardware.getSMS().getWobbleWorkingMode(), ...
                'fhSet', @(lVal) this.hardware.getSMS().setWobbleWorkingMode(lVal), ...
                'lUseFunctionCallbacks', true, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'cName', [this.cName, 'WobbleWorkingMode'], ...
                'cLabel', 'Wobble Wrk Md' ...
            );
            
        end
        
        
        
        
       
        
        function onFigureCloseRequest(this, src, evt)
            this.msg('closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        
        
        
    end
    
    
end

