classdef MeasurPointLogPlotter < mic.Base
    
    % rcs
    
	properties (Constant)
        
       dDaysBetweenMatlabAndExcel = 693960
       cecChannelNames = {
            '00 - J0', ...
            '01 - J1', ...
            '02 - J2', ...
            '03 - J3', ...
            '04 - J4', ...
            '05 - J5', ...
            '06 - J6', ...
            '07 - J7', ...
            '08 - AMP 2.4 PT1000', ...
            '09 - AMP 3.1 PT1000', ...
            '10 - AMP 1.4 PT1000', ...
            '11 - AMP 2.2 PT1000', ...
            '12 - AMP 2.1 PT1000', ...
            '13 - AMP 3.4 PT1000', ...
            '14 - AMP 2.3 PT1000', ...
            '15 - AMP 3.2 PT1000', ...
            '16 - PO M2 11:00 PT100', ...
            '17 - PO M1 12:00 PT100', ...
            '18 - PO M1 04:00 PT100', ...
            '19 - PO M1 07:30 PT100', ... 
            '20 - AMP 1.1 PT1000', ... 
            '21 - AMP 1.2 PT1000', ... 
            '22 - AMP 1.3 PT1000', ... 
            '23 - AMP 3.3 PT1000', ...
            '24 - MOD3 SP 03:00 PT100', ... 
            '25 - MOD3 SP 07:30 PT100', ...
            '25 - RTD 26 PT100', ...
            '27 - MOD3 SP 12:00 PT100', ... 
            '28 - RTD 28  PT100', ...
            '29 - MOD3 TC 01:30  PT100', ... 
            '30 - PO M2 07:00  PT100', ...
            '31 - P0 M2 02:00  PT100' ... 
        };
       
    end
    
    properties (SetAccess = private)
        
        dWidth              = 1600;
        dHeight             = 960;
       
    
    end
    
    properties (Access = private)
         
        hFigure
        hAxes
        
         % {mic.ui.common.Checkbox 1xm}
        uiCheckboxes
        
        % {mic.ui.common.Text 1xm}
        uiTextValues
        
        uiButtonRefresh
        uiButtonFile
        uiTextFile
        
        uiTextPlotX
        uiTextPlotY
        
        % storage for handles returned by plot()
        hLines
        
        cDir
        cFile
        
        % {struct 1x1} storage of the result struct loaded from JSON
        stResult
        
        % {struct 1x1} computed storage of results in format more useful
        % for plotting
        stResultForPlotting
        
        % {logical 1x1} used to not handle checkboxes when setting them
        % durign the initial load from disk operation
        lLoading
                
        % {double m x n} - storage for data read by CSV file
        % store it so when adjusting checkboxes don't have to read CSV 
        % again
        dData
    end
    
        
    events
        
        
        
    end
    

    
    methods
        
        
        function this = MeasurPointLogPlotter()
            
            this.init();
            
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

            this.cDir = fullfile(cDirThis, '..', '..', 'save');
            this.cFile = '';
            
        end
        
        function delete(this)
                        
            delete(this.hAxes);

            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            

        end
        
        function ce = getUiPropsSaved(this)
            
            ce = {...
                'uiTextFile' ...
            };
        
        end
        
        
        % @return {struct} UI state to save
        function st = save(this)
            
            st = struct();
            st.cDir = this.cDir;
            st.cFile = this.cFile;
            st.dChannelsToPlot = this.getChannelsToPlot();
            
            return;
            
            ceProps = this.getUiPropsSaved();
            for n = 1 : length(ceProps)
                cProp = ceProps{n};
                st.(cProp) = this.(cProp).save();
            end
            
        end
        
        % @param {struct} UI state to load.  See save() for info on struct
        function load(this, st)
                        
            this.lLoading = true;
            
            if isfield(st, 'cDir')
                this.cDir = st.cDir;
            end
            
            if isfield(st, 'cFile')
                this.cFile = st.cFile;
            end
            
            % Set checkboxes to true
            for n = 1 : length(st.dChannelsToPlot)
                dIndex = st.dChannelsToPlot(n) + 1;
                if length(this.uiCheckboxes) >= dIndex
                    this.uiCheckboxes(dIndex).set(true)
                end
            end
            
            
            this.loadFileAndPlot();
            this.lLoading = false;
            
            return;
            
            %{
            ceProps = this.getUiPropsSaved();
            for n = 1 : length(ceProps)
                cProp = ceProps{n};
                if isfield(st, cProp)
                    try
                        this.(cProp).load(st.(cProp));
                    end
                end
            end
            %}
            
            this.lLoading = false;
                        
        end
        
        function build(this)
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end

            
            this.buildFigure();
            this.buildAxes();
            
            dLeft = 10;
            dTop = 10;
            
            this.uiButtonRefresh.build(...
                this.hFigure, ...
                dLeft, ...
                dTop, ...
                100, ...
                24 ...
            );
            dLeft = dLeft + 120;
            
            this.uiButtonFile.build(...
                this.hFigure, ...
                dLeft, ...
                dTop, ...
                100, ...
                24 ...
            );
            
            dLeft = dLeft + 120;
            dTop = dTop + 5;
            this.uiTextFile.build(...
                this.hFigure, ...
                dLeft, ...
                dTop, ...
                1200, ...
                24 ...
            );
        
            dTop = 80;
            dLeft = this.dWidth - 280;
            dWidth = 200;
            for n = 1 : length(this.uiCheckboxes)
                this.uiCheckboxes(n).build(...
                    this.hFigure, ...
                    dLeft, ...
                    dTop + n * 20 , ...
                    dWidth, ...
                    24 ...
                );
            
                this.uiTextValues(n).build(...
                    this.hFigure, ...
                    dLeft + 180, ...
                    dTop + n * 20 + 6, ...
                    100, ...
                    24 ...
                );
            end
            
            dLeft = 100;
            dTop = 80;
            dWidth = 150;
            dHeight = 14;
            this.uiTextPlotX.build(this.hFigure, dLeft, dTop, dWidth, dHeight);
            this.uiTextPlotY.build(this.hFigure, dLeft + dWidth, dTop, dWidth, dHeight);
            
            
            this.plotData();
                
            
        end
        
        % @param {char 1xm} cPath - full path to results.json file
        function setFile(this, cPath)
            
            if (exist(cPath, 'file') ~= 2)
                cMsg = sprintf('setFile() %s is not a valid file', cPath);
                this.msg(cMsg);
                return;
            end
            
            [cDir, cFile, cExt] = fileparts(cPath);
            this.cDir = cDir;
            this.cFile = [cFile, cExt]; % cExt includes the .
            this.loadFileAndPlot();
        end
        
        function refresh(this)
            
            this.loadFileAndPlot();
        end
        
    end
    
    
    methods (Access = private)
        
        function onButtonRefresh(this, src, evt)
            this.refresh();
        end
        
        function onButtonChoose(this, src, evt)
            
            [cFile, cDir] = uigetfile(...
                '*.csv', ...
                'Select a log.csv File', ...
                this.cDir ...
            );
        
            if isequal(cFile, 0)
               return; % User clicked "cancel"
            end
            
            this.cDir = mic.Utils.path2canonical(cDir);
            this.cFile = cFile;
            
            % this.refresh(); 
            
            this.loadFileAndPlot()
                        
        end
        
        function loadFileAndPlot(this)
            
            if isempty(this.cDir)
                return
            end
            
            if isempty(this.cFile)
                return
            end
            
            cPath = fullfile(this.cDir, this.cFile);
            
            if exist(cPath, 'file') ~= 2
                return
            end
            this.uiTextFile.set(cPath);
            
            % Need to load the CSV file, skipping six header lines
            % (use second arg to skip headers)
            
            this.dData = csvread(cPath, 7, 0);
            this.plotData();
            
        end
        
        function plotData(this)
                        
            % Return if figure 
            
            if  isempty(this.hFigure) || ...
                ~ishghandle(this.hFigure)
                return
            end
            if  isempty(this.hAxes) || ...
                ~ishghandle(this.hAxes)
                return
            end
            
            if isempty(this.dData)
                return
            end
            
            
            % Update text values
            % First column is the serial date, so skip it
            for n = 1 : length(this.uiTextValues)
                cVal = sprintf('%1.2f', this.dData(end, n + 1));
                this.uiTextValues(n).set(cVal);
            end
            
                
            % Channels on hardware.  Need to offset by two to 
            % get index of data. Recall that date is added as first 
            % column of data
            
            dChannelsToPlot = this.getChannelsToPlot();
            
            
            
            
            if length(dChannelsToPlot) == 0
                return
            end
            
            plot(this.hAxes, ...
                datetime(this.dData(:, 1) + this.dDaysBetweenMatlabAndExcel, 'ConvertFrom', 'datenum'), ... % x
                this.dData(:, dChannelsToPlot + 2) ... % y
            );
            legend(this.hAxes, this.cecChannelNames(dChannelsToPlot + 1), ...
                'Location','northwest' ...
            );
        
        
            
        end
        
        % Returns a list of channels to plot, zero-indexed, to match the hardware
        % nomenclature. 
        % @return {double 1xm}
        function d = getChannelsToPlot(this)
            
            d = [];
            for n = 1 : length(this.cecChannelNames)
                if this.uiCheckboxes(n).get()
                    d(end + 1) = n;
                end
            end
            
            if ~isempty(d)
                % Subtract 1 to go to zero-indexed channels
                d = d - 1;
            end
            
            % d  = [16:19, 24, 25, 27, 29, 30, 31];
        end
        
        function initUiCheckboxes(this)
            
            this.uiCheckboxes = mic.ui.common.Checkbox(...
                'lChecked', false, ... 
                'cLabel', this.cecChannelNames(1) ...
            );
        
            for n = 2 : length(this.cecChannelNames)
                this.uiCheckboxes(n) = mic.ui.common.Checkbox(...
                    'lChecked', false, ...
                    'cLabel', this.cecChannelNames(n), ...
                    'fhDirectCallback', @this.onUiCheckbox ...
                );
            end
            
        end
        
        function initUiTextValues(this)
            
            this.uiTextValues = mic.ui.common.Text();
        
            for n = 2 : length(this.cecChannelNames)
                this.uiTextValues(n) = mic.ui.common.Text();
            end
            
        end
            
        function init(this)
            
            this.uiButtonFile = mic.ui.common.Button(...
                'cText', 'Choose File', ...
                'fhDirectCallback', @this.onButtonChoose ...
            );
        
            this.uiButtonRefresh = mic.ui.common.Button(...
                'cText', 'Refresh', ...
                'fhDirectCallback', @this.onButtonRefresh ...
            );
        
            this.uiTextFile = mic.ui.common.Text(...
                'cVal', '...' ...
            );
        
            this.initUiCheckboxes();
            this.initUiTextValues();
            this.initUiTextPlotX();
            this.initUiTextPlotY();
            
        end
        
        
        function buildFigure(this)
           
            dScreenSize = get(0, 'ScreenSize');
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'MeasurPoint Log Plotter', ...
                'CloseRequestFcn', @this.onFigureCloseRequest, ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ... 
                'WindowButtonMotionFcn', @this.onFigureWindowMouseMotion, ...
                'WindowButtonDownFcn', @this.onFigureWindowButtonDown, ... % doesn't work if datacursormode is on!
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Toolbar', 'figure', ... % zoom and all of that stuff
                'Visible', 'on' ...
            );
        
            % zoom(this.hFigure, 'on')
            % uitoolbar(this.hFigure)

            
        end
        
        function buildAxes(this)
            
            dLeft = 100;
            dTop = 100;
            
            this.hAxes = axes(...
                'Parent', this.hFigure, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidth - 400, this.dHeight - 200], this.hFigure),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
                        
        end
        

        function onUiCheckbox(this, src, evt)
            
            if this.lLoading
                return
            end
            this.plotData();
        end
        
        
         function onFigureCloseRequest(this, src, evt)
            
             
            if ~isempty(this.hFigure) && ~isvalid(this.hFigure)
                return
            end
            
            delete(this.hFigure);
            this.hFigure = [];
            
         end
         
         
         function onFigureWindowButtonDown(this, src, evt)
            
            % this.showSetAsZeroIfAxesIsClicked();
            
        end
        
        
        function onFigureWindowMouseMotion(this, src, evt)
           
           this.msg('onWindowMouseMotion()');
           this.setTextPlotXPlotYBasedOnAxesCurrentPoint();
        end
        
        
        function setTextPlotXPlotYBasedOnAxesCurrentPoint(this)
            
           % If the mouse is inside the axes, turn the cursor into a
           % crosshair, else make sure it is an arrow
           
           if ~ishandle(this.hFigure)
               return;
           end
           
           if ~ishandle(this.hAxes)
               return;
           end
           
          
           dCursor = get(this.hFigure, 'CurrentPoint');     % [left bottom]
           dAxes = get(this.hAxes, 'Position');             % [left bottom width height]
           dPoint = get(this.hAxes, 'CurrentPoint');
           
           % dPositionPanel = get(this.hPanelData, 'Position');
           
           if isempty(dAxes)
               return;
           end
           
           dCursorLeft =    dCursor(1);
           dCursorBottom =  dCursor(2);
           
           % Need to include left/bottom of container panel to get correct
           % left / bottom of the Axes since its Position is relative to
           % its parent
           
           dAxesLeft =      dAxes(1); %  + dPositionPanel(1);
           dAxesBottom =    dAxes(2); %  + dPositionPanel(2);
           dAxesWidth =     dAxes(3);
           dAxesHeight =    dAxes(4);
           
           if   dCursorLeft >= dAxesLeft && ...
                dCursorLeft <= dAxesLeft + dAxesWidth && ...
                dCursorBottom >= dAxesBottom && ...
                dCursorBottom <= dAxesBottom + dAxesHeight
            
                if strcmp(get(this.hFigure, 'Pointer'), 'arrow')
                    set(this.hFigure, 'Pointer', 'crosshair')
                end
                
                % this.uiTextPlotX.set(sprintf('x: %1.3f', dPoint(1, 1)));
                
                % https://www.mathworks.com/matlabcentral/answers/370074-gca-currentpoint-with-the-datetime-ticks-on-the-x-axis
                t = num2ruler(dPoint(1, 1), this.hAxes.XAxis);
                this.uiTextPlotX.set(datestr(t, 0)); % second arg of datestr is format identifier
                this.uiTextPlotY.set(sprintf('y: %1.3f', dPoint(1, 2)));
           else
                if ~strcmp(get(this.hFigure, 'Pointer'), 'arrow')
                    set(this.hFigure, 'Pointer', 'arrow')
                end
                this.uiTextPlotX.set('x: [hover]');
                this.uiTextPlotY.set('y: [hover]');
           end
        end
        
        
        function initUiTextPlotX(this)
            
            this.uiTextPlotX = mic.ui.common.Text(...
                'cLabel', 'x: ' ...
            );
            
            
        end
        
        
        function initUiTextPlotY(this)
            this.uiTextPlotY = mic.ui.common.Text(...
                'cLabel', 'y: ' ...
            );
        end
        

        
    end
    
    
end