classdef D141 < mic.Base
    
    properties
        
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommWago
        
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
        dHeight = 150
        hPanel
        
        configStageY
        configMeasPointVolts
        
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    properties (SetAccess = private)
        
        cName = 'd141-'
    end
    
    methods
        
        function this = D141(varargin)
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
        
        % @param {modbus 1x1}
        function connectWago(this, m)
            
            import bl12014.device.GetSetLogicalFromWagoIO750
            device = GetSetLogicalFromWagoIO750(m, 'd141');
            this.uiStageY.setDevice(device);
            this.uiStageY.turnOn();
            
        end
        
        function disconnectWago(this)
            this.uiStageY.turnOff();
            this.uiStageY.setDevice([])
        end
            
           
        

       
        
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'D141',...
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
            
            this.uiCommWago.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslationMeasurPoint.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiStageY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCurrent.build(this.hPanel, dLeft, dTop);
            
        end
        
        
        
        
        function delete(this)
            
            
            
            
        end  
        
        function st = save(this)
            
            st = struct();
            % st.uiStageY = this.uiStageY.save();
            
        end
        
        function load(this, st)
            %{
            if isfield(st, 'uiStageY')
                this.uiStageY.load(st.uiStageY)
            end
            %}
        end
        
        
    end
    
    
    methods (Access = private)
        
         function initUiStageY(this)
            
             
             
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Remove', ...
                'cTextFalse', 'Insert' ...
            };

            this.uiStageY = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'd141-stage-y', ...
                'cLabel', 'Stage Y' ...
            );
        
         end
        
         function d = getCurrent(this)
            % channel 33 on hardware zero-indexed
            dData = this.hardware.getDataTranslation().getScanData();
            d = dData(33 + 1);
        end
        
        
        function initUiCurrent(this)
            
            this.msg('initUiCurrent()');
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-d141-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiCurrent = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', [this.cName, 'measur-point'], ...
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
        
        function initUiCommWago(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommWago = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'wago-d141', ...
                'cLabel', 'Wago (Insert/Remove)' ...
            );
        
        end
        
        function init(this)
            
            this.msg('init()');
            this.initUiStageY();
            this.initUiCurrent();
            this.initUiCommWago();
            this.initUiCommDataTranslationMeasurPoint();
        end
        
        function onFigureCloseRequest(this, src, evt)
            this.msg('closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        
        
        
    end
    
    
end

