classdef ScanResultPlot2x2 < mic.Base
    
    % rcs
    
	properties
               
       
       
    end
    
    properties (SetAccess = private)
        
        dWidth              = 1300;
        dHeight             = 900;
        
        dWidthPadAxesLeft = 60
        dWidthPadAxesRight = 40
        dHeightPadAxesTop = 10
        dHeightPadAxesBottom = 40
        dWidthAxes = 550
        dHeightAxes = 330
        dHeightOffsetTop = 30;
       
        dWidthPopup = 200;
        dHeightPopup = 24;
        dHeightPopupFull = 30;
        dHeightPadPopupTop = 10;
        
    
    end
    
    properties (Access = private)
         
        hFigure
        hAxes1
        hAxes2
        hAxes3
        hAxes4
        
        uiPopup1
        uiPopup2
        uiPopup3
        uiPopup4
        
        uiButtonFile
        uiTextFile
        
        % storage for handles returned by plot()
        hLines
        
        cPath
        cFile
        
        % {struct 1x1} storage of the result struct loaded from JSON
        stResult
        
        % {struct 1x1} computed storage of results in format more useful
        % for plotting
        stResultForPlotting
        
        % {logical 1x1} 
        lLoading
                
    end
    
        
    events
        
        
        
    end
    

    
    methods
        
        
        function this = ScanResultPlot2x2()
            
            this.init();
            
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

            this.cPath = fullfile(cDirThis, '..', '..', 'save');
            this.cFile = '';
            
        end
        
        function delete(this)
                        
            delete(this.uiPopup1);
            delete(this.uiPopup2);
            delete(this.uiPopup3);
            delete(this.uiPopup4);
            delete(this.uiButtonFile);
            delete(this.uiTextFile);
            delete(this.hAxes1);
            delete(this.hAxes2);
            delete(this.hAxes3);
            delete(this.hAxes4);

            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            

        end
        
        function ce = getUiPropsSaved(this)
            
            ce = {...
                'uiTextFile', ...
                'uiPopup1', ...
                'uiPopup2', ...
                'uiPopup3', ...
                'uiPopup4', ...
            };
        
        end
        
        
        % @return {struct} UI state to save
        function st = save(this)
            
        
            st = struct();
            
            st.cPath = this.cPath;
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
            
            if isfield(st, 'cPath')
                this.cPath = st.cPath;
            end
            
            if isfield(st, 'cFile')
                this.cFile = st.cFile;
            end
            
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
        
        function build(this)
            this.buildFigure();
            
            this.buildAxes1();
            this.buildAxes2();
            this.buildAxes3();
            this.buildAxes4();
            
            dLeft = this.getLeft1();
            dTop = 10;
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
                900, ...
                24 ...
            );
                
            
            dLeft = this.getLeft1();
            dTop = this.getTopPulldown1();
            this.uiPopup1.build(...
                this.hFigure, ...
                dLeft , ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
        
        
            dLeft = this.getLeft2();
            dTop = this.getTopPulldown1();
            
            this.uiPopup2.build(...
                this.hFigure, ...
                dLeft , ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
        
        
            dLeft = this.dWidthPadAxesLeft;
            dTop = this.getTopPulldown3();
            
            this.uiPopup3.build(...
                this.hFigure, ...
                dLeft , ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
        
        
            dLeft = this.getLeft2();
            
            
            this.uiPopup4.build(...
                this.hFigure, ...
                dLeft , ...
                dTop, ...
                this.dWidthPopup, ...
                this.dHeightPopup ...
            );
                
            
        end
        
        
    end
    
    
    methods (Access = private)
        
        
        function onButtonFile(this, src, evt)
            
            [cFile, cPath] = uigetfile(...
                '*.json', ...
                'Select a Scan Result .json File', ...
                this.cPath ...
            );
        
            if isequal(cFile, 0)
               return; % User clicked "cancel"
            end
            
            this.cPath = mic.Utils.path2canonical(cPath);
            this.cFile = cFile;
            
            % this.refresh(); 
            
            this.loadFileAndUpdateAll()
            
            
            
        end
        
        function loadFileAndUpdateAll(this)
            
            if isempty(this.cPath)
                return
            end
            
            if isempty(this.cFile)
                return
            end
            
            cPathFull = fullfile(this.cPath, this.cFile);
            this.uiTextFile.set(cPathFull);
            
            this.stResult = loadjson(cPathFull);
            this.stResultForPlotting = this.getValuesStructFromResultStruct(this.stResult);
            this.updatePopups()
            
            
        end
        
        % Returns a {struct 1x1} where each prop is a list of values of
        % of a saved result property.  The result structure loaded from
        % .json has a values field that is a cell of structures.  
        function stOut = getValuesStructFromResultStruct(this, st)
            
            % Initialize the structure
            stOut = struct();
            
            if ~this.getResultStructHasValues(st)
                return
            end
            
            ceValues = this.stResult.values;
            stValue = ceValues{1};
            
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
                stValue = ceValues{idxValue};
                if ~isstruct(stValue)
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
                            stOut.(cField)(1, idxValue) = stValue.(cField);
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
        
        
        function updatePopups(this)
            
            if ~this.getResultStructHasValues(this.stResult)
                return
            end
            
            ceValues = this.stResult.values;
            stValue = ceValues{1};
            ceFields = fieldnames(stValue);
            
            this.uiPopup1.setOptions(ceFields);
            this.uiPopup2.setOptions(ceFields);
            this.uiPopup3.setOptions(ceFields);
            this.uiPopup4.setOptions(ceFields);
            
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
            
            this.onPopup1([], []);
            this.onPopup2([], []);
            this.onPopup3([], []);
            this.onPopup4([], []);
            
        end
        
        
        function updateAxes(this, hAxes, cProp)
            
            if ~this.getResultStructHasValues(this.stResult)
                return
            end
            
            plot(hAxes, ...
                this.stResultForPlotting.(cProp), '.-b');
            xlabel(hAxes, 'State Num');
            try
                ylabel(hAxes, this.stResult.unit.(cProp));
            end
            
        end
        
        function onPopup1(this, src, evt)
            this.updateAxes(this.hAxes1, this.uiPopup1.get());
        end
        
        function onPopup2(this, src, evt)
            this.updateAxes(this.hAxes2, this.uiPopup2.get());
        end
        
        function onPopup3(this, src, evt)
        	this.updateAxes(this.hAxes3, this.uiPopup3.get());

        end
        
        function onPopup4(this, src, evt)
            this.updateAxes(this.hAxes4, this.uiPopup4.get());

        end
        
        function init(this)
            
            this.uiButtonFile = mic.ui.common.Button(...
                'cText', 'Choose File', ...
                'fhDirectCallback', @this.onButtonFile ...
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
            
        end
        
        
        function buildFigure(this)
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end

            dScreenSize = get(0, 'ScreenSize');
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'Scan Result 2x2 Plotter', ...
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
        
        function buildAxes1(this)
            
            dLeft = this.getLeft1();
            dTop = this.getTopAxes1();
            
            this.hAxes1 = axes(...
                'Parent', this.hFigure, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hFigure),...
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
            
            dLeft = this.getLeft1();
            dTop = this.getTopAxes3();
            
            this.hAxes3 = axes(...
                'Parent', this.hFigure, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hFigure),...
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
                'Parent', this.hFigure, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hFigure),...
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
            
            dLeft = this.getLeft2();
            dTop = this.getTopAxes3();
            
            this.hAxes4 = axes(...
                'Parent', this.hFigure, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hFigure),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
                        
        end
        
        
         function onFigureCloseRequest(this, src, evt)
            
             
            if ~isempty(this.hFigure) && ~isvalid(this.hFigure)
                return
            end
            
            delete(this.hFigure);
            this.hFigure = [];
            
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
             d = this.dWidthPadAxesLeft + ...
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
         
         
        
    end
    
    
end