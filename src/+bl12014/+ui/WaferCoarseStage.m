classdef WaferCoarseStage < mic.Base
    
    properties
            
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiX
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiY
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiZ
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiTiltX
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiTiltY
        
        
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 600
        dHeight = 190
        
        cName = 'wafer-coarse-stage'
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 70
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = WaferCoarseStage(varargin)
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        
        function turnOn(this)
            
            this.uiX.turnOn();
            this.uiY.turnOn();
            this.uiZ.turnOn();
            this.uiTiltX.turnOn();
            this.uiTiltY.turnOn();
            
        end
        
        function turnOff(this)
            this.uiX.turnOff();
            this.uiY.turnOff();
            this.uiZ.turnOff();
            this.uiTiltX.turnOff();
            this.uiTiltY.turnOff();
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wafer Coarse Stage',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;            

            dTop = 20;
            dLeft = 10;
            dSep = 30;
            
            this.uiX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiZ.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiTiltX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiTiltY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            

            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end    
        
        
    end
    
    methods (Access = private)
        
         function onFigureCloseRequest(this, src, evt)
            this.msg('M141Control.closeRequestFcn()');
            delete(this.hPanel);
         end
        
         
        function initUiX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-x', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'X' ...
            );
        end
        
        function initUiY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-y.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-y', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Y' ...
            );
        end
        
        function initUiZ(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-z.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiZ = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-z', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Z' ...
            );
        end
        
        
        function initUiTiltX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-angle-urad.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiTiltX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-tilt-x', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Tilt X' ...
            );
        end
        
        function initUiTiltY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-angle-urad.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiTiltY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-tilt-y', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Tilt Y' ...
            );
        end
        
        
        function init(this)
            this.msg('init()');
            this.initUiX();
            this.initUiY();
            this.initUiZ();
            this.initUiTiltX();
            this.initUiTiltY();
            
        end
        
        
        
    end
    
    
end

