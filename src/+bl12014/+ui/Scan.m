classdef Scan < mic.Base
    
    % A panel with a list of available prescriptions, the ability to queue
    % multiple prescriptions to a new experiment (wafer), start/pause/stop
    % the experiment, checkboxes for booleans pertaining to running the
    % experiment
    
    
    properties (Constant)
       
        dWidth = 950
        dHeight = 600
        
        
        dWidthList = 400
        dHeightList = 100
        dWidthUiScan = 270
        
        dPauseTime = 1
        
        dWidthPanelAvailable = 700
        dHeightPanelAvailable = 200
        
        dWidthPanelAdded = 420
        dHeightPanelAdded = 940
        
        dWidthPanelBorder = 1
        
        dColorFigure = [200 200 200]./255
        
        dToleranceReticleX = 0.01 % mm
        dToleranceReticleY = 0.01 % mm
        dToleranceWaferX = 0.01 % mm
        dToleranceWaferY = 0.01 % mm
        dToleranceWaferZ = 5 % nm
        dToleranceReticleFineX = 0.1 % umm
        dToleranceReticleFineY = 0.1 % um

        dColorGreen = [.85, 1, .85];
        dColorRed = [1, .85, .85];
        
    end
    
	properties

        
    end
    
    properties (SetAccess = private)
        
        hDYMO
        
        uiEditMjPerCm2PerSec
        uiEditRowStart
        uiEditColStart
        
        uiFluxDensity
        
        uiPOCurrent
        uiShutter
        uiPrescriptionTool
        uiFocusLog
        uiCurrentOfALS
        uiDoseMonitorList
        
        cName = 'fem-scan-control'
    
    end
    
    properties (Access = private)
        
        
        dTicScanSetState
        dTicScanAcquire
        dWidthButton = 100
        dWidthPadPanel = 10
        dWidthPadFigure = 10
        dHeightPadFigure = 10
        dHeightButton = 24
        
        uiListPrescriptions            
        uiListActive
        
        uiButtonClearPrescriptions
        uiButtonClearWafer
        
        uibNewWafer
        uibAddToWafer
        uibPrint
        uibPrintSaved
        uicWaferLL
        uicAutoVentAtLL 
        
        
        uiMFDriftMonitor
        uiMfDriftMonitorVibration
        uiVibrationIsolationSystem
        uiWafer
        uiReticle
        uiPupilFill
        uiScannerMA
        uiScannerM142
        % {mic.ui.device.GetSetNumber 1x1}
        uiBeamline % Temporary, allows control of the shutter
        uiTuneFluxDensity
        uiHeightSensorLEDs
        
        clock
        uiClock
        
        hDock
        
        cDirThis
        cDirSrc
        cDirPrescriptions
        cDirSave
        cDirScan % new directory for every scan
        
        hPanelAvailable
        hPanelAdded
        hParent
        
        cePrescriptions           % Store uiListActive.ceOptions when FEM starts
         
        %{        
        uitScanPause
        uibScanAbort
        uibScanStart
        %}
        
        % {mic.ui.Scan 1x1}
        uiScan
        
        % Going to have a play/pause button and an abort button.  When you
        % click play the first time, a logical lRun = true will be set.  An
        % abort button will be shown.  Chenging the status of the button
        % will then put us into wait.  Only if we click abort lRun = false
        % will be set and the abort button will be hidden
        
        lRunning = false
        
        % {mic.Scan 1x1}
        scan
        
        % {struct 1x1} storage used  and checking if the
        % system has reached a particular state.  The structure has a prop
        % for each configurable prop of the system and each of those has
        % two props: lRequired, lIssued
        stScanSetContract
        stScanAcquireContract
        stScanTimingStore
        
        % {cell of struct} storage of state during each acquire
        ceValues
        ceValuesFast % storage at n Hz not necessarily correlated with exposures
        
                
        
        uiWaferAxes
        uiReticleAxes
        waferExposureHistory
        
        
         % {bl12014.Hardware 1x1}
        hardware
            
        
        uiSequenceLevelWafer
        uiSequenceLevelReticle
        uiStateM142ScanningDefault
        uiStateUndulatorIsCalibrated
        uiStateExitSlitIsCalibrated
        uiStateMonoGratingAtEUV
        uiStateEndstationLEDsOff
        uiStateVPFMOut
                uiStateSR570MDMIsSet

        uiStateM141SmarActOff
        uiStateHeightSensorLEDsOn
        uiStatePowerPmacAccelSetForFEM
        
        uiSequenceRecoverFem
        
        uiTextReticleField
        
        hAxesPupilFill
        hAxesFieldFill
        hPlotPupilFill
        hPlotFieldFill
        dColorPlotFiducials = [0.3 0.3 0.3]
        
        uiTextTimeCalibrated
        uiTextFluxDensityCalibrated
        
        lIsWaitingForAccOfAIToSettle = false
        lIsWaitingForVelOfAIToSettle = false
        lIsVib = false
        lIsWFZ = false
        dRmsDriftX = 0
        dRmsDriftY = 0
        
        dAccXOfAI = 0;
        dAccYOfAI = 0;
        
        dVelXOfAI = 0;
        dVelYOfAI = 0;
        
        
        lSkipWorkingMode = false
        
        dZHeightSensorTarget = 0;
        dChargeDoseMonitor = 0;
    end
    
        
    events
        ePreChange
    end
    

    
    methods
        
        
        function this = Scan(varargin)
            
            
            this.cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSrc = fullfile(this.cDirThis, '..', '..');
            
            this.cDirSave = fullfile(this.cDirSrc, 'save', 'fem-scans');

                        
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
            
            if ~isa(this.uiTuneFluxDensity, 'bl12014.ui.TuneFluxDensity')
                error('uiTuneFluxDensity must be bl12014.ui.TuneFluxDensity');
            end
            
            if ~isa(this.uiReticle, 'bl12014.ui.Reticle')
                error('uiReticle must be bl12014.ui.Reticle');
            end
            
            if ~isa(this.uiWafer, 'bl12014.ui.Wafer')
                error('uiWafer must be bl12014.ui.Wafer');
            end
            
            if ~isa(this.uiScannerMA, 'bl12014.ui.Scanner')
                error('uiScannerMA must be bl12014.ui.Scanner');
            end
            
            if ~isa(this.uiScannerM142, 'bl12014.ui.Scanner')
                error('uiScannerM142 must be bl12014.ui.Scanner');
            end
            
            if ~isa(this.waferExposureHistory, 'bl12014.WaferExposureHistory')
                error('waferExposureHistory must be bl12014.WaferExposureHistory');
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
            
        end
        
        function cec = getSaveLoadProps(this)
           
            cec = {...
                'uicWaferLL', ...
                'uicAutoVentAtLL', ...
                'uiFluxDensity', ...
                'uiEditRowStart', ...
                'uiEditColStart', ...
                'uiPrescriptionTool', ...
             };
            
        end
        
       
        
        % Returns the low frequency speed (nm/s) of the aerial image relative to the
        % wafer over the last 2 seconds.  
        function [dX, dY] = getVelocityOfAerialImage(this)
            
            dSamples = this.hardware.getMfDriftMonitor().getSampleData(4000);
            [dX, dY] =  bl12014.MfDriftMonitorUtilities.getVelocityOfAerialImageFromSampleData(dSamples);
           
        end
        
        % Returns the low frequency acceleration (nm/s/s) of the aerial image relative to the
        % wafer over the last 5 seconds
        function [dX, dY] = getAccelerationOfAerialImage(this)
            
            dSamples = this.hardware.getMfDriftMonitor().getSampleData(4000);
            [dX, dY] = bl12014.MfDriftMonitorUtilities.getAccelerationOfAerialImageFromSampleData(dSamples);
           
        end
        
       
        
        % @param {double 1x1} dFadeX - nm to fade image in X
        % @param {double 1x1} dSec - seconds in which the fade of dFade nm
        % is accomplished
        % Most likeley going to want to blur horizontal lines
        % Note that we can't independently set the speed of the X and Y
        % stages so we need to wait for both to be moving slowly enough
        % that the fade of the other direction is negligible or we say
        % we don't care because it is in the direction of the line edge and
        % may actually help.
        
        function setReticleFineYForImageFade(this, dFadeY, dSec)
                        
            lDebug = true;
            
            if lDebug
                cMsg = sprintf('Setting up y image fade of %1.2f nm over %1.0f ms', ...
                    dFadeY, ...
                    dSec * 1000 ...  
                );
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
            end
            
            
            [dVelAIX, dVelAIY] = this.getVelocityOfAerialImage(); % nm/s
            
            if lDebug
                cMsg = sprintf('Speed of aerial image: %1.3f nm/s (x), %1.3f nm/s (y)', ...
                    dVelAIX, ...
                    dVelAIY ...   
                );
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
            end
            
            % nm/s
            dSpeedReticleY = 5*(dFadeY / dSec - dVelAIY);
            
            if lDebug
                cMsg = sprintf('Demand speed of reticle y: %1.2f nm/s', ...
                    dSpeedReticleY ...   
                );
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
            end
            
            % Convert nm/s to mm/s
            this.hardware.getDeltaTauPowerPmac().setDemandSpeedReticleFine(dSpeedReticleY * 1e-6);
            
            % Set it to accelerate to the desired velocity over one second
            %this.hardware.getDeltaTauPowerPmac().setDemandAccelTimeReticleFine(500); % ms
           %this.hardware.getDeltaTauPowerPmac().setDemandAccelTimeBlendedReticleFine(1000); %ms

            % Tell it to move for 5 * dSec worth of distance
            dDeltaX = 0; % nm
            dDeltaY = dSpeedReticleY * dSec * 5; % nm

            dPosX = this.hardware.getDeltaTauPowerPmac().getXReticleFine(); % mm
            dPosY = this.hardware.getDeltaTauPowerPmac().getYReticleFine(); % mm

            dDestX = dPosX + dDeltaX * 1e-6; % mm
            dDestY = dPosY + dDeltaY * 1e-6; % mm
            
            if lDebug
                cMsg = sprintf('Moving reticle fine x %1.2f nm from: %1.3f um, to %1.3f um', ...
                    dDeltaX, ...
                    dPosX * 1e3, ...
                    dDestX * 1e3 ...   
                );
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                
                cMsg = sprintf('Moving reticle fine y %1.2f nm from: %1.3f um, to %1.3f um', ...
                    dDeltaY, ...
                    dPosY * 1e3, ...
                    dDestY * 1e3 ...   
                );
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                
            end
            
            this.hardware.getDeltaTauPowerPmac().setXReticleFineNoMove(dDestX);
            this.hardware.getDeltaTauPowerPmac().setYReticleFineNoMove(dDestY);
            this.hardware.getDeltaTauPowerPmac().moveReticleFineToDest();
            
            % FIX ME don't issue y move for now since can't independently
            % set speeds
                        
        end
        
        function stopReticleFineStageAndResetSpeed(this)
            
            this.hardware.getDeltaTauPowerPmac().stopAll();
            this.hardware.getDeltaTauPowerPmac().setDemandSpeedReticleFine(100); % mm/s
            this.hardware.getDeltaTauPowerPmac().setDemandAccelTimeReticleFine(100); % ms
            this.hardware.getDeltaTauPowerPmac().setDemandAccelTimeBlendedReticleFine(100); %ms

        end
        
        
        
        
        function st = save(this)
             cecProps = this.getSaveLoadProps();
            
            st = struct();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                if this.hasProp( cProp)
                    st.(cProp) = this.(cProp).save();
                end
            end

             
        end
        
        function load(this, st)
                        
            cecProps = this.getSaveLoadProps();
            for n = 1 : length(cecProps)
               cProp = cecProps{n};
               if isfield(st, cProp)
                   if this.hasProp( cProp )
                        this.(cProp).load(st.(cProp))
                   end
               end
            end
            
        end
        
        
        function buildPanelAdded(this)
            
           
            
            dLeft = 640;
            dTop = 10;
            
            this.hPanelAdded = uipanel(...
                'Parent', this.hParent,...
                'Units', 'pixels',...
                'Title', '',...
                'BorderWidth', this.dWidthPanelBorder, ...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                    dLeft ...
                    dTop ...
                    this.dWidthPanelAdded...
                    this.dHeightPanelAdded], ...
                    this.hParent ...
                ) ...
            );
        
            
            dLeft = this.dWidthPadFigure;
            dTop = this.dWidthPadFigure;
            
           dSep = 30;
           dSize = 100;
           
           this.hAxesFieldFill = axes(...
                'Parent', this.hPanelAdded,...
                'Units', 'pixels',...
                'Color', [0 0 0], ...
                'Position',mic.Utils.lt2lb([...
                dLeft, ...
                dTop, ...
                dSize, ...
                dSize], this.hPanelAdded),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                'DataAspectRatio',[1 1 1],...
                'HandleVisibility','on'...
           );
       
            
            this.hAxesPupilFill = axes(...
                'Parent', this.hPanelAdded,...
                'Units', 'pixels',...
                'Color', [0 0 0], ...
                'Position',mic.Utils.lt2lb([...
                dLeft + dSize + 50,...
                dTop,...
                dSize,...
                dSize], this.hPanelAdded),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                'DataAspectRatio',[1 1 1],...
                'HandleVisibility','on'...
           );
            
           dTop = dTop + 120;
           
           
           dWidthText = 300;
           dHeightText = 24;
            
           this.uiTextReticleField.build(this.hPanelAdded, dLeft, dTop, 300, 24);
           dTop = dTop + dSep;
           
           %{
            this.uiTextTimeCalibrated.build(this.hPanelAdded, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dSep;
           %}
            
            
            
            dWidthTask = 400;
            
            % 2022.09 comment out ALS beamline stuff
            
           this.uiStateUndulatorIsCalibrated.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           
           this.uiStateMonoGratingAtEUV.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           
           this.uiStateExitSlitIsCalibrated.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;

           
           this.uiStateM141SmarActOff.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           
           % END of SMS stuff that is not relevent
           
           this.uiStateEndstationLEDsOff.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           
           this.uiStateVPFMOut.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           
           this.uiStateSR570MDMIsSet.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;

           
           
           %{
           this.uiStateM142ScanningDefault.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           %}
           this.uiSequenceLevelReticle.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           
           
           this.uiStateHeightSensorLEDsOn.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           
           this.uiSequenceLevelWafer.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           
           %{
           this.uiStatePowerPmacAccelSetForFEM.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           %}
           
           dTop = dTop + 15
           this.uiListActive.build(this.hPanelAdded, ...
                dLeft, ...
                dTop, ...
                this.dWidthList, ...
                40);
            
           dTop = dTop + 60; % height of list does not include the label on top
           dSep = 20;
           
           
           dLeft = this.dWidthPadFigure;
           
%            this.uibNewWafer.build(this.hPanelAdded, ...
%                 dLeft, ...
%                 dTop, ...
%                 this.dWidthButton, ...
%                 this.dHeightButton);
%             dLeft = dLeft + this.dWidthButton + this.dWidthPadFigure;
            
            this.uiButtonClearPrescriptions.build(this.hPanelAdded, ...
                dLeft, ...
                dTop, ...
                this.dWidthButton, ...
                this.dHeightButton);
            dLeft = dLeft + this.dWidthButton + this.dWidthPadFigure;
            
            this.uiButtonClearWafer.build(this.hPanelAdded, ...
                dLeft, ...
                dTop, ...
                this.dWidthButton, ...
                this.dHeightButton);
            dLeft = dLeft + this.dWidthButton + this.dWidthPadFigure;
            
            
            this.uibPrint.build(this.hPanelAdded, ...
                dLeft, ...
                dTop, ...
                100, ...
                this.dHeightButton);
            
           
           dLeft = this.dWidthPadFigure;
           dTop = dTop + 30;
           
           dTopBelowList = dTop;
           
           dSep = 40;
           
           % this.uiTextFluxDensityCalibrated.build(this.hPanelAdded, dLeft, dTop, dWidthText, dHeightText);
                      
           this.uiFluxDensity.build(this.hPanelAdded, dLeft, dTop);
           dTop = dTop + this.uiFluxDensity.dHeight + 10;
           
           this.uiEditColStart.build(this.hPanelAdded, dLeft, dTop, 100, 24);           
           this.uiEditRowStart.build(this.hPanelAdded, dLeft, dTop + dSep, 100, 24);
           
           dLeftTemp = 130;
           
           this.uiScan.build(this.hPanelAdded, dLeftTemp - 10, dTop + 13);

           dTop = dTop + 80;
          
           dSep = 24;
           
           this.uicWaferLL.build(this.hPanelAdded, ...
               dLeftTemp, ...
               dTop, ...
               200, ...
               20);
           
           dTop = dTop + dSep;
            
           this.uicAutoVentAtLL.build(this.hPanelAdded, ...
               dLeftTemp, ...
               dTop, ...
               200, ...
               20);
                      
          
           dTop = dTop + dSep;
           this.uiSequenceRecoverFem.build(this.hPanelAdded, dLeft, dTop, dWidthTask);

           
            
        end
             
        
        function plotPupilFill(this)
            
            if isempty(this.hAxesPupilFill)
                return
            end
            
            if ~ishandle(this.hAxesPupilFill)
                return
            end
            
            
            st = this.uiScannerMA.uiNPointLC400.getWavetables();
            
            if isempty(this.hPlotPupilFill)
                this.hPlotPupilFill = plot(...
                    this.hAxesPupilFill, ...
                    st.x, st.y, 'm', ...
                    'LineWidth', 2 ...
                );
            
                % Create plotting data for circles at sigma = 0.3 - 1.0

                dSig = [0.3:0.1:1.0];
                dPhase = linspace(0, 2*pi, 100);

                for (k = 1:length(dSig))

                    x = dSig(k)*cos(dPhase);
                    y = dSig(k)*sin(dPhase);
                    line( ...
                        x, y, ...
                        'color', this.dColorPlotFiducials, ...
                        'LineWidth', 1, ...
                        'Parent', this.hAxesPupilFill ...
                    );

                end
            else
                this.hPlotPupilFill.XData = st.x;
                this.hPlotPupilFill.YData = st.y;
            end
            set(this.hAxesPupilFill, 'XTick', [], 'YTick', []);
            
            if this.uiScannerMA.uiNPointLC400.uiGetSetLogicalActive.get()
                set(this.hAxesPupilFill, 'Color', this.dColorGreen);
            else
                set(this.hAxesPupilFill, 'Color', this.dColorRed);
            end
            xlim(this.hAxesPupilFill, [-1 1])
            ylim(this.hAxesPupilFill, [-1 1])
            
        end
        
        function plotFieldFill(this)
            
            if isempty(this.hAxesFieldFill)
                return
            end
            
            if ~ishandle(this.hAxesFieldFill)
                return
            end
            
            
            st = this.uiScannerM142.uiNPointLC400.getWavetables();
            
            if isempty(this.hPlotFieldFill)
                this.hPlotFieldFill = plot(...
                    this.hAxesFieldFill, ...
                    st.x, st.y, 'm', ...
                    'LineWidth', 2 ...
                );
            
                % Draw a border that represents the width of the field
                dWidth = 0.62;
                dHeight = dWidth / 5;
                
                x = [-dWidth/2 dWidth/2 dWidth/2 -dWidth/2 -dWidth/2];
                y = [dHeight/2 dHeight/2 -dHeight/2 -dHeight/2 dHeight/2];
                line( ...
                    x, y, ...
                    'color', this.dColorPlotFiducials, ...
                    'LineWidth', 1, ...
                    'Parent', this.hAxesFieldFill ...
                );
            else
                this.hPlotFieldFill.XData = st.x;
                this.hPlotFieldFill.YData = st.y;
            end
            
            set(this.hAxesFieldFill, 'XTick', [], 'YTick', []);
            
            % Set background color based on if the scanner is on or not
            if this.uiScannerM142.uiNPointLC400.uiGetSetLogicalActive.get()
                set(this.hAxesFieldFill, 'Color', this.dColorGreen);
            else
                set(this.hAxesFieldFill, 'Color', this.dColorRed);
            end
            xlim(this.hAxesFieldFill, [-1 1])
            ylim(this.hAxesFieldFill, [-1 1])
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hParent = hParent;
            dTop = 10;
            this.uiPrescriptionTool.build(hParent, dLeft, dTop);
            
            dLeft = 390;
            dWidthButton = 110;
            dSep = 10;
            
            dTop = dTop + this.uiPrescriptionTool.dHeight - 30;
            this.uibAddToWafer.build(...
                hParent, ...
                dLeft, ...
                dTop, ...
                dWidthButton, ...
                this.dHeightButton);
            
            dLeft = dLeft + dWidthButton + dSep;
            this.uibPrintSaved.build( ...
                hParent, ...
                dLeft, ...
                dTop, ...
                dWidthButton, ...
                this.dHeightButton);
            
            
            this.buildPanelAdded()
            
            
            dTop = 20;
            dLeft = this.uiPrescriptionTool.dWidth + this.dWidthPanelAdded + this.dWidthPadPanel * 3;
            %this.uiReticleAxes.build(this.hParent, 10, dTop);
            this.uiWaferAxes.build(this.hParent, dLeft, dTop);
            this.uiShutter.build(this.hParent, dLeft, 800);
            % this.uiPOCurrent.build(this.hParent, 840, dTop);
            
            
            this.uiFocusLog.build(this.hParent, 10, 620);
            this.uiDoseMonitorList.build(this.hParent, 430, 620, 100, 300);
        end
        
        function onClock(this, ~, ~)
            this.updateTextReticleField();
            this.updateScannerPlots();
        
        end 
        
        
        %% Destructor
        
        function delete(this)
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);  
            this.uiClock.remove(this.id());
            
            this.uiReticleAxes.delete();
            this.uiWaferAxes.delete();
            this.uiFluxDensity.delete();
            %this.uiPOCurrent.delete();
            
                        
        end
        
        
        
        
                    

    end
    
    methods (Access = private)
        
        function init(this)
                  
            this.msg('init()');
            
            
            
            this.uiButtonClearPrescriptions = mic.ui.common.Button(...
                'cText', 'Clear Prescriptions', ...
                'fhOnClick', @this.onUiButtonClearPrescriptions ...
            );
        
            this.uiButtonClearWafer = mic.ui.common.Button(...
                'cText', 'Clear Wafer', ...
                'fhOnClick', @this.onUiButtonClearWafer ...
            );
        
            this.uibNewWafer = mic.ui.common.Button(...
                'cText', 'New', ...
                'fhOnClick', @this.onUiButtonNewWafer ...
            );
            this.uibAddToWafer = mic.ui.common.Button(...
                'cText', 'Add To Wafer', ...
                'fhOnClick', @this.onAddToWafer ...
            );
            % Prints from "Added" list
            this.uibPrint = mic.ui.common.Button(...
                'cText', 'Print', ...
                'fhOnClick', @this.onClickPrintActive ...
            );
        
            % Prints from "Saved Prescriptions" list
            this.uibPrintSaved = mic.ui.common.Button(...
                'cText', 'Print', ...
                'fhOnClick', @this.onClickPrintSaved ...
            );
        
            this.uiListActive = mic.ui.common.List(...
                'ceOptions', cell(1,0), ...
                'cLabel', 'Added prescriptions', ...
                'fhDirectCallback', @this.onListActiveChange, ...
                'lShowDelete', false, ...
                'lShowMove', false, ...
                'lShowLabel', true, ...
                'lShowRefresh', false ...
            );
            this.uicWaferLL = mic.ui.common.Checkbox(...
                'lChecked', false, ...
                'cLabel', 'Wafer to LL when done' ...
            );
            this.uicAutoVentAtLL = mic.ui.common.Checkbox(...
                'lChecked', false, ...
                'cLabel', 'Auto vent wafer at LL' ...
            );
            
            %{
            this.uibScanStart = mic.ui.common.Button( ...
                'cText', 'Start' ...
            );
        
            this.uitScanPause = mic.ui.common.Toggle( ...
                'cTextFalse', 'Pause', ...
                'cTextTrue', 'Resume' ...
            );
            
            this.uibScanAbort = mic.ui.common.Button(...
                'cText', 'Abort', ...
                'lAsk', true, ...
                'cMsg', 'The scan is now paused.  Are you sure you want to abort?' ... 
            );
            
            addlistener(this.uibScanAbort, 'ePress', @this.onButtonPressScanAbort);
            addlistener(this.uibScanAbort, 'eChange', @this.onButtonScanAbort);
            addlistener(this.uitScanPause, 'eChange', @this.onButtonScanPause);
            addlistener(this.uibScanStart, 'eChange', @this.onButtonScanStart);
            %}
            
            this.uiScan = mic.ui.Scan(...
                'dWidthBorderPanel', 0, ...
                'dWidth', this.dWidthUiScan, ...
                'cTitle', '', ...
                'dWidthButton', this.dWidthButton, ...
                'dHeightPadPanel', 0, ...
                'dWidthPadPanel', 0 ...
            );
            addlistener(this.uiScan, 'eStart', @this.onUiScanStart);
            addlistener(this.uiScan, 'ePause', @this.onUiScanPause);
            addlistener(this.uiScan, 'eResume', @this.onUiScanResume);
            addlistener(this.uiScan, 'eAbort', @this.onUiScanAbort);
            
            
            this.initScanSetContract();
            this.initScanAcquireContract();
            
            %{
            this.uiEditMjPerCm2PerSec = mic.ui.common.Edit(...
                'cLabel', 'mJ/cm2/s', ...
                'cType', 'd' ...
            );
            this.uiEditMjPerCm2PerSec.set(10);
            this.uiEditMjPerCm2PerSec.setMin(0);
            this.uiEditMjPerCm2PerSec.setMax(1e5);
            %}
            
             this.uiShutter = bl12014.ui.Shutter(...
                'cName', [this.cName, 'shutter'], ...
                'hardware', this.hardware, ...
                'clock', this.clock, ...
                'uiClock', this.uiClock ...
            );
        
            this.uiFluxDensity = bl12014.ui.FluxDensity(...
                'uiClock', this.uiClock, ...
                'clock', this.clock, ...
                'hardware', this.hardware, ...
                'uiShutter', this.uiShutter, ...
                'uiTuneFluxDensity', this.uiTuneFluxDensity ...
            );
            
            
            this.uiEditRowStart = mic.ui.common.Edit(...
                'cLabel', 'Row Start', ...
                'cType', 'u8' ...
            );
            this.uiEditRowStart.set(uint8(1));
            this.uiEditRowStart.setMin(uint8(0));
            
            this.uiEditColStart = mic.ui.common.Edit(...
                'cLabel', 'Col Start', ...
                'cType', 'u8' ...
            );
            this.uiEditColStart.set(uint8(1));
            this.uiEditColStart.setMin(uint8(0));
            
            
           
            
            
            this.uiWaferAxes = bl12014.ui.WaferAxes(...
                'cName', [this.cName, 'wafer-axes'], ...
                'dWidth', 750, ...
                'dHeight', 750, ...
                'clock', this.uiClock, ...
                'fhGetIsShutterOpen', @() this.uiShutter.uiOverride.get(), ...
                'waferExposureHistory', this.waferExposureHistory, ...
                ...
                'fhGetVibX', @() this.dRmsDriftX, ...
                'fhGetVibY', @() this.dRmsDriftY, ...
                'fhGetIsVib', @() this.lIsVib, ...
                ...
                'fhGetVelX', @() this.dVelXOfAI, ...
                'fhGetVelY', @() this.dVelYOfAI, ...
                'fhGetIsVel', @() this.lIsWaitingForVelOfAIToSettle, ...
                ...
                'fhGetAccX', @() this.dAccXOfAI, ...
                'fhGetAccY', @() this.dAccYOfAI, ...
                'fhGetIsAcc', @() this.lIsWaitingForAccOfAIToSettle, ...
                ...
                'fhGetIsWFZ', @() this.lIsWFZ, ...
                'fhGetIsDriftControl', @() this.uiWafer.uiWorkingMode.uiWorkingMode.getValCalDisplay() == 4, ...
                'fhGetXOfWafer', @() this.uiWafer.uiCoarseStage.uiX.getValCal('mm') / 1000, ...
                'fhGetYOfWafer', @() this.uiWafer.uiCoarseStage.uiY.getValCal('mm') / 1000, ...
                'fhGetXOfLsi', @() this.uiWafer.uiLsiCoarseStage.uiX.getValCal('mm') / 1000 ...
            );
        
            this.uiReticleAxes = bl12014.ui.ReticleAxes(...
                'cName', [this.cName, 'reticle-axes'], ...
                'dWidth', 350, ...
                'dHeight', 350, ...
                'clock', this.uiClock, ...
                'fhGetIsShutterOpen', @() this.uiShutter.uiOverride.get(), ...
                'fhGetX', @() this.uiReticle.uiCoarseStage.uiX.getValCal('mm') / 1000, ...
                'fhGetY', @() this.uiReticle.uiCoarseStage.uiY.getValCal('mm') / 1000 ...
            );
            
        
            this.uiPrescriptionTool = bl12014.ui.PrescriptionTool();
            
            
            %{
            this.uiPOCurrent = bl12014.ui.POCurrent(...
                'cName', [this.cName, 'po-current'], ...
                'hardware', this.hardware, ...
                'clock', this.clock, ...
                'dWidth', 780, ...
                'dHeight', 400 ...
            );
            %}
            
            
            this.uiSequenceLevelWafer = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-level-wafer'], ...
                'task', bl12014.Tasks.createSequenceLevelWafer(...
                    [this.cName, 'task-sequence-level-wafer'], ...
                    this.uiWafer.uiWaferTTZClosedLoop, ...
                    ...% this.uiWafer.uiWaferTTZClosedLoopuiHeightSensorLEDs, ...
                    this.clock ...
                 ), ...
                'clock', this.uiClock ...
            );
        
            
        
            this.uiSequenceLevelReticle = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-level-reticle'], ...
                'task', bl12014.Tasks.createSequenceLevelReticle(...
                    [this.cName, 'task-sequence-level-reticle'], ...
                    this.uiReticle.uiReticleTTZClosedLoop, ...
                    this.clock ...
                 ), ...
                'clock', this.uiClock ...
            );
        
            this.uiStateM142ScanningDefault = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-sequence-set-m142-to-default'], ...
                'task', bl12014.Tasks.createSequenceSetM142ToDefault(...
                    [this.cName, 'sequence-set-m142-to-default'], ...
                    this.uiScannerM142, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateUndulatorIsCalibrated = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-undulator-is-calibrated'], ...
                'task', bl12014.Tasks.createStateUndulatorIsCalibrated(...
                    [this.cName, 'state-undulator-is-calibrated'], ...
                    this.uiTuneFluxDensity, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
        
            this.uiStateMonoGratingAtEUV = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-mono-grating-at-euv'], ...
                'task', bl12014.Tasks.createStateMonoGratingAtEUV(...
                    [this.cName, 'state-mono-grating-at-euv'], ...
                    this.uiBeamline.uiGratingTiltX, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateEndstationLEDsOff = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-endstation-leds-off'], ...
                'task', bl12014.Tasks.createStateEndstationLEDsOff(...
                    [this.cName, 'state-endstation-leds-off'], ...
                    this.hardware, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateVPFMOut = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-vpfm-out'], ...
                'task', bl12014.Tasks.createStateVPFMOut(...
                    [this.cName, 'state-vpfm-out'], ...
                    this.hardware, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
        this.uiStateSR570MDMIsSet = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-sr570-mdm-is-set'], ...
                'task', bl12014.Tasks.createStateSR570MDMIsSet(...
                    [this.cName, 'state-sr570-mdm-is-set'], ...
                    this.hardware, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateM141SmarActOff = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-m141-smaract-off'], ...
                'task', bl12014.Tasks.createStateM141SmarActOff(...
                    [this.cName, 'state-m141-smaract-off'], ...
                    this.hardware, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateExitSlitIsCalibrated = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-exit-slit-is-calibrated'], ...
                'task', bl12014.Tasks.createStateExitSlitIsCalibrated(...
                    [this.cName, 'state-exit-slit-is-calibrated'], ...
                    this.uiTuneFluxDensity, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateHeightSensorLEDsOn = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-height-sensor-leds-on'], ...
                'task', bl12014.Tasks.createStateHeightSensorLEDsOn(...
                    [this.cName, 'state-height-sensor-leds-on'], ...
                    this.uiHeightSensorLEDs, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStatePowerPmacAccelSetForFEM = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-power-pmac-accel-set-for-fem'], ...
                'task', bl12014.Tasks.createStatePowerPmacAccelSetForFEM(...
                    [this.cName, 'state-power-pmac-accel-set-for-fem'], ...
                    this.hardware, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        

            this.uiTextReticleField = mic.ui.common.Text(...
                'cVal', 'Reticle Field: [--, --]' ...
            );
        
            
        
            try
                this.hDYMO =  bl12014.hardwareAssets.middleware.DymoLabelWriter450();
            catch
                this.msg('DYMO labelwriter failed to initialize!!', this.u8_MSG_TYPE_SCAN);
            end
            
            this.uiTextTimeCalibrated = mic.ui.common.Text(...
                'cVal', 'Last Calibration:');
            this.uiTextFluxDensityCalibrated = mic.ui.common.Text(...
                'cVal', 'Flux Density: ');
            
            this.uiClock.add(@this.onClock, this.id(), 1);
            
            
            this.uiSequenceRecoverFem = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-sequence-recover-fem'], ...
                'task', this.createSequenceRecoverFem(), ...
                'lShowIsDone', false, ...
                'clock', this.uiClock ...
            );
        
        
            this.uiFocusLog = bl12014.ui.FocusLog( ...
                'uiClock', this.uiClock, ...
                'dWidth', 400, ...
                'dHeight', 330, ...
                'dNumResults', 20);
            
            this.uiDoseMonitorList = mic.ui.common.List(...
                'lShowMove', false, ...
                'lShowRefresh', false, ...
                'lShowDelete', false, ...
                'cLabel', 'MDM (num of e-)' ...
                );
            
            this.initCurrentOfALS();
                                   
        end
        
        
        function initCurrentOfALS(this)
            
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-current-of-ring.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            ); 
            this.uiCurrentOfALS = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'dWidthName', 50, ...
                'dWidthVal', 50, ...
                'lShowLabels', false, ...
                'lShowInitButton', false, ...
                ...'fhGet', @() this.hardware.getDCTCorbaProxy().SCA_getBeamCurrent(), ...
                'fhGet', @() this.hardware.getALS().getCurrentOfRing(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'current-of-ring'], ...
                'config', uiConfig, ...
                'cLabel', 'ALS mA' ...
            );
        
        end

        
        
        
        function initScanTimingStore(this)
            ceFields = {...
                'tracking', ...
                'settle', ... % vibration settle from DMI
                'pause', ...
                'pupilFill', ...
                'reticleX', ...
                'reticleY', ...
                'waferX', ...
                'waferY', ...
                'waferZ', ...
                'waferZThenDriftControl', ...
                'xReticleFine', ...
                'yReticleFine', ...
                'workingMode', ...
                'shutter', ...
                'smsSlowShutter', ...
            };

            for n = 1 : length(ceFields)
                this.stScanTimingStore.(ceFields{n}) = 0;
            end
        end
        function initScanSetContract(this)
            
             ceFields = {...
                'tracking', ...
                'settle', ... % vibration settle from DMI
                'waitForAccOfAIToSettle', ...
                'waitForVelOfAIToSettle', ...
                'fadeY', ...
                'stopFadeY', ...
                'pause', ...
                'pupilFill', ...
                'reticleX', ...
                'reticleY', ...
                'waferX', ...
                'waferY', ...
                'waferZ', ...
                'waferZThenDriftControl', ...
                'smsSlowShutter', ... % 2022.01
                'xReticleFine', ...
                'yReticleFine', ...
                'workingMode', ...
            };

            for n = 1 : length(ceFields)
                this.stScanSetContract.(ceFields{n}).lRequired = false;
                this.stScanSetContract.(ceFields{n}).lIssued = false;
                this.stScanSetContract.(ceFields{n}).lAchieved = false;
            end
            
        end
        
        function initScanAcquireContract(this)
            
            ceFields = {...
                'shutter'
            };

            for n = 1 : length(ceFields)
                this.stScanAcquireContract.(ceFields{n}).lRequired = false;
                this.stScanAcquireContract.(ceFields{n}).lIssued = false;
            end
            
        end
        
        % For every field of this.stScanSetContract, set its lSetRequired and 
        % lSetIssued properties to false
        function resetScanSetContract(this)
            
            ceFields = fieldnames(this.stScanSetContract);
            for n = 1 : length(ceFields)
                this.stScanSetContract.(ceFields{n}).lRequired = false;
                this.stScanSetContract.(ceFields{n}).lIssued = false;
                this.stScanSetContract.(ceFields{n}).lAchieved = false;
            end
            
        end
        
        function resetScanTimingStore(this)
            ceFields = fieldnames(this.stScanTimingStore);
            for n = 1 : length(ceFields)
                this.stScanTimingStore.(ceFields{n}) = 0;
            end
            
        end
        
        function resetScanAcquireContract(this)
            
            ceFields = fieldnames(this.stScanAcquireContract);
            for n = 1 : length(ceFields)
                this.stScanAcquireContract.(ceFields{n}).lRequired = false;
                this.stScanAcquireContract.(ceFields{n}).lIssued = false;
                this.stScanAcquireContract.(ceFields{n}).lAchieved = false;
            end
            
        end
        
        %{
        function onButtonScanStart(this, src, evt)
            
            this.msg('onButtonScanStart');
            
            this.hideScanStart();
            this.showScanPauseAbort();
            this.startNewScan();
                       
        end
        
        function onButtonScanPause(this, ~, ~)
        
            if (this.uitScanPause.get()) % just changed to true, so was playing
                this.scan.pause();
            else
                this.scan.resume();
            end
        end
        
        function onButtonPressScanAbort(this, ~, ~)
            this.scan.pause();
            this.uitScanPause.set(true);
        end
        
        function onButtonScanAbort(this, ~, ~)
            this.scan.stop(); % calls onScanAbort()
        end
        
        %}
        
        
        function onUiScanStart(this, src, evt)
            this.msg('onUiScanStart');
            this.startNewScan();
        end
        
        function onUiScanPause(this, ~, ~)
            
            if isempty(this.scan)
                return
            end
            
            this.scan.pause();
            this.updateUiScanStatus()
        end
        
        function onUiScanResume(this, ~, ~)
            
            if isempty(this.scan)
                return
            end
            
            this.scan.resume();
            this.updateUiScanStatus()

        end
        
        function onUiScanAbort(this, ~, ~)
            
            if isempty(this.scan)
                return
            end
            this.scan.stop(); % calls onScanAbort()
        end
        
        
        function printRecipe(this, stRecipe, cFile)
            
            % build strings:
            cFEMSize        = sprintf('%d(F) x %d(D)', stRecipe.fem.u8FocusNum, stRecipe.fem.u8DoseNum);
            ceWaferID        = regexp(cFile, '(?<=\\)\w*\d+\-\d+','match');
            cWaferID        = ceWaferID{1};
            cFocusString    = sprintf('%g / %g', stRecipe.fem.dFocusCenter, stRecipe.fem.dFocusStep);
            cDoseString     = sprintf('%g / %g', stRecipe.fem.dDoseCenter, stRecipe.fem.dDoseStep);
            cPosString = sprintf('(%g,%g)[%g,%g]', ...
                stRecipe.fem.dPositionStartX, ...
                stRecipe.fem.dPositionStartY, ...
                stRecipe.fem.dPositionStepX, ...
                stRecipe.fem.dPositionStepY ...
            );
            cPEB            = sprintf('%sC / %ssec', stRecipe.process.dResistPebTemp, stRecipe.process.dResistPebTime);
            cDev            = sprintf('%s,%ssec/%s,%ssec', stRecipe.process.cDevName, stRecipe.process.dDevTime, ...
                                                  stRecipe.process.cRinseName, stRecipe.process.dRinseTime);
            [cPathPre, cNamePre, cExtPre] = fileparts(cFile);
            
            if length(cNamePre) > 20
                cNamePre = cNamePre(1:20)
            end
            
            % Set fields:
            % Not setting all fields here, can still set the following:
            % cPrescription,
            % cIllumination
            this.hDYMO.setField(...
                'cFemPos', cPosString, ...
                'cPrescription', cWaferID, ...
                'cSublayer', 'Si', ...
                'cResistThickness', stRecipe.process.dResistThick, ...
                'cIllumination', '', ...
                'cField', this.getTextReticleField(), ...
                'cWaferID', stRecipe.process.cUser, ...
                'cSize',    cFEMSize, ...
                'cDose',    cDoseString, ...
                'cFocus',   cFocusString, ...
                'cPEB',     cPEB, ...
                'cDev',     cDev, ...
                'cResist',  stRecipe.process.cResistName...
            )
        
            this.hDYMO.printLabel();
            
        end
        
        
        
        
        function onClickPrintActive(this, ~, ~)
            this.msg('Printing label on DYMO', this.u8_MSG_TYPE_SCAN);
           
            if isempty(this.hDYMO)
                msgbox('Cannot print label because DYMO failed to initialize');
                return
            end
            
            % Grab active prescriptions
            cFile = this.getPathRecipe();  
            [stRecipe, lError] = this.buildRecipeFromFile(cFile); 
            this.printRecipe(stRecipe, cFile);
            
            
        end
        
        function onClickPrintSaved(this, ~, ~)
            this.msg('Printing label on DYMO', this.u8_MSG_TYPE_SCAN);
           
            if isempty(this.hDYMO)
                msgbox('Cannot print label because DYMO failed to initialize');
                return
            end
            
            % Grab active prescriptions
            
            ceSelected = this.uiPrescriptionTool.uiListPrescriptions.get();
            
            if isempty(ceSelected)
                % Show alert
                
                cMsg = sprintf('Please select a prescription to print');
                cTitle = 'No prescription selected';
                msgbox(cMsg, cTitle, 'warn')    
                
                return
            end

            cFile = fullfile(this.uiPrescriptionTool.uiListPrescriptions.getDir(), ceSelected{1});
            [stRecipe, lError] = this.buildRecipeFromFile(cFile); 
            this.printRecipe(stRecipe, cFile);
            
            
        end
        
        function onUiButtonNewWafer(this, src, evt)
            
            % Purge all items from uiListActive
            this.uiListActive.setOptions(cell(1,0));
            
            this.waferExposureHistory.deleteExposures();
            this.waferExposureHistory.deleteFemPreviewScan();
            
        end
        
        function onUiButtonClearWafer(this, src, evt)
            
            
            
            this.waferExposureHistory.deleteExposures();
            this.waferExposureHistory.deleteFemPreviewScan();
            
        end
        
        function onUiButtonClearPrescriptions(this, src, evt)
            
            this.uiListActive.setOptions(cell(1,0));
            this.waferExposureHistory.deleteFemPreviewScan();

        end
        
        function onListActiveChange(this)
            
            this.addFemPreviewOfAllAddedPrescriptionsToWaferExposureHistory();
            
        end
        
        
        
        function onAddToWafer(this, src, evt)
                        
            % For all prescriptions highlihged when the user clicks 
            % "add to wafer", add them to ListActive 
            
            % ceSelected = this.uiListPrescriptions.get();
            
            ceSelected = this.uiPrescriptionTool.uiListPrescriptions.get();
            
            for k = 1:length(ceSelected)
                this.uiListActive.append(ceSelected{k});
            end
            
            % 2022.03.21 reset start row/col any time a new pre is added
            
            this.uiEditColStart.set(uint8(1));
            this.uiEditRowStart.set(uint8(1));
           
            this.addFemPreviewOfAllAddedPrescriptionsToWaferExposureHistory();
            
            
            
            
           
            
        end 
        
        function addFemPreviewOfAllAddedPrescriptionsToWaferExposureHistory(this)
            
            % Loop through all selected prescriptions and push them to the
            % active list
            
            this.waferExposureHistory.deleteFemPreviewScan();
            ceOptions = this.uiListActive.getOptions();
            for k = 1:length(ceOptions)
                
                % Read file, build recipe
                cFile = fullfile(this.uiPrescriptionTool.uiListPrescriptions.getDir(), ceOptions{k});
                [stRecipe, lError] = this.buildRecipeFromFile(cFile);
                
                [dX, dY] = this.getFemGrid(...
                    stRecipe.fem.dPositionStartX, ...
                    stRecipe.fem.dPositionStepX, ...
                    stRecipe.fem.u8DoseNum, ...
                    stRecipe.fem.dPositionStartY, ... 
                    stRecipe.fem.dPositionStepY, ...
                    stRecipe.fem.u8FocusNum ...
                );
                this.waferExposureHistory.addFemPreviewScan(dX, dY);
                    
            end
            
            
        end
        
        
        function [stRecipe, lError] = buildRecipeFromFile(this, cPath)
           
            cMsg = sprintf('buildRecipeFromFile: %s', cPath);
            this.msg(cMsg);
            
            lError = false;
            
            if strcmp('', cPath) || ...
                isempty(cPath)
                % Has not been set
                lError = true;
                stRecipe = struct();
                return;
            end
                        
            if exist(cPath, 'file') ~= 2
                % File doesn't exist
                lError = true;
                stRecipe = struct();
                
                cMsg = sprintf(...
                    'The recipe file %s does not exist.', ...
                    cPath ...
                );
                cTitle = sprintf('Error reading recipe');
                msgbox(cMsg, cTitle, 'warn')
                
                return;
            end
            
            % File exists
            
            %{
            cStatus = this.uitxStatus.cVal;
            this.uitxStatus.cVal = 'Reading recipe ...';
            drawnow;
            %}
            
            % stRecipe = loadjson(cPath);
            fid = fopen(cPath, 'r');
            cText = fread(fid, inf, 'uint8=>char');
            fclose(fid);
            stRecipe = jsondecode(cText');
            
            % this.uitxStatus.cVal = cStatus;
            
            if ~this.validateRecipe(stRecipe)
                lError = true;
                return;
            end

        end
            
        function d = getStageXFromWaferX(this, x)
            d = x + this.uiWafer.uiAxes.dXChiefRay * 1e3; % mm
        end
        
        function d = getStageYFromWaferY(this, y)
            d = y + this.uiWafer.uiAxes.dYChiefRay * 1e3; % mm
        end
        
        
        

        
        function startDriftControl(this, src, evt)
            
                                       
           % 2021.10 
           % Immediately start tracking and set
           % working mode to 4.  There will be
           % another task to verify that
           % working mode is set to 4

           this.hardware.getMfDriftMonitor().monitorStart();

            % issue CommandCode 6 before going to wm4 -
            % this would kill hydra closed loop (which they
            % theory is this causes a jump) before drift
            % control takes effect.
            this.hardware.getDeltaTauPowerPmac().sendCommandCode(uint8(6));
            this.uiWafer.uiWorkingMode.uiWorkingMode.setDestCalDisplay(4); 
            this.uiWafer.uiWorkingMode.uiWorkingMode.moveToDest(); 
            
            this.msg('startDriftControl');
                                   
        end
        
        
        
        
        
        function onScanSetState(this, stUnit, stValue)
            
            cFn = 'onScanSetState';
            lDebug = true;
            this.resetScanSetContract();
            this.dTicScanSetState = tic;
            
            % Update the stScanSetContract properties listed in stValue 
            
            ceFields = fieldnames(stValue);
            for n = 1 : length(ceFields)
                switch ceFields{n}
                    case {'task', 'type'}
                        % Do nothing
                    otherwise
                        this.stScanSetContract.(ceFields{n}).lRequired = true;
                        this.stScanSetContract.(ceFields{n}).lIssued = false;
                end
            end
            
            % Setting the state programatically does
            % exactly what would happen if the user were to do it manually
            % with the UI. I.E., we programatically update the UI and
            % programatically "click" UI buttons.
            
            for n = 1 : length(ceFields)
                
                cField = ceFields{n};
                
                if lDebug
                    this.msg(sprintf('%s setting %s', cFn, cField), this.u8_MSG_TYPE_SCAN);
                end
                                
                switch cField
                    
                    case 'waitForAccOfAIToSettle'
                         this.stScanSetContract.waitForAccOfAIToSettle.lIssued = true;
                        this.lIsWaitingForAccOfAIToSettle = true;
                     case 'waitForVelOfAIToSettle'
                         this.stScanSetContract.waitForVelOfAIToSettle.lIssued = true;
                        this.lIsWaitingForVelOfAIToSettle = true;
                        
                    case 'settle'
                        
                        %{
                        dTimeStart = tic;
                        
                        if isfield(stValue.settle, 'value')
                            dValue = stValue.settle.value;
                        else
                            dValue = 1.0;
                        end
                        
                        if isfield(stValue.settle, 'time')
                            dTime = stValue.settle.time;
                        else
                            dTime = 120;
                        end
                        
                        
                        [dRmsX, dRmsY] = this.getVibrationOfDmi();
                        
                        
                        while dRmsX > dValue || dRmsY > dValue
                            
                            dTimeElapsed = toc(dTimeStart);
                            [dRmsX, dRmsY] = this.getVibrationOfDmi();
                            
                            cMsg = [...
                                sprintf('%s DMI vib settling to %1.2f nm RMS: ', cFn, dValue), ...
                                sprintf('driftX = %1.2f nm RMS, driftY = %1.2f nm RMS ', dRmsX, dRmsY), ...
                                sprintf('(%1.1f sec elapsed)',dTimeElapsed) ...
                            ];
                        
                            if lDebug
                                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                            end
                        
                            pause(1);
                            
                            if (dTimeElapsed > dTime)
                               cMsg = sprintf('%s DMI vib settle TOOK TOO LONG > %1.1f sec!!', ...
                                   cFn, ...
                                   dTime);
                               if lDebug
                                    this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                               end 
                               break; % break out of while loop
                            end
                            
                            if this.scan.getIsPaused() || this.scan.getIsStopped()
                                
                                cMsg = [...
                                    sprintf('%s Aborting DMI settling at: ', cFn), ...
                                    sprintf('driftX = %1.2f nm RMS, driftY = %1.2f nm RMS ', dRmsX, dRmsY), ...
                                    sprintf('(%1.1f sec elapsed)',dTimeElapsed) ...
                                ];

                                if lDebug
                                    this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                end
                                
                                break; % break out of while loop
                            end
                                
                        end
                        %}
                        this.stScanSetContract.settle.lIssued = true;
                        this.lIsVib = true;
                        
                    
                    case 'pause'
                        
                        dTimeStart = tic;
                        dTimeElapsed = 0;

                        while dTimeElapsed < stValue.pause
                            dTimeElapsed = toc(dTimeStart);
                            pause(1);
                            fprintf('bl12014.ui.Scan.onScanSetState() pausing %1.1f sec of %1.1f sec\n', ...
                                dTimeElapsed, ...
                                stValue.pause ...
                            );
                        
                            if this.scan.getIsPaused() || this.scan.getIsStopped()
                                break
                            end
                            
                        end
                        this.stScanSetContract.pause.lIssued = true;
                    
                    case 'tracking'
                        
                        
                        switch stValue.tracking
                            case 'start'
                                this.hardware.getMfDriftMonitor().monitorStart();
                            case 'stop'
                                this.hardware.getMfDriftMonitor().monitorStop();
                        end
                        
                        this.stScanSetContract.tracking.lIssued = true;
                        
                    case 'smsSlowShutter'
                        this.hardware.getSMS().setBeamlineOpen(stValue.smsSlowShutter);
                        this.stScanSetContract.smsSlowShutter.lIssued = true;
                        
                    case 'fadeY'
                        
                        dSec = stValue.fadeY.dose / this.uiFluxDensity.get();
                        this.setReticleFineYForImageFade(stValue.fadeY.value, dSec);
                        this.stScanSetContract.fadeY.lIssued = true;
                        
                    case 'stopFadeY'
                        
                        this.stopReticleFineStageAndResetSpeed();
                        this.stScanSetContract.stopFadeY.lIssued = true;
                     
                    case 'workingMode'
                        
                        if this.lSkipWorkingMode
                            this.stScanSetContract.workingMode.lIssued = true;
                            return
                        end
                        
                        if stValue.workingMode == 4
                            % issue CommandCode 6 before going to wm4 -
                            % this would kill hydra closed loop (which they
                            % theory is this causes a jump) before drift
                            % control takes effect.
                            this.hardware.getDeltaTauPowerPmac().sendCommandCode(uint8(6));
                        end
                        
                        this.uiWafer.uiWorkingMode.uiWorkingMode.setDestCalDisplay(stValue.workingMode); 
                        this.uiWafer.uiWorkingMode.uiWorkingMode.moveToDest();
                        this.stScanSetContract.workingMode.lIssued = true;
                          
                    case 'xReticleFine'
                        
                        this.uiReticle.uiFineStage.uiX.setDestCalAndGo(stValue.xReticleFine, 'um');
                        this.stScanSetContract.xReticleFine.lIssued = true;
                    
                    case 'yReticleFine'
                        
                        this.uiReticle.uiFineStage.uiY.setDestCalAndGo(stValue.yReticleFine, 'um');
                        this.stScanSetContract.yReticleFine.lIssued = true;
                        
                    case 'waferX'
                        
                        % The FEM is constructed with positions relative to
                        % the center of the wafer in mm.  
                        % We need to tell the stage
                        % where to go to to make sure the EUV is at this 
                        % location on the wafer. Use
                        % uiWafer.uiAxes.dXChiefRay (mm)
                        % uiWafer.uiAxes.dYChiefRay (mm)
                        % to offset the stage correctly
                                    
                        dX = this.getStageXFromWaferX(stValue.waferX); % mm
                        this.uiWafer.uiCoarseStage.uiX.setDestCalDisplay(dX, 'mm');
                        this.uiWafer.uiCoarseStage.uiX.moveToDest(); % click
                        this.stScanSetContract.waferX.lIssued = true;
                        
                    case 'waferY'
                        
                        % See comment for waferX
                        
                        dY = this.getStageYFromWaferY(stValue.waferY); 
                        this.uiWafer.uiCoarseStage.uiY.setDestCalDisplay(dY, 'mm');
                        this.uiWafer.uiCoarseStage.uiY.moveToDest(); % click
                        this.stScanSetContract.waferY.lIssued = true;
                      
                    case {'waferZ', 'waferZThenDriftControl'}
                    
                        
                       
                        % this.uiWafer.uiFineStage.uiZ.setDestCalDisplay(
%                         this.uiWafer.uiHeightSensorZClosedLoop.uiZHeightSensor.setDestCalDisplay(stValue.waferZ, stUnit.waferZ);
%                         this.uiWafer.uiHeightSensorZClosedLoop.uiZHeightSensor.moveToDest();
%                         
                        
                        % Changed RM 12/2018 to new CL architecture:
                       this.stScanSetContract.(cField).lIssued = true;
                       this.dZHeightSensorTarget = stValue.(cField);
                        this.lIsWFZ = true;
                       
                        
                        %{
                        if strcmpi(cField, 'waferZThenDriftControl')
                            % update the 'onSetSuccess' callback of the
                            % CLZ controller so that we start drift control
                            % immediately after CLZ finishes, and not on 
                            % the next clock cycle of the scan sequence
                            this.uiWafer.uiWaferTTZClosedLoop.setOnSetSuccessCLZ(@this.startDriftControl)
                        else
                            this.uiWafer.uiWaferTTZClosedLoop.setOnSetSuccessCLZ(@(src,evt)[])

                        end
                        %}
                        
                        this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.setDestCalDisplay(stValue.(cField), stUnit.waferZ);
                        this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.moveToDest();
                        
                    
                        
                    case 'reticleX'
                        
                        % TEMPORARILY DONT MOVE 2018.04.19
                        % this.uiReticle.uiCoarseStage.uiX.setDestCalDisplay(dValue, cUnit);
                        % this.uiReticle.uiCoarseStage.uiX.moveToDest(); % click
                        this.stScanSetContract.(cField).lIssued = true;
                    
                    case 'reticleY'
                        
                        % this.uiReticle.uiCoarseStage.uiY.setDestCalDisplay(dValue, cUnit);
                        % this.uiReticle.uiCoarseStage.uiY.moveToDest(); % click
                        this.stScanSetContract.(cField).lIssued = true;
                    
                    case 'pupilFill'
                        % FIX ME
                        this.stScanSetContract.(cField).lIssued = true;
                        
                        %{

                        
                        % Load the saved structure associated with the pupil fill
                
                        cFile = fullfile( ...
                            this.cDirPupilFills, ...
                            stPre.uiPupilFillSelect.cSelected ...
                        );

                        if exist(cFile, 'file') ~= 0
                            load(cFile); % populates s in local workspace
                            stPupilFill = s;
                        else
                            this.abort(sprintf('Could not find pupilfill file: %s', cFile));
                            return;
                        end
                        if ~this.uiPupilFill.np.setWavetable(stPupilFill.i32X, stPupilFill.i32Y);

                            cQuestion   = ['The nPoint pupil fill scanner is ' ...
                                'not enabled and not scanning the desired ' ...
                                'pupil pattern.  Do you want to run the FEM anyway?'];

                            cTitle      = 'nPoint is not enabled';
                            cAnswer1    = 'Run FEM without pupilfill.';
                            cAnswer2    = 'Abort';
                            cDefault    = cAnswer2;

                            qanswer = questdlg(cQuestion, cTitle, cAnswer1, cAnswer2, cDefault);
                            switch qanswer
                                case cAnswer1;

                                otherwise
                                    this.abort('You stopped the FEM because the nPoint is not scanning.');
                                    return; 
                            end

                        end
                        %}
                        
                    otherwise
                        % do nothing
                        
                end % switch cField 
                
               
            end % loop through fields
        end
        
        
        
        
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the system is at the state


        function lOut = onScanIsAtState(this, stUnit, stValue)
            
            
            % The complexity of setState(), i.e., lots of 
            % series operations vs. one large parallel operation, dictates
            % how complex this needs to be.  I decided to implement a
            % general approach that will work for the case of complex
            % serial operations.  The idea is that each device (HIO) is
            % wrapped with a lSetRequired and lSetIssued {locical} property.
            %
            % The beginning of setState(), loops through all devices
            % that will be controlled and sets the lSetRequired flag ==
            % true for each one and false for non-controlled devices.  It also sets 
            % lSetIssued === false for all controlled devices.  
            %
            % Once a device move is commanded, the lSetIssued flag is set
            % to true.  These two flags provide a systematic way to check
            % isAtState: loop through all devices being controlled and only
            % return true when every one that needs to be moved has had its
            % move issued and also has isThere / lReady === true.
            
            % Ryan / Antine you might know a better way to do this nested
            % loop / conditional but I wanted readability and debugginb so
            % I made it verbose
            
            this.updateUiScanStatus()
            
            
            cFn = 'onScanIsAtState';
            lDebug = true;           
            lOut = true;
                        
            ceFields= fieldnames(stValue);
            
            for n = 1:length(ceFields)
                
                cField = ceFields{n};
                
                switch cField
                    case {'task', 'type'}
                        continue;
                end               
                
                if this.stScanSetContract.(cField).lRequired
                    
                    if lDebug
                        %this.msg(sprintf('%s %s set is required', cFn, cField), this.u8_MSG_TYPE_SCAN);
                    end

                    if this.stScanSetContract.(cField).lIssued
                        
                        if lDebug
                            %this.msg(sprintf('%s %s set has been issued', cFn, cField), this.u8_MSG_TYPE_SCAN);
                        end
                        
                        if this.stScanSetContract.(cField).lAchieved
                            
                            if lDebug
                                %this.msg(sprintf('% %s set has been achieved', cFn, cField), this.u8_MSG_TYPE_SCAN);
                            end
                            
                            continue % no need to check this property
                        end
                        
                        % Check if the set operation is complete
                        
                        lReady = true;
                        
                        if ~isempty(stValue.(cField))
                            
                            switch cField
                                
                                case 'waitForAccOfAIToSettle'
                                    
                                    dTimeElapsed = toc(this.dTicScanSetState);

                                    % defaults
                                    dValue = 0.2; % nm/s/s
                                    lReady = false;
                                    
                                    % eventually maybe add to pre but
                                    % hard-code for now
                                    [dX, dY] = this.getAccelerationOfAerialImage();
                                    this.dAccXOfAI = dX;
                                    this.dAccYOfAI = dY;
                                    
                                    if abs(dX) < dValue && abs(dY) < dValue
                                        lReady = true;
                                    end

                                    if lDebug
                                        cMsg = [...
                                            sprintf('%s acc of AI settling to %1.2f nm RMS: ', cFn, dValue), ...
                                            sprintf('accX = %1.2f nm/s/s, accY = %1.2f nm/s/s ', dX, dY), ...
                                            sprintf('(%1.1f sec elapsed)',dTimeElapsed) ...
                                        ];
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    end 
                                    
                                    if lReady
                                        this.lIsWaitingForAccOfAIToSettle = false;
                                    end
                                    
                                    
                                case 'waitForVelOfAIToSettle'
                                    
                                    dTimeElapsed = toc(this.dTicScanSetState);

                                    % defaults
                                    
                                    dValueX = 0.8;
                                    dValueY = 0.5;
                                    lReady = false;
                                    
                                    
                                    
                                    % eventually maybe add to pre but
                                    % hard-code for now
                                    [dX, dY] = this.getVelocityOfAerialImage();
                                    this.dVelXOfAI = dX;
                                    this.dVelYOfAI = dY;
                                    
                                    if abs(dX) < dValueX && abs(dY) < dValueY
                                        lReady = true;
                                    end

                                    if lDebug
                                        cMsg = [...
                                            sprintf('%s velX/Y of AI settling to %1.2f/%1.2f nm RMS: ', cFn, dValueX, dValueY), ...
                                            sprintf('velX = %1.2f nm/s, velY = %1.2f nm/s ', dX, dY), ...
                                            sprintf('(%1.1f sec elapsed)',dTimeElapsed) ...
                                        ];
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    end  
                                    
                                    if lReady
                                        this.lIsWaitingForVelOfAIToSettle = false;
                                    end
                                    
                                
                                case 'settle' % high frequency vibration
                                    
                                    % defaults
                                    dValue = 1.0;
                                    dTime = 120; 
                                    lReady = false;
                                    dTimeElapsed = toc(this.dTicScanSetState);
                                    
                                    % override from prescription
                                    if isfield(stValue.settle, 'value')
                                        dValue = stValue.settle.value;
                                    end

                                    if isfield(stValue.settle, 'time')
                                        dTime = stValue.settle.time;
                                    end

                                    [dRmsX, dRmsY] = this.getVibrationOfDmi();
                                    this.dRmsDriftX = dRmsX;
                                    this.dRmsDriftY = dRmsY;

                                    % Check values
                                    if dRmsX < dValue && dRmsY < dValue
                                        lReady = true;
                                    end

                                    if lDebug
                                        cMsg = [...
                                            sprintf('%s DMI vib settling to %1.2f nm RMS: ', cFn, dValue), ...
                                            sprintf('driftX = %1.2f nm RMS, driftY = %1.2f nm RMS ', dRmsX, dRmsY), ...
                                            sprintf('(%1.1f sec elapsed)',dTimeElapsed) ...
                                        ];
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    end


                                    if (dTimeElapsed > dTime)
                                       cMsg = sprintf('%s DMI vib settle TOOK TOO LONG > %1.1f sec!!', ...
                                           cFn, ...
                                           dTime);
                                       if lDebug
                                            this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                       end 
                                       lReady = true;
                                    end
                                    
                                    if lReady
                                        this.lIsVib = false;
                                    end
                                
                                case 'fadeY'
                                    lReady = true; % assume it starts moving correctly immediately
                                case 'stopFadeY'
                                    lReady = true;
                                case 'pause'
                                    lReady = true;
                                case 'tracking'
                                    lReady = true; % happens instantaneously
                                    
                                case 'pupilFill'
                                    % FIX ME
                                    lReady = true;
                                    

                                case 'xReticleFine'
                                    lReady =    abs(this.uiReticle.uiFineStage.uiX.getValCal(stUnit.xReticleFine) - stValue.xReticleFine) <= this.dToleranceReticleFineX;
                                    
                                    if lDebug
                                        cMsg = sprintf('%s %s value = %1.3f; goal = %1.3f', ...
                                            cFn, ...
                                            cField, ...
                                            this.uiReticle.uiFineStage.uiX.getValCal(stUnit.xReticleFine), ...
                                            stValue.xReticleFine ...
                                        );
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    end
                                    
                                case 'yReticleFine'
                                    lReady =    abs(this.uiReticle.uiFineStage.uiY.getValCal(stUnit.yReticleFine) - stValue.yReticleFine) <= this.dToleranceReticleFineY;
                                    
                                    if lDebug
                                        cMsg = sprintf('%s %s value = %1.3f; goal = %1.3f', ...
                                            cFn, ...
                                            cField, ...
                                            this.uiReticle.uiFineStage.uiY.getValCal(stUnit.yReticleFine), ...
                                            stValue.yReticleFine ...
                                        );
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    end
                                    
                                case 'reticleX'
                                    lReady =    ... ~this.hardware.getDeltaTauPowerPmac().getIsStartedReticleCoarseXYZTipTilt();
                                                abs(this.uiReticle.uiCoarseStage.uiX.getValCal(stUnit.reticleX) - stValue.reticleX) <= this.dToleranceReticleX;
                                    
                                    if lDebug
                                        cMsg = sprintf('%s %s value = %1.3f; goal = %1.3f', ...
                                            cFn, ...
                                            cField, ...
                                            this.uiReticle.uiCoarseStage.uiX.getValCal(stUnit.reticleX), ...
                                            stValue.reticleX ...
                                        );
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    end
                                case 'reticleY'
                                    lReady =    ... ~this.hardware.getDeltaTauPowerPmac().getIsStartedReticleCoarseXYZTipTilt();
                                                abs(this.uiReticle.uiCoarseStage.uiY.getValCal(stUnit.reticleY) - stValue.reticleY) <= this.dToleranceReticleY;
                                            
                                    if lDebug
                                        cMsg = sprintf('%s %s value = %1.3f; goal = %1.3f', ...
                                            cFn, ...
                                            cField, ...
                                            this.uiReticle.uiCoarseStage.uiY.getValCal(stUnit.reticleY), ...
                                            stValue.reticleY ...
                                        );
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    end
                                case 'waferX'
                                    
                                    % auto-recover on stage timeout
                                    dTimeElapsed = toc(this.dTicScanSetState);
                                    if dTimeElapsed > 20 && ~this.lSkipWorkingMode
                                        % comment 2021.04.01
                                        this.uiSequenceRecoverFem.execute();
                                    end
                                    
                                    dGoal = this.getStageXFromWaferX(stValue.waferX);
                                    lReady =    ... ~this.hardware.getDeltaTauPowerPmac().getIsStartedWaferCoarseXYZTipTilt();
                                                abs(this.uiWafer.uiCoarseStage.uiX.getValCal(stUnit.waferX) - dGoal) <= this.dToleranceWaferX;
                                            
                                    if lDebug
                                        cMsg = sprintf('%s %s value = %1.3f; goal = %1.3f', ...
                                            cFn, ...
                                            cField, ...
                                            this.uiWafer.uiCoarseStage.uiX.getValCal(stUnit.waferX), ...
                                            dGoal ...
                                        );
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    end
                                case 'waferY'
                                    
                                    % auto recover on stage timeout
                                    dTimeElapsed = toc(this.dTicScanSetState);
                                    if (dTimeElapsed > 20)
                                        % comment 2021.04.01
                                        this.uiSequenceRecoverFem.execute();
                                    end
                                    
                                    dGoal = this.getStageYFromWaferY(stValue.waferY);
                                    lReady =    ...~this.hardware.getDeltaTauPowerPmac().getIsStartedWaferCoarseXYZTipTilt();
                                                abs(this.uiWafer.uiCoarseStage.uiY.getValCal(stUnit.waferY) - dGoal) <= this.dToleranceWaferY;
                                            
                                    if lDebug
                                        cMsg = sprintf('%s %s value = %1.3f; goal = %1.3f', ...
                                            cFn, ...
                                            cField, ...
                                            this.uiWafer.uiCoarseStage.uiY.getValCal(stUnit.waferY), ...
                                            dGoal ...
                                        );
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    end
                                case {'waferZ', 'waferZThenDriftControl'}
                                   lReady =     ... (   ~this.hardware.getDeltaTauPowerPmac().getIsStartedWaferCoarseXYZTipTilt() && ...
                                                ... ~this.hardware.getDeltaTauPowerPmac().getIsStartedWaferFineZ);
                                                ... this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.getDevice().isReady();
                                                this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.isReady();
                                                ...abs(this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.getValCal(stUnit.waferZ) - stValue.waferZ) <= this.dToleranceWaferZ;
                                                    
                                   
                                   if (lReady && strcmpi(cField, 'waferZThenDriftControl'))
                                       this.startDriftControl()
                                   end
                                   
                                   if lDebug
                                       
                                       dVal = this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.getValCal(stUnit.waferZ);
                                       dTarget = stValue.(cField);
                                       dError = dTarget - dVal;
                                        cMsg = sprintf('%s %s value = %1.3f; goal = %1.3f; error = %1.1f nm', ...
                                            cFn, ...
                                            cField, ...
                                            dVal, ...
                                            dTarget, ...
                                            dError ...
                                        );
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                   end
                                    
                                   % 2019.11.04 CNA this is where we want
                                   % to check the WFZ delta from the last
                                   % location and see if it seems
                                   % reasonable.  If not, do we throw up
                                   % a modal?
                                   
                                   lReasonable = this.checkWaferFineZDeltas();
                                   if lReady
                                       this.lIsWFZ = false;
                                   end

                                case 'smsSlowShutter'
                                    lVal = this.hardware.getSMS().getBeamlineOpen();
                                    lGoal = stValue.smsSlowShutter;
                                    lReady = lVal == lGoal;
                                    
                                    if lDebug
                                        cMsg = sprintf('%s %s value = %1.0f; goal = %1.0f', ...
                                            cFn, ...
                                            cField, ...
                                            lVal, ...
                                            lGoal ...
                                        );
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                        
                                    end
                                    
                                case 'workingMode'
                                    

                                    lReady = this.uiWafer.uiWorkingMode.uiWorkingMode.getValCalDisplay() == stValue.workingMode;
                                    % lReady = true; % 2020.09 asume that working mode changes to 4/5 are instantaneous
                                    
                                    if lDebug
                                        cMsg = sprintf('%s %s value = %1.0f; goal = %1.0f', ...
                                            cFn, ...
                                            cField, ...
                                            this.uiWafer.uiWorkingMode.uiWorkingMode.getValCalDisplay(), ...
                                            stValue.workingMode ...
                                        );
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    end
                                    
                                    
                                    % OVERRIDE HACK 2020.11.09
                                    if this.lSkipWorkingMode
                                        lReady = true;
                                    end



                                otherwise

                                    % UNSUPPORTED

                            end
                            
                        end
                        
                        
                        if lReady
                            
                            this.stScanSetContract.(cField).lAchieved = true;
                            
                            timeElapsed = toc(this.dTicScanSetState);
                            if isfield(this.stScanTimingStore, cField)
                                this.stScanTimingStore.(cField) = timeElapsed; % added 2020.09
                            end
                        	
                            if lDebug
                                cMsg = sprintf('%s %s set operation complete ELAPSED TIME = %1.3f sec', ...
                                    cFn, ...
                                    cField, ...
                                    toc(this.dTicScanSetState));
                                this.msg(...
                                    cMsg, ...
                                    this.u8_MSG_TYPE_SCAN ...
                                );
                            end
                            
 
                        else
                            % still isn't there.
                            if lDebug
                                %this.msg(sprintf('%s %s is still setting to %1.3f', cFn, cField, stValue.(cField)), this.u8_MSG_TYPE_SCAN);
                            end
                            lOut = false;
                            return;
                        end
                    else
                        % need to move and hasn't been issued.
                        if lDebug
                            %this.msg(sprintf('%s %s set not yet issued', cFn, cField), this.u8_MSG_TYPE_SCAN);
                        end
                        
                        lOut = false;
                        return;
                    end                    
                else
                    
                    if lDebug
                        this.msg(sprintf('%s %s N/A', cFn, cField), this.u8_MSG_TYPE_SCAN);
                    end
                   % don't need to move, this param is OK. Don't false. 
                end
            end
        end
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state (possibly contains 
        % information about the task to execute during acquire)
        % called after every state is reached
        function onScanAcquire(this, stUnit, stValue)
            
            this.dTicScanAcquire = tic;
            this.resetScanAcquireContract();
            
            % If stValue does not have a "task" or "action" prop, return
            
            if ~isfield(stValue, 'task')
                return
            end
            
            
            
            
            
            % Should eventually have a "type" property associated with the
            % task that can be switched on.  "type", "data" which is a
            % struct.  
            % 
            % One type would be "exposure"
            
            this.stScanAcquireContract.shutter.lRequired = true;
            this.stScanAcquireContract.shutter.lIssued = false;
            

            % Pause before the exposure to let resonant motion settle
            
            if isfield(stValue.task, 'pausePreExpose')
                
                dTimeStart = tic;
                dTimeElapsed = 0;
                
                while dTimeElapsed < stValue.task.pausePreExpose
                    dTimeElapsed = toc(dTimeStart);
                    pause(1);
                    fprintf('bl12014.ui.Scan.onScanAcquire() pausing %1.1f sec of %1.1f sec\n', ...
                        dTimeElapsed, ...
                        stValue.task.pausePreExpose ...
                    );
                end
            
            end            

            
            dSec = stValue.task.dose / this.uiFluxDensity.get();
            
            % Set the shutter UI time (ms)
            this.uiShutter.uiShutter.setDestCal(...
                dSec * 1e3, ...
                'ms' ...
            );
            % Trigger the shutter UI
            this.uiShutter.uiShutter.moveToDest();
            
           
            this.stScanAcquireContract.shutter.lIssued = true;
            
            
                
            
        end
        
        

        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the acquisition task is complete
        function lOut = onScanIsAcquired(this, stUnit, stValue)

            cFn = 'onScanIsAcquired';
            lDebug = true;           
            lOut = true;
            
            if ~isfield(stValue, 'task')
                return
            end
                        
            ceFields= fieldnames(this.stScanAcquireContract);
            
            for n = 1:length(ceFields)
                
                cField = ceFields{n};
                
                if this.stScanAcquireContract.(cField).lRequired
                    if lDebug
                        this.msg(sprintf('%s %s set is required', cFn, cField), this.u8_MSG_TYPE_SCAN);
                    end

                    if this.stScanAcquireContract.(cField).lIssued
                        
                        if lDebug
                            this.msg(sprintf('%s %s set has been issued', cFn, cField), this.u8_MSG_TYPE_SCAN);
                        end
                        
                        % Check if the set operation is complete
                        
                        lReady = true;
                        
                        switch cField
                            case 'shutter'
                                
                                dSec = stValue.task.dose / this.uiFluxDensity.get();

                                
                                if lDebug
                                    cMsg = sprintf('%s %s checking shutter: %1.1f mJ/cm2, %1.0f msec', ...
                                        cFn, ...
                                        cField, ...
                                        stValue.task.dose, ...
                                        dSec * 1000 ...
                                    );
                                    this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    
                                end
                                
                                % comment for commit.
                               
                               lReady = this.uiShutter.uiShutter.isReady();
                               
                               % 2022.05.17
                               % If the shutter and the photocurrent
                               % electrons are not virtualized, check the 
                               
                               if (lReady && ...
                                   this.hardware.getIsConnectedDoseMonitor() && ...
                                   this.hardware.getIsConnectedTekAFG31021())
                               
                                    charge_dose_monitor = this.hardware.getDoseMonitor().getCharge(this.hardware.getSR570MDM().getSensitivity());
    
                                    % If the charge is less than an
                                    % absolute lower bound, assume the shutter
                                    % failed to open.  Re-trigger the
                                    % shutter and say that lReady is false
                                    
                                    % If the charge is the same as the last
                                    % charge, assume the shutter failed to
                                    % open.
                                    
                                    if (...
                                        abs(charge_dose_monitor) < 5e6 || ...
                                        charge_dose_monitor == this.dChargeDoseMonitor ...
                                     )
                                        
                                        
                                        if lDebug
                                            cMsg = sprintf('%s %s abs(charge dose monitor) = %1.0f electrons < 5e6. SHUTTER FAILED TO OPEN.  Re-cycling', ...
                                                cFn, ...
                                                cField, ...
                                                charge_dose_monitor ...
                                            );
                                            this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    
                                        end
                                
                                        
                                        % Trigger the shutter UI again
                                        lReady = false;
                                        this.uiShutter.uiShutter.moveToDest();
                                    else
                                        % update chage dose monitor
                                        this.dChargeDoseMonitor = charge_dose_monitor;
                                    end
                                    
                               end
                                                                
                            otherwise
                                
                                % UNSUPPORTED
                                
                        end
                        
                        
                        if lReady
                                                        
                            timeElapsed = toc(this.dTicScanAcquire);
                            if isfield(this.stScanTimingStore, cField)
                                this.stScanTimingStore.(cField) = timeElapsed; % added 2020.09
                            end

                        	if lDebug
                                this.msg(sprintf('%s %s set complete', cFn, cField), this.u8_MSG_TYPE_SCAN);
                                
                                cMsg = sprintf('%s %s set operation complete ELAPSED TIME = %1.2f sec', ...
                                    cFn, ...
                                    cField, ...
                                    toc(this.dTicScanAcquire));
                                this.msg(...
                                    cMsg, ...
                                    this.u8_MSG_TYPE_SCAN ...
                                );
                            
                            end
 
                        else
                            % still isn't there.
                            if lDebug
                                this.msg(sprintf('%s %s set still setting', cFn, cField), this.u8_MSG_TYPE_SCAN);
                            end
                            lOut = false;
                            return;
                        end
                    else
                        % need to move and hasn't been issued.
                        if lDebug
                            this.msg(sprintf('%s %s set not yet issued', cFn, cField), this.u8_MSG_TYPE_SCAN);
                        end
                        
                        lOut = false;
                        return;
                    end                    
                else
                    
                    if lDebug
                        this.msg(sprintf('%s %s set is not required', cFn, cField), this.u8_MSG_TYPE_SCAN);
                    end
                   % don't need to move, this param is OK. Don't false. 
                end
            end
            
            if lOut
                
                % Store the state of the system
                stState = this.getState(stUnit);
                
                
                stState.vib_x_nm_rms = 0;
                stState.vib_y_nm_rms = 0;
                stState.drift_x_nm = 0;
                stState.drift_y_nm = 0;
                
                cPath = this.saveDmiHeightSensorDataFromExposure(stValue);
                
                % Update state with DMI data (vibration and drift)
                
                try
                    ceData = bl12014.MfDriftMonitorUtilities.getDataFromLogFile(cPath);
                    ceData = bl12014.MfDriftMonitorUtilities.removePartialsFromFileData(ceData);
                    dDmi = bl12014.MfDriftMonitorUtilities.getDmiPositionFromFileData(ceData);

                    stState.vib_x_nm_rms = std(dDmi(5, :));
                    stState.vib_y_nm_rms = std(dDmi(6, :));

                    dTime = [0 : length(dDmi(5, :)) - 1] * 1e-3;


                    % Do a linear fit and then do peak to valley
                    dCoeffX = polyfit(dTime, dDmi(5, :), 1);
                    dCoeffY = polyfit(dTime, dDmi(6, :), 1);

                    dFitX = polyval(dCoeffX, dTime);
                    dFitY = polyval(dCoeffY, dTime);

                    stState.drift_x_nm = max(dFitX) - min(dFitX);
                    stState.drift_y_nm = max(dFitY) - min(dFitY);
                    
                catch mE
                    
                end
                
                
                stState.dose_mj_per_cm2 = stValue.task.dose;
                
                % 2019.11.05 adding deltas of height sensor and WFZ to the
                % data store so it is easy to plot in the log plotter.
                if isempty(this.ceValues)
                    stState.dz_height_sensor_nm = 0;
                    stState.dz_wafer_fine_nm = 0;
                else
                    stState.dz_height_sensor_nm = stState.z_height_sensor_nm - this.ceValues{end}.z_height_sensor_nm;
                    stState.dz_wafer_fine_nm = stState.z_wafer_fine_nm - this.ceValues{end}.z_wafer_fine_nm;
                end
                
                % 2021.10.18 add the target height sensor value
                stState.z_height_sensor_target_nm = this.dZHeightSensorTarget;
                
                % 2021.10.18 store the error between the height sensor
                % value and the target
                dError = stState.z_height_sensor_nm - this.dZHeightSensorTarget;
                stState.z_height_sensor_error_nm = dError;
                
                
                if lDebug
                    this.msg(sprintf('%s height sensor z error %1.1f nm', cFn, dError), this.u8_MSG_TYPE_SCAN);
                end
                
                this.ceValues{end + 1} = stState;
                
                
                if lDebug
                    this.msg(sprintf('%s adding exposure to GUI', cFn), this.u8_MSG_TYPE_SCAN);
                end

                this.writeToLog('Finished task.');

                % Add an exposure to the plot
                %{
                dExposure = [ ...
                    stValue.waferX ...
                    stValue.waferY ...
                    stValue.task.femCol ...
                    stValue.task.femCols ...
                    stValue.task.femRow ...
                    stValue.task.femRows ...
                ]
                %}
                
                % Needs units of m
                
                % Could also use stValue.waferX / 1000, stValue.waferY / 1000
                dExposure = [
                    this.uiWafer.uiAxes.dXChiefRay - this.uiWafer.uiCoarseStage.uiX.getValCal('mm') / 1000 ...
                    this.uiWafer.uiAxes.dYChiefRay - this.uiWafer.uiCoarseStage.uiY.getValCal('mm') / 1000 ...
                    stValue.task.femCol ...
                    stValue.task.femCols ...
                    stValue.task.femRow ...
                    stValue.task.femRows ...
                ];
                this.waferExposureHistory.addExposure(dExposure);
                
                % add mdm electrons to log
                dVal = stState.charge_dose_monitor; % millions of electrons
                dVal = round(dVal);
                cVal = sprintf('%1.3e', dVal); %num2str(dVal);
                this.uiDoseMonitorList.append(cVal);
                
                ceOptions = this.uiDoseMonitorList.getOptions();
                this.uiDoseMonitorList.setSelectedIndexes(uint8(length(ceOptions)));
                
                
                                
                dTic = tic;
                this.saveScanResultsCsv(stUnit);
                dToc = toc(dTic);

                cMsg = sprintf('% saveScanResultsCsv() elapsed time = %1.3f', cFn, dToc);
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
            
                
                drawnow;
                
                % 2018.11.15  
                this.pauseScanIfCurrentOfALSIsTooLow()
                
                this.resetScanTimingStore();
                
                
            end
        end
        
        function pauseScanIfCurrentOfALSIsTooLow(this)
            
            if (...
                this.hardware.getIsConnectedALS && ...
                this.hardware.getALS().getCurrentOfRing() < 20 ...
            )
                
                this.scan.pause();
                cMsg = sprintf('The FEM was automatically paused because the current of the ALS dropped below 20 mA.');
                cTitle = 'FEM Auto Paused (Current of ALS low)';
                cIcon = 'help';
                h = msgbox(cMsg, cTitle, cIcon, 'modal');  
            end
            
        end
        
        % Check the change of the WFZ stage from the previous exposure site
        % to this one and make sure it seems reasonable.  If not, return
        % false.  During development, echo values. 
        function lOut = checkWaferFineZDeltas(this)
            
           lDebug = false;
           lOut = true;
           
           return; % 2022.06 
           
           dZWafer = [];
           dZHS = [];
           
           for n = 1 : length(this.ceValues)
                stValue = this.ceValues{n};
                if ~isstruct(stValue)
                    continue
                end
                dZWafer(end + 1) = stValue.z_wafer_fine_nm;
                dZHS(end + 1) = stValue.z_height_sensor_nm;
                
           end
           
           % append current value
           dZWafer(end + 1) = this.uiWafer.uiFineStage.uiZ.getValCal('nm');
           dZHS(end + 1) = this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.getValCal('nm');
           
           % create lists of deltas of the WFZ and the height sensor.  
           dDeltaWafer = zeros(1, length(dZWafer));
           dDeltaHS = zeros(1, length(dZWafer)); 
           if length(dZWafer) > 1
               for n = 2 : length(dZWafer)
                   dDeltaWafer(n - 1) = dZWafer(n) - dZWafer(n - 1);
                   dDeltaHS(n - 1) = dZHS(n) - dZHS(n - 1);
               end
           end
                      
               
           cMsg = sprintf("deltaWFZ minus deltaHS: the discrepancy between the WFZ and what the HS sees");
           this.msg(cMsg, this.u8_MSG_TYPE_INFO);
           dDeltaWafer - dDeltaHS;

           % find all indicies where the dDeltaHS is larger than some
           % minimum value, call it 5 nm.  Then take the average of all of
           % the delta wafers from those indicies. That should be
           cMsg = sprintf("delta wafer (nm) where a height sensor move was commanded");
           this.msg(cMsg, this.u8_MSG_TYPE_INFO);
           lMoved = abs(dDeltaHS) >= 5;
           dDeltaWafer(lMoved);
           
           
        end

        % Save 1 kHz DMI data collected during the shutter is open
        function cPath = saveDmiHeightSensorDataFromExposure(this, stValue)
            
            cPath = fullfile(...
                this.cDirScan, ... 
                this.getNameOfDmiHeightSensorLogFile(stValue) ...
            );
            
            try
                
                dTic = tic;
                dSec = stValue.task.dose / this.uiFluxDensity.get();           
                dSamples = round(dSec * 1000);
                
                this.uiMfDriftMonitorVibration.saveLastNSamplesToFile(dSamples, cPath)
                dToc = toc(dTic);
                
                cMsg = sprintf('saveDmiHeightSensorDataFromExposure elapsedTime = %1.3f\n', dToc);
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
            
            catch mE
                fprintf('saveDmiHeightSensorDataFromExposure error');
            end
            

        end
        
        function onScanAbort(this, stUnit)
             
             this.saveScanResultsCsv(stUnit);
             this.saveScanResultsJson(stUnit, true);
             this.abort();
             
             
             
        end


        function onScanComplete(this, stUnit)
            
             this.saveScanResultsCsv(stUnit);
             this.saveScanResultsJson(stUnit, false);
             
             this.uiScan.reset();
             this.updateUiScanStatus();
             
             
             this.uiListActive.setOptions({});
             
             if this.uicWaferLL.get()
                 % set working mode to 7
                 this.hardware.getDeltaTauPowerPmac().setWorkingModeWaferTransfer();
             end
             
             if this.uicWaferLL.get()
                 cMsg = sprintf('FEM is complete. The list of added prescriptions has been purged. Wafer has been sent to LL.');
             else
                 cMsg = sprintf('FEM is complete. The list of added prescriptions has been purged.');
             end
             
             
            cTitle = 'Success';
            cIcon = 'none';
            msgbox(cMsg, cTitle, cIcon)  
             
        end
        
        function startNewScan(this)
            
            this.msg('startFEM');
                       
            % Pre-FEM Check
            
            if ~this.preCheck()
                this.msg('failed preCheck() returning from startNewScan()');
                this.uiScan.reset();
                return
            end
            
            % At this point, we have passed all pre-checks and want to
            % actually start moving motors and such.  The experiment/FEM
            % will now begin
            
            % Store all of the selected items in uiListActive into a temporary
            % cell 
            
                       
            % Create new log file
            
            % Tell grating and undulator to go to correct place.
            % *** TO DO ***
                        
            % Loop through prescriptions (k, l, m)
            
            % for k = 1:length(this.cePrescriptions)
            
                % Build the recipe from .json file (we dogfood our own .json recipes always)
                
                cFile = this.getPathRecipe();  
                
                % Create a new folder to save results
                this.cDirScan = this.getDirScan();
                

                [stRecipe, lError] = this.buildRecipeFromFile(cFile); 
                                
                % Figure out number of skipped states.  Assumes FEM does column 
                % by column and that rows per column is number of focus.
                if stRecipe.fem.u8DoseNum < this.uiEditColStart.get()
                    this.abort('The start column is larger than the number of dose colums in the FEM')
                    return 
                end

                if stRecipe.fem.u8FocusNum < this.uiEditRowStart.get()
                    this.abort('The start row is larger than the number of focus rows in the FEM')
                    return 
                end
            
                stRecipe = this.getRecipeModifiedForSkippedColsAndRows(stRecipe);
                
                if lError 
                    this.abort('There was an error building the scan recipe from the .json file.');
                    return;
                end
                
                this.ceValues = cell(0); % cell(size(stRecipe.values));
                this.ceValuesFast = cell(0);
                
                this.scan = mic.Scan(...
                    'ui-fem-scan', ...
                    this.clock, ...
                    stRecipe, ...
                    @this.onScanSetState, ...
                    @this.onScanIsAtState, ...
                    @this.onScanAcquire, ...
                    @this.onScanIsAcquired, ...
                    @this.onScanComplete, ...
                    @this.onScanAbort, ...
                    0.25 ... % Need larger than the PPMAC cache period of 0.2 s
                );
                
            
                this.initScanTimingStore();
                this.scan.start();
            % end
            
        end
        
        
        
        
       
        
        function abort(this, cMsg)
                           
            
            this.lIsVib = false;
            this.lIsWFZ = false;
            this.lIsWaitingForAccOfAIToSettle = false;
            this.lIsWaitingForVelOfAIToSettle = false;
            
            if exist('cMsg', 'var') ~= 1
                cMsg = 'The FEM was aborted.';
            end
            
            % Stop dmi tracking
            % Send to working mode 5
            this.hardware.getMfDriftMonitor().monitorStop();
            this.hardware.getDeltaTauPowerPmac().setWorkingModeRun();
            %this.uiWafer.uiWorkingMode.uiWorkingMode.setDestCalDisplay(5); 
            %this.uiWafer.uiWorkingMode.uiWorkingMode.moveToDest();
            
            this.uiListActive.setOptions({});
             
            cMsg = sprintf('The FEM was aborted. The list of added prescriptions has been purged.');
            cTitle = 'Fem Aborted';
            cIcon = 'help';
            h = msgbox(cMsg, cTitle, cIcon, 'modal');  
            
            % wait for them to close the message
            % uiwait(h);
            
            this.msg(sprintf('The FEM was aborted: %s', cMsg));
            
            % Write to logs.
            this.writeToLog(sprintf('The FEM was aborted: %s', cMsg));

            this.uiScan.reset();
            
        end
        
        function createNewLog(this)
            
            % Close existing log file
            
        end
        
        function writeToLog(this, cMsg)
            
            
        end
        
        function lReturn = preCheck(this)
           
            
            this.msg('preCheck');
            % Make sure at least one prescription is selected
            
            if (isempty(this.uiListActive.get()))
                this.abort('No prescriptions were added. Please add a prescription before starting the FEM.');
                lReturn = false;
                return;
            end
            
            % Verify that DMIs are zeroed:
            % this.uiMFDriftMonitor.apiDriftMonitor.setDMIZero();
            this.hardware.getMfDriftMonitorMiddleware().setDMIZero();
            
            
            % Make sure the shutter is not open (this happens when it is
            % manually overridden)
            
            %{
            if(this.shutter.lOpen)
                this.abort('The shutter is open.  Please make sure that it is not manually overridden');
                lReturn = false;
                return; 
            end
            %}
            
            % Make sure all valves that get light into the tool are open
            % *** TO DO ***
            
            
            % Check that every single hardware instance that I will control 
            % is active
            
            
            cMsg = '';
            
            % Shutter
            
%             if ~this.hardware.getIsConnectedRigolDG1000Z()
%                 cMsg = sprintf('%s\n%s', cMsg, 'Rigol DG100Z (Shutter Signal Generator)');
%             end
            
            if ~this.hardware.getIsConnectedTekAFG31021()
                cMsg = sprintf('%s\n%s', cMsg, 'Tektronix AFG31021 (Shutter Signal Generator)');
            end
            
            % PPMAC
            if ~this.hardware.getIsConnectedDeltaTauPowerPmac()
                cMsg = sprintf('%s\n%s', cMsg, 'PPMAC (Reticle + Wafer Stages)');
            end
            
            % MF Drift Monitor Middleware
            if ~this.hardware.getIsConnectedMfDriftMonitorMiddleware()
                cMsg = sprintf('%s\n%s', cMsg, 'MF Drift Monitor Middleware (Height Sensor + DMI)');
            end

            if ~strcmp(cMsg, '')
                
                cQuestion   = sprintf( ...
                    ['The following device UI controls are virtualized (not active):' ...
                    '\n %s \n\n' ...
                    'Do you want to continue running the FEM with virtual devices?'], ...
                    cMsg ...
                );
                
                cTitle      = 'Some UI controls are virtualized';
                cAnswer1    = 'Run FEM with virtual hardware';
                cAnswer2    = 'Abort';
                cDefault    = cAnswer2;

                qanswer = questdlg(cQuestion, cTitle, cAnswer1, cAnswer2, cDefault);
                switch qanswer
                    case cAnswer1;

                    otherwise
                        this.abort('You stopped the FEM because some hardware was virtualized.');
                        lReturn = false;
                        return; %  exit startFEM() method
                end
            end
            
            
            % Throw up the "Run preseciption(s) ______?" dialog box
                        
            cQuestion   = sprintf( ...
                ['You are about to run the following prescriptions: ' ...
                '\n\n\t\t\t--%s\n\n is that OK?'], ...
                strjoin(this.uiListActive.get(), '\n\t\t\t--') ...
            );
            cTitle      = 'Confirm prescriptions';
            cAnswer1    = 'Run FEM';
            cAnswer2    = 'Abort';
            cDefault    = cAnswer1;
            
            qanswer = questdlg(cQuestion, cTitle, cAnswer1, cAnswer2, cDefault);
           
            switch qanswer
                case cAnswer1
                    lReturn = true;
                    return;
                otherwise
                    this.abort('You elected not to run the prescription(s) you had queued.');
                    lReturn = false;
                    return; %  exit startFEM() method
            end
            
            
        end
        
                

        
        
        
        
        function lReturn = shIsClosed(this)
            
            lReturn = ~this.shutter.lOpen;
            
        end
        
        
        
        
        function lOut = validateRecipe(this, stRecipe)
            % FIX ME
            lOut = true;            
        end
        
        function [dX, dY] = getFemGrid(this, dXStart, dXStep, u8NumDose, dYStart, dYStep, u8NumFocus)
            
            dX = dXStart : dXStep : dXStart + (double(u8NumDose) - 1) * dXStep;
            dY = dYStart : dYStep : dYStart + (double(u8NumFocus) - 1) * dYStep;
            
            [dX, dY] = meshgrid(dX * 1e-3, dY * 1e-3);
        end
        
        function updateUiScanStatus(this)
           this.uiScan.setStatus(this.scan.getStatus()); 
        end
        
        
        
        
        
        
        %{
        function saveScanResultsFastJson(this, stUnit, lAborted)
       
            % Append new state
            stState = this.getState(stUnit);
            stState.dose_mj_per_cm2 = 0; % fix me?
            this.ceValuesFast{end + 1} = stState;

            this.msg('saveScanResultsJson()');
             
            cName = 'result-fast.json';
            
            cPath = fullfile(...
                this.cDirScan, ... 
                cName ...
            );
        
            stResult = struct();
            stResult.recipe = this.getPathRecipe();
            stResult.unit = stUnit;
            stResult.values = this.ceValuesFast;
            
            stOptions = struct();
            stOptions.FileName = cPath;
            stOptions.Compact = 0;
            
            savejson('', stResult, stOptions);     

        end
        %}
        
        function saveScanResultsJson(this, stUnit, lAborted)
       
            dTic = tic;
            this.msg('saveScanResultsJson()');
             
            switch lAborted
                case true
                    cName = 'result-aborted.json';
                case false
                    cName = 'result.json';
            end
            
            cPath = fullfile(...
                this.cDirScan, ... 
                cName ...
            );
        
            stResult = struct();
            stResult.recipe = this.getPathRecipe();
            stResult.unit = stUnit;
            stResult.values = this.ceValues;
            
            stOptions = struct();
            stOptions.FileName = cPath;
            stOptions.Compact = 0;
            
            
            savejson('', stResult, stOptions);
                        
            dToc = toc(dTic);
            cMsg = sprintf('saveScanResultsJson() elapsed time = %1.3f', dToc);
            this.msg(cMsg, this.u8_MSG_TYPE_SCAN);

        end
        
        
        function saveScanResultsCsv(this, stUnit)
        

            if isempty(this.ceValues)
                    return;
            end
            
            
            cName = 'result.csv';
            
            cPath = fullfile(...
                this.cDirScan, ... 
                cName ...
            );
            
            % Open the file in append mode
            % 2020.01.09 trying capital A to not automatically flush the
            % output buffer when the file closes to see if it is faster
            % was using 'a' before
            fid = fopen(cPath, 'A');

            % Write the header
            % Device
            % fprintf(fid, '# "%s"\n', this.uiPopupRecipeDevice.get().cValue);
            
            % Append the latest value to the log
            stValue = this.ceValues{end};
            
            % write the header if this is the first value
            
            ceNames = fieldnames(stValue);
            dNum = length(ceNames);
            
            if length(this.ceValues) == 1
                for n = 1:dNum
                    fprintf(fid, '%s', ceNames{n});
                    if n < dNum
                        fprintf(fid, ',');
                    end
                end
                fprintf(fid, '\n');
            end
            
            
            
            if isstruct(stValue)
                
                for m = 1 : dNum
                    switch ceNames{m}
                        case 'time'
                            fprintf(fid, '%s', stValue.(ceNames{m}));
                        otherwise
                            fprintf(fid, '%1.5e', stValue.(ceNames{m}));
                    end
                    
                    if m < dNum
                        fprintf(fid, ',');
                    end
                end
                fprintf(fid, '\n');
            end

            % Close the file
            fclose(fid);
            


        end
        
        % @param {struct} stValue - state value structure 
        function c = getNameOfDmiHeightSensorLogFile(this, stValue)
            
            % num of rows per col * current col = elapsed colums
            % then add current row
            dShot =  stValue.task.femRows * (stValue.task.femCol - 1) + stValue.task.femRow;
                
            %{
            c = sprintf(...
                [...
                    '%03d-', ...
                    'dose%02d-', ...
                    'focus%02d-', ...
                    '1kHz-DMI-HS-data-', ...
                    '%s.txt' ...
                ], ...
                dShot, ...
                stValue.task.femCol, ...
                stValue.task.femRow, ...
                datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local') ...
            );
            %}
        
            c = sprintf(...
                [...
                    '%s-', ...
                    'dose%02d-', ...
                    'focus%02d-', ...
                    '1kHz-DMI-HS-data.txt' ...
                ], ...
                datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local'), ...
                stValue.task.femCol, ...
                stValue.task.femRow ...
            );
        
        end
        
        function c = getDirScan(this)
            
            % Get name of recipe
            [cPath, cName, cExt] = fileparts(this.getPathRecipe());
            
            c = sprintf('%s__%s', ...
                cName, ...
                datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local')...
            );
        
            c = fullfile(this.cDirSave, c);
            c = mic.Utils.path2canonical(c);
            mic.Utils.checkDir(c);
            
        end
        
        
        function c = getPathRecipe(this)
            
            cePrescriptions = this.uiListActive.get();
%             c = fullfile(...
%                 this.cDirPrescriptions, ...
%                 cePrescriptions{1} ...
%             );


            c = fullfile(...
                this.uiPrescriptionTool.uiListPrescriptions.getDir(), ...
                cePrescriptions{1} ...
            );

                
        end
        
        function l = getScanIsPausedSafe(this)
            
            if isempty(this.scan)
                l = true;
                return
            end
            l = this.scan.getIsPaused();
        end
                    
            
        
        function task = createSequenceRecoverFem(this)
            
            taskPause = mic.Task( ...
                'fhExecute', @() this.onUiScanPause(), ...
                'fhIsDone', @() this.getScanIsPausedSafe(), ...
                'fhAbort', @() [], ...
                'fhGetMessage', @() sprintf('Pausing the FEM Scan') ...
            );
        
            taskResume = mic.Task( ...
                'fhExecute', @() this.onUiScanResume(), ...
                'fhIsDone', @() ~this.getScanIsPausedSafe(), ...
                'fhAbort', @() [], ...
                'fhGetMessage', @() sprintf('Resuming the FEM Scan') ...
            );
        
            taskRecoverPpmacAndHydra = bl12014.Tasks.createSequenceRecoverPpmacAndHydra(...
                [this.cName, 'sequence-recover-ppmac-and-hydra'], ...
                this.hardware, ...
                this.clock ...
            );
        
            ceTasks = {...
                taskPause, ...
                taskRecoverPpmacAndHydra, ...
                taskResume ...
            };
            
            task = mic.TaskSequence(...
                'cName', [this.cName, 'sequence-recover-fem'], ...
                'clock', this.clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'fhGetMessage', @() 'Recover FEM from PPMAC/Hydra Stall' ...
            );
            
        end
        
        
        function st = getState(this, stUnit)
            
        	st = struct();
            
            st.als_current_ma = this.uiCurrentOfALS.getValCal('mA');
            st.exit_slit_um = this.uiBeamline.uiExitSlit.uiGap.getValCal('um');
            st.undulator_gap_mm = this.uiBeamline.uiUndulatorGap.getValCal('mm');
            st.wavelength_nm = this.uiBeamline.uiGratingTiltX.getValCal('wav (nm)');
            
            st.x_reticle_coarse_mm = this.uiReticle.uiCoarseStage.uiX.getValCal('mm');
            st.y_reticle_coarse_mm = this.uiReticle.uiCoarseStage.uiY.getValCal('mm');
            st.z_reticle_coarse_mm = this.uiReticle.uiCoarseStage.uiZ.getValCal('mm');
            st.tilt_x_reticle_coarse_urad = this.uiReticle.uiCoarseStage.uiTiltX.getValCal('urad');
            st.tilt_y_reticle_coarse_urad = this.uiReticle.uiCoarseStage.uiTiltY.getValCal('urad');
            
            [dTiltX, dTiltY, dZ] =  this.uiReticle.uiMod3CapSensors.getTiltXAndTiltYAndZ(); % returns deg
            st.tilt_x_reticle_cap_urad = dTiltX * pi / 180 * 1e6;
            st.tilt_y_reticle_cap_urad = dTiltY * pi / 180 * 1e6;
            st.z_reticle_cap_um = dZ;
            
            st.cap_1_reticle_V = this.uiReticle.uiMod3CapSensors.uiCap1.getValCal('V');
            st.cap_2_reticle_V = this.uiReticle.uiMod3CapSensors.uiCap2.getValCal('V');
            st.cap_3_reticle_V = this.uiReticle.uiMod3CapSensors.uiCap3.getValCal('V');
            st.cap_4_reticle_V = this.uiReticle.uiMod3CapSensors.uiCap4.getValCal('V');
            
            st.cap_1_reticle_um = this.uiReticle.uiMod3CapSensors.uiCap1.getValCal('um');
            st.cap_2_reticle_um = this.uiReticle.uiMod3CapSensors.uiCap2.getValCal('um');
            st.cap_3_reticle_um = this.uiReticle.uiMod3CapSensors.uiCap3.getValCal('um');
            st.cap_4_reticle_um = this.uiReticle.uiMod3CapSensors.uiCap4.getValCal('um');

            st.x_reticle_fine_nm = this.uiReticle.uiFineStage.uiX.getValCal('nm');
            st.y_reticle_fine_nm = this.uiReticle.uiFineStage.uiY.getValCal('nm');
            
            st.x_wafer_coarse_mm = this.uiWafer.uiCoarseStage.uiX.getValCal('mm');
            st.y_wafer_coarse_mm = this.uiWafer.uiCoarseStage.uiY.getValCal('mm');
            st.z_wafer_coarse_mm = this.uiWafer.uiCoarseStage.uiZ.getValCal('mm');
            st.tilt_x_wafer_coarse_urad = this.uiWafer.uiCoarseStage.uiTiltX.getValCal('urad');
            st.tilt_y_wafer_coarse_urad = this.uiWafer.uiCoarseStage.uiTiltY.getValCal('urad');
            
            % TODO add mfdriftmon middleware foce update call
            st.tilt_x_wafer_height_sensor_urad = this.uiWafer.uiWaferTTZClosedLoop.uiCLTiltX.getValCal('urad');
            st.tilt_y_wafer_height_sensor_urad = this.uiWafer.uiWaferTTZClosedLoop.uiCLTiltY.getValCal('urad');
            
            [dTiltX, dTiltY] =  this.uiWafer.uiPobCapSensors.getTiltXAndTiltYWithoutSensor4(); % returns deg
            st.tilt_x_wafer_cap_urad = dTiltX * pi / 180 * 1e6;
            st.tilt_y_wafer_cap_urad = dTiltY * pi / 180 * 1e6;
            
            st.cap_1_wafer_V = this.uiWafer.uiPobCapSensors.uiCap1.getValCal('V');
            st.cap_2_wafer_V = this.uiWafer.uiPobCapSensors.uiCap2.getValCal('V');
            st.cap_3_wafer_V = this.uiWafer.uiPobCapSensors.uiCap3.getValCal('V');
            st.cap_4_wafer_V = this.uiWafer.uiPobCapSensors.uiCap4.getValCal('V');
            
            st.cap_1_wafer_um = this.uiWafer.uiPobCapSensors.uiCap1.getValCal('um');
            st.cap_2_wafer_um = this.uiWafer.uiPobCapSensors.uiCap2.getValCal('um');
            st.cap_3_wafer_um = this.uiWafer.uiPobCapSensors.uiCap3.getValCal('um');
            st.cap_4_wafer_um = this.uiWafer.uiPobCapSensors.uiCap4.getValCal('um');
            
            st.z_wafer_fine_nm = this.uiWafer.uiFineStage.uiZ.getValCal('nm');
            st.z_height_sensor_nm = this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.getValCal('nm');
            % st.z_height_sensor_cal_nm = this.hardware.getMfDriftMonitorMiddleware.
            
            
            % VIS
            st.z_encoder_1_vis_V = this.uiVibrationIsolationSystem.uiEncoder1.getValCal('Volts');
            st.z_encoder_2_vis_V = this.uiVibrationIsolationSystem.uiEncoder2.getValCal('Volts');
            st.z_encoder_3_vis_V = this.uiVibrationIsolationSystem.uiEncoder3.getValCal('Volts');
            st.z_encoder_4_vis_V = this.uiVibrationIsolationSystem.uiEncoder4.getValCal('Volts');
            st.z_encoder_1_vis_um = this.uiVibrationIsolationSystem.uiEncoder1.getValCal('um');
            st.z_encoder_2_vis_um = this.uiVibrationIsolationSystem.uiEncoder2.getValCal('um');
            st.z_encoder_3_vis_um = this.uiVibrationIsolationSystem.uiEncoder3.getValCal('um');
            st.z_encoder_4_vis_um = this.uiVibrationIsolationSystem.uiEncoder4.getValCal('um');
            [dTiltX, dTiltY] = this.uiVibrationIsolationSystem.getTiltXAndTiltY(); % returns deg
            st.tilt_x_vis_urad = dTiltX * pi / 180 * 1e6;
            st.tilt_y_vis_urad = dTiltY * pi / 180 * 1e6;
                        
            
            % st.z_height_sensor_nm = this.uiWafer.uiHeightSensorZClosedLoop.uiZHeightSensor.getDevice().getAveraged(); 
            st.shutter_ms = this.uiShutter.uiShutter.getDestCal('ms');
            
            % ca update 2020.08 to store the override value from the UI if 
            % it is being used during experiment.
            
            
            dFluxDensity = this.uiFluxDensity.get();
           
            st.flux_mj_per_cm2_per_s = dFluxDensity;
            

            
            % st.temp_c_po_m2_0200 = this.hardware.getDataTranslation().measure_temperature_rtd(31, 'PT100');
            dData = this.hardware.getDataTranslation().getScanData();
            st.temp_c_po_m2_0200 = dData(31 + 1);
            
            
            % Adding timing info
            ceFields = fieldnames(this.stScanTimingStore);
            for n = 1 : length(ceFields)
                cFieldSave = sprintf('time_%s', ceFields{n});
                st.(cFieldSave) = this.stScanTimingStore.(ceFields{n});
            end
            
            st.time = datestr(datevec(now), 'yyyy-mm-dd HH:MM:SS', 'local');
            
            st.charge_dose_monitor = this.hardware.getDoseMonitor().getCharge(this.hardware.getSR570MDM().getSensitivity());

        end
        
        function stRecipe = getRecipeModifiedForSkippedColsAndRows(this, stRecipe)
           
            % number of states per exposure (if you add pause back,
            % increase by 1
            dNumStatesSetup = 12;
            dNumStatesNormal = 10;
            
            % careful to convert all uint8 to type double or you can
            % get type casting and things will max at 255
            dNumDose = double(stRecipe.fem.u8DoseNum);
            dRowStart = double(this.uiEditRowStart.get());
            dColStart = double(this.uiEditColStart.get());
            
            dNumSkip = 0;
            
            if (...
                dColStart > 1 || ...
                dRowStart > 1 ...
            )
                dNumSkip = dNumSkip + dNumStatesSetup;
            end
            
            % Skip full rows
            dNumStatesInRow = dNumDose * dNumStatesNormal + 1;
            dNumRows =  dRowStart - 1;
            
            dNumSkip = dNumSkip + dNumRows * dNumStatesInRow; 
            
            % Skip partial row with cols
            if mod(dRowStart, 2) == 0 
                % starting on even row, which goes right to left
                dNumCols = dNumDose - dColStart;
            else
                % starting on odd row, which goes right to left
                dNumCols = dColStart - 1;
            end
            
            if dNumCols > 0
                dNumSkip = dNumSkip + dNumCols * dNumStatesNormal + 1;
            end
                
            %{
            dNumSkip = ...
                (this.uiEditColStart.get() - 1) * stRecipe.fem.u8FocusNum + ...
                (this.uiEditRowStart.get() - 1);
            %}
            
            ceValues = stRecipe.values;
            
            if dNumSkip > 0
                
                % Skip the first setup state
                ceValues = ceValues(2 : end);
                
                % Skip states
                for n = 1 : dNumSkip
                   ceValues = ceValues(2 : end); 
                end
            end
            
            stRecipe.values = ceValues;
            
        end
        
        % Returns {char 1xm} [row X, colX] = NAME
        function c = getTextReticleField(this)
            
            dRow = this.uiReticle.uiReticleFiducializedMove.uiRow.getValCalDisplay();
            dCol = this.uiReticle.uiReticleFiducializedMove.uiCol.getValCalDisplay();    
            
            if ~isnumeric(dRow) || ...
               ~isscalar(dRow) || ...
               ~isnumeric(dCol) || ...
               ~isscalar(dCol)
                return
            end
            
            dErrorRow = dRow - round(dRow);
            dErrorCol = dCol - round(dCol);
            
            if abs(dErrorRow) < 0.01
                dRow = round(dRow);
            end
            if abs(dErrorCol) < 0.01
                dCol = round(dCol);
            end
            
            % 2020.07 cols are flipped so col 1 = col 19, col2 = col 18
            %dCol = 19 - dCol + 1;
            
            try
                cNameOfField = bl12014.getNameOfReticleField(...
                    'row', dRow, ...
                    'col', dCol ...
                );
            catch mE
                cNameOfField = 'Unknown';
            end
            
            c = sprintf(...
                '[row %1.1f, col %1.1f] = %s', ...
                dRow, ...
                dCol, ...
                cNameOfField ...
           );
        end
        
        function updateTextReticleField(this, src, evt)
            
            cText = this.getTextReticleField();
           this.uiTextReticleField.set(['Reticle Field: ', cText]);
           
           dColorGreen = [.85, 1, .85];
           dColorRed = [1, .85, .85];
            
           if ~contains(cText, 'Not Specified')
               % green
               this.uiTextReticleField.setBackgroundColor(dColorGreen);
           else
               % red
               this.uiTextReticleField.setBackgroundColor(dColorRed);
           end
        end
        
        function updateScannerPlots(this, ~, ~)
            
            this.plotFieldFill();
            this.plotPupilFill();
            
        end
        
        

        
        
        
        % Returns the high frequency vibration (in nm) of the aerial image
        % relatifve to the wafer over the last 1 second.  Used by the
        % vibration settle routine.
        
        function [dRmsDriftX, dRmsDriftY] = getVibrationOfDmi(this)
            
            samples = this.hardware.getMfDriftMonitor().getSampleData(1000);
            dDmi = bl12014.MfDriftMonitorUtilities.getDmiPositionFromSampleData(samples);
            dRmsDriftX = std(dDmi(5, :));
            dRmsDriftY = std(dDmi(6, :));
            
        end
                          

    end 
    
    
end