% MET5 hardware class.  Contains getters for all hardware handles.
%
% Every hardware communication requires the addition of three things:
%
% 1) Corresponding "comm" property (e.g., commMFDriftMonitor) represeting
% the stored handle to the hardware component
%
% 2) Getter function: should return the comm if it is already initialized,
% otherwise should initialize it and then return it
%
% 3) Delete function: disconnects device and unsets the comm property.
%



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
        
        % {cxro.common.device.motion.Stage 1x1}
        commLSIHexapod
        
        % Temporarily:{lsicontrol.virtualDevice.virtualPVCam}
        commPIMTECamera
        
        commSmarActRotary
        
        % {deltaTau.PowerPmac 1x1}
        commDeltaTauPowerPmac
        
        % {MFDriftMonitor}
        commMFDriftMonitor   
    end
    

    
    properties (Access = private)
        
        % {char 1xm} - base directory for configuration and library files
        % for cwcork's cxro.met5.Instruments class
        cDirMet5InstrumentsConfig = fullfile(fileparts(mfilename('fullpath')),...
                '..', '..', 'vendor', 'cwcork');
        
        cDirLSI = fullfile(fileparts(mfilename('fullpath')),...
                '..', '..', 'vendor', 'ryanmiyakawa');
        
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
        function comm = getMFDriftMonitor(this)
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
        
        
        function comm = getLSIHexapod(this)
            if isempty(this.commMFDriftMonitor)
                CWCHexapod  = this.jMet5Instruments.getLsiHexapod();
                % Hexapod bridge, not usually necessary
                this.commLSIHexapod 	=  bl12014.hardwareAssets.middleware.CXROJavaStageAPI(...
                                        'jStage', CWCHexapod);
            end
            comm = this.commLSIHexapod;
        end
        
        
        %% Delete fcns
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
            this.initPath();
            this.initMet5Instruments();
        end
        
        function initPath(this)
            addpath(genpath(this.cDirMet5InstrumentsConfig));
            addpath(genpath(this.cDirLSI));
        end
        
        function initMet5Instruments(this)
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
        
        
                

    end % private
    
    
end