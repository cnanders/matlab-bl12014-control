classdef Dock < mic.Base
    
    
    properties (Constant)
        
    end
    
    
    properties (SetAccess = private)
        hFigure = {}
        dWidth = 1940
        dHeight = 1080
        hTabGroup
        ceUINames = {}
        
        uibCloseTab
        
        fhCloseRequestHandlers = []
    end
    
    methods
    
        function this = Dock(varargin)
            this.init();
        end
        
        function init(this)
            % Init main tabgroup
            this.hTabGroup = mic.ui.common.Tabgroup();
            this.fhCloseRequestHandlers = struct;
     
            this.uibCloseTab = mic.ui.common.Button('cText', 'X', 'fhDirectCallback', @this.closeActiveTab);
        end
        
        function registerCloseRequestHandler(this, cUIName, fhCloseRequest)
            this.fhCloseRequestHandlers.(this.sanitizeUIName(cUIName)) = fhCloseRequest;
        end
        
        function cName = sanitizeUIName(~, cUIName)
            cName = regexprep(cUIName, '\s', '');
        end
        
        function closeActiveTab(this, ~, ~)
            cActiveTabName = this.hTabGroup.getSelectedTabName();
            this.removeUITab(cActiveTabName);
        end
        
        % Creates a new UITab and returns it
        function uiTab = addUITab(this, cUIName)
            
            % If there are no tabs, then automatically build figure
            if isempty(this.ceUINames)
                this.build();
            end
            this.ceUINames{end + 1} = cUIName;
            
            uiTab = this.hTabGroup.addTab(cUIName);
            this.hTabGroup.alphabetizeTabs();
            this.makeUIActive(cUIName);
            
        end
        
        function removeUITab(this, cUIName)
            dIdx = find(strcmp(this.ceUINames, cUIName));
            this.ceUINames(dIdx) = [];
            
            this.hTabGroup.removeTab(cUIName);
            
            % Remove figure if we are out of tabs
            if isempty(this.ceUINames)
                this.onCloseRequest()
                delete(this.hFigure);
            end
            
            if isfield(this.fhCloseRequestHandlers, cUIName)
                fhCloseRequest = this.fhCloseRequestHandlers.(this.sanitizeUIName(cUIName));
                fhCloseRequest();
                this.fhCloseRequestHandlers = rmfield(this.fhCloseRequestHandlers, (this.sanitizeUIName(cUIName)));
            end
            
            this.hTabGroup.alphabetizeTabs();
        end
        
        function l = doesUIExist(this, cUIName)
            l = this.hTabGroup.doesTabExist(cUIName);
        end
        
        function makeUIActive(this, cUIName)
            this.hTabGroup.selectTabByName(cUIName);
        end
        
        function onCloseRequest(this, src, evt)
            
            this.msg('ReticleControl.closeRequestFcn()');
            
            % run all close request functions:
            ceFields = fieldnames(this.fhCloseRequestHandlers);
            for k = 1:length(ceFields)
                fhCloseRequest = this.fhCloseRequestHandlers.(this.sanitizeUIName(ceFields{k}));
                fhCloseRequest();
            end
            this.fhCloseRequestHandlers = struct;
            
            
            delete(this.hFigure);
            this.hFigure = [];
            % this.saveState();
           
            
        end
        
        
        function build(this)
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name', 'MET5 Control',...
                'Position', [ ...
                (dScreenSize(3) - this.dWidth)/2 ...
                (dScreenSize(4) - this.dHeight)/2 ...
                this.dWidth ...
                this.dHeight ...
                ],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                 'CloseRequestFcn', @this.onCloseRequest, ...
                'Visible', 'on'...
                );
            this.hTabGroup.build(this.hFigure, 10, 20, this.dWidth - 40, this.dHeight - 40);
            
            this.uibCloseTab.build(this.hFigure, this.dWidth - 60, 10, 30, 30);
            this.uibCloseTab.setColor([1, .5, .5]);
        end
        
    end
    
end