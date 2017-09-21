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
        dWidth = 610
        dHeight = 230
        hFigure
        
        configStageY
        configMeasPointVolts
        
        
    end
    
    properties (SetAccess = private)
        
        cName = 'm141'
    end
    
    methods
        
        function this = M141(varargin)
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        
        
        
        function build(this)
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'M141 Control', ...
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
            
            this.uiCommSmarActMcsM141.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslationMeasurPoint.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            this.uiStageX.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiStageTiltX.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStageTiltY.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCurrent.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;

            
        end
        
        
       
        
        
        function delete(this)
            
            this.msg('delete');
            
            % Clean up clock tasks
            
            %{
            if (isvalid(this.cl))
                this.cl.remove(this.id());
            end
            %}
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end   
        
        %{
        function connectSmarActMcsM141(this, comm)
            
            % {< mic.interface.device.GetSetNumber}
            deviceX = bl12014.device.GetSetNumberFromStage(comm, 1);

            % {< mic.interface.device.GetSetNumber}
            deviceTiltX = bl12014.device.GetSetNumberFromStage(comm, 2);

            % {< mic.interface.device.GetSetNumber}
            deviceTiltY = bl12014.device.GetSetNumberFromStage(comm, 3);
            
            this.uiStageX.setDevice(deviceX);
            this.uiStageTiltX.setDevice(deviceTiltX);
            this.uiStageTiltY.setDevice(deviceTiltY);
            
        end
        
        function disconnectSmarActMcsM141(this)
            
            this.uiStageX.setDevice([]);
            this.uiStageTiltX.setDevice([]);
            this.uiStageTiltY.setDevice([]);
            
        end
        
        
        function connectDataTranslationMeasurPoint(this, comm)
            
            u8Channel = 1;
            % {< mic.interface.device.GetNumber}
            device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, u8Channel);
            this.uiCurrent.setDevice(device);
        end
        
        function disconnectDataTranslationMeasurPoint(this)
            
            this.uiCurrent.setDevice([]);
        end
        
        %}
        
        
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
                'cName', sprintf('%s-current', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Current', ...
                'dWidthPadUnit', 277, ...
                'lShowInitButton', true, ...
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
                'cName', 'data-translation-measur-point-m141', ...
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

