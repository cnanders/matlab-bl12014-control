classdef M142 < mic.Base
    
    properties
        
        
        wagoSolenoid
        measPoint
        
        % {< mic.interface.device.GetSetNumber}
        deviceStageX
        
        % {< mic.interface.device.GetSetNumber}
        deviceStageTiltX
        
        % {< mic.interface.device.GetSetNumber}
        deviceStageTiltYMf
        
        % {< mic.interface.device.GetSetNumber}
        deviceStageTiltYMfr
        
        % {< mic.interface.device.GetSetNumber}
        deviceStageTiltZMfr
        
        
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiStageX
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiStageTiltX
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiStageTiltYMf
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiStageTiltYMfr
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiStageTiltZMfr
        
       
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 600
        dHeight = 180
        hFigure
        
        dWidthName = 70
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = M142(varargin)
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
                'Name', 'M142 Control', ...
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
            
            this.uiStageX.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiStageTiltX.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStageTiltYMf.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStageTiltYMfr.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStageTiltZMfr.build(this.hFigure, dLeft, dTop);
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
        
         
        function initUiStageX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m142-stage-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'cName', 'm142-stage-x', ...
                'config', uiConfig, ...
                'cLabel', 'X' ...
            );
        end
        
        function initUiStageTiltX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m142-stage-tilt-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageTiltX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'lShowLabels', false, ...
                'cName', 'm142-stage-tilt-x', ...
                'config', uiConfig, ...
                'cLabel', 'Tilt X' ...
            );
        end
        
        function initUiStageTiltYMf(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m142-stage-tilt-y-mf.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageTiltYMf = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'lShowLabels', false, ...
                'cName', 'm142-stage-tilt-y-mf', ...
                'config', uiConfig, ...
                'cLabel', 'Tilt Y (MF)' ...
            );
        end
        
        function initUiStageTiltYMfr(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m142-stage-tilt-y-mfr.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageTiltYMfr = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'lShowLabels', false, ...
                'cName', 'm142-stage-tilt-y-mfr', ...
                'config', uiConfig, ...
                'cLabel', 'Tilt Y (MFR)' ...
            );
        end
        
        function initUiStageTiltZMfr(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m142-stage-tilt-z-mfr.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageTiltZMfr = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'lShowLabels', false, ...
                'cName', 'm142-stage-tilt-z-mfr', ...
                'config', uiConfig, ...
                'cLabel', 'Tilt Z (MFR)' ...
            );
        end
        
        
        
        
        function init(this)
            this.msg('init');
            this.initUiStageX();
            this.initUiStageTiltX();
            this.initUiStageTiltYMf();
            this.initUiStageTiltYMfr();
            this.initUiStageTiltZMfr();
        end
        
        
        
    end
    
    
end

