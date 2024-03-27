classdef FluxLogger < mic.Base
    
    properties
            
        uiIndicator
        uiGS
        uiSetLog
        uibSetFlux

        cLabel

        
    end
    
    properties (Access = private)
        

        clock
        
        dWidthName = 200
        dWidth = 600;
        dHeight = 60;

        fhGetter
        fhIsLogged
        fhSetFlux

        cName

        cConfigFile = 'config-amps.json'
        

        u8FalseColor = [1, 0.75, 0.75]
        cBlankColor = 'gray'
        
    end
    
    
    methods
        
        function this = FluxLogger(varargin)
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
            
            
            
            this.init();
            
        end

        function init(this)

            switch this.cBlankColor
                case 'gray'
                    this.u8FalseColor = [0.75, 0.75, 0.75];
                case 'yellow'
                    this.u8FalseColor = [0.8, 0.8, 0];
                case 'orange'
                        this.u8FalseColor = [0.8, 0.4, 0];
                case 'red'
                    this.u8FalseColor = [0.8, 0.4, 0.4];
                case 'purple'
                    this.u8FalseColor = [0.8, 0.4, 0.8];
            end


            this.uiGS = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', [this.cName, '-', this.cLabel], ... 
                'config', mic.config.GetSetNumber(...
                            'cPath',  fullfile(...
                                bl12014.Utils.pathUiConfig(), ...
                                'get-number', ...
                                this.cConfigFile ...
                            ) ...
                        ), ...
                'cLabel', this.cLabel, ...
                'dWidthName', 150,...
                'dWidthPadUnit', 0, ...
                'lShowInitButton', false, ...
                'lShowLabels', false, ...
                'fhGet',@() this.fhGetter(), ...
                'fhIsVirtual', @() false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lUseFunctionCallbacks', true ...
            );

            this.uiIndicator = mic.ui.device.GetLogical(...
                'clock', this.clock, ...
                'config', mic.config.GetSetLogical(...
                    'cPath',  fullfile(...
                        bl12014.Utils.pathUiConfig(), ...
                        'get-logical', ...
                        'config-sms.json' ...
                    ) ...
                ), ...
                'dWidthName', 1, ...  
                'lShowDevice', false, ...
                'lShowLabels', false, ...
                'lShowInitButton', false, ...
                'fhIsVirtual', @() false, ...
                'fhGet', @() this.fhIsLogged(), ...
                'lUseFunctionCallbacks', true, ...
                'u8FalseColor', this.u8FalseColor, ...
                'cName', [this.cLabel, '-indicator']...
            );

            this.uibSetFlux = mic.ui.common.Button(...
                'cText', 'Write Flux to Log', ...
                'fhDirectCallback', @(src, evt) this.fhSetFlux() ...
            );
            

        end

        function val =  getValCal(this)
            val = abs(this.uiGS.getValCal(this.getUnit()));
        end

        function unit = getUnit(this)
            unit = this.uiGS.getUnit().name;
        end

        function build(this, hParent, dLeft, dTop)
            this.uiIndicator.build(hParent, dLeft, dTop);
            this.uiGS.build(hParent, dLeft + 100, dTop);
            this.uibSetFlux.build(hParent, dLeft + 420, dTop, 120, 24);
        end
    
                
        
        
    end
    
    
end

