classdef WaferDiode < mic.Base
    
    properties

        % {mic.ui.device.GetNumber 1x1}}
        uiCurrent
        
    end
    
    properties (SetAccess = private)
        
        dWidth = 350
        dHeight = 70
        
        cName = 'WaferDiode'
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 70
        dWidthUnit = 80
        dWidthVal = 75
        dWidthPadUnit = 25 %277
        
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = WaferDiode(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        
        function turnOn(this)
            
            this.uiCurrent.turnOn();
            this.uiY.turnOn();
            
            
        end
        
        function turnOff(this)
            this.uiCurrent.turnOff();
            this.uiY.turnOff();
           
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wafer Diode (Unknown Hardware)',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;            

            dTop = 20;
            dLeft = 10;
            dSep = 30;
            
            this.uiCurrent.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
           
            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end    
        
        
    end
    
    methods (Access = private)
                
         
        function initUiCurrent(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-wafer-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCurrent = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'wafer-diode', ...
                'config', uiConfig, ...
                'cLabel', 'Current' ...
            );
        end
        
        
        
        function init(this)
            this.msg('init()');
            this.initUiCurrent();
            
        end
        
        
        
    end
    
    
end

