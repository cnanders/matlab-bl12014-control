classdef Reticle < mic.Base
    
    % uiCoarseStage
    
    properties (Constant)
      
        dWidth      = 620
        dHeight     = 780
        
    end
    
	properties
        
        uiCoarseStage
        uiFineStage
        mod3cap
        zpa
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                      
        clock
        hFigure
        hTrack
        hCarriage
        hIllum
        dDelay = 0.1
        dFieldX
        dFieldY
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = Reticle(varargin)
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            this.init();
            
        end
        
                
        function build(this)
                        
            % Figure
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'Reticle Control', ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onCloseRequest ...
                );
            
            % There is a bug in the default 'painters' renderer when
            % drawing stacked patches.  This is required to make ordering
            % work as expected
            
            set(this.hFigure, 'renderer', 'OpenGL');
            
            drawnow;

            dTop = 10;
            dPad = 10;
            % this.mod3cap.build(this.hFigure, dPad, dTop);
            this.uiCoarseStage.build(this.hFigure, dPad, dTop);
            dTop = dTop + this.uiCoarseStage.dHeight + dPad;
            
            this.uiFineStage.build(this.hFigure, dPad, dTop);
            dTop = dTop + this.uiFineStage.dHeight + dPad;
            
            this.zpa.build(this.hFigure, dPad, dTop);
            
            
            this.hTrack = hggroup(...
                'Parent', this.zpa.hHggroup, ...
                'HitTest', 'off' ...
            );
            this.drawTrack();
            
            this.hCarriage = hgtransform(...
                'Parent', this.zpa.hHggroup, ...
                'HitTest', 'off' ...
            );
            this.drawCarriage();
            this.drawReticle();
            
            this.hIllum = hggroup(...
                'Parent', this.zpa.hHggroup, ...
                'HitTest', 'off' ...
            );
            this.drawIllum();
            
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
            
            % Clean up clock tasks
            
            if (isvalid(this.clock))
                this.clock.remove(this.id());
            end
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end
        
        %{
        function addExposureArea(this, dX1, dY1, dX2, dY2)
            
            
        end
        
        function purgeExposureAreas(this)
            
            
        end
        
        function addExposure(this, dX, dY)
            
        end
        
        function purgeExposures(this)
            
        end
        %}
        
        
        
            

    end
    
    methods (Access = private)
        
        function onClock(this)
            
            % Make sure the hggroup of the carriage is at the correct
            % location.  
            
            hHgtf = makehgtform('translate', [this.uiCoarseStage.uiX.getValCalDisplay() this.uiCoarseStage.uiY.getValCalDisplay() 0]);
            if ishandle(this.hCarriage);
                set(this.hCarriage, 'Matrix', hHgtf);
            end
            
            
        end
        
        
        
        function init(this)
            
           
            this.uiCoarseStage = bl12014.ui.ReticleCoarseStage(...
                'clock', this.clock ...
            );
                       
            this.uiFineStage = bl12014.ui.ReticleFineStage(...
                'clock', this.clock ...
            );
            
            % this.mod3cap = Mod3CapSensor(this.clock);
            this.zpa = mic.ui.axes.ZoomPanAxes(-1, 1, -1, 1, 600, 450, 200);
            this.clock.add(@this.onClock, this.id(), this.dDelay);

        end
        
        
        function onCloseRequest(this, src, evt)
            this.msg('ReticleControl.closeRequestFcn()');
            delete(this.hFigure);
            % this.saveState();
        end
        
        function drawTrack(this)
           
           % (L)eft (R)ight (T)op (B)ottom
           
           dL = -327e-3;
           dR = 623e-3;
           dT = 329e-3;
           dB = -329e-3;
           
           patch( ...
               [dL dL dR dR], ...
               [dB dT dT dB], ...
               [0.5, 0.5, 0.5], ...
               'Parent', this.hTrack, ...
               'EdgeColor', 'none', ...
               'HitTest', 'off' ...
           );
           
           dT = 184e-3;
           dB = -184e-3;
           
           patch( ...
               [dL dL dR dR], ...
               [dB dT dT dB], ...
               [0.6, 0.6, 0.6], ...
               'Parent', this.hTrack, ...
               'EdgeColor', 'none', ...
               'HitTest', 'off' ...
           );
            
        end
        
        function drawIllum(this)
                        
            dL = -1000e-6/2;
            dR = 1000e-6/2;
            dT = 150e-6/2;
            dB = -150e-6/2;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                hsv2rgb(0.9, 1, 1), ...
                'HitTest', 'off', ...
                'Parent', this.hIllum, ...
                'FaceAlpha', 0.5, ...
                'LineWidth', 2, ...
                'EdgeColor', [1, 1, 1] ...
            );
        
            uistack(hPatch, 'top');
        end
        
        function drawCarriage(this)
            

            dL = -200e-3;
            dR = 200e-3;
            dT = 200e-3;
            dB = -200e-3;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                [0.4, 0.4, 0.4], ...
                'HitTest', 'off', ...
                'Parent', this.hCarriage, ...
                'EdgeColor', 'none');
            

            % Circular part without the triangle-ish thing
                       
            dTheta = linspace(0, 2*pi, 100);
            dR = 175e-3;
          
            patch( ...
                dR*sin(dTheta), ...
                dR*cos(dTheta), ...
                [0.5, 0.5, 0.5], ...
                'HitTest', 'off', ...
                'Parent', this.hCarriage, ...
                'EdgeColor', 'none');
            
            % The part in 60-degree archs with 60-degree flats
            
            dDTheta = 1/360;
            dTheta = [0/180:dDTheta:30/180, ...
                90/180:dDTheta:150/180, ...
                210/180:dDTheta:270/180, ...
                330/180:dDTheta: 360/180]*pi;
            
            % dR = 173e-3;
            dTheta = dTheta - 30*pi/180;
            
            hPatch = patch( ...
                dR*sin(dTheta), ...
                dR*cos(dTheta), ...
                [0.3, 0.3, 0.3], ...
                'HitTest', 'off', ...
                'Parent', this.hCarriage, ...
                'EdgeColor', 'none');
            
        
            %{
            dT = [0*pi/180:dt:70*pi/180,...
            110*pi/180:dt:170*pi/180,...
            190*pi/180:dt:360*pi/180];
            %}
                
            
            
        end
        
        
        function drawReticle(this)
                        
            dL = -3*25.4e-3;
            dR = 3*25.4e-3;
            dT = 3*25.4e-3;
            dB = -3*25.4e-3;

            patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                [0, 0, 0], ...
                'HitTest', 'off', ...
                'Parent', this.hCarriage, ...
                'EdgeColor', 'none' ...
            );
            
            
            % The fields
            
            dX = 2.5e-3;           
            dY = 2.5e-3;
            
            this.dFieldX = -9*dX:dX:9*dX;        % center
            this.dFieldY = 9*dY:-dY:-9*dY;        % center
            
            % Field is 1 mm x 150 um
            
            dL = -0.5e-3;
            dR = 0.5e-3;
            dT = 0.15e-3/2;
            dB = -0.15e-3/2;
            
            dTextYOffset = -0.3e-3;
            
            % use HSV to get a rainbow.
            % H in [0:1] goes between ROYGBIV
            % S in [0:1] is how vivid the color is
            % V in [0:1] goes between black and white (or transparent and
            % not)
            
            dMinV = 0.5;       % Minimum value (how transparent it can get)
            
            for k = 1:length(this.dFieldX) % col
                for l = 1:length(this.dFieldY) % row
                    % fprintf('x: %1.4f, y: %1.4f\n', dFieldX(k), dFieldY(l));
                    
                    
                    dH = k/length(this.dFieldX);
                    dV = dMinV + (1 - dMinV)*l/length(this.dFieldY);
                    
                    patch( ...
                        [dL dL dR dR] + this.dFieldX(k), ...
                        [dB dT dT dB] + this.dFieldY(l), ...
                        hsv2rgb([dH, 1, dV]), ...
                        'Parent', this.hCarriage, ...
                        'EdgeColor', 'none', ...
                        'HitTest', 'on', ...
                        'ButtonDownFcn', {@this.handleFieldClick, k, l} ...
                    );
                
                    % cLabel = sprintf('R%1.0f C%1.0f', l, k);
                    cLabel = sprintf('%02d, %02d', l, k);
                    
                    text( ...
                        this.dFieldX(k) + dL, this.dFieldY(l) + dTextYOffset, cLabel, ...
                        'Parent', this.hCarriage, ...
                        'Interpreter', 'none', ...
                        'Clipping', 'on', ...
                        'HitTest', 'off', ...
                        'Color', [0.5, 0.5, 0.5] ...
                    );
                    
                    
                end
            end 
            
            
        end
        
        
        function handleFieldClick(this, src, evt, col, row)
            
            this.msg(sprintf('ReticleControl.handleFieldClick() col: %1d, row: %1d', col, row));
           
            this.uiCoarseStage.uiX.setDestCalDisplay(-this.dFieldX(col));
            this.uiCoarseStage.uiY.setDestCalDisplay(-this.dFieldY(row));
            
            this.uiCoarseStage.uiX.moveToDest();
            this.uiCoarseStage.uiY.moveToDest();            
            
        end
        

    end % private
    
    
end