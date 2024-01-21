classdef WaferStageSpeed < mic.Base
    
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
        
        % {bl12014.Hardware 1x1}
        hardware
    end
    
    methods
        
        function this = WaferStageSpeed(varargin)
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
                'Title', 'Wafer stage speed (PPMAC)',...
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
                'config-wafer-stage-speed.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-x', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', false, ...
                'lShowStep', false, ...
                'lShowStepNeg', false, ...
                'lShowStepPos', false, ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getDemandSpeedWaferCoarse(), ...
                'fhSet', @(dVal) this.hardware.getDeltaTauPowerPmac().setDemandSpeedWaferCoarse(dVal), ...
                'fhIsReady', @() true, ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'lShowUnit', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'cLabel', 'Stage Speed' ...
            );
        end
        
        
        
        
        function init(this)
            this.msg('init()');
            this.initUiX();
            
        end
        
        
        
    end
    
    
end

