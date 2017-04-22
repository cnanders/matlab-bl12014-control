classdef App < mic.Base
        
    properties (Constant)
       
    end
    
	properties
        
        uiApp
        
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                 
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
        
        % {newFocus.NewFocus8742 1x1} 
        % May cheat and use DLL directly with {mic.interface.device.*}
        % M142 + M142R common tiltX (pitch)
        % M142 independent tiltY  (roll)
        % M142R independent tiltY (roll)
        commNewFocus8742
        
        % {micronix.Mmc103 1x1}
        % M142R tiltZ (clocking)
        % M142 + M142R common x
        commMicronixMmc103
        
        lConnectedToCommNewFocus8742 = false
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
            this.uiApp.build();
        end
        
        %% Destructor
        
        function delete(this)
            delete(this.uiApp)
            this.destroyComm()
        end         

    end
    
    methods (Access = private)
        
        
        
        function init(this)
            
            this.uiApp = bl12014.ui.App(); 
            
            
            st = struct;
            
            st(1).cLabel = 'CXRO Beamline';
            st(1).fhOnClick = @this.connectCommCxroBeamline;
            st(1).cTooltip = 'Mono grating TiltX, Exit Slit, shutter';
            
            st(2).cLabel = 'CXRO Height Sensor';
            st(2).fhOnClick = @this.connectCommCxroHeightSensor;
            st(2).cTooltip = 'Wafer Z + TiltX + TiltY';
            
            st(3).cLabel = 'Data Translation MeasurPoint';
            st(3).fhOnClick = @this.connectCommDataTranslationMeasurPoint;
            st(3).cTooltip = 'M141 diode, D141 diode, D142 diode, M143 diode, Vis RTDs, Metrology Frame RTDs, Mod3 RTDs, POB RDTs';
            
            st(4).cLabel = 'SmarAct MCS (M141)';
            st(4).fhOnClick = @this.connectCommSmarActMcsM141;
            st(4).cTooltip = 'M141 Stage';
            
            st(5).cLabel = 'SmarAct MCS (Goni)';
            st(5).fhOnClick = @this.connectCommSmarActMcsGoni;
            st(5).cTooltip = 'Interferometry Goniometer';
            
            st(6).cLabel =  'Micronix MMC-103';
            st(6).fhOnClick = @this.connectCommMicronixMmc103;
            st(6).cTooltip = 'M142 + M142R common x, M142R tiltZ';
            
            st(7).cLabel =  'New Focus 8742';
            st(7).fhOnClick = @this.connectCommNewFocus8742;
            st(7).cTooltip = 'M142 + M142R common tiltX, M142 tiltY, M142R tiltY';
            
            st(8).cLabel =  'nPoint LC.403 (Field)';
            st(8).fhOnClick = @this.connectCommNPointLC400Field;
            st(8).cTooltip = 'M142 Field Scan';
            
            st(9).cLabel = 'nPoint LC.403 (Pupil)';
            st(9).fhOnClick = @this.connectCommNPointLC400Pupil;
            st(9).cTooltip = 'MA Pupil Scan';
            
            st(10).cLabel =  'Delta Tau PowerPMAC';
            st(10).fhOnClick = @this.connectCommDeltaTauPowerPmac;
            st(10).cTooltip = 'Reticle Stage, Reticle RTDs, Wafer Stage, Wafer RTDs';
            
            st(11).cLabel = 'Keithley6482 (Reticle)';
            st(11).fhOnClick = @this.connectCommKeithley6482Reticle;
            st(11).cTooltip = 'Reticle Diode';
            
            st(12).cLabel = 'Keithley6482 (Wafer)';
            st(12).fhOnClick = @this.connectCommKeithley6482Wafer;
            st(12).cTooltip = 'Wafer Diode (Dose), Wafer Diode (Focus)';
            
            st(13).cLabel =  'SmarAct SmarPod';
            st(13).fhOnClick = @this.connectCommSmarActSmarPod;
            st(13).cTooltip = 'Interferometry Hexapod';
            
            this.uiComm = bl12014.ui.Comm(...
                'stButtonDefinitions', st ...
            );

            % this.initComm()
            % this.loadStateFromDisk();

        end
        
        function initCommMet5Instruments(this)
           
            return
            
            if isempty(this.jMet5Instruments)
                this.jMet5Instruments = cxro.met5.Instruments();
            end
        end
        
                
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
            
            Connect.connectUiM141ToCommSmarActMcsM141(this.uiApp.uiM141, this.commSmarActMcsM141)
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
                this.commSmarActMcsGoni = this.jMet5Instruments.getGoniStage()
            catch mE
                l = false;
                return
            end
            
            Connect.connectUiInterferometryToCommSmarActMcsGoni(this.uiApp.uiInterferometry, this.commSmarActMcsGoni)
            this.lConnectedToCommSmarActMcsGoni = true;
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
            
            Connect.connectUiM141ToCommDataTranslationMeasurPoint(this.uiApp.uiM141, this.commDataTranslationMeasurPoint)
            Connect.connectUiD141ToCommDataTranslationMeasurPoint(this.uiApp.uiD141, this.commDataTranslationMeasurPoint);
            Connect.connectUiD142ToCommDataTranslationMeasurPoint(this.uiApp.uiD142, this.commDataTranslationMeasurPoint);
            Connect.connectUiM143ToCommDataTranslationMeasurPoint(this.uiApp.uiM143, this.commDataTranslationMeasurPoint);
            Connect.connectUiVisToCommDataTranslationMeasurPoint(this.uiApp.uiVis, this.commDataTranslationMeasurPoint);
            Connect.connectUiMetrologyFrameToCommDataTranslationMeasurPoint(this.uiApp.uiMetrologyFrame, this.commDataTranslationMeasurPoint);
            Connect.connectUiMod3ToCommDataTranslationMeasurPoint(this.uiApp.uiMod3, this.commDataTranslationMeasurPoint);
            Connect.connectUiPobToCommDataTranslationMeasurPoint(this.uiApp.uiPob, this.commDataTranslationMeasurPoint);
            
            this.lConnectedToCommDataTranslationMeasurPoint = true;
        end
        
        function l = connectcommDeltaTauPowerPmac(this)
            
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
            
            Connect.connectUiReticleToCommDeltaTauPowerPmac(this.uiApp.uiReticle, this.commDeltaTauPowerPmac);
            Connect.connectUiWaferToCommDeltaTauPowerPmac(this.uiApp.uiWafer, this.commDeltaTauPowerPmac);
            
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
            
            Connect.connectUiWaferToCommKeithley6482Wafer(this.uiApp.uiWafer, this.commKeithley6482Wafer);
            
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
            
            Connect.connectUiReticleToCommKeithley6482Reticle(this.uiApp.uiReticle, this.commKeithley6482Reticle);
            
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
            
            Connect.connectUiWaferToCommCxroHeightSensor(this.uiApp.uiWafer, this.commCxroHeightSensor);
            
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
            
            Connect.connectUiBeamlineToCommCxroBeamline(this.uiApp.uiBeamline, this.commCxroBeamline);
            
            this.lConnectedToCommCxroBeamline = true;
            
        end
        
               
        
        function destroyComm(this)
            
            
        end
        
        function showMsgConnected(this, cMsg)
            
        end
        
        function showMsgError(this, cMsg)
            
        end

    end % private
    
    
end