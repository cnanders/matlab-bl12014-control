classdef TuneFluxDensity < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 1000 %1295
        dHeight     = 880
        
        dWidthNameComm = 100;
        dPeriodOfScan = 0.5;
        cNameOfConfigFile = 'tune-flux-density-coordinates.json'
    end
    
	properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommConnectAll
        uiCommDeltaTauPowerPmac
        uiCommKeithley6482
        uiCommBL1201CorbaProxy
        
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
        
        commDeltaTauPowerPmac = []
        commMfDriftMonitorMiddleware = []
        
        hardware % needed for MFDriftMonitor integration
        
        % Must pass in
        waferExposureHistory
    end
    
    properties (SetAccess = private)
        
        hParent
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
        
        uiButtonGo
        
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
            this.init();
            
            
        end
        
        function connectRigolDG1000Z(this, comm)
            
            device = bl12014.device.GetSetNumberFromRigolDG1000Z(comm, 1);
            this.uiShutter.setDevice(device);
            this.uiShutter.turnOn();
                      
        end
        
        function disconnectRigolDG1000Z(this)
            
            this.uiShutter.turnOff();
            this.uiShutter.setDevice([]);
   
        end
       
        
        function connectDeltaTauPowerPmac(this, comm)
                            
            this.commDeltaTauPowerPmac = comm;
            this.uiStageWaferCoarse.connectDeltaTauPowerPmac(comm);
            
        end
        
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.uiStageWaferCoarse.disconnectDeltaTauPowerPmac();
            this.commDeltaTauPowerPmac = [];
                        
        end
        

        
        
        function build(this, hParent, dLeft, dTop)
                    
            this.hParent = hParent;
            
            this.uiTabGroup.build(hParent, dLeft, dTop, this.dWidth, this.dHeight);


           

            
            % Tab (Stages)
            
            dLeft = 10;
            dTop = 20;
            dPad = 10;
            dSep = 30;
            
            hTab = this.uiTabGroup.getTabByIndex(1);
             
            this.uiCommDeltaTauPowerPmac.build(hTab, dLeft, dTop);
            
            this.uiButtonGo.build(hTab, 300, dTop, 300, 24);
            dTop = dTop + dSep;
            this.uiClock.add(@()this.setColorOfGoButton(), this.id(), 1);


            
            this.uiStageWaferCoarse.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiStageWaferCoarse.dHeight + dPad;
            
            
            this.uiStageReticleCoarse.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiStageReticleCoarse.dHeight + dPad;
            
            this.uiAxesReticle.build(hTab, dLeft, dTop);            
            % dTop = dTop + this.uiAxesReticle.dHeight + dPad;
            
            this.uiAxesWafer.build(hTab, 480, dTop);
                         
            % Tab (Tune)
            
            hTab = this.uiTabGroup.getTabByIndex(2);
            
            dLeft = 10;
            dTop = 15;
            
            this.uiCommConnectAll.build(hTab, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommKeithley6482.build(hTab, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiDiode.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiDiode.dHeight + dPad;
            
            this.uiShutter.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiShutter.dHeight + dPad;
            
            this.uiExitSlit.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiExitSlit.dHeight + dPad;
            
            
            this.uiCommBL1201CorbaProxy.build(hTab, dLeft, dTop);
            dTop = dTop + dSep;
            
            
            this.uiUndulatorGap.build(hTab, dLeft, dTop);
            dTop = dTop + 24 + dPad;
            
            this.uiHeightSensorLeds.build(hTab, dLeft, dTop);
            dTop = dTop + this.uiHeightSensorLeds.dHeight + dPad;
            
        end
        
        function connectBL1201CorbaProxy(this, comm)
            deviceUndulatorGap = bl12014.device.GetSetNumberFromBL1201CorbaProxy(...
                comm, ...
                bl12014.device.GetSetNumberFromBL1201CorbaProxy.cDEVICE_UNDULATOR_GAP ...
            );
            
            
            this.uiUndulatorGap.setDevice(deviceUndulatorGap)
            this.uiUndulatorGap.turnOn()
            this.uiUndulatorGap.syncDestination()

            
        end
        
        function disconnectBL1201CorbaProxy(this, comm)
            this.uiUndulatorGap.turnOff()
            this.uiUndulatorGap.setDevice([])
            
        end
                        
        
        %% Destructor
        
        function delete(this)
            
            delete(this.uiCommBL1201CorbaProxy)
            delete(this.uiCommKeithley6482)
            delete(this.uiCommDeltaTauPowerPmac)
                        
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
                'clock', this.uiClock ...
            );
            
            
            this.uiStageWaferCoarse = bl12014.ui.WaferCoarseStage(...
                'cName', [this.cName, 'stage-wafer-coarse'], ...
                'clock', this.uiClock ...
            );
        
            this.uiStageReticleCoarse = bl12014.ui.ReticleCoarseStage(...
                'cName', [this.cName, 'stage-reticle-coarse'], ...-
                'clock', this.uiClock ...
            );
        
            this.uiDiode = bl12014.ui.WaferDiode(...
                'cName', [this.cName, 'diode-wafer'], ...-
                'clock', this.uiClock ...
            );
           
            this.initUiCommConnectAll();
            this.initUiCommBL1201CorbaProxy();
            this.initUiCommDeltaTauPowerPmac();
            this.initUiCommKeithley6482();
            
            this.uiExitSlit = bl12014.ui.ExitSlit('clock', this.uiClock);
            
            this.initUiDeviceUndulatorGap(); % BL1201 Corba Proxy
        
            
            this.uiShutter = bl12014.ui.Shutter(...
                'cName', [this.cName, 'shutter'], ...
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
        
            
            this.uiButtonGo = mic.ui.common.Button('fhDirectCallback', @(~, ~)this.onClickGo(), 'cText', '...');

                        
            

        end
        
        
        
        function initUiCommDeltaTauPowerPmac(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommDeltaTauPowerPmac = mic.ui.device.GetSetLogical(...
                'clock', this.uiClock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', this.dWidthNameComm, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', [this.cName, 'delta-tau-power-pmac-wafer'], ...
                'cLabel', 'DeltaTau Power PMAC' ...
            );
        
        end
        
        
        
        
        
        function initUiCommKeithley6482(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommKeithley6482 = mic.ui.device.GetSetLogical(...
                'clock', this.uiClock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', this.dWidthNameComm, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', [this.cName, 'keithley-6482-wafer'], ...
                'cLabel', 'Keithley 6482 (Wafer)' ...
            );
        
        end
        
        
        function l = onGet(this)
            l = this.uiCommBL1201CorbaProxy.get() && ...
                this.uiCommDeltaTauPowerPmac.get() && ...
                this.uiCommKeithley6482.get() && ...
                this.uiExitSlit.uiCommExitSlit.get() && ...
                this.uiShutter.uiCommRigol.get() && ...
                this.uiHeightSensorLeds.uiCommMightex.get();
        end
        
        function onSet(this, lVal)
            
            this.uiCommBL1201CorbaProxy.set(lVal);
            this.uiCommDeltaTauPowerPmac.set(lVal);
            this.uiCommKeithley6482.set(lVal);
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
        
        function initUiCommBL1201CorbaProxy(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommBL1201CorbaProxy = mic.ui.device.GetSetLogical(...
                'clock', this.uiClock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', this.dWidthNameComm, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', [this.cName, 'bl1201-corba-proxy'], ...
                'cLabel', 'BL1201 Corba Proxy' ...
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
                'cName', [this.cName, 'gap-of-undulator'], ...
                'config', uiConfig, ...
                'cLabel', 'Undulator Gap' ...
            );
        
        end
        
        
        function onClickGo(this)
            
            
            if this.isInPosition() 
                return
            end
            
            this.hProgress = waitbar(0, 'Sending reticle to clear field and wafer to diode. Please wait...');

                        
            % Set up scanner
            fhSetState      = @(~, stState) stState.action();
            fhIsAtState     = @(~, stState) stState.isReady();
            fhAcquire       = @(~, stState) waitbar((stState.idx)/6, this.hProgress);
            fhIsAcquired    = @(~, stState) true;
            fhOnComplete    = @(~, stState) delete(this.hProgress);
            fhOnAbort       = @(~, stState) delete(this.hProgress);
            
            stateList = { ...
                % struct('idx', 1, 'action', @()this.setMotMinToMax(), 'isReady', @()this.uiStageReticleCoarse.uiX.isReady()), ...
                % struct('idx', 1, 'action', @()this.setMotMinToMax(), 'isReady', @()this.uiStageReticleCoarse.uiX.isReady()), ...
                struct('idx', 1, 'action', @()this.setXOfReticleAndGo(), 'isReady', @()this.uiStageReticleCoarse.uiX.isReady()), ...
                struct('idx', 2, 'action', @()this.setYOfReticleAndGo(), 'isReady', @()this.uiStageReticleCoarse.uiY.isReady()), ...
                struct('idx', 3, 'action', @()this.setZOfReticleAndGo(), 'isReady', @()this.uiStageReticleCoarse.uiZ.isReady()), ...
                struct('idx', 4, 'action', @()this.setXOfWaferAndGo(), 'isReady', @()this.uiStageWaferCoarse.uiX.isReady()), ...
                struct('idx', 5, 'action', @()this.setYOfWaferAndGo(), 'isReady', @()this.uiStageWaferCoarse.uiY.isReady()), ...
                struct('idx', 6, 'action', @()this.setZOfWaferAndGo(), 'isReady', @()this.uiStageWaferCoarse.uiZ.isReady()) ...
            };
        
            stRecipe = struct;
            stRecipe.values = stateList; % enumerable list of states that can be read by setState
            stRecipe.unit = struct('unit', 'unit'); % not sure if we need units really, but let's fix later
            
            this.scan = mic.Scan(this.cName, ...
                                this.clock, ...
                                stRecipe, ...
                                fhSetState, ...
                                fhIsAtState, ...
                                fhAcquire, ...
                                fhIsAcquired, ...
                                fhOnComplete, ...
                                fhOnAbort, ...
                                this.dPeriodOfScan...
                                );
            this.scan.start();
            
            
        end
        
        
        function setXOfWaferAndGo(this)
            this.uiStageWaferCoarse.uiX.setDestCal(this.stConfig.xWafer.value, this.stConfig.xWafer.unit);
            this.uiStageWaferCoarse.uiX.moveToDest();
        end
        
        function setYOfWaferAndGo(this)
            this.uiStageWaferCoarse.uiY.setDestCal(this.stConfig.yWafer.value, this.stConfig.yWafer.unit);
            this.uiStageWaferCoarse.uiY.moveToDest();
        end
        
        function setZOfWaferAndGo(this)
            this.uiStageWaferCoarse.uiZ.setDestCal(this.stConfig.zWafer.value, this.stConfig.zWafer.unit);
            this.uiStageWaferCoarse.uiZ.moveToDest();
        end
        
        function setXOfReticleAndGo(this)
            this.uiStageReticleCoarse.uiX.setDestCal(this.stConfig.xReticle.value, this.stConfig.xReticle.unit);
            this.uiStageReticleCoarse.uiX.moveToDest();
        end
        
        function setYOfReticleAndGo(this)
            this.uiStageReticleCoarse.uiY.setDestCal(this.stConfig.yReticle.value, this.stConfig.yReticle.unit);
            this.uiStageReticleCoarse.uiY.moveToDest();
        end
        
        function setZOfReticleAndGo(this)
            this.uiStageReticleCoarse.uiZ.setDestCal(this.stConfig.zReticle.value, this.stConfig.zReticle.unit);
            this.uiStageReticleCoarse.uiZ.moveToDest();
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
        
        function setColorOfGoButton(this)
            if (this.isInPosition())
                this.uiButtonGo.setColor([.85, 1, .85]);
                this.uiButtonGo.setText('In Correct Position');
%             elseif this.isMissing()
%                 this.uiButtonGo.setColor([1, 1, .85]);
%                 this.uiButtonGo.setText('No Wafer!');
%             elseif this.isDriftMonitorOff()
%                 this.uiButtonGo.setColor([1, 1, .85]);
%                 this.uiButtonGo.setText('Level Wafer');
            else
                this.uiButtonGo.setColor([1, .85, .85]);
                this.uiButtonGo.setText('Move Into Position');
            end
            
        end
        
        
        
        
    end % private
    
    
end