classdef MADiagnostics < mic.Base
    
    properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommNewFocusModel8742

        % {mic.ui.device.GetSetNumber 1x1}
        uiStageMAYag
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiStageWheel
                
    end
    
    properties (Access = private)
        
        clock
        dWidth = 710
        dHeight = 160
        hFigure
        
        dWidthName = 140
        dWidthPadName = 29
        
        configStageY
        configMeasPointVolts
        
    end
    
    properties (SetAccess = private)
        
        cName = 'ma-diagnostics'
    end
    
    methods
        
        function this = MADiagnostics(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        
        
        function connectNewFocusModel8742(this, comm)
            
            device = bl12014.device.GetSetNumberFromNewFocusModel8742(comm, 1); 
            this.uiStageMAYag.setDevice(device);
            this.uiStageMAYag.turnOn()
            this.uiStageMAYag.syncDestination();
            
            device = bl12014.device.GetSetNumberFromNewFocusModel8742(comm, 2); 
            this.uiStageWheel.setDevice(device);
            this.uiStageWheel.turnOn()
            this.uiStageWheel.syncDestination();
            
            
        end
        
        
        function disconnectNewFocusModel8742(this)
            
            this.uiStageMAYag.turnOff()
            this.uiStageMAYag.setDevice([]);
            
            this.uiStageWheel.turnOff()
            this.uiStageWheel.setDevice([]);
            
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
                'Name', 'MADiagnostics Control', ...
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
            
                      
            this.uiCommNewFocusModel8742.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
                        
            this.uiStageMAYag.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStageWheel.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
                        
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
            st.uiStageMAYag = this.uiStageMAYag.save();
            st.uiStageWheel = this.uiStageWheel.save();
            
        end
        
        function load(this, st)
            
            
            if isfield(st, 'uiStageMAYag')
                this.uiStageMAYag.load(st.uiStageMAYag)
            end
            
            if isfield(st, 'uiStageWheel')
                this.uiStageWheel.load(st.uiStageWheel)
            end
            
            
            
        end
    end
    
    methods (Access = private)
        
         function onFigureCloseRequest(this, src, evt)
            this.msg('MADiagnosticsControl.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
         end
        
         
        
        
        function initUiStageMAYag(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-ma-yag-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageMAYag = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthPadName', this.dWidthPadName, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-ma-yag', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'MA YAG (neg=down)' ...
            );
        end
        
        function initUiStageWheel(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-subframe-wheel-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageWheel = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthPadName', this.dWidthPadName, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-subframe-wheel', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'SF Wheel (Pos = CW)' ...
            );
        end
        
        
        
        
        function initUiCommNewFocusModel8742(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommNewFocusModel8742 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 180, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-newfocus-model-8742', this.cName), ...
                'cLabel', 'NewFocus 8742' ...
            );
        
        end
        
        

        function init(this)
            this.msg('init');
            
            this.initUiCommNewFocusModel8742();
            this.initUiStageMAYag();
            this.initUiStageWheel();
            
        end
        
        
        
    end
    
    
end

