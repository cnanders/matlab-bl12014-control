classdef M143 < mic.Base
    
    properties
        
        % UI for hardware comm
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommGalil
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDataTranslationMeasurPoint
                        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiStageY
                
        % {mic.ui.device.GetNumber 1x1}
        uiCurrent
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 610
        dHeight = 170
        hParent
        
        configStageY
        configMeasPointVolts
        
        % {bl12014.Hardware 1x1}
        hardware
    end
    
    properties (SetAccess = private)
        
        cName = 'm143-'
 
    end
    
    methods
        
        function this = M143(varargin)
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
            
            this.hParent = hParent
            dSep = 30;
                        
            
            
            this.uiStageY.build(this.hParent, dLeft, dTop);
            dTop = dTop + 15 + dSep;
                        
            this.uiCurrent.build(this.hParent, dLeft, dTop);
            dTop = dTop + dSep;

            
        end
        
        
       
        
        
        function delete(this)
            
            this.msg('delete');
                        
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
        
         function onFigureCloseRequest(this, src, evt)
            this.msg('M143Control.closeRequestFcn()');
            delete(this.hParent);
            this.hParent = [];
         end
        
         
        function initStageY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m143-stage-y.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            u8Axis = 0;
            this.uiStageY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-y', this.cName), ...
                'config', uiConfig, ...
                'lShowInitButton', true, ...
                'fhGet', @() this.hardware.getGalilM143().getAxisPosition(u8Axis), ...
                'fhSet', @(dVal) this.hardware.getGalilM143().moveAxisAbsolute(u8Axis, dVal), ...
                'fhIsReady', @() this.hardware.getGalilM143().getAxisIsReady(u8Axis), ...
                'fhStop', @() this.hardware.getGalilM143().stopAxisMove(u8Axis), ...
                'fhInitialize', @() mic.Utils.evalAll(...
                    @() this.hardware.getGalilM143().initializeAxis(u8Axis) ...
                ), ... % wrap because fhInitialize doesn't expect a return but initializeAxis returns something
                'fhIsInitialized', @() this.hardware.getGalilM143.getAxisIsInitialized(u8Axis), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Y' ...
            );
        end
        
        
        
        function initCurrent(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-m143-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiCurrent = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-current', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Current', ...
                'dWidthPadUnit', 277, ...
                'lShowLabels', false, ...
                'fhGet', @() this.hardware.getDataTranslation().getScanDataOfChannel(35), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true ...
            );
        end
        
        
        
        
        function init(this)
            
            this.msg('init');
            this.initStageY();
            this.initCurrent();
        end
        
        
        
    end
    
    
end

