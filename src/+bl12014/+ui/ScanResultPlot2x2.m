classdef ScanResultPlot2x2 < mic.Base
    
    % rcs
    
	properties
               
       
       
    end
    
    properties (SetAccess = private)
        
        dWidth              = 1200;
        dHeight             = 900;
        
        dWidthPadAxesLeft = 60
        dWidthPadAxesRight = 40
        dHeightPadAxesTop = 5
        dHeightPadAxesBottom = 60
        dWidthAxes = 300
        dHeightAxes = 200
        dHeightOffsetTop = 30;
       
        dWidthPopup = 200;
        dHeightPopup = 24;
        dHeightPopupFull = 40;
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
                
    end
    
        
    events
        
        
        
    end
    

    
    methods
        
        
        function this = ScanResultPlot2x2()
            
            this.init();
            this.cPath = '';
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
        
        function ce = getPropsSaved(this)
            
            ce = {...
                'uiePositionX', ...
                'uiePositionY', ...
                'uiePositionStepX', ...
                'uiePositionStepY', ...
                'uipPositionType', ...
                'uieDoseNum', ...
                'uieDoseCenter', ...
                'uieDoseStep', ...
                'uipDoseStepType', ...
                'uieFocusNum', ...
                'uieFocusCenter', ...
                'uieFocusStep' ...
            };
        
        end
        
        
        % @return {struct} UI state to save
        function st = save(this)
            st  = struct();
            return;
            
            ceProps = this.getPropsSaved();
        
            st = struct();
            for n = 1 : length(ceProps)
                cProp = ceProps{n};
                st.(cProp) = this.(cProp).save();
            end
            
        end
        
        % @param {struct} UI state to load.  See save() for info on struct
        function load(this, st)
            
            return
            
            %{
            this.lLoading = true;
            
            ceProps = this.getPropsSaved();
        
            for n = 1 : length(ceProps)
                cProp = ceProps{n};
                if isfield(st, cProp)
                    try
                        this.(cProp).load(st.(cProp));
                    end
                end
            end
            
            
            this.lLoading = false;
            
            % call updateSize() to dispatch the event
            this.updateSize();
            this.updateFocus();
            this.updateDose();
            %}
            
            
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
                600, ...
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
                '*.csv', ...
                'Select a Scan Result .csv File', ...
                this.cPath ...
            );
        
            if isequal(cFile, 0)
               return; % User clicked "cancel"
            end
            
            this.cPath = mic.Utils.path2canonical(cPath);
            this.cFile = cFile;
            
            % this.refresh(); 
            this.uiTextFile.set([this.cPath, this.cFile]);      
        end
        
        
        function onPopup1(this, src, evt)
            
        end
        
        function onPopup2(this, src, evt)
            
        end
        
        function onPopup3(this, src, evt)
            
        end
        
        function onPopup4(this, src, evt)
            
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
                'fhDirectCallback', @this.onPopup1 ...
            );
            this.uiPopup2 = mic.ui.common.Popup(...
                'fhDirectCallback', @this.onPopup2 ...
                );
            this.uiPopup3 = mic.ui.common.Popup(...
                'fhDirectCallback', @this.onPopup3 ...
                );
            this.uiPopup4 = mic.ui.common.Popup(...
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
                'Name', 'Beamline Control', ...
                'CloseRequestFcn', @this.onFigureCloseRequest, ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ... 
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on' ...
            );

            
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