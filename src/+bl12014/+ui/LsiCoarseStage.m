classdef LsiCoarseStage < mic.Base
    
    properties
                
        % {mic.ui.device.GetSetNumber 1x1}}
        uiX
        
                
    end
    
    properties (SetAccess = private)
        
        dWidth = 730
        dHeight = 70
        cName = 'lsi-coarse-stage'
        
    end
    
    properties (Access = private)
        
        clock
        hPanel
        dWidthName = 70
        lShowRange = true
    end
    
    methods
        
        function this = LsiCoarseStage(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        function connectDeltaTauPowerPmac(this, comm)
            
            import bl12014.device.GetSetNumberFromDeltaTauPowerPmac
            import bl12014.device.GetSetTextFromDeltaTauPowerPmac
            
            deviceX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_LSI_COARSE_X);
            this.uiX.setDevice(deviceX);
            this.uiX.turnOn();
            this.uiX.syncDestination();

            
        end
        
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.uiX.turnOff();
            this.uiX.setDevice([]);
           
        end
        
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'LSI Coarse Stage (PPMAC)',...
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
            
            this.uiX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
                     
            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end 
        
        function st = save(this)
            st = struct();
            st.uiX = this.uiX.save();
            
        end
        
        function load(this, st)
            if isfield(st, 'uiX')
                this.uiX.load(st.uiX)
            end
            
        end
        
        
    end
    
    methods (Access = private)
        
         
         
        function initUiX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-lsi-coarse-stage-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-z', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'cLabel', 'X' ...
            );
        end
        
        
        
        
        function init(this)
            this.msg('init()');
            this.initUiX();
            
        end
        
        
        
    end
    
    
end

