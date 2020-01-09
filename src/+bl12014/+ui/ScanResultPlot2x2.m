classdef ScanResultPlot2x2 < mic.Base
    
    % rcs
    
	properties
               
       
       
    end
    
    properties (SetAccess = private)
        
        cName = 'fem-plotter'
        
        dWidth              = 1500;
        dHeight             = 960;
        
        dWidthPadAxesLeft = 60
        dWidthPadAxesRight = 40
        dHeightPadAxesTop = 10
        dHeightPadAxesBottom = 40
        dWidthAxes = 350
        dHeightAxes = 230
        dHeightOffsetTop = 80;
       
        dWidthPopup = 200;
        dHeightPopup = 24;
        dHeightPopupFull = 30;
        dHeightPadPopupTop = 10;
        
    
    end
    
    properties (Access = private)
         
        % {cell of char arrays}
        cecFieldsCsv
        
        uiPositionRecaller
        
        clock
        hDock
        
        hParent
        
        hAxes1
        hAxes2
        hAxes3
        hAxes4
        hAxes5
        hAxes6
        hAxes7
        hAxes8
        
        % returned by plot()
        hPlot1
        hPlot2
        hPlot3
        hPlot4
        hPlot5
        hPlot6
        hPlot7
        hPlot8
        
        uiPopup1
        uiPopup2
        uiPopup3
        uiPopup4
        uiPopup5
        uiPopup6
        uiPopup7
        uiPopup8
        
        uiCheckboxDC1
        uiCheckboxDC2
        uiCheckboxDC3
        uiCheckboxDC4
        uiCheckboxDC5
        uiCheckboxDC6
        uiCheckboxDC7
        uiCheckboxDC8
        
        
        uiPopupIndexStart
        uiPopupIndexEnd
        
        uiButtonRefresh
        uiButtonLatest
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
        
        c
                
    end
    
        
    events
        
        
        
    end
    

    
    methods
        
        
        function this = ScanResultPlot2x2(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
            
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

            this.cDir = fullfile(cDirThis, '..', '..', 'save');
            this.cFile = '';
            
        end
        
        function delete(this)
                        
            delete(this.uiPopup1);
            delete(this.uiPopup2);
            delete(this.uiPopup3);
            delete(this.uiPopup4);
            delete(this.uiPopupIndexStart);
            delete(this.uiPopupIndexEnd);
            delete(this.uiButtonRefresh);
            delete(this.uiButtonFile);
            delete(this.uiButtonLatest);
            delete(this.uiTextFile);
            delete(this.hAxes1);
            delete(this.hAxes2);
            delete(this.hAxes3);
            delete(this.hAxes4);

            % Delete the figure
            
            if ishandle(this.hParent)
                delete(this.hParent);
            end
            
            
            this.clock.remove(this.id());


        end
        
        function ce = getUiPropsSaved(this)
            
            ce = {...
                'uiTextFile', ...
                'uiPopup1', ...
                'uiPopup2', ...
                'uiPopup3', ...
                'uiPopup4', ...
                'uiPopup5', ...
                'uiPopup6', ...
                'uiPopup7', ...
                'uiPopup8', ...
                'uiCheckboxDC1', ...
                'uiCheckboxDC2', ...
                'uiCheckboxDC3', ...
                'uiCheckboxDC4', ...
                'uiCheckboxDC5', ...
                'uiCheckboxDC6', ...
                'uiCheckboxDC7', ...
                'uiCheckboxDC8', ...
            };
        
        end
        
        
        % @return {struct} UI state to save
        function st = save(this)
            
        
            st = struct();
            
            st.cDir = this.cDir;
            st.cFile = this.cFile;
            
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
              
            % This updates the popups so they have logged
            % properties as options.  Important to call this first so that
            % the .load() calls on the popups works below.
            this.loadFileAndUpdateAll(); 
            
            
            ceProps = this.getUiPropsSaved();
        
            for n = 1 : length(ceProps)
                cProp = ceProps{n};
                if isfield(st, cProp)
                    try
                        this.(cProp).load(st.(cProp));
                    end
                end
            end
            
            this.lLoading = false;
                        
        end
        
        % @return {cell 1xfields} where each item of the cell is the 
        % value of the field/property for each exposure of the fem.  For
        % example, ceData{1} may be a 121 element vector if it is a 12 x 10
        % FEM (120 + 1 for the index). and it would be the value of the
        % als_current_ma at each exposure
        % @return {cell of strings 1xfields} which is a list of field names
        function [ceData, ceFields] = getValuesStructFromCsvFile(this, cPath)
            
            hFile = fopen(cPath);
            
            % Get header fields
            cFormat = repmat('%q', 1, 58);
            ceHeader = textscan(...
                hFile, cFormat, 1, ...
                'delimiter', ',' ...
                ...'whitespace', '' ...
            );
        
            ceFields = cell(size(ceHeader));
            for n = 1 : length(ceHeader)
                ceFields{n} = ceHeader{n}{1};
            end

            

            % %d = signed integer, 32-bit
            cFormat = [...
                '%f%f%f%f%f%f%f%f%f%f', ... 10
                '%f%f%f%f%f%f%f%f%f%f', ... 20
                '%f%f%f%f%f%f%f%f%f%f', ... 30
                '%f%f%f%f%f%f%f%f%f%f', ... 40
                '%f%f%f%f%f%f%f%f%f%f', ... 50
                '%f%f%f%f', ... 54
                '%{yyyy-MM-dd HH:mm:ss}D', ... !!! CAREFUL !!! here need to use DateTime format, not datestr format !! search datetime properties, the characters for month and year and maybe others are different. SO DUMB
                '%f%f%f' ... 
            ];

            ceData = textscan(...
                hFile, cFormat, -1, ... 
                'delimiter', ',' ...
                ...'whitespace', '', ...
                ...'headerlines', 1 ...
            );
       
            
            fclose(hFile);
        end 
        
        function build(this, hParent, dLeft, dTop)
            
            this.hParent = hParent;
            
            
            this.buildAxes1();
            this.buildAxes2();
            this.buildAxes3();
            this.buildAxes4();
            this.buildAxes5();
            this.buildAxes6();
            this.buildAxes7();
            this.buildAxes8();
            
            
            dLeft = this.getLeft1();
            dTop = 15;
            
            this.uiButtonRefresh.build(...
                this.hParent, ...
                dLeft, ...
                dTop, ...
                100, ...
                24 ...
            );
            dLeft = dLeft + 120;
            
            
            this.uiButtonLatest.build(...
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
        
            dLeft = this.getLeft1();
            dTop = 45;
        
            dWidth = 70
            this.uiPopupIndexStart.build(...
                this.hParent, ...
                dLeft , ...
                dTop, ...
                dWidth, ...
                this.dHeightPopup ...
            );
        
            dLeft = dLeft + dWidth + 10;
            this.uiPopupIndexEnd.build(...
                this.hParent, ...
                dLeft , ...
                dTop, ...
                dWidth, ...
                this.dHeightPopup ...
            );
                
            
            dLeft = this.getLeft1();
            dTop = this.getTopPulldown1();
            this.uiPopup1.build(...
                this.hParent, ...
                dLeft , ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
            this.uiCheckboxDC1.build(...
                this.hParent, ...
                dLeft + this.dWidthPopup + 20, ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
        
        
            dLeft = this.getLeft2();
            dTop = this.getTopPulldown1();
            
            this.uiPopup2.build(...
                this.hParent, ...
                dLeft , ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
            this.uiCheckboxDC2.build(...
                this.hParent, ...
                dLeft + this.dWidthPopup + 20, ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
        
        
            dLeft = this.getLeft3();
            dTop = this.getTopPulldown1();
            
            this.uiPopup3.build(...
                this.hParent, ...
                dLeft , ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
            this.uiCheckboxDC3.build(...
                this.hParent, ...
                dLeft + this.dWidthPopup + 20, ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
        
        
            dLeft = this.getLeft4();
            dTop = this.getTopPulldown1();
            
            this.uiPopup4.build(...
                this.hParent, ...
                dLeft , ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
             this.uiCheckboxDC4.build(...
                this.hParent, ...
                dLeft + this.dWidthPopup + 20, ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
        
        
            dLeft = this.getLeft1();
            dTop = this.getTopPulldown3();
            
            this.uiPopup5.build(...
                this.hParent, ...
                dLeft , ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
            this.uiCheckboxDC5.build(...
                this.hParent, ...
                dLeft + this.dWidthPopup + 20, ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
        
        
            dLeft = this.getLeft2();
            dTop = this.getTopPulldown3();
            
            this.uiPopup6.build(...
                this.hParent, ...
                dLeft , ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
            this.uiCheckboxDC6.build(...
                this.hParent, ...
                dLeft + this.dWidthPopup + 20, ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
        
            dLeft = this.getLeft3();
            dTop = this.getTopPulldown3();
            
            this.uiPopup7.build(...
                this.hParent, ...
                dLeft , ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
            this.uiCheckboxDC7.build(...
                this.hParent, ...
                dLeft + this.dWidthPopup + 20, ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
        
            dLeft = this.getLeft4();
            dTop = this.getTopPulldown3();
            
            this.uiPopup8.build(...
                this.hParent, ...
                dLeft , ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
            this.uiCheckboxDC8.build(...
                this.hParent, ...
                dLeft + this.dWidthPopup + 20, ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
        
            dLeft = 50;
            dTop = 720;
            dWidth = 400;
            dHeight = 150;
        
            this.uiPositionRecaller.build(...
                this.hParent, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                dHeight ...
            );
                
            this.loadFileAndUpdateAll();
            
            if ~isempty(this.clock) && ...
                ~this.clock.has(this.id())
                this.clock.add(@this.onClock, this.id(), 1);
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
            this.loadFileAndUpdateAll();
        end
        
        function refresh(this)
            
            
            this.loadFileAndUpdateAll();
        end
        
    end
    
    
    methods (Access = private)
        
        function onClock(this)
            
            % Store the values of the index start and index min and reset
            % after
            
            % Before resettign the options of indexStart and indexEnd
            % save their current value and then re-select that value
            % when done
            
            
            u8IndexStart = this.uiPopupIndexStart.getSelectedIndex();
            u8IndexEnd = this.uiPopupIndexEnd.getSelectedIndex();

            this.refresh();
            
            this.uiPopupIndexStart.setSelectedIndex(u8IndexStart);
            this.uiPopupIndexEnd.setSelectedIndex(u8IndexEnd);
            this.onPopupIndexEnd([], []);
            this.onPopupIndexStart([], []);
            
        end
        
        function onButtonRefresh(this, src, evt)
            this.refresh();
        end
        
        function onButtonFile(this, src, evt)
            
            [cFile, cDir] = uigetfile(...
                '*.json;*.csv', ...
                'Select a Scan Result .json File', ...
                this.cDir ...
            );
        
            if isequal(cFile, 0)
               return; % User clicked "cancel"
            end
            
            this.cDir = mic.Utils.path2canonical(cDir);
            this.cFile = cFile;
            
            % this.refresh(); 
            
            this.loadFileAndUpdateAll()

        end
        
        
        function onButtonLatest(this, src, evt)
            
            cOrderByPredicate = 'date';
            cOrder = 'descend';
            cFilter = '*';
            cDir = mic.Utils.path2canonical(fullfile(this.cDir, '..'));
            
            ceReturn = mic.Utils.dir2cell(...
                cDir, ...
                cOrderByPredicate, ...
                cOrder, ...
                cFilter ...
            );
        
            % This includes files, folders, etc
            
            % Get a logical vector that tells which is a directory.
            % Make sure to use full path so MATLAB can check directories
            % that were created after MATLAB launched
            dirFlags = cellfun(@isdir, fullfile(cDir, ceReturn));
            % Extract only those that are directories.
            ceReturn = ceReturn(dirFlags);
           
            
            % Ignore '.' and '..' directories
            fhNotMacOSSpecial = @(c) ~strcmp('.', c) && ~strcmpi('..', c);
            
            flags = cellfun(fhNotMacOSSpecial, ceReturn);
            ceReturn = ceReturn(flags);
            
            % Loop through dirs
            % Check if it contains a result.json file
            % First one that contains, set this this.cDir and
            % this.cFile
            
            % cFile = 'result.json';
            cFile = 'result.csv';
            for n = 1 : length(ceReturn)
                cPath = fullfile(cDir, ceReturn{n}, cFile);
                if exist(cPath, 'file')
                    this.cDir = fullfile(cDir, ceReturn{n});
                    this.cFile = cFile;
                    break;
                end
            end
                        
            this.loadFileAndUpdateAll()
            
        end
        
        
        
        
        function loadFileAndUpdateAll(this)
            
            if isempty(this.cDir)
                return
            end
            
            if isempty(this.cFile)
                return
            end
            
            cPath = fullfile(this.cDir, this.cFile);
            this.uiTextFile.set(cPath);
            
            % this.stResult = loadjson(cPath);
            
            if contains(cPath, '.json')
                try 
                    fid = fopen(cPath, 'r');
                    cText = fread(fid, inf, 'uint8=>char');
                    fclose(fid);
                    this.stResult = jsondecode(cText');

                    this.stResultForPlotting = this.getValuesStructFromResultStruct(this.stResult);
                    this.updatePopups()
                catch mE
                    
                    % json error
                end
                
            end
            
            if contains(cPath, '.csv')
                
                % dData = csvread(cFile, 2, 0);
                [ceData, ceFields] = this.getValuesStructFromCsvFile(cPath);
                
                % initialize results structure formatted for easy plotting
                % (json import creates structure with same format)
                stResults= struct();
                
                % fill results structure
                for n = 1 : length(ceData)
                    stResults.(ceFields{n}) = ceData{n}'; % needs to be a row not a column
                end
                
                this.stResultForPlotting = stResults;
                this.cecFieldsCsv = ceFields; % storage for updatePopups()
                this.updatePopups(); 
                
                 
            end
              
            
        end
        
        function stOut = getValuesStructFromCsvData(this, ceData)
            
            stOut = struct();
        end
        
        
        % Returns a {struct 1x1} where each prop is a list of values of
        % of a saved result property.  The result structure loaded from
        % .json has a values field that is a cell of structures or a list
        % of structures (for log files created since 2019.11.05)
        function stOut = getValuesStructFromResultStruct(this, st)
            
            % Initialize the structure
            stOut = struct();
            
            if ~this.getResultStructHasValues(st)
                return
            end
            
            ceValues = this.getNonEmptyValues(st.values);
            
            if iscell(ceValues)
                stValue = ceValues{1};
            else
                stValue = ceValues(1);
            end
            
            % Initialize empty structure
            ceFields = fieldnames(stValue);
            for m = 1 : length(ceFields)
                cField = ceFields{m};
                switch cField
                    case 'time'
                        stOut.(cField) = NaT(1, length(ceValues)); % Allocate list of "Not a time"
                    otherwise
                        stOut.(cField) = zeros(1, length(ceValues));
                end
            end
             
            % Write values
            for idxValue = 1 : length(ceValues)
                %stValue = ceValues{idxValue};
                
                if iscell(ceValues)
                    stValue = ceValues{idxValue};
                else
                    stValue = ceValues(idxValue);
                end
                
                if ~isstruct(stValue)
                    continue
                end
                if isempty(stValue)
                    continue
                end
                
                ceFields = fieldnames(stValue);
                for idxField = 1 : length(ceFields)
                    
                    cField = ceFields{idxField};
                    switch cField
                        case 'time'
                            stOut.(cField)(1, idxValue) = datetime(...
                                stValue.(cField), ...
                                'Format', 'yyyy-MM-dd HH:mm:ss' ...
                            );
                        otherwise
                            % RM: 11/10/2018 Catching case where value is null but not
                            % expected to be:
                            if (isempty(stValue.(cField)))
                                stOut.(cField)(1, idxValue) = 0;
                            else
                                stOut.(cField)(1, idxValue) = stValue.(cField);
                            end
                
                            
                    end
                end
            end
            
            
        end
        
        
        function l = getResultStructHasValues(this, st)
            
            l = false;
            
            if isempty(st)
                return
            end
            
            if ~isfield(st, 'values')
                return
            end
                        
            if isempty(st.values)
                return
            end  
            
            l = true;
            
        end
        
  
        
        function ce = getNonEmptyValues(this, ceValues)
            
            % idxNonEmpty = find(~cellfun(@isempty, ceValues) && ~cellfun(@isnan, ceValues));
            % idxNonEmpty = find(cellfun(@isstruct, ceValues));
            % ceValues = ceValues(idxNonEmpty);
            
            % Use logical indexing
            if iscell(ceValues)
            
                lIsStruct = cellfun(@isstruct, ceValues);
                ce = ceValues(lIsStruct);
            else
                ce = ceValues;
            end
            
        end
        
        function l = getIsCsv(this)
            
            l = false;
            if isempty(this.cDir)
                return
            end
            
            if isempty(this.cFile)
                return
            end
            
            cPath = fullfile(this.cDir, this.cFile);
            if contains(cPath, '.csv')
                l = true;
            end
        end
        
        function l = getIsJson(this)
            
            l = false;
            if isempty(this.cDir)
                return
            end
            
            if isempty(this.cFile)
                return
            end
            
            cPath = fullfile(this.cDir, this.cFile);
            if contains(cPath, '.json')
                l = true;
            end
        end
        
        
        function updatePopups(this)
            
            if this.getIsCsv()
                ceFields = this.cecFieldsCsv;
            end
            
            
            if this.getIsJson()
                if ~this.getResultStructHasValues(this.stResult)
                    return
                end

                ceValues = this.getNonEmptyValues(this.stResult.values);

                if iscell(ceValues)
                    stValue = ceValues{1};
                else 
                    stValue = ceValues(1);
                end
                ceFields = fieldnames(stValue);
            end
            
            
            this.uiPopup1.setOptions(ceFields);
            this.uiPopup2.setOptions(ceFields);
            this.uiPopup3.setOptions(ceFields);
            this.uiPopup4.setOptions(ceFields);
            this.uiPopup5.setOptions(ceFields);
            this.uiPopup6.setOptions(ceFields);
            this.uiPopup7.setOptions(ceFields);
            this.uiPopup8.setOptions(ceFields);
            
            
            
            
            % Returns a {cell 1xm} with values for the index start and index
            % end popups
        
            dValues = this.stResultForPlotting.(ceFields{1}); % values of first field used to set the index popups
            ceOptions = cell(1, length(dValues));
            for n = 1 : length(dValues)
               ceOptions{n} = num2str(n); 
            end
            
            
            
            % Before resettign the options of indexStart and indexEnd
            % save their current value and then re-select that value
            % when done
            
            %{
            u8IndexStart = this.uiPopupIndexStart.getSelectedIndex();
            u8IndexEnd = this.uiPopupIndexEnd.getSelectedIndex();
            
            if isempty(u8IndexStart)
                u8IndexStart = uint16(1);
            end
            
            if isempty(u8IndexEnd) || ...
                u8IndexEnd <= u8IndexStart
                u8IndexEnd = uint16(length(dValues));
            end
            %}
             
            u8IndexStart = uint8(1);
            u8IndexEnd = uint16(length(dValues));
            
            this.uiPopupIndexStart.setOptions(ceOptions);
            this.uiPopupIndexEnd.setOptions(ceOptions);
            
            if u8IndexStart < length(ceOptions)
                this.uiPopupIndexStart.setSelectedIndex(u8IndexStart);
            else
                this.uiPopupIndexStart.setSelectedIndex(uint8(1));
            end
            
            if u8IndexEnd < length(ceOptions)
                this.uiPopupIndexEnd.setSelectedIndex(u8IndexEnd);
            else
                this.uiPopupIndexEnd.setSelectedIndex(uint8(length(dValues)));
            end
            
            %{
            if length(ceFields) > 0
                this.uiPopup1.setSelectedIndex(uint8(1))
            end
            
            if length(ceFields) > 1
                this.uiPopup2.setSelectedIndex(uint8(2))
            end
            
            if length(ceFields) > 2
                this.uiPopup3.setSelectedIndex(uint8(3))
            end
            
            if length(ceFields) > 3
                this.uiPopup4.setSelectedIndex(uint8(4))
            end
            %}
            
            this.onPopup1([], []);
            this.onPopup2([], []);
            this.onPopup3([], []);
            this.onPopup4([], []);
            this.onPopup5([], []);
            this.onPopup6([], []);
            this.onPopup7([], []);
            this.onPopup8([], []);
            
        end
        
        
        function updateAxes(this, u8Axes)
            
            if isempty(this.stResultForPlotting)
                return
            end
            
            if isempty(this.hAxes1) || ...
               isempty(this.hAxes2) || ...
               isempty(this.hAxes3) || ...
               isempty(this.hAxes4) || ...
               isempty(this.hAxes5) || ...
               isempty(this.hAxes6) || ...
               isempty(this.hAxes7) || ...
               isempty(this.hAxes8)
                return
            end
            
            switch u8Axes
                case 1
                   hAxes = this.hAxes1;
                   cProp = this.uiPopup1.get();
                   lRemoveDC = this.uiCheckboxDC1.get();
                   hPlot = this.hPlot1;
                case 2
                    hAxes = this.hAxes2;
                    cProp = this.uiPopup2.get();
                    lRemoveDC = this.uiCheckboxDC2.get();
                    hPlot = this.hPlot2;
                case 3
                    hAxes = this.hAxes3;
                    cProp = this.uiPopup3.get();
                    lRemoveDC = this.uiCheckboxDC3.get();
                    hPlot = this.hPlot3;
                case 4
                    hAxes = this.hAxes4;
                    cProp = this.uiPopup4.get();
                    lRemoveDC = this.uiCheckboxDC4.get();
                    hPlot = this.hPlot4;
                case 5
                    hAxes = this.hAxes5;
                    cProp = this.uiPopup5.get();
                    lRemoveDC = this.uiCheckboxDC5.get();
                    hPlot = this.hPlot5;
                case 6
                    hAxes = this.hAxes6;
                    cProp = this.uiPopup6.get();
                    lRemoveDC = this.uiCheckboxDC6.get();
                    hPlot = this.hPlot6;
                    
                case 7
                    hAxes = this.hAxes7;
                    cProp = this.uiPopup7.get();
                    lRemoveDC = this.uiCheckboxDC7.get();
                    hPlot = this.hPlot7;
                    
                case 8
                    hAxes = this.hAxes8;
                    cProp = this.uiPopup8.get();
                    lRemoveDC = this.uiCheckboxDC8.get();
                    hPlot = this.hPlot8;
                    
                    
            end
                       
            
            if ~this.getResultStructHasValues(this.stResult)
                return
            end
            
            
            
            dValues = this.stResultForPlotting.(cProp);
            dValues = dValues(this.uiPopupIndexStart.getSelectedIndex() : this.uiPopupIndexEnd.getSelectedIndex());
            if lRemoveDC
                dValues = dValues - mean(dValues);
            end
            
            % cla(hAxes);
            
            if isempty(hPlot)
                
                hPlot = plot(hAxes, dValues, '.-b');
                
                % Store
                switch u8Axes
                    case 1
                        this.hPlot1 = hPlot;
                    case 2
                        this.hPlot2 = hPlot;
                    case 3
                        this.hPlot3 = hPlot;
                    case 4
                        this.hPlot4 = hPlot;
                    case 5
                        this.hPlot5 = hPlot;
                    case 6
                        this.hPlot6 = hPlot;
                    case 7
                        this.hPlot7 = hPlot;
                    case 8
                        this.hPlot8 = hPlot;
                end
                
            else
                set(hPlot, ...
                    'XData', 1 : length(dValues), ...
                    'YData', dValues ...
                );
                
            end
            
            
            try
                xlabel(hAxes, 'State Num');
                ylabel(hAxes, this.stResult.unit.(cProp));
            catch mE
                
            end
            
        end
        
        
        function onPopupIndexStart(this, src, evt)
            
            if this.uiPopupIndexEnd.getSelectedIndex() < this.uiPopupIndexStart.getSelectedIndex()
                this.uiPopupIndexEnd.setSelectedIndex(this.uiPopupIndexStart.getSelectedIndex())
            end
            
            this.onPopup1([], []);
            this.onPopup2([], []);
            this.onPopup3([], []);
            this.onPopup4([], []);
            this.onPopup5([], []);
            this.onPopup6([], []);
            this.onPopup7([], []);
            this.onPopup8([], []);
            
        end
        
        function onPopupIndexEnd(this, src, evt)
            
            if this.uiPopupIndexStart.getSelectedIndex() > this.uiPopupIndexEnd.getSelectedIndex()
                this.uiPopupIndexStart.setSelectedIndex(this.uiPopupIndexEnd.getSelectedIndex())
            end
            
            this.onPopup1([], []);
            this.onPopup2([], []);
            this.onPopup3([], []);
            this.onPopup4([], []);
            this.onPopup5([], []);
            this.onPopup6([], []);
            this.onPopup7([], []);
            this.onPopup8([], []);
            
        end
        
        
        function onCheckboxDC1(this, src, evt)
            this.onPopup1(src, evt)
        end
        
        function onCheckboxDC2(this, src, evt)
            this.onPopup2(src, evt)
        end
        
        function onCheckboxDC3(this, src, evt)
            this.onPopup3(src, evt)
        end
        
        function onCheckboxDC4(this, src, evt)
            this.onPopup4(src, evt)
        end
        
        function onCheckboxDC5(this, src, evt)
            this.onPopup5(src, evt)
        end
        
        function onCheckboxDC6(this, src, evt)
            this.onPopup6(src, evt)
        end
        
        function onCheckboxDC7(this, src, evt)
            this.onPopup7(src, evt)
        end
        
        function onCheckboxDC8(this, src, evt)
            this.onPopup8(src, evt)
        end
        
        
        function onPopup1(this, src, evt)
            this.updateAxes(1);
        end
        
        function onPopup2(this, src, evt)
            this.updateAxes(2);
        end
        
        function onPopup3(this, src, evt)
        	this.updateAxes(3);
        end
        
        function onPopup4(this, src, evt)
            this.updateAxes(4);
        end
        
        function onPopup5(this, src, evt)
            this.updateAxes(5);
        end
        function onPopup6(this, src, evt)
            this.updateAxes(6);
        end
        function onPopup7(this, src, evt)
            this.updateAxes(7);
        end
        function onPopup8(this, src, evt)
            this.updateAxes(8);

        end
        
        function init(this)
            
            this.uiButtonFile = mic.ui.common.Button(...
                'cText', 'Choose File', ...
                'fhDirectCallback', @this.onButtonFile ...
            );
        
            this.uiButtonLatest = mic.ui.common.Button(...
                'cText', 'Load Latest Log', ...
                'fhDirectCallback', @this.onButtonLatest ...
            );
        
            this.uiButtonRefresh = mic.ui.common.Button(...
                'cText', 'Refresh', ...
                'fhDirectCallback', @this.onButtonRefresh ...
            );
        
            this.uiTextFile = mic.ui.common.Text(...
                'cVal', '...' ...
            );
            this.uiPopup1 = mic.ui.common.Popup(...
                'lShowLabel', false, ...
                'fhDirectCallback', @this.onPopup1 ...
            );
            this.uiPopup2 = mic.ui.common.Popup(...
                'lShowLabel', false, ...
                'fhDirectCallback', @this.onPopup2 ...
                );
            this.uiPopup3 = mic.ui.common.Popup(...
                'lShowLabel', false, ...
                'fhDirectCallback', @this.onPopup3 ...
                );
            this.uiPopup4 = mic.ui.common.Popup(...
                'lShowLabel', false, ...
                'fhDirectCallback', @this.onPopup4 ...
                );
            
            
            this.uiPopup5 = mic.ui.common.Popup(...
                'lShowLabel', false, ...
                'fhDirectCallback', @this.onPopup5 ...
                );
            
            this.uiPopup6 = mic.ui.common.Popup(...
                'lShowLabel', false, ...
                'fhDirectCallback', @this.onPopup6 ...
                );
            
            this.uiPopup7 = mic.ui.common.Popup(...
                'lShowLabel', false, ...
                'fhDirectCallback', @this.onPopup7 ...
                );
            
            this.uiPopup8 = mic.ui.common.Popup(...
                'lShowLabel', false, ...
                'fhDirectCallback', @this.onPopup8 ...
                );
            
            this.uiCheckboxDC1 = mic.ui.common.Checkbox(...
                'cLabel', 'Remove DC', ...
                'fhDirectCallback', @this.onCheckboxDC1 ...
            );
        
            this.uiCheckboxDC2 = mic.ui.common.Checkbox(...
                'cLabel', 'Remove DC', ...
                'fhDirectCallback', @this.onCheckboxDC2 ...
            );
        
            this.uiCheckboxDC3 = mic.ui.common.Checkbox(...
                'cLabel', 'Remove DC', ...
                'fhDirectCallback', @this.onCheckboxDC3 ...
            );
        
            this.uiCheckboxDC4 = mic.ui.common.Checkbox(...
                'cLabel', 'Remove DC', ...
                'fhDirectCallback', @this.onCheckboxDC4 ...
            );
        
        this.uiCheckboxDC5 = mic.ui.common.Checkbox(...
                'cLabel', 'Remove DC', ...
                'fhDirectCallback', @this.onCheckboxDC5 ...
            );
        
        this.uiCheckboxDC6 = mic.ui.common.Checkbox(...
                'cLabel', 'Remove DC', ...
                'fhDirectCallback', @this.onCheckboxDC6 ...
            );
        
        this.uiCheckboxDC7 = mic.ui.common.Checkbox(...
                'cLabel', 'Remove DC', ...
                'fhDirectCallback', @this.onCheckboxDC7 ...
            );
        
        this.uiCheckboxDC8 = mic.ui.common.Checkbox(...
                'cLabel', 'Remove DC', ...
                'fhDirectCallback', @this.onCheckboxDC8 ...
            );
            
            this.uiPopupIndexStart = mic.ui.common.Popup(...
                'lShowLabel', true, ...
                'cLabel', 'Index Start', ...
                'fhDirectCallback', @this.onPopupIndexStart ...
                );
            this.uiPopupIndexEnd = mic.ui.common.Popup(...
                'lShowLabel', true, ...
                'cLabel', 'Index End', ...
                'fhDirectCallback', @this.onPopupIndexEnd ...
                );
            
            this.initUiPositionRecaller();
        end
 
        
        function buildAxes1(this)
            
            dLeft = this.getLeft1();
            dTop = this.getTopAxes1();
            
            this.hAxes1 = axes(...
                'Parent', this.hParent, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hParent),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
                        
        end
        
        
        
        function buildAxes2(this)
            
            dLeft = this.getLeft2();
            dTop = this.getTopAxes1();
            
            this.hAxes2 = axes(...
                'Parent', this.hParent, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hParent),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
                        
        end
        
        function buildAxes3(this)
            
            dLeft = this.getLeft3();
            dTop = this.getTopAxes1();
            
            this.hAxes3 = axes(...
                'Parent', this.hParent, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hParent),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
                        
        end
        
        function buildAxes4(this)
            
            dLeft = this.getLeft4();
            dTop = this.getTopAxes1();
            
            this.hAxes4 = axes(...
                'Parent', this.hParent, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hParent),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
                        
        end
        
        function buildAxes5(this)
            
            dLeft = this.getLeft1();
            dTop = this.getTopAxes3();
            
            this.hAxes5 = axes(...
                'Parent', this.hParent, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hParent),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
                        
        end
        
        function buildAxes6(this)
            
            dLeft = this.getLeft2();
            dTop = this.getTopAxes3();
            
            this.hAxes6 = axes(...
                'Parent', this.hParent, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hParent),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
                        
        end
        
        function buildAxes7(this)
            
            dLeft = this.getLeft3();
            dTop = this.getTopAxes3();
            
            this.hAxes7 = axes(...
                'Parent', this.hParent, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hParent),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
                        
        end
        
        function buildAxes8(this)
            
            dLeft = this.getLeft4();
            dTop = this.getTopAxes3();
            
            this.hAxes8 = axes(...
                'Parent', this.hParent, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hParent),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
                        
        end
        
        
        
        
         
         function onDockClose(this, ~, ~)
            if ~isempty(this.hParent) && ~isvalid(this.hParent)
                return
            end
            
            this.hParent = [];
         end
         
        
         function d = getTopPulldown1(this)
             d = this.dHeightOffsetTop + ...
             	this.dHeightPadPopupTop;
         end
         
         function d = getTopPulldown3(this)
             d = this.getTopPulldown1() + ...
                this.dHeightPopupFull + ...
                this.dHeightPadAxesTop + ...
                this.dHeightAxes + ...
                this.dHeightPadAxesBottom + ...
                this.dHeightPadPopupTop;
         end
         
         
         
         function d = getLeft1(this)
             d = this.dWidthPadAxesLeft;
         end
         
         function d = getLeft2(this)             
             d = this.getLeft1() + ...
                this.dWidthAxes + ...
                this.dWidthPadAxesRight + ...
                this.dWidthPadAxesLeft;
         end
         
         function d = getLeft3(this)             
             d = this.getLeft2() + ...
                this.dWidthAxes + ...
                this.dWidthPadAxesRight + ...
                this.dWidthPadAxesLeft;
         end
         
         function d = getLeft4(this)             
             d = this.getLeft3() + ...
                this.dWidthAxes + ...
                this.dWidthPadAxesRight + ...
                this.dWidthPadAxesLeft;
         end
         
         
         
         function d = getTopAxes1(this)
             d = this.getTopPulldown1() + ...
                this.dHeightPopupFull + ...
                this.dHeightPadAxesTop;
         end
         
         function d = getTopAxes3(this)
             d = this.getTopAxes1() + ...
                this.dHeightAxes + ...
                this.dHeightPadAxesBottom + ...
                this.dHeightPadPopupTop + ...
                this.dHeightPopupFull + ...
                this.dHeightPadAxesTop;
         end
         
         function initUiPositionRecaller(this)
            
            cDirThis = fileparts(mfilename('fullpath'));
            cPath = fullfile(cDirThis, '..', '..', 'save', 'position-recaller');
            this.uiPositionRecaller = mic.ui.common.PositionRecaller(...
                'cConfigPath', cPath, ... 
                'cName', [this.cName, '-position-recaller'], ...
                'cTitleOfPanel', 'Saved Settings', ...
                'lShowLabelOfList', false, ...
                'lLoadOnSelect', true, ...
                'lShowLoadButton', false, ...
                'hGetCallback', @this.onUiPositionRecallerGet, ...
                'hSetCallback', @this.onUiPositionRecallerSet ...
            );
         end
        
        
         
         function dValues = onUiPositionRecallerGet(this)
                        
             dValues = [...
                this.uiPopup1.getSelectedIndex(), ...
                this.uiPopup2.getSelectedIndex(), ...
                this.uiPopup3.getSelectedIndex(), ...
                this.uiPopup4.getSelectedIndex(), ...
                this.uiPopup5.getSelectedIndex(), ...
                this.uiPopup6.getSelectedIndex(), ...
                this.uiPopup7.getSelectedIndex(), ...
                this.uiPopup8.getSelectedIndex(), ...
                this.uiCheckboxDC1.get(), ...
                this.uiCheckboxDC2.get(), ...
                this.uiCheckboxDC3.get(), ...
                this.uiCheckboxDC4.get(), ...
                this.uiCheckboxDC5.get(), ...
                this.uiCheckboxDC6.get(), ...
                this.uiCheckboxDC7.get(), ...
                this.uiCheckboxDC8.get(), ...
             ];

        end
        
        % Set recalled values into your app
        function onUiPositionRecallerSet(this, dValues)
            
            this.uiPopup1.setSelectedIndex(uint8(dValues(1)));
            this.uiPopup2.setSelectedIndex(uint8(dValues(2)));
            this.uiPopup3.setSelectedIndex(uint8(dValues(3)));
            this.uiPopup4.setSelectedIndex(uint8(dValues(4)));
            this.uiPopup5.setSelectedIndex(uint8(dValues(5)));
            this.uiPopup6.setSelectedIndex(uint8(dValues(6)));
            this.uiPopup7.setSelectedIndex(uint8(dValues(7)));
            this.uiPopup8.setSelectedIndex(uint8(dValues(8)));
            this.uiCheckboxDC1.set(dValues(9));
            this.uiCheckboxDC2.set(dValues(10));
            this.uiCheckboxDC3.set(dValues(11));
            this.uiCheckboxDC4.set(dValues(12));
            this.uiCheckboxDC5.set(dValues(13));
            this.uiCheckboxDC6.set(dValues(14));
            this.uiCheckboxDC7.set(dValues(15));
            this.uiCheckboxDC8.set(dValues(16));
            
            this.onPopup1([], []);
            this.onPopup2([], []);
            this.onPopup3([], []);
            this.onPopup4([], []);
            this.onPopup5([], []);
            this.onPopup6([], []);
            this.onPopup7([], []);
            this.onPopup8([], []);
                                
        end
         
         
        
    end
    
    
end