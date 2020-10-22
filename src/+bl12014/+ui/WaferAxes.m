classdef WaferAxes < mic.Base
        
    properties (Constant)
       
        
        
    end
    
	properties
        
        
       
    end
    
    properties (SetAccess = private)
        
        
        % {double 1x1} width of the mic.ui.axes.ZoomPanAxes in pixels
        dWidth = 500
        
        % {double 1x1} height of the mic.ui.axes.ZoomPanAxes in pixels
        dHeight = 500
        
        
        dXChiefRay = 1e-3 % m
        dYChiefRay = 1e-3 % m
        
        
        % These are overwritten in constructor
        dXCap1 = -80e-3
        dYCap1 = 20e-3
        
        dXCap2 = -80e-3
        dYCap2 = -20e-3
        
        dXCap3 = 80e-3
        dYCap3 = 20e-3
        
        dXCap4 = 80e-3
        dYCap4 = -20e-3
        
        cName = 'wafer-axes'
        
        
    end
    
    properties (Access = private)
        
        % {double 1x1} number that has to do with HSV color transparency
        dMinV = 0.5      
        
        % {double 1x1} width of an exposure in meters
        dWidthField = 200e-6
        
        % {double 1x1} height of an exposure in meters
        dHeightField = 30e-6
        
        % {double 1x1} height of crosshair at center of wafer
        dSizeCrosshairWafer = 100e-3;
        dSizeCrosshairChiefRay = 20e-3;
        
        dSizeCrosshairDiode = 10e-3;
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
        
        
        dAlphaCrosshairDiode = 1;
        dColorCrosshairDiode = [1 1 0];
        
        dAlphaCrosshairYag = 1;
        dColorCrosshairYag = [1 1 0];
        
        
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
        
        
        
        
        dXZero = 0
        dYZero = 0
        
        dXDiode = 103.45e-3
        dYDiode = -6.95e-3
        
        dXYag = 120e-3
        dYYag = -7e-3
        
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
        hCarriageLsi
        hIllum
        
        hCrosshairCap1
        hCrosshairCap2
        hCrosshairCap3
        hCrosshairCap4
        
        hCrosshairChiefRay
        hCrosshairZero
        hCrosshairDiode
        hCrosshairYag
        hCrosshairLoadLock
        hWafer
        hCrosshairWafer
        hFemPreviewPrescription
        hFemPreviewScan
        hExposures
        hOverlay
        hOverlayVib
        hOverlayWFZ
        hOverlayDriftControl
        
        
        tTextVib % {text 1x1}
        
        clock
        
        % @returns {double 1x1} x position of the stage in meters
        fhGetXOfWafer = @() -0.05
        % @returns {double 1x1} y position of the stage in meters
        fhGetYOfWafer = @() 0.02
        % @returns {double 1x1} x position of the lsi stage in meters
        fhGetXOfLsi = @() 450
        
        % @returns {logical 1x1} true if shutter is open
        fhGetIsShutterOpen = @()false
        fhGetIsVib = @() false
        fhGetIsWFZ = @() false
        fhGetIsDriftControl = @() false
        fhGetVibX = @() 0
        fhGetVibY = @() 0
        
        
        % {bl12014.waferExposureHistory
        waferExposureHistory
        
        dDelay = 0.5
        
        lIsExposing
        lIsVib
        lIsWFZ
        lIsDriftControl
        
        % Storage so only redraw when have to
        dXFemPreview = []
        dYFemPreview = []
        dXFemPreviewScan = []
        dYFemPreviewScan = []
        ceExposure = {}
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = WaferAxes(varargin)
            
            
            this.fhGetVibX = @() randn(1,1);
            this.fhGetVibY = @() randn(1,1);
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            % Cap sensor positions
            
            dR = 168e-3 / 2; % radial offset
            dTheta1 = -90 * pi / 180;
            dTheta2 = -150 * pi / 180;
            dTheta3 = 90 * pi / 180;
            dTheta4 = 30 * pi / 180;
            
            this.dXCap1 = dR * cos(dTheta1);
            this.dYCap1 = dR * sin(dTheta1);
            
            this.dXCap2 = dR * cos(dTheta2);
            this.dYCap2 = dR * sin(dTheta2);
            
            this.dXCap3 = dR * cos(dTheta3);
            this.dYCap3 = dR * sin(dTheta3);
            
            this.dXCap4 = dR * cos(dTheta4);
            this.dYCap4 = dR * sin(dTheta4);
            
            this.init();
            
            
        end
        
          
        function delete(this)
            if isvalid(this.clock) &&...
               this.clock.has(this.id())
                this.clock.remove(this.id());
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
            this.hCarriageLsi = hgtransform('Parent', this.hTransformedGroup);    
            this.drawCarriageLsi();
            this.setXLsi()
            
            
            this.hWafer = hggroup('Parent', this.hCarriage);  
            this.drawWafer();

                     
            this.hCrosshairDiode = hggroup('Parent', this.hCarriage);   
            this.drawCrosshairDiode();         
            this.hCrosshairYag = hggroup('Parent', this.hCarriage);
            
            this.hCrosshairWafer = hggroup('Parent', this.hWafer);
            this.hFemPreviewPrescription = hggroup('Parent', this.hWafer);
            this.hFemPreviewScan = hggroup('Parent', this.hWafer);
            this.hExposures = hggroup('Parent', this.hWafer);
            
            this.hIllum = hggroup('Parent', this.hTransformedGroup);
            this.drawIllum();
            
            
            this.hCrosshairChiefRay = hggroup('Parent', this.hTransformedGroup);
            this.hCrosshairZero = hggroup('Parent', this.hTransformedGroup);
            this.hCrosshairLoadLock = hggroup('Parent', this.hTransformedGroup);
            this.hOverlayVib = hggroup('Parent', this.hTransformedGroup);
            this.hOverlayWFZ = hggroup('Parent', this.hTransformedGroup);
            this.hOverlayDriftControl = hggroup('Parent', this.hTransformedGroup);
            this.hOverlay = hggroup('Parent', this.hTransformedGroup);

            this.hClockTimes = hggroup('Parent', this.hTransformedGroup);
            this.hCrosshairCap1 = hggroup('Parent', this.hTransformedGroup);
            this.hCrosshairCap2 = hggroup('Parent', this.hTransformedGroup);
            this.hCrosshairCap3 = hggroup('Parent', this.hTransformedGroup);
            this.hCrosshairCap4 = hggroup('Parent', this.hTransformedGroup);
            
            
            % Rotate around z axis by 180
            dRotation = makehgtform('zrotate', pi);
            set(this.hTransformedGroup, 'Matrix', dRotation);
            
            
                       
            % this.drawCrosshairYag();

            
            
            this.drawCrosshairChiefRay();
            this.drawCrosshairZero();
            this.drawCrosshairLoadLock();
            this.drawClockTimes();
            this.drawCrosshairCap1();
            this.drawCrosshairCap2();
            this.drawCrosshairCap3();
            this.drawCrosshairCap4();
            this.drawCrosshairWafer();
            
            
            this.clock.add(@this.onClock, this.id(), this.dDelay);
            
        end

            

    end
    
    methods (Access = private)
        
        function onClock(this)
            
            this.setXLsi();
            this.setStagePosition();
            this.drawExposures();
            this.drawFemPreview('prescription');
            this.drawFemPreview('scan');
            this.setExposing();
            this.setOverlayVib();
            this.setOverlayWFZ();
            this.setTextVib();
            this.setOverlayDriftControl();

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
        
        function deleteCrosshairYag(this)
            this.deleteChildren(this.hCrosshairYag)
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
        
        function deleteOverlayVib(this)
            this.deleteChildren(this.hOverlayVib);                
        end
        
        function deleteOverlayDriftControl(this)
            this.deleteChildren(this.hOverlayDriftControl);                
        end
        
        function deleteOverlayWFZ(this)
            this.deleteChildren(this.hOverlayWFZ);                
        end
        
        function setXLsi(this)
            
            dX = this.fhGetXOfLsi();
            
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
        
        
        function setStagePosition(this)
            
            % Make sure the hggroup of the carriage is at the correct
            % location.
            
            dX = this.fhGetXOfWafer();
            dY = this.fhGetYOfWafer();
            
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
        
        function setOverlayVib(this)
            
            lIsVib = this.fhGetIsVib();
            
            if (this.lIsVib == lIsVib)
                return
            end
            
            this.lIsVib = lIsVib;
                
            if this.lIsVib
                this.drawOverlayVib();
            else
                this.deleteOverlayVib();
            end
                            
        end
        
        function setOverlayDriftControl(this)
            
            lIsDriftControl = this.fhGetIsDriftControl();
            
            if (this.lIsDriftControl == lIsDriftControl)
                return
            end
            
            this.lIsDriftControl = lIsDriftControl;
                
            if this.lIsDriftControl
                this.drawOverlayDriftControl();
            else
                this.deleteOverlayDriftControl();
            end
                            
        end
        
        function setOverlayWFZ(this)
            
            lIsWFZ = this.fhGetIsWFZ();
            
            if (this.lIsWFZ == lIsWFZ)
                return
            end
            
            this.lIsWFZ = lIsWFZ;
                
            if this.lIsWFZ
                this.drawOverlayWFZ();
            else
                this.deleteOverlayWFZ();
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
        
        function init(this)
            this.msg('init()');
            this.uiZoomPanAxes = mic.ui.axes.ZoomPanAxes(-1, 1, -1, 1, this.dWidth, this.dHeight, this.dZoomMax);
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
                
                % Redraw diode crosshair
                %{
                this.deleteCrosshairYag();
                this.drawCrosshairYag();
                %}
                
                % Redraw load lock crosshair
                this.deleteCrosshairLoadLock();
                this.drawCrosshairLoadLock();
                
                
                this.deleteCrosshairCap1();
                this.drawCrosshairCap1();
                
                this.deleteCrosshairCap2();
                this.drawCrosshairCap2();
                
                this.deleteCrosshairCap3();
                this.drawCrosshairCap3();
                
                this.deleteCrosshairCap4();
                this.drawCrosshairCap4();
                
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
        
        function drawCarriageLsi(this)
            
            dOffset = 0;
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
                dLeft + dWidth/2, dBottom + 0.12 * dHeight, '12:00 (-Y)', ...
                ceProps{:} ...
            ); 
        
            % 03:00
            text( ...
                dLeft + dWidth * 0.1, dBottom + dHeight * 0.5, '03:00 (-X)', ...
                ceProps{:} ...
            );
        
            % 06:00
            text( ...
                dLeft + dWidth/2, dBottom + dHeight - 0.05 * dHeight, '06:00 (+Y)', ...
                ceProps{:} ...
            );
        
            % 09:00
            text( ...
                dLeft + dWidth * 0.93, dBottom + dHeight * 0.5, '09:00 (+X)', ...
                ceProps{:} ...
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
        

        
        function drawFemPreview(this, cType)
            
            if ~ishandle(this.hFemPreviewPrescription)
                return;
            end
            
            
            
            switch cType
                case 'prescription'
                    
                    
                    [dX, dY] = this.waferExposureHistory.getCoordinatesOfFemPreview();
                    
                    % check if can return before redraw
                    if all(size(dX) == size(this.dXFemPreview)) && ... 
                       all(size(dY) == size(this.dYFemPreview)) && ...     
                       isequal(dX, this.dXFemPreview) && ...
                       isequal(dY, this.dYFemPreview)
                        return
                    end
                    
                    if isempty(dX) 
                        return 
                    end
                    if isempty(dY) 
                        return 
                    end
                    
                    % update storage
                    this.dXFemPreview = dX;
                    this.dYFemPreview = dY;
                    
                    % delete and allow to redraw
                    this.deleteFemPreviewPrescription();
                    dColor = [1 1 1];
                    dAlpha = 0.5;
                    hParent = this.hFemPreviewPrescription;
                        
                case 'scan'
                   
                    [dX, dY] = this.waferExposureHistory.getCoordinatesOfFemPreviewScan();
                    
                    % if size and values have not changed, return
                    if all(size(dX) == size(this.dXFemPreviewScan)) && ... 
                       all(size(dY) == size(this.dYFemPreviewScan)) && ...
                       isequal(dX, this.dXFemPreviewScan) && ...
                       isequal(dY, this.dYFemPreviewScan)
                        return
                    end
                    
                    % size or values have changed
                    this.dXFemPreviewScan = dX;
                    this.dYFemPreviewScan = dY;
                    this.deleteFemPreviewScan();
                    
                    if isempty(dX)
                       return
                    end
                    if isempty(dY) 
                        return 
                    end
                    
                    % update storage
                    
                    dColor = [1 0 1];
                    dAlpha = 0.5;
                    hParent = this.hFemPreviewScan;

            end
                        
            [dFocusNum, dDoseNum] = size(dX);
                        
            for row = 1:dFocusNum
                for col = 1:dDoseNum
                
                    dL = dX(row, col) - this.dWidthField/2;
                    dR = dX(row, col) + this.dWidthField/2;
                    dT = dY(row, col) + this.dHeightField/2;
                    dB = dY(row, col) - this.dHeightField/2;

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
            
            % Index shot
            row = 1;
            col = 1;
            
            [dRows, dCols] = size(dY);
            if dRows > 1
                dYStep = dY(2, 1) - dY(1, 1);
            else
                dYStep = 0.2;
            end
            
            
            dL = dX(row, col) - this.dWidthField/2;
            dR = dX(row, col) + this.dWidthField/2;
            dT = dY(row, col) - dYStep + this.dHeightField/2;
            dB = dY(row, col) - dYStep - this.dHeightField/2;

            patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                dColor, ...
                'Parent', hParent, ...
                'FaceAlpha', dAlpha, ...
                'EdgeColor', 'none' ...
            );
            
            
        end
        
        
        function drawExposures(this)
                  
            % Need a clever way of doing this
            
            ceExposure = this.waferExposureHistory.getExposures();
            
            if all(size(ceExposure) == size(this.ceExposure)) && ...
               isequal(ceExposure, this.ceExposure)
                return
            end
            
            % size(ceExposure)
            this.ceExposure = ceExposure; % update storage, redraw
            this.deleteExposures();
            
            for k = 1:length(ceExposure)
                this.drawExposure(ceExposure{k});
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

            dL = dData(1) - this.dWidthField/2;
            dR = dData(1) + this.dWidthField/2;
            dT = dData(2) + this.dHeightField/2;
            dB = dData(2) - this.dHeightField/2;

            patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                hsv2rgb([dH, 1, dV]), ...
                'Parent', this.hExposures, ...
                'EdgeColor', 'none' ...
            );
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
            
            dColor = hsv2rgb(0.9, 1, 1);
            
            patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                dColor, ...
                'Parent', this.hOverlay, ...
                'FaceAlpha', 0.5, ...
                'LineWidth', 1, ...
                'EdgeColor', [1, 1, 1] ...
            );
        
            ceProps = {
               'Parent', this.hOverlay, ...
                'Interpreter', 'none', ...
                'Clipping', 'on', ...
                'HitTest', 'off', ...
                'FontSize', 50, ...
                ...% 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', ...
                'Color', dColor ... 
            };
                        
            % 12:00
            text( ...
                0, 0, 'EXPOSE', ...
                ceProps{:} ...
            ); 
            
        end
        
        function setTextVib(this)
            
            if ~this.fhGetIsVib()
                return
            end
            
            if isempty(this.tTextVib)
                return
            end
            
            cMsg = {...
                'VIB', ...
                sprintf('X=%1.2f nm', this.fhGetVibX()), ...
                sprintf('Y=%1.2f nm', this.fhGetVibY()) ...
            };
            set(this.tTextVib, 'String', cMsg);
        end
        
        
        function drawOverlayVib(this)
            
            this.msg('drawOverlayVib');
            
            
            if isempty(this.hOverlayVib) || ...
                ~ishandle(this.hOverlayVib)
                return
            end
            
            dL = -1;
            dR = 1;
            dT = 1;
            dB = -1;
            
            dColor = hsv2rgb(0.3, 1, 1);
            patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                dColor, ...
                'Parent', this.hOverlayVib, ...
                'FaceAlpha', 0.5, ...
                'LineWidth', 1, ...
                'EdgeColor', [1, 1, 1] ...
            );
        
            ceProps = {
               'Parent', this.hOverlayVib, ...
                'Interpreter', 'none', ...
                'Clipping', 'on', ...
                'HitTest', 'off', ...
                'FontSize', 50, ...
                ...% 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', ...
                'Color', dColor ... 
            };
        
            cMsg = {...
                'VIB', ...
                sprintf('X=%1.2f nm', this.fhGetVibX()), ...
                sprintf('Y=%1.2f nm', this.fhGetVibY()) ...
            };
                        
            this.tTextVib = text( ...
                0, 0, cMsg, ...
                ceProps{:} ...
            ); 

        end
        
        
        function drawOverlayDriftControl(this)
            
            this.msg('drawOverlayDriftControl');
            
            
            if isempty(this.hOverlayDriftControl) || ...
                ~ishandle(this.hOverlayDriftControl)
                return
            end
            
            dL = -1;
            dR = 1;
            dT = 1;
            dB = -1;
            
            dColor = hsv2rgb(0.2, 1, 1);
            patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                dColor, ...
                'Parent', this.hOverlayDriftControl, ...
                'FaceAlpha', 0.5, ...
                'LineWidth', 1, ...
                'EdgeColor', [1, 1, 1] ...
            );
        
            ceProps = {
               'Parent', this.hOverlayDriftControl, ...
                'Interpreter', 'none', ...
                'Clipping', 'on', ...
                'HitTest', 'off', ...
                'FontSize', 50, ...
                ...% 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', ...
                'Color', dColor ... 
            };
                                
            this.tTextVib = text( ...
                0, 0, 'Drift Control', ...
                ceProps{:} ...
            ); 

        end
        
        function drawOverlayWFZ(this)
            
            this.msg('drawOverlayWFZ');
            
            
            if isempty(this.hOverlayWFZ) || ...
                ~ishandle(this.hOverlayWFZ)
                return
            end
            
            dL = -1;
            dR = 1;
            dT = 1;
            dB = -1;
            
            dColor = hsv2rgb(0.4, 1, 1);
            
            patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                dColor, ...
                'Parent', this.hOverlayWFZ, ...
                'FaceAlpha', 0.5, ...
                'LineWidth', 1, ...
                'EdgeColor', [1, 1, 1] ...
            );
        
            ceProps = {
               'Parent', this.hOverlayWFZ, ...
                'Interpreter', 'none', ...
                'Clipping', 'on', ...
                'HitTest', 'off', ...
                'FontSize', 50, ...
                ...% 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', ...
                'Color', dColor ... 
            };
                        
            % 12:00
            text( ...
                0, 0, 'WFZ', ...
                ceProps{:} ...
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