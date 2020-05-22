classdef Undulator < mic.Base
    
    properties
        
    end
    
    properties (Access = protected)
        
    end
    
    properties (SetAccess = private)
        
        cName = 'bl12-undulator'
        
        % GetSetNumber config
        dWidthName = 100
        
        uiClock
        hardware
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiGap
        
    end
    
    methods
        
        function this = Undulator(varargin)
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
            
            this.init();
        
        end
        
                
        function build(this, hParent, dLeft, dTop)
            this.uiGap.build(hParent, dLeft, dTop);
            
        end
        
        
        
        function delete(this)
   
        end  
        
        function cec = getSaveLoadProps(this)
            cec = {};
        end
        
        
        function st = save(this)
             cecProps = this.getSaveLoadProps();
            
            st = struct();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                if this.hasProp( cProp)
                    st.(cProp) = this.(cProp).save();
                end
            end

             
        end
        
        function load(this, st)
                        
            cecProps = this.getSaveLoadProps();
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
        
             
        function initUiGap(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-undulator-gap.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiGap = mic.ui.device.GetSetNumber(...
                'clock', this.uiClock, ...
                'lShowLabels', false, ...
                ...'dWidthName', 150, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                ... % 'dWidthUnit', this.dWidthUiDeviceUnit, ...
                'fhGet', @() this.hardware.getBL1201CorbaProxy().SCA_getIDGap(), ...
                'fhSet', @(dVal) this.hardware.getBL1201CorbaProxy().SCA_setIDGap(dVal), ...
                'fhIsReady', @() ~this.hardware.getBL1201CorbaProxy().SCA_getIDMotionComplete(), ...
                'fhStop', @() [], ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'gap'], ...
                'config', uiConfig, ...
                'cLabel', 'Undulator Gap' ...
            );
        end
        

        function init(this)
            this.msg('init()');
            this.initUiGap();
        end

        
    end
    
    
end

