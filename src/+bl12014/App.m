classdef App < mic.Base
        
    properties (Constant)
        
        dWidth = 250
        dHeight = 750
        
        dWidthButton = 210
        
        % Branchline Subnet
        cTcpipSmarActM141 = '192.168.10.20'
        cTcpipMicronix = '192.168.10.21'
        cTcpipLc400M142 = '192.168.10.22'
        cTcpipNewFocus = '192.168.10.23'
        cTcpipGalilD142 = '192.168.10.24'
        cTcpipGalilM143 = '192.168.10.25'
        
        % Endstation 1 Subnet
        cTcpipLc400MA = '192.168.20.20'
        % cTcpipGalilVibrationIsolationSystem = '192.168.20.21'
        cTcpipAcromag = '192.168.20.22'
        cTcpipDeltaTau = '192.168.20.23'
        cTcpipSmarActLSIGoni = '192.168.20.24'
        cTcpipSmarActLSIHexapod = '192.168.20.25'
        cTcpipSmarActFocusMonitor = '192.168.20.26'
        cTcpipDataTranslation = '192.168.20.27'
        cTcpipKeithley6482Wafer = '192.168.20.28'
        cTcpipKeithley6482Reticle = '192.168.20.28'
        
        cTcpipRigolDG1000Z = '192.168.20.35' % Temporary
        
        cTcpip3GStoreRemotePowerSwitch1 = '192.168.10.30'; % Beamline
        cTcpip3GStoreRemotePowerSwitch2 = '192.168.20.30'; % End station
        

        % Video Subnet
        
        % Endstation 2 Subnet
        
        
    end
    
	properties
        
        hardware
        
        % {cxro.met5.Instruments 1x1}
        jMet5Instruments
        
        % {rigol.DG1000Z 1x1}
        commRigolDG1000Z
        
        % {cxro.common.device.motion.Stage 1x1}
        commSmarActMcsM141
        
        % {cxro.common.device.motion.Stage 1x1}
        commSmarActMcsGoni
        
        % {cxro.common.device.motion.Stage 1x1}
        commSmarActSmarPod
        
        % Temporarily:{lsicontrol.virtualDevice.virtualPVCam}
        commPIMTECamera
        lUseVirtualPVCam = false % <--- helpful for debugging PI-MTE cam
        
        commSmarActRotary
        
        % {deltaTau.PowerPmac 1x1}
        commDeltaTauPowerPmac
        
        % {MFDriftMonitor}
        commMFDriftMonitor
        
        % {dataTranslation.MeasurPoint 1x1}
        commDataTranslationMeasurPoint
        
        % {npoint.LC400 1x1}
        commNPointLC400M142
        
        % {npoint.LC400 1x1}
        commNPointLC400MA
        
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
        commGalilVis
        
        % see vendor/pnaulleau/bl12-exit-slits/readme.txt
        commExitSlit
        
        % Since uses dll, this will be true or false
        commMightex1
        commMightex2
        
        % {threegstore.RemotePowerSwitch}
        % github.com/cnanders/matlab-3gstore-remote-power-switch
        comm3GStoreRemotePowerSwitch1
        comm3GStoreRemotePowerSwitch2
        
        
        uiApp
        
        
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        cPathDllMightex
        cPathHeaderMightex
        
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
            
            [cDirThis] = fileparts(mfilename('fullpath'));

            cDirMightex = fullfile(cDirThis, '..', '..', 'src', 'vendor', 'mightex');
            this.cPathDllMightex =  fullfile(cDirMightex, 'Mightex_LEDDriver_SDK.dll');
            this.cPathHeaderMightex = fullfile(cDirMightex, 'Mightex_LEDDriver_SDK.h');
            
            this.init();
            
            
        end
        
                
        function build(this)
            
            this.buildFigure();
            this.uiApp.build(this.hFigure, 10, 10);
            % this.uiComm.build(this.hFigure, 210, 10);
        end
        
        %% Destructor
        
        function delete(this)
           
            this.destroyAndDisconnectAll();
            delete(this.uiApp)
            
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
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
           end
            
        end
        
        function destroyAndDisconnectMet5Instruments(this)
            
           if isempty(this.jMet5Instruments)
               return
           end
           
           this.jMet5Instruments.disconnect();
           this.jMet5Instruments = [];
           
            
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
            this.destroyAndDisconnectNPointLC400M142();
            this.destroyAndDisconnectNPointLC400MA();
            this.destroyAndDisconnectSmarActMcsGoni();
            this.destroyAndDisconnectSmarActMcsM141();
            this.destroyAndDisconnectSmarActSmarPod();
            this.destroyAndDisconnectSmarActRotary();
            this.destroyAndDisconnect3GStoreRemotePowerSwitch1();
            this.destroyAndDisconnect3GStoreRemotePowerSwitch2();
            this.destroyAndDisconnectMightex();
            this.destroyAndDisconnectMet5Instruments();

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
        
        function l = getPIMTECamera(this)
            l = ~isempty(this.commPIMTECamera);
        end
        
        function l = getMicronixMmc103(this)
            l = ~isempty(this.commMicronixMmc103);
            
        end
        
        function l = getRigolDG1000Z(this)
            l = ~isempty(this.commRigolDG1000Z);
            
        end
        
        function l = getGalilD142(this)
            l = ~isempty(this.commGalilD142);
        end
        
        function l = getGalilVIS(this)
            l = ~isempty(this.commGalilVis);
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
        
        function l = get3GStoreRemotePowerSwitch1(this)
            l = ~isempty(this.comm3GStoreRemotePowerSwitch1);
        end
        
        function l = get3GStoreRemotePowerSwitch2(this)
            l = ~isempty(this.comm3GStoreRemotePowerSwitch2);
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
        
        function l = getMightex(this)
            l = ~isempty(this.commMightex1) && ~isempty(this.commMightex2);
        end
        
        function l = getBL1201CorbaProxy(this)
            l = ~isempty(this.commBL1201CorbaProxy);
        end
        
        function l = getDctCorbaProxy(this)
            l = ~isempty(this.commDctCorbaProxy);
        end
        
        function l = getMFDriftMonitor(this)
            l = ~isempty(this.commMFDriftMonitor);
        end
        
        function l = getNPointLC400M142(this)
            l = ~isempty(this.commNPointLC400M142);
            
        end
        
        function l = getNPointLC400MA(this)
            l = ~isempty(this.commNPointLC400MA);
        end
        
        function initAndConnectSmarActMcsM141(this)
                        
            if this.getSmarActMcsM141()
                return
            end
            
            if strcmp(questdlg('This will re-initialize M141 and set to 0 (out). Proceed with reset?', ...
                'M141 Reset Warning', ...
                'Yes','No','No'), 'No')
                return
            end
            
            try
                this.initAndConnectMet5Instruments();
                this.commSmarActMcsM141 = this.jMet5Instruments.getM141Stage();
                
                % 3/13 (RHM): for now let's reset stage and reinitialize, but
                % eventually let's pull this out to somewhere in the ui
                this.commSmarActMcsM141.reset();
                this.commSmarActMcsM141.initializeAxes().get();
                
                this.commSmarActMcsM141.moveAxisAbsolute(0, 0);
            catch mE
                
                cMsg = sprintf('initAndConnectSmarActMcsM141() %s', mE.message);
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                this.commSmarActMcsM141 = [];
                return
            end
            
            this.uiApp.uiM141.connectSmarActMcs(this.commSmarActMcsM141);
            
        end
        
        
        function destroyAndDisconnectSmarActMcsM141(this)
            
            if ~this.getSmarActMcsM141()
                return
            end
            
            this.uiApp.uiM141.disconnectSmarActMcs();
            
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
                cMsg = sprintf('initAndConnectSmarActRotary %s', mE.message);
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
            
            this.uiApp.uiFocusSensor.connectSmarActRotary(this.commSmarActRotary);

            
        end
        
        function destroyAndDisconnectSmarActRotary(this)
            if ~this.getSmarActRotary()
                return
            end
            
            this.uiApp.uiFocusSensor.disconnectSmarActRotary()
                        
        end
        
        % Called as GSLC callback in lsiControl UI connect
        function initAndConnectSmarActMcsGoni(this)
            
            
            if this.getSmarActMcsGoni()
                return
            end
            
            try
                this.initAndConnectMet5Instruments();
                this.commSmarActMcsGoni = this.jMet5Instruments.getLsiGoniometer();
            catch mE
                this.commSmarActMcsGoni = [];
                cMsg = sprintf('initAndConnectSmarActMcsGoni() %s', mE.message);
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                
                return
            end
            
             % Initializes and enables goni, setting devices via the
            % coupled axis API.
            this.uiApp.uiLSIControl.setGoniDeviceAndEnable(this.commSmarActMcsGoni);
        end
        
        function destroyAndDisconnectSmarActMcsGoni(this)
            if ~this.getSmarActMcsGoni()
                return
            end
            this.uiApp.uiLSIControl.disconnectGoni();
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
                cMsg = sprintf('initAndConnectSmarSmarPod() %s', mE.message);
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
            
            % Initializes and enables hexapod, setting devices via the
            % coupled axis API.
            this.uiApp.uiLSIControl.setHexapodDeviceAndEnable(this.commSmarActSmarPod);
            this.uiApp.uiDriftMonitor.setHexapodDeviceAndEnable(this.commSmarActSmarPod);
        end
        
       
        
        function destroyAndDisconnectSmarActSmarPod(this)
            if ~this.getSmarActSmarPod()
                return
            end
            % Disconnect the UIs for Hexapod, and disconnect the stage
            % itself too
            this.uiApp.uiLSIControl.disconnectHexapod();
            this.commSmarActSmarPod = [];
            
        end
        
        function initAndConnectPIMTECamera(this)
            if this.getPIMTECamera()
                return;
            end
            
            try
                if this.lUseVirtualPVCam
                    this.commPIMTECamera = lsicontrol.virtualDevice.virtualPVCam(); % <----- switch to CWCork camera when ready
                else
                    this.initAndConnectMet5Instruments();
                    % Test this camera directly by SSH into met5-pixis:
                    % cxrodev@met5-pixis:~/Development/met5/device/LsiCamera/corba/java-idl/test/LsiCameraTest
                    % run: java -jar store/PixisTest-0.1b.jar
                    this.commPIMTECamera = this.jMet5Instruments.getLsiCamera(); % Proper PVCam handle
                end
            catch mE
                this.commPIMTECamera = [];
                cMsg = sprintf('initAndConnectPIMTECamera() %s', mE.message);
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
            
            % Initializes and enables camera
            this.uiApp.uiLSIControl.setCameraDeviceAndEnable(this.commPIMTECamera);
        end
        
        function destroyAndDisconnectPIMTECamera(this)
            this.uiApp.uiLSIControl.disconnectCamera();
            this.commPIMTECamera = [];
        end
        
        
        function initAndConnectDataTranslationMeasurPoint(this)
            
            
            import bl12014.device.GetNumberFromDataTranslationMeasurPoint
            
            return;
            
            if this.getDataTranslationMeasurPoint()
                return
            end
                        
            try
                this.commDataTranslationMeasurPoint = datatranslation.MeasurPoint(this.cTcpipDataTranslation);
                
                % Connect the instrument through TCP/IP
                this.commDataTranslationMeasurPoint.connect();

                % Enable readout on protected channels
                this.commDataTranslationMeasurPoint.enable();
                
            catch mE
                this.commDataTranslationMeasurPoint = [];
                cMsg = sprintf('initAndConnectDataTranslationMeasurPoint() %s', mE.message);
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                
               
                return
            end
            
            
            %{
            TC   sensor channels = 00 01 02 03 04 05 06 07
            RTD  sensor channels = 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
            Volt sensor channels = 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47
            %}
            
            this.uiApp.uiM141.connectDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint);
            this.uiApp.uiD141.connectDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint);
            this.uiApp.uiD142.connectDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint);
            this.uiApp.uiBeamline.connectDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint);
            this.uiApp.uiM143.connectDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint);
            this.uiApp.uiReticle.connectDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint);
            this.uiApp.uiWafer.connectDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint);
            this.uiApp.uiTempSensors.connectDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint);
            this.uiApp.uiTempSensors.connectDataTranslationMeasurPoint(this.commDataTranslationMeasurPoint);
            
        end
        
        
        function destroyAndDisconnectDataTranslationMeasurPoint(this)
            
            return;
            
            if ~this.getDataTranslationMeasurPoint()
                return
            end
            
            this.uiApp.uiBeamline.disconnectDataTranslationMeasurPoint();
            this.uiApp.uiM141.disconnectDataTranslationMeasurPoint();
            this.uiApp.uiD141.disconnectDataTranslationMeasurPoint();
            this.uiApp.uiD142.disconnectDataTranslationMeasurPoint();
            this.uiApp.uiM143.disconnectDataTranslationMeasurPoint();
            this.uiApp.uiReticle.disconnectDataTranslationMeasurPoint();
            this.uiApp.uiWafer.disconnectDataTranslationMeasurPoint();
            this.uiApp.uiTempSensors.disconnectDataTranslationMeasurPoint();
                        
            this.commDataTranslationMeasurPoint.delete();
            this.commDataTranslationMeasurPoint = [];
        end
        

        
        function connectCommDeltaTauPowerPmacToUiLsi(this, comm, ui)
            
            % CA returning because this is crashing my reticle and wafer UI
            
            
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
           
            % Set LSI reticle axis control
            ui.setReticleAxisDevice(deviceCoarseX, 1);
            ui.setReticleAxisDevice(deviceCoarseY, 2);
            ui.setReticleAxisDevice(deviceCoarseZ, 3);
            ui.setReticleAxisDevice(deviceCoarseTiltX, 4);
            ui.setReticleAxisDevice(deviceCoarseTiltY, 5);
            ui.setReticleAxisDevice(deviceFineX, 6);
            ui.setReticleAxisDevice(deviceFineY, 7);
        end
         function connectCommDeltaTauPowerPmacToDM(this, comm, ui)
            
            % CA returning because this is crashing my reticle and wafer UI
            
            
            import bl12014.device.GetSetNumberFromDeltaTauPowerPmac
            import bl12014.device.GetSetTextFromDeltaTauPowerPmac
            
            % Devices
            deviceCoarseZ = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_Z);
            deviceCoarseTiltX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TIP);
            deviceCoarseTiltY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TILT);

            % Set LSI reticle axis control
            ui.setWaferAxisDevice(deviceCoarseZ, 1);
            ui.setWaferAxisDevice(deviceCoarseTiltX, 2);
            ui.setWaferAxisDevice(deviceCoarseTiltY, 3);
            
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
                    % fprintf('connectCommDeltaTauPowerPmacToUiPowerPmacStatus %s\n', ui.ceceTypes{m}{n});
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
                cMsg = sprintf('initAndConnectDeltaTauPowerPmac %s', mE.message);
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
               
                return
            end
            
            this.uiApp.uiReticle.connectDeltaTauPowerPmac(this.commDeltaTauPowerPmac);
            this.uiApp.uiWafer.connectDeltaTauPowerPmac(this.commDeltaTauPowerPmac);
            this.uiApp.uiPowerPmacStatus.connectDeltaTauPowerPmac(this.commDeltaTauPowerPmac);
            
            % RYAN WILL REPLACE
            this.connectCommDeltaTauPowerPmacToUiLsi(this.commDeltaTauPowerPmac, this.uiApp.uiLSIControl);
            this.connectCommDeltaTauPowerPmacToDM(this.commDeltaTauPowerPmac, this.uiApp.uiDriftMonitor);
        end
        
        function disconnectCommDeltaTauPowerPmacFromUiLsi(this, ui)
            for k = 1:7
                ui.disconnectReticleAxisDevice(k);
            end
        end
        function disconnectCommDeltaTauPowerPmacFromUiDM(this, ui)
            for k = 1:3
                ui.disconnectWaferAxisDevice(k);
            end
        end

        
        function destroyAndDisconnectDeltaTauPowerPmac(this)

            if ~this.getDeltaTauPowerPmac()
                return
            end
                      
            this.uiApp.uiReticle.disconnectDeltaTauPowerPmac()
            this.uiApp.uiWafer.disconnectDeltaTauPowerPmac();
            this.uiApp.uiPowerPmacStatus.disconnectDeltaTauPowerPmac()
            
            % FIXME
            this.disconnectCommDeltaTauPowerPmacFromUiLsi(this.uiApp.uiLSIControl);
            this.disconnectCommDeltaTauPowerPmacFromUiDM(this.uiApp.uiDriftMonitor);
                                    
            this.commDeltaTauPowerPmac.delete();
            this.commDeltaTauPowerPmac = [];
            
        end
        
        
        function initAndConnectExitSlit(this)
            
            if this.getExitSlit()
                return
            end
            
            try
                % [this.commExitSlit, e] = bl12pico_attach();
                this.commExitSlit = bl12pico_slits;
                [e,estr] = this.commExitSlit.checkServer();
                if e
                    this.commExitSlit = [];
                    error('Problem attaching to pico server');
                    return;
                end
            catch mE
                this.commExitSlit = [];
                cMsg = sprintf('initAndConnectExitSlit() %s', mE.message);
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                
               
                return;
            end
                        
            this.uiApp.uiBeamline.connectExitSlit(this.commExitSlit);
                        
        end
        
        function destroyAndDisconnectExitSlit(this)
            
            if ~this.getExitSlit()
                return
            end
            
            
            this.uiApp.uiBeamline.disconnectExitSlit();
            
            % this.commExitSlit.delete();
            this.commExitSlit = [];
        end
        
        
        
        function initAndConnectKeithley6482Wafer(this)
            
            if this.getKeithley6482Wafer()
                return
            end
            
            try
                this.commKeithley6482Wafer = keithley.Keithley6482(...
                    'cTcpipHost', this.cTcpipKeithley6482Wafer, ...
                    'u16TcpipPort', 4001, ...
                    'cConnection', keithley.Keithley6482.cCONNECTION_TCPCLIENT ...
                );
            
                % this.commKeithley6482Wafer.connect()
                % this.commKeithley6482Wafer.identity()
            catch mE
                this.commKeithley6482Wafer = [];
                cMsg = sprintf('initAndConnectKeithley6482Wafer() %s', mE.message);
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
            this.uiApp.uiBeamline.connectKeithley6482(this.commKeithley6482Wafer);
            % this.uiApp.uiWafer.connectKeithley6482(this.commKeithley6482Wafer);
            this.uiApp.uiLSIControl.connectKeithley6482(this.commKeithley6482Wafer);
        end
        
        function destroyAndDisconnectKeithley6482Wafer(this)
            
            if ~this.getKeithley6482Wafer()
                return
            end
            
            
            this.uiApp.uiBeamline.disconnectKeithley6482();
            % this.uiApp.uiWafer.disconnectKeithley6482()
            this.uiApp.uiLSIControl.disconnectKeithley6482();
            
            this.commKeithley6482Wafer.delete();
            this.commKeithley6482Wafer = [];
        end
        
        
        function initAndConnect3GStoreRemotePowerSwitch1(this)
            
            
            if this.get3GStoreRemotePowerSwitch1()
                return
            end
               
            try
                this.comm3GStoreRemotePowerSwitch1 = threegstore.RemotePowerSwitch(...
                    'cHost', this.cTcpip3GStoreRemotePowerSwitch1 ...
                );
                
            catch mE
                this.comm3GStoreRemotePowerSwitch1 = [];
                cMsg = sprintf('initAndConnect3GStoreRemotePowerSwitch1() %s', mE.message);
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
                        
            this.uiApp.uiCameraLEDs.connect3GStoreRemotePowerSwitch1(this.comm3GStoreRemotePowerSwitch1);
            
                        
        end
        
        function initAndConnect3GStoreRemotePowerSwitch2(this)
            
            
            if this.get3GStoreRemotePowerSwitch2()
                return
            end
               
            try
                this.comm3GStoreRemotePowerSwitch2 = threegstore.RemotePowerSwitch(...
                    'cHost', this.cTcpip3GStoreRemotePowerSwitch2 ...
                );
                
            catch mE
                this.comm3GStoreRemotePowerSwitch2 = [];
                cMsg = sprintf('initAndConnect3GStoreRemotePowerSwitch2() %s', mE.message);
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
                        
            this.uiApp.uiCameraLEDs.connect3GStoreRemotePowerSwitch2(this.comm3GStoreRemotePowerSwitch2);
            
                        
        end
        
        function initAndConnectKeithley6482Reticle(this)
            
            
            if this.getKeithley6482Reticle()
                return
            end
               
            try
                this.commKeithley6482Reticle = keithley.Keithley6482(...
                    'cTcpipHost', this.cTcpipKeithley6482Reticle, ...
                    'u16TcpipPort', 4002, ...
                    'cConnection', keithley.Keithley6482.cCONNECTION_TCPCLIENT ...
                );
                
            catch mE
                this.commKeithley6482Reticle = [];
                cMsg = sprintf('initAndConnectKeithley6482Reticle() %s', mE.message);
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
                        
            this.uiApp.uiReticle.connectKeithley6482(this.commKeithley6482Reticle);
                        
        end
        
        function destroyAndDisconnect3GStoreRemotePowerSwitch1(this)
            if ~this.get3GStoreRemotePowerSwitch1()
                return
            end
            
            this.uiApp.uiCameraLEDs.disconnect3GStoreRemotePowerSwitch1()
            this.comm3GStoreRemotePowerSwitch1 = [];
        end
        
        function destroyAndDisconnect3GStoreRemotePowerSwitch2(this)
            if ~this.get3GStoreRemotePowerSwitch2()
                return
            end
            
            this.uiApp.uiCameraLEDs.disconnect3GStoreRemotePowerSwitch2()
            this.comm3GStoreRemotePowerSwitch2 = [];
        end
        
        
        
        function destroyAndDisconnectKeithley6482Reticle(this)
            
            if ~this.getKeithley6482Reticle()
                return
            end
                            
            this.uiApp.uiReticle.disconnectKeithley6482();
            
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
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
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
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
                return;
            end
           
            this.uiApp.uiBeamline.connectDctCorbaProxy(this.commDctCorbaProxy)
            
        end
        
        function destroyAndDisconnectDctCorbaProxy(this)
            
            if ~this.getDctCorbaProxy()
                return
            end
                        
            this.uiApp.uiBeamline.disconnectDctCorbaProxy()
                        
            this.commDctCorbaProxy = [];
        end
        
        
        function initAndConnectBL1201CorbaProxy(this)
            
            if this.getBL1201CorbaProxy()
                return
            end
            
            try
                this.commBL1201CorbaProxy = cxro.bl1201.beamline.BL1201CorbaProxy();
                % this.commBL1201CorbaProxy.serverStatus() 2018.02.10 not
                % working
            catch mE
                this.commBL1201CorbaProxy = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
                return;
            end
            
            this.uiApp.uiBeamline.connectBL1201CorbaProxy(this.commBL1201CorbaProxy);
                        
        end
        
        function destroyAndDisconnectBL1201CorbaProxy(this)
            
            if ~this.getBL1201CorbaProxy()
                return
            end
            
            this.uiApp.uiBeamline.disconnectBL1201CorbaProxy();
            
            % this.commBL1201CorbaProxy.delete();
            this.commBL1201CorbaProxy = [];
        end
        
        function initAndConnectNewFocusModel8742(this)
            

            if this.getNewFocusModel8742()
                return
            end
            
            try
                this.commNewFocusModel8742 = newfocus.Model8742( ...
                    'cTcpipHost', this.cTcpipNewFocus ...
                );
                this.commNewFocusModel8742.init();
                this.commNewFocusModel8742.connect();
            catch mE
                this.commNewFocusModel8742 = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
                return;
            end

            this.uiApp.uiM142.connectNewFocusModel8742(this.commNewFocusModel8742)
            
        end
        
        function destroyAndDisconnectNewFocusModel8742(this)
            

            if ~this.getNewFocusModel8742()
                return
            end
            
            this.uiApp.uiM142.disconnectNewFocusModel8742();
            
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
                this.msg(mE.msgtext, this.u8_MSG_TYPE_ERROR);
               
            end
            
            
            this.uiApp.uiD142.connectGalil(this.commGalilD142);
            this.uiApp.uiBeamline.connectGalil(this.commGalilD142);
            
        end
        
        function destroyAndDisconnectGalilD142(this)
            if ~this.getGalilD142()
                return
            end
            
            this.uiApp.uiD142.disconnectGalil()
            this.uiApp.uiBeamline.disconnectGalil();
            
            this.commGalilD142.disconnect();
            this.commGalilD142 = [];
            
        end
        
        function initAndConnectGalilM143(this)
            if this.getGalilM143()
                return
            end
            
            try
                this.initAndConnectMet5Instruments();
                this.commGalilM143 = this.jMet5Instruments.getM143Stage();
                this.commGalilM143.connect();
            catch mE
                this.commGalilM143 = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
            end
            
            this.uiApp.uiM143.connectGalil(this.commGalilM143);
            
            
        end
        
        function destroyAndDisconnectGalilM143(this)
            if ~this.getGalilM143()
                return
            end
            
            this.uiApp.uiM143.disconnectGalil()
            
            this.commGalilM143.disconnect();
            this.commGalilM143 = [];
            
        end
        
        
        function initAndConnectGalilVIS(this)
            if this.getGalilVIS()
                return
            end
            
            try
                this.initAndConnectMet5Instruments();
                this.commGalilVis = this.jMet5Instruments.getVisStage();
                this.commGalilVis.connect();
            catch mE
                this.commGalilVis = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
            end

            this.uiApp.uiVibrationIsolationSystem.connectGalil(this.commGalilVis)
            
        end
        
        function destroyAndDisconnectGalilVIS(this)
            if ~this.getGalilVIS()
                return
            end
            
            this.uiApp.uiVibrationIsolationSystem.disconnectGalil();
            
            this.commGalilVis.disconnect(); 
            this.commGalilVis = [];
            
        end
        
        function initAndConnectMicronixMmc103(this)
            
            
            if this.getMicronixMmc103()
                return
            end
            
            try
 

                this.commMicronixMmc103 = micronix.MMC103(...
                    'cConnection', micronix.MMC103.cCONNECTION_TCPCLIENT, ...
                    'cTcpipHost', this.cTcpipMicronix, ...
                    'u16TcpipPort', 4001 ...
                );
                
                
                this.commMicronixMmc103.init();
                this.commMicronixMmc103.connect();
                this.commMicronixMmc103.clearBytesAvailable()

                % Get Firmware Version
                cFirmware = this.commMicronixMmc103.getFirmwareVersion(uint8(1));
                cMsg = sprintf(...
                    'initAndConnectMicronixMmc103() firmware version: %s', ...
                    cFirmware ...
                );
                fprintf([cMsg, '\n'])
                this.msg(cMsg, this.u8_MSG_TYPE_INFO);
            
            catch mE
            
                this.commMicronixMmc103 = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
                return;
            end

            this.uiApp.uiM142.connectMicronixMmc103(this.commMicronixMmc103);
            
        end
        
        function destroyAndDisconnectMicronixMmc103(this)
            
            
            if ~this.getMicronixMmc103()
                return
            end
                                        
            this.uiApp.uiM142.disconnectMicronixMmc103();
            
            
            this.commMicronixMmc103.delete();
            this.commMicronixMmc103 = [];
            
        end
        
        function initAndConnectMFDriftMonitor(this)
            if this.getMFDriftMonitor()
                return
            end
            
            try
                this.initAndConnectMet5Instruments();
                this.commMFDriftMonitor = this.jMet5Instruments.getMfDriftMonitor();
                this.commMFDriftMonitor.connect();
         
            catch mE
                this.commMFDriftMonitor = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
               
                return;
            end
            
            
            
            % Here connect any UIs that use this
            
