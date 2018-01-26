classdef WaferAxes < mic.Base
        
    properties (Constant)
       
        
        
    end
    
	properties
        
       
    end
    
    properties (SetAccess = private)
        
        
        % {double 1x1} width of the mic.ui.axes.ZoomPanAxes in pixels
        dWidth = 600
        
        % {double 1x1} height of the mic.ui.axes.ZoomPanAxes in pixels
        dHeight = 600
        
        
    end
    
    properties (Access = private)
        
        % {double 1x1} number that has to do with HSV color transparency
        dMinV = 0.5      
        
        % {double 1x1} width of an exposure in meters
        dFieldWidth = 200e-6
        
        % {double 1x1} height of an exposure in meters
        dFieldHeight = 30e-6
        
        % {double 1x1} height of crosshair at center of wafer
        dSizeWaferCrosshair = 100e-3;
        dSizeChiefRayCrosshair = 20e-3;
        
        % {double 1x1} thickness of crosshair at center of wafer
        dThickCrosshair
                
        dAlphaWaferCrosshair = 1;
        dColorWaferCrosshair = [0 1 0];
        
        dAlphaChiefRayCrosshair = 1;
        dColorChiefRayCrosshair = [1 0 1];
            
        dZoomMax = 500;
        
        % {logical 1x1} true when exposing.  Adds pink overlay over
        % everything
        lExposing = false
        
        uiZoomPanAxes
        hTrack
        hCarriage
        hCarriageLsi
        hIllum
        hChiefRayCrosshair
        hWafer
        hWaferCrosshair
        hFemPreviewPrescription
        hFemPreviewScan
        hExposures
        hOverlay
        
        dFieldX
        dFieldY
        
        dXFemPreview            % size: [focus x dose] of X positions
        dYFemPreview            % size: [focus x dose] of Y positions
                                % these values are updated whenever the FEM
                                % grid changes
                                
        % {double focus x dose} x positions
        dXFemPreviewScan
        % {double focus x dose} y positions 
        dYFemPreviewScan 
        
        
        % Store exposure data in a cell.  Each item of the cell is an array that 
        % contains:
        %
        %   dX
        %   dY
        %   dDoseNum        the dose shot num
        %   dFEMDoseNum
        %   dFocusNum       the focus shot num
        %   dFEMFocusNum
        %
        % The dose/focus data is used for color/hue 
        % As each exposure finishes, an array is pushed to to this cell
        
        ceExposure  
        
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = WaferAxes(varargin)
            
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
                        
            this.uiZoomPanAxes.build(hParent, dLeft, dTop);
            
            this.dThickCrosshair = this.getThickCrosshair();
            
            % Build heirarchy of hggroups/hgtransforms for drawing
            
            %{
            this.hTrack         = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.hCarriage      = hgtransform('Parent', this.uiZoomPanAxes.hHggroup);
            this.hWafer         = hggroup('Parent', this.hCarriage);
            this.hFemPreview    = hggroup('Parent', this.hWafer);
            this.hFEM           = hggroup('Parent', this.hWafer);
            this.hIllum         = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            
            this.drawTrack(); 
            this.drawCarriage();
            this.drawWafer(); 
            this.drawIllum(); 
            this.drawFEM(); 
            this.drawFemPreview(); 
            %}
            
            % For some reason when I build the hg* instances as shown above
            % and then add content to them, the stacking order is messed up
            % (the wafer is not on top of the carriage) but when I do it
            % this way it works. 
            
           
            this.hTrack         = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawTrack(); 
            
            this.hCarriage      = hgtransform('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawCarriage(); 
            
            this.hCarriageLsi = hgtransform('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawCarriageLsi();
            
            this.hWafer         = hggroup('Parent', this.hCarriage);
            this.drawWafer();
            
            this.hWaferCrosshair = hggroup('Parent', this.hWafer);
            this.drawWaferCrosshair();

            this.hFemPreviewPrescription    = hggroup('Parent', this.hWafer);
            this.hFemPreviewScan    = hggroup('Parent', this.hWafer);
            
            this.hExposures     = hggroup('Parent', this.hWafer);
            this.drawExposures();
            
            this.hIllum         = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawIllum();
            
            this.hChiefRayCrosshair = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            this.drawChiefRayCrosshair();
            
            this.hOverlay       = hggroup('Parent', this.uiZoomPanAxes.hHggroup);
            
            
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            
            
        end
        
        % The FEM preview is not drawn as a single rectangle like it is in
        % MET software.  It is a grid of exposure sites.  You don't pass
        % in information to draw one rectangle, you pass in the x, y
        % meshgrid of the (, y) position on the wafer at every exposure site
        % @param {double focus x dose} dX - x position of
        % every exposure, e.g.:
        %  [-1.1  -0.8   -0.5
        %   -1.1  -0.8   -0.5
        %   -1.1  -0.8   -0.5] * 1e-3
        % @param {double focus x dose} dY - y position of
        % every exposure, e.g.:
        %  [2.2   2.2   2.2
        %   2.1   2.1   2.1
        %   2.0   2.0   2.0] * 1e-3
        % See addFakeFemPreview()
        
        function addFemPreviewPrescription(this, dX, dY)
           this.drawFemPreview(dX, dY, 'prescription')
        end 
        
        function addFemPreviewScan(this, dX, dY)
           this.drawFemPreview(dX, dY, 'scan')
        end 
                
        % Draw an exposure on the wafer.  It is understood that the
        % exposure is part of a FEM.  Information about the FEM the
        % exposure is part of must be passed in so the colors can be drawn
        % correctly.  May need to edit this at some point to take
        % experimental data of exposure time and stage z of each exposure.
        % @param {double 1x6} dData
        % @param {double 1x1} dData[1] x position of the exposure on the
        % wafer.  OR is it the x position of the stage when the exposure
        % occurs?
        % @param {double 1x1} dData[2] y position of the stage when the
        %   exposure occurs
        % @param {double 1x1} dData[3] dose shot num (used with dData[4]
        %   to calculate the saturation of the fill color 
        % @param {double 1x1} dData[4] FEM dose size
        % @param {double 1x1} dData[5] focus shot num (used with dData[6]
        %   to calculate the hue of the fill color 
        % @param {double 1x1} dData[6] FEM focus size
        function addExposure(this, dData)
            
            this.ceExposure{length(this.ceExposure) + 1} = dData;
            this.drawExposure(dData);
                        
        end
        
        function deleteWaferCrosshair(this)
            this.deleteChildren(this.hWaferCrosshair)
        end
        
        function deleteChiefRayCrosshair(this)
            this.deleteChildren(this.hChiefRayCrosshair)
        end
        
        function purgeExposures(this)
            
            this.ceExposure = {};
            this.deleteChildren(this.hExposures);                
            
        end
        
        function purgeOverlay(this)
            
            this.deleteChildren(this.hOverlay);                
            
        end
        
        function setXLsi(this, dX)
            
            if isnan(dX)
                this.msg('setXLsi() dX === NaN', this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            
            try
                hHgtf = makehgtform('translate', [dX 0 0]);
                if ishandle(this.hCarriageLsi)
                    set(this.hCarriageLsi, 'Matrix', hHgtf);
                end
            catch mE
                this.msg(getReport(mE));
            end
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
                if ishandle(this.hCarriage)
                    set(this.hCarriage, 'Matrix', hHgtf);
                end
            catch mE
                this.msg(getReport(mE));
            end
                
            
        end
        
        function addFakeFemPreview(this)
        
            dX          = 0.5e-3; % Dose
            dY          = -0.1e-3; % Focus
            dX0         = .3e-3;
            dY0         = -.3e-3;
            dDoseNum    = 11;
            dFocusNum   = 9;
            
            x = dX0 : dX : dX0 + (dDoseNum - 1) * dX;
            y = dY0 : dY : dY0 + (dFocusNum - 1) * dY;
            
            [xx, yy] = meshgrid(x, y);
            
            this.addFemPreviewPrescription(xx, yy);
            
        end
        
        function addFakeExposures(this)
            
            % For testing
            
            dX          = 0.4e-3;
            dY          = -0.1e-3;
            dX0         = 0e-3;
            dY0         = 1e-3;
            dDoseNum    = 11;
            dFocusNum   = 9;
            
            for focus = 1:dFocusNum
                for dose = 1:dDoseNum
                    this.addExposure([...
                        dX0 + (dose - 1)*dX, ...
                        dY0 + (focus - 1)*dY, ...
                        dose, ...
                        dDoseNum, ...
                        focus, ...
                        dFocusNum ...
                    ]);
                end
            end
        end
        
        
        function setExposing(this, lVal)
            
            this.lExposing = lVal;
            
            if this.lExposing
                this.drawOverlay();
            else
                this.purgeOverlay();
            end
                            
        end
        
        
        function deleteFemPreviewPrescription(this)
            
            if ishandle(this.hFemPreviewPrescription)
                this.deleteChildren(this.hFemPreviewPrescription);
            else
                return;
            end 
            
        end
        
        function deleteFemPreviewScan(this)
            
            if ishandle(this.hFemPreviewScan)
                this.deleteChildren(this.hFemPreviewScan);
            else
                return;
            end 
            
        end
        
            

    end
    
    methods (Access = private)
        
        
        function init(this)
            this.msg('init()');
            this.uiZoomPanAxes = mic.ui.axes.ZoomPanAxes(-1, 1, -1, 1, this.dWidth, this.dHeight, this.dZoomMax);
            addlistener(this.uiZoomPanAxes, 'eZoom', @this.onZoom);
        end
        
        function onZoom(this, ~, ~)
            
            dThick = this.getThickCrosshair();
            if dThick ~= this.dThickCrosshair
                this.dThickCrosshair = dThick;
                this.deleteWaferCrosshair();
                this.deleteChiefRayCrosshair();
                this.drawWaferCrosshair();
                this.drawChiefRayCrosshair();
            end
            
            cMsg = sprintf('zoom = %1.2e', this.uiZoomPanAxes.getZoom());
            this.msg(cMsg);
            
        end
        function drawTrack(this)
            
           
           % (L)eft (R)ight (T)op (B)ottom
           
           % Base is 1500 x 500 perfectly centered
           
           dL = -750e-3;
           dR = 750e-3;
           dT = 250e-3;
           dB = -250e-3;
           
           patch( ...
               [dL dL dR dR], ...
               [dB dT dT dB], ...
               [0.5, 0.5, 0.5], ...
               'Parent', this.hTrack, ...
               'EdgeColor', 'none');
           
           % Track
           
           dL = -1450e-3/2;
           dR = 1450e-3/2;
           dT = 200e-3;
           dB = -200e-3;
           
           patch( ...
               [dL dL dR dR], ...
               [dB dT dT dB], ...
               [0.6, 0.6, 0.6], ...
               'Parent', this.hTrack, ...
               'EdgeColor', 'none');
            
        end
        
        function drawIllum(this)
            
            dL = -this.dFieldWidth/2;
            dR = this.dFieldWidth/2;
            dT = this.dFieldHeight/2;
            dB = -this.dFieldHeight/2;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                hsv2rgb(0.9, 1, 1), ...
                'Parent', this.hIllum, ...
                'FaceAlpha', 0.5, ...
                'LineWidth', 1, ...
                'EdgeColor', [1, 1, 1] ...
            );
        
            uistack(hPatch, 'top');
        end
        
        function drawCarriageLsi(this)
            
            dOffset = 500e-3;
            dL = -200e-3 + dOffset;
            dR = 200e-3 + dOffset;
            dT = 200e-3;
            dB = -200e-3;

            
            % Base square
            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                [0.4, 0.4, 0.4], ...
                'Parent', this.hCarriageLsi, ...
                'EdgeColor', 'none');
            
        end
        
        function drawCarriage(this)
            

            dL = -200e-3;
            dR = 200e-3;
            dT = 200e-3;
            dB = -200e-3;

            
            % Base square
            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                [0.4, 0.4, 0.4], ...
                'Parent', this.hCarriage, ...
                'EdgeColor', 'none');
            

            % Circular part without the triangle-ish thing
                       
            dTheta = linspace(0, 2*pi, 100);
            dR = 175e-3;
          
            patch( ...
                dR*sin(dTheta), ...
                dR*cos(dTheta), ...
                [0.5, 0.5, 0.5], ...
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
                'Parent', this.hCarriage, ...
                'EdgeColor', 'none');
                        
        end
        
        function drawWaferCrosshair(this)
            
            % Vertical Line
                       
            dL = -this.dThickCrosshair/2;
            dR = this.dThickCrosshair/2;
            dT = this.dSizeWaferCrosshair/2;
            dB = -this.dSizeWaferCrosshair/2;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorWaferCrosshair, ...
                'Parent', this.hWaferCrosshair, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaWaferCrosshair ...
            );
        
            uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeWaferCrosshair/2;
            dR = this.dSizeWaferCrosshair/2;
            dT = this.dThickCrosshair/2;
            dB = -this.dThickCrosshair/2;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorWaferCrosshair, ...
                'Parent', this.hWaferCrosshair, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaWaferCrosshair ...
            );
        
            uistack(hPatch, 'top');
            
            
            
        end 
        
        
        function drawChiefRayCrosshair(this)
            
            % Vertical Line
                       
            dL = -this.dThickCrosshair/2;
            dR = this.dThickCrosshair/2;
            dT = this.dSizeChiefRayCrosshair/2;
            dB = -this.dSizeChiefRayCrosshair/2;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorChiefRayCrosshair, ...
                'Parent', this.hChiefRayCrosshair, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaChiefRayCrosshair ...
            );
        
            uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeChiefRayCrosshair/2;
            dR = this.dSizeChiefRayCrosshair/2;
            dT = this.dThickCrosshair/2;
            dB = -this.dThickCrosshair/2;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorChiefRayCrosshair, ...
                'Parent', this.hChiefRayCrosshair, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaChiefRayCrosshair ...
            );
        
            uistack(hPatch, 'top');
            
            
            
        end 
            
        
        function drawWafer(this)
            
            dDTheta = 1/360;            
            dTheta = [0/180:dDTheta:70/180,...
                110/180:dDTheta:170/180,...
                190/180:dDTheta:360/180]*pi;
            
            
            dR = 150e-3;
            dTheta = dTheta - 90*pi/180;
            
            hPatch = patch( ...
                dR*sin(dTheta), ...
                dR*cos(dTheta), ...
                [0, 0, 0], ...
                'Parent', this.hWafer, ...
                'EdgeColor', 'none');
            
            uistack(hPatch, 'top');
                        
        end
        

        
        function drawFemPreview(this, dX, dY, cType)
            
            if ~ishandle(this.hFemPreviewPrescription)
                return;
            end
            
            switch cType
                case 'prescription'
                    dColor = [1 1 1];
                    dAlpha = 0.5;
                    hParent = this.hFemPreviewPrescription;
                case 'scan'
                    dColor = [1 0 1];
                    dAlpha = 0.5;
                    hParent = this.hFemPreviewScan;
            end
                        
            [dFocusNum, dDoseNum] = size(dX);
                        
            for row = 1:dFocusNum
                for col = 1:dDoseNum
                
                    dL = dX(row, col) - this.dFieldWidth/2;
                    dR = dX(row, col) + this.dFieldWidth/2;
                    dT = dY(row, col) + this.dFieldHeight/2;
                    dB = dY(row, col) - this.dFieldHeight/2;

                    patch( ...
                        [dL dL dR dR], ...
                        [dB dT dT dB], ...
                        dColor, ...
                        'Parent', hParent, ...
                        'FaceAlpha', dAlpha, ...
                        'EdgeColor', 'none' ...
                    );
                    % 'LineWidth', 2, ...

                end
            end
        end
        
        function drawExposures(this)
                        
            for k = 1:length(this.ceExposure)
                this.drawExposure(this.ceExposure{k});
            end
            
        end
        
        function drawExposure(this, dData)
            
            
            if isempty(this.hExposures) || ...
                ~ishandle(this.hExposures)
                return
            end
            
            % (H)ue is focus
            % (V)alue is dose
            
            dH = (dData(5) - 1)/dData(6); 
            dV = this.dMinV + (1 - this.dMinV)*dData(3)/dData(4);

            dL = dData(1) - this.dFieldWidth/2;
            dR = dData(1) + this.dFieldWidth/2;
            dT = dData(2) + this.dFieldHeight/2;
            dB = dData(2) - this.dFieldHeight/2;

            patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                hsv2rgb([dH, 1, dV]), ...
                'Parent', this.hExposures, ...
                'EdgeColor', 'none' ...
            );
        end
        
        
        function drawOverlay(this)
            
            this.msg('drawOverlay');
            
            
            if isempty(this.hOverlay) || ...
                ~ishandle(this.hOverlay)
                return
            end
            
            dL = -1;
            dR = 1;
            dT = 1;
            dB = -1;
            
            patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                hsv2rgb(0.9, 1, 1), ...
                'Parent', this.hOverlay, ...
                'FaceAlpha', 0.5, ...
                'LineWidth', 1, ...
                'EdgeColor', [1, 1, 1] ...
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
        
        
        function d = getThickCrosshair(this)
        
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