classdef ReticleAxes < mic.Base
    
    
    properties (Constant)
      
        
    end
    
	properties
        
        
        uiZoomPanAxes
    end
    
    properties (SetAccess = private)
        
        dWidth = 600
        dHeight = 450
        dZoomMax = 200
        
        cName = 'ReticleAxes'
    
    end
    
    properties (Access = private)
                      
        hTrack
        hCarriage
        hIllum
        dFieldX
        dFieldY
        
    end
    
        
    events
        
        eName
        eClickField
        
    end
    

    
    methods
        
        
        function this = ReticleAxes(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            this.init();
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
                        
            % There is a bug in the default 'painters' renderer when
            % drawing stacked patches.  This is required to make ordering
            % work as expected
            
            set(hParent, 'renderer', 'OpenGL');
            
            this.uiZoomPanAxes.build(hParent, dLeft, dTop);
            
            
            this.hTrack = hggroup(...
                'Parent', this.uiZoomPanAxes.hHggroup, ...
                'HitTest', 'off' ...
            );
            this.drawTrack();
            
            this.hCarriage = hgtransform(...
                'Parent', this.uiZoomPanAxes.hHggroup, ...
                'HitTest', 'off' ...
            );
            this.drawCarriage();
            this.drawReticle();
            
            this.hIllum = hggroup(...
                'Parent', this.uiZoomPanAxes.hHggroup, ...
                'HitTest', 'off' ...
            );
            this.drawIllum();
            
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
            
        end
        
        
        % @param {double 1x1} x position of the stage in meters
        % @param {double 1x1} y position of the stage in meters
        function setStagePosition(this, dX, dY)
            
            % Make sure the hggroup of the carriage is at the correct
            % location. 

            if isnan(dX)
                this.msg('setStagePosition() dX === NaN', this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            if isnan(dY)
                this.msg('setStagePosition() dY === NaN', this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            try
                hHgtf = makehgtform('translate', [dX dY 0]);
                if ishandle(this.hCarriage);
                    set(this.hCarriage, 'Matrix', hHgtf);
                end
            catch mE
                this.msg(getReport(mE));
            end
            
        end
        
        
        
        
        
            

    end
    
    methods (Access = private)
        
        
        function init(this)
            this.msg('init()');
            this.uiZoomPanAxes = mic.ui.axes.ZoomPanAxes(-1, 1, -1, 1, this.dWidth, this.dHeight, this.dZoomMax);

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
                        'ButtonDownFcn', {@this.onFieldClick, k, l} ...
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
        
        
        function onFieldClick(this, src, evt, col, row)
            
            this.msg(sprintf('ReticleControl.onFieldClick() col: %1d, row: %1d', col, row));
           
            stData = struct();
            stData.dX = this.dFieldX(col);
            stData.dY = this.dFieldY(row);
            
            e = mic.EventWithData(stData);
            notify(this, 'eClickField', e);                     
            
        end
        

    end % private
    
    
end