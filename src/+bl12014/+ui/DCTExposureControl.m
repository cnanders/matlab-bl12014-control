classdef DCTExposureControl < mic.Base
    
    % A panel with a list of available prescriptions, the ability to queue
    % multiple prescriptions to a new experiment (wafer), start/pause/stop
    % the experiment, checkboxes for booleans pertaining to running the
    % experiment
    
    
    properties (Constant)
        
        dXChiefRay = 0e-3 % m think of this as the stage position when EUV hits center of wafer
        dYChiefRay = 0e-3 % m
       
        dWidth = 950
        dHeight = 600
        
        dWidthList = 500
        dHeightList = 100
        dWidthUiScan = 270
        
        dPauseTime = 1
        
        dWidthPanelAvailable = 700
        dHeightPanelAvailable = 200
        
        dWidthPanelAdded = 430
        dHeightPanelAdded = 650
        
        dWidthPanelBorder = 0
        
        dColorFigure = [200 200 200]./255
        
        dToleranceWaferX = 0.01 % mm
        dToleranceWaferY = 0.01 % mm

       
        
    end
    
	properties

        
    end
    
    properties (SetAccess = private)
        
        hDYMO
        
        lUseMjPerCm2PerSecOverride = true
        uiEditMjPerCm2PerSec
        
        uiShutter
        uiPrescriptions
        
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
        
        uiListActive
        
        uiButtonClearPrescriptions
        uiButtonClearExposures
        
        uibNewWafer
        uibAddToWafer
        uibPrint
        uibPrintSaved
        uicWaferLL
        uicAutoVentAtLL 
        
        uiStageWafer
        uiStageAperture
        uiScannerM142
        uiBeamline 
        uiFluxDensity
        
        clock
        uiClock
        
        hDock
        
        cDirThis
        cDirSrc
        cDirSave
        cDirScan % new directory for every scan
        
        hPanelAvailable
        hPanelAdded
        hParent
                         
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
        
        % {cell of struct} storage of state during each acquire
        ceValues
        ceValuesFast % storage at n Hz not necessarily correlated with exposures
        
                
        
        uiAxes
        uiReticleAxes
        exposures
        
        
         % {bl12014.Hardware 1x1}
        hardware
            
        
        uiScannerPlotDCT
        uiStateM142ScanningDefault
        uiStateUndulatorIsCalibrated
        uiStateExitSlitIsCalibrated
        uiStateApertureIsCalibrated
        uiStateApertureStageIsCalibrated
        uiStateMonoGratingAtEUV
        uiStateM141SmarActOff
        uiStateApertureMatchesDiode
                        
        uiTextTimeCalibrated
        uiTextFluxDensityCalibrated
    end
    
        
    events
        ePreChange
    end

    
    methods
        
        
        function this = DCTExposureControl(varargin)
            
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
            
            % These are all basically indirect ways to access some property
            % of a piece of hardware or some piece of UI state.  There is
            % no global state that is the source of truth so need to pass
            % in some UIs
            
            if ~isa(this.uiFluxDensity, 'bl12014.ui.DCTFluxDensity')
                error('uiFluxDensity must be bl12014.ui.DCTFluxDensity');
            end
            
            if ~isa(this.uiBeamline, 'bl12014.ui.Beamline')
                error('uiBeamline must be bl12014.ui.Beamline');
            end
            
            %{
            if ~isa(this.uiScannerM142, 'bl12014.ui.Scanner')
                error('uiScannerM142 must be bl12014.ui.Scanner');
            end
            %}
            
            if ~isa(this.exposures, 'bl12014.DCTExposures')
                error('exposures must be bl12014.DCTExposures');
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
                'uiEditMjPerCm2PerSec' ...
             };
            
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
        
        
        function buildPanelAdded(this, hParent, dLeft, dTop)
            
            this.hPanelAdded = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', '',...
                'BorderWidth', this.dWidthPanelBorder, ...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                    dLeft ...
                    dTop ...
                    this.dWidthPanelAdded...
                    this.dHeightPanelAdded], ...
                    hParent ...
                ) ...
            );
        
        
           dLeft = 10;
           
           this.uiScannerPlotDCT.build(this.hPanelAdded, dLeft, dTop)
       
           dSep = 30;
           dTop = dTop + this.uiScannerPlotDCT.dHeight + 10;
           
           dWidthTask = 400;
            
           this.uiStateUndulatorIsCalibrated.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           
           this.uiStateMonoGratingAtEUV.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           
           this.uiStateExitSlitIsCalibrated.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           
           %{
           this.uiStateApertureIsCalibrated.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           %}
           
           this.uiStateApertureStageIsCalibrated.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           
           %{
           this.uiStateApertureMatchesDiode.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           %}
                      
           this.uiStateM141SmarActOff.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           dTop = dTop + 60;
           dHeightList = 40;
           
           this.uiListActive.build(this.hPanelAdded, ...
                dLeft, ...
                dTop, ...
                this.dWidthPanelAdded - 2 * this.dWidthPadFigure, ...
                dHeightList);
            
           dSep = 20;
           dTop = dTop + dHeightList + 20;
           
           %dLeft = dPad + this.dWidthList + dPad;
           dLeft = this.dWidthPadFigure;
           
            this.uiButtonClearPrescriptions.build(this.hPanelAdded, ...
                dLeft, ...
                dTop, ...
                this.dWidthButton, ...
                this.dHeightButton);
            dLeft = dLeft + this.dWidthButton + this.dWidthPadFigure;
            
            this.uiButtonClearExposures.build(this.hPanelAdded, ...
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
            
           
           dLeft = 10;
           dTop = dTop + 50;
           dSep = 40;
           
           if this.lUseMjPerCm2PerSecOverride
                this.uiEditMjPerCm2PerSec.build(this.hPanelAdded, dLeft, dTop, 100, 24);
                
                dWidthText = 200;
                dHeightText = 36;
                this.uiTextFluxDensityCalibrated.build(this.hPanelAdded, dLeft + 110, dTop + 8, dWidthText, dHeightText);
                
           else
               
           dWidthText = 300;
           dHeightText = 24;
           this.uiTextFluxDensityCalibrated.build(this.hPanelAdded, dLeft, dTop, dWidthText, dHeightText);
               
           end
           
           dTop = dTop + dSep;
           dSep = 20;
           
           this.uicWaferLL.build(this.hPanelAdded, ...
               dLeft, ...
               dTop, ...
               200, ...
               20);
            
           dTop = dTop + dSep;
           this.uicAutoVentAtLL.build(this.hPanelAdded, ...
               dLeft, ...
               dTop, ...
               200, ...
               20);
           dTop = dTop + 30;
           
           
           
           
           
           
           
           
           
           %{
           this.uiStateM142ScanningDefault.build(this.hPanelAdded, dLeft, dTop, dWidthTask);
           dTop = dTop + dSep;
           %}
           
           % dLeft = 150;
           % dTop = 180
           this.uiScan.build(this.hPanelAdded, dLeft - 10, dTop);
           
           dTop = dTop + this.uiScan.dHeight + 10;
            
        end
             
                
        
        function build(this, hParent, dLeft, dTop)
            
            this.buildPanelPrescriptions(hParent, dLeft, dTop)
            this.buildPanelAdded(hParent, dLeft + this.uiPrescriptions.dWidth + 20, dTop)
            
            % this.uiShutter.build(this.hParent, this.uiPrescriptions.dWidth + 25, 400);
                      
        end
        
        function buildPanelPrescriptions(this, hParent, dLeft, dTop)
            
            this.uiPrescriptions.build(hParent, dLeft, dTop);
            
            dLeft = dLeft + this.uiPrescriptions.dWidth - 250;
            dWidthButton = 110;
            dSep = 10;
            
            dTop = dTop + this.uiPrescriptions.dHeight + 10;
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
            
        end
        
        
        %% Destructor
        
        function cec = getPropsDelete(this)
            
            cec = {...
                'uiShutter', ...
                'uiStageWafer', ...
                'uiStageAperture', ...
                'uiStateUndulatorIsCalibrated', ...
                'uiStateMonoGratingAtEUV', ...
                'uiStateM141SmarActOff', ...
                'uiStateApertureMatchesDiode', ...
                'uiStateExitSlitIsCalibrated', ...
                'uiStateApertureIsCalibrated', ...
                'uiStateApertureStageIsCalibrated', ...
                'uiScannerPlotDCT' ...
            };
            
        end
        
        function delete(this)
                        this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);  

            this.uiClock.remove(this.id());
            cecProps = this.getPropsDelete();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                this.(cProp).delete();
            end
                        
        end
                            

    end
    
    methods (Access = private)
        
        function init(this)
                  
            this.msg('init()');
            
            this.uiButtonClearPrescriptions = mic.ui.common.Button(...
                'cText', 'Clear Prescriptions', ...
                'fhOnClick', @this.onClickClearPrescriptions ...
            );
        
            this.uiButtonClearExposures = mic.ui.common.Button(...
                'cText', 'Clear Exposures', ...
                'fhOnClick', @this.onClickClearExposures ...
            );
        
            this.uibNewWafer = mic.ui.common.Button(...
                'cText', 'New', ...
                'fhOnClick', @this.onClickNewWafer ...
            );
            this.uibAddToWafer = mic.ui.common.Button(...
                'cText', 'Add To Wafer', ...
                'fhOnClick', @this.onClickAddToWafer ...
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
                'fhDirectCallback', @this.onChangeListActive, ...
                'lShowDelete', true, ...
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
            
            
            this.uiEditMjPerCm2PerSec = mic.ui.common.Edit(...
                'cLabel', 'mJ/cm2/s', ...
                'cType', 'd' ...
            );
            this.uiEditMjPerCm2PerSec.set(10);
            this.uiEditMjPerCm2PerSec.setMin(0);
            this.uiEditMjPerCm2PerSec.setMax(1e5);
            
            this.uiShutter = bl12014.ui.Shutter(...
                'cName', [this.cName, 'shutter'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
            
            this.uiStageWafer = bl12014.ui.DCTWaferStage(...
                'cName', [this.cName, 'stage-wafer'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        
            this.uiStageAperture = bl12014.ui.DCTApertureStage(...
                'cName', [this.cName, 'stage-aperture'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
            
            
        
            this.uiPrescriptions = bl12014.ui.DCTPrescriptions(...
                'fhOnChange', @(stData) this.onChangePrescription(stData) ...
            );
            
            
            %{
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
            %}
        
            this.uiStateUndulatorIsCalibrated = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-undulator-is-calibrated'], ...
                'task', bl12014.Tasks.createStateUndulatorIsCalibrated(...
                    [this.cName, 'state-undulator-is-calibrated'], ...
                    this.uiFluxDensity, ...
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
        
            this.uiStateApertureMatchesDiode = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-dct-aperture-stage-matches-diode'], ...
                'task', bl12014.Tasks.createStateDCTApertureStageMatchesDiode(...
                    [this.cName, 'state-dct-aperture-stage-matches-diode'], ...
                    this.uiStageAperture, ...
                    this.uiFluxDensity.uiDiode, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateExitSlitIsCalibrated = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-exit-slit-is-calibrated'], ...
                'task', bl12014.Tasks.createStateExitSlitIsCalibrated(...
                    [this.cName, 'state-exit-slit-is-calibrated'], ...
                    this.uiFluxDensity, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateApertureIsCalibrated = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-aperture-is-calibrated'], ...
                'task', bl12014.Tasks.createStateDCTApertureIsCalibrated(...
                    [this.cName, 'state-aperture-is-calibrated'], ...
                    this.uiFluxDensity, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateApertureStageIsCalibrated = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-aperture-stage-is-calibrated'], ...
                'task', bl12014.Tasks.createStateDCTApertureStageIsCalibrated(...
                    [this.cName, 'state-aperture-stage-is-calibrated'], ...
                    this.uiStageAperture, ...
                    this.uiFluxDensity, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiScannerPlotDCT = bl12014.ui.ScannerPlotDCT(...
                'cName', [this.cName, 'scanner-plot-dct'], ...
                'uiClock', this.uiClock, ...
                'fhGetWidthOfAperture', @() this.uiFluxDensity.uiDiode.uiPopupAperture.get().dWidth * 1e-3, ...
                'fhGetHeightOfAperture', @() this.uiFluxDensity.uiDiode.uiPopupAperture.get().dWidth * 1e-3, ...
                'fhGetWavetables', @() this.uiScannerM142.uiNPointLC400.getWavetables(), ...
                'fhGetActive', @() this.uiScannerM142.uiNPointLC400.uiGetSetLogicalActive.get() ...
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
            
            this.uiClock.add(...
                @this.updateTextsFluxCalibration, ...
                this.id(), ...
                1 ...
            );
                       
        end
        
        
        function updateTextsFluxCalibration(this, src, evt)
            
            this.uiTextFluxDensityCalibrated.set(...
                sprintf('Flux Density: %1.1f mJ/cm2/s (%s aperture) on %s', ...
                this.uiFluxDensity.getFluxDensityCalibrated(), ...
                this.uiFluxDensity.getApertureCalibrated(), ...
                this.uiFluxDensity.getTimeCalibrated() ...
            ));
            
        end
        
        function initScanSetContract(this)
            
             ceFields = {...
                'xWafer', ...
                'yWafer', ...
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
        
        function resetScanAcquireContract(this)
            
            ceFields = fieldnames(this.stScanAcquireContract);
            for n = 1 : length(ceFields)
                this.stScanAcquireContract.(ceFields{n}).lRequired = false;
                this.stScanAcquireContract.(ceFields{n}).lIssued = false;
                this.stScanAcquireContract.(ceFields{n}).lAchieved = false;
            end
            
        end
        
        
        function onUiScanStart(this, src, evt)
            this.msg('onUiScanStart');
            this.startNewScan();
        end
        
        function onUiScanPause(this, ~, ~)
            this.scan.pause();
            this.updateUiScanStatus()

        end
        
        function onUiScanResume(this, ~, ~)
            this.scan.resume();
            this.updateUiScanStatus()

        end
        
        function onUiScanAbort(this, ~, ~)
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
            
            ceSelected = this.uiPrescriptions.uiListPrescriptions.get();
            
            if isempty(ceSelected)
                % Show alert
                
                cMsg = sprintf('Please select a prescription to print');
                cTitle = 'No prescription selected';
                msgbox(cMsg, cTitle, 'warn')    
                
                return
            end

            cFile = fullfile(this.uiPrescriptions.uiListPrescriptions.getDir(), ceSelected{1});
            [stRecipe, lError] = this.buildRecipeFromFile(cFile); 
            this.printRecipe(stRecipe, cFile);
            
            
        end
        
        function onClickNewWafer(this, src, evt)
            
            % Purge all items from uiListActive
            this.uiListActive.setOptions(cell(1,0));
            this.exposures.purgeExposures();
            this.exposures.purgeExposuresScan();
            
        end
        
        function onClickClearExposures(this, src, evt)
            this.exposures.purgeExposures();
        end
        
        function onClickClearPrescriptions(this, src, evt)
            this.exposures.purgeExposuresScan();
            this.uiListActive.setOptions({});
        end
        
        function onChangeListActive(this)
            
            this.exposures.purgeExposuresScan();
            
            cFile = this.getPathRecipe();  
            [stRecipe, lError] = this.buildRecipeFromFile(cFile); 
            
            if lError
                return;
            end
            
            dX = stRecipe.matrix.dX;
            dY = stRecipe.matrix.dY;
            dDose = stRecipe.matrix.dDose;
            for n = 1 : length(dX)
                this.exposures.addExposureToScan([
                    dX(n), ...
                    dY(n), ...
                    this.uiFluxDensity.uiDiode.uiPopupAperture.get().dWidth * 1e-3, ...
                    this.uiFluxDensity.uiDiode.uiPopupAperture.get().dHeight * 1e-3, ...
                    dDose(n) ...
                ]);
            end
            
        end
        
        
        function onClickAddToWafer(this, src, evt)
                        
            % For all prescriptions highlihged when the user clicks 
            % "add to wafer", add them to ListActive 
           
            ceSelected = this.uiPrescriptions.uiListPrescriptions.get();
            
            for k = 1:length(ceSelected)
                this.uiListActive.append(ceSelected{k});
            end
            
        end 
        
        
        function onChangePrescription(this, stData)
            
            this.exposures.purgeExposuresPre();
                        
            %{
            dX = this.uiPrescriptions.uiExposureMatrix.dX;
            dY = this.uiPrescriptions.uiExposureMatrix.dY;
            dDose = this.uiPrescriptions.uiExposureMatrix.dDose;
            %}
            
            dX = stData.dX;
            dY = stData.dY;
            dDose = stData.dDose;
            
            for n = 1 : length(dX)
                this.exposures.addExposureToPre([
                    dX(n), ...
                    dY(n), ...
                    this.uiFluxDensity.uiDiode.uiPopupAperture.get().dWidth * 1e-3, ...
                    this.uiFluxDensity.uiDiode.uiPopupAperture.get().dHeight * 1e-3, ...
                    dDose(n) ...
                ]);
            end
            
        end
        

        % @param {char 1xm} full path to .mat recipe file
        
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
            
            load(cPath); 
            % populates variable st in local workspace.  The variable st is
            % the saved state of the prescription UI which has props
            % uieName
            % uiExposureMatrix
            % stRecipe
         
            stRecipe = st.stRecipe;
            
            %{
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
            %}

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
            
            
            for n = 1 : length(ceFields)
                
                cField = ceFields{n};
                
                
                                
                switch cField
                    case 'xWafer'
                        
                        % stValue.xWafer is where we want the exposure on
                        % the wafer so the stage needs to be opposite this.
                        dVal = -stValue.(cField) + this.dXChiefRay; % both in SI (m)
                        this.uiStageWafer.uiX.setDestCalAndGo(dVal * 1e3, 'mm')
                        this.stScanSetContract.(cField).lIssued = true;
                    case 'yWafer'
                        dVal = -stValue.(cField) + this.dYChiefRay; 
                        this.uiStageWafer.uiY.setDestCalAndGo(dVal * 1e3, 'mm')
                        this.stScanSetContract.(cField).lIssued = true;
                    otherwise
                        % do nothing
                end % switch cField 
                
                if lDebug
                    this.msg(sprintf('%s setting %s', cFn, cField), this.u8_MSG_TYPE_SCAN);
                end
            end % loop through fields
        end
        

        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the system is at the state


        function lOut = onScanIsAtState(this, stUnit, stValue)
            

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
                        this.msg(sprintf('%s %s set is required', cFn, cField), this.u8_MSG_TYPE_SCAN);
                    end

                    if this.stScanSetContract.(cField).lIssued
                        
                        if lDebug
                            this.msg(sprintf('%s %s set has been issued', cFn, cField), this.u8_MSG_TYPE_SCAN);
                        end
                        
                        if this.stScanSetContract.(cField).lAchieved
                            
                            if lDebug
                                this.msg(sprintf('% %s set has been achieved', cFn, cField), this.u8_MSG_TYPE_SCAN);
                            end
                            
                            continue % no need to check this property
                        end
                        
                        % Check if the set operation is complete
                        
                        lReady = true;
                        
                        if ~isempty(stValue.(cField))
                            
                            switch cField
                                
                                case 'xWafer'
                                    
                                    dXStageMm = this.uiStageWafer.uiX.getValCal(stUnit.xWafer); % mm
                                    dXWafer = -dXStageMm * 1e-3 + this.dXChiefRay; % m % position of exposure on wafer
                                    lReady = abs(dXWafer - stValue.xWafer) <= this.dToleranceWaferX;
                                            
                                    if lDebug
                                        cMsg = sprintf('%s %s value = %1.3f; goal = %1.3f', ...
                                            cFn, ...
                                            cField, ...
                                            this.uiStageWafer.uiX.getValCal(stUnit.xWafer) - this.dXChiefRay * 1e3, ...
                                            stValue.xWafer ...
                                        );
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    end
                                case 'yWafer'
                                    
                                    dYStageMm = this.uiStageWafer.uiY.getValCal(stUnit.yWafer); % mm
                                    dYWafer = -dYStageMm * 1e-3 + this.dYChiefRay; % m % position of exposure on wafer
                                    lReady = abs(dYWafer - stValue.yWafer) <= this.dToleranceWaferY;
                                                                                
                                    if lDebug
                                        cMsg = sprintf('%s %s value = %1.3f; goal = %1.3f', ...
                                            cFn, ...
                                            cField, ...
                                            this.uiStageWafer.uiY.getValCal(stUnit.yWafer) - this.dYChiefRay * 1e3, ...
                                            stValue.yWafer ...
                                        );
                                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                                    end
                                
                                otherwise

                                    % UNSUPPORTED

                            end
                            
                        end
                        
                        
                        if lReady
                            
                            this.stScanSetContract.(cField).lAchieved = true;
                        	
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
        function onScanAcquire(this, stUnit, stValue)
            
            this.dTicScanAcquire = tic;
            this.resetScanAcquireContract();
            
            % If stValue does not have a "task" or "action" prop, return
            
            if ~isfield(stValue, 'task')
                return
            end
            
            this.stScanAcquireContract.shutter.lRequired = true;
            this.stScanAcquireContract.shutter.lIssued = false;
            
            % Calculate the exposure time
            % dSec = stValue.task.dose / this.uiFluxDensity.getFluxDensityCalibrated();
            
            if this.lUseMjPerCm2PerSecOverride
                dSec = stValue.task.dose / this.uiEditMjPerCm2PerSec.get();
            else
                dSec = stValue.task.dose / this.uiFluxDensity.getFluxDensityCalibrated();
            end
            
            % Set the shutter UI time (ms)
            this.uiShutter.uiShutter.setDestCal(...
                dSec * 1e3, ...
                'ms' ...
            );
            % Trigger the shutter UI
            this.uiShutter.uiShutter.moveToDest();
           
            this.stScanAcquireContract.shutter.lIssued = true;
            
            if isfield(stValue, 'task')
                % Store the state of the system
                stState = this.getState(stUnit);
                stState.dose_mj_per_cm2 = stValue.task.dose;
                this.ceValues{end + 1} = stState;
            end
            
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
                                
                                if this.lUseMjPerCm2PerSecOverride
                                    dSec = stValue.task.dose / this.uiEditMjPerCm2PerSec.get();
                                else
                                    dSec = stValue.task.dose / this.uiFluxDensity.getFluxDensityCalibrated();
                                end
                                
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
                                 
                            otherwise
                                
                                % UNSUPPORTED
                                
                        end
                        
                        
                        if lReady
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
                
                % Write to log
                
                if lDebug
                    this.msg(sprintf('%s adding exposure to GUI', cFn), this.u8_MSG_TYPE_SCAN);
                end
                
                dXStageMm = this.uiStageWafer.uiX.getValCal(stUnit.xWafer); % mm
                dXWafer = -dXStageMm * 1e-3 + this.dXChiefRay; % m % position of exposure on wafer

                dYStageMm = this.uiStageWafer.uiY.getValCal(stUnit.yWafer); % mm
                dYWafer = -dYStageMm * 1e-3 + this.dYChiefRay; % m % position of exposure on wafer
                                    
                                    
                % Could also use stValue.xWafer / 1000, stValue.yWafer / 1000
                dExposure = [
                    dXWafer ...
                    dYWafer ...
                    this.uiFluxDensity.uiDiode.uiPopupAperture.get().dWidth * 1e-3, ...
                    this.uiFluxDensity.uiDiode.uiPopupAperture.get().dHeight * 1e-3, ...
                    stValue.task.dose ...
                ];
                this.exposures.addExposure(dExposure);
                
                dTic = tic;
                this.saveScanResultsCsv(stUnit);
                dToc = toc(dTic);

                cMsg = sprintf('% saveScanResultsCsv() elapsed time = %1.3f', cFn, dToc);
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
            
                drawnow;
                
                % 2018.11.15  
                this.pauseScanIfCurrentOfALSIsTooLow()
                
                
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
        
        % Save 1 kHz DMI data collected during the shutter is open
        
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
             
             this.onClickClearPrescriptions([], []);
             
             if this.uicWaferLL.get()
                 % FIX ME
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
            
            % Build the recipe from .json file (we dogfood our own .json recipes always)

            cFile = this.getPathRecipe();  

            % Create a new folder to save results
            this.cDirScan = this.getDirScan();

            [stRecipe, lError] = this.buildRecipeFromFile(cFile); 

            if lError 
                this.abort('There was an error building the scan recipe from the .json file.');
                return;
            end

            this.ceValues = cell(0); % cell(size(stRecipe.values));
            this.ceValuesFast = cell(0);

            this.scan = mic.Scan(...
                [this.cName, 'scan'], ...
                this.clock, ...
                stRecipe, ...
                @this.onScanSetState, ...
                @this.onScanIsAtState, ...
                @this.onScanAcquire, ...
                @this.onScanIsAcquired, ...
                @this.onScanComplete, ...
                @this.onScanAbort, ...
                0.25 ... % Need larger than any hardware cache periods (PPMAC is 0.2 s)
            );

            this.scan.start();
            
        end

        
        function abort(this, cMsg)
                           
            if exist('cMsg', 'var') ~= 1
                cMsg = 'The FEM was aborted.';
            end
            
            this.onClickClearPrescriptions([], []);
            
             
            cMsg = sprintf('The FEM was aborted. The list of added prescriptions has been purged.');
            cTitle = 'Fem Aborted';
            cIcon = 'help';
            h = msgbox(cMsg, cTitle, cIcon, 'modal');  
            
            % wait for them to close the message
            % uiwait(h);
            
            this.msg(sprintf('The FEM was aborted: %s', cMsg));
            
            % Write to logs.

            this.uiScan.reset();
            
        end
        
        function createNewLog(this)
            
            % Close existing log file
            
        end
        
        
        function lReturn = preCheck(this)
           
            
            this.msg('preCheck');
            % Make sure at least one prescription is selected
            
            if (isempty(this.uiListActive.get()))
                this.abort('No prescriptions were added. Please add a prescription before starting the FEM.');
                lReturn = false;
                return;
            end
                        
            cMsg = '';
            
            % Check if any hardware is virtualized
            
            if ~this.hardware.getIsConnectedRigolDG1000Z()
                cMsg = sprintf('%s\n%s', cMsg, 'Rigol DG100Z (Shutter Signal Generator)');
            end
            
            if ~this.hardware.getIsConnectedDCTWaferStage()
                cMsg = sprintf('%s\n%s', cMsg, 'DCT Wafer Stage');
            end
            
            if ~this.hardware.getIsConnectedDCTApertureStage()
                cMsg = sprintf('%s\n%s', cMsg, 'DCT Aperture Stage');
            end
            
            if ~this.hardware.getIsConnectedSR570DCT1()
                cMsg = sprintf('%s\n%s', cMsg, 'SR570 Current Preamp DCT1');
            end
            
            if ~this.hardware.getIsConnectedSR570DCT2()
                cMsg = sprintf('%s\n%s', cMsg, 'SR570 Current Preamp DCT2');
            end
            
            if ~this.hardware.getIsConnectedDataTranslation()
                cMsg = sprintf('%s\n%s', cMsg, 'Data Translation (Volts From SR570)');
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
        

        
        function lOut = validateRecipe(this, stRecipe)
            % FIX ME
            lOut = true;            
        end
        
        
        function updateUiScanStatus(this)
           this.uiScan.setStatus(this.scan.getStatus()); 
        end
        

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
                        case {'time', 'aperture', 'sensitivity_sr570'}
      
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
            c = fullfile(...
                this.uiPrescriptions.uiListPrescriptions.getDir(), ...
                cePrescriptions{1} ...
            );

                
        end
        
        
        function st = getState(this, stUnit)
            
        	st = struct();
            
            st.als_current_ma = 500; % FIX ME
            st.exit_slit_um = this.uiBeamline.uiExitSlit.uiGap.getValCal('um');
            st.undulator_gap_mm = this.uiBeamline.uiUndulatorGap.getValCal('mm');
            st.wavelength_nm = this.uiBeamline.uiGratingTiltX.getValCal('wav (nm)');
            
            st.x_wafer_mm = this.uiStageWafer.uiX.getValCal('mm');
            st.y_wafer_mm = this.uiStageWafer.uiY.getValCal('mm');
            
            st.x_aperture_mm = this.uiStageAperture.uiX.getValCal('mm');
            st.y_aperture_mm = this.uiStageAperture.uiY.getValCal('mm');
            
            st.shutter_ms = this.uiShutter.uiShutter.getDestCal('ms');
            st.sensitivity_sr570 = this.uiFluxDensity.uiDiode.uiPopupSensitivity.get().cLabel;
            st.aperture = this.uiFluxDensity.uiDiode.uiPopupAperture.get().cLabel;
            st.flux_mj_per_cm2_per_s = this.uiFluxDensity.uiDiode.getFluxDensity();
            
            st.time = datestr(datevec(now), 'yyyy-mm-dd HH:MM:SS', 'local');

        end
        
        
        
        

    end 
    
    
end