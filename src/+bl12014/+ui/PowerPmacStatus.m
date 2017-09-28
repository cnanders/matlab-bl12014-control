classdef PowerPmacStatus < mic.Base
    
    properties (Access = private)
        
        dWidth = 1900
        dHeight = 840
        
        dTopLabels = 50
        dTopUi = 80;
               
    end
    
    properties
              
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDeltaTauPowerPmac
        
        
        % {cell of mic.ui.device.GetLogical m x n}
        uiGetLogicals = {}
        
        % {cell of mic.ui.common.Text 1 x m}
        uiTexts = {}
        
        % {cell of cell 1 x m}
        ceceTypes
        
        cName = 'Power PMAC Status (Updates every 2 sec)'
        hFigure
        
        clock
        dWidthName = 120
        lShowDevice = false
        lShowInitButton = false
        
        %{ cell of char 1xm } list of titles of each status category
        cecTitles 
        
        dWidthColSep = 40
        
        
    end
    
    methods
        
        function this = PowerPmacStatus(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.ceceTypes = bl12014.device.GetLogicalFromDeltaTauPowerPmac.ceceTypes;
            this.cecTitles = {
                'CS Error', ...
                'CS Status', ...
                'Mtr Error', ...
                'Mtr Stat Moving', ...
                'Mtr Stat Open Loop', ...
                'Mtr Stat Neg Lim', ...
                'Mtr Stat Pos Lim', ...
                'Encoder Error', ...
                'Global Error', ...
                'IO Info', ...
                'MET50 Error' ...
            };
            this.init();
            
        end
        
        
        
        
        function buildUiComm(this)
            
            dTop = 10;
            dLeft = 10;
            this.uiCommDeltaTauPowerPmac.build(this.hFigure, dLeft, dTop);
            
        end
        
        function initUiCommDeltaTauPowerPmac(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommDeltaTauPowerPmac = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'delta-tau-power-pmac-power-pmac-status-panel', ...
                'cLabel', 'DeltaTau Power PMAC' ...
            );
        
        end
        
        
        function buildUiGetLogicals(this)
            
            dTopStart = this.dTopUi;
            dTop = dTopStart;
            dLeft = 10;
            dSep = 30;
            
            for m = 1 : length(this.ceceTypes)
                for n = 1 : length(this.ceceTypes{m})
                    this.uiGetLogicals{m}{n}.build(this.hFigure, dLeft, dTop);
                    dTop = dTop + dSep;
                end
                
                % Update dLeft (shift to right)
                dLeft = dLeft + this.dWidthName + this.dWidthColSep + 10;
                % Reset dTop
                dTop = dTopStart;
            end
            
        end
        
        function buildUiTexts(this)
            
            dTopStart = this.dTopLabels;
            dTop = dTopStart;
            dLeft = 10;
            
            for m = 1 : length(this.ceceTypes)
                    
                this.uiTexts{m}.build(this.hFigure, dLeft, dTop, this.dWidthName, 20);
                % Update dLeft (shift to right)
                dLeft = dLeft + this.dWidthName + this.dWidthColSep + 10;
                
            end
            
        end
        
          
        
        function build(this)
            
            if ishghandle(this.hFigure)
                % Bring to front and return
                figure(this.hFigure);
                return
            end
            
            this.buildFigure()
            this.buildUiComm();
            this.buildUiTexts();
            this.buildUiGetLogicals();
                        
                       
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
        
        function buildFigure(this)
            
            % this.connect();
            % this.turnOn();
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', this.cName, ...
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
        end
        
        function onFigureCloseRequest(this, src, evt)
            
            % this.turnOff();
            this.msg('M143Control.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        
                
        function init(this)
            
            this.msg('init()');
            this.initUiCommDeltaTauPowerPmac();
            this.initUiGetLogicals(); 
            this.initUiTexts();
            
        end
        
        function initUiTexts(this)
            
            for m = 1 : length(this.cecTitles)
                this.uiTexts{m} = mic.ui.common.Text(...
                    'cVal', this.cecTitles{m}, ...
                    'dFontSize', 12, ...
                    'cFontWeight', 'bold' ...
                );
            end
        end
        
        
        function initUiGetLogicals(this)
            
            this.msg('initGetLogicals()');
            
            u8WordsToSkip = bl12014.device.GetLogicalFromDeltaTauPowerPmac.u8WordsToSkip;
            
            for m = 1 : length(this.ceceTypes)
                for n = 1 : length(this.ceceTypes{m})                    
                    if n == 1
                        % Initialize cell array
                        this.uiGetLogicals{m} = {};
                    end
            
                    lShowLabels = false;                    

                    cPathConfig = fullfile(...
                        bl12014.Utils.pathUiConfig(), ...
                        'get-logical', ...
                        'config-ping.json' ...
                    );
                    config = mic.config.GetSetLogical(...
                        'cPath', cPathConfig ...
                    );

                    % Make label
                    ceWords = strsplit(this.ceceTypes{m}{n}, '-');
                    cLabel = strjoin(ceWords(u8WordsToSkip(m):end), ' ');
                    this.uiGetLogicals{m}{n} = mic.ui.device.GetLogical(...
                       'clock', this.clock, ...
                       'config', config, ...
                       'dWidthName', this.dWidthName, ... 
                       'lShowDevice', this.lShowDevice, ...
                       'lShowLabels', lShowLabels, ...
                       'lShowInitButton', this.lShowInitButton, ...
                       'cName', this.ceceTypes{m}{n}, ...
                       'cLabel', cLabel ...
                    );
                end
            end            
        end
        
        
        
    end
    
    
end

