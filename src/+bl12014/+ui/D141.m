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
        dWidth = 610
        dHeight = 170
        hFigure
        
        configStageY
        configMeasPointVolts
        
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
            
           
        
        function connectDataTranslationMeasurPoint(this, comm)
            
            import bl12014.device.GetNumberFromDataTranslationMeasurPoint
            device = GetNumberFromDataTranslationMeasurPoint(...
                comm, ...
                GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, ...
                33 ...
            );
            this.uiCurrent.setDevice(device);
            this.uiCurrent.turnOn()
        end
       
        function disconnectDataTranslationMeasurPoint(this)
            this.uiCurrent.turnOff();
            this.uiCurrent.setDevice([]);
        end
        
        function build(this)
            
            this.msg('D141.build()');
            
            if ishghandle(this.hFigure)
                cMsg = sprintf(...
                    'D141.build() ishghandle(%1.0f) === true', ...
                    this.hFigure ...
                );
                this.msg(cMsg);
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'D141 Control', ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onFigureCloseRequest ...
            );
                        
            drawnow;

            dTop = 10;
            dLeft = 10;
            dSep = 30;
            
            this.uiCommWago.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslationMeasurPoint.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            this.uiStageY.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiCurrent.build(this.hFigure, dLeft, dTop);
            
        end
        
        
        
        
        function delete(this)
            
            this.msg('delete');
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
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
                'cName', 'measur-point-d141-diode', ...
                'config', uiConfig, ...
                'cLabel', 'MeasurPoint', ...
                'lShowInitButton', true, ...
                'dWidthPadUnit', 277, ...
                'lShowLabels', false ...
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
                'cName', 'data-translation-measur-point-d141', ...
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
                'cLabel', 'Wago' ...
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

