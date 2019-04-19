classdef App < mic.Base
        
    properties (Constant)
        
        
        
        dWidthButton = 210
        
        % Branchline Subnet
        cTcpipSmarActM141 = '192.168.10.20'
        cTcpipMicronix = '192.168.10.21'
        cTcpipLc400M142 = '192.168.10.22'
        cTcpipNewFocus = '192.168.10.23'
        
        
        % Endstation 1 Subnet
        cTcpipLc400MA = '192.168.20.20'
        cTcpipAcromag = '192.168.20.22'
        cTcpipDeltaTau = '192.168.20.23'
        cTcpipSmarActLSIGoni = '192.168.20.24'
        cTcpipSmarActLSIHexapod = '192.168.20.25'
        cTcpipSmarActFocusMonitor = '192.168.20.26'
        cTcpipKeithley6482Wafer = '192.168.20.28'
        cTcpipKeithley6482Reticle = '192.168.20.28'
        cTcpipNewFocusMA = '192.168.20.31'
        
        cTcpipRigolDG1000Z = '192.168.20.35' % Temporary
        cTcpip3GStoreRemotePowerSwitch1 = '192.168.10.30'; % Beamline
        cTcpip3GStoreRemotePowerSwitch2 = '192.168.20.30'; % End station
        

        % Video Subnet
        
        % Endstation 2 Subnet
        
        
    end
    
	properties
        
        % {bl12015.Logger 1x1}
        logger
        
        % {bl12014.Hardware 1x1}
        hardware
        
        % {mic.Clock 1x1}
        clock
        
        % {cxro.met5.Instruments 1x1}
        jMet5Instruments
        
        % {rigol.DG1000Z 1x1}
        commRigolDG1000Z
        
        
        
        
        % {cxro.common.device.motion.Stage 1x1}
        commSmarActMcsGoni
        
        % {cxro.common.device.motion.Stage 1x1}
        commSmarActSmarPod
        
        % Temporarily:{lsicontrol.virtualDevice.virtualPVCam}
        commPIMTECamera
        lUseVirtualPVCam = false % <--- helpful for debugging PI-MTE cam
        
        commSmarActRotary
        
        
       
                
        % {cxro.bl1201.dct.DctCorbaProxy 1x1}
        commDctCorbaProxy
        
        % {newFocus.NewFocusModel8742 1x1} 
        % May cheat and use DLL directly with {mic.interface.device.*}
        % M142 + M142R common tiltX (pitch)
        % M142 independent tiltY  (roll)
        % M142R independent tiltY (roll)
        commNewFocusModel8742
        
        
        % {newFocus.NewFocusModel8742 1x1} 
        % MA diagnostic YAG
        % Subframe wheel
        commNewFocusModel8742MA
        
        
        % {micronix.Mmc103 1x1}
        % M142R tiltZ (clocking)
        % M142 + M142R common x
        commMicronixMmc103
        
        
        
        
        

        
        % {threegstore.RemotePowerSwitch}
        % github.com/cnanders/matlab-3gstore-remote-power-switch
        comm3GStoreRemotePowerSwitch1
        comm3GStoreRemotePowerSwitch2
        
        
        uiApp
        
        
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
                
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


            this.init();
            
            
        end
        
                
        function build(this)
            this.uiApp.build();
        end
        
        %% Destructor
        
        function delete(this)
           
            this.msg('bl12014.App.delete', this.u8_MSG_TYPE_INFO);
            this.destroyAndDisconnectAll();
            
            
            this.logger.delete();
            this.uiApp.delete();
            
            % uiApp uses hardware so delete hardware after
            this.hardware.delete();
            
            % hardware uses clock so delete clock after
            % uiApp uses clock
            % this.clock = [];
            
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
            
            this.msg('destroyAndDisconnectAll', this.u8_MSG_TYPE_INFO);
                        
            this.destroyAndDisconnectMicronixMmc103();
            this.destroyAndDisconnectNewFocusModel8742();
            this.destroyAndDisconnectNewFocusModel8742MA();
            this.destroyAndDisconnectSmarActMcsGoni();
            this.destroyAndDisconnectSmarActSmarPod();
            this.destroyAndDisconnectSmarActRotary();
            this.destroyAndDisconnect3GStoreRemotePowerSwitch1();
            this.destroyAndDisconnect3GStoreRemotePowerSwitch2();
            this.destroyAndDisconnectMet5Instruments();

        end
        
        % Getters return logical if the COMM class exists.  Used by
        % GetSetLogicalConnect instances
        
        
        
        
        function l = getNewFocusModel8742(this)
            l = ~isempty(this.commNewFocusModel8742);
        end
        
        function l = getNewFocusModel8742MA(this)
            l = ~isempty(this.commNewFocusModel8742MA);
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
        
        function l = get3GStoreRemotePowerSwitch1(this)
            l = ~isempty(this.comm3GStoreRemotePowerSwitch1);
        end
        
        function l = get3GStoreRemotePowerSwitch2(this)
            l = ~isempty(this.comm3GStoreRemotePowerSwitch2);
        end
                

        
        
        
        function l = getDctCorbaProxy(this)
            l = ~isempty(this.commDctCorbaProxy);
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

            this.uiApp.uiBeamline.uiM142.connectNewFocusModel8742(this.commNewFocusModel8742)
            
        end
        
        
        function initAndConnectNewFocusModel8742MA(this)
            

            if this.getNewFocusModel8742MA()
                return
            end
            
            try
                this.commNewFocusModel8742MA = newfocus.Model8742( ...
                    'cTcpipHost', this.cTcpipNewFocusMA ...
                );
                this.commNewFocusModel8742MA.init();
                this.commNewFocusModel8742MA.connect();
            catch mE
                this.commNewFocusModel8742MA = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
                return;
            end

            this.uiApp.uiMA.uiDiagnostics.connectNewFocusModel8742(this.commNewFocusModel8742MA)
            
        end
        
        function destroyAndDisconnectNewFocusModel8742(this)
            

            if ~this.getNewFocusModel8742()
                return
            end
            
            this.uiApp.uiBeamline.uiM142.disconnectNewFocusModel8742();
            
            this.commNewFocusModel8742.delete();
            this.commNewFocusModel8742 = [];
                            
        end
        
        function destroyAndDisconnectNewFocusModel8742MA(this)
            

            if ~this.getNewFocusModel8742MA()
                return
            end
            
            this.uiApp.uiMA.uiDiagnostics.disconnectNewFocusModel8742();
            
            this.commNewFocusModel8742MA.delete();
            this.commNewFocusModel8742MA = [];
                            
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

            this.uiApp.uiBeamline.uiM142.connectMicronixMmc103(this.commMicronixMmc103);
            
        end
        
        function destroyAndDisconnectMicronixMmc103(this)
            
            
            if ~this.getMicronixMmc103()
                return
            end
                                        
            this.uiApp.uiBeamline.uiM142.disconnectMicronixMmc103();
            
            
            this.commMicronixMmc103.delete();
            this.commMicronixMmc103 = [];
            
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
                % this.uiApp.uiBeamline.uiShutter.connectRigolDG1000Z(this.commRigolDG1000Z); % 
                % this.uiApp.uiWafer.uiShutter.connectRigolDG1000Z(this.commRigolDG1000Z); % 
                % this.uiApp.uiReticle.uiShutter.connectRigolDG1000Z(this.commRigolDG1000Z); % 
                % this.uiApp.uiScan.uiShutter.connectRigolDG1000Z(this.commRigolDG1000Z);
                % this.uiApp.uiTuneFluxDensity.uiShutter.connectRigolDG1000Z(this.commRigolDG1000Z);
            catch mE
                
                this.commRigolDG1000Z = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
                
            end
            
            
        end
        
        
        function destroyAndDisconnectRigolDG1000Z(this)
            
            % this.uiApp.uiBeamline.uiShutter.disconnectRigolDG1000Z();
            % this.uiApp.uiWafer.uiShutter.disconnectRigolDG1000Z();
            % this.uiApp.uiReticle.uiShutter.disconnectRigolDG1000Z();
            % this.uiApp.uiScan.uiShutter.disconnectRigolDG1000Z();
            % this.uiApp.uiTuneFluxDensity.uiShutter.disconnectRigolDG1000Z();
            this.commRigolDG1000Z = [];
            
        end
        
        
        
       
            
        
        function initGetSetLogicalConnects(this)
            
            

        
            %{
            gslcCommRigolDG1000Z = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getRigolDG1000Z, ...
                'fhSetTrue', @this.initAndConnectRigolDG1000Z, ...
                'fhSetFalse', @this.destroyAndDisconnectRigolDG1000Z ...
            );
            %}
        
            gslcCommNewFocusModel8742 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getNewFocusModel8742, ...
                'fhSetTrue', @this.initAndConnectNewFocusModel8742, ...
                'fhSetFalse', @this.destroyAndDisconnectNewFocusModel8742 ...
            );
        
        
            gslcCommNewFocusModel8742MA = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getNewFocusModel8742MA, ...
                'fhSetTrue', @this.initAndConnectNewFocusModel8742MA, ...
                'fhSetFalse', @this.destroyAndDisconnectNewFocusModel8742MA ...
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
        
            
        
            
        
        
            gslcCommDctCorbaProxy = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getDctCorbaProxy, ...
                'fhSetTrue', @this.initAndConnectDctCorbaProxy, ...
                'fhSetFalse', @this.destroyAndDisconnectDctCorbaProxy ...
            );
        
            
        
            gslcCommMicronixMmc103 = bl12014.device.GetSetLogicalConnect(...
                'fhGet', @this.getMicronixMmc103, ...
                'fhSetTrue', @this.initAndConnectMicronixMmc103, ...
                'fhSetFalse', @this.destroyAndDisconnectMicronixMmc103 ...
            );
        
        
           

            
            % Beamline
            % this.uiApp.uiBeamline.uiCommDctCorbaProxy.setDevice(gslcCommDctCorbaProxy)
            % this.uiApp.uiBeamline.uiCommDctCorbaProxy.turnOn()
            

                        
           
            
            % M142
            this.uiApp.uiBeamline.uiM142.uiCommMicronixMmc103.setDevice(gslcCommMicronixMmc103);
            this.uiApp.uiBeamline.uiM142.uiCommMicronixMmc103.turnOn();
            this.uiApp.uiBeamline.uiM142.uiCommNewFocusModel8742.setDevice(gslcCommNewFocusModel8742);
            this.uiApp.uiBeamline.uiM142.uiCommNewFocusModel8742.turnOn();
            
            
            
            
            
            
            % MA Diagnostics
            this.uiApp.uiMA.uiDiagnostics.uiCommNewFocusModel8742.setDevice(gslcCommNewFocusModel8742MA);
            this.uiApp.uiMA.uiDiagnostics.uiCommNewFocusModel8742.turnOn();
            
            
            
            
           
           
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
                
              

            catch mE
                disp('App.m could not connect uiLSIControl');
            end
            
            % MF drift monitor
            this.uiApp.uiDriftMonitor.uicConnectHexapod.setDevice(gslcCommSmarActSmarPod);
            this.uiApp.uiDriftMonitor.uicConnectHexapod.turnOn();
            

            
            
            % Focus Sensor
            this.uiApp.uiFocusSensor.uiCommSmarActRotary.setDevice(gslcCommSmarActRotary);
            this.uiApp.uiFocusSensor.uiCommSmarActRotary.turnOn();
            


            
            %{
            this.uiApp.uiBeamline.uiShutter.uiCommRigol.setDevice(gslcCommRigolDG1000Z);
            this.uiApp.uiBeamline.uiShutter.uiCommRigol.turnOn();
            
            this.uiApp.uiWafer.uiShutter.uiCommRigol.setDevice(gslcCommRigolDG1000Z);
            this.uiApp.uiWafer.uiShutter.uiCommRigol.turnOn();
            
            this.uiApp.uiReticle.uiShutter.uiCommRigol.setDevice(gslcCommRigolDG1000Z);
            this.uiApp.uiReticle.uiShutter.uiCommRigol.turnOn();
            
            this.uiApp.uiScan.uiShutter.uiCommRigol.setDevice(gslcCommRigolDG1000Z);
            this.uiApp.uiScan.uiShutter.uiCommRigol.turnOn();
            
            this.uiApp.uiTuneFluxDensity.uiShutter.uiCommRigol.setDevice(gslcCommRigolDG1000Z);
            this.uiApp.uiTuneFluxDensity.uiShutter.uiCommRigol.turnOn();
            %}
            
            % Camera LEDs
            %{
            this.uiApp.uiCameraLEDs.uiComm3GStoreRemotePowerSwitch1.setDevice(gslcComm3GStoreRemotePowerSwitch1);
            this.uiApp.uiCameraLEDs.uiComm3GStoreRemotePowerSwitch1.turnOn();
            %}
            
            this.uiApp.uiCameraLEDs.uiComm3GStoreRemotePowerSwitch2.setDevice(gslcComm3GStoreRemotePowerSwitch2);
            this.uiApp.uiCameraLEDs.uiComm3GStoreRemotePowerSwitch2.turnOn();
        end
        
        
        
        function init(this)
            
            this.clock = mic.Clock('bl12014-control');
            
            this.hardware = bl12014.Hardware();
            
            % Set clock, required for drift monitor middle layer
            this.hardware.setClock(this.clock); 
            
            cDirThis = fileparts(mfilename('fullpath'));
            
            if ~contains(cDirThis, 'cnanderson') && ...
               ~contains(cDirThis, 'ryanmiyakawa')
           
                this.hardware.connectDataTranslation(); % force real hardware
                this.hardware.connectMfDriftMonitor(); % force real hardware
               
                this.logger = bl12014.Logger(...
                    'hardware', this.hardware, ...
                    'clock', this.clock ...
                );
        
            end
            
            
            this.uiApp = bl12014.ui.App(...
                'dWidthButtonButtonList', this.dWidthButton, ...
                'clock', this.clock, ...
                'hardware', this.hardware ...
            ); 
                
            this.initGetSetLogicalConnects();
            

        end
        
        function onCloseRequestFcn(this, src, evt)
            this.msg('closeRequestFcn()');
            % purge;
            delete(this.hFigure);
            % this.saveState();
        end
         
                

    end % private
    
    
end