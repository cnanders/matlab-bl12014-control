classdef TuneFluxDensity < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 700 %1295
        dHeight     = 800
        
        dPeriodOfScan = 0.5;
        cNameOfConfigFile = 'tune-flux-density-coordinates.json'
    end
    
	properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        
        uiHeightSensorLeds

        uiTabGroup
                
        uiStageWaferCoarse
        uiStageReticleCoarse
        
        uiReticle
        
        uiDiode
        uiShutter
        uiUndulatorGap
        uiExitSlit
        uiGratingTiltX
        
        uiMotMinSimple
        
                
        % Must pass in
        waferExposureHistory
        uiScannerMA
        uiScannerM142
        
        uiSequencePrep
        uiStateMonoGratingAtEUV
        uiStateReticleAtClearField
        uiStateReticleLevel
        uiStateWaferAtDiode
        uiStateHeightSensorLEDsOff
        uiStateShutterOpen
        uiStateMAScanningAnnular3585
        uiStateM142ScanningDefault
        uiStateUndulatorIsCalibrated
        
        
        % {figure handle 1x1} returned by waitbar()
        hWaitbar
        
        % {logical 1x1} true when save is aborted. rest to true when save
        % clicked
        lAbortSave
        
        uiButtonSave
        uiButtonCancelSave
        uiButtonConfirmSave
        uiButtonRedoSave
        
        hFigureSave
        hAxesSave
        hPlotSave
        uiTextSaveGapOfUndulator
        uiTextSaveGapOfExitSlit
        uiTextSaveValue
        uiTextSaveMean
        uiTextSaveStd
        uiTextSavePV
        uiProgressBarSave
        
        uiTextTimeCalibrated
        uiTextFluxDensityCalibrated
        uiTextGapOfUndulatorCalibrated
        uiTextGapOfExitSlitCalibrated
                
    end
    
    properties (SetAccess = private)
        
        hPanel
        cName = 'tune-flux-density-'
        
        % {struct 1x1} stores config date loaded from +bl12014/config/tune-flux-density-coordinates.json
        stConfig
        cDirSave
    end
    
    properties (Access = private)
                      
        clock
        uiClock
        dDelay = 0.5
        
        hProgress
        
        % {mic.Scan 1x1}
        scan
        
        
        % {bl12014.Hardware 1x1}
        hardware
        
        dFluxDensityAcc = [] % accumulated during calibration
        
        dFluxDensityCalibrated = 0
        dGapOfUndulatorCalibrated = 40.24
        dGapOfExitSlitCalibrated = 300
        dtTimeCalibrated = 'Never';
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = TuneFluxDensity(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSave = fullfile( ...
                cDirThis, ...
                '..', ...
                '..', ...
                'save', ...
                'flux-density' ...
            );
            
        
            if ~isa(this.uiGratingTiltX, 'mic.ui.device.GetSetNumber')
                    error('uiGratingTiltX must be mic.ui.device.GetSetNumber');
            end
            if ~isa(this.uiReticle, 'bl12014.ui.Reticle')
                    error('uiReticle must be bl12014.ui.Reticle');
            end
            
            if ~isa(this.uiScannerMA, 'bl12014.ui.Scanner')
                error('uiScannerMA must be bl12014.ui.Scanner');
            end
            
            if ~isa(this.uiScannerM142, 'bl12014.ui.Scanner')
                error('uiScannerM142 must be bl12014.ui.Scanner');
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
            
        end
        
        % Returns mJ/cm2/s flux density value currently loaded / saved
        % @return {double 1x1} flux density in mJ/cm2/s
        function d = getFluxDensityCalibrated(this)
            d = this.dFluxDensityCalibrated;
        end
        
        % Returns gap of the undulator in mm that was set when the last
        % flux density calibration was performend and saved.  The gap of
        % the undulaotr will need to be this durin exposures
        % @return {double 1x1} gap of undulator in mm
        function d = getGapOfUndulatorCalibrated(this)
            d = this.dGapOfUndulatorCalibrated;
        end
        
        % Returns gap of the exit slit in um that was set when the last
        % flux density calibration was performend and saved.  The gap of
        % the exit slit will need to be this during exposures
        % @return {double 1x1} gap of exit slit in um
        function d = getGapOfExitSlitCalibrated(this)
            d = this.dGapOfExitSlitCalibrated;
        end
        
        % Returns {char 1xm} time yyyy-mm-dd--hh-mm-ss when the last 
        % flux density calibration was performed
        function c = getTimeCalibrated(this)
            c = this.dtTimeCalibrated;
        end
        
        
        
        
        
        

        function buildTab1(this)
            
            % Tab (Stages)
            
            dLeft = 10;
            dTop = 45;
            dPad = 10;
            dSep = 30;
            
            hTab = this.uiTabGroup.getTabByIndex(1);
             
            
            dTop = dTop + dSep;
            
            this.uiStageWaferCoarse.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiStageWaferCoarse.dHeight + dPad;
            
            
            this.uiStageReticleCoarse.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiStageReticleCoarse.dHeight + dPad;
            
            
        end
        
        function buildTab2(this)
            
            % Tab (Tune)
            
            % hTab = this.uiTabGroup.getTabByIndex(2);
            hTab = this.hPanel;
            dLeft = 10;
            dTop = 15;
            dSep = 30;
            dPad = 10;
                        
            dWidthTask = 300;
            this.uiSequencePrep.build(hTab, 10, dTop, 600);
            dTop = dTop + dSep;
            
            this.uiMotMinSimple.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiMotMinSimple.dHeight + dPad;
            
            this.uiStateMonoGratingAtEUV.build(hTab, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
            
            this.uiStateReticleAtClearField.build(hTab, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
            
            this.uiStateReticleLevel.build(hTab, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
            
            this.uiStateWaferAtDiode.build(hTab, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
            
            this.uiStateHeightSensorLEDsOff.build(hTab, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
            
            this.uiStateMAScanningAnnular3585.build(hTab, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
            
            this.uiStateM142ScanningDefault.build(hTab, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
            
            this.uiStateShutterOpen.build(hTab, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
                        
            
            dTopLast = dTop;
            
            dTop = 100;
            dSep = 25;
            dWidthText = 200;
            dHeightText = 14;
            dSep = 5;
            dLeft = 380;
            
            this.uiTextTimeCalibrated.build(hTab, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextFluxDensityCalibrated.build(hTab, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextGapOfUndulatorCalibrated.build(hTab, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextGapOfExitSlitCalibrated.build(hTab, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            this.uiStateUndulatorIsCalibrated.build(hTab, dLeft, dTop, 300)
            
            
            dTop = dTopLast;
            dLeft = 10;
            
            this.uiDiode.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiDiode.dHeight + dPad;
            
            this.uiShutter.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiShutter.dHeight + dPad;
            
            this.uiExitSlit.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiExitSlit.dHeight + dPad;
            
            
            this.uiUndulatorGap.build(hTab, dLeft, dTop);
            dTop = dTop + 24 + dPad;
            
            dTop = dTop + 10
            this.uiButtonSave.build(hTab, dLeft + 350, dTop, 300, 48);
            dTop = dTop + 24 + dPad;
            
            %{
            this.uiHeightSensorLeds.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiHeightSensorLeds.dHeight + dPad;
            %}
            
            this.buildSaveModal();
            
        end
        
        
        function build(this, hParent, dLeft, dTop)
                    
            
            % this.uiTabGroup.build(hParent, dLeft, dTop, this.dWidth, this.dHeight);

            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', '',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
            % this.buildTab1();
            this.buildTab2();
            
        end
        
        
                        
        
        %% Destructor
        
        
        
        function delete(this)
                        
            delete(this.uiStateM142ScanningDefault);
            delete(this.uiStateMAScanningAnnular3585);
            delete(this.uiStateReticleAtClearField);
            delete(this.uiStateReticleLevel);
            delete(this.uiStateShutterOpen);
            delete(this.uiStateWaferAtDiode);
            delete(this.uiStateHeightSensorLEDsOff);
            delete(this.uiSequencePrep);
            
            %delete(this.uiScannerM142)
            %delete(this.uiScannerMA);
            delete(this.uiShutter);
            delete(this.uiExitSlit);
                        
        end
        
        function st = save(this)
            st = struct();
            st.uiStageWaferCoarse = this.uiStageWaferCoarse.save();
            st.uiStageReticleCoarse = this.uiStageReticleCoarse.save();
            
        end
        
        function load(this, st)
            if isfield(st, 'uiStageWaferCoarse')
                this.uiStageWaferCoarse.load(st.uiStageWaferCoarse)
            end
            
            if isfield(st, 'uiStageReticleCoarse')
                this.uiStageReticleCoarse.load(st.uiStageReticleCoarse)
            end
        end
               
    end
    
    methods (Access = private)
        
        function init(this)
            
            % Init config
            cDirThis = fileparts(mfilename('fullpath'));

            this.stConfig = loadjson(fullfile(cDirThis, '..', '..', 'config', this.cNameOfConfigFile));
            
            this.msg('init()');
            
            
            cecNames = {...
                'Position Wafer + Reticle Stages', ...
                'Tune Exit Slit + Undulator' ...
            };
        
%             cefhCallbacks = { ...
%                 @this.onUiTabStages, ...
%                 @this.onUiTabTune ...
%             };
%         
            this.uiTabGroup = mic.ui.common.Tabgroup(...
                ... % 'fhDirectCallback', cefhCallbacks, ...
                'ceTabNames',  cecNames ...
            );
        
        
            this.uiHeightSensorLeds = bl12014.ui.HeightSensorLEDs(...
                'cName', [this.cName, 'height-sensor-leds'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
            
            
            this.uiStageWaferCoarse = bl12014.ui.WaferCoarseStage(...
                'hardware', this.hardware, ...
                'cName', [this.cName, 'stage-wafer-coarse'], ...
                'clock', this.uiClock ...
            );
        
            this.uiStageReticleCoarse = bl12014.ui.ReticleCoarseStage(...
                'hardware', this.hardware, ...
                'cName', [this.cName, 'stage-reticle-coarse'], ...-
                'clock', this.uiClock ...
            );
        
            
        
        
            
        
            this.uiDiode = bl12014.ui.WaferDiode(...
                'cName', [this.cName, 'diode-wafer'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
           
            
            this.uiExitSlit = bl12014.ui.ExitSlit(...
                'hardware', this.hardware, ...
                'clock', this.uiClock);
            
            this.initUiDeviceUndulatorGap(); % BL1201 Corba Proxy
        
            
            this.uiShutter = bl12014.ui.Shutter(...
                'cName', [this.cName, 'shutter'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );


            this.uiStateMonoGratingAtEUV = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-mono-grating-at-euv'], ...
                'task', bl12014.Tasks.createStateMonoGratingAtEUV(...
                    [this.cName, 'state-mono-grating-at-euv'], ...
                    this.uiGratingTiltX, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
                        
            this.uiStateReticleAtClearField = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-reticle-at-clear-field'], ...
                'task', bl12014.Tasks.createStateReticleStageAtClearField(...
                    [this.cName, 'state-reticle-at-clear-field'], ...
                    this.uiReticle.uiReticleFiducializedMove, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateReticleLevel = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-reticle-reticle-level'], ...
                'task', bl12014.Tasks.createSequenceLevelReticle(...
                    [this.cName, 'state-reticle-level'], ...
                    this.uiReticle.uiReticleTTZClosedLoop, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateWaferAtDiode = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-wafer-at-diode'], ...
                'task', bl12014.Tasks.createStateWaferStageAtDiode(...
                    [this.cName, 'state-wafer-at-diode'], ...
                    this.uiStageWaferCoarse, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateHeightSensorLEDsOff = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-height-sensor-leds-off'], ...
                'task', bl12014.Tasks.createStateHeightSensorLEDsOff(...
                    [this.cName, 'state-height-sensor-leds-off'], ...
                    this.uiHeightSensorLeds, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateShutterOpen = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-shutter-is-open'], ...
                'task', bl12014.Tasks.createStateShutterIsOpen(...
                    [this.cName, 'state-shutter-is-open'], ...
                    this.uiShutter, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateMAScanningAnnular3585 = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-ma-is-scanning-annular'], ...
                'task', bl12014.Tasks.createStateMAScanningAnnular3585(...
                    [this.cName, 'state-ma-is-scanning-annular'], ...
                    this.uiScannerMA.uiNPointLC400, ...
                    this.clock ...
                ), ...
                'lShowButton', false, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateM142ScanningDefault = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-m142-is-scanning-default'], ...
                'task', bl12014.Tasks.createStateM142ScanningDefault(...
                    [this.cName, 'state-m142-is-scanning-default'], ...
                    this.uiScannerM142.uiNPointLC400, ...
                    this.clock ...
                ), ...
                'lShowButton', false, ...
                'clock', this.uiClock ...
            );
        
        
            this.uiSequencePrep = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-sequence-prep-for-tuning-flux-density'], ...
                'task', bl12014.Tasks.createSequencePrepForTuningFluxDensity(...
                    [this.cName, 'sequence-prep-for-tuning-flux-density'], ...
                    this.uiReticle.uiReticleFiducializedMove, ...
                    this.uiReticle.uiReticleTTZClosedLoop, ...
                    this.uiStageWaferCoarse, ...
                    this.uiHeightSensorLeds, ...
                    this.uiScannerMA, ...
                    this.uiScannerM142, ...
                    this.uiShutter, ...
                    this.clock ...
                ), ...
                'lShowIsDone', false, ...
                'clock', this.uiClock ...
            );
        
            this.uiButtonSave = mic.ui.common.Button(...
                'fhOnClick', @this.onClickSave, ...
                'cText', 'Record mJ/cm2/s and Save Calibration' ...
            );
        
            this.uiButtonCancelSave = mic.ui.common.Button(...
                'fhOnClick', @this.onClickCancelSave, ...
                'cText', 'Cancel' ...
            );
        
            this.uiButtonConfirmSave = mic.ui.common.Button(...
                'fhOnClick', @this.onClickConfirmSave, ...
                'cText', 'Save This Calibration' ...
            );
        
            this.uiButtonRedoSave = mic.ui.common.Button(...
                'fhOnClick', @this.onClickSave, ...
                'cText', 'Redo' ...
            );
            
            this.uiTextSaveGapOfUndulator = mic.ui.common.Text(...
                'cVal', 'Gap of Undulator', ...
                'dFontSize', 14, ...
                'cFontWeight', 'bold' ...
            );
            this.uiTextSaveGapOfExitSlit = mic.ui.common.Text(...
                'cVal', 'Gap of Exit Slit', ...
                'dFontSize', 14, ...
                'cFontWeight', 'bold' ...
            );
            this.uiTextSaveValue = mic.ui.common.Text(...
                'cVal', 'Value');
            this.uiTextSaveMean = mic.ui.common.Text(...
                'cVal', 'Mean', ...
                'dFontSize', 14, ...
                'cFontWeight', 'bold' ...
            );
            this.uiTextSaveStd = mic.ui.common.Text(...
                'cVal', 'Std');
            this.uiTextSavePV = mic.ui.common.Text(...
                'cVal', 'PV');
            this.uiProgressBarSave = mic.ui.common.ProgressBar();
        
            
            this.uiTextTimeCalibrated = mic.ui.common.Text(...
                'cVal', 'Last Calibration:');
            this.uiTextFluxDensityCalibrated = mic.ui.common.Text(...
                'cVal', 'Flux Density: ');
            this.uiTextGapOfUndulatorCalibrated = mic.ui.common.Text(...
                'cVal', 'Gap of Undulator:');
            this.uiTextGapOfExitSlitCalibrated = mic.ui.common.Text(...
                'cVal', 'Gap of Exit Slit:');
            
            this.uiStateUndulatorIsCalibrated = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-undulator-is-calibrated'], ...
                'task', bl12014.Tasks.createStateUndulatorIsCalibrated(...
                    [this.cName, 'state-undulator-is-calibrated'], ...
                    this, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
        
            this.uiMotMinSimple = bl12014.ui.PowerPmacHydraMotMinSimple(...
                'cName', [this.cName, 'power-pmac-hydra-mot-min-simple'], ...
                'hardware', this.hardware, ...
                'uiClock', this.uiClock, ...
                'clock', this.clock ...
            );
        
        
        
            this.loadLastFluxCalibration();
        end
        
        
        
       
        
        
        
        
        
        
        
        
        
       
        
       
        
        
        
        function initUiDeviceUndulatorGap(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-undulator-gap.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiUndulatorGap = mic.ui.device.GetSetNumber(...
                'clock', this.uiClock, ...
                'lShowLabels', false, ...
                'dWidthName', 150, ...
                ... % 'dWidthUnit', this.dWidthUiDeviceUnit, ...
                'fhGet', @() this.hardware.getBL1201CorbaProxy().SCA_getIDGap(), ...
                'fhSet', @(dVal) this.hardware.getBL1201CorbaProxy().SCA_setIDGap(dVal), ...
                'fhIsReady', @() ~this.hardware.getBL1201CorbaProxy().SCA_getIDMotionComplete(), ...
                'fhStop', @() [], ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'gap-of-undulator'], ...
                'config', uiConfig, ...
                'cLabel', 'Undulator Gap' ...
            );
        
        end
        
        
        
        
        
        function setMotMinToMax(this)
                        
        end
        
        function l = isReadyMotMin(this)
           l = true; 
        end
        
        function setWorkingModeToUndefined(this)
            
        end
        
        function l = isWorkingModeUndefined(this)
           l = true; 
        end
        
        function setWorkingModeToActivate(this)
            
        end
        
        function l = isWorkingModeActivate(this)
            l = true;
        end
        
        
        function l = isReticleStageInPosition(this)
        
               l =  abs(this.stConfig.xReticle.value - this.uiStageReticleCoarse.uiX.getValCal(this.stConfig.xReticle.unit)) <= ...
                        this.stConfig.xReticle.displayTol && ...
                    abs(this.stConfig.yReticle.value - this.uiStageReticleCoarse.uiY.getValCal(this.stConfig.yReticle.unit)) <= ...
                        this.stConfig.yReticle.displayTol && ...
                    abs(this.stConfig.zReticle.value - this.uiStageReticleCoarse.uiZ.getValCal(this.stConfig.zReticle.unit)) <= ...
                        this.stConfig.zReticle.displayTol;
        
        end
        
        function l = isWaferStageInPosition(this)
        
               l =  abs(this.stConfig.xWafer.value - this.uiStageWaferCoarse.uiX.getValCal(this.stConfig.xWafer.unit)) <= ...
                        this.stConfig.xWafer.displayTol && ...
                    abs(this.stConfig.yWafer.value - this.uiStageWaferCoarse.uiY.getValCal(this.stConfig.yWafer.unit)) <= ...
                        this.stConfig.yWafer.displayTol && ...
                    abs(this.stConfig.zWafer.value - this.uiStageWaferCoarse.uiZ.getValCal(this.stConfig.zWafer.unit)) <= ...
                        this.stConfig.zWafer.displayTol;
        
        end
        
        function l = isInPosition(this)
            l = this.isReticleStageInPosition() && this.isWaferStageInPosition();
        end
        
        function cancelSave(this)
            % close(this.hWaitbar)
            this.hideSaveModal();
            this.lAbortSave = true;
        end
        
        function hideSaveModal(this)
            
            
            if ~ishandle(this.hFigureSave)
                return
            end
            %{
            delete(this.hPlotSave);
            delete(this.hFigureSave)
            %}
            
            set(this.hFigureSave, 'Visible', 'off');
            
            
            
            
        end
        
        function buildSaveModal(this)
            
            
            % Build it the first time
            
            dWidthFigure = 500;
            dHeightFigure = 430;
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigureSave = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name', 'Averaging Flux Density for 10 Seconds',...
                'Position', [ ...
                (dScreenSize(3) - dWidthFigure)/2 ...
                (dScreenSize(4) - dHeightFigure)/2 ...
                dWidthFigure ...
                dHeightFigure ...
                ],... % left bottom width height
                'CloseRequestFcn', @this.onClickCancelSave, ... 
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                ... % 'CloseRequestFcn', @this.onCloseRequest, ...
                ... Default to not visible, show when user clicks "Save"
                'Visible', 'off'... % def
            );
                    
            dTop = 30;
            dLeft = 70;
            dWidthAxes = 400;
            dHeightAxes = 200;
            
            this.hAxesSave = axes(...
                'Parent', this.hFigureSave,...
                'Units', 'pixels',...
                'Position',mic.Utils.lt2lb([...
                    dLeft, ...
                    dTop, ...
                    dWidthAxes,...
                    dHeightAxes], this.hFigureSave),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                'DataAspectRatio',[1 1 1],...
                'HandleVisibility','on'...
           );
            dTop = dTop + dHeightAxes + 50;
            
            dTopTexts = dTop;
            dLeft = 30;
            dWidthText = 300;
            dHeightText = 20;
            dSep = 5;
            
            
            this.uiTextSaveMean.build(this.hFigureSave, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextSaveGapOfUndulator.build(...
                this.hFigureSave, ...
                dLeft, ...
                dTop, ...
                dWidthText, ...
                dHeightText ...
            );
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextSaveGapOfExitSlit.build(...
                this.hFigureSave, ...
                dLeft, ...
                dTop, ...
                dWidthText, ...
                dHeightText ...
            );
            dTop = dTop + dHeightText + dSep;
            
            %{
            this.uiTextSaveValue.build(this.hFigureSave, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            %}
            
           
            dHeightText = 14;
            this.uiTextSaveStd.build(this.hFigureSave, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextSavePV.build(this.hFigureSave, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            
            this.uiTextSaveGapOfUndulator.hide();
            this.uiTextSaveGapOfExitSlit.hide();
            this.uiTextSaveValue.hide();
            this.uiTextSaveMean.hide();
            this.uiTextSaveStd.hide();
            this.uiTextSavePV.hide();
            
            
            dTop = dTopTexts;
            dLeft = 240;
            dWidthButton = 100;
            dSep = 10;
            
            dLeft = 350;
            this.uiButtonCancelSave.build(...
                this.hFigureSave, ...
                dLeft, ...
                dTop, ...
                100, ...
                24 ...
            );
            dTop = dTop + 24;
            
            this.uiButtonRedoSave.build(...
                this.hFigureSave, ...
                dLeft, ...
                dTop, ...
                dWidthButton, ...
                24 ...
            );
            dTop = dTop + 24;
            
            this.uiButtonConfirmSave.build(...
                this.hFigureSave, ...
                dLeft - 25, ...
                dTop, ...
                150, ...
                48 ...
            );
        
            this.uiButtonRedoSave.hide();
            this.uiButtonConfirmSave.hide();
            dTop = dTop + 24;
        
            dTop = dTop + 70;
            dLeft = 0;
            this.uiProgressBarSave.build(...
                this.hFigureSave, ...
                dLeft, ...
                dTop, ...
                dWidthFigure, ...
                10 ...
            );
            
            
        end
        
        function showSaveModal(this)
            
            if ishandle(this.hFigureSave)
                
                set(this.hFigureSave, 'Visible', 'on');
                this.uiTextSaveGapOfUndulator.hide();
                this.uiTextSaveGapOfExitSlit.hide();
                this.uiTextSaveValue.hide();
                this.uiTextSaveMean.hide();
                this.uiTextSaveStd.hide();
                this.uiTextSavePV.hide();
                this.uiButtonConfirmSave.hide();
                this.uiButtonRedoSave.hide();
                
            end
            
            

            
        end
        
        function onClickCancelSave(this, ~, ~)
            
            this.lAbortSave = true;
            this.hideSaveModal();
        end
        
        
        function onClickSave(this, ~, ~)
            
            % Build up an average flux density over 10 seconds
            % with a progress bar
            
            this.lAbortSave = false;
            this.showSaveModal();
            this.uiProgressBarSave.show();
            
%             this.hWaitbar = waitbar(...
%                 0, ...
%                 'Averaging flux density for 10 seconds ...', ...
%                 'CreateCancelBtn', @(src, evt) this.cancelSave() ...
%             );
        
            % Adjust the height
%             dPosition = get(this.hWaitbar, 'Position');
            
            % left bottom width height
%             set(this.hWaitbar, 'Position', [dPosition(1:3) 250]);
            
            this.dFluxDensityAcc = [];
            dNum = 20;
            for n = 1 : dNum
                
                if this.lAbortSave
                    return
                end
                
                this.dFluxDensityAcc(end + 1) = this.uiDiode.uiCurrent.getValCal("mJ/cm2/s (clear field)");
                                
                if isempty(this.hPlotSave)
                    this.hPlotSave = plot(1 : n, this.dFluxDensityAcc,'.-');
                    ylabel(this.hAxesSave, 'mJ/cm2/s');
                else
                    this.hPlotSave.XData = 1 : n;
                    this.hPlotSave.YData = this.dFluxDensityAcc;
                end
                
                this.uiProgressBarSave.set(n / dNum);
                
%                 waitbar(n / dNum, this.hWaitbar, cecMsg);
                pause(0.6);
            end
            
           %{ 
           cMsgValue = sprintf(...
                '%d of %d: %1.3f mJ/cm2/s', ...
                n, ...
                dNum, ...
                this.dFluxDensityAcc(end) ...
            );
            %}
            
            dMean = abs(mean(this.dFluxDensityAcc));
            dStd = std(this.dFluxDensityAcc);
            dPV = abs(max(this.dFluxDensityAcc) - min(this.dFluxDensityAcc));
            
            
            cMsgMean = sprintf(...
                'Avgeraging Complete: %1.1f mJ/cm2/s', ...
                dMean ...
            );
            cMsgUndulator = sprintf(...
                '@Undulator = %1.2f mm', ...
                this.uiUndulatorGap.getValCal('mm') ...
            );
            cMsgExitSlit = sprintf(...
                '@ExitSlit = %1.2f um', ...
                this.uiExitSlit.uiGap.getValCal('um') ...
            );
        
            
            cMsgStd = sprintf(...
                'Std = %1.1f%% (%1.3f mJ/cm2/s)', ...
                dStd / dMean  * 100, ...
                dStd...
            );
            cMsgPV = sprintf(...
                'PV = %1.1f%% (%1.3f mJ/cm2/s)', ...
                dPV / dMean * 100 , ...
                dPV...
            );
            
            
            this.uiTextSaveMean.set(cMsgMean);
            this.uiTextSaveGapOfUndulator.set(cMsgUndulator);
            this.uiTextSaveGapOfExitSlit.set(cMsgExitSlit);
            
            % this.uiTextSaveValue.set(cMsgValue);
            this.uiTextSaveStd.set(cMsgStd);
            this.uiTextSavePV.set(cMsgPV);
            
            
            this.uiTextSaveMean.show();
            this.uiTextSaveGapOfUndulator.show();
            this.uiTextSaveGapOfExitSlit.show();
            % this.uiTextSaveValue.show();
            this.uiTextSaveStd.show();
            this.uiTextSavePV.show();
            
            this.uiButtonRedoSave.show();
            this.uiButtonConfirmSave.show();
            this.uiProgressBarSave.hide();
            
            % close(this.hWaitbar);
            % this.hideSaveModal();
                            
        end
        
        function onClickConfirmSave(this, ~, ~)
            
            st = struct();
            st.dFluxDensity = abs(mean(this.dFluxDensityAcc));
            st.dGapOfUndulator = this.uiUndulatorGap.getValCal('mm');
            st.dGapOfExitSlit = this.uiExitSlit.uiGap.getValCal('um');
            st.dtTime = datetime('now');
            
            cTime = datestr(datevec(now), 'yyyy-mm-dd--HH-MM-SS', 'local');
            mic.Utils.checkDir(this.cDirSave);
            c = fullfile(...
                this.cDirSave, ...
                ['flux-density-calibration-', cTime , '.mat']...
            );
        
            % Save this to disk
            save(c, 'st');
            
            this.loadLastFluxCalibration();
            
            this.lAbortSave = true;
            this.hideSaveModal();
            
        end
        
        
        function loadLastFluxCalibration(this)
            
            
            cOrder = 'descend';
            cOrderByPredicate = 'date';
            % {char 1xm} - filter for dir2cell, e.g., '*.json'
            cFilter = '*.mat';
            
            ceReturn = mic.Utils.dir2cell(...
                this.cDirSave, ...
                cOrderByPredicate, ...
                cOrder, ...
                cFilter ...
            );
            
            if isempty(ceReturn)
                return
            end
            
            load(fullfile(this.cDirSave, ceReturn{1})); % populates variable st in local workspace
            
            this.dFluxDensityCalibrated = st.dFluxDensity;
            this.dGapOfUndulatorCalibrated = st.dGapOfUndulator;
            this.dGapOfExitSlitCalibrated = st.dGapOfExitSlit;
            this.dtTimeCalibrated = st.dtTime;
                        
            this.uiTextTimeCalibrated.set(sprintf('Last Calibration: %s', this.dtTimeCalibrated));
            this.uiTextFluxDensityCalibrated.set(sprintf('Flux Density: %1.1f mJ/cm2/s', this.dFluxDensityCalibrated));
            this.uiTextGapOfUndulatorCalibrated.set(sprintf('Gap of Undulator: %1.2f mm', this.dGapOfUndulatorCalibrated));            
            this.uiTextGapOfExitSlitCalibrated.set(sprintf('Gap of Exit Slit: %1.1f um', this.dGapOfExitSlitCalibrated));

        end
        
        
        
        
        
    end % private
    
    
end