classdef TuneFluxDensity < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 1900 %1295
        dHeight     = 1000
        
        dWidthNameComm = 100;
        
    end
    
	properties
        
        hDock = {}
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommConnectAll
        uiCommDeltaTauPowerPmac
        uiCommKeithley6482
        uiCommBL1201CorbaProxy

        
                
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
        
    end
    
    properties (Access = private)
                      
        clock
        dDelay = 0.5
        
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

            dPad = 10;
            dSep = 30;

            
            this.uiCommConnectAll.build(this.hParent, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDeltaTauPowerPmac.build(this.hParent, dLeft, dTop);
            dTop = dTop + dSep;
            
                        
            
            

            this.uiStageWaferCoarse.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiStageWaferCoarse.dHeight + dPad;
            
            this.uiStageReticleCoarse.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiStageReticleCoarse.dHeight + dPad;
                         
            
            this.uiCommKeithley6482.build(this.hParent, dLeft, dTop);
            dTop = dTop + dSep;
            
           
            this.uiDiode.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiDiode.dHeight + dPad;
            
            this.uiShutter.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiShutter.dHeight + dPad;
            
            this.uiExitSlit.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiExitSlit.dHeight + dPad;
            
            
            this.uiCommBL1201CorbaProxy.build(this.hParent, dLeft, dTop);
            dTop = dTop + dSep;
            
            
            this.uiUndulatorGap.build(this.hParent, dLeft, dTop);
            dTop = dTop + 24 + dPad;
            
            
            dLeft = 1000;
            dTop = 10;
            
            this.uiAxesReticle.build(this.hParent, dLeft, dTop);            
            dTop = dTop + this.uiAxesReticle.dHeight + dPad;
            
            this.uiAxesWafer.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiAxesWafer.dHeight + dPad;
            
            
            
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
            
            this.msg('init()');
            
            
            this.uiStageWaferCoarse = bl12014.ui.WaferCoarseStage(...
                'cName', [this.cName, 'stage-wafer-coarse'], ...
                'clock', this.clock ...
            );
        
            this.uiStageReticleCoarse = bl12014.ui.ReticleCoarseStage(...
                'cName', [this.cName, 'stage-reticle-coarse'], ...-
                'clock', this.clock ...
            );
        
            this.uiDiode = bl12014.ui.WaferDiode(...
                'cName', [this.cName, 'diode-wafer'], ...-
                'clock', this.clock ...
            );
           
            this.initUiCommConnectAll();
            this.initUiCommBL1201CorbaProxy();
            this.initUiCommDeltaTauPowerPmac();
            this.initUiCommKeithley6482();
            
            this.uiExitSlit = bl12014.ui.ExitSlit('clock', this.clock);
            
            this.initUiDeviceUndulatorGap(); % BL1201 Corba Proxy
        
            
            this.uiShutter = bl12014.ui.Shutter(...
                'cName', [this.cName, 'shutter'], ...
                'clock', this.clock ...
            );


            dHeight = 400;
            this.uiAxesWafer = bl12014.ui.WaferAxes( ...
                'cName', [this.cName, 'wafer-axes'], ...
                'clock', this.clock, ...
                'fhGetIsShutterOpen', @() this.uiShutter.uiOverride.get(), ...
                'fhGetXOfWafer', @() this.uiStageWaferCoarse.uiX.getValCal('mm') / 1000, ...
                'fhGetYOfWafer', @() this.uiStageWaferCoarse.uiY.getValCal('mm') / 1000, ...
                'waferExposureHistory', this.waferExposureHistory, ...
                'dWidth', dHeight, ...
                'dHeight', dHeight ...
            );
        
        
            dHeight = 400;
            this.uiAxesReticle = bl12014.ui.ReticleAxes( ...
                'cName', [this.cName, 'reticle-axes'], ...
                'clock', this.clock, ...
                'fhGetIsShutterOpen', @() this.uiShutter.uiOverride.get(), ...
                'fhGetX', @() this.uiStageReticleCoarse.uiX.getValCal('mm') / 1000, ...
                'fhGetY', @() this.uiStageReticleCoarse.uiY.getValCal('mm') / 1000, ...
                'dWidth', dHeight, ...
                'dHeight', dHeight ...
            );
        
            
                        
            

        end
        
        
        
        function initUiCommDeltaTauPowerPmac(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommDeltaTauPowerPmac = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
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
                'clock', this.clock, ...
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
                this.uiShutter.uiCommRigol.get();
        end
        
        function onSet(this, lVal)
            
            this.uiCommBL1201CorbaProxy.set(lVal);
            this.uiCommDeltaTauPowerPmac.set(lVal);
            this.uiCommKeithley6482.set(lVal);
            this.uiExitSlit.uiCommExitSlit.set(lVal);
            this.uiShutter.uiCommRigol.set(lVal);
        end
        
        function initUiCommConnectAll(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            
            this.uiCommConnectAll = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
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
                'clock', this.clock, ...
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
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', 150, ...
                ... % 'dWidthUnit', this.dWidthUiDeviceUnit, ...
                'cName', [this.cName, 'gap-of-undulator'], ...
                'config', uiConfig, ...
                'cLabel', 'Undulator Gap' ...
            );
        
        end
        
        
        
    end % private
    
    
end