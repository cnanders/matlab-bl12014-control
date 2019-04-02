classdef M141 < mic.Base
    
    properties
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommSmarActMcsM141
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDataTranslationMeasurPoint

        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiStageX
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiStageTiltX
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiStageTiltY
        
        % {mic.ui.device.GetNumber 1x1}
        uiCurrent
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 590
        dHeight = 225
        
        configStageY
        configMeasPointVolts
        
        hPanel
        
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    properties (SetAccess = private)
        
        cName = 'm141-'
    end
    
    methods
        
        function this = M141(varargin)
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
        
        
        function connectSmarActMcs(this, comm)
            
            device = bl12014.device.GetSetNumberFromStage(comm, 0);
            this.uiStageX.setDevice(device);
            this.uiStageX.turnOn();
            this.uiStageX.syncDestination();
            
            % {< mic.interface.device.GetSetNumber}
            deviceTiltX = bl12014.device.GetSetNumberFromStage(comm, 1);

            % {< mic.interface.device.GetSetNumber}
            deviceTiltY = bl12014.device.GetSetNumberFromStage(comm, 2);
            
            this.uiStageTiltX.setDevice(deviceTiltX);
            this.uiStageTiltY.setDevice(deviceTiltY);
            
            this.uiStageTiltX.turnOn();
            this.uiStageTiltY.turnOn();
            
            
            
        end
        
        function disconnectSmarActMcs(this, comm)
            this.uiStageX.turnOff();
            this.uiStageX.setDevice([]);
            
            this.uiStageX.turnOff();
           this.uiStageTiltX.turnOff();
            this.uiStageTiltY.turnOff();
            
            this.uiStageX.setDevice([]);
            this.uiStageTiltX.setDevice([]);
            this.uiStageTiltY.setDevice([]);
            
        end
        

        
        
        
                
        function build(this, hParent, dLeft, dTop)
            
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'M141',...
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
            
            this.uiCommSmarActMcsM141.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslationMeasurPoint.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            this.uiStageX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            this.uiStageTiltX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStageTiltY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCurrent.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;

            
        end
        
        
       
        
        
        function delete(this)
            
            
            
        end   
        
        function st = save(this)
            st = struct();
            st.uiStageX = this.uiStageX.save();
        end
        
        function load(this, st)
            if isfield(st, 'uiStageY')
                this.uiStageX.load(st.uiStageX)
            end
        end
        
        
    end
    
    methods (Access = private)
        
         function onFigureCloseRequest(this, src, evt)
            this.msg('M141Control.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
         end
        
         
        function initUiStageX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m141-stage-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-x', this.cName), ...
                'config', uiConfig, ...
                'lShowInitButton', true, ...
                'cLabel', 'X' ...
            );
        end
        
        function initUiStageTiltX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m141-stage-tilt-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageTiltX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-tilt-x', this.cName), ...
                'config', uiConfig, ...
                'lShowInitButton', true, ...
                'cLabel', 'Tilt X' ...
            );
        end
        
        function initUiStageTiltY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m141-stage-tilt-y.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageTiltY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-tilt-y', this.cName), ...
                'config', uiConfig, ...
                'lShowInitButton', true, ...
                'cLabel', 'Tilt Y' ...
            );
        end
        
        
        function d = getCurrent(this)
            % channel 32
            dData = this.hardware.getDataTranslation().getScanData();
            d = dData(32 + 1);
        end
        
        function initUiCurrent(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-m141-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiCurrent = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', [this.cName, 'current'], ... 
                'config', uiConfig, ...
                'cLabel', 'Current', ...
                'dWidthPadUnit', 277, ...
                'lShowInitButton', true, ...
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
                'cLabel', 'Data Trans MeasurPoint' ...
            );
        
        end
        
        function initUiCommSmarActMcsM141(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommSmarActMcsM141 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'smaract-mcs-m141', ...
                'cLabel', 'SmarAct MCS M141' ...
            );
        
        end
        
        function init(this)
            
            this.msg('init');
            this.initUiStageX();
            this.initUiStageTiltX();
            this.initUiStageTiltY();
            this.initUiCurrent();
            this.initUiCommSmarActMcsM141();
            this.initUiCommDataTranslationMeasurPoint();
        end
        
        
        
    end
    
    
end

