classdef Comm < mic.Base
        
    % Single class to hold references to all hardware communication class
    % instances / wrappers
    
    properties (Constant)
        
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
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        hFigure
        
        uiApp
        uiComm
        
        

    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = Comm()
            this.init();
        end
        
        %% Destructor
        
        function delete(this)
            delete(this.uiApp)
            
            this.destroyCommCxroBeamline();
            this.destroyCommCxroHeightSensor();
            this.destroyCommDataTranslationMeasurPoint();
            this.destroyCommDeltaTauPowerPmac();
            this.destroyCommKeithley6482Reticle();
            this.destroyCommKeithley6482Wafer();
            this.destroyCommMicronixMmc103();
            this.destroyCommNewFocusModel8742();
            this.destroyCommNPointLC400Field();
            this.destroyCommNPointLC400Pupil();
            this.destroyCommSmarActMcsGoni();
            this.destroyCommSmarActMcsM141();
            this.destroyCommSmarActSmarPod();
            
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
        
        function l = getMicronixMmc103(this)
            l = ~isempty(this.commMicronixMmc103);
            
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
        
        
        % Init methods

        function initCommMet5Instruments(this)            
            if isempty(this.jMet5Instruments)
                this.jMet5Instruments = cxro.met5.Instruments();
            end
        end
        
        %{
        function initWago(this)
            
            l = true;
            return;
            
            if this.getWago
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
            this.getWago = true;
            
        end
        %}
                
        function initCommSmarActMcsM141(this)
                        
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
        
        
        function destroyCommSmarActMcsM141(this)
            
            bl12014.Connect.disconnectCommSmarActMcsM141ToUiM141(this.uiApp.uiM141);
            this.commSmarActMcsM141 = [];
        end
        
        
        function initCommSmarActMcsGoni(this)
            
            
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
        
        function destroyCommSmarActMcsGoni(this)
            bl12014.Connect.disconnectCommSmarActMcsGoniToUiInterferometry(this.uiApp.uiInterferometry)
            this.commSmarActMcsGoni = [];
        end
        
        
        
        function initCommSmarActSmarPod(this)
            

            if this.getSmarActSmarPod()
                this.showMsgConnected('commSmarActSmarPod');
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
        
        function destroyCommSmarActSmarPod(this)
            bl12014.Connect.disconnectCommSmarActSmarPodToUiInterferometry(this.uiApp.uiInterferometry)
            this.commSmarActSmarPod = [];
        end
        
        
        function initCommDataTranslationMeasurPoint(this)
            
            
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
        
        function destroyCommDataTranslationMeasurPoint(this)
            
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
            this.commDataTranslationMeasurPoint = [];
        end
        
        function initCommDeltaTauPowerPmac(this)
           
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
        
        function destroyCommDeltaTauPowerPmac(this)
           

            bl12014.Connect.disconnectCommDeltaTauPowerPmacToUiReticle(this.uiApp.uiReticle);
            bl12014.Connect.disconnectCommDeltaTauPowerPmacToUiWafer(this.uiApp.uiWafer);
            this.commDeltaTauPowerPmac = [];
            
        end
        
        function initCommKeithley6482Wafer(this)
            
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
        
        function destroyCommKeithley6482Wafer(this)
            
            bl12014.Connect.disconnectCommKeithley6482WaferToUiWafer(this.uiApp.uiWafer);
            this.commKeithley6482Wafer = [];
        end
        
        
        function initCommKeithley6482Reticle(this)
            
            
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
        
        function destroyCommKeithley6482Reticle(this)
            
                
            bl12014.Connect.disconnectCommKeithley6482ReticleToUiReticle(this.uiApp.uiReticle);
            this.commKeithley6482Reticle = [];
        end
        
        function initCommCxroHeightSensor(this)
            
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
        
        function destroyCommCxroHeightSensor(this)
            
            bl12014.Connect.disconnectCommCxroHeightSensorToUiWafer(this.uiApp.uiWafer);
            this.commCxroHeightSensor = [];
        end
        
        function initCommCxroBeamline(this)
            
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
        
        function destroyCommCxroBeamline(this)
            
            bl12014.Connect.disconnectCommCxroBeamlineToUiBeamline(this.uiApp.uiBeamline);
            this.commCxroBeamline = [];
        end
        
        function initCommNewFocusModel8742(this)
            

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
        
        function destroyCommNewFocusModel8742(this)
            

            if ~this.getNewFocusModel8742()
                return
            end
            
            
            bl12014.Connect.disconnectCommNewFocusModel8742ToUiM142(this.uiApp.uiM142);
            this.commNewFocusModel8742.delete();
            this.commNewFocusModel8742 = [];
                            
        end
        
        function initCommMicronixMmc103(this)
            
            
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
        
        function destroyCommMicronixMmc103(this)
            
            
            if ~this.getMicronixMmc103()
                return
            end
                            
            bl12014.Connect.disconnectCommMicronixMmc103ToUiM142(this.uiApp.uiM142);
            this.commMicronixMmc103.delete();
            this.commMicronixMmc103 = [];
            
        end
        
        
        function initCommNPointLC400Pupil(this)
            
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
        
        function destroyCommNPointLC400Pupil(this)
            
            if ~this.getNPointLC400Pupil()
                return
            end

            bl12014.Connect.disconnectCommNPointLC400PupilToUiPupilScanner(this.uiApp.uiPupilScanner);
            this.commNPointLC400Pupil.delete();
            this.commNPointLC400Pupil = [];
        end
        
        function initCommNPointLC400Field(this)
            

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
        
        function destroyCommNPointLC400Field(this)
            
            if ~this.getNPointLC400Field()
                return
            end
            
            bl12014.Connect.disconnectCommNPointLC400FieldToUiFieldScanner(this.uiApp.uiFieldScanner);
            this.commNPointLC400Field.delete();
            this.commNPointLC400Field = [];
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