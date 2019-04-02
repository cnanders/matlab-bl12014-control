classdef D142 < mic.Base
    
    properties
        
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
        dWidth = 590
        dHeight = 165
        hPanel
        
        configStageY
        configMeasPointVolts
        
         % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    properties (SetAccess = private)
        
        cName = 'd142-'
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
        
        function connectGalil(this, comm)
            device = bl12014.device.GetSetNumberFromStage(comm, 0);
            this.uiStageY.setDevice(device);
            this.uiStageY.turnOn();
            this.uiStageY.syncDestination();
            
        end
        
        function disconnectGalil(this)
            this.uiStageY.turnOff();
            this.uiStageY.setDevice([]);
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
                        
            this.uiCommGalil.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslationMeasurPoint.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
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
                'cLabel', 'Stage Y' ...
            );
        end
        
        function d = getCurrent(this)
            % channel 34 on hardware zero-indexed
            dData = this.hardware.getDataTranslation().getScanData();
            d = dData(34 + 1);
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
                'lShowInitButton', true, ...
                'dWidthPadUnit', 277, ...
                'lShowLabels', false, ...
                'fhGet', @() this.getCurrent(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true ...
            );
        end
        
        function initUiCommDataTranslationMeasurPoint(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommDataTranslationMeasurPoint = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'fhGet', @() this.hardware.getIsConnectedDataTranslation(), ...
                'fhSet', @(lVal) this.hardware.setIsConnectedDataTranslation(lVal), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'data-translation-measur-point'], ...
                'cLabel', 'DataTrans MeasurPoint' ...
            );
        
        end
        
        function initUiCommGalil(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommGalil = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'galil-d142', ...
                'cLabel', 'Galil' ...
            );
        
        end
        
        function init(this)
            this.msg('init()');
            this.initStageY();
            this.initCurrent();
            this.initUiCommGalil();
            this.initUiCommDataTranslationMeasurPoint();
        end
        
       
        
        
        
        
    end
    
    
end

