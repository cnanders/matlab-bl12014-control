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
        hFigure
        
        configStageY
        configMeasPointVolts
        
    end
    
    properties (SetAccess = private)
        
        cName = 'm143'
 
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
            
            this.init();
        
        end
        
        function connectDataTranslationMeasurPoint(this, comm)
            
           import bl12014.device.GetNumberFromDataTranslationMeasurPoint

           device = GetNumberFromDataTranslationMeasurPoint(...
                comm, ...
                GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, ...
                35 ...
            );
            this.uiCurrent.setDevice(device);
            this.uiCurrent.turnOn()     
        end
        
        function disconnectDataTranslationMeasurPoint(this)
            this.uiCurrent.turnOff();
            this.uiCurrent.setDevice([]);
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
                        
            this.uiCommGalil.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslationMeasurPoint.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiStageY.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
                        
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
                'cName', sprintf('%s-y', this.cName), ...
                'config', uiConfig, ...
                'lShowInitButton', true, ...
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
                'cName', sprintf('%s-data-translation-measur-point', this.cName), ...
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
                'cName', sprintf('%s-galil', this.cName), ...
                'cLabel', 'Galil' ...
            );
        
        end
        
        function init(this)
            
            this.msg('init');
            this.initStageY();
            this.initCurrent();
            this.initUiCommGalil();
            this.initUiCommDataTranslationMeasurPoint();
        end
        
        
        
    end
    
    
end

