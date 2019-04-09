% MET5 hardware class.  Contains getters for all hardware handles.
%
% Every hardware communication requires the addition of four things:
%
% 1) Corresponding "comm" property (e.g., commMfDriftMonitorMiddleware) represeting
% the stored handle to the hardware component
%
% 2) Getter function: should return the comm if it is already initialized,
% otherwise should initialize it and then return it
%
% 3) Delete function: disconnects device and unsets the comm property.
%
% 4) Modify the path variable structure to ensure your getter is properly
% scoped.
%

%%%

classdef Hardware < mic.Base
        
    properties (Constant)
        
        % Branchline Subnet
        cTcpipSmarActM141           = '192.168.10.20'
        cTcpipMicronix              = '192.168.10.21'
        cTcpipLc400M142             = '192.168.10.22'
        cTcpipNewFocus              = '192.168.10.23'
        cTcpipGalilD142             = '192.168.10.24'
        cTcpipGalilM143             = '192.168.10.25'
        cTcpipWago                  = '192.168.10.26'
        
        % Endstation 1 Subnet
        cTcpipLc400MA               = '192.168.20.20'
        % cTcpipGalilVibrationIsolationSystem = '192.168.20.21'
        cTcpipAcromag               = '192.168.20.22'
        cTcpipDeltaTau              = '192.168.20.23'
        cTcpipSmarActLSIGoni        = '192.168.20.24'
        cTcpipSmarActLSIHexapod     = '192.168.20.25'
        cTcpipSmarActFocusMonitor   = '192.168.20.26'
        cTcpipDataTranslation       = '192.168.20.27'
        cTcpipKeithley6482Wafer     = '192.168.20.28'
        cTcpipKeithley6482Reticle   = '192.168.20.28'
        
        cTcpipRigolDG1000Z = '192.168.20.35'
        
        cTcpipWebSwitchVis = '192.168.20.32';
        cTcpipWebSwitchBeamline = '192.168.10.30';
        
        
    end
    
	properties
        clock
        
        % {cxro.met5.Instruments 1x1}
        jMet5Instruments
        cDirMet5InstrumentsConfig = ...
            fullfile(fileparts(mfilename('fullpath')), '..', '..', 'vendor', 'cwcork');

        
        % {cxro.common.device.motion.Stage 1x1}
        commLSIHexapod
        
        % Temporarily:{lsicontrol.virtualDevice.virtualPVCam}
        commPIMTECamera
        
        % {keithley.Keithley6482 1x1}
        commKeithley6482Wafer
        commKeithley6482WaferVirtual
        
        commKeithley6482Reticle
        commKeithley6482ReticleVirtual
        
        commDataTranslation
        commDataTranslationVirtual
        
        % {deltaTau.PowerPmac 1x1}
        commDeltaTauPowerPmac
        commDeltaTauPowerPmacVirtual
        
        % {MFDriftMonitor}
        commMfDriftMonitorMiddleware
        commMfDriftMonitorMiddlewareVirtual
        
        commRigolDG1000Z
        commRigolDG1000ZVirtual
        lIsConnectedRigolDG1000Z = false
        
        
        commMfDriftMonitor
        commMfDriftMonitorVirtual
        
        commWebSwitchBeamline
        commWebSwitchBeamlineVirtual
        
        commWebSwitchEndstation
        commWebSwitchEndstationVirtual
        
        commWebSwitchVis
        commWebSwitchVisVirtual
        
        commBL1201CorbaProxy
        commBL1201CorbaProxyVirtual
        
        commSmarActM141
        commSmarActM141Virtual
        
        commWagoD141
        commWagoD141Virtual
        
        commExitSlit
        commExitSlitVirtual
        
        commGalilD142
        commGalilD142Virtual
        
        commGalilM143
        commGalilM143Virtual
        
        commGalilVis
        commGalilVisVirtual
                
    end
    

    
    properties (Access = private)
        
        
    end
    
        
    

    
    methods
        
        % Constructor
        function this = Hardware()
            this.init();
        end
    
        % Destructor
        function delete(this)
            % Put all of the disconnect functions here
            this.disconnectDeltaTauPowerPmac();
        end
        
        % Setters
        function setClock(this, clock)
            this.clock = clock;
        end
        
        
        
        %% WebSwitch (Beamline)
        function l = getIsConnectedWebSwitchBeamline(this)
           
            if isa(this.commWebSwitchBeamline, 'controlbyweb.WebSwitch')
                l = true;
                return;
                
            end

            l = false;
        end
        
        function connectWebSwitchBeamline(this)
            
            try
                this.commWebSwitchBeamline = controlbyweb.WebSwitch(...
                    'cHost', this.cTcpipWebSwitchBeamline ...
                );
           catch mE
                error(getReport(mE));
           end
        end
        
        function disconnectWebSwitchBeamline(this)
            this.commWebSwitchBeamline = [];
        end
                
        function comm = getWebSwitchBeamline(this)
            if this.getIsConnectedWebSwitchBeamline()
                comm = this.commWebSwitchBeamline;
            else
                comm = this.commWebSwitchBeamlineVirtual;
            end            
        end
        
        
        %% WebSwitch (Endstation)
        function l = getIsConnectedWebSwitchEndstation(this)
           
            if isa(this.commWebSwitchEndstation, 'controlbyweb.WebSwitch')
                l = true;
                return;
                
            end

            l = false;
        end
        
        function connectWebSwitchEndstation(this)
            
            try
                this.commWebSwitchEndstation = controlbyweb.WebSwitch(...
                    'cHost', this.cTcpipWebSwitchEndstation ...
                );
           catch mE
                error(getReport(mE));
           end
        end
        
        function disconnectWebSwitchEndstation(this)
            this.commWebSwitchEndstation = [];
        end
                
        function comm = getWebSwitchEndstation(this)
            if this.getIsConnectedWebSwitchEndstation()
                comm = this.commWebSwitchEndstation;
            else
                comm = this.commWebSwitchEndstationVirtual;
            end            
        end
        
        %% WebSwitch (VIS)
        function l = getIsConnectedWebSwitchVis(this)
           
            if isa(this.commWebSwitchVis, 'controlbyweb.WebSwitch')
                l = true;
                return;
                
            end

            l = false;
        end
        
        function connectWebSwitchVis(this)
            
            try
                this.commWebSwitchVis = controlbyweb.WebSwitch(...
                    'cHost', this.cTcpipWebSwitchVis ...
                );
           catch mE
                error(getReport(mE));
           end
        end
        
        function disconnectWebSwitchVis(this)
            this.commWebSwitchVis = [];
        end
                
        function comm = getWebSwitchVis(this)
            if this.getIsConnectedWebSwitchVis()
                comm = this.commWebSwitchVis;
            else
                comm = this.commWebSwitchVisVirtual;
            end            
        end
        
        %% BL1201 Cobra Proxy
        
        
        
        
        function l = getIsConnectedBL1201CorbaProxy(this)
           
            if isa(this.commBL1201CorbaProxy, 'cxro.bl1201.beamline.BL1201CorbaProxy')
                l = true;
                return;
            end

            l = false;
        end
        
        function connectBL1201CorbaProxy(this)
            
            try
                this.commBL1201CorbaProxy = cxro.bl1201.beamline.BL1201CorbaProxy();
           catch mE
                error(getReport(mE));
           end
        end
        
        function disconnectBL1201CorbaProxy(this)
            this.commBL1201CorbaProxy = [];
        end
                
        function comm = getBL1201CorbaProxy(this)
            if this.getIsConnectedBL1201CorbaProxy()
                comm = this.commBL1201CorbaProxy;
            else
                comm = this.commBL1201CorbaProxyVirtual;
            end            
        end
        
        
        %% MF Drift Monitor (different than MfDriftMonitor Middleware)
        
        function l = getIsConnectedMfDriftMonitor(this)
           
            if isa(this.commMfDriftMonitor, 'cxro.met5.device.mfdriftmonitor.MfDriftMonitorCorbaProxy')
                l = true;
            else
                l = false;
            end

        end
        
        function connectMfDriftMonitor(this)
            if isempty(this.jMet5Instruments)
                this.getjMet5Instruments();
           end

           try
                this.commMfDriftMonitor = this.jMet5Instruments.getMfDriftMonitor();
                this.commMfDriftMonitor.connect();
           catch mE
                error(getReport(mE));
           end
        end
        
        function disconnectMfDriftMonitor(this)
            this.commMfDriftMonitor = [];
        end
         
        function comm = getMfDriftMonitor(this)
            if this.getIsConnectedMfDriftMonitor()
                comm = this.commMfDriftMonitor;
                return;
            end
            comm = this.commMfDriftMonitorVirtual;
        end
        
        
        %% Rigol DG1000Z
        
        function l = getIsConnectedRigolDG1000Z(this)
           
            if isa(this.commRigolDG1000Z, 'rigol.DG1000Z')
                l = true;
                return;
            end
            l = false;
        end
        
        function connectRigolDG1000Z(this)
            try
                u16Port = 5555;
                this.commRigolDG1000Z = rigol.DG1000Z(...
                    'cHost', this.cTcpipRigolDG1000Z, ...
                    'u16Port', u16Port ...
                );
                this.commRigolDG1000Z.idn()                       
           catch mE
                error(getReport(mE));
           end
        end
        
        function disconnectRigolDG1000Z(this)
            this.commRigolDG1000Z = [];
        end
                        
        function comm = getRigolDG1000Z(this)
            if this.getIsConnectedRigolDG1000Z()
                comm = this.commRigolDG1000Z;
            else
                comm = this.commRigolDG1000ZVirtual;
            end            
        end
        
        
        %% SmarAct M141
        
        function l = getIsConnectedSmarActM141(this)
           
            if isa(this.commSmarActM141, 'cxro.common.device.motion.Stage')
                l = true;
                return;
            end
            l = false;
        end
        
        function connectSmarActM141(this)
            
            this.getjMet5Instruments();
             try
                
                this.commSmarActM141 = this.jMet5Instruments.getM141Stage();
                this.commSmarActM141.reset();
                this.commSmarActM141.initializeAxes().get();
                this.commSmarActM141.moveAxisAbsolute(0, 0);

