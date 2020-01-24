classdef LogPlotter < mic.Base
    
    % rcs
    
	properties (Constant)
        
       dDaysBetweenMatlabAndExcel = 693960
       cecChannelNames = {
            '00 - AHU CW Inlet', ...
            '01 - AHU Air Inlet', ...
            '02 - AHU Mixed Air', ...
            '03 - AHU Chilled Air', ...
            '04 - ES Lid Mat', ...
            '05 - ES Lid Air', ...
            '06 - ES Floor Air', ...
            '07 - ES UA Floorplate', ...
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
            '31 - P0 M2 02:00  PT100', ... 
            '32 - Volts', ...
            '33 - Volts', ...
            '34 - Volts', ...
            '35 - Photo Current (V)', ...
            '36 - Shutter 5VTTL', ...
            '37 - DMI Laser Power ', ...
            '38 - Volts', ...
            '39 - Volts', ...
            '40 - Volts', ...
            '41 - Volts', ...
            '42 - Volts', ...
            '43 - Volts', ...
            '44 - Volts', ...
            '45 - Volts', ...
            '46 - Volts', ...
            '47 - Volts', ...
            'DMI AC 1', ...
            'DMI AC 2', ...
            'DMI AC 3', ...
            'DMI AC 4', ...
            'DMI DC 1', ...
            'DMI DC 2', ...
            'DMI DC 3', ...
            'DMI DC 4' ... 
            'MotMin WCX', ...
            'MotMin WCY', ...
            'MotMin RCX', ...
            'MotMin RCY', ...
            'MotMin LSIX', ...
            'VIS Encoder 0', ...
            'VIS Encoder 1', ...
            'VIS Encoder 2', ...
            'VIS Encoder 3', ...
        };
       
    end
    
    properties (SetAccess = private)
        
        dWidth              = 1600;
        dHeight             = 960;
       
        cName = 'log-plotter-'
    end
    
    properties (Access = private)
         
        hParent
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
        
        uiToggleLive
        
        uiButtonSaveLive
        
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
        
        % {bl12014.Hardware 1x1}
        hardware
        
        % {mic.clock 1x1}
        % clock
        
        % {mic.ui.clock 1x1}
        uiClock
        
        uiCheckboxAutoScaleY
        uiEditYMax
        uiEditYMin
    end
    
        
    events
        
        
        
    end
    

    
    methods
        
        
        function this = LogPlotter(varargin)
            
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
%             if ~isa(this.clock, 'mic.Clock')
%                 error('clock must be mic.Clock');
%             end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
            
            
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
            this.cDir = fullfile(cDirThis, '..', '..', 'save');
            this.cFile = '';
            
        end
        
        function delete(this)
                        
            delete(this.hAxes);
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
            
            st.uiEditYMin = this.uiEditYMin.save();
            st.uiEditYMax = this.uiEditYMax.save();
            st.uiCheckboxAutoScaleY = this.uiCheckboxAutoScaleY.save();
            
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
            
            if isfield(st, 'uiEditYMin')
                this.uiEditYMin.load(st.uiEditYMin);
            end
            
            if isfield(st, 'uiEditYMax')
                this.uiEditYMax.load(st.uiEditYMax);
            end
            
            if isfield(st, 'uiCheckboxAutoScaleY')
                this.uiCheckboxAutoScaleY.load(st.uiCheckboxAutoScaleY);
            end
            
            
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
        
        function build(this, hParent, dLeft, dTop)
            
            this.hParent = hParent;
            this.buildAxes();
            
            dLeft = 10;
            dTop = 10;
            
            
            this.uiButtonRefresh.build(...
                this.hParent, ...
                dLeft, ...
                dTop, ...
                100, ...
                24 ...
            );
            dLeft = dLeft + 120;
            
            
            this.uiButtonFile.build(...
                this.hParent, ...
                dLeft, ...
                dTop, ...
                100, ...
                24 ...
            );
            
            dLeft = dLeft + 120;
            dTop = dTop + 5;
            this.uiTextFile.build(...
                this.hParent, ...
                dLeft, ...
                dTop, ...
                1200, ...
                24 ...
            );
        
            this.uiToggleLive.build(...
                this.hParent, ...
                1200, ...
                dTop, ...
                200, ...
                24 ...
            );
        
            this.uiButtonSaveLive.build(...
                this.hParent, ...
                1450, ...
                dTop, ...
                200, ...
                24 ...
            );
            this.uiButtonSaveLive.hide();
        
            dTop = 50;
            dLeft = this.dWidth - 400;
            dWidth = 240;
            
            dItemsPerCol = 34;
            for n = 1 : length(this.uiCheckboxes)
                
                
                this.uiCheckboxes(n).build(...
                    this.hParent, ...
                    dLeft + floor((n - 1) / dItemsPerCol) * dWidth, ...
                    dTop + mod(n - 1, dItemsPerCol) * 20 , ...
                    dWidth, ...
                    24 ...
                );
            
                this.uiTextValues(n).build(...
                    this.hParent, ...
                    dLeft + 180 + floor((n - 1) / dItemsPerCol) * dWidth, ...
                    dTop + mod(n - 1, dItemsPerCol) * 20 + 6, ...
                    100, ...
                    24 ...
                );
            end
            
            dLeft = 100;
            dTop = 40;
            dWidth = 150;
            dHeight = 14;
            this.uiTextPlotX.build(this.hParent, dLeft, dTop, dWidth, dHeight);
            this.uiTextPlotY.build(this.hParent, dLeft + dWidth, dTop, dWidth, dHeight);
            
            
            
            dTop = 750;
            dLeft = 1200;
            dSep = 30;
            
            this.uiCheckboxAutoScaleY.build(this.hParent, dLeft, dTop, 150, 24);
            dTop = dTop + dSep - 10;
            
            this.uiEditYMax.build(this.hParent, dLeft, dTop, 150, 24);
            dTop = dTop + dSep;
            
            
            this.uiEditYMin.build(this.hParent, dLeft, dTop, 150, 24);
            dTop = dTop + dSep;
            
            
            if this.uiCheckboxAutoScaleY.get()
                this.uiEditYMin.hide()
                this.uiEditYMax.hide()
            end
            
            
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
        
        % @param {handle 1x1} hFigure - handle to the top-level figure
        
        function setTextPlotXPlotYBasedOnAxesCurrentPoint(this, hFigure)
            
           % If the mouse is inside the axes, turn the cursor into a
           % crosshair, else make sure it is an arrow
           
           if ~ishandle(this.hParent)
               return;
           end
           
           if ~ishandle(this.hAxes)
               return;
           end
           
           dCursor = get(hFigure, 'CurrentPoint');     % [left bottom] 
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
            
                if strcmp(get(hFigure, 'Pointer'), 'arrow')
                    set(hFigure, 'Pointer', 'crosshair')
                end
                
                % this.uiTextPlotX.set(sprintf('x: %1.3f', dPoint(1, 1)));
                
                % https://www.mathworks.com/matlabcentral/answers/370074-gca-currentpoint-with-the-datetime-ticks-on-the-x-axis
                t = num2ruler(dPoint(1, 1), this.hAxes.XAxis);
                this.uiTextPlotX.set(datestr(t, 0)); % second arg of datestr is format identifier
                this.uiTextPlotY.set(sprintf('y: %1.3f', dPoint(1, 2)));
           else
                if ~strcmp(get(hFigure, 'Pointer'), 'arrow')
                    set(hFigure, 'Pointer', 'arrow')
                end
                this.uiTextPlotX.set('x: [hover]');
                this.uiTextPlotY.set('y: [hover]');
           end
        end
        
    end
    
    
    methods (Access = private)
        
        function onButtonRefresh(this, src, evt)
            this.refresh();
        end
        
        function onButtonSaveLive(this, src, evt)
            
            cFilter = '*.csv';
            cTitle = 'Save Live Trace Data as .csv ';
            cNameDefault = [datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local'), '-Live-Trace-Data.csv'];
            cDefault = fullfile(this.cDir, cNameDefault);
            
            [cFile, cDir] = uiputfile(...
                cFilter, ...
                cTitle, ...
                cDefault ...
            );
        
            if isequal(cFile, 0)
               return; % User clicked "cancel"
            end
            
            cPath = fullfile(cDir, cFile);
            
            if exist(cPath, 'file') ~= 2
                % File doesn't exist 
                % open new file in write mode
                try
                    fid = fopen(cPath, 'w');
                catch mE
                    cMsg = sprintf('LogPlotter could not open file (write mode) %s', cPath);
                    disp(cMsg);
                    mE;
                    
                end

            else 
                % open file in append mode
                try
                    fid = fopen(cPath, 'a');
                catch mE
                    cMsg = sprintf('LogPlotter could not open file (append mode) %s', cPath);
                    disp(cMsg);
                end
            end
                       
            [dRows, dCols] = size(this.dData);
            
            % dRows = num of records
            % dCols = num of channels per record
            
            for m = 1 : dRows
                % current record
                for n = 1 : dCols
                    % record channel val;
                    fprintf(fid, '%1.8f,', this.dData(m, n));
                end
                fprintf(fid, '\n'); % line break
            end
                
            fclose(fid);   
            
        end
        
        function onButtonChoose(this, src, evt)
            
            cFilter = '*.csv';
            cTitle = 'Select a log.csv File';
            cDefault = this.cDir;
            
            [cFile, cDir] = uigetfile(...
                cFilter, ...
                cTitle, ...
                cDefault ...
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
            
            try
                this.dData = csvread(cPath, 7, 0);
            catch mE
                % it is likeley that someone chose a FEM log file or some
                % other type that should never be loaded into this
                % DataTrans logger
                return
            end
            this.plotData();
            
        end
        
        function plotData(this)
                        
            % Return if figure 
            
            if  isempty(this.hParent) || ...
                ~ishghandle(this.hParent)
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
            
            [dRows, dCols] = size(this.dData);
            for n = 1 : length(this.uiTextValues)
                
                if n + 1 > dCols
                    continue
                end
                cVal = sprintf('%1.2f', this.dData(end, n + 1));
                this.uiTextValues(n).set(cVal);
            end
            
                
            % Channels on hardware.  Need to offset by two to 
            % get index of data. Recall that date is added as first 
            % column of data
            
            dChannelsToPlot = this.getChannelsToPlot();
            
            % Support legacy log files that may not have as many
            % columns as are now possible.
            dChannelsToPlot(dChannelsToPlot > dCols) = [];
            

            if length(dChannelsToPlot) == 0
                cla(this.hAxes);
                return
            end
            
            plot(this.hAxes, ...
                datetime(this.dData(:, 1) + this.dDaysBetweenMatlabAndExcel, 'ConvertFrom', 'datenum'), ... % x
                this.dData(:, dChannelsToPlot + 2) ... % y
            );
            legend(this.hAxes, this.cecChannelNames(dChannelsToPlot + 1), ...
                'Location','northwest' ...
            );
        
            if ~this.uiCheckboxAutoScaleY.get()
                ylim(this.hAxes, [this.uiEditYMin.get() , this.uiEditYMax.get()])
            else
                ylim(this.hAxes, 'auto')
            end
        
        
            
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
        
        function onToggleLive(this, src, evt)
            
            if this.uiToggleLive.get()
                
                % Switch to live mode
                
                this.dData = []; % purge dData
                
                if this.uiClock.has(this.id())
                    this.uiClock.remove(this.id())
                end
                
                this.uiClock.add(@this.onClockLive, this.id(), 1)
                
                this.uiButtonSaveLive.show();
                
            else
                % Switch to log file mode
                 if this.uiClock.has(this.id())
                    this.uiClock.remove(this.id())
                 end
                 this.loadFileAndPlot();   
                 % this.uiClock.add(@this.onClock, this.id(), 5 * 60);
                 
                 this.uiButtonSaveLive.hide();
                
            end
            
        end
            
        function init(this)
            
            this.uiToggleLive = mic.ui.common.Toggle(...
                'cTextTrue', 'Stop Live Trace (Show Log File)', ...
                'cTextFalse', 'Show Fast Live Trace', ...
                'fhDirectCallback', @this.onToggleLive ...
            );
        
            this.uiButtonSaveLive = mic.ui.common.Button(...
                'cText', 'Save Live Trace as CSV', ...
                'fhDirectCallback', @this.onButtonSaveLive ...
            );
            
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
            
            % update plot every 5 seconds
            % this.uiClock.add(@this.onClock, this.id(), 5 * 60);
            
            this.uiCheckboxAutoScaleY = mic.ui.common.Checkbox(...
                'cLabel', 'Auto Scale Y', ...
                'lChecked', true, ...
                'fhDirectCallback', @this.onUiCheckboxAutoScaleY ...
            );
        
            this.initUiEditYMin();
            this.initUiEditYMax();
            
        end
        
        
        function onUiCheckboxAutoScaleY(this, src, evt)
            
            if isempty(this.uiEditYMin)
                return
            end
            
            if isempty(this.uiEditYMax)
                return
            end
            
            if this.uiCheckboxAutoScaleY.get()
                this.uiEditYMin.hide()
                this.uiEditYMax.hide()
            else
                this.uiEditYMin.show()
                this.uiEditYMax.show()
            end
            
            this.plotData();
            
            
        end
        
        function initUiEditYMin(this)
            
             this.uiEditYMin = mic.ui.common.Edit(...
                'cType', 'd', ...
                'fhDirectCallback', @this.onUiEditYMin, ...
                'cLabel', 'Y Min (nm) (min = 0)' ...
            );
            this.uiEditYMin.setMin(-50)
            this.uiEditYMin.set(0);
            
        end
        
        function initUiEditYMax(this)
            
             this.uiEditYMax = mic.ui.common.Edit(...
                'cType', 'd', ...
                'fhDirectCallback', @this.onUiEditYMax, ...
                'cLabel', 'Y Max (nm)' ...
            );
            this.uiEditYMax.setMin(-50)
            this.uiEditYMax.set(30);
            
        end
        
        
        function onUiEditYMin(this, src, evt)
            
            if isempty(this.uiEditYMax)
               return 
            end
            
            % Make sure max is not less than min
            if this.uiEditYMax.get() < this.uiEditYMin.get()
                this.uiEditYMax.set(this.uiEditYMin.get() + 1)
            end
            
            this.plotData();
            
        end
        
        function onUiEditYMax(this, src, evt)
            
            if isempty(this.uiEditYMin)
                return
            end
            
            
            % Make sure min is not > max
            if this.uiEditYMin.get() > this.uiEditYMax.get()
                this.uiEditYMin.set(this.uiEditYMax.get() - 1)
            end
            
            this.plotData();
            
        end
        
        
        function appendLatestReadingToData(this)
            
            % See bl12014.Logger.m - the first value is expected to be an Excel-corrected
            % timestamp since the log files are built to be easily read
            % by Excel
            
            if this.hardware.getDataTranslation().getIsBusy()
                
                fprintf('bl12014.ui.LogPlotter.appendLatestReadingToData() returning DT is busy!\n');
                return
            end
            
            
            readings = now - 693960;
            
            try

                %{
                channels = 0 : 7;
                readings = [readings this.hardware.getDataTranslation().measure_temperature_tc(channels, 'J')];

                channels = 8 : 15;
                readings = [readings this.hardware.getDataTranslation().measure_temperature_rtd(channels, 'PT1000')];

                channels = 16 : 19;
                readings = [readings this.hardware.getDataTranslation().measure_temperature_rtd(channels, 'PT100')];

                channels = 20 : 23;
                readings = [readings this.hardware.getDataTranslation().measure_temperature_rtd(channels, 'PT1000')];

                channels = 24 : 31;
                readings = [readings this.hardware.getDataTranslation().measure_temperature_rtd(channels, 'PT100')];

                channels = 32 : 47;
                readings = [readings this.hardware.getDataTranslation().measure_voltage(channels)];
                %}
                
                readings = [readings this.hardware.getDataTranslation().getScanData()];

                % DMI power
                readings = [readings this.hardware.getMfDriftMonitor().dmiGetAxesOpticalPower()'];
                readings = [readings this.hardware.getMfDriftMonitor().dmiGetAxesOpticalPowerDC()'];
                
                % Mot Min Levels
                readings = [readings this.hardware.getDeltaTauPowerPmac().getMotMinWaferCoarseX()];
                readings = [readings this.hardware.getDeltaTauPowerPmac().getMotMinWaferCoarseY()];
                readings = [readings this.hardware.getDeltaTauPowerPmac().getMotMinReticleCoarseX()];
                readings = [readings this.hardware.getDeltaTauPowerPmac().getMotMinReticleCoarseY()];
                readings = [readings this.hardware.getDeltaTauPowerPmac().getMotMinLsiCoarseX()];
                
                % VIS encoders
                readings = [readings this.hardware.getGalilVis().getAxisAnalog(0)];
                readings = [readings this.hardware.getGalilVis().getAxisAnalog(1)];
                readings = [readings this.hardware.getGalilVis().getAxisAnalog(2)];
                readings = [readings this.hardware.getGalilVis().getAxisAnalog(3)];
                
                this.dData(end + 1, :) = readings;
            
            catch
                
            end
            
            
        end
        
        
        function onClockLive(this)
            
            this.appendLatestReadingToData();
            this.plotData();
            
        end
        
        
        function onClock(this)
             this.loadFileAndPlot();
        end
        
        
        function buildAxes(this)
            
            dLeft = 50;
            dTop = 50;
            
            this.hAxes = axes(...
                'Parent', this.hParent, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidth - 500, this.dHeight - 200], this.hParent),...
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
            
             
            if ~isempty(this.hParent) && ~isvalid(this.hParent)
                return
            end
            
            delete(this.hParent);
            this.hParent = [];
            
         end
         
         
         function onFigureWindowButtonDown(this, src, evt)
            
            % this.showSetAsZeroIfAxesIsClicked();
            
        end
        
        
        function onFigureWindowMouseMotion(this, src, evt)
           
           this.msg('onWindowMouseMotion()');
           this.setTextPlotXPlotYBasedOnAxesCurrentPoint();
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