classdef App < mic.Base
        
    properties (Constant)
        dWidth = 500
        dHeight = 500
        
        dWidthButton = 150
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
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        hFigure
        
        uiApp
        uiComm
        
        lConnectedToCommNewFocusModel8742 = false
        lConnectedToCommSmarActMcsM141 = false
        lConnectedToCommSmarActMcsGoni = false
        lConnectedToCommMicronixMmc103 = false
        lConnectedToCommDeltaTauPowerPmac = false
        lConnectedToCommDataTranslationMeasurPoint = false
        lConnectedToCommKeithley6482Reticle = false
        lConnectedToCommKeithley6482Wafer = false
        lConnectedToCommCxroHeightSensor = false
        lConnectedToCommCxroBeamline = false
        lConnectedToCommNPointLC400Field = false
        lConnectedToCommNPointLC400Pupil = false

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
            this.uiComm.build(this.hFigure, 210, 10);
        end
        
        %% Destructor
        
        function delete(this)
            delete(this.uiApp)
            this.destroyComm()
        end         

    end
    
    methods (Access = private)
        
        
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
        
        
        function init(this)
            
            this.uiApp = bl12014.ui.App(...
                'dWidthButtonButtonList', this.dWidthButton ...
            ); 
            this.initUiComm();

            % this.initComm()
            % this.loadStateFromDisk();

        end
        

        function initCommMet5Instruments(this)
           
            return
            
            if isempty(this.jMet5Instruments)
                this.jMet5Instruments = cxro.met5.Instruments();
            end
        end
        
        %{
        function l = connectWago(this)
            
            l = true;
            return;
            
            if this.lConnectedToCommWago
                this.showMsgConnected('commWago');
                return
            end 
            
            
            try
                this.commWago = wago.Wago()
            catch mE
                l = false;
                return
            end
            
            bl12014.Connect.connectCommWagoToUiD141(this.commWago, this.uiApp.uiD141)
            this.lConnectedToCommWago = true;
            
        end
        %}
                
        function l = connectCommSmarActMcsM141(this)
            
            l = true;
            return
            
            if this.lConnectedToCommSmarActMcsM141
                this.showMsgConnected('commSmarActMcsM141');
                return
            end
            
            try
                this.initCommMet5Instruments();
                this.commSmarActMcsM141 = this.jMet5Instruments.getM141Stage()
            catch mE
                l = false;
                return
            end
            
            bl12014.Connect.connectCommSmarActMcsM141ToUiM141(this.commSmarActMcsM141, this.uiApp.uiM141)
            this.lConnectedToCommSmarActMcsM141 = true;
        end
        
        function l = connectCommSmarActMcsGoni(this)
            
            l = true;
            return
            
            if this.lConnectedToCommSmarActMcsGoni
                this.showMsgConnected('commSmarActMcsGoni');
                return
            end
            
            try
                this.initCommMet5Instruments();
                this.commSmarActMcsGoni = this.jMet5Instruments.getLsiGoniometer()
            catch mE
                l = false;
                return
            end
            
            bl12014.Connect.connectCommSmarActMcsGoniToUiInterferometry(this.commSmarActMcsGoni, this.uiApp.uiInterferometry)
            this.lConnectedToCommSmarActMcsGoni = true;
        end
        
        function l = connectCommSmarActSmarPod(this)
            
            l = true;
            return
            
            if this.lConnectedToCommSmarActSmarPod
                this.showMsgConnected('commSmarActSmarPod');
                return
            end
            
            try
                this.initCommMet5Instruments();
                this.commSmarActSmarPod = this.jMet5Instruments.getLsiHexapod()
            catch mE
                l = false;
                return
            end
            
            bl12014.Connect.connectCommSmarActSmarPodToUiInterferometry(this.commSmarActSmarPod, this.uiApp.uiInterferometry)
            this.lConnectedToCommSmarActSmarPod = true;
        end
        
        
        function l = connectCommDataTranslationMeasurPoint(this)
            
            l = true;
            return
            
            if this.lConnectedToCommDataTranslationMeasurPoint
                this.showMsgConnected('commDataTranslationMeasurPoint');
                return
            end
                        
            try
                this.commDataTranslationMeasurPoint = dataTranslation.MeasurPoint();
            catch mE
                l = false;
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
            
            
            this.lConnectedToCommDataTranslationMeasurPoint = true;
        end
        
        function l = connectCommDeltaTauPowerPmac(this)
            
            l = true;
            return
            
            if this.lConnectedToCommDeltaTauPowerPmac
                this.showMsgConnected('commDeltaTauPowerPmac');
                return
            end
            
            try
                this.commDeltaTauPowerPmac = deltaTau.powerPmac.PowerPmac();
            catch mE
                l = false;
                return
            end
            
            bl12014.Connect.connectCommDeltaTauPowerPmacToUiReticle(this.commDeltaTauPowerPmac, this.uiApp.uiReticle);
            bl12014.Connect.connectCommDeltaTauPowerPmacToUiWafer(this.commDeltaTauPowerPmac, this.uiApp.uiWafer);
            
            this.lConnectedToCommDeltaTauPowerPmac = true;
            
        end
        
        function l = connectCommKeithley6482Wafer(this)
            
            l = true;
            return
            
            if this.lConnectedToCommKeithley6482Wafer
                this.showMsgConnected('commKeityley6482Wafer');
                return
            end
            
            try
                this.commKeithley6482Wafer = keithley.keithley6482.Keithley6482();
            catch mE
                l = false;
                return
            end
            
            bl12014.Connect.connectCommKeithley6482WaferToUiWafer(this.commKeithley6482Wafer, this.uiApp.uiWafer);
            
            this.lConnectedToCommKeithley6482Wafer = true;
        end
        
        
        function l = connectCommKeithley6482Reticle(this)
            
            l = true;
            return
            
            if this.lConnectedToCommKeithley6482Reticle
                this.showMsgConnected('commKeityley6482Reticle');
                return
            end
               
            try
                this.commKeithley6482Reticle = keithley.Keithley6482();
                % DO INITIAL CONNECTION
            catch mE
                l = false;
                return
            end
            
            bl12014.Connect.connectCommKeithley6482ReticleToUiReticle(this.commKeithley6482Reticle, this.uiApp.uiReticle);
            
            this.lConnectedToCommKeithley6482Reticle = true;
            
        end
        
        function l = connectCommCxroHeightSensor(this)
            
            l = true;
            return
            
            if this.lConnectedToCommCxroHeightSensor
                this.showMsgConnected('commCxroHeightSensor');
                return
            end
               
            try
                this.commCxroHeightSensor = cxro.met5.HeightSensor();
            catch mE
                l = false;
                return
            end
            
            bl12014.Connect.connectCommCxroHeightSensorToUiWafer(this.commCxroHeightSensor, this.uiApp.uiWafer);
            
            this.lConnectedToCommCxroHeightSensor = true;
            
        end
        
        function l = connectCommCxroBeamline(this)
            
            l = true;
            return
            
            if this.lConnectedToCommCxroBeamline
                this.showMsgConnected('commCxroBeamline');
                return
            end
            
            try
                this.commCxroBeamline = cxro.bl1201.Beamline();
            catch mE
                l = false;
                return;
            end
            
            bl12014.Connect.connectCommCxroBeamlineToUiBeamline(this.commCxroBeamline, this.uiApp.uiBeamline);
            
            this.lConnectedToCommCxroBeamline = true;
            
        end
        
        function l = connectCommNewFocusModel8742(this)
            
            %l = true;
            %return
            
            if this.lConnectedToCommNewFocusModel8742
                this.showMsgConnected('commNewFocusModel8742');
                return
            end
            
            try
                this.commNewFocusModel8742 = newfocus.Model8742( ...
                    'cTcpipHost', '192.168.0.3' ...
                );
                this.commNewFocusModel8742.init();
                this.commNewFocusModel8742.connect();
            catch mE
                l = false;
                rethrow(mE)
                return;
            end
            
            bl12014.Connect.connectCommNewFocusModel8742ToUiM142(this.commNewFocusModel8742, this.uiApp.uiM142);
            this.lConnectedToCommNewFocusModel8742 = true;
            l = true;
            
        end
        
        function l = connectCommMicronixMmc103(this)
            
            %{
            l = true;
            return
            %}
            
            if this.lConnectedToCommMicronixMmc103
                this.showMsgConnected('commMicronixMmc103');
                return
            end
            
            try
                this.commMicronixMmc103 = micronix.MMC103(...
                    'cConnection', micronix.MMC103.cCONNECTION_TCPIP, ...
                    'cTcpipHost', '192.168.0.2' ...
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
            
                l = false;
                return;
            end
            
            bl12014.Connect.connectCommMicronixMmc103ToUiM142(this.commMicronixMmc103, this.uiApp.uiM142);
            this.lConnectedToCommMicronixMmc103 = true;
            l = true;
            
        end
        
        
        function l = connectCommNPointLC400Pupil(this)
            
            l = true;
            return
            
            if this.lConnectedToCommNPointLC400Pupil
                this.showMsgConnected('commNPointLC400Pupil');
                return
            end
            
            try
                this.commNPointLC400Pupil = npoint.LC400();
            catch mE
                l = false;
                return;
            end
            
            bl12014.Connect.connectCommNPointLC400PupilToUiPupilScanner(this.commNPointLC400Pupil, this.uiApp.uiPupilScanner);
            
            this.lConnectedToCommNPointLC400Pupil = true;
            
        end
        
        function l = connectCommNPointLC400Field(this)
            
            l = true;
            return
            
            if this.lConnectedToCommNPointLC400Field
                this.showMsgConnected('commNPointLC400Field');
                return
            end
            
            try
                this.commNPointLC400Field = npoint.LC400();
            catch mE
                l = false;
                return;
            end
            
            bl12014.Connect.connectCommNPointLC400FieldToUiFieldScanner(this.commNPointLC400Field, this.uiApp.uiFieldScanner);
            
            this.lConnectedToCommNPointLC400Field = true;
            
        end
        
               
        
        function destroyComm(this)
            if this.lConnectedToCommMicronixMmc103
                this.commMicronixMmc103.disconnect();
            end
            
        end
        
        function showMsgConnected(this, cMsg)
            
        end
        
        function showMsgError(this, cMsg)
            
        end
        
        function onCloseRequestFcn(this, src, evt)
            this.msg('closeRequestFcn()');
            % purge;
            delete(this.hFigure);
            % this.saveState();
         end
        

    end % private
    
    
end