%{
                % 3/13 (RHM): for now let's reset stage and reinitialize, but
                % eventually let's pull this out to somewhere in the ui
                
                
                %}
                
            catch mE
                
                error(getReport(mE));
            end
        end
        
        function disconnectSmarActM141(this)
             if this.getIsConnectedSmarActM141()
                 this.commSmarActM141.disconnect();
             end
            this.commSmarActM141 = [];
        end
                        
        function comm = getSmarActM141(this)
            if this.getIsConnectedSmarActM141()
                comm = this.commSmarActM141;
            else
                comm = this.commSmarActM141Virtual;
            end            
        end
        
        
        
        
        %% Getters
        function comm = getjMet5Instruments(this)
            if isempty(this.jMet5Instruments)
                this.jMet5Instruments = cxro.met5.Instruments(this.cDirMet5InstrumentsConfig);
            end
            comm = this.jMet5Instruments;
        end
        
        
        %% Data Translation Measur Point
        
        function l = getIsConnectedDataTranslation(this)
            if isa(this.commDataTranslation, 'datatranslation.MeasurPoint')
                l = true;
            else
                l = false;
            end
        end
        
        function comm = getDataTranslation(this)
            
            if this.getIsConnectedDataTranslation()
                comm = this.commDataTranslation;
            else
                comm = this.commDataTranslationVirtual;
            end
        end
        
        function  connectDataTranslation(this)
            
            this.commDataTranslation = datatranslation.MeasurPoint(this.cTcpipDataTranslation);
            this.commDataTranslation.connect();
            this.commDataTranslation.idn()
            this.commDataTranslation.enable();
                
        end
        
        function disconnectDataTranslation(this)
            this.commDataTranslation = [];
        end
        
        
        %% Power Pmac
        
        function connectDeltaTauPowerPmac(this)
            
            if isa(this.commDeltaTauPowerPmac, 'deltatau.PowerPmac')
                return
            end
            
            this.commDeltaTauPowerPmac = deltatau.PowerPmac(...
                'cHostname', this.cTcpipDeltaTau ...
            );
            if ~this.commDeltaTauPowerPmac.init();
                this.disconnectDeltaTauPowerPmac();
            end
            
        end
        
        function disconnectDeltaTauPowerPmac(this)
            if isa(this.commDeltaTauPowerPmac, 'deltatau.PowerPmac')
                % this.commDeltaTauPowerPmac.disconnect();
                this.commDeltaTauPowerPmac = []; % calls delete() which calls disconnect
            end
        end
        
        function l = getIsConnectedDeltaTauPowerPmac(this)
            if isa(this.commDeltaTauPowerPmac, 'deltatau.PowerPmac')
                l = true;
            else
                l = false;
            end
        end
        
        
        function setIsConnectedDeltaTauPowerPmac(this, lVal)
           this.lIsConnectedDeltaTauPowerPmac = lVal;
        end
        
        
        function comm = getDeltaTauPowerPmac(this)
            
            if isa(this.commDeltaTauPowerPmac, 'deltatau.PowerPmac')
                comm = this.commDeltaTauPowerPmac; 
                return;
            end
            
            comm = this.commDeltaTauPowerPmacVirtual;
            
        end
        
        
        
        %% Keithley6482Wafer
        
        function l = getIsConnectedKeithley6482Wafer(this)
            if isa(this.commKeithley6482Wafer, 'keithley.Keithley6482')
                l = true;
            else
                l = false;
            end
        end
        
        function disconnectKeithley6482Wafer(this)
            this.commKeithley6482Wafer = [];
        end
        
        function connectKeithley6482Wafer(this)
            
            if this.getIsConnectedKeithley6482Wafer()
                return
            end
            
            this.commKeithley6482Wafer = keithley.Keithley6482(...
                'cTcpipHost', this.cTcpipKeithley6482Wafer, ...
                'u16TcpipPort', 4002, ...
                'cConnection', keithley.Keithley6482.cCONNECTION_TCPCLIENT ...
            );
            this.commKeithley6482Wafer.connect()
            
        end
        
        function comm = getKeithley6482Wafer(this)
            
            if this.getIsConnectedKeithley6482Wafer()
                comm = this.commKeithley6482Wafer;
                return
            end
                
            comm = this.commKeithley6482WaferVirtual;
                
        end
        
        %% WagoD141
        
        function l = getIsConnectedWagoD141(this)
            if isa(this.commWagoD141, 'bl12014.hardwareAssets.WagoD141')
                l = true;
            else
                l = false;
            end
        end
        
        function disconnectWagoD141(this)
            if this.getIsConnectedWagoD141()
                this.commWagoD141 = [];
            end
        end
        
        function connectWagoD141(this)
            
            try
                % modbus requires instrument control toolbox
                
                this.commWagoD141 = bl12014.hardwareAssets.WagoD141(...
                    'cHost', this.cTcpipWago ...
                );
            
            catch mE
                
                % Will crash the app, but gives lovely stack trace.
                error(getReport(mE));
                
                this.commWagoD141 = [];
                
            end
            
        end
        
        function comm = getWagoD141(this)
            
            if this.getIsConnectedWagoD141()
                comm = this.commWagoD141;
                return
            end
                
            comm = this.commWagoD141Virtual;
                
        end
        
        
        %% ExitSlit
        
        function l = getIsConnectedExitSlit(this)
            if isa(this.commExitSlit, 'bl12pico_slits')
                l = true;
            else
                l = false;
            end
        end
        
        function disconnectExitSlit(this)
            if this.getIsConnectedExitSlit()
                this.commExitSlit = [];
            end
        end
        
        function connectExitSlit(this)
            
            this.commExitSlit = bl12pico_slits();
            [e,estr] = this.commExitSlit.checkServer();
            if e
                this.commExitSlit = [];
                error('Problem attaching to pico server');
            end
            
        end
        
        function comm = getExitSlit(this)
            
            if this.getIsConnectedExitSlit()
                comm = this.commExitSlit;
                return
            end
                
            comm = this.commExitSlitVirtual;
                
        end
        
        
        
        %% Keithley6482Reticle
        
        function l = getIsConnectedKeithley6482Reticle(this)
            if isa(this.commKeithley6482Reticle, 'keithley.Keithley6482')
                l = true;
            else
                l = false;
            end
        end
        
        function disconnectKeithley6482Reticle(this)
            if this.getIsConnectedKeithley6482Reticle()
                this.commKeithley6482Reticle = [];
            end
        end
        
        function connectKeithley6482Reticle(this)
            
            if this.getIsConnectedKeithley6482Reticle()
                return
            end
            
            this.commKeithley6482Reticle = keithley.Keithley6482(...
                'cTcpipHost', this.cTcpipKeithley6482Reticle, ...
                'u16TcpipPort', 4001, ...
                'cConnection', keithley.Keithley6482.cCONNECTION_TCPCLIENT ...
            );
            this.commKeithley6482Reticle.connect()
            
        end
        
        function comm = getKeithley6482Reticle(this)
            
            if this.getIsConnectedKeithley6482Reticle()
                comm = this.commKeithley6482Reticle;
                return
            end
                
            comm = this.commKeithley6482ReticleVirtual;
                
        end
        
        
        %% GalilD142
        
        function l = getIsConnectedGalilD142(this)
            if isa(this.commGalilD142, 'cxro.common.device.motion.Stage')
                l = true;
            else
                l = false;
            end
        end
        
        function disconnectGalilD142(this)
            if this.getIsConnectedGalilD142()
                this.commGalilD142.disconnect();
                this.commGalilD142 = [];
            end
        end
        
        function connectGalilD142(this)
            
            if this.getIsConnectedGalilD142()
                return
            end

            try
                this.getjMet5Instruments();
                this.commGalilD142 = this.jMet5Instruments.getDiag142Stage();
                this.commGalilD142.connect();
            catch mE
                this.commGalilD142 = [];
                this.msg(mE.msgtext, this.u8_MSG_TYPE_ERROR);
               
            end
            
        end
        
        function comm = getGalilD142(this)
            
            if this.getIsConnectedGalilD142()
                comm = this.commGalilD142;
                return
            end
                
            comm = this.commGalilD142Virtual;
                
        end
        
        
        %% GalilM143
        
        function l = getIsConnectedGalilM143(this)
            if isa(this.commGalilM143, 'cxro.common.device.motion.Stage')
                l = true;
            else
                l = false;
            end
        end
        
        function disconnectGalilM143(this)
            if this.getIsConnectedGalilM143()
                this.commGalilM143.disconnect();
                this.commGalilM143 = [];
            end
        end
        
        function connectGalilM143(this)
            
            if this.getIsConnectedGalilM143()
                return
            end

            try
                this.getjMet5Instruments();
                this.commGalilM143 = this.jMet5Instruments.getM143Stage();
                this.commGalilM143.connect();
            catch mE
                this.commGalilM143 = [];
                this.msg(mE.msgtext, this.u8_MSG_TYPE_ERROR);
               
            end
            
        end
        
        function comm = getGalilM143(this)
            
            if this.getIsConnectedGalilM143()
                comm = this.commGalilM143;
                return
            end
                
            comm = this.commGalilM143Virtual;
                
        end
        
        
        
        %% GalilM143
        
        function l = getIsConnectedGalilVis(this)
            if isa(this.commGalilVis, 'cxro.common.device.motion.Stage')
                l = true;
            else
                l = false;
            end
        end
        
        function disconnectGalilVis(this)
            if this.getIsConnectedGalilVis()
                this.commGalilVis.disconnect();
                this.commGalilVis = [];
            end
        end
        
        function connectGalilVis(this)
            
            if this.getIsConnectedGalilVis()
                return
            end

            try
                this.getjMet5Instruments();
                this.commGalilVis = this.jMet5Instruments.getVisStage();
                this.commGalilVis.connect();
            catch mE
                this.commGalilVis = [];
                this.msg(mE.msgtext, this.u8_MSG_TYPE_ERROR);
               
            end
            
        end
        
        function comm = getGalilVis(this)
            
            if this.getIsConnectedGalilVis()
                comm = this.commGalilVis;
                return
            end
                
            comm = this.commGalilVisVirtual;
                
        end
        
        %% MfDriftMonitorMiddleware 
        % This is a layer on top of MfDriftMonitor that is exposed
        % from met5instruments in java that has a 
        % different interface
        
        function l = getIsConnectedMfDriftMonitorMiddleware(this)
            l = this.getMfDriftMonitorMiddleware().isConnected();
        end
        
        function connectMfDriftMonitorMiddleware(this)
           this.getMfDriftMonitorMiddleware().connect();
           
        end
        
        function disconnectMfDriftMonitorMiddleware(this)
           this.getMfDriftMonitorMiddleware().disconnect();
        end
                
        function comm = getMfDriftMonitorMiddleware(this)
            
            % This one is set up differently than some of the others,
            % it has virtualization built-in.  That is a little smarter,
            % actually!
            
            if isempty(this.jMet5Instruments)
                this.getjMet5Instruments();
            end
            
           
            
            
            if isempty(this.commMfDriftMonitorMiddleware)
                this.connectMfDriftMonitor();
                comm = this.getMfDriftMonitor();
                this.commMfDriftMonitorMiddleware     = bl12014.hardwareAssets.middleware.MFDriftMonitor(...
                                'commMFDriftMonitor', comm, ...
                                 'clock', this.clock);
            end
            
 
