classdef App < mic.Base
        
    properties (Constant)
        
        dWidth = 750
        dHeight = 550
                       
    end
    
	properties
        
        cName = 'ui.App'
        uiNetworkCommunication
        uiBeamline
        uiShutter
        uiM141
        uiM142
        uiM143
        uiD141
        uiD142
        uiVibrationIsolationSystem
        uiReticle
        uiWafer
        uiPowerPmacStatus
        uiPrescriptionTool           
        uiScan
        uiTempSensors
        uiFocusSensor
        uiDriftMonitor
        uiLSIControl = {};
        uiLSIAnalyze = {};
        uiScannerM142
        uiScannerMA
        uiHeightSensorLEDs
        uiCameraLEDs
        uiScanResultPlot2x2
        uiMeasurPointLogPlotter
        uiMADiagnostics
        uiPOCurrent
        uiPowerPmacHydraMotMin
        uiMfDriftMonitorVibration
        uiExitSlit
        
        
        % Eventually make private.
        % Exposing for troubleshooting
        clock

    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
         
        dHeightEdit = 24
        dWidthButtonButtonList = 200
        cTitleButtonList = 'UI'
        hFigure
        cDirThis
        cDirSave
        
        uiButtonListBeamline
        uiButtonListVisAndPpmac
        uiButtonListHsDmi
        uiButtonListInterferometry
        uiButtonListFemScan
        uiButtonListOther
        
        hHardware
        dDelay = 0.5
        dColorOn = [0 0.9 0]
        dColorOff = [0.9 0.9 0.9]
        
        uiTextDurationOfTimerExecution
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = App(varargin)
            
            cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSave = fullfile( ...
                cDirThis, ...
                '..', ...
                '..', ...
                'save', ...
                'app' ...
            );
        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
            
        end
        
          
        function sayHi(this)
            this.msg('Hi!');
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
                    'Position', [50 50 this.dWidth this.dHeight], ... % left bottom width height
                    'Resize', 'off', ...
                    'HandleVisibility', 'on', ... % lets close all close the figure
                    'CloseRequestFcn', @this.onFigureCloseRequest, ...
                    'Visible', 'on'...
                );
                % 'CloseRequestFcn', @this.onCloseRequestFcn ...

                drawnow;                
            end
            
        end
        
        function onFigureCloseRequest(this, src, evt)
            this.msg('App.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
         end
        
        function build(this)
            
            this.buildFigure();
            
            
            this.uiButtonListBeamline.build(this.hFigure, 10, 10);
            this.uiButtonListVisAndPpmac.build(this.hFigure, 250, 10);
            
            this.uiButtonListHsDmi.build(this.hFigure, 250, 200);
            this.uiButtonListFemScan.build(this.hFigure, 250, 350);
            
            this.uiButtonListOther.build(this.hFigure, 500, 10);
            this.uiButtonListInterferometry.build(this.hFigure, 500, 300);
            
            this.uiTextDurationOfTimerExecution.build(...
                this.hFigure, ...
                10, ... % left
                480, ... % top
                200, ... % width
                24 ...
            );
        
            if ~isempty(this.clock) && ...
                ~this.clock.has(this.id())
                this.clock.add(@this.onClock, this.id(), this.dDelay);
            end
            
            
        end
        
        
        function setColorOfBeamline(this)
            if (...
                this.uiBeamline.uiCommExitSlit.get() ||...
                this.uiBeamline.uiCommBL1201CorbaProxy.get() || ...
                this.uiBeamline.uiCommDctCorbaProxy.get() || ...
                this.uiBeamline.uiCommRigolDG1000Z.get() || ...
                this.uiBeamline.uiCommDataTranslationMeasurPoint.get() || ...
                this.uiBeamline.uiCommGalilD142.get() ...
            ) 
                this.uiButtonListBeamline.setButtonColorBackground(1, this.dColorOn);
            else 
                this.uiButtonListBeamline.setButtonColorBackground(1, this.dColorOff);
            end
        end
        function setColorOfExitSlit(this)

            if (...
                this.uiExitSlit.uiCommExitSlit.get() ...
            ) 
                this.uiButtonListBeamline.setButtonColorBackground(2, this.dColorOn);
            else 
                this.uiButtonListBeamline.setButtonColorBackground(2, this.dColorOff);
            end
        end
        function setColorOfM141(this)
            if (...
                this.uiM141.uiCommSmarActMcsM141.get() ||...
                this.uiM141.uiCommDataTranslationMeasurPoint.get() ...
            ) 
                this.uiButtonListBeamline.setButtonColorBackground(4, this.dColorOn);
            else 
                this.uiButtonListBeamline.setButtonColorBackground(4, this.dColorOff);
            end
        end
        function setColorOfD141(this)
            if (...
                this.uiD141.uiCommDataTranslationMeasurPoint.get() ...
            ) 
                this.uiButtonListBeamline.setButtonColorBackground(5, this.dColorOn);
            else 
                this.uiButtonListBeamline.setButtonColorBackground(5, this.dColorOff);
            end
        end
        function setColorOfM142(this)
            if (...
                this.uiM142.uiCommNewFocusModel8742.get() ||...
                this.uiM142.uiCommMicronixMmc103.get() ...
            ) 
                this.uiButtonListBeamline.setButtonColorBackground(6, this.dColorOn);
            else 
                this.uiButtonListBeamline.setButtonColorBackground(6, this.dColorOff);
            end
        end
        function setColorOfScannerM142(this)
            if (...
                this.uiScannerM142.uiCommNPointLC400.get() ... 
            ) 
                this.uiButtonListBeamline.setButtonColorBackground(7, this.dColorOn);
            else 
                this.uiButtonListBeamline.setButtonColorBackground(7, this.dColorOff);
            end
        end
        function setColorOfD142(this)
            if (...
                this.uiD142.uiCommGalil.get() ||...
                this.uiD142.uiCommDataTranslationMeasurPoint.get() ...
            ) 
                this.uiButtonListBeamline.setButtonColorBackground(8, this.dColorOn);
            else 
                this.uiButtonListBeamline.setButtonColorBackground(8, this.dColorOff);
            end
        end
        function setColorOfM143(this)
            if (...
                this.uiM143.uiCommGalil.get() ||...
                this.uiM143.uiCommDataTranslationMeasurPoint.get() ...
            ) 
                this.uiButtonListBeamline.setButtonColorBackground(9, this.dColorOn);
            else 
                this.uiButtonListBeamline.setButtonColorBackground(9, this.dColorOff);
            end
        end
        
        function setColorOfMADiagnostics(this)
            if (...
                this.uiMADiagnostics.uiCommNewFocusModel8742.get() ...
            ) 
                this.uiButtonListBeamline.setButtonColorBackground(10, this.dColorOn);
            else 
                this.uiButtonListBeamline.setButtonColorBackground(10, this.dColorOff);
            end
        end
        function setColorOfScannerMA(this)
            if (...
                this.uiScannerMA.uiCommNPointLC400.get() ... 
            ) 
                this.uiButtonListBeamline.setButtonColorBackground(11, this.dColorOn);
            else 
                this.uiButtonListBeamline.setButtonColorBackground(11, this.dColorOff);
            end
        end
        
        
        function setColorOfVibrationIsolationSystem(this)

            if (...
                this.uiVibrationIsolationSystem.uiCommGalil.get() ||...
                this.uiVibrationIsolationSystem.uiCommDataTranslation.get() ...
            ) 
                this.uiButtonListVisAndPpmac.setButtonColorBackground(1, this.dColorOn);
            else 
                this.uiButtonListVisAndPpmac.setButtonColorBackground(1, this.dColorOff);
            end
        end
        function setColorOfReticle(this)

             if (...
                this.uiReticle.uiCommDeltaTauPowerPmac.get() ||...
                this.uiReticle.uiCommKeithley6482.get() ...
            ) 
                this.uiButtonListVisAndPpmac.setButtonColorBackground(2, this.dColorOn);
            else 
                this.uiButtonListVisAndPpmac.setButtonColorBackground(2, this.dColorOff);
             end
        end
        function setColorOfWafer(this)
             if (...
                this.uiWafer.uiCommDeltaTauPowerPmac.get() ||...
                this.uiWafer.uiCommMfDriftMonitor.get() || ...
                this.uiWafer.uiCommKeithley6482.get() ...
            ) 
                this.uiButtonListVisAndPpmac.setButtonColorBackground(3, this.dColorOn);
            else 
                this.uiButtonListVisAndPpmac.setButtonColorBackground(3, this.dColorOff);
             end
        end
        
        function setColorOfPpmacStatus(this)
              if (...
                this.uiPowerPmacStatus.uiCommDeltaTauPowerPmac.get() ...
            ) 
                this.uiButtonListVisAndPpmac.setButtonColorBackground(4, this.dColorOn);
            else 
                this.uiButtonListVisAndPpmac.setButtonColorBackground(4, this.dColorOff);
              end
        end
        
        function setColorOfPpmacHydraMotMin(this)
            if (...
                this.uiPowerPmacHydraMotMin.uiCommDeltaTauPowerPmac.get() ...
            ) 
                this.uiButtonListVisAndPpmac.setButtonColorBackground(5, this.dColorOn);
            else 
                this.uiButtonListVisAndPpmac.setButtonColorBackground(5, this.dColorOff);
            end
        end
        
        
        function setColorOfMfDriftMonitorVibration(this)

             if (...
                this.uiMfDriftMonitorVibration.uiCommMfDriftMonitor.get() ...
            ) 
                this.uiButtonListHsDmi.setButtonColorBackground(2, this.dColorOn);
            else 
                this.uiButtonListHsDmi.setButtonColorBackground(2, this.dColorOff);
             end
        end
        function setColorOfPoCurrent(this)
             if (...
                this.uiPOCurrent.uiCommKeithley6482.get() ...
            ) 
                this.uiButtonListFemScan.setButtonColorBackground(3, this.dColorOn);
            else 
                this.uiButtonListFemScan.setButtonColorBackground(3, this.dColorOff);
             end
             
        end
        
        
        function setColorOfShutter(this)

             if (...
                this.uiShutter.uiCommRigol.get() ...
            ) 
                this.uiButtonListBeamline.setButtonColorBackground(3, this.dColorOn);
            else 
                this.uiButtonListBeamline.setButtonColorBackground(3, this.dColorOff);
             end
        end
        
        
        
        function onClock(this)
            
             
            
            % Update the color of the buttons
            %{
            stButtons = [
              
              stTempSensors, ...
              stFocusSensor, ...
              stDriftMonitor, ...
              stLSIControl, ...
              stLSIAnalyze, ...
              stHeightSensorLEDs, ...
              stCameraLEDs, ...
              stScanResultPlot2x2, ...
              stShutter ...
           ];
            %}
            
            
            this.setColorOfBeamline();
            this.setColorOfExitSlit()
            this.setColorOfM141();
            this.setColorOfD141()
            this.setColorOfM142();
            this.setColorOfScannerM142();
            this.setColorOfD142();
            this.setColorOfM143();
            this.setColorOfVibrationIsolationSystem();
            this.setColorOfMADiagnostics();
            this.setColorOfScannerMA()
            this.setColorOfReticle()
            this.setColorOfWafer()
            this.setColorOfMfDriftMonitorVibration()
            this.setColorOfPoCurrent()
            this.setColorOfPpmacStatus()
            this.setColorOfPpmacHydraMotMin()
            this.setColorOfShutter() 
            
            cVal = sprintf('%1.1f', this.clock.getDurationOfLastTimerExecution() * 1000);
            this.uiTextDurationOfTimerExecution.set(cVal);
            
            
        end
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
            
            this.saveStateToDisk();

            % remove clock task
            
            if isvalid(this.clock) && ...
               this.clock.has(this.id())
                this.clock.remove(this.id());
            end
            
            % Delete the figure
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            % Delete the device UI controls
            delete(this.uiNetworkCommunication)
            delete(this.uiShutter)
            delete(this.uiM141)
            delete(this.uiM142)
            delete(this.uiMADiagnostics)
            delete(this.uiM143)
            delete(this.uiD141)
            delete(this.uiD142)
            delete(this.uiVibrationIsolationSystem)
            delete(this.uiReticle)
            delete(this.uiWafer)
            delete(this.uiPOCurrent)
            delete(this.uiScannerMA)
            delete(this.uiScannerM142)
            delete(this.uiPrescriptionTool)           
            delete(this.uiScan) 
            delete(this.uiTempSensors)
            delete(this.uiFocusSensor)
            delete(this.uiHeightSensorLEDs)
            delete(this.uiCameraLEDs)
            delete(this.uiScanResultPlot2x2)
            delete(this.uiExitSlit)
            delete(this.uiMfDriftMonitorVibration);
            delete(this.uiPowerPmacHydraMotMin);
            delete(this.uiPowerPmacStatus);
            
            % Delete the clock
            delete(this.clock);
                       
        end 
        
        function cec = getSaveLoadProps(this)
           
            cec = {...
                'uiPrescriptionTool', ...
                'uiScannerMA', ...
                'uiScannerM142', ...
                'uiScan', ...
                ...%'uiNetworkCommunication', ...
                ...%'uiBeamline', ...
                ...%'uiShutter', ...
                'uiM141', ...
                'uiM142', ...
                'uiMADiagnostics', ...
                'uiPOCurrent', ...
                'uiM143', ...
                'uiD141', ...
                'uiD142', ...
                ...% 'uiVibrationIsolationSystem', ...
                'uiReticle', ...
                'uiWafer', ...
                'uiScanResultPlot2x2', ...
                'uiMeasurPointLogPlotter', ...
                'uiMfDriftMonitorVibration', ...
                'uiExitSlit' ...
             };
            
        end
        
        
        function st = save(this)
             cecProps = this.getSaveLoadProps();
            
            st = struct();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                st.(cProp) = this.(cProp).save();
            end

             
        end
        
        function load(this, st)
                        
            cecProps = this.getSaveLoadProps();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
               if isfield(st, cProp)
               	this.(cProp).load(st.(cProp))
               end
            end
            
        end
        
        function saveStateToDisk(this)
            st = this.save();
            fprintf('ui.App saveStateToDisk() file: %s\n', this.file());
            save(this.file(), 'st');
        end
        
        function loadStateFromDisk(this)
            if exist(this.file(), 'file') == 2
                fprintf('ui.App loadStateFromDisk() file: %s\n', this.file());
                load(this.file()); % populates variable st in local workspace
                this.load(st);
            end
        end

    end
    
    methods (Access = private)
        
        function onFemToolSizeChange(this, src, evt)
            
            % evt has a property stData
            %   dX
            %   dY
            
            
            this.msg('onFemToolSizeChange');
            %disp(evt.stData.dX)
            %disp(evt.stData.dY)
            
            this.uiWafer.uiAxes.deleteFemPreviewPrescription();
            this.uiWafer.uiAxes.addFemPreviewPrescription(evt.stData.dX, evt.stData.dY);
        end
        
        function initBeamline(this)
            stBeamline = struct(...
                'cLabel',  'Grating Scan / Calibrate', ...
                'fhOnClick',  @() this.uiBeamline.build(), ...
                'cTooltip',  'Beamline' ...
            );
        
            stExitSlit = struct(...
                'cLabel',  'Exit Slit (All 4 Blades)', ...
                'fhOnClick',  @() this.uiExitSlit.build(), ...
                'cTooltip',  'Exit Slit' ...
            );
            
            stShutter = struct(...
            'cLabel',  'Shutter', ...
            'fhOnClick',  @() this.uiShutter.build(), ...
            'cTooltip',  'Beamline');
            
            stD141 = struct(...
            'cLabel',  'D141', ...
            'fhOnClick',  @() this.uiD141.build(), ...
            'cTooltip',  'D141');
                        
            stM141 = struct(...
            'cLabel',  'M141', ...
            'fhOnClick',  @() this.uiM141.build(), ...
            'cTooltip',  'Beamline');
        
        
            stD142 = struct(...
            'cLabel',  'D142', ...
            'fhOnClick',  @() this.uiD142.build(), ...
            'cTooltip',  'D142');
            
            stM142 = struct(...
            'cLabel',  'M142', ...
            'fhOnClick',  @() this.uiM142.build(), ...
            'cTooltip',  'Beamline');
        
            stMADiagnostics = struct(...
            'cLabel',  'MA Diagnostics', ...
            'fhOnClick',  @() this.uiMADiagnostics.build(), ...
            'cTooltip',  'MA Diagnostics');
            
            stM143 = struct(...
            'cLabel',  'M143', ...
            'fhOnClick',  @() this.uiM143.build(), ...
            'cTooltip',  'Beamline');
        
            stScannerMA = struct(...
            'cLabel',  'MA Scanner', ...
            'fhOnClick',  @() this.uiScannerMA.build(), ...
            'cTooltip',  'Beamline');
        
            stScannerM142 = struct(...
            'cLabel',  'M142 Scanner', ...
            'fhOnClick',  @() this.uiScannerM142.build(), ...
            'cTooltip',  'Beamline');
        
            stButtons = [
              stBeamline, ...
              stExitSlit, ...
              stShutter, ...
              stM141, ...
              stD141, ...
              stM142, ...
              stScannerM142, ...
              stD142, ...
              stM143, ...  
              stMADiagnostics, ...
              stScannerMA ...
            ];
        
            this.uiButtonListBeamline = mic.ui.common.ButtonList(...
                'stButtonDefinitions', stButtons, ...
                'cTitle', 'Branch Line', ...
                'dWidthButton', this.dWidthButtonButtonList ...
            );
            
        end
        
        function initHsDmi(this)
            
            stMfDriftMonitorVibration = struct(...
                'cLabel',  'HS + DMI Vibration 1 kHz', ...
                'fhOnClick',  @() this.uiMfDriftMonitorVibration.build(), ...
                'cTooltip',  'HS + DMI Vibration 1 kHz' ...
            );
        
            stHeightSensorLEDs = struct(...
            'cLabel',  'Height Sensor LEDs', ...
            'fhOnClick',  @() this.uiHeightSensorLEDs.build(), ...
            'cTooltip',  'HeightSensorLEDs');
        
            stDriftMonitor =  struct(...
                'cLabel',  'Drift Monitor/Height Sensor', ...
                'fhOnClick',  @() this.uiDriftMonitor.build(10, 10), ...
                'cTooltip',  'Drift Monitor/Height Sensor'...
            );
        
            stButtons = [...
              stHeightSensorLEDs, ...
              stMfDriftMonitorVibration, ...
              stDriftMonitor, ... 
            ];
        
            this.uiButtonListHsDmi = mic.ui.common.ButtonList(...
                'stButtonDefinitions', stButtons, ...
                'cTitle', 'HS / DMI', ...
                'dWidthButton', this.dWidthButtonButtonList ...
            );
        
        
            
        end
        
        function initInterferometry(this)
            
            stFocusSensor = struct(...
                'cLabel',  'Focus Sensor', ...
                'fhOnClick',  @() this.uiFocusSensor.build(), ...
                'cTooltip',  'Focus Sensor'...
            );
            
            
        
            stLSIControl =  struct(...
                'cLabel',  'LSI Control', ...
                'fhOnClick',  @() this.uiLSIControl.build(), ...
                'cTooltip',  'LSI Control'...
            );
        
            stLSIAnalyze =  struct(...
                'cLabel',  'LSI Analysis GUI', ...
                'fhOnClick',  @() this.uiLSIAnalyze.build(0, -200), ...
                'cTooltip',  'LSI Analysis GUI'...
            );
        
            stButtons = [
              stFocusSensor, ...
              stLSIControl, ...
              stLSIAnalyze, ...
            ];
        
            this.uiButtonListInterferometry = mic.ui.common.ButtonList(...
                'stButtonDefinitions', stButtons, ...
                'cTitle', 'Interferometry', ...
                'dWidthButton', this.dWidthButtonButtonList ...
            );
           
        end
        
        function initVisAndPpmac(this)
            
            stPowerPmacStatus = struct(...
                'cLabel',  'Power PMAC Status', ...
                'fhOnClick',  @() this.uiPowerPmacStatus.build(), ...
                'cTooltip',  'Power PMAC Status' ...
            );
        
            stVibrationIsolationSystem = struct(...
            'cLabel',  'Vibration Isolation System', ...
            'fhOnClick',  @() this.uiVibrationIsolationSystem.build(), ...
            'cTooltip',  'Vibration Isolation System');
        
            stReticle = struct(...
            'cLabel',  'Reticle', ...
            'fhOnClick',  @() this.uiReticle.build(), ...
            'cTooltip',  'Beamline');
            
            stWafer = struct(...
            'cLabel',  'Wafer', ...
            'fhOnClick',  @() this.uiWafer.build(), ...
            'cTooltip',  'Beamline');
        
            stPowerPmacHydraMotMin = struct(...
                'cLabel',  'Power PMAC Hydra MotMin', ...
                'fhOnClick',  @() this.uiPowerPmacHydraMotMin.build(), ...
                'cTooltip',  'Power PMAC Hydra MotMin' ...
            );
        
            stButtons = [
              stVibrationIsolationSystem, ...
              stReticle, ...
              stWafer, ...
              stPowerPmacStatus, ...
              stPowerPmacHydraMotMin, ...
           ];
       
            this.uiButtonListVisAndPpmac = mic.ui.common.ButtonList(...
                'stButtonDefinitions', stButtons, ...
                'cTitle', 'VIS + Wafer + Reticle Stages', ...
                'dWidthButton', this.dWidthButtonButtonList ...
            );
            
        end
        
        function initFemScan(this)
            
            stExptControl = struct(...
            'cLabel',  'FEM Control', ...
            'fhOnClick',  @() this.uiScan.build(), ...
            'cTooltip',  'Beamline');
        
        
            stPrescriptionTool = struct(...
            'cLabel',  'Prescription Tool', ...
            'fhOnClick',  @()this.uiPrescriptionTool.build(), ...
            'cTooltip',  'Beamline');
        
         stPOCurrent = struct(...
            'cLabel',  'PO Current (MDM)', ...
            'fhOnClick',  @() this.uiPOCurrent.build(), ...
            'cTooltip',  'PO Current (MDM)');
        
        
            stButtons = [...
              stPrescriptionTool, ...
              stExptControl, ...
              stPOCurrent ...
            ];
        
            this.uiButtonListFemScan = mic.ui.common.ButtonList(...
                'stButtonDefinitions', stButtons, ...
                'cTitle', 'FEM', ...
                'dWidthButton', this.dWidthButtonButtonList ...
            );
        
            
        end
        
        function initOther(this)
            
             stNetworkCommunication = struct(...
                'cLabel',  'Network Status', ...
                'fhOnClick',  @() this.uiNetworkCommunication.build(), ...
                'cTooltip',  'Network Status' ...
            );
        
            stMeasurPointLogPlotter = struct(...
                'cLabel',  'MeasurPoint Log Plotter', ...
                'fhOnClick',  @() this.uiMeasurPointLogPlotter.build(), ...
                'cTooltip',  'MeasurPoint Log Plotter' ...
            );
            
            stTempSensors = struct( ...
                'cLabel',  'Temp Sensors', ...
                'fhOnClick',  @()this.uiTempSensors.build(), ...
                'cTooltip',  'Temp Sensors (Mod3, POB)' ...
            );
                                          
        
            stCameraLEDs = struct(...
            'cLabel',  'Diag. Cam + LED Power', ...
            'fhOnClick',  @() this.uiCameraLEDs.build(), ...
            'cTooltip',  'Diag. Cam + LED Power');
        
        
            stScanResultPlot2x2 = struct(...
            'cLabel',  'Scan Result Plotter 2x2', ...
            'fhOnClick',  @() this.uiScanResultPlot2x2.build(), ...
            'cTooltip',  'Scan Result Plotter 2x2');
        
            
            stListClockTasks =  struct(...
                'cLabel',  'List Clock Tasks', ...
                'fhOnClick',  @this.onListClockTasks, ...
                'cTooltip',  ''...
            );
        

            stButtons = [
              stNetworkCommunication, ...
              stScanResultPlot2x2, ...
              stMeasurPointLogPlotter, ...
              stTempSensors, ...
              stCameraLEDs, ...  
              stListClockTasks ...
           ];
            
            this.uiButtonListOther = mic.ui.common.ButtonList(...
                'stButtonDefinitions', stButtons, ...
                'cTitle', 'Other', ...
                'dWidthButton', this.dWidthButtonButtonList ...
            );
        end
        
        
        
        function init(this)
            
            this.clock = mic.Clock('Master');
            
            % Set clock, required for drift monitor middle layer
            this.hHardware.setClock(this.clock);
            
            this.uiNetworkCommunication = bl12014.ui.NetworkCommunication('clock', this.clock);
            this.uiVibrationIsolationSystem = bl12014.ui.VibrationIsolationSystem('clock', this.clock);
            this.uiBeamline = bl12014.ui.Beamline('clock', this.clock);
            this.uiShutter = bl12014.ui.Shutter('clock', this.clock);
            this.uiD141 = bl12014.ui.D141('clock', this.clock);
            this.uiD142 = bl12014.ui.D142('clock', this.clock);
            this.uiM141 = bl12014.ui.M141('clock', this.clock);
            this.uiM142 = bl12014.ui.M142('clock', this.clock);
            this.uiM143 = bl12014.ui.M143('clock', this.clock);
            this.uiReticle = bl12014.ui.Reticle('clock', this.clock);
            this.uiWafer = bl12014.ui.Wafer('clock', this.clock);
            this.uiPowerPmacStatus = bl12014.ui.PowerPmacStatus('clock', this.clock);
            this.uiPowerPmacHydraMotMin = bl12014.ui.PowerPmacHydraMotMin('clock', this.clock);
            this.uiMfDriftMonitorVibration = bl12014.ui.MfDriftMonitorVibration('clock', this.clock);
            this.uiExitSlit = bl12014.ui.ExitSlit('clock', this.clock);
            this.uiTempSensors = bl12014.ui.TempSensors('clock', this.clock);
            this.uiFocusSensor = bl12014.ui.FocusSensor('clock', this.clock);
            this.uiScannerM142 = bl12014.ui.Scanner(...
                'clock', this.clock, ...
                'cName', 'M142 Scanner' ...
            );
            this.uiScannerMA = bl12014.ui.Scanner(...
                'clock', this.clock, ...
                'cName', 'MA Scanner', ...
                'dScale', 0.67 ... % 0.67 rel amp = sig 1
            );
            
            % LSI UIs exist separately.  Check if exists first though
            % because not guaranteed to have this repo:
            this.uiLSIControl = lsicontrol.ui.LSI_Control('clock', this.clock, ...
                                                           'hardware', this.hHardware);
            this.uiLSIAnalyze = lsianalyze.ui.LSI_Analyze();
            this.uiDriftMonitor = bl12014.ui.MFDriftMonitor('hardware', this.hHardware, ...
                               'clock', this.clock);
           
            

            this.uiPrescriptionTool = bl12014.ui.PrescriptionTool();
            this.uiScan = bl12014.ui.Scan(...
                'clock', this.clock, ...
                'uiShutter', this.uiShutter, ...
                'uiReticle', this.uiReticle, ...
                'uiWafer', this.uiWafer, ...
                'uiVibrationIsolationSystem', this.uiVibrationIsolationSystem, ...
                'uiMfDriftMonitorVibration', this.uiMfDriftMonitorVibration, ...
                'uiMFDriftMonitor', this.uiDriftMonitor, ...
                'uiBeamline', this.uiBeamline ...
            );
        
            this.uiHeightSensorLEDs = bl12014.ui.HeightSensorLEDs(...
                'clock', this.clock ...
            );
            this.uiCameraLEDs = bl12014.ui.CameraLEDs(...
                'clock', this.clock ...
            );
            this.uiScanResultPlot2x2 = bl12014.ui.ScanResultPlot2x2('clock', this.clock);
            this.uiMADiagnostics = bl12014.ui.MADiagnostics('clock', this.clock);
            this.uiPOCurrent = bl12014.ui.POCurrent('clock', this.clock);
            
            this.uiMeasurPointLogPlotter = bl12014.ui.MeasurPointLogPlotter();
            
            addlistener(this.uiPrescriptionTool.uiFemTool, 'eSizeChange', @this.onFemToolSizeChange);
            addlistener(this.uiPrescriptionTool, 'eNew', @this.onPrescriptionToolNew);
            addlistener(this.uiPrescriptionTool, 'eDelete', @this.onPrescriptionToolDelete);
           
            % Cannot directly pass the function handle of the build method
            % of the bl12014.ui.* instances but I found that passing an
            % anonymous function that calls bl12014.ui.*.build() works
            %
            % Does not work: function handle of method of property
            % st.fhOnClick = @this.uiBeamline.build;
            %
            % Does work: anonymous function that calls uiBeamline.build()
            % st.fhOnClick = @() this.uiBeamline.build()
              
            this.initBeamline();
            this.initVisAndPpmac();
            this.initHsDmi();
            this.initInterferometry();
            this.initFemScan();
            this.initOther();
           
        
            this.uiTextDurationOfTimerExecution = mic.ui.common.Text(...
                'lShowLabel', true, ...
                'cLabel', 'Duration of last timer execution (ms)' ...
            );
        
            this.loadStateFromDisk();

        end
        
        function onListClockTasks(this, src, evt)
            this.clock.listTasks();
        end
        
        function onCloseRequestFcn(this, src, evt)
            this.msg('closeRequestFcn()');
            % purge;
            delete(this.hFigure);
            % this.saveState();
        end
            
        function onPrescriptionToolNew(this, src, evt)
            this.uiScan.refreshPrescriptions();
        end
        
        function onPrescriptionToolDelete(this, src, evt)
            this.uiScan.refreshPrescriptions();
        end
        
        function onPupilFillNew(this, src, evt)
            % uil property is private, so I exposed a public method
            this.uiPrescriptionTool.pupilFillSelect.refreshList();
        end
        
        function onPupilFillDelete(this, src, evt)
            % uil property is private, so I exposed a public method
            this.uiPrescriptionTool.pupilFillSelect.refreshList();
        end
        
        
        
        
        function c = file(this)
            mic.Utils.checkDir(this.cDirSave);
            c = fullfile(...
                this.cDirSave, ...
                ['saved-state', '.mat']...
            );
            c = mic.Utils.path2canonical(c);
        end
        
    end % private
    
    
end