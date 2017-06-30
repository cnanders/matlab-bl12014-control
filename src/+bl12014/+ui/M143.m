classdef M143 < mic.Base
    
    properties
        
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiGalil
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiDataTranslationMeasurPoint
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiStageY
                
        % {mic.ui.device.GetNumber 1x1}
        uiMeasPointVolts
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 580
        dHeight = 170
        hFigure
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = M143(varargin)
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
                'Name', 'M143 Control', ...
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
                        
            this.uiGalil.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiDataTranslationMeasurPoint.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiStageY.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
                        
            this.uiMeasPointVolts.build(this.hFigure, dLeft, dTop);
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
        
        
    end
    
    methods (Access = private)
        
         function onFigureCloseRequest(this, src, evt)
            this.msg('M143Control.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
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
            
            this.uiStageY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', 'm143-stage-y', ...
                'config', uiConfig, ...
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
        
            this.uiMeasPointVolts = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', 'm143-current', ...
                'config', uiConfig, ...
                'cLabel', 'Current', ...
                'dWidthPadUnit', 277, ...
                'lShowLabels', false ...
            );
        end
        
        function initUiDataTranslationMeasurPoint(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiDataTranslationMeasurPoint = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'data-translation-measur-point-d142', ...
                'cLabel', 'DataTrans MeasurPoint' ...
            );
        
        end
        
        function initUiGalil(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiGalil = mic.ui.device.GetSetLogical(...
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
            
            this.msg('init');
            this.initStageY();
            this.initCurrent();
            this.initUiGalil();
            this.initUiDataTranslationMeasurPoint();
        end
        
        
        
    end
    
    
end

