classdef ReticleTool < mic.Base

    
    properties (Constant, Access = private)
        
        d_FIELD_WIDTH       = 1000e-6;       
        d_FIELD_HEIGHT      = 150e-6;       
        d_FIELD_X_PITCH     = 2.5e-3;     
        d_FIELD_Y_PITCH     = 2.5e-3;     
        d_ROWS              = 19;
        d_COLS              = 19;
        d_PxScale           = 400/1000e-6;
        
        dHeightEdit = 24;
        
    end
    
    properties
                
        dX                  % x position of stage including field + offset (um)
        dY                  % y position of stage including field + offset (um)
                
        uipReticle
        uipField
        
        uieXOffset          % x offset (um) to get light centered over field target
        uieYOffset          % y offset (um) to get light centered over field target
        
        uitQA
    end
    
    properties (SetAccess = private)
        dWidth     = 425
        dHeight    = 200 
        
    end
    
    properties (Access = private)
        
        
        cDirSrc
        
        hPanel
        hFigure
        hAxes
        hCrosshairCircles
        hCrosshairLine1
        hCrosshairLine2
        hCrosshairLine3
        hCrosshairLine4
        
        dCrosshairXOffset   % px offset to center of plot.  Right in GUI is +
        dCrosshairYOffset   % px offset to center of plot.  Up in GUI is +
          
        uibZero
        sData               % parse_json(JSON) JSON returned from server
    
    end
       
    events    
        
        eChange
    end
    
    methods
        
        function this = ReticleTool()
        %RETICLEPICKPANEL Class constructor
        %   ReticlePickPanel('name')
        %
        % See also INIT, BUILD, DELETE
            
            cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSrc = fullfile(cDirThis, '..', '..');
            
            this.init();    
        end
                      
        % @return {struct} state to save
        function st = save(this)
            st = struct();
            
            st.u8Reticle = this.uipReticle.getSelectedIndex();
            st.u8Field = this.uipField.getSelectedIndex();
            st.dXOffset = this.uieXOffset.get();
            st.dYOffset = this.uieYOffset.get();
            
        end
        
        % @param {struct} state to load
        function load(this, st)
            this.uipReticle.setSelectedIndex(st.u8Reticle);
            this.uipField.setSelectedIndex(st.u8Field);
            this.uieXOffset.set(st.dXOffset);
            this.uieYOffset.set(st.dYOffset);
        end

        
        
        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the UI element in a figure
        %   ReticlePickPanel.build(hParent, dLeft, dTop)
        %
        % See also RETICLEPICKPANEL, INIT, DELETE
            
            % hParent needs to be a Figure, not a Panel
            this.hFigure = hParent;
            
            % Panel
            this.hPanel = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Reticle',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], this.hFigure) ...
            );
			drawnow; 
            
