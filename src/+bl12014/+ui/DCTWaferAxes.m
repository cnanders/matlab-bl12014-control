classdef DCTWaferAxes < mic.Base
        
    properties (Constant)
       
        
        
    end
    
	properties
        
        
       
    end
    
    properties (SetAccess = private)
        
        
        % {double 1x1} width of the mic.ui.axes.ZoomPanAxes in pixels
        dWidth = 600
        
        % {double 1x1} height of the mic.ui.axes.ZoomPanAxes in pixels
        dHeight = 600
        
        dXChiefRay = 0e-3 % m think of this as the stage position when EUV hits center of wafer
        dYChiefRay = 0e-3 % m
        
        cName = 'dct-axes'
        
        
    end
    
    properties (Access = private)
        
        % {double 1x1} number that has to do with HSV color transparency
        dMinV = 0.01      
        
        % {double 1x1} width of an exposure in meters
        dWidthField = 200e-6
        
        % {double 1x1} height of an exposure in meters
        dHeightField = 30e-6
        
        % {double 1x1} height of crosshair at center of wafer
        dSizeCrosshairWafer = 100e-3;
        
        % {double 1x1} size in mm of crosshair of chief ray (stays fixed)
        dSizeCrosshairChiefRay = 20e-3;
        
        dSizeCrosshairDiode = 10e-3;
        
        dWidthDiode = 22.05e-3
        dHeightDiode = 15.85e-3
        
        dDiameterYag = 25.4e-3
        dSizeCrosshairYag = 10e-3;
        
        % {double 1x1} thickness of crosshair at center of wafer
        dThicknessOfCrosshair
                
        dAlphaCrosshairWafer = 1;
        dColorCrosshairWafer = [0 1 0];
        
        dAlphaCrosshairChiefRay = 1;
        dColorCrosshairChiefRay = [1 0 1];
        
        dAlphaCrosshairZero = 1;
        dColorCrosshairZero = [1 1 0];
        
        dAlphaCrosshairLoadLock = 1;
        dColorCrosshairLoadLock = [1 1 0];
        
        dColorCrosshairDiode = [1 1 0];
        dAlphaCrosshairDiode = 1;
        
        
        dColorCrosshairDiode2 = [1 1 0];
        dAlphaCrosshairDiode2 = 0.2;
        
        
        dColorDiode = [1 1 0]
        dAlphaDiode = 0.5
        
        dColorDiode2 = [1 1 0]
        dAlphaDiode2 = 0.2;
        
        dAlphaCrosshairYag = 1;
        dColorCrosshairYag = [1 1 0];
        dColorYag = [178	215	92] / 255;
        dAlphaYag = 0.5
        
        
        % Positions of things relative to the the chief ray?
        dXZero = 0
        dYZero = 0
        
        dXDiode = 130e-3
        dYDiode = 0e-3
        
        dXDiode2 = 5e-3
        dYDiode2 = -5e-3
        
        dXYag = 130e-3
        dYYag = -30e-3
        
        dXLoadLock = -0.45
        dYLoadLock = 0
        
        dZoomMax = 700;
        
        % {logical 1x1} true when exposing.  Adds pink overlay over
        % everything
        lExposing = false
        
        uiZoomPanAxes
        
        hTransformedGroup % a global transformation that can be applied to the ZoomPanAxes before adding anything
        hTrack
        hClockTimes
        hCarriage
        hIllum
        hAperture
                
        hCrosshairChiefRay
        hCrosshairZero
        hCrosshairDiode
        hCrosshairDiode2
        hCrosshairYag
        hCrosshairLoadLock
        hCrosshairWafer

        hYag
        hDiode
        hDiode2
        hWafer
        hExposuresPre
        hExposuresScan
        hExposures
        hOverlay
        
        clock
        
        % @returns {double 1x1} x position of the stage in meters
        fhGetXOfWafer = @() -0.05
        % @returns {double 1x1} y position of the stage in meters
        fhGetYOfWafer = @() 0.02
        % @returns {double 1x1} x, y position of the aperture stage in meters
        fhGetXOfAperture = @() 10e-3
        fhGetYOfAperture = @() -20e-3
        % @returns {logical 1x1} true if shutter is open
        fhGetIsShutterOpen = @()false
        
        % {bl12014.DCTExposures
        exposures
        
        dDelay = 0.5
        
        lIsExposing
        
        % Storage so only redraw when have to
        
        ceExposuresPre = {}
        ceExposuresScan = {}
        ceExposures = {}
        
        dHueExposurePre = 0.9; % has low saturation so gray
        dHueExposureScan = 0.3; % yellow
        dHueExposure = 0.8; % magenta
        
        dHue
        
        hardware
        
        uiStageAperture
        uiStageWafer
        uiShutter
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = DCTWaferAxes(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end

            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
            
        end
        
        function cec = getPropsDelete(this)
            cec = {
                'uiShutter', ...
                'uiStageWafer', ...
                'uiStageAperture' ...
            };
        end
          
        function delete(this)
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_INIT_DELETE);  

            this.clock.remove(this.id());
            cecProps = this.getPropsDelete();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                cMsg = sprintf('delete() deleting %s', cProp);
                this.msg(cMsg, this.u8_MSG_TYPE_CLASS_INIT_DELETE); 
                this.(cProp).delete();
            end
            
        end
        
        function build(this, hParent, dLeft, dTop)
                        
            this.uiZoomPanAxes.build(hParent, dLeft, dTop);
            this.dThicknessOfCrosshair = this.getThicknessOfCrosshair();
            
            % Allows global transformations to everything.
            % Allows you do draw it with one frame of reference and let you
            % view it in another frame of reference
            this.hTransformedGroup = hgtransform('Parent', this.uiZoomPanAxes.hHggroup);  
            
                
            % For some reason when I build the hg* instances as shown above
            % and then add content to them, the stacking order is messed up
            % (the wafer is not on top of the carriage) but when I do it
            % this way it works. 
            
            this.hTrack = hggroup('Parent', this.hTransformedGroup); 
            this.drawTrack(); 
            this.hCarriage = hgtransform('Parent', this.hTransformedGroup);      
            this.drawCarriage();   
            
            
           
            
            
            this.hAperture = hgtransform('Parent', this.hTransformedGroup);  
            this.drawAperture();
            
            this.hWafer = hggroup('Parent', this.hCarriage);  
            this.drawWafer();

                     
            this.hCrosshairDiode = hggroup('Parent', this.hCarriage);   
            this.drawCrosshairDiode();
            
            this.hCrosshairDiode2 = hggroup('Parent', this.hCarriage);   
            this.drawCrosshairDiode2();
            
            this.hDiode = hggroup('Parent', this.hCarriage);
            this.drawDiode();
            
            this.hDiode2 = hggroup('Parent', this.hCarriage);
            this.drawDiode2();
            
            this.hCrosshairYag = hggroup('Parent', this.hCarriage);
            
            this.hCrosshairWafer = hggroup('Parent', this.hWafer);
            this.hExposuresPre = hggroup('Parent', this.hWafer);
            this.hExposuresScan = hggroup('Parent', this.hWafer);
            this.hExposures = hggroup('Parent', this.hWafer);
            
            this.hIllum = hggroup('Parent', this.hTransformedGroup);
            this.drawIllum();
            
            
            this.hCrosshairChiefRay = hggroup('Parent', this.hTransformedGroup);
            this.hCrosshairZero = hggroup('Parent', this.hTransformedGroup);
            this.hCrosshairLoadLock = hggroup('Parent', this.hTransformedGroup);
            
            
            this.hOverlay = hggroup('Parent', this.hTransformedGroup);
            this.hClockTimes = hggroup('Parent', this.hTransformedGroup);
            
            
            
            % Rotate around z axis by 180
            %{
            dRotation = makehgtform('zrotate', pi);
            set(this.hTransformedGroup, 'Matrix', dRotation);
            %}
            
            
                       
            this.drawCrosshairYag();
            this.drawYag()

            
            this.drawCrosshairChiefRay();
            this.drawCrosshairZero();
            this.drawCrosshairLoadLock();
            this.drawClockTimes();
            
            this.drawCrosshairWafer();
            
            
            this.clock.add(@this.onClock, this.id(), this.dDelay);
            
        end

            

    end
    
    methods (Access = private)
        
        function onClock(this)
            this.setPositionOfWafer();
            this.setPositionOfAperture();
            this.drawExposures();
            this.drawExposuresPre();
            this.drawExposuresScan();
            this.setExposing();
        end 
                
        function deleteClockTimes(this)
            this.deleteChildren(this.hClockTimes)
        end
        
        function deleteCrosshairWafer(this)
            this.deleteChildren(this.hCrosshairWafer)
        end
        
        function deleteCrosshairChiefRay(this)
            this.deleteChildren(this.hCrosshairChiefRay)
        end
        
        function deleteCrosshairZero(this)
            this.deleteChildren(this.hCrosshairZero)
        end
        
        function deleteCrosshairDiode(this)
            this.deleteChildren(this.hCrosshairDiode)
        end
        
        function deleteCrosshairDiode2(this)
            this.deleteChildren(this.hCrosshairDiode2)
        end
        
        function deleteDiode(this)
            this.deleteChildren(this.hDiode)
        end
        
        function deleteDiode2(this)
            this.deleteChildren(this.hDiode2)
        end
        
        function deleteCrosshairYag(this)
            this.deleteChildren(this.hCrosshairYag)
        end
        
        function deleteYag(this)
            this.deleteChildren(this.hYag)
        end
        
        function deleteCrosshairLoadLock(this)
            this.deleteChildren(this.hCrosshairLoadLock)
        end
        
        function deleteExposures(this)
            this.deleteChildren(this.hExposures);                
        end
        
        function deleteOverlay(this)
            this.deleteChildren(this.hOverlay);                
        end
        
        
        function setPositionOfWafer(this)
            
            % Make sure the hggroup of the carriage is at the correct
            % location.
            
            dX = this.fhGetXOfWafer();
            dY = this.fhGetYOfWafer();
            
            if isnan(dX)
                this.msg('setPositionOfWafer() dX === NaN', this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            
            if isnan(dY)
                this.msg('setPositionOfWafer() dY === NaN', this.u8_MSG_TYPE_ERROR);
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
        
        function setPositionOfAperture(this)
            
            % Make sure the hggroup of the carriage is at the correct
            % location.
            
            dX = this.fhGetXOfAperture();
            dY = this.fhGetYOfAperture();
            
            if isnan(dX)
                this.msg('setPositionOfAperture() dX === NaN', this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            
            if isnan(dY)
                this.msg('setPositionOfAperture() dY === NaN', this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            try
            
                hHgtf = makehgtform('translate', [dX dY 0]);
                if ishandle(this.hAperture)
                    set(this.hAperture, 'Matrix', hHgtf);
                end
            catch mE
                this.msg(getReport(mE));
            end
            
        end
        
        function setExposing(this)
            
            lIsExposing = this.fhGetIsShutterOpen();
            
            if (this.lIsExposing == lIsExposing)
                return
            end
            
            this.lIsExposing = lIsExposing;
                
            if this.lIsExposing
                this.drawOverlay();
            else
                this.deleteOverlay();
            end
                            
        end
        
        function deleteExposuresPre(this)
            
            if ishandle(this.hExposuresPre)
                this.deleteChildren(this.hExposuresPre);
            else
                return;
            end 
            
        end
        
        function deleteExposuresScan(this)
            if ishandle(this.hExposuresScan)
                this.deleteChildren(this.hExposuresScan);
            else
                return;
            end 
            
        end
        
        function init(this)
            this.msg('init()');
            this.uiZoomPanAxes = mic.ui.axes.ZoomPanAxes(-1, 1, -1, 1, this.dWidth, this.dHeight, this.dZoomMax);
            
            this.uiShutter = bl12014.ui.Shutter(...
                'cName', [this.cName, 'shutter'], ...
                'hardware', this.hardware, ...
                'clock', this.clock ...
            );
        
            this.uiStageWafer = bl12014.ui.DCTWaferStage(...
                'cName', [this.cName, 'stage-wafer'], ...
                'hardware', this.hardware, ...
                'clock', this.clock ...
            );
        
            this.uiStageAperture = bl12014.ui.DCTApertureStage(...
                'cName', [this.cName, 'stage-aperture'], ...
                'hardware', this.hardware, ...
                'clock', this.clock ...
            );
        
            this.fhGetIsShutterOpen = @() this.uiShutter.uiOverride.get();
            this.fhGetXOfWafer = @() this.uiStageWafer.uiX.getValCal('mm') * 1e-3;
            this.fhGetYOfWafer = @() this.uiStageWafer.uiY.getValCal('mm') * 1e-3;
            this.fhGetXOfAperture = @() this.uiStageAperture.uiX.getValCal('mm') * 1e-3;
            this.fhGetYOfAperture = @() this.uiStageAperture.uiY.getValCal('mm') * 1e-3;
        
            addlistener(this.uiZoomPanAxes, 'eZoom', @this.onZoom);
            addlistener(this.uiZoomPanAxes, 'ePanX', @this.onPan);
            addlistener(this.uiZoomPanAxes, 'ePanY', @this.onPan);
        end
        
        function onZoom(this, ~, ~)
            
            % The thickness of crosshairs dynamically changes with zoom
            % so the crosshair takes up same angular FOV for observer on
            % computer screen at all zooms
            
            dThickness = this.getThicknessOfCrosshair();
            if dThickness ~= this.dThicknessOfCrosshair
                
                % Update for future
                this.dThicknessOfCrosshair = dThickness;
                
                % Redraw wafer crosshair
                this.deleteCrosshairWafer();
                this.drawCrosshairWafer();
                
                % Redraw chief ray crosshair
                this.deleteCrosshairChiefRay();
                this.drawCrosshairChiefRay();
                
                % Redraw zero crosshair
                this.deleteCrosshairZero();
                this.drawCrosshairZero();
                
                % Redraw diode crosshair
                this.deleteCrosshairDiode();
                this.drawCrosshairDiode();
                
                this.deleteDiode();
                this.drawDiode();
                
                
                this.deleteCrosshairDiode2();
                this.drawCrosshairDiode2();
                
                this.deleteDiode2();
                this.drawDiode2();
                
                % Redraw diode crosshair
                this.deleteCrosshairYag();
                this.drawCrosshairYag();
                
                this.deleteYag();
                this.drawYag();
                
                % Redraw load lock crosshair
                this.deleteCrosshairLoadLock();
                this.drawCrosshairLoadLock();
                
            end
            
            this.deleteClockTimes();
            this.drawClockTimes();
            
            cMsg = sprintf('zoom = %1.2e', this.uiZoomPanAxes.getZoom());
            this.msg(cMsg);
            
        end
        
        function onPan(this, ~, ~)
            this.deleteClockTimes();
            this.drawClockTimes(); 
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
            
            dL = -this.dWidthField/2 + this.dXChiefRay;
            dR = this.dWidthField/2 + this.dXChiefRay;
            dT = this.dHeightField/2 + this.dYChiefRay;
            dB = -this.dHeightField/2 + this.dYChiefRay;

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
        
        function drawCrosshairWafer(this)
            
            % Vertical Line
                       
            dL = -this.dThicknessOfCrosshair/2;
            dR = this.dThicknessOfCrosshair/2;
            dT = this.dSizeCrosshairWafer/2;
            dB = -this.dSizeCrosshairWafer/2;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairWafer, ...
                'Parent', this.hCrosshairWafer, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairWafer ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairWafer/2;
            dR = this.dSizeCrosshairWafer/2;
            dT = this.dThicknessOfCrosshair/2;
            dB = -this.dThicknessOfCrosshair/2;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairWafer, ...
                'Parent', this.hCrosshairWafer, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairWafer ...
            );
        
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                dShiftX, dShiftY, 'Wafer (0,0)', ...
                'Parent', this.hCrosshairWafer, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorCrosshairWafer ... 
            ); 
        
            % uistack(hPatch, 'top');
            
            
            
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
                this.dXZero + dShiftX, this.dYZero + dShiftY, 'Stage (0,0) ', ...
                'Parent', this.hCrosshairZero, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorCrosshairZero ... 
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
        
            
        
            % uistack(hPatch, 'top');
                        
        end 
        
        function drawDiode(this)
            
            dL = this.dXDiode - this.dWidthDiode / 2;
            dR = this.dXDiode + this.dWidthDiode / 2;
            dT = this.dYDiode + this.dHeightDiode / 2;
            dB = this.dYDiode - this.dHeightDiode / 2;
            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorDiode, ...
                'Parent', this.hDiode, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaDiode ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXDiode + dShiftX, ...
                this.dYDiode + dShiftY, ...
                'Diode', ...
                'Parent', this.hDiode, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorDiode ... 
            ); 
            
        end
        
        
        function drawCrosshairDiode2(this)
            
            % Vertical Line
            
            dL = -this.dThicknessOfCrosshair/2 + this.dXDiode2;
            dR = this.dThicknessOfCrosshair/2 + this.dXDiode2;
            dT = this.dSizeCrosshairDiode/2 + this.dYDiode2;
            dB = -this.dSizeCrosshairDiode/2 + this.dYDiode2;

            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairDiode2, ...
                'Parent', this.hCrosshairDiode2, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairDiode2 ...
            );
        
            % uistack(hPatch, 'top');
            
            % Horizontal Line
            
            dL = -this.dSizeCrosshairDiode/2 + this.dXDiode2;
            dR = this.dSizeCrosshairDiode/2 + this.dXDiode2;
            dT = this.dThicknessOfCrosshair/2 + this.dYDiode2;
            dB = -this.dThicknessOfCrosshair/2 + this.dYDiode2;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorCrosshairDiode2, ...
                'Parent', this.hCrosshairDiode2, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaCrosshairDiode2 ...
            );
        
            
        
            % uistack(hPatch, 'top');
                        
        end 
        
        function drawDiode2(this)
            
            dL = this.dXDiode2 - this.dWidthDiode / 2;
            dR = this.dXDiode2 + this.dWidthDiode / 2;
            dT = this.dYDiode2 + this.dHeightDiode / 2;
            dB = this.dYDiode2 - this.dHeightDiode / 2;
            
            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                this.dColorDiode2, ...
                'Parent', this.hDiode2, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaDiode2 ...
            );
        
            [dShiftX, dShiftY] = this.getShiftOfCrosshairLabel();
            text( ...
                this.dXDiode2 + dShiftX, ...
                this.dYDiode2 + dShiftY, ...
                'Diode 2', ...
                'Parent', this.hDiode2, ...
                ...%'HorizontalAlignment', 'center', ...
                'Color', this.dColorDiode2 ... 
            ); 
            
        end
        
        function drawYag(this)
            
            
            dTheta = [0 : 1 : 360] * 2 * pi / 360;
            dR = ones(size(dTheta)) * this.dDiameterYag / 2;
            
            hPatch = patch( ...
                this.dXYag + dR .* sin(dTheta), ...
                this.dYYag + dR .* cos(dTheta), ...
                this.dColorYag, ...
                'Parent', this.hDiode, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaYag ...
            );
            
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
                'Color', this.dColorCrosshairLoadLock ... 
            ); 
        
            % uistack(hPatch, 'top');
                        
        end 
        
        function [dX, dY] = getShiftOfCrosshairLabel(this)
            
            dZoom = this.uiZoomPanAxes.getZoom();
            dX = .005/dZoom;
            dY = -0.015/dZoom;
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
                dLeft + dWidth/2, ...
                dBottom + 0.12 * dHeight, ...
                '12:00 (-Y)', ...
                ceProps{:} ...
            ); 
        
            % 03:00
            text( ...
                dLeft + 0.1 * dWidth, ...
                dBottom + dHeight * 0.5, ...
                '03:00 (-X)', ...
                ceProps{:} ...
            );
        
            % 06:00
            text( ...
                dLeft + dWidth/2, ...
                dBottom + dHeight - 0.02 * dHeight, ...
                '06:00 (+Y)', ...
                ceProps{:} ...
            );
        
            % 09:00
            text( ...
                dLeft + dWidth - 0.06 * dWidth, ...
                dBottom + dHeight * 0.5, ...
                '09:00 (+X)', ...
                ceProps{:} ...
            );
            
            
        end
        
        function drawAperture(this)
         
            % Plate
            dWidth = 100;
            dHeight = 50;
            
           
            % Plate left/right/top/bottom
            dLP = -dWidth/2;
            dRP = dWidth/2;
            dTP = dHeight/2;
            dBP = -dHeight/2;
            
            % This is going to be dumb and manual but only need to do one
            % time so not trying to get too clever
            
            % Need to make a text file with these values that the aperture
            % uses and this uses.
            
            
            %{
            ceOptions = {...
                struct('cLabel', '25 mm', 'dArea', 2.5^2, 'dX', -25, 'dY' , 0, 'dWidth', 25, 'dHeight', 25), ...
                struct('cLabel', '10 mm', 'dArea', 1, 'dX', 5, 'dY', 0, 'dWidth', 10, 'dHeight', 10), ...
                struct('cLabel', '5 mm', 'dArea', .5^2, 'dX', 25, 'dY', 0, 'dWidth', 5, 'dHeight', 5), ...
                struct('cLabel', '500 um', 'dArea', 0.002, 'dX', 35, 'dY', 0, 'dWidth', 0.5, 'dHeight', 0.5) ...
            };
            %}
            
            % Aperture 1
            dX1 = 25;
            dY1 = 0;
            dWidth1 = 25.4;
            dHeight1 = 25.4;
            
            % Aperture 2
            dX2 = -5;
            dY2 = 0;
            dWidth2 = 10;
            dHeight2 = 10;
            
            % Aperture 3
            dX3 = -25;
            dY3 = 0;
            dWidth3 = 5;
            dHeight3 = 5;
            
            % Aperture 4
            dX4 = -35;
            dY4 = 0;
            dWidth4 = 1;
            dHeight4 = 1;
            
            % left/right/top/bottom
            
            dL1 = dX1 - dWidth1/2;
            dR1 = dX1 + dWidth1/2;
            dT1 = dY1 + dHeight1/2;
            dB1 = dY1 - dHeight1/2;
            
            dL2 = dX2 - dWidth2/2;
            dR2 = dX2 + dWidth2/2;
            dT2 = dY2 + dHeight2/2;
            dB2 = dY2 - dHeight2/2;
            
            dL3 = dX3 - dWidth3/2;
            dR3 = dX3 + dWidth3/2;
            dT3 = dY3 + dHeight3/2;
            dB3 = dY3 - dHeight3/2;
            
            dL4 = dX4 - dWidth4/2;
            dR4 = dX4 + dWidth4/2;
            dT4 = dY4 + dHeight4/2;
            dB4 = dY4 - dHeight4/2;
            
            
            %top half start bottom left
            xtop = [
                dLP dLP ...
                dL1 dL1 ...
                dR1 dR1 ...
                dL2 dL2 ...
                dR2 dR2 ...
                dL3 dL3 ...
                dR3 dR3 ...
                dL4 dL4 ...
                dR4 dR4 ...
                dRP dRP];
            
            ytop = [dTP 0 0 dT1 dT1 0 0 dT2 dT2 0 0 dT3 dT3 0 0 dT4 dT4 0 0 dTP];            
            ybot = [dBP 0 0 dB1 dB1 0 0 dB2 dB2 0 0 dB3 dB3 0 0 dB4 dB4 0 0 dBP];
                
            x = xtop * 1e-3;
            y = ytop * 1e-3;
                        
            hPatch = patch( ...
                x, ...
                y, ...
                this.dColorYag, ...
                'Parent', this.hAperture, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaYag ...
            );
        
            x = xtop * 1e-3;
            y = ybot * 1e-3;
            
            hPatch = patch( ...
                x, ...
                y, ...
                this.dColorYag, ...
                'Parent', this.hAperture, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', this.dAlphaYag ...
            );
            
            
        end
        
        
        
        function drawWafer(this)
            
            %{
            dDTheta = 1/360;            
            dTheta = [0/180:dDTheta:70/180,...
                110/180:dDTheta:170/180,...
                190/180:dDTheta:360/180]*pi;
            %}
            
            
            dTheta = 1;
            dTheta = [...
                0 : dTheta : 170 , ...
                180, ...
                190 : dTheta : 360 ...
            ] * 2 * pi / 360;
            
            
            dR = ones(size(dTheta)) * 100e-3;
            dR(ceil(length(dTheta)/2)) = 80e-3;
            
            dTheta = dTheta + 90*pi/180;
            
            hPatch = patch( ...
                dR .* sin(dTheta), ...
                dR .* cos(dTheta), ...
                [0, 0, 0], ...
                'Parent', this.hWafer, ...
                'EdgeColor', 'none');
            
            % uistack(hPatch, 'top');
                        
        end
        

        % Returns the max dose in a cell array of exposure arrays
        function dDoseMax = getDoseMaxOfExposures(this, ceExposures)
            dDoseMax = 0; % each exposure is a matrix of (x, y, width, height, dose)
            for k = 1:length(ceExposures)
                dDose = ceExposures{k}(5);
                if dDose > dDoseMax
                    dDoseMax = dDose;
                end
            end
            
        end
        
        
        function drawExposures(this)
                  
            % Need a clever way of doing this
            
            ceExposures = this.exposures.getExposures();
            
            if all(size(ceExposures) == size(this.ceExposures)) && ...
               isequal(ceExposures, this.ceExposures)
                return
            end
            
            % size(ceExposures)
            this.ceExposures = ceExposures; % update storage, redraw
            this.deleteExposures();
            
            % Draw
            if isempty(this.hExposures) || ...
                ~ishandle(this.hExposures)
                return
            end
            
            dDoseMax = this.getDoseMaxOfExposures(ceExposures); % each exposure is a matrix of (x, y, width, height, dose)
            dVMax = 1; % VALUE
            for k = 1:length(ceExposures)
                dExposure = ceExposures{k};
                dX = dExposure(1);
                dY = dExposure(2);
                dWidth = dExposure(3);
                dHeight = dExposure(4);
                dDose = dExposure(5);
                
                % (H)ue is focus
                % (V)alue is dose
    
                dH = this.dHueExposure; 
                % dV = this.dMinV + (1 - this.dMinV)*dDose / dDoseMax;
                dV = dDose / dDoseMax * dVMax;
                
                dL = dX - dWidth/2;
                dR = dX + dWidth/2;
                dT = dY + dHeight/2;
                dB = dY - dHeight/2;

                patch( ...
                    'XData', [dL dL dR dR], ...
                    'YData', [dB dT dT dB], ...
                    'FaceColor', hsv2rgb([dH, 1, dV]), ...
                    'EdgeColor', hsv2rgb([dH, 1, dVMax]), ...
                    'LineWidth', this.getThicknessOfCrosshair(), ...
                    'Parent', this.hExposures ...
                );
            end
              
        end
        
        function drawExposuresPre(this)
                  
            % Need a clever way of doing this
            
            ceExposures = this.exposures.getExposuresPre();
            
            if all(size(ceExposures) == size(this.ceExposuresPre)) && ...
               isequal(ceExposures, this.ceExposuresPre)
                return
            end
            
            % size(ceExposures)
            this.ceExposuresPre = ceExposures; % update storage, redraw
            this.deleteExposuresPre();
            
            % Draw
            if isempty(this.hExposuresPre) || ...
                ~ishandle(this.hExposuresPre)
                return
            end
            
            dDoseMax = this.getDoseMaxOfExposures(ceExposures); % each exposure is a matrix of (x, y, width, height, dose)
            dVMax = 0.4;
            for k = 1:length(ceExposures)
                dExposure = ceExposures{k};
                dX = dExposure(1);
                dY = dExposure(2);
                dWidth = dExposure(3);
                dHeight = dExposure(4);
                dDose = dExposure(5);
                
                % (H)ue is focus
                % (V)alue is dose
    
                dH = this.dHueExposurePre; 
                % dV = this.dMinV + (1 - this.dMinV)*dDose / dDoseMax;
                dV = (dDose / dDoseMax) * dVMax; % lower value so tends toward black
                
                dL = dX - dWidth/2;
                dR = dX + dWidth/2;
                dT = dY + dHeight/2;
                dB = dY - dHeight/2;

                patch( ...
                    'XData', [dL dL dR dR], ...
                    'YData', [dB dT dT dB], ...
                    'EdgeColor', hsv2rgb([dH, 1, dVMax]), ...
                    'LineWidth', this.getThicknessOfCrosshair(), ...
                    'FaceColor', hsv2rgb([dH, 1, dV]), ... % low saturation
                    'Parent', this.hExposuresPre ...
                    ...'EdgeColor', 'none' ...
                );
            
                
            end
              
        end
        
        function drawExposuresScan(this)
                  
            % Need a clever way of doing this
            
            ceExposures = this.exposures.getExposuresScan();
            
            if all(size(ceExposures) == size(this.ceExposuresScan)) && ...
               isequal(ceExposures, this.ceExposuresScan)
                return
            end
            
            % size(ceExposures)
            this.ceExposuresScan = ceExposures; % update storage, redraw
            this.deleteExposuresScan();
            
            % Draw
            if isempty(this.hExposuresScan) || ...
                ~ishandle(this.hExposuresScan)
                return
            end
            
            dDoseMax = this.getDoseMaxOfExposures(ceExposures); % each exposure is a matrix of (x, y, width, height, dose)
            dVMax = 0.4;
            for k = 1:length(ceExposures)
                dExposure = ceExposures{k};
                dX = dExposure(1);
                dY = dExposure(2);
                dWidth = dExposure(3);
                dHeight = dExposure(4);
                dDose = dExposure(5);
                
                % (H)ue is focus
                % (V)alue is dose
    
                dH = this.dHueExposureScan; 
                % dV = this.dMinV + (1 - this.dMinV)*dDose / dDoseMax;
                dV = dDose / dDoseMax * dVMax;
                
                
                dL = dX - dWidth/2;
                dR = dX + dWidth/2;
                dT = dY + dHeight/2;
                dB = dY - dHeight/2;

                
                patch( ...
                    'XData', [dL dL dR dR], ...
                    'YData', [dB dT dT dB], ...
                    ...'FaceColor', 'none', ...
                    'EdgeColor', hsv2rgb([dH, 1, dVMax]), ...
                    'LineWidth', this.getThicknessOfCrosshair(), ...
                    'FaceColor', hsv2rgb([dH, 1, dV]), ... 
                    ...'LineWidth', this.getThicknessOfCrosshair(), ...
                    'Parent', this.hExposuresScan ...
                    ...'EdgeColor', 'none' ...
                );
            end
              
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