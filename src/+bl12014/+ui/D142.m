classdef D142 < mic.Base
    
    properties
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommGalil
        
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiStageY
        
        % {mic.ui.device.GetNumber 1x1}
        uiCurrent
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 590
        hPanel
        
        configStageY
        configMeasPointVolts
        
         % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    properties (SetAccess = private)
        
        cName = 'd142-'
        dHeight = 90
    end
    
    methods
        
        function this = D142(varargin)
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
            
            
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
        
        end
        
        
       

        
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'D142',...
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
                       
            
            
            this.uiStageY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiCurrent.build(this.hPanel, dLeft, dTop);
            
        end
        
        
        
        
        function delete(this)
            
            
            
        end   
        
        
        function st = save(this)
            st = struct();
            st.uiStageY = this.uiStageY.save();
        end
        
        function load(this, st)
            if isfield(st, 'uiStageY')
                this.uiStageY.load(st.uiStageY)
            end
        end
        
        
    end
    
    
    methods (Access = private)
        
         function initStageY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-d142-stage-y.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', 'd142-stage-y', ...
                'config', uiConfig, ...
                'lShowInitButton', true, ...
                'fhGet', @() this.hardware.getGalilD142().getAxisPosition(0), ...
                'fhSet', @(dVal) this.hardware.getGalilD142().moveAxisAbsolute(0, dVal), ...
                'fhIsReady', @() this.hardware.getGalilD142().getAxisIsReady(0), ...
                'fhStop', @() this.hardware.getGalilD142().stopAxisMove(0), ...
                'fhInitialize', @() mic.Utils.evalAll(...
                    @() this.hardware.getGalilD142().initializeAxis(0) ...
                ), ... % wrap because fhInitialize doesn't expect a return but initializeAxis returns something
                'fhIsInitialized', @() this.hardware.getGalilD142.getAxisIsInitialized(0), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Stage Y' ...
            );
        end
        
        
        
        function initCurrent(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-d142-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiCurrent = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', 'measur-point-d142-diode', ...
                'config', uiConfig, ...
                'cLabel', 'MeasurPoint', ...
                'lShowInitButton', false, ...
                'dWidthPadUnit', 277, ...
                'lShowLabels', false, ...
                'fhGet', @() this.hardware.getDataTranslation().getScanDataOfChannel(34), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true ...
            );
        end
        
        
                
        function init(this)
            this.msg('init()');
            this.initStageY();
            this.initCurrent();
        end
        
       
        
        
        
        
    end
    
    
end