%             % If first time, establish link with Drift Monitor middleware
%             if isempty(this.commMfDriftMonitorMiddleware)
%                 % Set up drift monitor bridge
%                 this.commMfDriftMonitorMiddleware     = bl12014.hardwareAssets.middleware.MFDriftMonitor(...
%                                 'jMet5Instruments', this.jMet5Instruments, ...
%                                  'clock', this.clock);
%             end

            comm = this.commMfDriftMonitorMiddleware;
            
        end
        
        
        
        
        % LSI HEXAPOD
%         function comm = getLSIHexapod(this)
%             if isempty(this.jMet5Instruments)
%                 this.getjMet5Instruments();
%             end
%             if isempty(this.commMfDriftMonitorMiddleware)
%                 CWCHexapod  = this.jMet5Instruments.getLsiHexapod();
%                 % Hexapod bridge, not usually necessary
%                 this.commLSIHexapod 	=  bl12014.hardwareAssets.middleware.CXROJavaStageAPI(...
%                                         'jStage', CWCHexapod);
%             end
%             comm = this.commLSIHexapod;
%         end
%         
        
        
        
        %% Delete fcns
        function deleteKeithley6482Wafer(this)
            this.commKeithley6482Wafer.delete();
            this.commKeithley6482Wafer = [];
        end
        
        function deleteKeithley6482Reticle(this)
            this.commKeithley6482Reticle.delete();
            this.commKeithley6482Reticle = [];
        end
            
        function deleteMFDriftMonitor(this)
            this.commMfDriftMonitorMiddleware.disconnect();
        end
        
        function deleteLSIHexapod(this)
            this.commLSIHexapod.disconnect();
            this.commLSIHexapod = [];
        end
    end
    
    methods (Access = private)
        
        
        
        
        
        
        
        %% Init  functions
        % Initializes directories and any helper classes 
        function init(this)
            
            % {char 1xm} - base directory for configuration and library files
            % for cwcork's cxro.met5.Instruments class

            % Hardware will load the following paths and genpaths on init:

            cDirThis = fileparts(mfilename('fullpath'));
            cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');
            cDirVendor = mic.Utils.path2canonical(cDirVendor);
            
            ceGenpathLoad = { ...
                fullfile(cDirVendor, 'github', 'awojdyla', 'matlab-datatranslation-measurpoint', 'src'), ...
                fullfile(cDirVendor, 'github', 'cnanders', 'matlab-micronix-mmc-103', 'src'), ...
                fullfile(cDirVendor, 'github', 'cnanders', 'matlab-newfocus-model-8742', 'src'), ...
                fullfile(cDirVendor, 'github', 'cnanders', 'matlab-hex', 'src'), ...
                fullfile(cDirVendor, 'github', 'cnanders', 'matlab-ieee', 'src'), ...
                fullfile(cDirVendor, 'github', 'cnanders', 'matlab-npoint-lc400', 'src'), ...
                fullfile(cDirVendor, 'github', 'cnanders', 'matlab-keithley-6482', 'src'), ...
                fullfile(cDirVendor, 'github', 'cnanders', 'matlab-deltatau-ppmac-met5', 'src'), ...
                fullfile(cDirVendor, 'github', 'cnanders', 'matlab-rigol-dg1000z', 'src'), ...
                fullfile(cDirVendor, 'github', 'cnanders', 'matlab-3gstore-remote-power-switch', 'src'), ...
                fullfile(cDirVendor, 'github', 'cnanders', 'matlab-npoint-lc400-ui', 'src'), ...
                fullfile(cDirVendor, 'github', 'cnanders', 'matlab-mightex-led-controller', 'src'), ...
                fullfile(cDirVendor, 'github', 'cnanders', 'matlab-controlbyweb-webswitch', 'src'), ...
                fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v3'), ...
                fullfile(cDirVendor, 'cnanderson'), ...
            };
        
             mic.Utils.map(...
                ceGenpathLoad, ...
                @(cVPath) addpath(genpath(cVPath))...
             );
        
            cePathLoad = {};
            mic.Utils.map(...
                cePathLoad, ...
                @(cVPath) addpath(cVPath));

            
            % Java
            ceJavaPathLoad = { ...
                fullfile(cDirVendor, 'cwcork', 'Met5Instruments.jar'), ...
                ... BL 12.0.1 Exit Slit
                fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v3', 'BL12PICOCorbaProxy.jar'), ...
                ... BL 12.0.1 Undulator, mono grating angle.  Does not have methods for shutter
                fullfile(cDirVendor, 'cwcork', 'bl1201', 'jar_jdk6', 'BL1201CorbaProxy.jar'), ...
                ... BL 12.0.1 Shutter
                fullfile(cDirVendor, 'cwcork', 'bl1201', 'jar_jdk6', 'DctCorbaProxy.jar'), ...
                ... Java SSH2 Communication With DeltaTau Power PMAC Motion Controller (uses JSch)
                ... needed by github/cnanders/matlab-deltatau-ppmac-met5
                fullfile(cDirVendor, 'cnanderson', 'deltatau-power-pmac-comm-jre1.7.jar'), ...
                ... Java utility to check if a network device (host + port) is reachable
                ... Used by GetLogicalPing
                fullfile(cDirVendor, 'cnanderson', 'network-device-jre1.7.jar'), ...
            };

            mic.Utils.map(...
                ceJavaPathLoad, ...
                @(cPath) this.addJavaPathIfNecessary(cPath), ...
                0);
            
            
            this.commRigolDG1000ZVirtual = rigol.DG1000ZVirtual();
            this.commKeithley6482WaferVirtual = keithley.Keithley6482Virtual();
            this.commKeithley6482ReticleVirtual = keithley.Keithley6482Virtual();
            this.commDeltaTauPowerPmacVirtual = deltatau.PowerPmacVirtual();
            this.commDataTranslationVirtual = datatranslation.MeasurPointVirtual();
            this.commMfDriftMonitorVirtual = bl12014.hardwareAssets.virtual.MFDriftMonitor();
            this.commWebSwitchBeamlineVirtual = controlbyweb.WebSwitchVirtual();
            this.commWebSwitchEndstationVirtual = controlbyweb.WebSwitchVirtual();
            this.commWebSwitchVisVirtual = controlbyweb.WebSwitchVirtual();
            this.commBL1201CorbaProxyVirtual = bl12014.hardwareAssets.virtual.BL1201CorbaProxy();
            this.commSmarActM141Virtual = bl12014.hardwareAssets.virtual.Stage();
            this.commWagoD141Virtual = bl12014.hardwareAssets.virtual.WagoD141();
            this.commExitSlitVirtual = bl12014.hardwareAssets.virtual.BL12PicoExitSlit();
            this.commGalilD142Virtual = bl12014.hardwareAssets.virtual.Stage();
            this.commGalilM143Virtual = bl12014.hardwareAssets.virtual.Stage();
            this.commGalilVisVirtual = bl12014.hardwareAssets.virtual.Stage();
        end
        
  
        
        
        function addJavaPathIfNecessary(this, cPath)
            cecPaths = javaclasspath('-dynamic');
            
            if ~isempty(cecPaths)
                ceMatches = mic.Utils.filter(cecPaths, @(cVal) strcmpi(cVal, cPath));
                if ~isempty(ceMatches)
                    return
                end
            end
            
            fprintf('bl12014.hardware.addJavaPathIfNecessary adding:\n%s\n', cPath);
            javaaddpath(cPath);
            
        end
        
        
                

    end % private
    
    
end