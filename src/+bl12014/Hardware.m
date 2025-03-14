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
        
        
        cTcpipHydraWafer            = '192.168.10.11'
        
        % Branchline Subnet
        cTcpipSmarActM141           = '192.168.10.20'
        cTcpipMicronix              = '192.168.10.21'
        cTcpipLc400M142             = '192.168.10.22'
        cTcpipNewFocusM142          = '192.168.10.23'
        cTcpipGalilD142             = '192.168.10.24'
        cTcpipGalilM143             = '192.168.10.25'
        cTcpipWago                  = '192.168.10.26'
        cTcpipWebSwitchBeamline     = '192.168.10.30'
        
        % Endstation 1 Subnet
        cTcpipLc400MA               = '192.168.20.20'
        % cTcpipGalilVibrationIsolationSystem = '192.168.20.21'
        cTcpipAcromag               = '192.168.20.22' % met5vme.dhcp.lbl.gov
        cTcpipDeltaTau              = '192.168.20.23'
        cTcpipSmarActLSIGoni        = '192.168.20.24' % 
        cTcpipSmarActLSIHexapod     = '192.168.20.25'
        cTcpipSmarActFocusMonitor   = '192.168.20.26'
        cTcpipDataTranslation       = '192.168.20.27'
        cTcpipKeithley6482Wafer     = '192.168.20.28'
        cTcpipKeithley6482Reticle   = '192.168.20.28'
        cTcpipNewFocusMA            = '192.168.20.31'
        cTcpipWebSwitchVis          = '192.168.20.32'
        cTcpipSMS                   = '192.168.10.31'
        cTcpipRigolDG1000Z          = '192.168.20.35'
        cTcpipDoseMonitor           = '192.168.20.60'

        cTcpipGalilM1               = '192.168.10.150'
        dPortGalilM1                = uint16(23)

        cTcpipIris                  = '192.168.20.50'
        dPortIris                   = 5020
        
        cSNSM_MCS2_DCT              = 'network:sn:MCS2-00005705'
    end
    
	properties
        clock
        
        % {cxro.met5.Instruments 1x1}
        jMet5Instruments
        cDirMet5InstrumentsConfig = ...
            fullfile(fileparts(mfilename('fullpath')), '..', '..', 'vendor', 'cwcork');

        commDoseMonitor
        commDoseMonitorVirtual
        
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
        
       
        commDCTWaferStage
        commDCTWaferStageVirtual
        
        commSR570MDM
        commSR570MDMVirtual
        
        commSR570DCT1
        commSR570DCT1Virtual
        
        commSR570DCT2
        commSR570DCT2Virtual
        
        commSMS
        commSMSVirtual
        
        
        commDCTApertureStage
        commDCTApertureStageVirtual
        
        % {deltaTau.PowerPmac 1x1}
        commDeltaTauPowerPmac
        commDeltaTauPowerPmacVirtual
        
        commHydraWafer
        commHydraWaferVirtual
        
        % {MFDriftMonitor}
        commMfDriftMonitorMiddleware
        commMfDriftMonitorMiddlewareVirtual
        
        
        commTekAFG31021
        commTekAFG31021Virtual
        
        commRigolDG1000Z
        commRigolDG1000ZVirtual
                
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
        
        
        commDCTCorbaProxy
        commDCTCorbaProxyVirtual
        
        commSmarActM141
        commSmarActM141Virtual
        
        commSmarActVPFM
        commSmarActVPFMVirtual
        
        commWagoD141
        commWagoD141Virtual
        
        commExitSlit
        commExitSlitVirtual
        
        commGalilD142
        commGalilD142Virtual
        
        commGalilM143
        commGalilM143Virtual
        
        commGalilVis
        commGalilVisFiltered % middleware filter
        commGalilVisVirtual

        commGalilM1
        commGalilM1Virtual
        
        commMightex1
        commMightex1Virtual
        
        commMightex2
        commMightex2Virtual
        
        commNPointM142
        commNPointM142Virtual
        
        commNPointMA
        commNPointMAVirtual
        
        commALS
        commALSVirtual
        
        commNewFocus8742M142
        commNewFocus8742M142Virtual
        
        commNewFocus8742MA
        commNewFocus8742MAVirtual


        commIris
        commIrisVirtual


                
    end
    

    
    properties (Access = private)
        
        
    end
    
        
    

    
    methods
        
        % Constructor
        function this = Hardware(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            this.init();
        end
    
        % Destructor
        function delete(this)
            % Put all of the disconnect functions here
            this.disconnectALS();
            this.disconnectBL1201CorbaProxy();
            this.disconnectDataTranslation();
            this.disconnectDCTCorbaProxy();
            this.disconnectDeltaTauPowerPmac();
            this.disconnectExitSlit();
            this.disconnectGalilD142();
            this.disconnectGalilM143();
            this.disconnectGalilVis();
            this.disconnectKeithley6482Reticle();
            this.disconnectKeithley6482Wafer();
            this.disconnectMfDriftMonitor();
            this.disconnectMfDriftMonitorMiddleware();
            this.disconnectMightex1();
            this.disconnectMightex2();
            this.disconnectNewFocus8742M142();
            this.disconnectNewFocus8742MA();
            this.disconnectNPointM142();
            this.disconnectNPointMA();
            this.disconnectRigolDG1000Z();
            this.disconnectTekAFG31021();
            this.disconnectSmarActM141();
            this.disconnectSmarActVPFM();
            this.disconnectWagoD141();
            this.disconnectWebSwitchBeamline();
            this.disconnectWebSwitchEndstation();
            this.disconnectWebSwitchVis();
            
            this.commALSVirtual= [];
            this.commBL1201CorbaProxyVirtual = [];
            this.commDataTranslationVirtual = [];
            this.commDCTCorbaProxyVirtual = [];
            this.commDeltaTauPowerPmacVirtual = [];
            this.commExitSlitVirtual = [];
            this.commGalilD142Virtual = [];
            this.commGalilM143Virtual = [];
            this.commGalilVisVirtual = [];

            this.commGalilM1Virtual = [];
            
            this.commDCTWaferStageVirtual = [];
            this.commDCTApertureStageVirtual = [];
            
            this.commSR570DCT1Virtual = [];
            this.commSR570DCT2Virtual = [];
            
                        this.commSMSVirtual = [];

            
            this.commSR570MDMVirtual = [];
            
            this.commKeithley6482ReticleVirtual = [];
            this.commKeithley6482WaferVirtual = [];
            this.commMfDriftMonitorVirtual = [];
            this.commMfDriftMonitorMiddlewareVirtual = [];
            this.commMightex1Virtual = [];
            this.commMightex2Virtual = [];
            this.commNewFocus8742M142Virtual = [];
            this.commNewFocus8742MAVirtual = [];
            this.commNPointM142Virtual = [];
            this.commNPointMAVirtual = [];
            this.commRigolDG1000ZVirtual = [];
            this.commTekAFG31021Virtual = [];
            this.commSmarActM141Virtual = [];
            this.commSmarActVPFMVirtual = [];
            this.commWagoD141Virtual = [];
            this.commWebSwitchBeamlineVirtual = [];
            this.commWebSwitchEndstationVirtual = [];
            this.commWebSwitchVisVirtual = [];
            this.commIrisVirtual = [];
        end
        
        
        
        %% WebSwitch (Beamline)
        function l = getIsConnectedALS(this)
          
            if this.notEmptyAndIsA(this.commALS, 'cxro.ALS')
                l = true;
                return;
                
            end

            l = false;
        end
        
        function connectALS(this)
            
            try
                this.commALS = cxro.ALS();
           catch mE
                % error(getReport(mE));
           end
        end
        
        function disconnectALS(this)
            if this.getIsConnectedALS()
                try
                    this.commALS.disconnect();
                catch mE
                    
                end
            end
            
            this.commALS = [];
        end
                
        function comm = getALS(this)
            if this.getIsConnectedALS()
                comm = this.commALS;
            else
                comm = this.commALSVirtual;
            end            
        end
        
        
        
        %% WebSwitch (Beamline)
        function l = getIsConnectedWebSwitchBeamline(this)
                        
            if this.notEmptyAndIsA(this.commWebSwitchBeamline, 'controlbyweb.WebSwitch')
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
                % error(getReport(mE));
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
            
            
            if this.notEmptyAndIsA(this.commWebSwitchEndstation, 'controlbyweb.WebSwitch')
                l = true;
                return;
                
            end

            l = false;
        end
        
        function connectWebSwitchEndstation(this)
            
            try
                this.commWebSwitchEndstation = controlbyweb.WebSwitch(...
                    'cHost', '192.168.20.30' ...
                );
           catch mE
                % error(getReport(mE));
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
        
        %% MET5/CXRO Dose Monitor
        function l = getIsConnectedDoseMonitor(this)
            
            if this.notEmptyAndIsA(this.commDoseMonitor, 'cxro.DoseMonitor')
                l = true;
                return;
                
            end

            l = false;
        end
        
        function connectDoseMonitor(this)
            
            try
                this.commDoseMonitor = cxro.DoseMonitor(...
                    'cHost', this.cTcpipDoseMonitor ...
                );
            
                this.commDoseMonitor.connect();
                this.commDoseMonitor.getCounts(); % Make sure it can talk to hardware
           catch mE
                % error(getReport(mE));
           end
        end
        
        function disconnectDoseMonitor(this)
            this.commDoseMonitor.disconnect();
            this.commDoseMonitor = [];
        end
                
        function comm = getDoseMonitor(this)
            if this.getIsConnectedDoseMonitor()
                comm = this.commDoseMonitor;
            else
                comm = this.commDoseMonitorVirtual;
            end            
        end
        
        %% WebSwitch (VIS)
        function l = getIsConnectedWebSwitchVis(this)
            
            if this.notEmptyAndIsA(this.commWebSwitchVis, 'controlbyweb.WebSwitch')
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
            
                % SPECIAL case, also turn on relay 1 so we power on the
                % controller.
                % this.commWebSwitchVis.turnOnRelay1();
           catch mE
                % error(getReport(mE));
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
           
            if this.notEmptyAndIsA(this.commBL1201CorbaProxy, 'cxro.bl1201.beamline.BL1201CorbaProxy')
                l = true;
                return;
            end

            l = false;
        end
        
        function connectBL1201CorbaProxy(this)
            
            try
                this.commBL1201CorbaProxy = cxro.bl1201.beamline.BL1201CorbaProxy();
           catch mE
                % error(getReport(mE));
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
        
        
        %% DCT Cobra Proxy
        
        function l = getIsConnectedDCTCorbaProxy(this)
           
            if this.notEmptyAndIsA(this.commDCTCorbaProxy, 'cxro.bl1201.dct.DctCorbaProxy')
                l = true;
                return;
            end

            l = false;
        end
        
        function connectDCTCorbaProxy(this)
            
            try
                this.commDCTCorbaProxy = cxro.bl1201.dct.DctCorbaProxy();
           catch mE
                % error(getReport(mE));
           end
        end
        
        function disconnectDCTCorbaProxy(this)
            this.commDCTCorbaProxy = [];
        end
                
        function comm = getDCTCorbaProxy(this)
            if this.getIsConnectedDCTCorbaProxy()
                comm = this.commDCTCorbaProxy;
            else
                comm = this.commDCTCorbaProxyVirtual;
            end            
        end
        
        
        
        
        
        %% MF Drift Monitor (different than MfDriftMonitor Middleware)
        
        function l = getIsConnectedMfDriftMonitor(this)
           
            if this.notEmptyAndIsA(this.commMfDriftMonitor, 'cxro.met5.device.mfdriftmonitor.MfDriftMonitorCorbaProxy')
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
                % error(getReport(mE));
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
        
        
        %% Tektronix AFG31021
        
        function l = getIsConnectedTekAFG31021(this)
            
            if this.notEmptyAndIsA(this.commTekAFG31021, 'tektronix.AFG31021')
                l = true;
                return;
            end
            l = false;
        end
        
        function connectTekAFG31021(this)
            try
                this.commTekAFG31021 = tektronix.AFG31021(...
                    'cTcpipHost', '192.168.20.38' ...
                );
           catch mE
                % error(getReport(mE));
           end
        end
        
        function disconnectTekAFG31021(this)
            this.commTekAFG31021 = [];
        end
                        
        function comm = getTekAFG31021(this)
            if this.getIsConnectedTekAFG31021()
                comm = this.commTekAFG31021;
            else
                comm = this.commTekAFG31021Virtual;
            end            
        end
        
        %% Rigol DG1000Z
        
        function l = getIsConnectedRigolDG1000Z(this)
            
            if this.notEmptyAndIsA(this.commRigolDG1000Z, 'rigol.DG1000Z')
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
                % error(getReport(mE));
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
        
        
        %% SmarAct VPFM
        
        function l = getIsConnectedSmarActVPFM(this)
            
            if this.notEmptyAndIsA(this.commSmarActVPFM, 'smaract.MCS')
                l = true;
                return;
            end
            l = false;
               
            %{
            if ( ...
                this.notEmptyAndIsA(this.commSmarActVPFM, 'cxro.common.device.motion.Stage') || ...
                this.notEmptyAndIsA(this.commSmarActVPFM, 'cxro.common.device.motion.SmarActMcsController') ...
                ) && ...
               this.commSmarActVPFM.isConnected()
                l = true;
                return;
            end
            l = false;
            %}
        end
        
        function connectSmarActVPFM(this)
            
            try
                % NOTE TO CHRIS 2023.02.14 - this is for MCS1 controller
                % current hardware configuration is MCS2 controller stollen
                % from DCT2.  The MCS does not work
                this.commSmarActVPFM = smaract.MCS(....
                    'cHost', '192.168.20.24', ...
                    'cPort', '5000' ...
                );
            catch mE
                getReport(mE)
                % error(getReport(mE))
            end
            
            % 2022.11.02 commenting Java code from Carl/Will
            %{
            
            this.getjMet5Instruments();
             try
                
                this.commSmarActVPFM = this.jMet5Instruments.getVPfmStage();
                
                % FIX ME 2019.07.10
                this.commSmarActVPFM.connect();
                %this.commSmarActVPFM.reset();
                %this.commSmarActVPFM.initializeAxes().get();
                %this.commSmarActVPFM.moveAxisAbsolute(0, 0);
                
            catch mE
                
                getReport(mE);
                % error(getReport(mE));
            end
            %}
        end
        
        function disconnectSmarActVPFM(this)
%              if this.getIsConnectedSmarActVPFM()
%                  this.commSmarActVPFM.disconnect();
%              end
            this.commSmarActVPFM = [];
        end
                        
        function comm = getSmarActVPFM(this)
            if this.getIsConnectedSmarActVPFM()
                comm = this.commSmarActVPFM;
            else
                comm = this.commSmarActVPFMVirtual;
            end            
        end
        
        %% SmarAct M141
        
        function l = getIsConnectedSmarActM141(this)
                  
            
            
            if this.notEmptyAndIsA(this.commSmarActM141, 'cxro.common.device.motion.Stage') && ...
               this.commSmarActM141.isConnected()
                l = true;
                return;
            end
            
            if this.notEmptyAndIsA(this.commSmarActM141, 'cxro.common.device.motion.Stage') && ...
               this.commSmarActM141.isConnected() ... &&
               ...this.commSmarActM141.getAxesIsInitialized()
                l = true;
                return;
            end
            l = false;
        end
        
        function connectSmarActM141(this)
            
            this.getjMet5Instruments();
             try
                
                this.commSmarActM141 = this.jMet5Instruments.getM141Stage();
                
                
                % this.commSmarActM141.connect();
                this.commSmarActM141.reset();
                this.commSmarActM141.initializeAxes().get();
                this.commSmarActM141.moveAxisAbsolute(0, 0);

%{
                % 3/13 (RHM): for now let's reset stage and reinitialize, but
                % eventually let's pull this out to somewhere in the ui
                
                
                %}
                
            catch mE
                
                getReport(mE);
                % error(getReport(mE));
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
        
        
        %% Mightex Universal LED Controller (1)
        
        function l = getIsConnectedMightex1(this)
            
            if this.notEmptyAndIsA(this.commMightex1, 'mightex.UniversalLedController')
                l = true;
                return;
            end
            l = false;
        end
        
        function connectMightex1(this)
            
            try 
                this.commMightex1 = mightex.UniversalLedController(...
                    'u8DeviceIndex', 0 ...
                );
                this.commMightex1.init();
                
            catch mE
                
                this.commMightex1 = [];
                getReport(mE);
                % error(getReport(mE));
            end
            
        end
        
        function disconnectMightex1(this)
             if this.getIsConnectedMightex1()
                 this.commMightex1.disconnect();
             end
            this.commMightex1 = [];
        end
                        
        function comm = getMightex1(this)
            if this.getIsConnectedMightex1()
                comm = this.commMightex1;
            else
                comm = this.commMightex1Virtual;
            end            
        end
        
        
        %% NewFocus Model 8742 (M142)
        
        function l = getIsConnectedNewFocus8742M142(this)
                       
            if this.notEmptyAndIsA(this.commNewFocus8742M142, 'newfocus.Model8742')
                l = true;
                return;
            end
            l = false;
        end
        
        function connectNewFocus8742M142(this)
            
            try 
                this.commNewFocus8742M142 = newfocus.Model8742(...
                    'cTcpipHost', this.cTcpipNewFocusM142 ...
                );
                this.commNewFocus8742M142.init();
                this.commNewFocus8742M142.connect();
                this.commNewFocus8742M142.getIdentity()
                
            catch mE
                
                this.commNewFocus8742M142 = [];
                % error(getReport(mE));
            end
            
        end
        
        function disconnectNewFocus8742M142(this)
             if this.getIsConnectedNewFocus8742M142()
                 this.commNewFocus8742M142.disconnect();
             end
            this.commNewFocus8742M142 = [];
        end
                        
        function comm = getNewFocus8742M142(this)
            if this.getIsConnectedNewFocus8742M142()
                comm = this.commNewFocus8742M142;
            else
                comm = this.commNewFocus8742M142Virtual;
            end            
        end
        
        %% NewFocus Model 8742 (M142)
        
        function l = getIsConnectedNewFocus8742MA(this)
            
            if this.notEmptyAndIsA(this.commNewFocus8742MA, 'newfocus.Model8742')
                l = true;
                return;
            end
            l = false;
        end
        
        function connectNewFocus8742MA(this)
            
            try 
                this.commNewFocus8742MA = newfocus.Model8742(...
                    'cTcpipHost', '192.168.20.31' ...
                );
                this.commNewFocus8742MA.init();
                this.commNewFocus8742MA.connect();
                
            catch mE
                
                this.commNewFocus8742MA = [];
                % error(getReport(mE));
            end
            
        end
        
        function disconnectNewFocus8742MA(this)
             if this.getIsConnectedNewFocus8742MA()
                 this.commNewFocus8742MA.disconnect();
             end
            this.commNewFocus8742MA = [];
        end
                        
        function comm = getNewFocus8742MA(this)
            if this.getIsConnectedNewFocus8742MA()
                comm = this.commNewFocus8742MA;
            else
                comm = this.commNewFocus8742MAVirtual;
            end            
        end

        function l = getIsConnectedIris(this)
            if this.notEmptyAndIsA(this.commIris, 'bl12014.hardwareAssets.ModbusIris')
                l = true;
                return;
            end
            l = false;
        end

        function connectIrisModbus(this)
            try
                this.commIris = bl12014.hardwareAssets.ModbusIris(...
                    'cTcpipHost', this.cTcpipIris, ...
                    'dPort', this.dPortIris ...
                );
            catch mE
                this.commIris = [];
                % error(getReport(mE));
            end
        end

        function disconnectIrisModbus(this)
            if this.getIsConnectedIris()
                this.commIris.disconnect();
            end
            this.commIris = [];
        end

        function comm = getModbusIris(this)
            if this.getIsConnectedIris()
                comm = this.commIris;
            else
                comm = this.commIrisVirtual;
            end
        end
        
        
        %% Mightex Universal LED Controller (2)
        
        function l = getIsConnectedMightex2(this)
            
            if this.notEmptyAndIsA(this.commMightex2, 'mightex.UniversalLedController')
                l = true;
                return;
            end
            l = false;
        end
        
        function connectMightex2(this)
            
            try 
                this.commMightex2 = mightex.UniversalLedController(...
                    'u8DeviceIndex', 1 ...
                );
                this.commMightex2.init();
                
            catch mE
                
                this.commMightex2 = [];
                % error(getReport(mE));
            end
            
        end
        
        function disconnectMightex2(this)
             if this.getIsConnectedMightex2()
                 this.commMightex2.disconnect();
             end
            this.commMightex2 = [];
        end
                        
        function comm = getMightex2(this)
            if this.getIsConnectedMightex2()
                comm = this.commMightex2;
            else
                comm = this.commMightex2Virtual;
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
            
            if this.notEmptyAndIsA(this.commDataTranslation, 'datatranslation.MeasurPoint')
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
            
            
            % Show all MeasurePoint channel hardware types (These cannot be set)
            [tc, rtd, volt] = this.commDataTranslation.channelType();
            fprintf('bl12014.Logger.init():\n');
            fprintf('DataTranslation MeasurPoint Hardware configuration:\n');
            fprintf('TC   sensor channels = %s\n',num2str(tc,'%1.0f '))
            fprintf('RTD  sensor channels = %s\n',num2str(rtd,'%1.0f '))
            fprintf('Volt sensor channels = %s\n',num2str(volt,'%1.0f '))
                        
            channels = 0 : 7;
            for n = channels
               this.commDataTranslation.setSensorType(n, 'J');
            end

            channels = 8 : 15;
            for n = channels
                this.commDataTranslation.setSensorType(n, 'PT1000');
            end

            channels = 16 : 19;
            for n = channels
                this.commDataTranslation.setSensorType(n, 'PT100');
            end

            channels = 20 : 23;
            for n = channels
               this.commDataTranslation.setSensorType(n, 'PT1000');
            end

            channels = 24 : 31;
            for n = channels
                this.commDataTranslation.setSensorType(n, 'PT100');
            end

            channels = 32 : 47;
            for n = channels
                this.commDataTranslation.setSensorType(n, 'V');
            end
            
            this.commDataTranslation.abortScan(); % stops scanning so the filter type can be set
            this.commDataTranslation.setFilterTypeToRaw() % if you dont
            % it uses its internal 16 point rolling averaging filter (1.6
            % seconds)
            
            % echo the filter type:
            this.commDataTranslation.getFilterType()
            this.commDataTranslation.setScanList(0:47);
            this.commDataTranslation.setScanPeriod(0.1);
            this.commDataTranslation.initiateScan();
            % this.commDataTranslation.abortScan();
            this.commDataTranslation.clearBytesAvailable();
                
        end
        
        function disconnectDataTranslation(this)
            this.commDataTranslation = [];
        end
        
        
        %% Hydra
        
        function connectHydraWafer(this)
            
            if this.notEmptyAndIsA(this.commHydraWafer, 'pi.Hydra')
                return
            end
            
            this.commHydraWafer = pi.Hydra(...
                'cTcpipHost', this.cTcpipHydraWafer, ...
                'u16TcpipPort', uint16(400) ...
            );
            
        end
        
        function disconnectHydraWafer(this)
 
            if this.notEmptyAndIsA(this.commHydraWafer, 'pi.Hydra')
                this.commHydraWafer = []; % calls delete() which calls disconnect
            end
        end
        
        function l = getIsConnectedHydraWafer(this)
            if this.notEmptyAndIsA(this.commHydraWafer, 'pi.Hydra')
                l = true;
            else
                l = false;
            end
        end
        
        
        function setIsConnectedHydraWafer(this, lVal)
           this.lIsConnectedHydraWafer = lVal;
        end
        
        
        function comm = getHydraWafer(this)
            if this.notEmptyAndIsA(this.commHydraWafer, 'pi.Hydra')
                comm = this.commHydraWafer; 
                return;
            end
            comm = this.commHydraWaferVirtual;
            
        end
        
        
        %% Power Pmac
        
        function connectDeltaTauPowerPmac(this)
            
            if this.notEmptyAndIsA(this.commDeltaTauPowerPmac, 'deltatau.PowerPmac')
                return
            end
            
            this.commDeltaTauPowerPmac = deltatau.PowerPmac(...
                'cHostname', this.cTcpipDeltaTau ...
            );
            
        end
        
        function disconnectDeltaTauPowerPmac(this)
 
            if this.notEmptyAndIsA(this.commDeltaTauPowerPmac, 'deltatau.PowerPmac')
                % this.commDeltaTauPowerPmac.disconnect();
                this.commDeltaTauPowerPmac = []; % calls delete() which calls disconnect
            end
        end
        
        function l = getIsConnectedDeltaTauPowerPmac(this)
            if this.notEmptyAndIsA(this.commDeltaTauPowerPmac, 'deltatau.PowerPmac')
                l = true;
            else
                l = false;
            end
        end
        
        
        function setIsConnectedDeltaTauPowerPmac(this, lVal)
           this.lIsConnectedDeltaTauPowerPmac = lVal;
        end
        
        
        function comm = getDeltaTauPowerPmac(this)
            
            if this.notEmptyAndIsA(this.commDeltaTauPowerPmac, 'deltatau.PowerPmac')
                comm = this.commDeltaTauPowerPmac; 
                return;
            end
            
            comm = this.commDeltaTauPowerPmacVirtual;
            
        end
        
        % Wrapper around built-in isa that also checks first if the first
        % arg is not empty
        function lReturn = notEmptyAndIsA(this, var, type)
            
            lReturn = false;
            
            % return immediately if var is empty
            if isempty(var)
                return
            end
            
            % check
            if isa(var, type)
                lReturn = true;
            end
        end
        
        %% Keithley6482Wafer
        
        function l = getIsConnectedKeithley6482Wafer(this)
            
            
            
            
            if this.notEmptyAndIsA(this.commKeithley6482Wafer, 'keithley.Keithley6482')
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
            
            
            
            
            if this.notEmptyAndIsA(this.commWagoD141, 'bl12014.hardwareAssets.WagoD141')
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
                % error(getReport(mE));
                
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
            
            if this.notEmptyAndIsA(this.commExitSlit, 'bl12pico_slits')
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
                % error('Problem attaching to pico server');
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
            

            
            if this.notEmptyAndIsA(this.commKeithley6482Reticle, 'keithley.Keithley6482')
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
            
            if this.notEmptyAndIsA(this.commGalilD142, 'cxro.common.device.motion.Stage') && ...
               this.commGalilD142.isConnected()
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
            
            if this.notEmptyAndIsA(this.commGalilM143, 'cxro.common.device.motion.Stage') && ...
               this.commGalilM143.isConnected()
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
        

        %% GalilM1
        function l = getIsConnectedGalilM1(this)
            if ~isempty(this.commGalilM1)
                l = true;
            else
                l = false;
            end
        end

        function connectGalilM1(this)
            if this.getIsConnectedGalilM1()
                return
            end

            try
                this.commGalilM1 = galilTCP.GalilTCP2Ch(...
                    'cTcpipHost', this.cTcpipGalilM1, ...
                    'u16TcpipPort', this.dPortGalilM1, ...
                    'axes', [2, 3, 4]...
                );
            catch mE
                this.commGalilM1 = [];
                error('Cannot connect to galil');
            end
        end

        function disconnectGalilM1(this)
            if this.getIsConnectedGalilM1()
                this.commGalilM1 = [];
            end
        end

        function comm = getGalilM1(this)
            if this.getIsConnectedGalilM1()
                comm = this.commGalilM1;
            else
                comm = this.commGalilM1Virtual;
            end
        end
        
        
        %% GalilM143
        
        function l = getIsConnectedGalilVis(this)
            
            if this.notEmptyAndIsA(this.commGalilVis, 'cxro.common.device.motion.Stage') && ...
               this.commGalilVis.isConnected()
                l = true;
            else
                l = false;
            end
        end
        
        function disconnectGalilVis(this)
            if this.getIsConnectedGalilVis()
                
                this.commGalilVisFiltered = [];
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
                
                % 2019.09.04 wrap with StageFilter middleware to return 
                % averages of previous values.
                this.commGalilVisFiltered = bl12014.middleware.StageFilter(...
                    'stage', this.commGalilVis, ...
                    'dSizeOfFilter', 3 ...
                );
                
                
            catch mE
                this.commGalilVis = [];
                this.msg(mE.msgtext, this.u8_MSG_TYPE_ERROR);
               
            end
            
        end
        
        
        
        
        
        function comm = getGalilVis(this)
            
            if this.getIsConnectedGalilVis()
                % comm = this.commGalilVis;
                comm = this.commGalilVisFiltered;
                return
            end
                
            comm = this.commGalilVisVirtual;
                
        end
        
        %% MDM SR570 1
        
        function l = getIsConnectedSR570MDM(this)
            l = this.notEmptyAndIsA(this.commSR570MDM, 'srs.SR570');
        end
        
        function disconnectSR570MDM(this)
            if this.getIsConnectedSR570MDM()
                this.commSR570MDM = [];
            end
        end
        
        
        function connectSR570MDM(this)
            
            if this.getIsConnectedSR570MDM()
                return
            end

            try
                this.commSR570MDM = srs.SR570(...
                    'cConnection', AsciiComm.cCONNECTION_TCPCLIENT, ...
                    'cTcpipHost', '192.168.20.37' ...
                );
            catch mE
                this.commSR570MDM = [];
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
            end
            
        end
        
        function comm = getSR570MDM(this)
            
            if this.getIsConnectedSR570MDM()
                comm = this.commSR570MDM;
                return
            end
                
            comm = this.commSR570MDMVirtual;
                
        end
        
        %% DCT SR570 1
        
        function l = getIsConnectedSR570DCT1(this)
            l = this.notEmptyAndIsA(this.commSR570DCT1, 'srs.SR570');
        end
        
        function disconnectSR570DCT1(this)
            if this.getIsConnectedSR570DCT1()
                this.commSR570DCT1 = [];
            end
        end
        
        
        function connectSR570DCT1(this)
            
            if this.getIsConnectedSR570DCT1()
                return
            end

            try
                this.commSR570DCT1 = srs.SR570(); % FIX ME SET THE PORT
            catch mE
                this.commSR570DCT1 = [];
                this.msg(mE.msgtext, this.u8_MSG_TYPE_ERROR);
            end
            
        end
        
        function comm = getSR570DCT1(this)
            
            if this.getIsConnectedSR570DCT1()
                comm = this.commSR570DCT1;
                return
            end
                
            comm = this.commSR570DCT1Virtual;
                
        end
        
        
        %% DCT SR570 2
        
        function l = getIsConnectedSR570DCT2(this)
            l = this.notEmptyAndIsA(this.commSR570DCT2, 'srs.SR570');
        end
        
        function disconnectSR570DCT2(this)
            if this.getIsConnectedSR570DCT2()
                this.commSR570DCT2 = [];
            end
        end
        
        
        function connectSR570DCT2(this)
            
            if this.getIsConnectedSR570DCT2()
                return
            end

            try
                this.commSR570DCT2 = srs.SR570(); % FIX ME SET THE PORT
            catch mE
                this.commSR570DCT2 = [];
                this.msg(mE.msgtext, this.u8_MSG_TYPE_ERROR);
            end
            
        end
        
        function comm = getSR570DCT2(this)
            
            if this.getIsConnectedSR570DCT2()
                comm = this.commSR570DCT2;
                return
            end
                
            comm = this.commSR570DCT2Virtual;
                
        end
        
        
        %% EUV Tech SMS
        
        function l = getIsConnectedSMS(this)
            l = this.notEmptyAndIsA(this.commSMS, 'euvtech.SMS');
        end
        
        function disconnectSMS(this)
            if this.getIsConnectedSMS()
                this.commSMS = [];
            end
        end
        
        
        function connectSMS(this)
            
            if this.getIsConnectedSMS()
                return
            end

            try
                this.commSMS = euvtech.SMS(...
                    'cHost', this.cTcpipSMS ...
                ); % FIX ME SET THE PORT
            catch mE
                this.commSMS = [];
                this.msg(mE.msgtext, this.u8_MSG_TYPE_ERROR);
            end
            
        end
        
        function comm = getSMS(this)
            
            if this.getIsConnectedSMS()
                comm = this.commSMS;
                return
            end
                
            comm = this.commSMSVirtual;
                
        end
        
        
        %% DCT Wafer Stage
        
        
        function l = getIsConnectedDCTWaferStage(this)
            l = this.notEmptyAndIsA(this.commDCTWaferStage, 'aerotech.Ensemble');
        end
        
        function disconnectDCTWaferStage(this)
            if this.getIsConnectedDCTWaferStage()
                
                this.commDCTWaferStage.disconnect();
                this.commDCTWaferStage = [];
            end
        end
        
        
        function connectDCTWaferStage(this)
            
            if this.getIsConnectedDCTWaferStage()
                return
            end

            try
                this.commDCTWaferStage = aerotech.Ensemble();
                
            catch mE
                this.commDCTWaferStage = [];
                this.msg(mE.msgtext, this.u8_MSG_TYPE_ERROR);
               
            end
            
        end
        
        function comm = getDCTWaferStage(this)
            
            if this.getIsConnectedDCTWaferStage()
                comm = this.commDCTWaferStage;
                return
            end
                
            comm = this.commDCTWaferStageVirtual;
                
        end
        
        
        %% DCT Aperture Stage
        
        
        function l = getIsConnectedDCTApertureStage(this)
            
            if this.notEmptyAndIsA(this.commDCTApertureStage, 'smaract.MCS2') && ...
               this.commDCTApertureStage.getIsConnected()
                l = true;
            else
                l = false;
            end
        end
        
        function disconnectDCTApertureStage(this)
            if this.getIsConnectedDCTApertureStage()
                
                this.commDCTApertureStage.disconnect();
                this.commDCTApertureStage = [];
            end
        end
        
        
        function connectDCTApertureStage(this)
            
            if this.getIsConnectedDCTApertureStage()
                return
            end

            try
             
                cDeviceLocation = this.cSNSM_MCS2_DCT;
                this.commDCTApertureStage = smaract.MCS2();
                this.commDCTApertureStage.connect(cDeviceLocation);
                
            catch mE
                this.commDCTApertureStage = [];
                this.msg(mE.msgtext, this.u8_MSG_TYPE_ERROR);
               
            end
            
        end
        
        function comm = getDCTApertureStage(this)
            
            if this.getIsConnectedDCTApertureStage()
                comm = this.commDCTApertureStage;
                return
            end
                
            comm = this.commDCTApertureStageVirtual;
                
        end
        
        
        %% NPoint (MA)
        
        function l = getIsConnectedNPointMA(this)
            
            if this.notEmptyAndIsA(this.commNPointMA, 'npoint.LC400')
                l = true;
            else
                l = false;
            end
        end
        
        function disconnectNPointMA(this)
            if this.getIsConnectedNPointMA()
                this.commNPointMA.delete();
            end
            
            this.commNPointMA = [];
        end
        
        function connectNPointMA(this)
            this.commNPointMA = npoint.LC400(...
                'cConnection', npoint.LC400.cCONNECTION_TCPCLIENT, ...
                'cTcpipHost', this.cTcpipLc400MA, ...
                'u16TcpipPort', 23 ...
            );
        end
        
        function comm = getNPointMA(this)
            
            if this.getIsConnectedNPointMA()
                comm = this.commNPointMA;
                return
            end
                
            comm = this.commNPointMAVirtual;
                
        end
        
        
        %% NPoint (M142)
        
        function l = getIsConnectedNPointM142(this)
            
            if this.notEmptyAndIsA(this.commNPointM142, 'npoint.LC400')
                l = true;
            else
                l = false;
            end
        end
        
        function disconnectNPointM142(this)
            if this.getIsConnectedNPointM142()
                this.commNPointM142.delete();
            end
            
            this.commNPointM142 = [];
        end
        
        function connectNPointM142(this)
            this.commNPointM142 = npoint.LC400(...
                'cConnection', npoint.LC400.cCONNECTION_TCPCLIENT, ...
                'cTcpipHost', this.cTcpipLc400M142, ...
                'u16TcpipPort', 23 ...
            );
        end
        
        function comm = getNPointM142(this)
            
            if this.getIsConnectedNPointM142()
                comm = this.commNPointM142;
                return
            end
                
            comm = this.commNPointM142Virtual;
                
        end
        
        %% MfDriftMonitorMiddleware 
        % This is a layer on top of MfDriftMonitor that is exposed
        % from met5instruments in java that has a 
        % different interface
        
        function l = getIsConnectedMfDriftMonitorMiddleware(this)
            
            if this.notEmptyAndIsA(this.commMfDriftMonitorMiddleware, 'bl12014.hardwareAssets.middleware.MFDriftMonitor')
                l = true;
            else
                l = false;
            end
        end
        
        function connectMfDriftMonitorMiddleware(this)
           % this.getMfDriftMonitorMiddleware().connect();
           
           this.connectMfDriftMonitor(); % Needs to be real
           comm = this.getMfDriftMonitor();
           this.commMfDriftMonitorMiddleware     = bl12014.hardwareAssets.middleware.MFDriftMonitor(...
                'commMFDriftMonitor', comm, ...
                 'clock', this.clock ...
           );
            this.commMfDriftMonitorMiddleware.connect();
           
        end
        
        function disconnectMfDriftMonitorMiddleware(this)
            
            
            if this.getIsConnectedMfDriftMonitorMiddleware
                this.getMfDriftMonitorMiddleware().disconnect();
           end
           
           % Put disconnect code here
           
           
           this.commMfDriftMonitorMiddleware = [];
        end
                
        function comm = getMfDriftMonitorMiddleware(this)
            
            if this.getIsConnectedMfDriftMonitorMiddleware()
                comm = this.commMfDriftMonitorMiddleware;
            else
                 comm = this.commMfDriftMonitorMiddlewareVirtual;
            end

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
                fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v5'), ...
                fullfile(cDirVendor, 'cnanderson'), ...
                fullfile(cDirVendor, 'fileexchange', 'ssh2_v2_m1_r7'), ... % needed by cxro.DoseMonitor
            };
        
             mic.Utils.map(...
                ceGenpathLoad, ...
                @(cVPath) addpath(genpath(cVPath))...
             );
        
            cePathLoad = {};
            mic.Utils.map(...
                cePathLoad, ...
                @(cVPath) addpath(cVPath));

            cDirMpm = fullfile(cDirThis, '..', '..', 'mpm-packages');
            cDirMpm = mic.Utils.path2canonical(cDirMpm);
            
            
            
            % Java
            ceJavaPathLoad = { ...
                ... SSH2 I have found doing it explicitly here rather than relying on
                ... the auto-include capability of the ssh2_v2_m1_r7 library, works better
                fullfile(cDirVendor, 'fileexchange', 'ssh2_v2_m1_r7', 'ganymed-ssh2-m1', 'ganymed-ssh2-m1.jar'), ...
                ... ALS Channel Access
                fullfile(cDirMpm, 'matlab-cxro-als', 'src', 'ca_matlab-1.0.0.jar'), ...
                fullfile(cDirVendor, 'cwcork', 'Met5Instruments_V2.2.0.jar'), ...
                ... BL 12.0.1 Exit Slit
                fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v5', 'BL12PICOCorbaProxy.jar'), ...
                ... BL 12.0.1 Undulator, mono grating angle.  Does not have methods for shutter
                fullfile(cDirVendor, 'cwcork', 'bl1201', 'jar_jdk6', 'BL1201CorbaProxy.jar'), ...
                ... BL 12.0.1 Shutter
                fullfile(cDirVendor, 'cwcork', 'bl1201', 'jar_jdk6', 'DctCorbaProxy.jar'), ...
                ... Java SSH2 Communication With DeltaTau Power PMAC Motion Controller (uses JSch)
                ... needed by github/cnanders/matlab-deltatau-ppmac-met5
                fullfile(cDirVendor, 'cnanderson', 'deltatau-power-pmac-comm-8192buffer-jre1.7.jar'), ...
                ... Java utility to check if a network device (host + port) is reachable
                ... Used by GetLogicalPing
                fullfile(cDirVendor, 'cnanderson', 'network-device-jre1.7.jar'), ...
            };

            mic.Utils.map(...
                ceJavaPathLoad, ...
                @(cPath) this.addJavaPathIfNecessary(cPath), ...
                0);
            
            
            this.commDoseMonitorVirtual = cxro.DoseMonitorVirtual();
            this.commRigolDG1000ZVirtual = rigol.DG1000ZVirtual();
            this.commTekAFG31021Virtual = tektronix.AFG31021Virtual();
            this.commKeithley6482WaferVirtual = keithley.Keithley6482Virtual();
            this.commKeithley6482ReticleVirtual = keithley.Keithley6482Virtual();
            this.commDeltaTauPowerPmacVirtual = deltatau.PowerPmacVirtual();
            this.commHydraWaferVirtual = pi.HydraVirtual();
            this.commDataTranslationVirtual = datatranslation.MeasurPointVirtual();
            this.commMfDriftMonitorVirtual = bl12014.hardwareAssets.virtual.MFDriftMonitor();
            this.commMfDriftMonitorMiddlewareVirtual = bl12014.hardwareAssets.virtual.MFDriftMonitorMiddleware(...
                'clock', this.clock ...
            );
            this.commWebSwitchBeamlineVirtual = controlbyweb.WebSwitchVirtual();
            this.commWebSwitchEndstationVirtual = controlbyweb.WebSwitchVirtual();
            this.commWebSwitchVisVirtual = controlbyweb.WebSwitchVirtual();
            this.commBL1201CorbaProxyVirtual = bl12014.hardwareAssets.virtual.BL1201CorbaProxy();
            this.commDCTCorbaProxyVirtual = bl12014.hardwareAssets.virtual.DCTCorbaProxy();
            this.commSmarActM141Virtual = bl12014.hardwareAssets.virtual.Stage();
            % this.commSmarActVPFMVirtual = bl12014.hardwareAssets.virtual.Stage();
            this.commSmarActVPFMVirtual = smaract.MCSVirtual();
            this.commWagoD141Virtual = bl12014.hardwareAssets.virtual.WagoD141();
            this.commExitSlitVirtual = bl12014.hardwareAssets.virtual.BL12PicoExitSlit();
            this.commGalilD142Virtual = bl12014.hardwareAssets.virtual.Stage();
            this.commGalilM143Virtual = bl12014.hardwareAssets.virtual.Stage();
            this.commGalilVisVirtual = bl12014.hardwareAssets.virtual.Stage();

            this.commGalilM1Virtual = bl12014.hardwareAssets.virtual.Stage();
            
            
            this.commDCTWaferStageVirtual = aerotech.EnsembleVirtual(); % bl12014.hardwareAssets.virtual.Stage();
            this.commDCTApertureStageVirtual = smaract.MCS2Virtual();
            
            this.commSR570DCT1Virtual = srs.SR570Virtual();
            this.commSR570DCT2Virtual = srs.SR570Virtual();
            
            this.commSMSVirtual = euvtech.SMSVirtual();
            
            this.commSR570MDMVirtual = srs.SR570Virtual();

            this.commMightex1Virtual = mightex.UniversalLedControllerVirtual();
            this.commMightex2Virtual = mightex.UniversalLedControllerVirtual();
            
            this.commNPointM142Virtual = npoint.LC400Virtual();
            this.commNPointMAVirtual = npoint.LC400Virtual();
            
            this.commALSVirtual = cxro.ALSVirtual();
            
            this.commNewFocus8742M142Virtual = newfocus.Model8742Virtual();
            this.commNewFocus8742MAVirtual = newfocus.Model8742Virtual();

            this.commIrisVirtual = bl12014.hardwareAssets.virtual.ModbusIris();
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