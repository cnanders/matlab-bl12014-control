classdef PowerPmacWorkingMode < mic.Base
    
    properties
        % {mic.ui.device.GetSetText 1x1}}
        ui
         
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 600
        dHeight = 80
        
        cName = 'power-pmac-working-mode'
        
    end
    
    properties (Access = private)
        
        clock
        hPanel
        dWidthName = 70
        
    end
    
    methods
        
        function this = PowerPmacWorkingMode(varargin)
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
            this.ui.turnOn();
        end
        
        function turnOff(this)
            this.ui.turnOff();
           
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Working Mode',...
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
            
            this.ui.build(this.hPanel, dLeft, dTop);
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
        
         
         
        function initUi(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-text', ...
                'power-pmac-working-mode.json' ...
            );
        
            uiConfig = mic.config.GetSetText(...
                'cPath',  cPathConfig ...
            );
            
            this.ui = mic.ui.device.GetSetText(...
                'cName', this.cName, ...
                'cLabel', 'Working Mode', ...
                'clock', this.clock, ...
                'config', uiConfig, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowInitButton', false, ...
                'dWidthName', 100, ...
                'dWidthVal', 120, ...
                'dWidthStores', 120, ...
                'lShowStores', true ...
            );
        end
        
        
        
        
        
        
        function init(this)
            this.msg('init()');
            this.initUi();
            
            
        end
        
        
        
    end
    
    
end

