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
            '08 - AMP 2.4', ...
            '09 - AMP 3.1', ...
            '10 - AMP 1.4', ...
            '11 - AMP 2.2', ...
            '12 - AMP 2.1', ...
            '13 - AMP 3.4', ...
            '14 - AMP 2.3', ...
            '15 - AMP 3.2', ...
            '16 - PO M2 11:00', ...
            '17 - PO M1 12:00', ...
            '18 - PO M1 04:00', ...
            '19 - PO M1 07:30', ... 
            '20 - AMP 1.1', ... 
            '21 - AMP 1.2', ... 
            '22 - AMP 1.3', ... 
            '23 - AMP 3.3', ...
            '24 - MOD3 SP 03:00', ... 
            '25 - MOD3 SP 07:30', ... 
            '26 - MOD3 SP 12:00', ... 
            '27 - MOD3 SP 01:30', ... 
            '28 - PO M2 07:00', ...
            '29 - P0 M2 02:00', ... 
            '30 - Unknown', ... 
            '31 - Unknown' ...
        };
       
    end
    
    properties (SetAccess = private)
        
        dWidth              = 1500;
        dHeight             = 960;
       
    
    end
    
    properties (Access = private)
         
        hFigure
        hAxes
        
         % {mic.ui.common.Checkbox 1xm}
        uiCheckboxes
        
        uiButtonRefresh
        uiButtonFile
        uiTextFile
        
        % storage for handles returned by plot()
        hLines
        
        cDir
        cFile
        
        % {struct 1x1} storage of the result struct loaded from JSON
        stResult
        
        % {struct 1x1} computed storage of results in format more useful
        % for plotting
        stResultForPlotting
        
        % {logical 1x1} 
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
                this.uiCheckboxes(n + 1).set(true)
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
        
            dTop = 10;
            dLeft = 1320;
            for n = 1 : length(this.uiCheckboxes)
                this.uiCheckboxes(n).build(...
                    this.hFigure, ...
                    dLeft, ...
                    dTop + n * 20 , ...
                    150, ...
                    24 ...
                );
            end
                
            
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
            this.uiTextFile.set(cPath);
            
            % Need to load the CSV file, skipping six header lines
            % (use second arg to skip headers)
            
            this.dData = csvread(cPath, 7, 0);
            this.plotData();
            
        end
        
        function plotData(this)
                        
            
                
            % Channels on hardware.  Need to offset by two to 
            % get index of data. Recall that date is added as first 
            % column of data
            
            dChannelsToPlot = this.getChannelsToPlot();
            plot(this.hAxes, ...
                datetime(this.dData(:, 1) + this.dDaysBetweenMatlabAndExcel, 'ConvertFrom', 'datenum'), ... % x
                this.dData(:, dChannelsToPlot + 2) ... % y
            );
            legend(this.hAxes, this.cecChannelNames(dChannelsToPlot + 1));
            
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
                'lChecked', true, ... 
                'cLabel', this.cecChannelNames(1) ...
            );
        
            for n = 2 : length(this.cecChannelNames)
                this.uiCheckboxes(n) = mic.ui.common.Checkbox(...
                    'lChecked', true, ...
                    'cLabel', this.cecChannelNames(n), ...
                    'fhDirectCallback', @this.onUiCheckbox ...
                );
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
        
            this.initUiCheckboxes()
            
            
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
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Toolbar', 'figure', ...
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
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidth - 300, this.dHeight - 200], this.hFigure),...
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
            this.plotData();
        end
        
        
         function onFigureCloseRequest(this, src, evt)
            
             
            if ~isempty(this.hFigure) && ~isvalid(this.hFigure)
                return
            end
            
            delete(this.hFigure);
            this.hFigure = [];
            
         end
        

        
    end
    
    
end