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
        lIsConnectedKeithley6482Wafer = false
        
        commKeithley6482Reticle
        commKeithley6482ReticleVirtual
        lIsConnectedKeithley6482Reticle = false
        
        
        commDataTranslation
        commDataTranslationVirtual
        lIsConnectedDataTranslation = false
        
        % {deltaTau.PowerPmac 1x1}
        commDeltaTauPowerPmac
        commDeltaTauPowerPmacVirtual
        lIsConnectedDeltaTauPowerPmac = false
        
        % {MFDriftMonitor}
        commMfDriftMonitorMiddleware
        commMfDriftMonitorMiddlewareVirtual
        lIsConnectedMfDriftMonitorMiddleware = false
        
        commRigolDG1000Z
        commRigolDG1000ZVirtual
        lIsConnectedRigolDG1000Z = false
        
        
        commMfDriftMonitor
        commMfDriftMonitorVirtual
        lIsConnectedMfDriftMonitor = false
        
        
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
        end
        
        % Setters
        function setClock(this, clock)
            this.clock = clock;
        end
        
        %% MF Drift Monitor (different than MfDriftMonitor Middleware
        
        function l = getIsConnectedMfDriftMonitor(this)
            l = this.lIsConnectedMfDriftMonitor;
        end
        
        function setIsConnectedMfDriftMonitor(this, lVal)
           this.lIsConnectedMfDriftMonitor = lVal;
        end
                
        function comm = getMfDriftMonitor(this)
            if this.lIsConnectedMfDriftMonitor
                if isempty(this.commMfDriftMonitor)
                    
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
                comm = this.commMfDriftMonitor;
            else
                comm = this.commMfDriftMonitorVirtual;
            end            
        end
        
        
        %% Rigol DG1000Z
        
        function l = getIsConnectedRigolDG1000Z(this)
            l = this.lIsConnectedRigolDG1000Z;
        end
        
        function setIsConnectedRigolDG1000Z(this, lVal)
           this.lIsConnectedRigolDG1000Z = lVal;
        end
                
        function comm = getRigolDG1000Z(this)
            if this.lIsConnectedRigolDG1000Z
                if isempty(this.commRigolDG1000Z)
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
                comm = this.commRigolDG1000Z;
            else
                comm = this.commRigolDG1000ZVirtual;
            end            
        end
        
        
        %% Getters
        function comm = getjMet5Instruments(this)
            if isempty(this.jMet5Instruments)
                this.jMet5Instruments = cxro.met5.Instruments(this.cDirMet5InstrumentsConfig);
            end
            comm = this.jMet5Instruments;
        end
        
        function l = getIsConnectedDataTranslation(this)
            l = this.lIsConnectedDataTranslation;
        end
        
        function setIsConnectedDataTranslation(this, lVal)
           this.lIsConnectedDataTranslation = lVal;
        end
        
        function comm = getDataTranslation(this)
            
            if this.lIsConnectedDataTranslation
                
                if isempty(this.commDataTranslation)
                   this.commDataTranslation = datatranslation.MeasurPoint(this.cTcpipDataTranslation);
                    
                    % Connect the instrument through TCP/IP
                    this.commDataTranslation.connect();

                    % Enable readout on protected channels
                    this.commDataTranslation.enable();
                end
                comm = this.commDataTranslation;
            else
                comm = this.commDataTranslationVirtual;
                
            end
        end
        
        % WAFER DOSE MONITOR (KEITHLEY 6482)
        
        function l = getIsConnectedDeltaTauPowerPmac(this)
            l = this.lIsConnectedDeltaTauPowerPmac;
        end
        
        function setIsConnectedDeltaTauPowerPmac(this, lVal)
           this.lIsConnectedDeltaTauPowerPmac = lVal;
        end
        
        function comm = getDeltaTauPowerPmac(this)
            
            if this.lIsConnectedDeltaTauPowerPmac
                
                if isempty(this.commDeltaTauPowerPmac)
                   this.commDeltaTauPowerPmac = deltatau.PowerPmac(...
                        'cHostname', this.cTcpipDeltaTau ...
                    );
                    this.commDeltaTauPowerPmac.init();
                end
                comm = this.commDeltaTauPowerPmac;
            else
                comm = this.commDeltaTauPowerPmacVirtual;
                
            end
        end
        
        
        
        %% Keithley6482Wafer
        
        function l = getIsConnectedKeithley6482Wafer(this)
            l = this.lIsConnectedKeithley6482Wafer;
        end
        
        function setIsConnectedKeithley6482Wafer(this, lVal)
           this.lIsConnectedKeithley6482Wafer = lVal;
        end
        
        function comm = getKeithley6482Wafer(this)
            
            if this.lIsConnectedKeithley6482Wafer
                
                if isempty(this.commKeithley6482Wafer)
                   this.commKeithley6482Wafer = keithley.Keithley6482(...
                        'cTcpipHost', this.cTcpipKeithley6482Wafer, ...
                        'u16TcpipPort', 4001, ...
                        'cConnection', keithley.Keithley6482.cCONNECTION_TCPCLIENT ...
                    );
                    this.commKeithley6482Wafer.connect()
                end
                comm = this.commKeithley6482Wafer;
            else
                comm = this.commKeithley6482WaferVirtual;
                
            end
        end
        
        %% Keithley6482Reticle
        
        function l = getIsConnectedKeithley6482Reticle(this)
            l = this.lIsConnectedKeithley6482Reticle;
        end
        
        function setIsConnectedKeithley6482Reticle(this, lVal)
           this.lIsConnectedKeithley6482Reticle = lVal;
        end
        
        function comm = getKeithley6482Reticle(this)
            
            if this.lIsConnectedKeithley6482Reticle
                
                if isempty(this.commKeithley6482Reticle)
                   this.commKeithley6482Reticle = keithley.Keithley6482(...
                        'cTcpipHost', this.cTcpipKeithley6482Reticle, ...
                        'u16TcpipPort', 4002, ...
                        'cConnection', keithley.Keithley6482.cCONNECTION_TCPCLIENT ...
                    );
                    this.commKeithley6482Reticle.connect()
                end
                comm = this.commKeithley6482Reticle;
            else
                comm = this.commKeithley6482ReticleVirtual;
                
            end
        end
        
        %% MfDriftMonitorMiddleware 
        % This is a layer on top of MfDriftMonitor that is exposed
        % from met5instruments in java that has a 
        % different interface
        
        function l = getIsConnectedMfDriftMonitorMiddleware(this)
            
            % l = this.lIsConnectedMfDriftMonitorMiddleware;
            l = this.getMfDriftMonitorMiddleware().isConnected();
        end
        
        function setIsConnectedMfDriftMonitorMiddleware(this, lVal)
           % this.lIsConnectedMfDriftMonitorMiddleware = lVal;
           mic.Utils.ternEval(...
               lVal, ...
               @() this.getMfDriftMonitorMiddleware().connect(), ...
               @() this.getMfDriftMonitorMiddleware().disconnect() ...
           )
        end
                
        function comm = getMfDriftMonitorMiddleware(this)
            
            % This one is set up differently than some of the others,
            % it has virtualization built-in.  That is a little smarter,
            % actually!
            
            if isempty(this.jMet5Instruments)
                this.getjMet5Instruments();
            end
            
           
            
            
            if isempty(this.commMfDriftMonitorMiddleware)
                this.setIsConnectedMfDriftMonitor(true);
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
            };
        
            cePathLoad = {};

            ceJavaPathLoad = { ...
                fullfile(cDirVendor, 'cwcork', 'Met5Instruments.jar'), ...
            };


            % Init path
            mic.Utils.map(ceGenpathLoad, ...
                @(cVPath) addpath(genpath(cVPath)));
            mic.Utils.map(cePathLoad, ...
                @(cVPath) addpath(cVPath));
            mic.Utils.map(ceJavaPathLoad, ...
                @(cVPath) javaaddpath(cVPath), 0);
            
            
            this.commRigolDG1000ZVirtual = rigol.DG1000ZVirtual();
            this.commKeithley6482WaferVirtual = keithley.Keithley6482Virtual();
            this.commKeithley6482ReticleVirtual = keithley.Keithley6482Virtual();
            this.commDeltaTauPowerPmacVirtual = deltatau.PowerPmacVirtual();
            this.commDataTranslationVirtual = datatranslation.MeasurPointVirtual();
            this.commMfDriftMonitorVirtual = bl12014.hardwareAssets.virtual.MFDriftMonitor();
                        

        end
        
  
        
        
  
        
        
                

    end % private
    
    
end