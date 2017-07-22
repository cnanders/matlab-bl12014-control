classdef App < mic.Base
        
    properties (Constant)
        
        dWidth = 150
        dHeight = 440
        
        dWidthButton = 110
        
        cTcpipHostMicronix = '192.168.0.2'
        cTcpipHostNewFocus = '192.168.0.3'
        cTcpipHostKeithley6482Wafer = '192.168.0.3'
        
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
        
        % {cxro.bl1201.Beamline 1x1}
        commCxroBeamline
        
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
        
        commGalilD142
        
        commGalilM143
        
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        hFigure
        uiApp
        
        % {bl12014.Comm 1x1}
        comm
        
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = App()
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
        
        function destroyAndDisconnectAll(this)
            this.destroyAndDisconnectCxroBeamline();
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
        
        function l = getGalilM142(this)
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
        
        function l = getCxroBeamline(this)
            l = ~isempty(this.commCxroBeamline);
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
                this.initCommMet5Instruments();
                this.commSmarActMcsM141 = this.jMet5Instruments.getM141Stage();
            catch mE
                this.commSmarActMcsM141 = [];
                return
            end
            
            % {< mic.interface.device.GetSetNumber}
            deviceX = bl12014.device.GetSetNumberFromStage(this.commSmarActMcsM141, 1);

            % {< mic.interface.device.GetSetNumber}
            deviceTiltX = bl12014.device.GetSetNumberFromStage(this.commSmarActMcsM141, 2);

            % {< mic.interface.device.GetSetNumber}
            deviceTiltY = bl12014.device.GetSetNumberFromStage(this.commSmarActMcsM141, 3);
            
            this.uiApp.uiM141.uiStageX.setDevice(deviceX);
            this.uiApp.uiM141.uiStageTiltX.setDevice(deviceTiltX);
            this.uiApp.uiM141.uiStageTiltY.setDevice(deviceTiltY);
            
            
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
            
            
            this.commSmarActMcsM141 = [];
        end
        
        
        function initAndConnectSmarActRotary(this)
            
            if this.getSmarActRotary()
                return
            end
            
            try 
                
            catch mE
                
            end
            
            % Wafer Focus Sensor
            
            device = bl12014.device.GetSetNumberFromStage(this.commSmarActRotary, 1);
            % 

            
        end
        
        function destroyAndDisconnectSmarActRotary(this)
            if ~this.getSmarActRotary()
                return
            end
            
            % Wafer Focus Sensor
            
            
        end
        
        
        function initAndConnectSmarActMcsGoni(this)
            
            
            if this.getSmarActMcsGoni()
                return
            end
            
            try
                this.initCommMet5Instruments();
                this.commSmarActMcsGoni = this.jMet5Instruments.getLsiGoniometer();
            catch mE
                this.commSmarActMcsGoni = [];
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
                this.initCommMet5Instruments();
                this.commSmarActSmarPod = this.jMet5Instruments.getLsiHexapod();
            catch mE
                this.commSmarActSmarPod = [];
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
                return
            end
            
            
            % M141
            device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 1);
            this.uiApp.uiM141.uiMeasurPointVolts.setDevice(device);
            
            % D141
            device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 1);
            this.uiApp.uiD141.uiMeasurPointVolts.setDevice(device);
            
            % D142
            device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 1);
            this.uiApp.uiD142.uiMeasurPointVolts.setDevice(device);
            
            % M143
            device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 1);
            this.uiApp.uiM143.uiMeasurPointVolts.setDevice(device);
            
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
            
            % Wafer
            
            deviceCap1 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 21);
            deviceCap2 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 22);
            deviceCap3 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 23);
            deviceCap4 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint, 24);
            
            this.uiApp.uiWafer.uiPobCapSensors.uiCap1.setDevice(deviceCap1);
            this.uiApp.uiWafer.uiPobCapSensors.uiCap2.setDevice(deviceCap2);
            this.uiApp.uiWafer.uiPobCapSensors.uiCap3.setDevice(deviceCap3);
            this.uiApp.uiWafer.uiPobCapSensors.uiCap4.setDevice(deviceCap4);
            
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
            
        end
        
        function destroyAndDisconnectDataTranslationMeasurPoint(this)
            
            if ~this.getDataTranslationMeasurPoint()
                return
            end
            
            
            
            % M141
            this.uiApp.uiM141.uiMeasurPointVolts.turnOff();
            this.uiApp.uiM141.uiMeasurPointVolts.setDevice([]);
            
            % D141
            this.uiApp.uiD141.uiMeasurPointVolts.turnOff();
            this.uiApp.uiD141.uiMeasurPointVolts.setDevice([]);
            
            % D142
            this.uiApp.uiD142.uiMeasurPointVolts.turnOff();
            this.uiApp.uiD142.uiMeasurPointVolts.setDevice([]);
            
            % M143
            this.uiApp.uiM143.uiMeasurPointVolts.turnOff();
            this.uiApp.uiM143.uiMeasurPointVolts.setDevice([]);
            
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
        
        function initAndConnectDeltaTauPowerPmac(this)
           
            if this.getDeltaTauPowerPmac()
                return
            end
            
            try
                this.commDeltaTauPowerPmac = deltaTau.powerPmac.PowerPmac();
            catch mE
                this.commDeltaTauPowerPmac = []
                return
            end
            
            % Reticle
            
            % Wafer
            
            
            
            
        end
        
        function destroyAndDisconnectDeltaTauPowerPmac(this)

            if ~this.getDeltaTauPowerPmac()
                return
            end
            
            % Reticle
            
            % Wafer
            
            
            this.commDeltaTauPowerPmac.delete();
            this.commDeltaTauPowerPmac = [];
            
        end
        
        
        function initAndConnectBeamline12ExitSlits(this)
            
            if this.getBeamline12ExitSlits()
                return
            end
            
            try
                [this.commBeamline12ExitSlits, e] = bl12pico_attach();
            catch mE
                this.commBeamline12ExitSlits = [];
            end
            
            device = bl12014.device.GetSetNumberFromBeamline12ExitSlits(comm);
            this.uiApp.uiBeamline.uiDeviceExitSlit.setDevice(device);
            this.uiApp.uiBeamline.uiDeviceExitSlit.turnOn();
        
            
        end
        
        function destroyAndDisconnectBeamline12ExitSlits(this)
            
            if ~this.getBeamline12ExitSlits()
                return
            end
            
            this.uiApp.uiBeamline.uiDeviceExitSlit.turnOff();
            this.uiApp.uiBeamline.uiDeviceExitSlit.setDevice([]);
            
            % this.commBeamline12ExitSlits.delete();
            this.commBeamline12ExitSlits = [];
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
        
        function initAndConnectCxroBeamline(this)
            
            if this.getCxroBeamline()
                return
            end
            
            try
                this.commCxroBeamline = cxro.bl1201.Beamline();
            catch mE
                this.commCxroBeamline = [];
                return;
            end
            
            % Beamline
            
                        
        end
        
        function destroyAndDisconnectCxroBeamline(this)
            
            if ~this.getCxroBeamline()
                return
            end
            
            % Beamline
            
            this.commCxroBeamline.delete();
            this.commCxroBeamline = [];
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
                rethrow(mE)
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
                
            catch mE
                
            end
            
            device = bl12014.device.GetSetNumberFromGalil(this.commGalilD142, 1);
            this.uiApp.uiD142.uiStageY.setDevice(device);
            
        end
        
        function destroyAndDisconnectGalilD142(this)
            if ~this.getGalilD142()
                return
            end
            
            this.uiApp.uiD142.uiStageY.turnOff();
            this.uiApp.uiD142.uiStageY.setDevice([]);
            
            this.commGalilD142 = [];
            
        end
        
        function initAndConnectGalilM143(this)
            if this.getGalilM143()
                return
            end
            
            try
                
            catch mE
                
            end
            
            device = bl12014.device.GetSetNumberFromGalil(this.commGalilM143, 1);
            this.uiApp.uiM143.uiStageY.setDevice(device);
            
            
        end
        
        function destroyAndDisconnectGalilM143(this)
            if ~this.getGalilM143()
                return
            end
            
            this.uiApp.uiM143.uiStageY.turnOff();
            this.uiApp.uiM143.uiStageY.setDevice([]);
            
            this.commGalilM143 = [];
            
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
                    'Position', [0 0 this.dWidth this.dHeight], ... % left bottom width height
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
            
            stCxroBeamline = struct(...
                'cLabel',  'CXRO Beamline', ...
                'fhOnClick',  @this.connectCommCxroBeamline, ...
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
                'cLabel',   'Delta Tau PowerPMAC', ...
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
                stCxroBeamline ...
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
            
            gslcNewFocusModel8742 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getNewFocusModel8742, ...
                'fhSetTrue', @this.initAndConnectNewFocusModel8742, ...
                'fhSetFalse', @this.destroyAndDisconnectNewFocusModel8742 ...
            );
        
            gslcSmarActMcsM141 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getSmarActMcsM141, ...
                'fhSetTrue', @this.initAndConnectSmarActMcsM141, ...
                'fhSetFalse', @this.destroyAndDisconnectSmarActMcsM141 ...
            );
        
            gslcSmarActMcsGoni = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getSmarActMcsGoni, ...
                'fhSetTrue', @this.initAndConnectSmarActMcsGoni, ...
                'fhSetFalse', @this.destroyAndDisconnectSmarActMcsGoni ...
            );
        
            gslcDeltaTauPowerPmac = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getDeltaTauPowerPmac, ...
                'fhSetTrue', @this.initAndConnectDeltaTauPowerPmac, ...
                'fhSetFalse', @this.destroyAndDisconnectDeltaTauPowerPmac ...
            );
        
            gslcDataTranslationMeasurPoint = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getDataTranslationMeasurPoint, ...
                'fhSetTrue', @this.initAndConnectDataTranslationMeasurPoint, ...
                'fhSetFalse', @this.destroyAndDisconnectDataTranslationMeasurPoint ...
            );
        
            %{
            gslcNPointLC400Field = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getNPointLC400Field, ...
                'fhSetTrue', @this.initAndConnectNPointLC400Field, ...
                'fhSetFalse', @this.destroyAndDisconnectNPointLC400Field ...
            );
        
            gslcNPointLC400Pupil = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getNPointLC400Pupil, ...
                'fhSetTrue', @this.initAndConnectNPointLC400Pupil, ...
                'fhSetFalse', @this.destroyAndDisconnectNPointLC400Pupil ...
            );
            %}
            
            gslcCxroHeightSensor = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getCxroHeightSensor, ...
                'fhSetTrue', @this.initAndConnectCxroHeightSensor, ...
                'fhSetFalse', @this.destroyAndDisconnectCxroHeightSensor ...
            );
        
            gslcKeithley6482Reticle = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getKeithley6482Reticle, ...
                'fhSetTrue', @this.initAndConnectKeithley6482Reticle, ...
                'fhSetFalse', @this.destroyAndDisconnectKeithley6482Reticle ...
            );
        
            gslcKeithley6482Wafer = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getKeithley6482Wafer, ...
                'fhSetTrue', @this.initAndConnectKeithley6482Wafer, ...
                'fhSetFalse', @this.destroyAndDisconnectKeithley6482Wafer ...
            );
        
            gslcCxroBeamline = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getCxroBeamline, ...
                'fhSetTrue', @this.initAndConnectCxroBeamline, ...
                'fhSetFalse', @this.destroyAndDisconnectCxroBeamline ...
            );
        
            gslcMicronixMmc103 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getMicronixMmc103, ...
                'fhSetTrue', @this.initAndConnectMicronixMmc103, ...
                'fhSetFalse', @this.destroyAndDisconnectMicronixMmc103 ...
            );
        

            %this.uiApp.uiBeamline.uiCxroBeamline.setDevice(gslcCxroBeamline);
            %this.uiApp.uiShutter.uiCxroBeamline.setDevice(gslcCxroBeamline);
            
            this.uiApp.uiM141.uiSmarActMcsM141.setDevice(gslcSmarActMcsM141);
            this.uiApp.uiM141.uiSmarActMcsM141.turnOn();
            this.uiApp.uiM141.uiDataTranslationMeasurPoint.setDevice(gslcDataTranslationMeasurPoint)
            this.uiApp.uiM141.uiDataTranslationMeasurPoint.turnOn();
            
            this.uiApp.uiM142.uiMicronixMmc103.setDevice(gslcMicronixMmc103);
            this.uiApp.uiM142.uiMicronixMmc103.turnOn();
            this.uiApp.uiM142.uiNewFocusModel8742.setDevice(gslcNewFocusModel8742);
            this.uiApp.uiM142.uiNewFocusModel8742.turnOn();
            
            % this.uiApp.uiM143.uiDataTranslationMeasurPoint.setDevice(gslcDataTranslationMeasurPoint)
            % this.uiApp.uiM143.uiDataTranslationMeasurPoint.turnOn()
            
            this.uiApp.uiD141.uiDataTranslationMeasurPoint.setDevice(gslcDataTranslationMeasurPoint)
            this.uiApp.uiD141.uiDataTranslationMeasurPoint.turnOn()
            
            this.uiApp.uiD142.uiDataTranslationMeasurPoint.setDevice(gslcDataTranslationMeasurPoint)
            this.uiApp.uiD142.uiDataTranslationMeasurPoint.turnOn()
            
            this.uiApp.uiReticle.uiDeltaTauPowerPmac.setDevice(gslcDeltaTauPowerPmac)
            this.uiApp.uiReticle.uiKeithley6482.setDevice(gslcKeithley6482Reticle)
            this.uiApp.uiReticle.uiDataTranslationMeasurPoint.setDevice(gslcDataTranslationMeasurPoint);
            this.uiApp.uiReticle.uiDeltaTauPowerPmac.turnOn()
            this.uiApp.uiReticle.uiKeithley6482.turnOn()
            this.uiApp.uiReticle.uiDataTranslationMeasurPoint.turnOn()
           
            this.uiApp.uiWafer.uiDeltaTauPowerPmac.setDevice(gslcDeltaTauPowerPmac)
            this.uiApp.uiWafer.uiDataTranslationMeasurPoint.setDevice(gslcDataTranslationMeasurPoint);
            this.uiApp.uiWafer.uiKeithley6482.setDevice(gslcKeithley6482Wafer)
            this.uiApp.uiWafer.uiCxroHeightSensor.setDevice(gslcCxroHeightSensor)
            this.uiApp.uiWafer.uiDeltaTauPowerPmac.turnOn()
            this.uiApp.uiWafer.uiDataTranslationMeasurPoint.turnOn()
            this.uiApp.uiWafer.uiKeithley6482.turnOn()
            this.uiApp.uiWafer.uiCxroHeightSensor.turnOn()
            
            %this.uiApp.uiScannerControlMA.ui
            %this.uiApp.uiScannerControlM142.ui
            %this.uiApp.uiPrescriptionTool.ui          
            %this.uiApp.uiScan.ui
            
            this.uiApp.uiTempSensors.uiDataTranslationMeasurPoint.setDevice(gslcDataTranslationMeasurPoint)
            this.uiApp.uiTempSensors.uiDeltaTauPowerPmac.setDevice(gslcDeltaTauPowerPmac)
            this.uiApp.uiTempSensors.uiDataTranslationMeasurPoint.turnOn()
            this.uiApp.uiTempSensors.uiDeltaTauPowerPmac.turnOn()
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