%             this.uiApp.uiMFDriftMonitor.setDevice(this.commMFDriftMonitor);
%             this.uiApp.uiMFDriftMonitor.turnOn();
            
        end
        
        function destroyAndDisconnectMFDriftMonitor(this)
            this.commMFDriftMonitor.disconnect();
            this.commMFDriftMonitor = [];
        end
        
        
        function initAndConnectNPointLC400MA(this)
            
            if this.getNPointLC400MA()
                return
            end
            
            try
                
                this.commNPointLC400MA = npoint.LC400(...
                    'cConnection', npoint.LC400.cCONNECTION_TCPCLIENT, ...
                    'cTcpipHost', this.cTcpipLc400MA, ...
                    'u16TcpipPort', 23 ...
                );
            
                this.commNPointLC400MA.init();
                this.commNPointLC400MA.connect();
         
            catch mE
                this.commNPointLC400MA = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
               
                return;
            end
            
            this.uiApp.uiScannerMA.connectNPointLC400(this.commNPointLC400MA);
            
        end
        
        function destroyAndDisconnectNPointLC400MA(this)
            
            if ~this.getNPointLC400MA()
                return
            end

            this.uiApp.uiScannerMA.disconnectNPointLC400();
            
            this.commNPointLC400MA.delete();
            this.commNPointLC400MA = [];
        end
        
        function initAndConnectNPointLC400M142(this)
            

            if this.getNPointLC400M142()
                return
            end
            
            try
                this.commNPointLC400M142 = npoint.LC400(...
                    'cConnection', npoint.LC400.cCONNECTION_TCPCLIENT, ...
                    'cTcpipHost', this.cTcpipLc400M142, ...
                    'u16TcpipPort', 23 ...
                );
                this.commNPointLC400M142.init();
                this.commNPointLC400M142.connect();
                
            catch mE
                this.commNPointLC400M142 = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
                                
                 
                return;
            end
            
            
            this.uiApp.uiScannerM142.connectNPointLC400(this.commNPointLC400M142);
            
            
            
        end
        
        function destroyAndDisconnectNPointLC400M142(this)
            
            if ~this.getNPointLC400M142()
                return
            end
            
            this.uiApp.uiScannerM142.disconnectNPointLC400();
            
            this.commNPointLC400M142.delete();
            this.commNPointLC400M142 = [];
        end
        
        
        function initAndConnectRigolDG1000Z(this)
            
            if this.getRigolDG1000Z()
                return
            end
            
            try 
                
                u16Port = 5555;
                this.commRigolDG1000Z = rigol.DG1000Z(...
                    'cHost', this.cTcpipRigolDG1000Z, ...
                    'u16Port', u16Port ...
                );
                this.commRigolDG1000Z.idn()
                this.uiApp.uiShutter.connectRigolDG1000Z(this.commRigolDG1000Z);
                                
            catch mE
                
                this.commRigolDG1000Z = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
                
            end
            
            
        end
        
        
        function destroyAndDisconnectRigolDG1000Z(this)
            
            this.uiApp.uiShutter.disconnectRigolDG1000Z();
            this.commRigolDG1000Z = [];
            
        end
        
        
        
        function initAndConnectMightex(this)
            
            if this.getMightex()
                return
            end
            
            try 
                this.commMightex1 = mightex.UniversalLedController(...
                    'u8DeviceIndex', 0 ...
                );
                this.commMightex1.init();
                this.uiApp.uiHeightSensorLEDs.connectMightex1(this.commMightex1);
                                
            catch mE
                
                this.commMightex1 = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
                
            end
            
            
            try 
                
                this.commMightex2 = mightex.UniversalLedController(...
                    'u8DeviceIndex', 1 ...
                );
                this.commMightex2.init();
                this.uiApp.uiHeightSensorLEDs.connectMightex2(this.commMightex2);
                
            catch mE
                
                this.commMightex2 = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
                
            end
            
            
            
        end
        
        
        function destroyAndDisconnectMightex(this)
            
            % Disconnect UI
            this.uiApp.uiHeightSensorLEDs.disconnectMightex1();
            this.uiApp.uiHeightSensorLEDs.disconnectMightex2();
            
            % this.commMightex1.disconnect();
            % this.commMightex2.disconnect();
            
            this.commMightex1 = [];
            this.commMightex2 = [];
            
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
            
            stNPointLC400M142 = struct( ...
                'cLabel',   'nPoint LC.403 (Field)', ...
                'fhOnClick',  @this.connectCommNPointLC400M142, ...
                'cTooltip',  'M142 Field Scan' ...
            );
            
            stNPointLC400MA = struct( ...
                'cLabel',  'nPoint LC.403 (Pupil)', ...
                'fhOnClick',  @this.connectCommNPointLC400MA, ...
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
                stNPointLC400M142, ...
                stNPointLC400MA, ...
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
        
            gslcCommMightex = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getMightex, ...
                'fhSetTrue', @this.initAndConnectMightex, ...
                'fhSetFalse', @this.destroyAndDisconnectMightex ...
            );
        
            gslcCommRigolDG1000Z = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getRigolDG1000Z, ...
                'fhSetTrue', @this.initAndConnectRigolDG1000Z, ...
                'fhSetFalse', @this.destroyAndDisconnectRigolDG1000Z ...
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
        
            gslcCommSmarActSmarPod = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getSmarActSmarPod, ...
                'fhSetTrue', @this.initAndConnectSmarActSmarPod, ...
                'fhSetFalse', @this.destroyAndDisconnectSmarActSmarPod ...
            );
        
            gslcCommPIMTECamera = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getPIMTECamera, ...
                'fhSetTrue', @this.initAndConnectPIMTECamera, ...
                'fhSetFalse', @this.destroyAndDisconnectPIMTECamera ...
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
        
            
            gslcCommNPointLC400M142 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getNPointLC400M142, ...
                'fhSetTrue', @this.initAndConnectNPointLC400M142, ...
                'fhSetFalse', @this.destroyAndDisconnectNPointLC400M142 ...
            );
        
            gslcCommNPointLC400MA = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getNPointLC400MA, ...
                'fhSetTrue', @this.initAndConnectNPointLC400MA, ...
                'fhSetFalse', @this.destroyAndDisconnectNPointLC400MA ...
            );
            
            
            gslcCommCxroHeightSensor = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getCxroHeightSensor, ...
                'fhSetTrue', @this.initAndConnectCxroHeightSensor, ...
                'fhSetFalse', @this.destroyAndDisconnectCxroHeightSensor ...
            );
        
            gslcComm3GStoreRemotePowerSwitch1 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.get3GStoreRemotePowerSwitch1 , ...
                'fhSetTrue', @this.initAndConnect3GStoreRemotePowerSwitch1 , ...
                'fhSetFalse', @this.destroyAndDisconnect3GStoreRemotePowerSwitch1 ...
            );
        
            gslcComm3GStoreRemotePowerSwitch2 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.get3GStoreRemotePowerSwitch2 , ...
                'fhSetTrue', @this.initAndConnect3GStoreRemotePowerSwitch2 , ...
                'fhSetFalse', @this.destroyAndDisconnect3GStoreRemotePowerSwitch2 ...
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
        
        
%             gslcCommMFDriftMonitor = bl12014.device.GetSetLogicalConnect(...
%                 'fhGet', @this.getMFDriftMonitor, ...
%                 'fhSetTrue', @this.initAndConnectMFDriftMonitor, ...
%                 'fhSetFalse', @this.destroyAndDisconnectMFDriftMonitor ...
%             );
%         

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
            
            % ScannerM142
            this.uiApp.uiScannerM142.uiCommNPointLC400.setDevice(gslcCommNPointLC400M142);
            this.uiApp.uiScannerM142.uiCommNPointLC400.turnOn();
            
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
            
            % ScannerMA
            this.uiApp.uiScannerMA.uiCommNPointLC400.setDevice(gslcCommNPointLC400MA);
            this.uiApp.uiScannerMA.uiCommNPointLC400.turnOn();
            
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
            % this.uiApp.uiWafer.uiCommCxroHeightSensor.setDevice(gslcCommCxroHeightSensor)
            this.uiApp.uiWafer.uiCommDeltaTauPowerPmac.turnOn()
            this.uiApp.uiWafer.uiCommDataTranslationMeasurPoint.turnOn()
            this.uiApp.uiWafer.uiCommKeithley6482.turnOn()
            % this.uiApp.uiWafer.uiCommCxroHeightSensor.turnOn()
            
            % Power PMAC Status
            this.uiApp.uiPowerPmacStatus.uiCommDeltaTauPowerPmac.setDevice(gslcCommDeltaTauPowerPmac)
            this.uiApp.uiPowerPmacStatus.uiCommDeltaTauPowerPmac.turnOn();
            
            
            %this.uiApp.uiPrescriptionTool.ui          
            %this.uiApp.uiScan.ui            
            
            % LSI
            
            try
                this.uiApp.uiLSIControl.uiCommSmarActSmarPod.setDevice(gslcCommSmarActSmarPod);
    %             this.uiApp.uiLSIControl.uiCommSmarActMcsGoni.setDevice(gslcCommSmarActMcsGoni);
                this.uiApp.uiLSIControl.uiCommSmarActSmarPod.turnOn();
    %             this.uiApp.uiLSIControl.uiCommSmarActMcsGoni.turnOn();
                this.uiApp.uiLSIControl.uiCommPIMTECamera.setDevice(gslcCommPIMTECamera);
                this.uiApp.uiLSIControl.uiCommPIMTECamera.turnOn();
                this.uiApp.uiLSIControl.uiCommDeltaTauPowerPmac.setDevice(gslcCommDeltaTauPowerPmac);
                this.uiApp.uiLSIControl.uiCommDeltaTauPowerPmac.turnOn();
                
                this.uiApp.uiLSIControl.uicommWaferDoseMonitor.setDevice(gslcCommKeithley6482Wafer);
                this.uiApp.uiLSIControl.uicommWaferDoseMonitor.turnOn();

            catch mE
                disp('App.m could not connect uiLSIControl');
            end
            
            % MF drift monitor
            this.uiApp.uiDriftMonitor.uicConnectHexapod.setDevice(gslcCommSmarActSmarPod);
            this.uiApp.uiDriftMonitor.uicConnectWafer.setDevice(gslcCommDeltaTauPowerPmac);
            this.uiApp.uiDriftMonitor.uicConnectHexapod.turnOn();
            this.uiApp.uiDriftMonitor.uicConnectWafer.turnOn();
        
            
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
            
            this.uiApp.uiHeightSensorLEDs.uiCommMightex.setDevice(gslcCommMightex);
            this.uiApp.uiHeightSensorLEDs.uiCommMightex.turnOn();
            
            this.uiApp.uiShutter.uiCommRigol.setDevice(gslcCommRigolDG1000Z);
            this.uiApp.uiShutter.uiCommRigol.turnOn();
            
            % Camera LEDs
            this.uiApp.uiCameraLEDs.uiComm3GStoreRemotePowerSwitch1.setDevice(gslcComm3GStoreRemotePowerSwitch1);
            this.uiApp.uiCameraLEDs.uiComm3GStoreRemotePowerSwitch1.turnOn();
            this.uiApp.uiCameraLEDs.uiComm3GStoreRemotePowerSwitch2.setDevice(gslcComm3GStoreRemotePowerSwitch2);
            this.uiApp.uiCameraLEDs.uiComm3GStoreRemotePowerSwitch2.turnOn();
        end
        
        
        function init(this)
            
            this.hardware = bl12014.Hardware();
            
            this.uiApp = bl12014.ui.App(...
                'dWidthButtonButtonList', this.dWidthButton, ...
                'hHardware', this.hardware ...
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