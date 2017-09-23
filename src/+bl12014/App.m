classdef App < mic.Base
        
    properties (Constant)
        
        dWidth = 250
        dHeight = 550
        
        dWidthButton = 210
        
        % Branchline Subnet
        cTcpipSmarActM141 = '192.168.10.20'
        cTcpipHostMicronix = '192.168.10.21'
        cTcpipLc400M142 = '192.168.10.22'
        cTcpipHostNewFocus = '192.168.10.23'
        cTcpipGalilD142 = '192.168.10.24'
        cTcpipGalilM143 = '192.168.10.25'
        
        % Endstation 1 Subnet
        cTcpipLc400MA = '192.168.20.20'
        cTcpipGalilVibrationIsolationSystem = '192.168.20.21'
        cTcpipAcromag = '192.168.20.22'
        cTcpipDeltaTau = '192.168.20.23'
        cTcpipSmarActLSIGoni = '192.168.20.24'
        cTcpipSmarActLSIHexapod = '192.168.20.25'
        cTcpipSmarActFocusMonitor = '192.168.20.26'
        cTcpipDataTranslation = '192.168.20.27'
        cTcpipKeithley6482Wafer = '192.168.20.28'
        cTcpipKeithley6482Reticle = '192.168.20.29'
        
        % Video Subnet
        
        % Endstation 2 Subnet
        
        
    end
    
	properties
        
        
        % {cxro.met5.Instruments 1x1}
        jMet5Instruments
        
        % {cxro.common.device.motion.Stage 1x1}
        commSmarActMcsM141
        
        % {cxro.common.device.motion.Stage 1x1}
        commSmarActMcsGoni
        
        % {FIX ME}
        commSmarActSmarPod
        
        commSmarActRotary
        
        % {deltaTau.PowerPmac 1x1}
        commDeltaTauPowerPmac
        
        % {dataTranslation.MeasurPoint 1x1}
        commDataTranslationMeasurPoint
        
        % {npoint.LC400 1x1}
        commNPointLC400Field
        
        % {npoint.LC400 1x1}
        commNPointLC400Pupil
        
        % {cxro.met5.HeightSensor 1x1}
        commCxroHeightSensor
        
        % {keithley.Keithley6482 1x1}
        commKeithley6482Reticle
        
        % {keithley.Keithley6482 1x1}
        commKeithley6482Wafer
        
        % {cxro.bl1201.beamline.BL1201CorbaProxy 1x1}
        commBL1201CorbaProxy
        
        % {cxro.bl1201.dct.DctCorbaProxy 1x1}
        commDctCorbaProxy
        
        % {newFocus.NewFocusModel8742 1x1} 
        % May cheat and use DLL directly with {mic.interface.device.*}
        % M142 + M142R common tiltX (pitch)
        % M142 independent tiltY  (roll)
        % M142R independent tiltY (roll)
        commNewFocusModel8742
        
        % {micronix.Mmc103 1x1}
        % M142R tiltZ (clocking)
        % M142 + M142R common x
        commMicronixMmc103
        
        % {cxro.common.device.motion.Stage}
        commGalilD142
        
        % {cxro.common.device.motion.Stage}
        commGalilM143
        
        % {cxro.common.device.motion.Stage}
        commGalilVIS
        
        % see vendor/pnaulleau/bl12-exit-slits/readme.txt
        commExitSlit
        
        uiApp
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        hFigure
        
        
        % {bl12014.Comm 1x1}
        comm
        
        % {char 1xm} - base directory for configuration and library files
        % for cwcork's cxro.met5.Instruments class
        cDirMet5InstrumentsConfig
        
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = App(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
            
            
        end
        
                
        function build(this)
            
            this.buildFigure();
            this.uiApp.build(this.hFigure, 10, 10);
            % this.uiComm.build(this.hFigure, 210, 10);
        end
        
        %% Destructor
        
        function delete(this)
            delete(this.uiApp)
            % this.comm.delete()
            this.destroyAndDisconnectAll();
            
        end
        
        
        

    end
    
    methods (Access = private)
        
        function initAndConnectMet5Instruments(this)
            
           if ~isempty(this.jMet5Instruments)
               return
           end
           
           try
                this.jMet5Instruments = cxro.met5.Instruments(this.cDirMet5InstrumentsConfig);
           catch mE
                this.jMet5Instruments = []; 
                this.msg(getReport(mE), this.u8_MSG_TYPE_ERROR);
           end
            
        end
        
        function destroyAndDisconnectMet5Instruments(this)
            
           if isempty(this.jMet5Instruments)
               return
           end
           
           this.jMet5Instruments.disconnect();
           this.jMet5Instruments = []
           
            
        end
        
        
        function destroyAndDisconnectAll(this)
            
            this.destroyAndDisconnectBL1201CorbaProxy();
            this.destroyAndDisconnectCxroHeightSensor();
            this.destroyAndDisconnectDataTranslationMeasurPoint();
            this.destroyAndDisconnectDeltaTauPowerPmac();
            this.destroyAndDisconnectKeithley6482Reticle();
            this.destroyAndDisconnectKeithley6482Wafer();
            this.destroyAndDisconnectMicronixMmc103();
            this.destroyAndDisconnectNewFocusModel8742();
            this.destroyAndDisconnectNPointLC400Field();
            this.destroyAndDisconnectNPointLC400Pupil();
            this.destroyAndDisconnectSmarActMcsGoni();
            this.destroyAndDisconnectSmarActMcsM141();
            this.destroyAndDisconnectSmarActSmarPod();
            this.destroyAndDisconnectSmarActRotary();
        end
        
        % Getters return logical if the COMM class exists.  Used by
        % GetSetLogicalConnect instances
        
        function l = getExitSlit(this)
            l = ~isempty(this.commExitSlit);
        end
        
        function l = getNewFocusModel8742(this)
            l = ~isempty(this.commNewFocusModel8742);
        end
        
        function l = getSmarActMcsM141(this)
            l =  ~isempty(this.commSmarActMcsM141);
        end
        
        function l = getSmarActMcsGoni(this)
            l = ~isempty(this.commSmarActMcsGoni);
        end
        
        function l = getSmarActRotary(this)
            l = ~isempty(this.commSmarActRotary);
        end
        
        function l = getSmarActSmarPod(this)
            l = ~isempty(this.commSmarActSmarPod);
        end
        
        function l = getMicronixMmc103(this)
            l = ~isempty(this.commMicronixMmc103);
            
        end
        
        function l = getGalilD142(this)
            l = ~isempty(this.commGalilD142);
        end
        
        function l = getGalilVIS(this)
            l = ~isempty(this.commGalilVIS);
        end
        
        function l = getGalilM143(this)
            l = ~isempty(this.commGalilM143);
        end
        
        function l = getDeltaTauPowerPmac(this)
            l = ~isempty(this.commDeltaTauPowerPmac);
            
        end
        
        function l = getDataTranslationMeasurPoint(this)
            l = ~isempty(this.commDataTranslationMeasurPoint);
        end
        
        function l = getKeithley6482Reticle(this)
            l = ~isempty(this.commKeithley6482Reticle);
            
        end
        
        function l = getKeithley6482Wafer(this)
            l = ~isempty(this.commKeithley6482Wafer);
        end
        
        function l = getCxroHeightSensor(this)
            l = ~isempty(this.commCxroHeightSensor);
            
        end
        
        function l = getBL1201CorbaProxy(this)
            l = ~isempty(this.commBL1201CorbaProxy);
        end
        
        function l = getDctCorbaProxy(this)
            l = ~isempty(this.commDctCorbaProxy);
        end
        
        function l = getNPointLC400Field(this)
            l = ~isempty(this.commNPointLC400Field);
            
        end
        
        function l = getNPointLC400Pupil(this)
            l = ~isempty(this.commNPointLC400Pupil);
        end
        
        function initAndConnectSmarActMcsM141(this)
                        
            if this.getSmarActMcsM141()
                return
            end
            
            try
                this.initAndConnectMet5Instruments();
                this.commSmarActMcsM141 = this.jMet5Instruments.getM141Stage();
                this.commSmarActMcsM141.connect()
            catch mE
                
                cMsg = sprintf('initAndConnectSmarActMcsM141() %s', getReport(mE));
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                this.commSmarActMcsM141 = [];
                return
            end
            
            % {< mic.interface.device.GetSetNumber}
            deviceX = bl12014.device.GetSetNumberFromStage(this.commSmarActMcsM141, 0);

            % {< mic.interface.device.GetSetNumber}
            deviceTiltX = bl12014.device.GetSetNumberFromStage(this.commSmarActMcsM141, 1);

            % {< mic.interface.device.GetSetNumber}
            deviceTiltY = bl12014.device.GetSetNumberFromStage(this.commSmarActMcsM141, 2);
            
            this.uiApp.uiM141.uiStageX.setDevice(deviceX);
            this.uiApp.uiM141.uiStageTiltX.setDevice(deviceTiltX);
            this.uiApp.uiM141.uiStageTiltY.setDevice(deviceTiltY);
            
            
            this.uiApp.uiM141.uiStageX.turnOn();
            this.uiApp.uiM141.uiStageTiltX.turnOn();
            this.uiApp.uiM141.uiStageTiltY.turnOn();
            
        end
        
        
        function destroyAndDisconnectSmarActMcsM141(this)
            
            if ~this.getSmarActMcsM141()
                return
            end
            
            this.uiApp.uiM141.uiStageX.turnOff();
            this.uiApp.uiM141.uiStageTiltX.turnOff();
            this.uiApp.uiM141.uiStageTiltY.turnOff();
            
            this.uiApp.uiM141.uiStageX.setDevice([]);
            this.uiApp.uiM141.uiStageTiltX.setDevice([]);
            this.uiApp.uiM141.uiStageTiltY.setDevice([]);
            
            
            this.commSmarActMcsM141.disconnect();
            this.commSmarActMcsM141 = [];
        end
        
        
        function initAndConnectSmarActRotary(this)
            
            if this.getSmarActRotary()
                return
            end
            
            try
                this.initAndConnectMet5Instruments();
                this.commSmarActRotary = this.jMet5Instruments.getFmStage();
                
            catch mE
                this.commSmarActRotary = [];
                cMsg = sprintf('initAndConnectSmarActRotary %s', getReport(mE));
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
            
            
            % Wafer Focus Sensor
            device = bl12014.device.GetSetNumberFromStage(this.commSmarActRotary, 1);
            this.uiApp.uiFocusSensor.uiFocusSensor.uiTiltZ.setDevice(device);
            this.uiApp.uiFocusSensor.uiFocusSensor.uiTiltZ.turnOn();

            
        end
        
        function destroyAndDisconnectSmarActRotary(this)
            if ~this.getSmarActRotary()
                return
            end
            
            % Wafer Focus Sensor
            this.uiApp.uiFocusSensor.uiFocusSensor.uiTiltZ.turnOff();
            this.uiApp.uiFocusSensor.uiFocusSensor.uiTiltZ.setDevice([]);
                        
        end
        
        
        function initAndConnectSmarActMcsGoni(this)
            
            
            if this.getSmarActMcsGoni()
                return
            end
            
            try
                this.initAndConnectMet5Instruments();
                this.commSmarActMcsGoni = this.jMet5Instruments.getLsiGoniometer();
            catch mE
                this.commSmarActMcsGoni = [];
                cMsg = sprintf('initAndConnectSmarActMcsGoni() %s', getReport(mE));
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                
                return
            end
            
            % Interferometry
        end
        
        function destroyAndDisconnectSmarActMcsGoni(this)
            
            if ~this.getSmarActMcsGoni()
                return
            end
            
            % Interferometry
            
            this.commSmarActMcsGoni = [];
        end
        
        
        
        function initAndConnectSmarActSmarPod(this)
            

            if this.getSmarActSmarPod()
                return
            end
            
            try
                this.initAndConnectMet5Instruments();
                this.commSmarActSmarPod = this.jMet5Instruments.getLsiHexapod();
            catch mE
                this.commSmarActSmarPod = [];
                cMsg = sprintf('initAndConnectSmarSmarPod() %s', getReport(mE));
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
            
            % Interferometry
        end
        
        function destroyAndDisconnectSmarActSmarPod(this)
            
            if ~this.getSmarActSmarPod()
                return
            end
            
            % Interferometry
            
            this.commSmarActSmarPod = [];
        end
        
        
        function initAndConnectDataTranslationMeasurPoint(this)
            
            
            if this.getDataTranslationMeasurPoint()
                return
            end
                        
            try
                this.commDataTranslationMeasurPoint = dataTranslation.MeasurPoint();
            catch mE
                this.commDataTranslationMeasurPoint = [];
                cMsg = sprintf('initAndConnectDataTranslationMeasurPoint() %s', getReport(mE));
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
            
            
            
            % M141
            device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 1);
            this.uiApp.uiM141.uiCurrent.setDevice(device);
            this.uiApp.uiM141.uiCurrent.turnOn()
            
            % D141
            device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 1);
            this.uiApp.uiD141.uiCurrent.setDevice(device);
            this.uiApp.uiD141.uiCurrent.turnOn()
            
            % D142 & Beamline (share a device)
            device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 1);
            this.uiApp.uiD142.uiCurrent.setDevice(device);
            this.uiApp.uiD142.uiCurrent.turnOn()
            this.uiApp.uiBeamline.uiD142Current.setDevice(device);
            this.uiApp.uiBeamline.uiD142Current.turnOn();
            
            % M143
            device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 1);
            this.uiApp.uiM143.uiCurrent.setDevice(device);
            this.uiApp.uiM143.uiCurrent.turnOn()
            
            % Vibration Isolation System
            
            % Reticle
            
            deviceCap1 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 21);
            deviceCap2 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 22);
            deviceCap3 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 23);
            deviceCap4 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 24);
            
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap1.setDevice(deviceCap1);
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap2.setDevice(deviceCap2);
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap3.setDevice(deviceCap3);
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap4.setDevice(deviceCap4);
            
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap1.turnOn();
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap2.turnOn();
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap3.turnOn();
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap4.turnOn();
            
            % Wafer
            
            deviceCap1 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 21);
            deviceCap2 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 22);
            deviceCap3 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 23);
            deviceCap4 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 24);
            
            this.uiApp.uiWafer.uiPobCapSensors.uiCap1.setDevice(deviceCap1);
            this.uiApp.uiWafer.uiPobCapSensors.uiCap2.setDevice(deviceCap2);
            this.uiApp.uiWafer.uiPobCapSensors.uiCap3.setDevice(deviceCap3);
            this.uiApp.uiWafer.uiPobCapSensors.uiCap4.setDevice(deviceCap4);
            
            this.uiApp.uiWafer.uiPobCapSensors.uiCap1.turnOn();
            this.uiApp.uiWafer.uiPobCapSensors.uiCap2.turnOn();
            this.uiApp.uiWafer.uiPobCapSensors.uiCap3.turnOn();
            this.uiApp.uiWafer.uiPobCapSensors.uiCap4.turnOn();
            
            % TempSensors
            
            deviceReticleCam1 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 1);
            deviceReticleCam2 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 2);
            deviceFiducialCam1 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 3);
            deviceFiducialCam2 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 4);
            deviceMod3Frame1 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 5);
            deviceMod3Frame2 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 6);
            deviceMod3Frame3 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 7);
            deviceMod3Frame4 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 8);
            deviceMod3Frame5 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 9);
            deviceMod3Frame6 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 10);
            
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiReticleCam1.setDevice(deviceReticleCam1);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiReticleCam2.setDevice(deviceReticleCam2);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFiducialCam1.setDevice(deviceFiducialCam1);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFiducialCam2.setDevice(deviceFiducialCam2);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame1.setDevice(deviceMod3Frame1);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame2.setDevice(deviceMod3Frame2);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame3.setDevice(deviceMod3Frame3);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame4.setDevice(deviceMod3Frame4);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame5.setDevice(deviceMod3Frame5);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame6.setDevice(deviceMod3Frame6);
            
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiReticleCam1.turnOn();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiReticleCam2.turnOn();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFiducialCam1.turnOn();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFiducialCam2.turnOn();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame1.turnOn();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame2.turnOn();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame3.turnOn();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame4.turnOn();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame5.turnOn();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame6.turnOn();
            
            devicePobFrame1 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 11);
            devicePobFrame2 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 12);
            devicePobFrame3 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 13);
            devicePobFrame4 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 14);
            devicePobFrame5 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 15);
            devicePobFrame6 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 16);
            devicePobFrame7 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 17);
            devicePobFrame8 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 18);
            devicePobFrame9 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 19);
            devicePobFrame10 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 20);
            devicePobFrame11 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 21);
            devicePobFrame12 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 22);
            
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame1.setDevice(devicePobFrame1);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame2.setDevice(devicePobFrame2);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame3.setDevice(devicePobFrame3);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame4.setDevice(devicePobFrame4);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame5.setDevice(devicePobFrame5);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame6.setDevice(devicePobFrame6);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame7.setDevice(devicePobFrame7);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame8.setDevice(devicePobFrame8);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame9.setDevice(devicePobFrame9);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame10.setDevice(devicePobFrame10);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame11.setDevice(devicePobFrame11);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame12.setDevice(devicePobFrame12);
            
            
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame1.turnOn();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame2.turnOn();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame3.turnOn();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame4.turnOn();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame5.turnOn();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame6.turnOn();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame7.turnOn();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame8.turnOn();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame9.turnOn();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame10.turnOn();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame11.turnOn();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame12.turnOn();
            
        end
        
        function destroyAndDisconnectDataTranslationMeasurPoint(this)
            
            if ~this.getDataTranslationMeasurPoint()
                return
            end
            
            % Beamline
            this.uiApp.uiBeamline.uiD142Current.turnOff();
            this.uiApp.uiBeamline.uiD142Current.setDevice([]);
            
            
            % M141
            this.uiApp.uiM141.uiCurrent.turnOff();
            this.uiApp.uiM141.uiCurrent.setDevice([]);
            
            % D141
            this.uiApp.uiD141.uiCurrent.turnOff();
            this.uiApp.uiD141.uiCurrent.setDevice([]);
            
            % D142
            this.uiApp.uiD142.uiCurrent.turnOff();
            this.uiApp.uiD142.uiCurrent.setDevice([]);
            
            % M143
            this.uiApp.uiM143.uiCurrent.turnOff();
            this.uiApp.uiM143.uiCurrent.setDevice([]);
            
            % Vibration Isolation System
            
            % Reticle
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap1.turnOff();
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap2.turnOff();
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap3.turnOff();
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap4.turnOff();
            
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap1.setDevice([]);
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap2.setDevice([]);
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap3.setDevice([]);
            this.uiApp.uiReticle.uiMod3CapSensors.uiCap4.setDevice([]);
            
            % Wafer
            
            this.uiApp.uiWafer.uiPobCapSensors.uiCap1.turnOff();
            this.uiApp.uiWafer.uiPobCapSensors.uiCap2.turnOff();
            this.uiApp.uiWafer.uiPobCapSensors.uiCap3.turnOff();
            this.uiApp.uiWafer.uiPobCapSensors.uiCap4.turnOff();
            
            this.uiApp.uiWafer.uiPobCapSensors.uiCap1.setDevice([]);
            this.uiApp.uiWafer.uiPobCapSensors.uiCap2.setDevice([]);
            this.uiApp.uiWafer.uiPobCapSensors.uiCap3.setDevice([]);
            this.uiApp.uiWafer.uiPobCapSensors.uiCap4.setDevice([]);
            
            % Temp Sensors
            
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiReticleCam1.turnOff();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiReticleCam2.turnOff();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFiducialCam1.turnOff();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFiducialCam2.turnOff();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame1.turnOff();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame2.turnOff();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame3.turnOff();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame4.turnOff();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame5.turnOff();
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame6.turnOff();
            
            
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiReticleCam1.setDevice([]);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiReticleCam2.setDevice([]);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFiducialCam1.setDevice([]);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFiducialCam2.setDevice([]);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame1.setDevice([]);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame2.setDevice([]);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame3.setDevice([]);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame4.setDevice([]);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame5.setDevice([]);
            this.uiApp.uiTempSensors.uiMod3TempSensors.uiFrame6.setDevice([]);
            
            
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame1.turnOff();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame2.turnOff();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame3.turnOff();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame4.turnOff();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame5.turnOff();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame6.turnOff();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame7.turnOff();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame8.turnOff();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame9.turnOff();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame10.turnOff();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame11.turnOff();
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame12.turnOff();
            
            
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame1.setDevice([]);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame2.setDevice([]);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame3.setDevice([]);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame4.setDevice([]);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame5.setDevice([]);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame6.setDevice([]);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame7.setDevice([]);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame8.setDevice([]);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame9.setDevice([]);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame10.setDevice([]);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame11.setDevice([]);
            this.uiApp.uiTempSensors.uiPobTempSensors.uiFrame12.setDevice([]);
            
            
            
            this.commDataTranslationMeasurPoint.delete();
            this.commDataTranslationMeasurPoint = [];
        end
        
        
        function connectCommDeltaTauPowerPmacToUiReticle(this, comm, ui)
            
            import bl12014.device.GetSetNumberFromDeltaTauPowerPmac
            import bl12014.device.GetSetTextFromDeltaTauPowerPmac
            
            
            % Devices
            deviceWorkingMode = GetSetTextFromDeltaTauPowerPmac(comm, GetSetTextFromDeltaTauPowerPmac.cTYPE_WORKING_MODE);
            deviceCoarseX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_X);
            deviceCoarseY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_Y);
            deviceCoarseZ = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_Z);
            deviceCoarseTiltX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_TIP);
            deviceCoarseTiltY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_TILT);
            deviceFineX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_FINE_X);
            deviceFineY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_FINE_Y);
            
             % Set Devices 
            ui.uiWorkingMode.ui.setDevice(deviceWorkingMode);
            ui.uiCoarseStage.uiX.setDevice(deviceCoarseX);
            ui.uiCoarseStage.uiY.setDevice(deviceCoarseY);
            ui.uiCoarseStage.uiZ.setDevice(deviceCoarseZ);
            ui.uiCoarseStage.uiTiltX.setDevice(deviceCoarseTiltX);
            ui.uiCoarseStage.uiTiltY.setDevice(deviceCoarseTiltY);
            ui.uiFineStage.uiX.setDevice(deviceFineX);
            ui.uiFineStage.uiY.setDevice(deviceFineY);
            
            % Turn on
            ui.uiWorkingMode.ui.turnOn();
            ui.uiCoarseStage.uiX.turnOn();
            ui.uiCoarseStage.uiY.turnOn();
            ui.uiCoarseStage.uiZ.turnOn();
            ui.uiCoarseStage.uiTiltX.turnOn();
            ui.uiCoarseStage.uiTiltY.turnOn();
            ui.uiFineStage.uiX.turnOn();
            ui.uiFineStage.uiY.turnOn();
            
            
        end
        
        
        function connectCommDeltaTauPowerPmacToUiWafer(this, comm, ui)
            
            import bl12014.device.GetSetNumberFromDeltaTauPowerPmac
            import bl12014.device.GetSetTextFromDeltaTauPowerPmac
            
            % Devices
            deviceWorkingMode = GetSetTextFromDeltaTauPowerPmac(comm, GetSetTextFromDeltaTauPowerPmac.cTYPE_WORKING_MODE);
            deviceCoarseX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_X);
            deviceCoarseY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_Y);
            deviceCoarseZ = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_Z);
            deviceCoarseTiltX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TIP);
            deviceCoarseTiltY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TILT);
            deviceFineZ = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_FINE_Z);
            
            % Set Devices
            ui.uiWorkingMode.ui.setDevice(deviceWorkingMode);
            ui.uiCoarseStage.uiX.setDevice(deviceCoarseX);
            ui.uiCoarseStage.uiY.setDevice(deviceCoarseY);
            ui.uiCoarseStage.uiZ.setDevice(deviceCoarseZ);
            ui.uiCoarseStage.uiTiltX.setDevice(deviceCoarseTiltX);
            ui.uiCoarseStage.uiTiltY.setDevice(deviceCoarseTiltY);
            ui.uiFineStage.uiZ.setDevice(deviceFineZ);
            
            % Turn on
            ui.uiWorkingMode.ui.turnOn();
            ui.uiCoarseStage.uiX.turnOn();
            ui.uiCoarseStage.uiY.turnOn();
            ui.uiCoarseStage.uiZ.turnOn();
            ui.uiCoarseStage.uiTiltX.turnOn();
            ui.uiCoarseStage.uiTiltY.turnOn();
            ui.uiFineStage.uiZ.turnOn();
            
        end
        
        function connectCommDeltaTauPowerPmacToUiLsi(this, comm, ui)
           
            % Ryan fill in
        end
        
        function connectCommDeltaTauPowerPmacToUiPowerPmacStatus(this, comm, ui)

            for m = 1 : length(ui.ceceTypes)
                for n = 1 : length(ui.ceceTypes{m}) 
                    device = bl12014.device.GetLogicalFromDeltaTauPowerPmac(...
                        comm, ...
                        ui.ceceTypes{m}{n}...
                    );
                    ui.uiGetLogicals{m}{n}.setDevice(device);
                    ui.uiGetLogicals{m}{n}.turnOn();
                end
            end
        end
        
        
        function initAndConnectDeltaTauPowerPmac(this)
           
            
            if this.getDeltaTauPowerPmac()
                return
            end
            
            try
                this.commDeltaTauPowerPmac = deltatau.PowerPmac(...
                    'cHostname', this.cTcpipDeltaTau ...
                );
                this.commDeltaTauPowerPmac.init();
            catch mE
                this.commDeltaTauPowerPmac = [];
                cMsg = sprintf('initAndConnectDeltaTauPowerPmac %s', getReport(mE));
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
            
            this.connectCommDeltaTauPowerPmacToUiReticle(this.commDeltaTauPowerPmac, this.uiApp.uiReticle);
            this.connectCommDeltaTauPowerPmacToUiWafer(this.commDeltaTauPowerPmac, this.uiApp.uiWafer);
            % this.connectCommDeltaTauPowerPmacToUiLsi(this.commDeltaTauPowerPmac, this.uiApp.uiLsi);
            this.connectCommDeltaTauPowerPmacToUiPowerPmacStatus(this.commDeltaTauPowerPmac, this.uiApp.uiPowerPmacStatus);
            
        end
        
        function disconnectCommDeltaTauPowerPmacFromUiReticle(this, ui)
            
            ui.uiWorkingMode.ui.turnOff();
            ui.uiCoarseStage.uiX.turnOff();
            ui.uiCoarseStage.uiY.turnOff();
            ui.uiCoarseStage.uiZ.turnOff();
            ui.uiCoarseStage.uiTiltX.turnOff();
            ui.uiCoarseStage.uiTiltY.turnOff();
            ui.uiFineStage.uiX.turnOff();
            ui.uiFineStage.uiY.turnOff();
            
            ui.uiWorkingMode.ui.setDevice([]);
            ui.uiCoarseStage.uiX.setDevice([]);
            ui.uiCoarseStage.uiY.setDevice([]);
            ui.uiCoarseStage.uiZ.setDevice([]);
            ui.uiCoarseStage.uiTiltX.setDevice([]);
            ui.uiCoarseStage.uiTiltY.setDevice([]);
            ui.uiFineStage.uiX.setDevice([]);
            ui.uiFineStage.uiY.setDevice([]);
            
        end
        
        function disconnectCommDeltaTauPowerPmacFromUiWafer(this, ui)
            
            ui.uiWorkingMode.ui.turnOff();
            ui.uiCoarseStage.uiX.turnOff();
            ui.uiCoarseStage.uiY.turnOff();
            ui.uiCoarseStage.uiZ.turnOff();
            ui.uiCoarseStage.uiTiltX.turnOff();
            ui.uiCoarseStage.uiTiltY.turnOff();
            ui.uiFineStage.uiZ.turnOff();
                        
            ui.uiWorkingMode.ui.setDevice([]);
            ui.uiCoarseStage.uiX.setDevice([]);
            ui.uiCoarseStage.uiY.setDevice([]);
            ui.uiCoarseStage.uiZ.setDevice([]);
            ui.uiCoarseStage.uiTiltX.setDevice([]);
            ui.uiCoarseStage.uiTiltY.setDevice([]);
            ui.uiFineStage.uiZ.setDevice([]);
            
        end
        
        function disconnectCommDeltaTauPowerPmacFromUiPowerPmacStatus(this, ui)
            
            % Disconnect uiApp.uiPowerPmacStatus
            for m = 1 : length(ui.ceceTypes)
                for n = 1 : length(ui.ceceTypes{m}) 
                    ui.uiGetLogicals{m}{n}.turnOff();
                    ui.uiGetLogicals{m}{n}.setDevice([]);
                end
            end
        end
        
        function destroyAndDisconnectDeltaTauPowerPmac(this)

            if ~this.getDeltaTauPowerPmac()
                return
            end
                      
            this.disconnectCommDeltaTauPowerPmacFromUiReticle(this.uiApp.uiReticle)
            this.disconnectCommDeltaTauPowerPmacFromUiWafer(this.uiApp.uiWafer);
            this.disconnectCommDeltaTauPowerPmacFromUiPowerPmacStatus(this.uiApp.uiPowerPmacStatus)
                                    
            this.commDeltaTauPowerPmac.delete();
            this.commDeltaTauPowerPmac = [];
            
        end
        
        
        function initAndConnectExitSlit(this)
            
            if this.getExitSlit()
                return
            end
            
            try
                [this.commExitSlit, e] = bl12pico_attach();
            catch mE
                this.commExitSlit = [];
                cMsg = sprintf('initAndConnectExitSlit() %s', getReport(mE));
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            if e == 1
                this.commExitSlit = [];
                return;
            end
            
            device = bl12014.device.GetSetNumberFromExitSlit(commExitSlit);
            this.uiApp.uiBeamline.uiExitSlit.setDevice(device);
            this.uiApp.uiBeamline.uiExitSlit.turnOn();
        
            
        end
        
        function destroyAndDisconnectExitSlit(this)
            
            if ~this.getExitSlit()
                return
            end
            
            this.uiApp.uiBeamline.uiExitSlit.turnOff();
            this.uiApp.uiBeamline.uiExitSlit.setDevice([]);
            
            % this.commExitSlit.delete();
            this.commExitSlit = [];
        end
        
        
        
        function initAndConnectKeithley6482Wafer(this)
            
            if this.getKeithley6482Wafer()
                return
            end
            
            try
                this.commKeithley6482Wafer = keithley.Keithley6482(...
                    'cTcpipHost', this.cTcpipHostKeithley6482Wafer, ...
                    'cConnection', keithley.Keithley6482.cCONNECTION_TCPCLIENT ...
                );
            
                this.commKeithley6482Wafer.init()
                this.commKeithley6482Wafer.connect()
                % this.commKeithley6482Wafer.identity()
            catch mE
                this.commKeithley6482Wafer = [];
                cMsg = sprintf('initAndConnectKeithley6482Wafer() %s', getReport(mE));
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
            
            % Wafer
            device = bl12014.device.GetNumberFromKeithley6482(this.commKeithley6482Wafer, 1);
            this.uiApp.uiWafer.uiDiode.uiCurrent.setDevice(device);
            this.uiApp.uiWafer.uiDiode.uiCurrent.turnOn();
                        
            % Wafer Focus Sensor
            %{
            device = bl12014.device.GetNumberFromKeithley6482(this.commKeithley6482Wafer, 2);
            this.uiApp.uiWaferFocusSensor.uiDiode.setDevice(device);
            this.uiApp.uiWaferFocusSensor.uiDiode.turnOn();
            %}
            
        end
        
        function destroyAndDisconnectKeithley6482Wafer(this)
            
            if ~this.getKeithley6482Wafer()
                return
            end
            
            this.uiApp.uiWafer.uiDiode.uiCurrent.turnOff()
            this.uiApp.uiWafer.uiDiode.uiCurrent.setDevice([]);
            
            %{
            this.uiApp.uiWaferFocusSensor.uiDiode.turnOff()
            this.uiApp.uiWaferFocusSensor.ui.uiDiode.setDevice([]);
            %}
            
            this.commKeithley6482Wafer.delete();
            this.commKeithley6482Wafer = [];
        end
        
        
        function initAndConnectKeithley6482Reticle(this)
            
            
            if this.getKeithley6482Reticle()
                return
            end
               
            try
                this.commKeithley6482Reticle = keithley.Keithley6482();
            catch mE
                this.commKeithley6482Reticle = [];
                cMsg = sprintf('initAndConnectKeithley6482Reticle() %s', getReport(mE));
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
                        
            % {< mic.interface.device.GetNumber}
            device = bl12014.device.GetNumberFromKeithley6482(this.commKeithley6482Reticle, 1);
            this.uiApp.uiReticle.uiDiode.uiCurrent.setDevice(device);
            this.uiApp.uiReticle.uiDiode.uiCurrent.turnOn();
            
        end
        
        function destroyAndDisconnectKeithley6482Reticle(this)
            
            if ~this.getKeithley6482Reticle()
                return
            end
                            
            this.uiApp.uiReticle.uiDiode.uiCurrent.turnOff()
            this.uiApp.uiReticle.uiDiode.uiCurrent.setDevice([]);
            
            this.commKeithley6482Reticle.delete();
            this.commKeithley6482Reticle = [];
        end
        
        function initAndConnectCxroHeightSensor(this)
            
            if this.getCxroHeightSensor()
                return
            end
               
            try
                this.commCxroHeightSensor = cxro.met5.HeightSensor();
            catch mE
                this.commCxroHeightSensor = [];
                this.msg(getReport(mE), this.u8_MSG_TYPE_ERROR);
                return
            end
            
            % Wafer
            
        end
        
        function destroyAndDisconnectCxroHeightSensor(this)
            
            if ~this.getCxroHeightSensor()
                return
            end
            
            % Wafer
            
            this.commCxroHeightSensor.delete();
            this.commCxroHeightSensor = [];
        end
        
        function initAndConnectDctCorbaProxy(this)
            
            if this.getDctCorbaProxy()
                return
            end
            
            try
                this.commDctCorbaProxy = cxro.bl1201.dct.DctCorbaProxy();
            catch mE
                this.commDctCorbaProxy = [];
                this.msg(getReport(mE), this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            device = bl12014.device.GetSetNumberFromDctCorbaProxy(...
                this.commDctCorbaProxy, ...
                bl12014.device.GetSetNumberFromDctCorbaProxy.cDEVICE_SHUTTER ...
            );
        
            this.uiApp.uiBeamline.uiShutter.setDevice(device)
            this.uiApp.uiBeamline.uiShutter.turnOn()
        
            
            
        end
        
        function destroyAndDisconnectDctCorbaProxy(this)
            
            if ~this.getDctCorbaProxy()
                return
            end
            
            % Beamline
            
            this.uiApp.uiBeamline.uiShutter.turnOff()
            this.uiApp.uiBeamline.uiShutter.setDevice([])
                        
            this.commDctCorbaProxy = [];
        end
        
        
        function initAndConnectBL1201CorbaProxy(this)
            
            if this.getBL1201CorbaProxy()
                return
            end
            
            try
                this.commBL1201CorbaProxy = cxro.bl1201.beamline.BL1201CorbaProxy();
            catch mE
                this.commBL1201CorbaProxy = [];
                this.msg(getReport(mE), this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            % Beamline
            
            deviceUndulatorGap = bl12014.device.GetSetNumberFromBL1201CorbaProxy(...
                this.commBL1201CorbaProxy, ...
                bl12014.device.GetSetNumberFromBL1201CorbaProxy.cDEVICE_UNDULATOR_GAP ...
            );
            deviceGratingTiltX = bl12014.device.GetSetNumberFromBL1201CorbaProxy(...
                this.commBL1201CorbaProxy, ...
                bl12014.device.GetSetNumberFromBL1201CorbaProxy.cDEVICE_GRATING_TILT_X ...
            );
            
            this.uiApp.uiBeamline.uiUndulatorGap.setDevice(deviceUndulatorGap)
            this.uiApp.uiBeamline.uiUndulatorGap.turnOn()

            this.uiApp.uiBeamline.uiGratingTiltX.setDevice(deviceGratingTiltX)
            this.uiApp.uiBeamline.uiGratingTiltX.turnOn()
                        
        end
        
        function destroyAndDisconnectBL1201CorbaProxy(this)
            
            if ~this.getBL1201CorbaProxy()
                return
            end
            
            % Beamline
            this.uiApp.uiBeamline.uiUndulatorGap.turnOff()
            this.uiApp.uiBeamline.uiUndulatorGap.setDevice([])
            
            this.uiApp.uiBeamline.uiGratingTiltX.turnOff()
            this.uiApp.uiBeamline.uiGratingTiltX.setDevice([])
            
            % this.commBL1201CorbaProxy.delete();
            this.commBL1201CorbaProxy = [];
        end
        
        function initAndConnectNewFocusModel8742(this)
            

            if this.getNewFocusModel8742()
                return
            end
            
            try
                this.commNewFocusModel8742 = newfocus.Model8742( ...
                    'cTcpipHost', this.cTcpipHostNewFocus ...
                );
                this.commNewFocusModel8742.init();
                this.commNewFocusModel8742.connect();
            catch mE
                this.commNewFocusModel8742 = [];
                this.msg(getReport(mE), this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            
            % {< mic.interface.device.GetSetNumber}
            deviceTiltX = bl12014.device.GetSetNumberFromNewFocusModel8742(this.commNewFocusModel8742, 2); % 2

            % {< mic.interface.device.GetSetNumber}
            deviceTiltYMf = bl12014.device.GetSetNumberFromNewFocusModel8742(this.commNewFocusModel8742, 1); % 1
            
            % {< mic.interface.device.GetSetNumber}
            deviceTiltYMfr = bl12014.device.GetSetNumberFromNewFocusModel8742(this.commNewFocusModel8742, 3);
            
            this.uiApp.uiM142.uiStageTiltX.setDevice(deviceTiltX);
            this.uiApp.uiM142.uiStageTiltYMf.setDevice(deviceTiltYMf);
            this.uiApp.uiM142.uiStageTiltYMfr.setDevice(deviceTiltYMfr);
            
            this.uiApp.uiM142.uiStageTiltX.turnOn()
            this.uiApp.uiM142.uiStageTiltYMf.turnOn()
            this.uiApp.uiM142.uiStageTiltYMfr.turnOn()
            
            
        end
        
        function destroyAndDisconnectNewFocusModel8742(this)
            

            if ~this.getNewFocusModel8742()
                return
            end
            
            this.uiApp.uiM142.uiStageTiltX.turnOff()
            this.uiApp.uiM142.uiStageTiltYMf.turnOff()
            this.uiApp.uiM142.uiStageTiltYMfr.turnOff()
            
            this.uiApp.uiM142.uiStageTiltX.setDevice([]);
            this.uiApp.uiM142.uiStageTiltYMf.setDevice([]);
            this.uiApp.uiM142.uiStageTiltYMfr.setDevice([]);
            
            this.commNewFocusModel8742.delete();
            this.commNewFocusModel8742 = [];
                            
        end
        
        
        function initAndConnectGalilD142(this)
            
            if this.getGalilD142()
                return
            end
            
            try
                this.initAndConnectMet5Instruments();
                this.commGalilD142 = this.jMet5Instruments.getDiag142Stage();
                this.commGalilD142.connect();
            catch mE
                this.commGalilD142 = [];
                this.msg(getReport(mE), this.u8_MSG_TYPE_ERROR);
            end
            
            device = bl12014.device.GetSetNumberFromStage(this.commGalilD142, 0);
            
            this.uiApp.uiD142.uiStageY.setDevice(device);
            this.uiApp.uiD142.uiStageY.turnOn();
            
            this.uiApp.uiBeamline.uiD142StageY.setDevice(device);
            this.uiApp.uiBeamline.uiD142StageY.turnOn()
            
        end
        
        function destroyAndDisconnectGalilD142(this)
            if ~this.getGalilD142()
                return
            end
            
            this.uiApp.uiD142.uiStageY.turnOff();
            this.uiApp.uiD142.uiStageY.setDevice([]);
            
            this.uiApp.uiBeamline.uiD142StageY.turnOff()
            this.uiApp.uiBeamline.uiD142StageY.setDevice([]);
            
            this.commGalilD142.disconnect();
            this.commGalilD142 = [];
            
        end
        
        function initAndConnectGalilM143(this)
            if this.getGalilM143()
                return
            end
            
            try
                this.initAndConnectMet5Instruments();
                this.commGalilM143 = this.jMet5Instruments.getDiagM143Stage();
            catch mE
                this.commGalilM143 = [];
                this.msg(getReport(mE), this.u8_MSG_TYPE_ERROR);
            end
            
            device = bl12014.device.GetSetNumberFromStage(this.commGalilM143, 1);
            this.uiApp.uiM143.uiStageY.setDevice(device);
            this.uiApp.uiM143.uiStageY.turnOn();
            
            
        end
        
        function destroyAndDisconnectGalilM143(this)
            if ~this.getGalilM143()
                return
            end
            
            this.uiApp.uiM143.uiStageY.turnOff();
            this.uiApp.uiM143.uiStageY.setDevice([]);
            
            this.commGalilM143.disconnect();
            this.commGalilM143 = [];
            
        end
        
        
        function initAndConnectGalilVIS(this)
            if this.getGalilVIS()
                return
            end
            
            try
                this.initAndConnectMet5Instruments();
                this.commGalilVIS = this.jMet5Instruments.getVISStage();
                this.commGalilVIS.connect();
            catch mE
                this.commGalilVIS = [];
                this.msg(getReport(mE), this.u8_MSG_TYPE_ERROR);
            end
            
            
            device1 = bl12014.device.GetSetNumberFromStage(this.commGalilVIS, 0);
            device2 = bl12014.device.GetSetNumberFromStage(this.commGalilVIS, 1);
            device3 = bl12014.device.GetSetNumberFromStage(this.commGalilVIS, 2);
            device4 = bl12014.device.GetSetNumberFromStage(this.commGalilVIS, 3);
            
            this.uiApp.uiVibrationIsolationSystem.uiStage1.setDevice(device1);
            this.uiApp.uiVibrationIsolationSystem.uiStage2.setDevice(device2);
            this.uiApp.uiVibrationIsolationSystem.uiStage3.setDevice(device3);
            this.uiApp.uiVibrationIsolationSystem.uiStage4.setDevice(device4);
            
            this.uiApp.uiVibrationIsolationSystem.uiStage1.turnOn();
            this.uiApp.uiVibrationIsolationSystem.uiStage2.turnOn();
            this.uiApp.uiVibrationIsolationSystem.uiStage3.turnOn();
            this.uiApp.uiVibrationIsolationSystem.uiStage4.turnOn();
            
        end
        
        function destroyAndDisconnectGalilVIS(this)
            if ~this.getGalilVIS()
                return
            end
            
            this.uiApp.uiVibrationIsolationSystem.uiStage1.turnOff();
            this.uiApp.uiVibrationIsolationSystem.uiStage2.turnOff();
            this.uiApp.uiVibrationIsolationSystem.uiStage3.turnOff();
            this.uiApp.uiVibrationIsolationSystem.uiStage4.turnOff();
            
            this.uiApp.uiVibrationIsolationSystem.uiStage1.setDevice([]);
            this.uiApp.uiVibrationIsolationSystem.uiStage2.setDevice([]);
            this.uiApp.uiVibrationIsolationSystem.uiStage3.setDevice([]);
            this.uiApp.uiVibrationIsolationSystem.uiStage4.setDevice([]);
            
            this.commGalilVIS.disconnect(); 
            this.commGalilVIS = [];
            
        end
        
        function initAndConnectMicronixMmc103(this)
            
            
            if this.getMicronixMmc103()
                return
            end
            
            try
                this.commMicronixMmc103 = micronix.MMC103(...
                    'cConnection', micronix.MMC103.cCONNECTION_TCPIP, ...
                    'cTcpipHost', this.cTcpipHostMicronix ...
                );
                % Create tcpip object
                this.commMicronixMmc103.init();

                % Open connection to tcpip/tcpclient/serial)
                this.commMicronixMmc103.connect();

                % Clear any bytes sitting in the output buffer
                this.commMicronixMmc103.clearBytesAvailable()

                % Get Firmware Version
                % this.commMicronixMmc103.getFirmwareVersion(uint8(1))
            
            catch mE
            
                this.commMicronixMmc103 = [];
                this.msg(getReport(mE), this.u8_MSG_TYPE_ERROR);
                return;
            end
                        
            % {< mic.interface.device.GetSetNumber}
            deviceX = bl12014.device.GetSetNumberFromMicronixMMC103(this.commMicronixMmc103, 1);
            
            % {< mic.interface.device.GetSetNumber}
            deviceTiltZMfr = bl12014.device.GetSetNumberFromMicronixMMC103(this.commMicronixMmc103, 2);
            
            this.uiApp.uiM142.uiStageX.setDevice(deviceX);
            this.uiApp.uiM142.uiStageTiltZMfr.setDevice(deviceTiltZMfr);
            
            this.uiApp.uiM142.uiStageX.turnOn()
            this.uiApp.uiM142.uiStageTiltZMfr.turnOn()
            
        end
        
        function destroyAndDisconnectMicronixMmc103(this)
            
            
            if ~this.getMicronixMmc103()
                return
            end
                                        
            this.uiApp.uiM142.uiStageX.turnOff()
            this.uiApp.uiM142.uiStageTiltZMfr.turnOff()
            
            this.uiApp.uiM142.uiStageX.setDevice([]);
            this.uiApp.uiM142.uiStageTiltZMfr.setDevice([]);
            
            
            this.commMicronixMmc103.delete();
            this.commMicronixMmc103 = [];
            
        end
        
        
        function initAndConnectNPointLC400Pupil(this)
            
            if this.getNPointLC400Pupil()
                return
            end
            
            try
                this.commNPointLC400Pupil = npoint.LC400();
            catch mE
                this.commNPointLC400Pupil = [];
                this.msg(getReport(mE), this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            % this.uiApp.uiPupilScanner
            
        end
        
        function destroyAndDisconnectNPointLC400Pupil(this)
            
            if ~this.getNPointLC400Pupil()
                return
            end

            % this.uiApp.uiPupilScanner
            
            this.commNPointLC400Pupil.delete();
            this.commNPointLC400Pupil = [];
        end
        
        function initAndConnectNPointLC400Field(this)
            

            if this.getNPointLC400Field()
                return
            end
            
            try
                this.commNPointLC400Field = npoint.LC400();
            catch mE
                this.commNPointLC400Field = [];
                this.msg(getReport(mE), this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            % this.uiApp.uiFieldScanner
            
        end
        
        function destroyAndDisconnectNPointLC400Field(this)
            
            if ~this.getNPointLC400Field()
                return
            end
            
            % this.uiApp.uiFieldScanner
            this.commNPointLC400Field.delete();
            this.commNPointLC400Field = [];
        end
        
        
        function buildFigure(this)
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            else 
            
                
                % Figure
                this.hFigure = figure( ...
                    'NumberTitle', 'off', ...
                    'MenuBar', 'none', ...
                    'Name', 'MET5', ...
                    'Position', [50 50 this.dWidth this.dHeight], ... % left bottom width height
                    'Resize', 'off', ...
                    'HandleVisibility', 'on', ... % lets close all close the figure
                    'Visible', 'on'...
                );
                % 'CloseRequestFcn', @this.onCloseRequestFcn ...

                drawnow;                
            end
            
        end
        
        %{
        function initUiComm(this)
            
            stBL1201CorbaProxy = struct(...
                'cLabel',  'CXRO Beamline', ...
                'fhOnClick',  @this.connectCommBL1201CorbaProxy, ...
                'cTooltip',  'Mono grating TiltX, Exit Slit, shutter' ...
            );
        
            stDataTranslationMeasurPoint = struct( ...
                'cLabel',  'Data Translation MeasurPoint', ...
                'fhOnClick',  @this.connectCommDataTranslationMeasurPoint, ...
                'cTooltip',  'M141 diode, D141 diode, D142 diode, M143 diode, Vis RTDs, Metrology Frame RTDs, Mod3 RTDs, POB RDTs' ...
            );
        
            % No longer needed?
            stWago = struct( ...
                'cLabel', 'Wago', ...
                'fhOnClick', @this.connectCommWago, ...
                'cTooltip', 'D141 Actuator' ...
            );
        
            stSmarActMcsM141 = struct( ...
                'cLabel',  'SmarAct MCS (M141)', ...
                'fhOnClick',  @this.connectCommSmarActMcsM141, ...
                'cTooltip',  'M141 Stage' ...
            );
        
            stSmarActMcsGoni = struct( ...
                'cLabel',  'SmarAct MCS (Goni)', ...
                'fhOnClick',  @this.connectCommSmarActMcsGoni, ...
                'cTooltip',  'Interferometry Goniometer' ...
            );
            
            stMicronixMmc103 = struct( ...
                'cLabel',   'Micronix MMC-103', ...
                'fhOnClick',  @this.connectCommMicronixMmc103, ...
                'cTooltip',  'M142 + M142R common x, M142R tiltZ' ...
            );
            
            stNewFocusModel8742 = struct( ...
                'cLabel',   'New Focus 8742', ...
                'fhOnClick',  @this.connectCommNewFocusModel8742, ...
                'cTooltip',  'M142 + M142R common tiltX, M142 tiltY, M142R tiltY' ...
            );
            
            stNPointLC400Field = struct( ...
                'cLabel',   'nPoint LC.403 (Field)', ...
                'fhOnClick',  @this.connectCommNPointLC400Field, ...
                'cTooltip',  'M142 Field Scan' ...
            );
            
            stNPointLC400Pupil = struct( ...
                'cLabel',  'nPoint LC.403 (Pupil)', ...
                'fhOnClick',  @this.connectCommNPointLC400Pupil, ...
                'cTooltip',  'MA Pupil Scan' ...
            );
            
            stDeltaTauPowerPmac = struct( ...
                'cLabel',   'Delta Tau Power PMAC', ...
                'fhOnClick',  @this.connectCommDeltaTauPowerPmac, ...
                'cTooltip',  'Reticle Stage, Reticle RTDs, Wafer Stage, Wafer RTDs' ...
            );
        
            stKeithley6482Reticle = struct( ...
                'cLabel',  'Keithley6482 (Reticle)', ...
                'fhOnClick',  @this.connectCommKeithley6482Reticle, ...
                'cTooltip',  'Reticle Diode' ...
            );
        
            stKeithley6482Wafer = struct( ...
                'cLabel',  'Keithley6482 (Wafer)', ...
                'fhOnClick',  @this.connectCommKeithley6482Wafer, ...
                'cTooltip',  'Wafer Diode (Dose), Wafer Diode (Focus)' ...
            );
            
            stCxroHeightSensor = struct( ...
                'cLabel',  'CXRO Height Sensor', ...
                'fhOnClick',  @this.connectCommCxroHeightSensor, ...
                'cTooltip',  'Wafer Z + TiltX + TiltY' ...
            );
            
            stSmarActSmarPod = struct( ...
                'cLabel',   'SmarAct SmarPod', ...
                'fhOnClick',  @this.connectCommSmarActSmarPod, ...
                'cTooltip',  'Interferometry Hexapod' ...
            );
            
        % stWago, ...

            stButtons = [...
                stBL1201CorbaProxy ...
                stKeithley6482Reticle, ...
                stKeithley6482Wafer, ...
                stDeltaTauPowerPmac, ...
                stNPointLC400Field, ...
                stNPointLC400Pupil, ...
                stNewFocusModel8742, ...
                stMicronixMmc103, ...
                stSmarActMcsM141, ...
                stDataTranslationMeasurPoint, ...
                stSmarActSmarPod, ...
                stSmarActMcsGoni, ...
                stCxroHeightSensor ...
            ];
                
            
            this.uiComm = bl12014.ui.Comm(...
                'stButtonDefinitions', stButtons, ...
                'cTitle', 'Hardware Comm', ...
                'dWidthButton', this.dWidthButton ...
            );
            
        end
        %}
        
        
        
        
        
        function initGetSetLogicalConnects(this)
            
            
            gslcCommExitSlit = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getExitSlit, ...
                'fhSetTrue', @this.initAndConnectExitSlit, ...
                'fhSetFalse', @this.destroyAndDisconnectExitSlit ...
            );
        
            gslcCommNewFocusModel8742 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getNewFocusModel8742, ...
                'fhSetTrue', @this.initAndConnectNewFocusModel8742, ...
                'fhSetFalse', @this.destroyAndDisconnectNewFocusModel8742 ...
            );
        
            gslcCommSmarActMcsM141 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getSmarActMcsM141, ...
                'fhSetTrue', @this.initAndConnectSmarActMcsM141, ...
                'fhSetFalse', @this.destroyAndDisconnectSmarActMcsM141 ...
            );
        
            gslcCommSmarActRotary = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getSmarActRotary, ...
                'fhSetTrue', @this.initAndConnectSmarActRotary, ...
                'fhSetFalse', @this.destroyAndDisconnectSmarActRotary ...
            );
        
            gslcCommSmarActMcsGoni = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getSmarActMcsGoni, ...
                'fhSetTrue', @this.initAndConnectSmarActMcsGoni, ...
                'fhSetFalse', @this.destroyAndDisconnectSmarActMcsGoni ...
            );
        
            gslcCommDeltaTauPowerPmac = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getDeltaTauPowerPmac, ...
                'fhSetTrue', @this.initAndConnectDeltaTauPowerPmac, ...
                'fhSetFalse', @this.destroyAndDisconnectDeltaTauPowerPmac ...
            );
        
            gslcCommDataTranslationMeasurPoint = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getDataTranslationMeasurPoint, ...
                'fhSetTrue', @this.initAndConnectDataTranslationMeasurPoint, ...
                'fhSetFalse', @this.destroyAndDisconnectDataTranslationMeasurPoint ...
            );
        
            %{
            gslcCommNPointLC400Field = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getNPointLC400Field, ...
                'fhSetTrue', @this.initAndConnectNPointLC400Field, ...
                'fhSetFalse', @this.destroyAndDisconnectNPointLC400Field ...
            );
        
            gslcCommNPointLC400Pupil = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getNPointLC400Pupil, ...
                'fhSetTrue', @this.initAndConnectNPointLC400Pupil, ...
                'fhSetFalse', @this.destroyAndDisconnectNPointLC400Pupil ...
            );
            %}
            
            gslcCommCxroHeightSensor = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getCxroHeightSensor, ...
                'fhSetTrue', @this.initAndConnectCxroHeightSensor, ...
                'fhSetFalse', @this.destroyAndDisconnectCxroHeightSensor ...
            );
        
            gslcCommKeithley6482Reticle = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getKeithley6482Reticle, ...
                'fhSetTrue', @this.initAndConnectKeithley6482Reticle, ...
                'fhSetFalse', @this.destroyAndDisconnectKeithley6482Reticle ...
            );
        
            gslcCommKeithley6482Wafer = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getKeithley6482Wafer, ...
                'fhSetTrue', @this.initAndConnectKeithley6482Wafer, ...
                'fhSetFalse', @this.destroyAndDisconnectKeithley6482Wafer ...
            );
        
        
            gslcCommDctCorbaProxy = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getDctCorbaProxy, ...
                'fhSetTrue', @this.initAndConnectDctCorbaProxy, ...
                'fhSetFalse', @this.destroyAndDisconnectDctCorbaProxy ...
            );
        
            gslcCommBL1201CorbaProxy = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getBL1201CorbaProxy, ...
                'fhSetTrue', @this.initAndConnectBL1201CorbaProxy, ...
                'fhSetFalse', @this.destroyAndDisconnectBL1201CorbaProxy ...
            );
        
            gslcCommMicronixMmc103 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getMicronixMmc103, ...
                'fhSetTrue', @this.initAndConnectMicronixMmc103, ...
                'fhSetFalse', @this.destroyAndDisconnectMicronixMmc103 ...
            );
        
        
            gslcCommGalilM143 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getGalilM143, ...
                'fhSetTrue', @this.initAndConnectGalilM143, ...
                'fhSetFalse', @this.destroyAndDisconnectGalilM143 ...
            );
        
            gslcCommGalilVIS = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getGalilVIS, ...
                'fhSetTrue', @this.initAndConnectGalilVIS, ...
                'fhSetFalse', @this.destroyAndDisconnectGalilVIS ...
            );
        
            gslcCommGalilD142 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getGalilD142, ...
                'fhSetTrue', @this.initAndConnectGalilD142, ...
                'fhSetFalse', @this.destroyAndDisconnectGalilD142 ...
            );
        

            %this.uiApp.uiBeamline.uiCommBL1201CorbaProxy.setDevice(gslcCommBL1201CorbaProxy);
            %this.uiApp.uiShutter.uiCommBL1201CorbaProxy.setDevice(gslcCommBL1201CorbaProxy);
            
            % Beamline
            this.uiApp.uiBeamline.uiCommDctCorbaProxy.setDevice(gslcCommDctCorbaProxy)
            this.uiApp.uiBeamline.uiCommDctCorbaProxy.turnOn()
            
            this.uiApp.uiBeamline.uiCommBL1201CorbaProxy.setDevice(gslcCommBL1201CorbaProxy)
            this.uiApp.uiBeamline.uiCommBL1201CorbaProxy.turnOn()
            
            this.uiApp.uiBeamline.uiCommExitSlit.setDevice(gslcCommExitSlit);
            this.uiApp.uiBeamline.uiCommExitSlit.turnOn()
            
            this.uiApp.uiBeamline.uiCommDataTranslationMeasurPoint.setDevice(gslcCommDataTranslationMeasurPoint);
            this.uiApp.uiBeamline.uiCommDataTranslationMeasurPoint.turnOn()
            
            this.uiApp.uiBeamline.uiCommGalilD142.setDevice(gslcCommGalilD142);
            this.uiApp.uiBeamline.uiCommGalilD142.turnOn()
            
            % M141
            this.uiApp.uiM141.uiCommSmarActMcsM141.setDevice(gslcCommSmarActMcsM141);
            this.uiApp.uiM141.uiCommSmarActMcsM141.turnOn();
            this.uiApp.uiM141.uiCommDataTranslationMeasurPoint.setDevice(gslcCommDataTranslationMeasurPoint)
            this.uiApp.uiM141.uiCommDataTranslationMeasurPoint.turnOn();
            
            
            % M142
            this.uiApp.uiM142.uiCommMicronixMmc103.setDevice(gslcCommMicronixMmc103);
            this.uiApp.uiM142.uiCommMicronixMmc103.turnOn();
            this.uiApp.uiM142.uiCommNewFocusModel8742.setDevice(gslcCommNewFocusModel8742);
            this.uiApp.uiM142.uiCommNewFocusModel8742.turnOn();
            
            % this.uiApp.uiM143.uiCommDataTranslationMeasurPoint.setDevice(gslcCommDataTranslationMeasurPoint)
            % this.uiApp.uiM143.uiCommDataTranslationMeasurPoint.turnOn()
            
            % D141
            
            this.uiApp.uiD141.uiCommDataTranslationMeasurPoint.setDevice(gslcCommDataTranslationMeasurPoint)
            this.uiApp.uiD141.uiCommDataTranslationMeasurPoint.turnOn()
            
            % D142
            this.uiApp.uiD142.uiCommGalil.setDevice(gslcCommGalilD142);
            this.uiApp.uiD142.uiCommGalil.turnOn();
            this.uiApp.uiD142.uiCommDataTranslationMeasurPoint.setDevice(gslcCommDataTranslationMeasurPoint)
            this.uiApp.uiD142.uiCommDataTranslationMeasurPoint.turnOn()
            
            % M143
            this.uiApp.uiM143.uiCommGalil.setDevice(gslcCommGalilM143)
            this.uiApp.uiM143.uiCommGalil.turnOn();
            this.uiApp.uiM143.uiCommDataTranslationMeasurPoint.setDevice(gslcCommDataTranslationMeasurPoint);
            this.uiApp.uiM143.uiCommDataTranslationMeasurPoint.turnOn();
            
            % Vibration Isolation System
            this.uiApp.uiVibrationIsolationSystem.uiCommGalil.setDevice(gslcCommGalilVIS)
            this.uiApp.uiVibrationIsolationSystem.uiCommGalil.turnOn();
            
            % Reticle
            this.uiApp.uiReticle.uiCommDeltaTauPowerPmac.setDevice(gslcCommDeltaTauPowerPmac)
            this.uiApp.uiReticle.uiCommKeithley6482.setDevice(gslcCommKeithley6482Reticle)
            this.uiApp.uiReticle.uiCommDataTranslationMeasurPoint.setDevice(gslcCommDataTranslationMeasurPoint);
            this.uiApp.uiReticle.uiCommDeltaTauPowerPmac.turnOn()
            this.uiApp.uiReticle.uiCommKeithley6482.turnOn()
            this.uiApp.uiReticle.uiCommDataTranslationMeasurPoint.turnOn()
           
            % Wafer
            this.uiApp.uiWafer.uiCommDeltaTauPowerPmac.setDevice(gslcCommDeltaTauPowerPmac)
            this.uiApp.uiWafer.uiCommDataTranslationMeasurPoint.setDevice(gslcCommDataTranslationMeasurPoint);
            this.uiApp.uiWafer.uiCommKeithley6482.setDevice(gslcCommKeithley6482Wafer)
            this.uiApp.uiWafer.uiCommCxroHeightSensor.setDevice(gslcCommCxroHeightSensor)
            this.uiApp.uiWafer.uiCommDeltaTauPowerPmac.turnOn()
            this.uiApp.uiWafer.uiCommDataTranslationMeasurPoint.turnOn()
            this.uiApp.uiWafer.uiCommKeithley6482.turnOn()
            this.uiApp.uiWafer.uiCommCxroHeightSensor.turnOn()
            
            % Power PMAC Status
            this.uiApp.uiPowerPmacStatus.uiCommDeltaTauPowerPmac.setDevice(gslcCommDeltaTauPowerPmac)
            this.uiApp.uiPowerPmacStatus.uiCommDeltaTauPowerPmac.turnOn();
            
            %this.uiApp.uiScannerControlMA.ui
            %this.uiApp.uiScannerControlM142.ui
            %this.uiApp.uiPrescriptionTool.ui          
            %this.uiApp.uiScan.ui
            
            this.uiApp.uiTempSensors.uiCommDataTranslationMeasurPoint.setDevice(gslcCommDataTranslationMeasurPoint)
            this.uiApp.uiTempSensors.uiCommDeltaTauPowerPmac.setDevice(gslcCommDeltaTauPowerPmac)
            this.uiApp.uiTempSensors.uiCommDataTranslationMeasurPoint.turnOn()
            this.uiApp.uiTempSensors.uiCommDeltaTauPowerPmac.turnOn()
            
            
            % Focus Sensor
            this.uiApp.uiFocusSensor.uiCommSmarActRotary.setDevice(gslcCommSmarActRotary);
            this.uiApp.uiFocusSensor.uiCommSmarActRotary.turnOn();
            this.uiApp.uiFocusSensor.uiCommKeithley6482.setDevice(gslcCommKeithley6482Wafer);
            this.uiApp.uiFocusSensor.uiCommKeithley6482.turnOn();
            this.uiApp.uiFocusSensor.uiCommDeltaTauPowerPmac.setDevice(gslcCommDeltaTauPowerPmac)
            this.uiApp.uiFocusSensor.uiCommDeltaTauPowerPmac.turnOn();
        end
        
        
        function init(this)
            
            this.uiApp = bl12014.ui.App(...
                'dWidthButtonButtonList', this.dWidthButton ...
            ); 
            this.initGetSetLogicalConnects();
            % this.initUiComm();
            % this.initAndConnect()
            % this.loadStateFromDisk();

        end
        
        function onCloseRequestFcn(this, src, evt)
            this.msg('closeRequestFcn()');
            % purge;
            delete(this.hFigure);
            % this.saveState();
        end
         
                

    end % private
    
    
end