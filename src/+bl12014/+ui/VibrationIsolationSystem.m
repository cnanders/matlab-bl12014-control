classdef VibrationIsolationSystem < mic.Base
    
    properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommGalil
       
        % {mic.ui.device.GetSetNumber 1x1}
        uiStage1
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiStage2
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiStage3
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiStage4
        
       
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 630
        dHeight = 200
        hFigure
        
        dWidthName = 70
        dWidthPadName = 29
                
    end
    
    properties (SetAccess = private)
        
        cName = 'vibration-isolation-system'
    end
    
    methods
        
        function this = VibrationIsolationSystem(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
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
                'Name', 'Vibration Isolation System Control', ...
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
            dTop = dTop + 15 + dSep;
                       
            this.uiStage1.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStage2.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStage3.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStage4.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            

            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end    
        
        
        
    end
    
    methods (Access = private)
        
         function onFigureCloseRequest(this, src, evt)
            this.msg('M141Control.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
         end
               
        
        function initUiStage1(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-vibration-isolation-system-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStage1 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthPadName', this.dWidthPadName, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-1', this.cName), ...
                'config', uiConfig, ...
                'cLabel', '1' ...
            );
        end
        
        function initUiStage2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-vibration-isolation-system-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStage2 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthPadName', this.dWidthPadName, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-2', this.cName), ...
                'config', uiConfig, ...
                'cLabel', '2' ...
            );
        end
        
        function initUiStage3(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-vibration-isolation-system-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStage3 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthPadName', this.dWidthPadName, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-3', this.cName), ...
                'config', uiConfig, ...
                'cLabel', '3' ...
            );
        end
        
        function initUiStage4(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-vibration-isolation-system-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStage4 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthPadName', this.dWidthPadName, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-4', this.cName), ...
                'config', uiConfig, ...
                'cLabel', '4' ...
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
                'cName', sprintf('%s-galil-dmc-4143', this.cName), ...
                'cLabel', 'Galil DMC 4143' ...
            );
        
        end
        
        
        

        function init(this)
            this.msg('init');
            
            this.initUiCommGalil();
            this.initUiStage1();
            this.initUiStage2();
            this.initUiStage3();
            this.initUiStage4();
        end
        
        
        
    end
    
    
end

