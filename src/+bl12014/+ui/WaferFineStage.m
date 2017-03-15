classdef WaferFineStage < mic.Base
    
    properties
      
        
        % {< mic.interface.device.GetSetNumber}
        deviceZ
                
        % {mic.ui.device.GetSetNumber 1x1}}
        uiZ
        
                
    end
    
    properties (SetAccess = private)
        
        dWidth = 600
        dHeight = 70
        
    end
    
    properties (Access = private)
        
        clock
        hPanel
        dWidthName = 70
       
        
    end
    
    methods
        
        function this = WaferFineStage(varargin)
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        
        function turnOn(this)
            this.uiZ.turnOn();
        end
        
        function turnOff(this)
            this.uiZ.turnOff();
           
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wafer Fine Stage',...
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
            
            this.uiZ.build(this.hPanel, dLeft, dTop);
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
        
         
         
        function initUiZ(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-fine-stage-z.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiZ = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'cName', 'wafer-fine-stage-z', ...
                'config', uiConfig, ...
                'cLabel', 'Z' ...
            );
        end
        
        
        
        
        function init(this)
            this.initUiZ();
            
        end
        
        
        
    end
    
    
end

