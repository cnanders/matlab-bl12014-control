% MET5 hardware class.  Contains getters for all hardware handles.
%
% Every hardware communication requires the addition of four things:
%
% 1) Corresponding "comm" property (e.g., commMFDriftMonitor) represeting
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
        
        
        
    end
    
	properties
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
        
        % {deltaTau.PowerPmac 1x1}
        commDeltaTauPowerPmac
        
        % {MFDriftMonitor}
        commMFDriftMonitor   
    end
    

    
    properties (Access = private)
        
        % {char 1xm} - base directory for configuration and library files
        % for cwcork's cxro.met5.Instruments class
        
        % Hardware will load the following paths and genpaths on init:
        ceGenpathLoad = { ...
            fullfile(fileparts(mfilename('fullpath')), '..', '..', 'vendor',    ...
                        'github', 'cnanders', 'matlab-keithley-6482', 'src')    ...
            }
%         ceGenpathLoad = {}
        cePathLoad = { ...
            }
        
        ceJavaPathLoad = { ...
            fullfile(fileparts(mfilename('fullpath')), '..', '..', 'vendor',    ...
                        'cwcork', 'Met5Instruments.jar')                        ...
            }
    end
    
        
    

    
    methods
        
        % Constructor
        function this = Hardware()
            this.init();
        end
    
        % Destructor
        function delete(this)
        end
        
        
        %% Getters
        function comm = getjMet5Instruments(this)
            if isempty(this.jMet5Instruments)
                this.jMet5Instruments = cxro.met5.Instruments(this.cDirMet5InstrumentsConfig);
            end
            comm = this.jMet5Instruments;
        end
        
        % WAFER DOSE MONITOR (KEITHLEY 6482)
        function comm = getKeithleyWafer(this)
            if isempty(this.commKeithley6482Wafer)
               this.commKeithley6482Wafer = keithley.Keithley6482(...
                    'cTcpipHost', this.cTcpipKeithley6482Wafer, ...
                    'u16TcpipPort', 4001, ...
                    'cConnection', keithley.Keithley6482.cCONNECTION_TCPCLIENT ...
                );
                this.commKeithley6482Wafer.connect()
            end
            comm = this.commKeithley6482Wafer;
        end
        
        % DRIFT MONITOR
        function comm = getMFDriftMonitor(this)
            if isempty(this.jMet5Instruments)
                this.getjMet5Instruments();
            end
            if isempty(this.commMFDriftMonitor)
                CWCDriftMonitorAPI  = this.jMet5Instruments.getMfDriftMonitor();
                % Drift monitor bridge, not usually necessary
                this.commMFDriftMonitor     = bl12014.hardwareAssets.middleware.MFDriftMonitor(...
                                'javaAPI', CWCDriftMonitorAPI);
            end
            comm = this.commMFDriftMonitor;
        end
        function comm = getMFDriftMonitorVirtual(~)
            comm = bl12014.hardwareAssets.virtual.VirtualMFDriftMonitor();
        end
        
        % LSI HEXAPOD
        function comm = getLSIHexapod(this)
            if isempty(this.jMet5Instruments)
                this.getjMet5Instruments();
            end
            if isempty(this.commMFDriftMonitor)
                CWCHexapod  = this.jMet5Instruments.getLsiHexapod();
                % Hexapod bridge, not usually necessary
                this.commLSIHexapod 	=  bl12014.hardwareAssets.middleware.CXROJavaStageAPI(...
                                        'jStage', CWCHexapod);
            end
            comm = this.commLSIHexapod;
        end
        
        
        
        
        %% Delete fcns
        function deleteKeithleyWafer(this)
            this.commKeithley6482Wafer.delete();
            this.commKeithley6482Wafer = [];
        end
            
        function deleteMFDriftMonitor(this)
            this.commMFDriftMonitor.disconnect();
            this.commMFDriftMonitor = [];
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
            % Init path
            mic.Utils.map(this.ceGenpathLoad, ...
                @(cVPath) addpath(genpath(cVPath)));
            mic.Utils.map(this.cePathLoad, ...
                @(cVPath) addpath(cVPath));
            mic.Utils.map(this.ceJavaPathLoad, ...
                @(cVPath) javaaddpath(cVPath), 0);
        end
        
  
        
  
        
        
                

    end % private
    
    
end