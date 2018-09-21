classdef ReticleFineStage < mic.Base
    
    properties

        % {mic.ui.device.GetSetNumber 1x1}}
        uiX
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiY
        
    end
    
    properties (SetAccess = private)
        
        dWidth = 730
        dHeight = 100
        
        cName = 'ReticleFineStage'
        
        lShowRange = true
        lShowStores = false
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 70
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = ReticleFineStage(varargin)
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
            import bl12014.device.GetNumberFromDeltaTauPowerPmac
            
            % Devices
            deviceFineX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_FINE_X);
            deviceFineY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_FINE_Y);
            
             % Set Devices 
            this.uiX.setDevice(deviceFineX);
            this.uiY.setDevice(deviceFineY);
            
            % Turn on
            this.uiX.turnOn();
            this.uiY.turnOn();
            
            this.uiX.syncDestination();
            this.uiY.syncDestination();
            


        end
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.uiX.turnOff();
            this.uiY.turnOff();
          
            this.uiX.setDevice([]);
            this.uiY.setDevice([]);
            
                 
        end
        
        
        function turnOn(this)
            
            this.uiX.turnOn();
            this.uiY.turnOn();
            
            
        end
        
        function turnOff(this)
            this.uiX.turnOff();
            this.uiY.turnOff();
           
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Reticle Fine Stage (PPMAC)',...
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
            
            this.uiY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
           
            
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
            st.uiY = this.uiY.save();
            
        end
        
        function load(this, st)
            if isfield(st, 'uiX')
                this.uiX.load(st.uiX)
            end
            
            if isfield(st, 'uiY')
                this.uiY.load(st.uiY)
            end
            
            
        end
        
        
    end
    
    methods (Access = private)
                
         
        function initUiX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-reticle-fine-stage-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'cName', 'reticle-fine-stage-x', ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'cLabel', 'X' ...
            );
        end
        
        function initUiY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-reticle-fine-stage-y.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', 'reticle-fine-stage-y', ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'cLabel', 'Y' ...
            );
        end
        
        
        
        function init(this)
            this.msg('init()');
            this.initUiX();
            this.initUiY();
            
        end
        
        
        
    end
    
    
end

