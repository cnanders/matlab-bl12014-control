classdef ReticleAxes < mic.Base
    
    
    properties (Constant)
      
        
    end
    
	properties
        
        
        uiZoomPanAxes
    end
    
    properties (SetAccess = private)
        
        dWidth = 600
        dHeight = 600
        dZoomMax = 200
        dZoomMinForFieldLabels = 40
        
        cName = 'ReticleAxes'
        
        
        
        dXYag = 97.93/1000
        dYYag = -3.32/1000
        
        dXDiode = 97.93/1000
        dYDiode = -3.32/1000 - 7.5/1000 % 7.5 mm center to center
    
    end
    
    properties (Access = private)
                      
        hTrack
        hCarriage
        hIllum

        hCrosshairCam1
        hCrosshairCam2
        hCrosshairCap1
        hCrosshairCap2
        hCrosshairCap3
        hCrosshairCap4
        hCrosshairChiefRay
        hCrosshairZero
        hCrosshairLoadLock
        hCrosshairDiode
        hCrosshairYag
        
        hReticle
        hLabels
        hFields
        
        dFieldX
        dFieldY
        
        % {double 1x1} height of crosshair at center of wafer
        
        
        hClockTimes
        
        % 2018.04.18 PROBABLY DEPRECATE
        % offset of the center of the reticle relative to the center of the
        % RCX, RCY stage.  Nomally 0. Each time we load, this will change a
        % bit. 
        dXReticleCenter = 0e-3
        dYReticleCenter = 0e-3
        
        
        % {double 1x1} thickness of crosshair at center of wafer
        dThicknessOfCrosshair
                
        dAlphaCrosshairWafer = 1;
        dColorCrosshairWafer = [0 1 0];
        dSizeCrosshairWafer = 100e-3;
        
        dAlphaCrosshairChiefRay = 1;
        dColorCrosshairChiefRay = [1 0 1];
        dSizeCrosshairChiefRay = 20e-3;
        
        dAlphaCrosshairZero = 1;
        dColorCrosshairZero = [1 1 1];
        
        dAlphaCrosshairLoadLock = 1;
        dColorCrosshairLoadLock = [1 1 0];
        
        
        dAlphaCrosshairDiode = 1;
        dColorCrosshairDiode = [1 1 0];
        dSizeCrosshairDiode = 10e-3;

        dAlphaCrosshairYag = 1;
        dColorCrosshairYag = [1 1 0];
        dSizeCrosshairYag = 10e-3;
        
        
        dAlphaCrosshairCap1 = 1;
        dColorCrosshairCap1 = [1 1 0];
        dSizeCrosshairCap1 = 10e-3;
        
        dAlphaCrosshairCap2 = 1;
        dColorCrosshairCap2 = [1 1 0];
        dSizeCrosshairCap2 = 10e-3;
        
        dAlphaCrosshairCap3 = 1;
        dColorCrosshairCap3 = [1 1 0];
        dSizeCrosshairCap3 = 10e-3;
        
        dAlphaCrosshairCap4 = 1;
        dColorCrosshairCap4 = [1 1 0];
        dSizeCrosshairCap4 = 10e-3;
        
        
        dAlphaCrosshairCam1 = 1;
        dColorCrosshairCam1 = [1 1 0];
        dSizeCrosshairCam1 = 10e-3;
        
        dAlphaCrosshairCam2 = 1;
        dColorCrosshairCam2 = [1 1 0];
        dSizeCrosshairCam2 = 10e-3;
        
        dXZero = 0
        dYZero = 0
        
        dXLoadLock = -0.35 % As drawn, needs to be on left, even through this is positive X coordinate of stage.
        dYLoadLock = 0
                
    end
    
    properties (SetAccess = private)
        
        % location of EUV beam relative to 0, 0 coordinate of RCXY stages
        % can determine this experimentally 
        
        dXChiefRay = -42/1000
        dYChiefRay = 3.42/1000
        
        % These get set relative to dX/YChiefRay in constructor
        dXCap1 = 0
        dYCap1 = 0
        
        dXCap2 = 0
        dYCap2 = 0
        
        dXCap3 = 0
        dYCap3 = 0
        
        dXCap4 = 0
        dYCap4 = 0
        
        dXCam1 = 0;
        dYCam1 = 0;
        
        dXCam2 = 0;
        dYCam2 = 0;
        
        
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
            
            % Values foound in this Google Drive Document 
            % https://drive.google.com/drive/u/1/folders/1u3exI3KsOyzyBwwFe0cZU5mPFVUcB_w9
            
            this.dXCap4 = this.dXChiefRay - 34.075 / 1000;
            this.dYCap4 = this.dYChiefRay;

            this.dXCap3 = this.dXChiefRay + 34.075 / 1000;
            this.dYCap3 = this.dYChiefRay;

            this.dXCap1 = this.dXCap4;
            this.dYCap1 = this.dYChiefRay - 27.833 / 1000;

            this.dXCap2 = this.dXCap3;
            this.dYCap2 = this.dYCap1;
            
            this.dXCam1 = this.dXChiefRay - 68 / 1000;
            this.dYCam1 = this.dYChiefRay;
            
            this.dXCam2 = this.dXChiefRay + 68 / 1000;
            this.dYCam2 = this.dYChiefRay;
        
            this.init();
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            this.dThicknessOfCrosshair = this.getThicknessOfCrosshair();

                        
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
            
            this.hCrosshairDiode = hggroup('Parent', this.hCarriage);
            this.drawCrosshairDiode();
            
            this.hCrosshairYag = hggroup('Parent', this.hCarriage);
            this.drawCrosshairYag();
            
            
            this.hReticle         = hggroup('Parent', this.hCarriage);
            this.drawReticle();
            
            
            this.hLabels = hggroup('Parent', this.hReticle);
            this.drawLabels();
            
            this.hFields = hggroup('Parent', this.hReticle);
            this.drawFields();
            
            this.hIllum = hggroup(...
                'Parent', this.uiZoomPanAxes.hHggroup, ...
                'HitTest', 'off' ...
            );
            this.drawIllum();
            
            
            this.hCrosshairCam1 = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawCrosshairCam1();
            
            this.hCrosshairCam2 = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawCrosshairCam2();
            
            this.hCrosshairCap1 = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawCrosshairCap1();
            
            this.hCrosshairCap2 = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawCrosshairCap2();
            
            this.hCrosshairCap3 = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawCrosshairCap3();
            
            this.hCrosshairCap4 = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawCrosshairCap4();
            
            this.hCrosshairChiefRay = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawCrosshairChiefRay();
            
            this.hCrosshairZero = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawCrosshairZero();
            
            this.hCrosshairLoadLock = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawCrosshairLoadLock();
            
            
            
            this.hClockTimes    = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawClockTimes();
            
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
            addlistener(this.uiZoomPanAxes, 'eZoom', @this.onZoom);
            addlistener(this.uiZoomPanAxes, 'ePanX', @this.onPan);
            addlistener(this.uiZoomPanAxes, 'ePanY', @this.onPan);
        end
        
        
        function onZoom(this, ~, ~)
            
            
            
            dThickness = this.getThicknessOfCrosshair();
            if dThickness ~= this.dThicknessOfCrosshair
                
                % Update for future
                this.dThicknessOfCrosshair = dThickness;
                
                % Redraw crosshairs
                
                this.deleteCrosshairChiefRay();
                this.drawCrosshairChiefRay();
                
                
                this.deleteCrosshairCam1();
                this.drawCrosshairCam1();
                
                this.deleteCrosshairCam2();
                this.drawCrosshairCam2();
                
                
                this.deleteCrosshairCap1();
                this.drawCrosshairCap1();
                
                this.deleteCrosshairCap2();
                this.drawCrosshairCap2();
                
                this.deleteCrosshairCap3();
                this.drawCrosshairCap3();
                
                this.deleteCrosshairCap4();
                this.drawCrosshairCap4();
                
                this.deleteCrosshairZero();
                this.drawCrosshairZero();
                
                this.deleteCrosshairLoadLock();
                this.drawCrosshairLoadLock();
                
                % Redraw diode crosshair
                this.deleteCrosshairDiode();
                this.drawCrosshairDiode();
                
                % Redraw diode crosshair
                
                this.deleteCrosshairYag();
                this.drawCrosshairYag();
                
                
                
                this.deleteFields();
                this.drawFields();
                
                this.deleteLabels();
                this.drawLabels();
            end
            
            this.deleteClockTimes();
            this.drawClockTimes();
            
            
        end
        
        function onPan(this, ~, ~)
            this.deleteClockTimes();
            this.drawClockTimes(); 
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
                        
            dL = -1000e-6/2 + this.dXChiefRay;
            dR = 1000e-6/2 + this.dXChiefRay;
            dT = 150e-6/2 + this.dYChiefRay;
            dB = -150e-6/2 + this.dYChiefRay;

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
        
            % uistack(hPatch, 'top');
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
        
        function deleteLabels(this)
            this.deleteChildren(this.hLabels)            
        end
        
        
        
        function drawLabels(this)
            
            
            if this.uiZoomPanAxes.getZoom() < this.dZoomMinForFieldLabels
                return
            end
                        
            dX = 2.5e-3;           
            dY = 2.5e-3;
            
            this.dFieldX = (-9*dX : dX : 9*dX) + this.dXReticleCenter;        % center
            this.dFieldY = (9*dY : -dY : -9*dY) + this.dYReticleCenter;        % center
            
            % Field is 1 mm x 150 um
            
            dL = -0.5e-3;
            dR = 0.5e-3;
            dT = 0.15e-3/2;
            dB = -0.15e-3/2;
            
            dTextYOffset = -0.3e-3;
            
            for k = 1:length(this.dFieldX) % col
                for l = 1:length(this.dFieldY) % row
                    % fprintf('x: %1.4f, y: %1.4f\n', dFieldX(k), dFieldY(l));
                
                    % cLabel = sprintf('R%1.0f C%1.0f', l, k);
                    cLabel = sprintf('%02d, %02d', l, k);
                    
                    text( ...
                        this.dFieldX(k) + dL, this.dFieldY(l) + dTextYOffset, cLabel, ...
                        'Parent', this.hLabels, ...
                        'Interpreter', 'none', ...
                        'Clipping', 'on', ...
                        'HitTest', 'off', ...
                        'Color', [0.8, 0.8, 0.8] ...
                    );                    
                end
            end         
            
        end
        
        
        function drawReticle(this)
                        
            dL = -3*25.4e-3 + this.dXReticleCenter;
            dR = 3*25.4e-3 + this.dXReticleCenter;
            dT = 3*25.4e-3 + this.dYReticleCenter;
            dB = -3*25.4e-3 + this.dYReticleCenter;

            patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                [0, 0, 0], ...
                'HitTest', 'off', ...
                'Parent', this.hReticle, ...
                'EdgeColor', 'none' ...
            );
        
        end
        
        
        function deleteFields(this)
            this.deleteChildren(this.hFields)
        end
        
        
        function drawFields(this)
                        
            dX = 2.5e-3;           
            dY = 2.5e-3;
            
            this.dFieldX = (-9*dX : dX : 9*dX) + this.dXReticleCenter;        % center
            this.dFieldY = (9*dY : -dY : -9*dY) + this.dYReticleCenter;        % center
            
            % Field is 1 mm x 150 um
            
            dL = -0.5e-3 - this.dThicknessOfCrosshair/2;
            dR = 0.5e-3 + this.dThicknessOfCrosshair/2;
            dT = 0.15e-3/2 + this.dThicknessOfCrosshair/2;
            dB = -0.15e-3/2 - this.dThicknessOfCrosshair/2;
                        
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
                    
                    hPatch = patch( ...
                        [dL dL dR dR] + this.dFieldX(k), ...
                        [dB dT dT dB] + this.dFieldY(l), ...
                        hsv2rgb([dH, 1, dV]), ...
                        'Parent', this.hFields, ...
                        'EdgeColor', 'none', ...
                        'HitTest', 'on', ...
                        'ButtonDownFcn', {@this.onFieldClick, k, l} ...
                    );
                
                    % uistack(hPatch, 'top');
                               
                end
            end             
        end
        
        
        function onFieldClick(this, src, evt, col, row)
            
            this.msg(sprintf('ReticleControl.onFieldClick() col: %1d, row: %1d', col, row));
           
            stData = struct();
            stData.dX = this.dFieldX(col) * 1000;
            stData.dY = this.dFieldY(row) * 1000;
            
            e = mic.EventWithData(stData);
            notify(this, 'eClickField', e);                     
            
        end
        
        function deleteClockTimes(this)
            this.deleteChildren(this.hClockTimes)
        end
        
        function drawClockTimes(this)
            
            ceProps = {
               'Parent', this.hClockTimes, ...
                'Interpreter', 'none', ...
                'Clipping', 'on', ...
                'HitTest', 'off', ...
                'FontSize', 10, ...
                ...% 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', ...
                'Color', [1, 1, 1] ... 
            };
            [dLeft, dBottom, dWidth, dHeight] = this.uiZoomPanAxes.getVisibleSceneLBWH();
                        
            % 12:00
            text( ...
                dLeft + dWidth/2, dBottom + 0.12 * dHeight, '06:00 (+CY) (-FY)', ...
                ceProps{:} ...
            ); 
        
            % 03:00
            text( ...
                dLeft + dWidth * 0.05, dBottom + dHeight * 0.5, '03:00 (+X)', ...
                ceProps{:}, ...
                'HorizontalAlignment', 'Left' ...
            );
        
            % 06:00
            text( ...
                dLeft + dWidth/2, dBottom + dHeight - 0.05 * dHeight, '12:00 (-CY) (+FY)', ...
                ceProps{:} ...
            );
        
            % 09:00
            text( ...
                dLeft + dWidth * 0.97, dBottom + dHeight * 0.5, '09:00 (-X)', ...
                ceProps{:}, ...
                'HorizontalAlignment', 'Right' ...
            );
            
            
        end
        
        function deleteChildren(this, h)
            
            % This is a utility to delete all children of an axes, hggroup,
            % or hgtransform instance
            
            if ~ishandle(h)
                return
            end
            
            hChildren = get(h, 'Children');
            for k = 1:length(hChildren)
                if ishandle(hChildren(k))
                    delete(hChildren(k));
                end
            end
        end
        
        
        function drawCrosshairChiefRay(this)
            
            % Vertical Line
            
                       
            dL = -this.dThicknessOfCrosshair/2 + this.dXChiefRay;
            dR = this.dThicknessOfCrosshair/2 + this.dXChiefRay;
            dT = this.dSizeCrosshairChiefRay/2 + this.dYChiefRay;
            dB = -this.dSizeCrosshairChiefRay/2 + this.dYChiefRay;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairChiefRay, ...
                'Parent', this.hCrosshairChiefRay, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairChiefRay ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairChiefRay/2 + this.dXChiefRay;
            dR = this.dSizeCrosshairChiefRay/2 + this.dXChiefRay;
            dT = this.dThicknessOfCrosshair/2 + this.dYChiefRay;
            dB = -this.dThicknessOfCrosshair/2 + this.dYChiefRay;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairChiefRay, ...
                'Parent', this.hCrosshairChiefRay, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairChiefRay ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXChiefRay + dShiftX, this.dYChiefRay + dShiftY, 'EUV', ...
                'Parent', this.hCrosshairChiefRay, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorCrosshairChiefRay ... 
            ); 
        
            % uistack(hPatch, 'top');
            
            
            
        end
        
        
        function drawCrosshairCam1(this)
            
            % Vertical Line
            
                       
            dL = -this.dThicknessOfCrosshair/2 + this.dXCam1;
            dR = this.dThicknessOfCrosshair/2 + this.dXCam1;
            dT = this.dSizeCrosshairCam1/2 + this.dYCam1;
            dB = -this.dSizeCrosshairCam1/2 + this.dYCam1;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairCam1, ...
                'Parent', this.hCrosshairCam1, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairCam1 ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairCam1/2 + this.dXCam1;
            dR = this.dSizeCrosshairCam1/2 + this.dXCam1;
            dT = this.dThicknessOfCrosshair/2 + this.dYCam1;
            dB = -this.dThicknessOfCrosshair/2 + this.dYCam1;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairCam1, ...
                'Parent', this.hCrosshairCam1, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairCam1 ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXCam1 + dShiftX, this.dYCam1 + dShiftY, 'Cam 1', ...
                'Parent', this.hCrosshairCam1, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorCrosshairCam1 ... 
            ); 
        
            % uistack(hPatch, 'top');
            
            
            
        end
        
        
        function drawCrosshairCam2(this)
            
            % Vertical Line
            
                       
            dL = -this.dThicknessOfCrosshair/2 + this.dXCam2;
            dR = this.dThicknessOfCrosshair/2 + this.dXCam2;
            dT = this.dSizeCrosshairCam2/2 + this.dYCam2;
            dB = -this.dSizeCrosshairCam2/2 + this.dYCam2;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairCam2, ...
                'Parent', this.hCrosshairCam2, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairCam2 ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairCam2/2 + this.dXCam2;
            dR = this.dSizeCrosshairCam2/2 + this.dXCam2;
            dT = this.dThicknessOfCrosshair/2 + this.dYCam2;
            dB = -this.dThicknessOfCrosshair/2 + this.dYCam2;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairCam2, ...
                'Parent', this.hCrosshairCam2, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairCam2 ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXCam2 + dShiftX, this.dYCam2 + dShiftY, 'Cam 2', ...
                'Parent', this.hCrosshairCam2, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorCrosshairCam2 ... 
            ); 
        
            % uistack(hPatch, 'top');
            
            
            
        end
        
        
        function drawCrosshairCap1(this)
            
            % Vertical Line
            
                       
            dL = -this.dThicknessOfCrosshair/2 + this.dXCap1;
            dR = this.dThicknessOfCrosshair/2 + this.dXCap1;
            dT = this.dSizeCrosshairCap1/2 + this.dYCap1;
            dB = -this.dSizeCrosshairCap1/2 + this.dYCap1;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairCap1, ...
                'Parent', this.hCrosshairCap1, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairCap1 ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairCap1/2 + this.dXCap1;
            dR = this.dSizeCrosshairCap1/2 + this.dXCap1;
            dT = this.dThicknessOfCrosshair/2 + this.dYCap1;
            dB = -this.dThicknessOfCrosshair/2 + this.dYCap1;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairCap1, ...
                'Parent', this.hCrosshairCap1, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairCap1 ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXCap1 + dShiftX, this.dYCap1 + dShiftY, 'Cap 1', ...
                'Parent', this.hCrosshairCap1, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorCrosshairCap1 ... 
            ); 
        
            % uistack(hPatch, 'top');
            
            
            
        end
        
        
        function drawCrosshairCap2(this)
            
            % Vertical Line
            
                       
            dL = -this.dThicknessOfCrosshair/2 + this.dXCap2;
            dR = this.dThicknessOfCrosshair/2 + this.dXCap2;
            dT = this.dSizeCrosshairCap2/2 + this.dYCap2;
            dB = -this.dSizeCrosshairCap2/2 + this.dYCap2;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairCap2, ...
                'Parent', this.hCrosshairCap2, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairCap2 ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairCap2/2 + this.dXCap2;
            dR = this.dSizeCrosshairCap2/2 + this.dXCap2;
            dT = this.dThicknessOfCrosshair/2 + this.dYCap2;
            dB = -this.dThicknessOfCrosshair/2 + this.dYCap2;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairCap2, ...
                'Parent', this.hCrosshairCap2, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairCap2 ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXCap2 + dShiftX, this.dYCap2 + dShiftY, 'Cap 2', ...
                'Parent', this.hCrosshairCap2, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorCrosshairCap2 ... 
            ); 
        
            % uistack(hPatch, 'top');
            
            
            
        end
        
        
        function drawCrosshairCap3(this)
            
            % Vertical Line
            
                       
            dL = -this.dThicknessOfCrosshair/2 + this.dXCap3;
            dR = this.dThicknessOfCrosshair/2 + this.dXCap3;
            dT = this.dSizeCrosshairCap3/2 + this.dYCap3;
            dB = -this.dSizeCrosshairCap3/2 + this.dYCap3;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairCap3, ...
                'Parent', this.hCrosshairCap3, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairCap3 ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairCap3/2 + this.dXCap3;
            dR = this.dSizeCrosshairCap3/2 + this.dXCap3;
            dT = this.dThicknessOfCrosshair/2 + this.dYCap3;
            dB = -this.dThicknessOfCrosshair/2 + this.dYCap3;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairCap3, ...
                'Parent', this.hCrosshairCap3, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairCap3 ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXCap3 + dShiftX, this.dYCap3 + dShiftY, 'Cap 3', ...
                'Parent', this.hCrosshairCap3, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorCrosshairCap3 ... 
            ); 
        
            % uistack(hPatch, 'top');
            
            
            
        end
        
        
        function drawCrosshairCap4(this)
            
            % Vertical Line
            
                       
            dL = -this.dThicknessOfCrosshair/2 + this.dXCap4;
            dR = this.dThicknessOfCrosshair/2 + this.dXCap4;
            dT = this.dSizeCrosshairCap4/2 + this.dYCap4;
            dB = -this.dSizeCrosshairCap4/2 + this.dYCap4;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairCap4, ...
                'Parent', this.hCrosshairCap4, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairCap4 ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairCap4/2 + this.dXCap4;
            dR = this.dSizeCrosshairCap4/2 + this.dXCap4;
            dT = this.dThicknessOfCrosshair/2 + this.dYCap4;
            dB = -this.dThicknessOfCrosshair/2 + this.dYCap4;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairCap4, ...
                'Parent', this.hCrosshairCap4, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairCap4 ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXCap4 + dShiftX, this.dYCap4 + dShiftY, 'Cap 4', ...
                'Parent', this.hCrosshairCap4, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorCrosshairCap4 ... 
            ); 
        
            % uistack(hPatch, 'top');
            
            
            
        end
        
        
        function drawCrosshairZero(this)
            
            % Vertical Line
            
            dL = -this.dThicknessOfCrosshair/2 + this.dXZero;
            dR = this.dThicknessOfCrosshair/2 + this.dXZero;
            dT = this.dSizeCrosshairChiefRay/2 + this.dYZero;
            dB = -this.dSizeCrosshairChiefRay/2 + this.dYZero;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairZero, ...
                'Parent', this.hCrosshairZero, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairZero ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairChiefRay/2 + this.dXZero;
            dR = this.dSizeCrosshairChiefRay/2 + this.dXZero;
            dT = this.dThicknessOfCrosshair/2 + this.dYZero;
            dB = -this.dThicknessOfCrosshair/2 + this.dYZero;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairZero, ...
                'Parent', this.hCrosshairZero, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairZero ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXZero + dShiftX, this.dYZero + dShiftY, 'Stage (0, 0)', ...
                'Parent', this.hCrosshairZero, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorCrosshairZero ... 
            ); 
        
            % uistack(hPatch, 'top');
                        
        end 
        
        
        
        function drawCrosshairLoadLock(this)
            
            % Vertical Line

                       
            dL = -this.dThicknessOfCrosshair/2 + this.dXLoadLock;
            dR = this.dThicknessOfCrosshair/2 + this.dXLoadLock;
            dT = this.dSizeCrosshairChiefRay/2 + this.dYLoadLock;
            dB = -this.dSizeCrosshairChiefRay/2 + this.dYLoadLock;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairLoadLock, ...
                'Parent', this.hCrosshairLoadLock, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairLoadLock ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairChiefRay/2 + this.dXLoadLock;
            dR = this.dSizeCrosshairChiefRay/2 + this.dXLoadLock;
            dT = this.dThicknessOfCrosshair/2 + this.dYLoadLock;
            dB = -this.dThicknessOfCrosshair/2 + this.dYLoadLock;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairLoadLock, ...
                'Parent', this.hCrosshairLoadLock, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairLoadLock ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXLoadLock + dShiftX, this.dYLoadLock + dShiftY, 'LL', ...
                'Parent', this.hCrosshairLoadLock, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', [1, 1, 1] ... 
            ); 
        
            % uistack(hPatch, 'top');
                        
        end
        
        function drawCrosshairDiode(this)
            
            % Vertical Line
            
            dL = -this.dThicknessOfCrosshair/2 + this.dXDiode;
            dR = this.dThicknessOfCrosshair/2 + this.dXDiode;
            dT = this.dSizeCrosshairDiode/2 + this.dYDiode;
            dB = -this.dSizeCrosshairDiode/2 + this.dYDiode;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairDiode, ...
                'Parent', this.hCrosshairDiode, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairDiode ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairDiode/2 + this.dXDiode;
            dR = this.dSizeCrosshairDiode/2 + this.dXDiode;
            dT = this.dThicknessOfCrosshair/2 + this.dYDiode;
            dB = -this.dThicknessOfCrosshair/2 + this.dYDiode;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairDiode, ...
                'Parent', this.hCrosshairDiode, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairDiode ...
            );
        
            % Face of diode
            dWidthDiode = 2.3e-3; %m
            dHeightDiode = 2.3e-3;
            
            dL = this.dXDiode - dWidthDiode / 2;
            dR = this.dXDiode + dWidthDiode / 2;
            dT = this.dYDiode + dHeightDiode / 2;
            dB = this.dYDiode - dHeightDiode / 2;
            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairDiode, ...
                'Parent', this.hCrosshairDiode, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', 0.5 ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXDiode + dShiftX, this.dYDiode + dShiftY, 'Diode', ...
                'Parent', this.hCrosshairDiode, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorCrosshairDiode ... 
            ); 
        
            % uistack(hPatch, 'top');
                        
        end 
        
        
        function drawCrosshairYag(this)
            
            % Vertical Line
            
            dL = -this.dThicknessOfCrosshair/2 + this.dXYag;
            dR = this.dThicknessOfCrosshair/2 + this.dXYag;
            dT = this.dSizeCrosshairYag/2 + this.dYYag;
            dB = -this.dSizeCrosshairYag/2 + this.dYYag;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairYag, ...
                'Parent', this.hCrosshairYag, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairYag ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairYag/2 + this.dXYag;
            dR = this.dSizeCrosshairYag/2 + this.dXYag;
            dT = this.dThicknessOfCrosshair/2 + this.dYYag;
            dB = -this.dThicknessOfCrosshair/2 + this.dYYag;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairYag, ...
                'Parent', this.hCrosshairYag, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairYag ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXYag + dShiftX, this.dYYag + dShiftY, 'Yag', ...
                'Parent', this.hCrosshairYag, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorCrosshairYag ... 
            ); 
        
            % uistack(hPatch, 'top');
                        
        end 
        
        
        function deleteCrosshairCam1(this)
            this.deleteChildren(this.hCrosshairCam1)
        end
        
        function deleteCrosshairCam2(this)
            this.deleteChildren(this.hCrosshairCam2)
        end
        
        function deleteCrosshairCap1(this)
            this.deleteChildren(this.hCrosshairCap1)
        end
        
        function deleteCrosshairCap2(this)
            this.deleteChildren(this.hCrosshairCap2)
        end
        
        function deleteCrosshairCap3(this)
            this.deleteChildren(this.hCrosshairCap3)
        end
        
        function deleteCrosshairCap4(this)
            this.deleteChildren(this.hCrosshairCap4)
        end
        
        function deleteCrosshairChiefRay(this)
            this.deleteChildren(this.hCrosshairChiefRay)
        end
        
        function deleteCrosshairZero(this)
            this.deleteChildren(this.hCrosshairZero)
        end
        
        function deleteCrosshairLoadLock(this)
            this.deleteChildren(this.hCrosshairLoadLock)
        end
        
        function deleteCrosshairDiode(this)
            this.deleteChildren(this.hCrosshairDiode)
        end
        
        function deleteCrosshairYag(this)
            this.deleteChildren(this.hCrosshairYag)
        end
        
        function [dX, dY] = getShiftOfCrosshairLabel(this)
            
            dZoom = this.uiZoomPanAxes.getZoom();
            dX = .005/dZoom;
            dY = -0.015/dZoom;
        end
        
        
        function d = getThicknessOfCrosshair(this)
        
            dZoomUi = this.uiZoomPanAxes.getZoom();
            
            % Start with a thickness and a zoom transition level.  The idea
            % is if you double the zoom, halve the thickness.  Keep doing
            % this until you get to this.dZoomMax
            
            dThickStart = 5e-3;
            dZoomStart = 1.25;
            
            % Compute number of zoom levels.  If dZoomStart is 1.5, they
            % look like this:
            % 1.5, 3, 6, 12, 24, 48, ...
            % Use this equation:
            % dZoomStart * 2^(n - 1) = this.dZoomMax
            
            dLevels = ceil(log10(this.dZoomMax / dZoomStart) / log10(2) + 1);
            dLevel = 1 : dLevels;
            dZoom = dZoomStart * 2.^(dLevel - 1);
            dThick = dThickStart ./ 2.^(dLevel - 1);
            
            for n = 1 : length(dZoom)
                if dZoomUi < dZoom(n)
                    d = dThick(n);
                    return;
                end
            end
            
            d = dThick(end);
        end
        

    end % private
    
    
end