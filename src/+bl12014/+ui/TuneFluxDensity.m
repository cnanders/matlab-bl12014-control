classdef TuneFluxDensity < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 700 %1295
        dHeight     = 730
        
        dWidthNameComm = 100;
        dPeriodOfScan = 0.5;
        cNameOfConfigFile = 'tune-flux-density-coordinates.json'
    end
    
	properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommConnectAll
        
        uiHeightSensorLeds

        uiTabGroup
                
        uiStageWaferCoarse
        uiStageReticleCoarse
        uiAxesWafer
        uiAxesReticle
        uiDiode
        uiShutter
        uiUndulatorGap
        uiExitSlit
        
                
        % Must pass in
        waferExposureHistory
        uiScannerMA
        uiScannerM142
        
        uiSequencePrep
        uiStateReticleAtClearField
        uiStateWaferAtDiode
        uiStateHeightSensorLEDsOff
        uiStateShutterOpen
        uiStateMAScanningAnnular3585
        uiStateM142ScanningDefault
        
    end
    
    properties (SetAccess = private)
        
        hPanel
        cName = 'tune-flux-density-'
        
        % {struct 1x1} stores config date loaded from +bl12014/config/tune-flux-density-coordinates.json
        stConfig
        
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
            
            this.uiAxesReticle.build(hTab, dLeft, dTop);            
            % dTop = dTop + this.uiAxesReticle.dHeight + dPad;
            
            this.uiAxesWafer.build(hTab, 480, dTop);
            
        end
        
        function buildTab2(this)
            
            % Tab (Tune)
            
            % hTab = this.uiTabGroup.getTabByIndex(2);
            hTab = this.hPanel;
            dLeft = 10;
            dTop = 15;
            dSep = 30;
            dPad = 10;
            
                        
            this.uiCommConnectAll.build(hTab, dLeft, dTop);
            dTop = dTop + dSep;
            
            
            
            dWidthTask = 300;
            this.uiSequencePrep.build(hTab, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
            
            this.uiStateReticleAtClearField.build(hTab, 10, dTop, dWidthTask);
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
                        
            this.uiDiode.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiDiode.dHeight + dPad;
            
            this.uiShutter.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiShutter.dHeight + dPad;
            
            this.uiExitSlit.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiExitSlit.dHeight + dPad;
            
            
            this.uiUndulatorGap.build(hTab, dLeft, dTop);
            dTop = dTop + 24 + dPad;
            
            %{
            this.uiHeightSensorLeds.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiHeightSensorLeds.dHeight + dPad;
            %}
            
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
            
            delete(this.uiCommConnectAll)
            
            delete(this.uiStateM142ScanningDefault);
            delete(this.uiStateMAScanningAnnular3585);
            delete(this.uiStateReticleAtClearField);
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
           
            this.initUiCommConnectAll();
            
            this.uiExitSlit = bl12014.ui.ExitSlit(...
                'hardware', this.hardware, ...
                'clock', this.uiClock);
            
            this.initUiDeviceUndulatorGap(); % BL1201 Corba Proxy
        
            
            this.uiShutter = bl12014.ui.Shutter(...
                'cName', [this.cName, 'shutter'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );


            dHeight = 410;
            this.uiAxesWafer = bl12014.ui.WaferAxes( ...
                'cName', [this.cName, 'wafer-axes'], ...
                'clock', this.uiClock, ...
                'fhGetIsShutterOpen', @() this.uiShutter.uiOverride.get(), ...
                'fhGetXOfWafer', @() this.uiStageWaferCoarse.uiX.getValCal('mm') / 1000, ...
                'fhGetYOfWafer', @() this.uiStageWaferCoarse.uiY.getValCal('mm') / 1000, ...
                'waferExposureHistory', this.waferExposureHistory, ...
                'dWidth', dHeight, ...
                'dHeight', dHeight ...
            );
        
        
            dHeight = 410;
            this.uiAxesReticle = bl12014.ui.ReticleAxes( ...
                'cName', [this.cName, 'reticle-axes'], ...
                'clock', this.uiClock, ...
                'fhGetIsShutterOpen', @() this.uiShutter.uiOverride.get(), ...
                'fhGetX', @() this.uiStageReticleCoarse.uiX.getValCal('mm') / 1000, ...
                'fhGetY', @() this.uiStageReticleCoarse.uiY.getValCal('mm') / 1000, ...
                'dWidth', dHeight, ...
                'dHeight', dHeight ...
            );
        
            

                        
            this.uiStateReticleAtClearField = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-reticle-at-clear-field'], ...
                'task', bl12014.Tasks.createStateReticleStageAtClearField(...
                    [this.cName, 'state-reticle-at-clear-field'], ...
                    this.uiStageReticleCoarse, ...
                    this.clock ...
                ), ...
                'lShowButton', false, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateWaferAtDiode = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-wafer-at-diode'], ...
                'task', bl12014.Tasks.createStateWaferStageAtDiode(...
                    [this.cName, 'state-wafer-at-diode'], ...
                    this.uiStageWaferCoarse, ...
                    this.clock ...
                ), ...
                'lShowButton', false, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateHeightSensorLEDsOff = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-height-sensor-leds-off'], ...
                'task', bl12014.Tasks.createStateHeightSensorLEDsOff(...
                    [this.cName, 'state-height-sensor-leds-off'], ...
                    this.uiHeightSensorLeds, ...
                    this.clock ...
                ), ...
                'lShowButton', false, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateShutterOpen = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-shutter-is-open'], ...
                'task', bl12014.Tasks.createStateShutterIsOpen(...
                    [this.cName, 'state-shutter-is-open'], ...
                    this.uiShutter, ...
                    this.clock ...
                ), ...
                'lShowButton', false, ...
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
                    this.uiStageReticleCoarse, ...
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

        end
        
        
        
       
        
        
        
        
        
        
        
        function l = onGet(this)
            l = this.uiExitSlit.uiCommExitSlit.get() && ...
                this.uiShutter.uiCommRigol.get() && ...
                this.uiHeightSensorLeds.uiCommMightex.get();
        end
        
        function onSet(this, lVal)
            

            this.uiExitSlit.uiCommExitSlit.set(lVal);
            this.uiShutter.uiCommRigol.set(lVal);
            this.uiHeightSensorLeds.uiCommMightex.set(lVal);
        end
        
        function initUiCommConnectAll(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            
            this.uiCommConnectAll = mic.ui.device.GetSetLogical(...
                'clock', this.uiClock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', this.dWidthNameComm, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', [this.cName, 'connect-all'], ...
                'lUseFunctionCallbacks', true, ...
                'fhIsVirtual', @() false, ...
                'fhGet', @this.onGet, ...
                'fhSet', @this.onSet, ...
                'cLabel', 'All' ...
            );
        
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
        
        
        
        
        
    end % private
    
    
end