%             this.hFigure = figure( ...
%                 'NumberTitle', 'off',...
%                 'MenuBar', 'none',...
%                 'Name',  this.cName,...
%                 'Position', [100 100 500 400],... % left bottom width height
%                 'Resize', 'off',...
%                 'HandleVisibility', 'on',... % lets close all close the figure
%                 'Visible', 'on',...
%                 'CloseRequestFcn', @this.onFigure, ...
%                 'WindowButtonMotionFcn', @this.onMouseMotion ...
%                 );
%                 % 'Pointer', 'fullcrosshair' ...
%                 % );
%             
%             drawnow;
                        
            this.uipReticle.build(this.hPanel, 10, 20, 200, 40);
            this.uipField.build(this.hPanel, 210, 20, 200, 40);
            
            
            % The field is 1000 um x 150 mm.  Use 400 px x 60 px (same
            % aspect ratio) for the plot
            
            dWidth = this.d_PxScale*this.d_FIELD_WIDTH;
            dHeight = this.d_PxScale*this.d_FIELD_HEIGHT;
            
            this.hAxes = axes(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([10 70 dWidth dHeight], this.hPanel),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                'XTick',[],...
                'YTick',[],...
                'XColor','white',...
                'YColor','white',...
                'HandleVisibility','on', ...
                'XLimMode', 'manual',...
                'YLimMode', 'manual', ...
                'ZLimMode', 'manual', ...
                'ALimMode', 'manual', ...
                'CLimMode', 'manual', ...
                'ZLimMode', 'manual', ...
                'ButtonDownFcn', @this.onAxesClick ...
                );
            
            drawnow;
            
            dTop = 145;
            
            this.uieXOffset.build(this.hPanel, 10, dTop, 100, this.dHeightEdit);
            this.uieYOffset.build(this.hPanel, 110, dTop, 100, this.dHeightEdit);
            
            dTop = dTop + 14;
            this.uibZero.build(this.hPanel, 220, dTop, 100, this.dHeightEdit);
            this.uitQA.build(this.hPanel, 390, dTop, 20, this.dHeightEdit);
            
            % The ButtonDownFunction listener registers clicks on the axes
            % but if you add anything handles on top of the axes (for
            % example with plot(...) or image(...), you also need to add
            % the click listener to those handles since they will be "on
            % top" of the axes.
            
            % Listen for mouse motion to draw crosshair inside axes
            % set(this.hFigure, 'WindowButtonMotionFcn', @this.onMouseMotion);
            
            % Initilaize field in plot
            this.onField();
        end
        
        function cReticles = getReticleOptions(this)
            
            % Return a cell array of chars with the name of each reticle
            
            cReticles = cell(0);
            for k = 1:length(this.sData.reticles)
                cReticles{k} = this.sData.reticles{k}.name;
            end

        end
        
        
        function cFields = getFieldOptions(this)
            
           % Based on the value of the reticle popup, return a cell array
           % of char with the name of each field in the selected reticle
           
           cFields = cell(0);
           for k = 1:length(this.sData.reticles{this.uipReticle.getSelectedIndex()}.fields)
               cFields{k} = this.sData.reticles{this.uipReticle.getSelectedIndex()}.fields{k}.name;
           end
            
        end
        
    end
    
    methods (Access = private)
        
        function init(this)
        %INIT Initializes the Reticle Pick Panel class
        %   ReticlePickPanel.init()
        %    reads and parse JSON with reticle/field data.  Eventually this
        %    will be a URL request that returns JSON. For now I will read
        %    a text file with JSON
        
            
            cPath = fullfile(this.cDirSrc, 'reticles.json');
            this.sData = parse_json(fileread(cPath));
            
            this.sData = this.sData{1}; % has to do with parse_json

            this.uipReticle = mic.ui.common.Popup( ...
                'ceOptions', this.getReticleOptions(), ...
                'cLabel', 'Reticle' ...
            );
            
            this.uipField = mic.ui.common.Popup( ...
                'ceOptions', this.getFieldOptions(), ...
                'cLabel', 'Field' ...
            );
            
            this.uieXOffset = mic.ui.common.Edit(...
                'cLabel', 'X offset (um)', ...
                'cType', 'd' ...
            );
            this.uieYOffset = mic.ui.common.Edit(...
                'cLabel', 'Y offset (um)', ...
                'cType', 'd' ...
            );
            this.uibZero = mic.ui.common.Button(...
                'cText', 'Re-zero' ...
            );
            
            
            this.uitQA = mic.ui.common.Toggle(...
                'cTextTrue', 'X', ...
                'cTextFalse', 'OK' ...
            );
        
        
            this.dCrosshairXOffset = this.d_FIELD_WIDTH * this.d_PxScale / 2;
            this.dCrosshairYOffset = this.d_FIELD_HEIGHT * this.d_PxScale / 2;
            this.uieXOffset.set(0);
            this.uieYOffset.set(0);
                        
            addlistener(this.uieXOffset, 'eChange', @this.onXOffset);
            addlistener(this.uieYOffset, 'eChange', @this.onYOffset);
            addlistener(this.uibZero, 'eChange', @this.onZero);
            addlistener(this.uipReticle, 'eChange', @this.onReticle);
            addlistener(this.uipField, 'eChange', @this.onField);
            
            addlistener(this.uitQA, 'eChange', @this.onQA);
        end
        
        
        function onQA(this, ~, ~)
            
            if this.uitQA.get()
                set(this.hPanel, ...
                    'BackgroundColor', [1 .6 1] ...
                );
            else
                set(this.hPanel, ...
                    'BackgroundColor', [.94 .94 .94] ...
                );
            end
            
        end
        
        function onReticle(this, src, evt)
            
            this.uipField.setOptions(this.getFieldOptions());
            notify(this, 'eChange');
            
        end
        
        
        function onField(this, src, evt)
            
            if isempty(this.hAxes) 
                return
            end
            
            if ~ishandle(this.hAxes)
                return
            end
            
            % Update field plot/image
            
            u8R = this.uipReticle.getSelectedIndex();
            u8F = this.uipField.getSelectedIndex();
            
            
            cPath = fullfile(...
                this.cDirSrc, ...
                'img', ...
                'reticles', ...
                this.sData.reticles{u8R}.name, ...
                sprintf(...
                    '%1.0f%1.0f.jpg', ...
                    this.sData.reticles{u8R}.fields{u8F}.row, ...
                    this.sData.reticles{u8R}.fields{u8F}.col ...
                )...
            );
            
            if exist(cPath, 'file') == 2
                
                dImg = imread(cPath);
                % set(this.hFigure, 'CurrentAxes', this.hAxes);
                
                imagesc(dImg, ...
                    'Parent', this.hAxes, ...
                    'ButtonDownFcn', @this.onAxesClick);
                
                % axis('image');
                % colormap('gray');
                set(this.hAxes, 'xtick', [], 'ytick', []);
                
                % Make sure the image handle has the ButtonDown listener
                % set(this.hImage, 'ButtonDownFcn', @this.onAxesClick);
                
            else
                this.msg(sprintf('onField() %s oes not exist', cPath));
            end
            
            % Update dX, dY, dXOffset, dYOffset
            
            this.updatePos();
            this.updateCrosshair();
            
            notify(this, 'eChange');

        end
        
        
        function onFigure(this, src, evt)
            
            delete(this.hFigure);
            
        end
        
                
        
        function onAxesClick(this, src, evt)
            
            % this.msg('ReticlePick.onAxesClick()');
            % get(this.hAxes, 'CurrentPoint')
            
            % Update crosshair
            
            %{
            dCursor = get(this.hFigure, 'CurrentPoint');     % [left bottom]
            dAxes = get(this.hAxes, 'Position');             % [left bottom width height]
            dPanel = get(this.hPanel, 'Position');
            
            dCursorLeft =    dCursor(1);
            dCursorBottom =  dCursor(2);
           
            dAxesLeft =      dAxes(1) + dPanel(1);
            dAxesBottom =    dAxes(2) + dPanel(2);
            dAxesWidth =     dAxes(3);
            dAxesHeight =    dAxes(4);
            
            this.dCrosshairXOffset = dCursorLeft - dAxesLeft - dAxesWidth/2;         % px
            this.dCrosshairYOffset = dCursorBottom - dAxesBottom - dAxesHeight/2;    % px           
           
            %}
            
            dCurrentPoint = get(this.hAxes, 'CurrentPoint');
            this.dCrosshairXOffset = dCurrentPoint(1, 1);
            this.dCrosshairYOffset = dCurrentPoint(1, 2);
            
            this.msg(sprintf('offset: x = %1.1f, y = %1.1f', this.dCrosshairXOffset, this.dCrosshairYOffset));
            this.updateCrosshair();
            this.updatePos();
        end
        
        function updateCrosshair(this)
            
            % Remove previous crosshair
            
            if isempty(this.hAxes) 
                return
            end
            
            if ~ishandle(this.hAxes)
                return
            end
            
            if ishandle(this.hCrosshairCircles)
                delete([ ...
                    this.hCrosshairCircles ...
                    this.hCrosshairLine1 ...
                    this.hCrosshairLine2 ...
                    this.hCrosshairLine3 ...
                    this.hCrosshairLine4]);
            end
            
            dR1 = 5;
            dR2 = 10;
            
            dTime = linspace(0,2*pi,50);
            dX1 = dR1*cos(dTime) + this.dCrosshairXOffset;
            dY1 = dR1*sin(dTime) + this.dCrosshairYOffset;
            dX2 = dR2*cos(dTime) + this.dCrosshairXOffset;
            dY2 = dR2*sin(dTime) + this.dCrosshairYOffset;
            dX = [dX1 dX2];
            dY = [dY1 dY2];
            
            mult_out = 1.5;
            mult_in = 0.5;
           
            % Line color, line width

            c1 = .3;
            c2 = .1;
            c3 = .4;
            linewidth = 1;
            
            % set(this.hFigure, 'CurrentAxes', this.hAxes);
            
            % Inner / outer circles
            this.hCrosshairCircles = line( ...
                dX, ...
                dY, ...
                'color', [c1 c2 c3], ...
                'LineWidth', linewidth, ...
                'Parent', this.hAxes, ...
                'ButtonDownFcn', @this.onAxesClick ...
                );
            
            % Cross
            this.hCrosshairLine1 = line( ...
                [-dR2*mult_out -dR1*mult_in] + this.dCrosshairXOffset, ...
                [0 0] + this.dCrosshairYOffset, ...
                'color', [c1 c2 c3], ...
                'LineWidth', linewidth, ...
                'Parent', this.hAxes, ...
                'ButtonDownFcn', @this.onAxesClick ...
                );
            
            this.hCrosshairLine2 = line( ...
                [dR2*mult_out dR1*mult_in] + this.dCrosshairXOffset, ...
                [0 0] + this.dCrosshairYOffset, ...
                'color', [c1 c2 c3], ...
                'LineWidth', linewidth, ...
                'Parent', this.hAxes, ...
                'ButtonDownFcn', @this.onAxesClick ...
                );
            
            this.hCrosshairLine3 = line( ...
                [0 0]  + this.dCrosshairXOffset, ...
                [dR2*mult_out dR1*mult_in] + this.dCrosshairYOffset, ...
                'color', [c1 c2 c3], ...
                'LineWidth', linewidth, ...
                'Parent', this.hAxes, ...
                'ButtonDownFcn', @this.onAxesClick ...
                );
            
            this.hCrosshairLine4 = line( ...
                [0 0] + this.dCrosshairXOffset, ...
                -[dR2*mult_out dR1*mult_in] + this.dCrosshairYOffset, ...
                'color', [c1 c2 c3], ...
                'LineWidth', linewidth, ...
                'Parent', this.hAxes, ...
                'ButtonDownFcn', @this.onAxesClick ...
                );
            
        end
        
        
        function onMouseMotion(this, src, evt)
            
           % this.msg('ReticlePickPanel.onMouseMotion()');
           
           % If the mouse is inside the axes, turn the cursor into a
           % crosshair, else make sure it is an arrow
           
           dCursor = get(this.hFigure, 'CurrentPoint');     % [left bottom] relative to this.hFigure
           dAxes = get(this.hAxes, 'Position');             % [left bottom width height] relative to parent (this.hPanel)
           dPanel = get(this.hPanel, 'Position');           % [left bottom width height] relative to parent (this.hFigure)
           
           dCursorLeft =    dCursor(1);
           dCursorBottom =  dCursor(2);
                      
           dAxesLeft =      dAxes(1) + dPanel(1);
           dAxesBottom =    dAxes(2) + dPanel(2);
           dAxesWidth =     dAxes(3);
           dAxesHeight =    dAxes(4);
           
           if   dCursorLeft > dAxesLeft && ...
                dCursorLeft < dAxesLeft + dAxesWidth && ...
                dCursorBottom > dAxesBottom && ...
                dCursorBottom <= dAxesBottom + dAxesHeight
            
                
                if strcmp(get(this.hFigure, 'Pointer'), 'arrow')
                    set(this.hFigure, 'Pointer', 'fullcrosshair')
                end
                
            
           else
           
                if ~strcmp(get(this.hFigure, 'Pointer'), 'arrow')
                    set(this.hFigure, 'Pointer', 'arrow')
                end
                
           end

        end
        
        
        function onZero(this, src, evt)
            
            dWidth = this.d_PxScale*this.d_FIELD_WIDTH;
            dHeight = this.d_PxScale*this.d_FIELD_HEIGHT;
            
            this.dCrosshairXOffset = dWidth/2;
            this.dCrosshairYOffset = dHeight/2;
            
            this.updatePos();
            this.updateCrosshair();
        end
        
        
        function onXOffset(this, src, evt)
            
            % Update crosshair
            dWidth = this.d_PxScale*this.d_FIELD_WIDTH;
            this.dCrosshairXOffset = -this.uieXOffset.get()/1e6*this.d_PxScale + dWidth/2;
            this.updateCrosshair();
            
            notify(this, 'eChange');
            
        end
        
        
        function onYOffset(this, src, evt)
            
            % Update crosshair
            dHeight = this.d_PxScale*this.d_FIELD_HEIGHT;
            this.dCrosshairYOffset = -this.uieYOffset.get()/1e6*this.d_PxScale + dHeight/2;
            this.updateCrosshair();
            
            notify(this, 'eChange');

        end
        
        
        function updatePos(this)
            
        %UPDATEPOS Updates dX, dY, dXOffset, dYOffset
        %   ReticlePickPanel.updatePos()
            
            % If we assume that the stage axis is oriented such that when
            % you look at the multilayer side of the reticle as you hold it
            % in your hand (as you are the photons), the right side of the
            % mask is positive x, the left side is negative x
            
            dWidth = this.d_PxScale*this.d_FIELD_WIDTH;
            dHeight = this.d_PxScale*this.d_FIELD_HEIGHT;
            
            this.uieXOffset.set(-(this.dCrosshairXOffset - dWidth/2)/this.d_PxScale*1e6);
            this.uieYOffset.set(-(this.dCrosshairYOffset - dHeight/2)/this.d_PxScale*1e6);

            % Compute the stage position.  Assume that 0,0 is the center of
            % the reticle.  I will need to program some offsets here.  This
            % will assume that the middle of the fields area is in the
            % center of the reticle
            
            u8R = this.uipReticle.getSelectedIndex();
            u8F = this.uipField.getSelectedIndex();
            
            dActiveRow = this.sData.reticles{u8R}.fields{u8F}.row;
            dActiveCol = this.sData.reticles{u8R}.fields{u8F}.col;
            
            % X
            if this.d_COLS == floor(this.d_COLS/2)
                % even
                % space is in the middle, need to subtract 0.5 of the pitch
                this.dX = (this.d_COLS/2 - dActiveCol - 0.5)*this.d_FIELD_X_PITCH + this.uieXOffset.get()*1e-6;
                
            else
                % odd.  easy since a field is centered in the middle
                this.dX = (ceil(this.d_COLS/2) - dActiveCol)*this.d_FIELD_X_PITCH + this.uieXOffset.get()*1e-6;
            end
            
            % Y
            if this.d_ROWS == floor(this.d_ROWS/2)
                % even
                % space is in the middle, need to subtract 0.5 of the pitch
                this.dY = (dActiveRow - this.d_ROWS/2 - 0.5)*this.d_FIELD_Y_PITCH + this.uieYOffset.get()*1e-6;
                
            else
                % odd.  easy since a field is centered in the middle
                this.dY = (dActiveRow - ceil(this.d_ROWS/2))*this.d_FIELD_Y_PITCH + this.uieYOffset.get()*1e-6;
            end
 
        end
 
    end 
    
end %classdef