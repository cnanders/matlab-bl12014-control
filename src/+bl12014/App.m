classdef App < mic.Base
        
    properties (Constant)
        
        dWidth = 150
        dHeight = 440
        
        dWidthButton = 110
        
        cTcpipHostMicronix = '192.168.0.2'
        cTcpipHostNewFocus = '192.168.0.3'
        
    end
    
	properties
        
        
        % {cxro.met5.Instruments 1x1}
        jMet5Instruments
        
        % {cxro.common.device.motion.Stage 1x1}
        commSmarActMcsM141
        
        % {cxro.common.device.motion.Stage 1x1}
        commSmarActMcsGoni
        
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
            bl12014.Connect.connectCommSmarActMcsM141ToUiM141(this.commSmarActMcsM141, this.uiApp.uiM141)
        end
        
        
        function destroyAndDisconnectSmarActMcsM141(this)
            
            bl12014.Connect.disconnectCommSmarActMcsM141ToUiM141(this.uiApp.uiM141);
            this.commSmarActMcsM141 = [];
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
            
            bl12014.Connect.connectCommSmarActMcsGoniToUiInterferometry(this.commSmarActMcsGoni, this.uiApp.uiInterferometry)
        end
        
        function destroyAndDisconnectSmarActMcsGoni(this)
            bl12014.Connect.disconnectCommSmarActMcsGoniToUiInterferometry(this.uiApp.uiInterferometry)
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
            
            bl12014.Connect.connectCommSmarActSmarPodToUiInterferometry(this.commSmarActSmarPod, this.uiApp.uiInterferometry)
        end
        
        function destroyAndDisconnectSmarActSmarPod(this)
            bl12014.Connect.disconnectCommSmarActSmarPodToUiInterferometry(this.uiApp.uiInterferometry)
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
            
            bl12014.Connect.connectCommDataTranslationMeasurPointToUiM141(this.commDataTranslationMeasurPoint, this.uiApp.uiM141)
            bl12014.Connect.connectCommDataTranslationMeasurPointToUiD141(this.commDataTranslationMeasurPoint, this.uiApp.uiD141);
            bl12014.Connect.connectCommDataTranslationMeasurPointToUiD142(this.commDataTranslationMeasurPoint, this.uiApp.uiD142);
            bl12014.Connect.connectCommDataTranslationMeasurPointToUiM143(this.commDataTranslationMeasurPoint, this.uiApp.uiM143);
            bl12014.Connect.connectCommDataTranslationMeasurPointToUiVis(this.commDataTranslationMeasurPoint, this.uiApp.uiVis);
            %bl12014.Connect.connectCommDataTranslationMeasurPointToUiMetrologyFrame(this.commDataTranslationMeasurPoint, this.uiApp.uiMetrologyFrame);
            %bl12014.Connect.connectCommDataTranslationMeasurPointToUiMod3(this.commDataTranslationMeasurPoint, this.uiApp.uiMod3);
            %bl12014.Connect.connectCommDataTranslationMeasurPointToUiPob(this.commDataTranslationMeasurPoint, this.uiApp.uiPob);
            bl12014.Connect.connectCommDataTranslationMeasurPointToUiReticle(this.commDataTranslationMeasurPoint, this.uiApp.uiReticle);
            bl12014.Connect.connectCommDataTranslationMeasurPointToUiWafer(this.commDataTranslationMeasurPoint, this.uiApp.uiWafer);
            bl12014.Connect.connectCommDataTranslationMeasurPointToUiTempSensors(this.commDataTranslationMeasurPoint, this.uiApp.uiTempSensors);
            
        end
        
        function destroyAndDisconnectDataTranslationMeasurPoint(this)
            
            bl12014.Connect.disconnectCommDataTranslationMeasurPointToUiM141(this.uiApp.uiM141)
            bl12014.Connect.disconnectCommDataTranslationMeasurPointToUiD141(this.uiApp.uiD141);
            bl12014.Connect.disconnectCommDataTranslationMeasurPointToUiD142(this.uiApp.uiD142);
            bl12014.Connect.disconnectCommDataTranslationMeasurPointToUiM143(this.uiApp.uiM143);
            bl12014.Connect.disconnectCommDataTranslationMeasurPointToUiVis(this.uiApp.uiVis);
            %bl12014.Connect.disconnectCommDataTranslationMeasurPointToUiMetrologyFrame(this.uiApp.uiMetrologyFrame);
            %bl12014.Connect.disconnectCommDataTranslationMeasurPointToUiMod3(this.uiApp.uiMod3);
            %bl12014.Connect.disconnectCommDataTranslationMeasurPointToUiPob(this.uiApp.uiPob);
            bl12014.Connect.disconnectCommDataTranslationMeasurPointToUiReticle(this.uiApp.uiReticle);
            bl12014.Connect.disconnectCommDataTranslationMeasurPointToUiWafer(this.uiApp.uiWafer);
            bl12014.Connect.disconnectCommDataTranslationMeasurPointToUiTempSensors(this.uiApp.uiTempSensors);
            
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
            
            bl12014.Connect.connectCommDeltaTauPowerPmacToUiReticle(this.commDeltaTauPowerPmac, this.uiApp.uiReticle);
            bl12014.Connect.connectCommDeltaTauPowerPmacToUiWafer(this.commDeltaTauPowerPmac, this.uiApp.uiWafer);
            
            
        end
        
        function destroyAndDisconnectDeltaTauPowerPmac(this)

            bl12014.Connect.disconnectCommDeltaTauPowerPmacToUiReticle(this.uiApp.uiReticle);
            bl12014.Connect.disconnectCommDeltaTauPowerPmacToUiWafer(this.uiApp.uiWafer);
            this.commDeltaTauPowerPmac.delete();
            this.commDeltaTauPowerPmac = [];
            
        end
        
        function initAndConnectKeithley6482Wafer(this)
            
            if this.getKeithley6482Wafer()
                return
            end
            
            try
                this.commKeithley6482Wafer = keithley.keithley6482.Keithley6482();
            catch mE
                this.commKeithley6482Wafer = [];
                return
            end
            
            bl12014.Connect.connectCommKeithley6482WaferToUiWafer(this.commKeithley6482Wafer, this.uiApp.uiWafer);

        end
        
        function destroyAndDisconnectKeithley6482Wafer(this)
            
            bl12014.Connect.disconnectCommKeithley6482WaferToUiWafer(this.uiApp.uiWafer);
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
            
            bl12014.Connect.connectCommKeithley6482ReticleToUiReticle(this.commKeithley6482Reticle, this.uiApp.uiReticle);
            
        end
        
        function destroyAndDisconnectKeithley6482Reticle(this)
            
                
            bl12014.Connect.disconnectCommKeithley6482ReticleToUiReticle(this.uiApp.uiReticle);
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
            
            bl12014.Connect.connectCommCxroHeightSensorToUiWafer(this.commCxroHeightSensor, this.uiApp.uiWafer);
            
        end
        
        function destroyAndDisconnectCxroHeightSensor(this)
            
            bl12014.Connect.disconnectCommCxroHeightSensorToUiWafer(this.uiApp.uiWafer);
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
            
            bl12014.Connect.connectCommCxroBeamlineToUiBeamline(this.commCxroBeamline, this.uiApp.uiBeamline);
                        
        end
        
        function destroyAndDisconnectCxroBeamline(this)
            
            bl12014.Connect.disconnectCommCxroBeamlineToUiBeamline(this.uiApp.uiBeamline);
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
            
            bl12014.Connect.connectCommNewFocusModel8742ToUiM142(this.commNewFocusModel8742, this.uiApp.uiM142);
            
        end
        
        function destroyAndDisconnectNewFocusModel8742(this)
            

            if ~this.getNewFocusModel8742()
                return
            end
            
            
            bl12014.Connect.disconnectCommNewFocusModel8742ToUiM142(this.uiApp.uiM142);
            this.commNewFocusModel8742.delete();
            this.commNewFocusModel8742 = [];
                            
        end
        
        
        function initAndConnectGalilD142(this)
            if this.getGalilD142()
                return
            end
        end
        
        function destroyAndDisconnectGalilD142(this)
            if ~this.getGalilD142()
                return
            end
            
        end
        
        function initAndConnectGalilM143(this)
            if this.getGalilM143()
                return
            end
        end
        
        function destroyAndDisconnectGalilM143(this)
            if ~this.getGalilM143()
                return
            end
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
            
            bl12014.Connect.connectCommMicronixMmc103ToUiM142(this.commMicronixMmc103, this.uiApp.uiM142);
            
        end
        
        function destroyAndDisconnectMicronixMmc103(this)
            
            
            if ~this.getMicronixMmc103()
                return
            end
                            
            bl12014.Connect.disconnectCommMicronixMmc103ToUiM142(this.uiApp.uiM142);
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
            
            bl12014.Connect.connectCommNPointLC400PupilToUiPupilScanner(this.commNPointLC400Pupil, this.uiApp.uiPupilScanner);
            
        end
        
        function destroyAndDisconnectNPointLC400Pupil(this)
            
            if ~this.getNPointLC400Pupil()
                return
            end

            bl12014.Connect.disconnectCommNPointLC400PupilToUiPupilScanner(this.uiApp.uiPupilScanner);
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
            
            bl12014.Connect.connectCommNPointLC400FieldToUiFieldScanner(this.commNPointLC400Field, this.uiApp.uiFieldScanner);
            
        end
        
        function destroyAndDisconnectNPointLC400Field(this)
            
            if ~this.getNPointLC400Field()
                return
            end
            
            bl12014.Connect.disconnectCommNPointLC400FieldToUiFieldScanner(this.uiApp.uiFieldScanner);
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