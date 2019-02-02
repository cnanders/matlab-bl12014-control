classdef WaferFineStage < mic.Base
    
    properties
                      
        % {mic.ui.device.GetSetNumber 1x1}}
        uiZ
        
                
    end
    
    properties (SetAccess = private)
        
        dWidth = 730
        dHeight = 70
        cName = 'wafer-fine-stage'
        
    end
    
    properties (Access = private)
        
        clock
        hPanel
        dWidthName = 70
       
        lShowRange = true
        
        % {bl12014.Hardware 1x1}
        hardware
    end
    
    methods
        
        function this = WaferFineStage(varargin)
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
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wafer Fine Stage (PPMAC)',...
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
        
        function st = save(this)
            st = struct();
            st.uiZ = this.uiZ.save();
            
        end
        
        function load(this, st)
            if isfield(st, 'uiZ')
                this.uiZ.load(st.uiZ)
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
                'cName', sprintf('%s-z', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getZWaferFine(), ...
                'fhSet', @(dVal) this.hardware.getDeltaTauPowerPmac().setZWaferFine(dVal), ...
                'fhIsReady', @() ~this.hardware.getDeltaTauPowerPmac().getIsStartedWaferFineZ(), ...
                'fhStop', @() this.hardware.getDeltaTauPowerPmac().stopAll(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Z' ...
            );
        end
        
        
        
        
        function init(this)
            this.msg('init()');
            this.initUiZ();
            
        end
        
        
        
    end
    
    
end

