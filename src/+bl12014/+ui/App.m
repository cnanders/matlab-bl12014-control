classdef App < mic.Base
        
    properties (Constant)
        

        
                    
        dWidth = 1850;
        dHeight = 1040;
        
        lUseDock = true;
        
       
                       
    end
    
	properties
        
        cName = 'ui.App'
        waferExposureHistory
        uiHardware
        uiNetworkCommunication
        uiBeamline
        uiTuneFluxDensity
        uiM143
        uiVibrationIsolationSystem
        uiReticle
        uiWafer
        uiPowerPmacStatus
        uiScan
        uiTempSensors
        uiFocusSensor
        uiDriftMonitor
        uiLSIControl = {};
        uiLSIAnalyze = {};
        uiScannerM142
        uiMA
        uiHeightSensorLEDs
        uiCameraLEDs
        uiScanResultPlot2x2
        uiLogPlotter
        uiPOCurrent
        uiMfDriftMonitorVibration
        uiButtonListClockTasks
        uiPowerPmacHydraMotMin
        uiPowerPmacAccel
        uiDMIPowerMonitor
        uiPowerPmacHydraMotMinMonitor
        uiDCT
        
        uiCurrentOfRing
        
        % Eventually make private.
        % Exposing for troubleshooting
        clock
        
        % { mic.ui.Clock 1x1}
        uiClockHardware
        uiClockNetworkCommunication
        uiClockBeamline
        uiClockM143
        uiClockDCT
        uiClockVibrationIsolationSystem
        uiClockReticle
        uiClockWafer
        uiClockPowerPmacStatus
        uiClockPrescriptionTool
        uiClockScan
        uiClockTempSensors
        uiClockFocusSensor
        uiClockDriftMonitor
        uiClockLSIControl
        uiClockLSIAnalyze
        uiClockScannerM142
        uiClockMA
        uiClockHeightSensorLEDs
        uiClockCameraLEDs
        uiClockScanResultPlot2x2
        uiClockLogPlotter
        uiClockPOCurrent
        uiClockMfDriftMonitorVibration
        uiClockMfDriftMonitor
        uiClockTuneFluxDensity
        uiClockPowerPmacHydraMotMin
        uiClockDMIPowerMonitor
        uiClockPowerPmacHydraMotMinMonitor
        
        fhOnCloseFigure = @(src, evt)[];

    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        cecTabs = {...
            'Hardware', ...
            'Beamline', ...
            'Field Scanner (M142)', ...
            'M143', ...
            'DCT', ...
            'MA', ...
            'VIS', ...
            'Drift Monitor Vib', ...
            'Drift Monitor', ...
            'Reticle', ...
            'Wafer', ...
            'Tune Flux Density', ...
            'FEM Control', ...
            'FEM Plotter', ...
            'PO Current', ...
            'PPMAC Status', ....
            'PPMAC Hydra Mot Min', ...
            'Camera LEDs', ...
            'Log Plotter', ...
            'Height Sensor LEDs', ...
            'Network Status', ...
        };
    
        lIsTabBuilt = false(1, 30);
            
         
        dHeightEdit = 24
        dWidthButtonButtonList = 200
        cTitleButtonList = 'UI'
        hFigure
        cDirThis
        cDirSave
        
        uiButtonListBeamline
        uiButtonListVisAndPpmac

        uiButtonListInterferometry
        uiButtonListFemScan
        
        hardware
        dDelay = 0.5
        dColorOn = [0 0.9 0]
        dColorOff = [0.9 0.9 0.9]
        
        uiTextDurationLabel
        uiTextDurationOfTimerExecution
        
        uiTabGroup
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
        
            this.fhOnCloseFigure = @(src, evt) this.delete(); % default
        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            

            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            
            this.init();
            
        end
        
          
        function sayHi(this)
            this.msg('Hi!');
        end
        
                
        function build(this)
            
            % LSIControl is built separately now
            % this.uiLSIControl.build();
            

            dScreenSize = get(0, 'ScreenSize');
            
            % Centered
            dLeft = (dScreenSize(3) - this.dWidth)/2;
            dBottom = (dScreenSize(4) - this.dHeight)/2;
            
            % Top Left
            dLeft = 10;
            dBottom = dScreenSize(4) - this.dHeight - 10 - 60;
            
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name', 'MET5 Control',...
                'Position', [ ...
                dLeft ...
                dBottom ...
                this.dWidth ...
                this.dHeight ...
                ],... % left bottom width height
                'Toolbar', 'figure', ... % zoom tools
                'Resize', 'off',...
                'WindowButtonMotionFcn', @this.onFigureWindowMouseMotion, ...
                'WindowButtonDownFcn', @this.onFigureWindowMouseDown, ... % doesn't work if datacursormode is on!
                'HandleVisibility', 'on',... % lets close all close the figure
                'CloseRequestFcn', @this.onCloseRequest, ...
                'Visible', 'on'...
            );
            this.uiTabGroup.build(this.hFigure, 0, 30, this.dWidth, this.dHeight - 40);
            
            this.uiTextDurationLabel.build(...
                this.hFigure, ...
                10, ... % left
                5, ... % top
                180, ... % width
                12 ...
            );
            this.uiTextDurationOfTimerExecution.build(...
                this.hFigure, ...
                190, ... % left
                5, ... % top
                200, ... % width
                12 ...
            );
        
            this.uiButtonListClockTasks.build(this.hFigure, 290, 5, 100, 20);
            this.uiCurrentOfRing.build(this.hFigure, 400, 5);
            this.uiDMIPowerMonitor.build(this.hFigure, 600, 1);
            this.uiPowerPmacHydraMotMinMonitor.build(this.hFigure, 1000, 1);
        
            this.clock.add(@this.onClock, this.id(), this.dDelay);
            
            % Build the first tab.
            
            cTab = 'Hardware';
            this.lIsTabBuilt(strcmp(cTab, this.cecTabs)) = true;
            hTab = this.uiTabGroup.getTabByName(cTab);
            this.uiHardware.build(hTab, 10, 10);
            
        end
        
        
        function onFigureWindowMouseDown(this, src, evt)
           
            if ~ishandle(this.hFigure)
                return
            end
            cTab = this.uiTabGroup.getSelectedTabName();
            
            switch cTab
               case 'Beamline'
                    this.uiBeamline.showSetAsZeroIfFigureClickIsInAxes(this.hFigure);
               
            end
            
        end
        
        
        function onFigureWindowMouseMotion(this, src, evt)
           
            if ~ishandle(this.hFigure)
                return
            end
            
           % this.msg('onWindowMouseMotion()');
           cTab = this.uiTabGroup.getSelectedTabName();
           switch cTab
               case 'Beamline'
                    this.uiBeamline.updateAxesCrosshair(this.hFigure);
               case 'Log Plotter'
                    this.uiLogPlotter.setTextPlotXPlotYBasedOnAxesCurrentPoint(this.hFigure);
           end
           
        end
       
        function onClock(this)
            
            cDuration = sprintf('%1.1f', this.clock.getDurationOfLastTimerExecution() * 1000);
            dNum = this.clock.getNumberOfActiveTasks();
            
            cVal = sprintf('%s (%1.0f tasks)', cDuration, dNum);
            this.uiTextDurationOfTimerExecution.set(cVal);
            
            % 2020.10.06 try turning off for improved performance
            % this.saveStateToDisk(); % save state every second or two
            
        end
        
        %% Destructor
        
        function cec = getPropsDelete(this)
            
            cec = {
                'uiDCT', ...
                'uiScan', ...
                'uiBeamline', ...
                'uiTuneFluxDensity', ...
                'uiM143', ...
                'uiVibrationIsolationSystem', ...
                'uiReticle', ...
                'uiWafer', ...
                'uiPowerPmacStatus', ...
                'uiTempSensors', ...
                'uiFocusSensor', ...
                'uiDriftMonitor', ...
                ...'uiLSIControl', ...
                ...'uiLSIAnalyze', ...
                'uiScannerM142', ...
                'uiMA', ...
                'uiHeightSensorLEDs', ...
                'uiCameraLEDs', ...
                'uiScanResultPlot2x2', ...
                'uiLogPlotter', ...
                'uiPOCurrent', ...
                'uiMfDriftMonitorVibration', ...
                'uiButtonListClockTasks', ...
                'uiPowerPmacHydraMotMin', ...
                'uiPowerPmacAccel', ...
                'uiDMIPowerMonitor', ...
                'uiPowerPmacHydraMotMinMonitor', ...
                'uiHardware', ...
                'uiNetworkCommunication', ...
                'uiCurrentOfRing', ...
                ...
                ... ui.clock instances
                'uiClockHardware', ...
                'uiClockNetworkCommunication', ...
                'uiClockBeamline', ...
                'uiClockM143', ...
                'uiClockVibrationIsolationSystem', ...
                'uiClockReticle', ...
                'uiClockWafer', ...
                'uiClockPowerPmacStatus', ...
                'uiClockPrescriptionTool', ...
                'uiClockScan', ...
                'uiClockTempSensors', ...
                'uiClockFocusSensor', ...
                'uiClockDriftMonitor', ...
                'uiClockLSIControl', ...
                'uiClockLSIAnalyze', ...
                'uiClockScannerM142', ...
                'uiClockMA', ...
                'uiClockHeightSensorLEDs', ...
                'uiClockCameraLEDs', ...
                'uiClockScanResultPlot2x2', ...
                'uiClockLogPlotter', ...
                'uiClockPOCurrent', ...
                'uiClockMfDriftMonitorVibration', ...
                'uiClockMfDriftMonitor', ...
                'uiClockTuneFluxDensity', ...
                'uiClockPowerPmacHydraMotMin', ...
                'uiClockDMIPowerMonitor', ...
                'uiClockPowerPmacHydraMotMinMonitor' ...
            };
        end
        
        function delete(this)
            
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);  
            
            this.saveStateToDisk();
            this.clock.remove(this.id());
            
            % Delete the figure
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            if ishandle(this.hFigure)
               delete(this.hFigure);
            end
            
            cecProps = this.getPropsDelete();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                cMsg = sprintf('delete() deleting %s', cProp);
                this.msg(cMsg, this.u8_MSG_TYPE_CLASS_DELETE);  
                this.(cProp).delete();
            end
            
            this.uiLSIControl = [];
            this.uiLSIAnalyze = [];
                        
                       
        end 
        
        function cec = getSaveLoadProps(this)
           
            cec = {...
                'uiMA', ...
                'uiScannerM142', ...
                'uiScan', ...
                'uiDCT', ...
                ...%'uiNetworkCommunication', ...
                'uiBeamline', ...
                'uiPOCurrent', ...
                'uiM143', ...
                ...% 'uiVibrationIsolationSystem', ...
                'uiReticle', ...
                'uiWafer', ...
                'uiScanResultPlot2x2', ...
                'uiLogPlotter', ...
                'uiMfDriftMonitorVibration', ...
             };
            
        end
        
        
        function st = save(this)
             cecProps = this.getSaveLoadProps();
            
            st = struct();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                if this.hasProp( cProp)
                    st.(cProp) = this.(cProp).save();
                end
            end

             
        end
        
        function load(this, st)
                        
            cecProps = this.getSaveLoadProps();
            for n = 1 : length(cecProps)
               cProp = cecProps{n};
               if isfield(st, cProp)
                   if this.hasProp( cProp )
                        this.(cProp).load(st.(cProp))
                   end
               end
            end
            
        end
        
        function saveStateToDisk(this)
            st = this.save();
            % fprintf('ui.App saveStateToDisk() file: %s\n', this.file());
            save(this.file(), 'st');
        end
        
        function loadStateFromDisk(this)
            if exist(this.file(), 'file') == 2
                fprintf('ui.App loadStateFromDisk() file: %s\n', this.file());
                load(this.file()); % populates variable st in local workspace
                this.load(st);
            end
        end
        
        function listClockTasks(this)
            this.onListClockTasks();
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
            
            this.waferExposureHistory.deleteFemPreview();
            this.waferExposureHistory.addFemPreview(evt.stData.dX, evt.stData.dY);
            
            %this.uiWafer.uiAxes.deleteFemPreviewPrescription();
            %this.uiWafer.uiAxes.addFemPreviewPrescription(evt.stData.dX, evt.stData.dY);
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
        

        
        
        
        
        
        
        function init(this)
            
            this.waferExposureHistory = bl12014.WaferExposureHistory();
            
            % Initialize cell of function handle callbacks for each tab of 
            % the tab group
            
            cefhCallback = cell(1, length(this.cecTabs));
            for n = 1 : length(this.cecTabs)
                cefhCallback{n} = @this.onUiTabGroup;
            end
            
            
            this.uiTabGroup = mic.ui.common.Tabgroup(...
                'fhDirectCallback', cefhCallback, ...
                'ceTabNames',  this.cecTabs ...
            );
                                   
            
            this.uiClockHardware = mic.ui.Clock(this.clock);
            this.uiClockNetworkCommunication = mic.ui.Clock(this.clock);
            this.uiClockBeamline = mic.ui.Clock(this.clock);
            this.uiClockM143 = mic.ui.Clock(this.clock);
            this.uiClockDCT = mic.ui.Clock(this.clock);
            this.uiClockVibrationIsolationSystem = mic.ui.Clock(this.clock);
            this.uiClockReticle = mic.ui.Clock(this.clock);
            this.uiClockWafer = mic.ui.Clock(this.clock);
            this.uiClockPowerPmacStatus = mic.ui.Clock(this.clock);
            this.uiClockPrescriptionTool = mic.ui.Clock(this.clock);
            this.uiClockScan = mic.ui.Clock(this.clock);
            this.uiClockTempSensors = mic.ui.Clock(this.clock);
            this.uiClockFocusSensor = mic.ui.Clock(this.clock);
            this.uiClockDriftMonitor = mic.ui.Clock(this.clock);
            this.uiClockLSIControl = mic.ui.Clock(this.clock);
            this.uiClockLSIAnalyze = mic.ui.Clock(this.clock);
            this.uiClockScannerM142 = mic.ui.Clock(this.clock);
            this.uiClockMA = mic.ui.Clock(this.clock);
            this.uiClockHeightSensorLEDs = mic.ui.Clock(this.clock);
            this.uiClockCameraLEDs = mic.ui.Clock(this.clock);
            this.uiClockScanResultPlot2x2 = mic.ui.Clock(this.clock);
            this.uiClockLogPlotter = mic.ui.Clock(this.clock);
            this.uiClockPOCurrent = mic.ui.Clock(this.clock);
            this.uiClockMfDriftMonitorVibration = mic.ui.Clock(this.clock);
            this.uiClockMfDriftMonitor = mic.ui.Clock(this.clock);
            this.uiClockTuneFluxDensity = mic.ui.Clock(this.clock);
            this.uiClockPowerPmacHydraMotMin = mic.ui.Clock(this.clock);
            this.uiClockDMIPowerMonitor = mic.ui.Clock(this.clock);
            this.uiClockPowerPmacHydraMotMinMonitor = mic.ui.Clock(this.clock);
            this.uiNetworkCommunication = bl12014.ui.NetworkCommunication('clock', this.uiClockNetworkCommunication);
            
                    
        
            this.uiBeamline = bl12014.ui.Beamline(...
                'clock', this.clock, ...
                'uiClock', this.uiClockBeamline, ...
                'hardware', this.hardware ...
            );
            
            [cDir, cName, cExt] = fileparts(mfilename('fullpath'));
            cDirSave = mic.Utils.path2canonical(fullfile(...
                cDir, ...
                '..', ...
                '..', ...    
                'save', ...
                'scanner-m142' ...
            ));
                    
            this.uiScannerM142 = bl12014.ui.Scanner(...
                'fhGetNPoint', @() this.hardware.getNPointM142(), ...
                'cName', 'M142 Scanner', ...
                'clock', this.clock, ...
                'uiClock', this.uiClockScannerM142, ...
                'cDirSave', cDirSave ...
            );
        
            this.uiM143 = bl12014.ui.M143(...
                'clock', this.uiClockM143, ...
                'hardware', this.hardware ...
            );  
        
            this.uiDCT = bl12014.ui.DCT(...
               'uiBeamline', this.uiBeamline, ...
               'uiScannerM142', this.uiScannerM142, ...
               'hardware', this.hardware, ...
               'clock', this.clock, ...
               'uiClock', this.uiClockDCT ...
            );

            
            this.uiReticle = bl12014.ui.Reticle(...
                'clock', this.clock, ...
                'hardware', this.hardware, ...
                'uiClock', this.uiClockReticle ...
            );
            
            this.uiWafer = bl12014.ui.Wafer(...
                'clock', this.clock, ...
                'uiClock', this.uiClockWafer, ...
                'hardware', this.hardware, ...
                'waferExposureHistory', this.waferExposureHistory ...
            );
            this.uiPowerPmacStatus = bl12014.ui.PowerPmacStatus(...
                'hardware', this.hardware, ...
                'clock', this.uiClockPowerPmacStatus ...
            );
            this.uiPowerPmacHydraMotMin = bl12014.ui.PowerPmacHydraMotMin(...
                'hardware', this.hardware, ...
                'clock', this.clock, ...
                'uiClock', this.uiClockPowerPmacHydraMotMin ...
            );
        
            this.uiPowerPmacAccel = bl12014.ui.PowerPmacAccel(...
                'hardware', this.hardware, ...
                'clock', this.clock, ...
                'uiClock', this.uiClockPowerPmacHydraMotMin ...
            );
            
            this.uiMfDriftMonitorVibration = bl12014.ui.MfDriftMonitorVibration(...
                'hardware', this.hardware, ...
                'clock', this.uiClockMfDriftMonitorVibration ...
            );
            this.uiVibrationIsolationSystem = bl12014.ui.VibrationIsolationSystem(...
                'clock', this.uiClockVibrationIsolationSystem, ...
                'hardware', this.hardware ...
            );
            this.uiTempSensors = bl12014.ui.TempSensors('clock', this.uiClockTempSensors);
            this.uiFocusSensor = bl12014.ui.FocusSensor(...
                'hardware', this.hardware, ...
                'clock', this.uiClockFocusSensor ...
            );
            
            [cDir, cName, cExt] = fileparts(mfilename('fullpath'));
            cDirWaveforms = mic.Utils.path2canonical(fullfile(...
                cDir, ...
                '..', ...
                '..', ...
                'save', ...
                'scanner-ma' ...
            ));
        
            cDirWaveformsStarred = fullfile(...
                cDirWaveforms, ...
                'starred' ...
            );
            
            this.uiMA = bl12014.ui.MA(...
                'hardware', this.hardware, ...
                'clock', this.clock, ...
                'uiClock', this.uiClockMA ...
            );
        
            
            % LSI UIs exist separately.  Check if exists first though
            % because not guaranteed to have this repo:
            this.uiLSIControl = lsicontrol.ui.LSI_Control('clock', this.clock, ... % eventually provide a uiClock but it has a scan
                                                           'hardware', this.hardware);
            this.uiLSIAnalyze = lsianalyze.ui.LSI_Analyze();
            this.uiDriftMonitor = bl12014.ui.MFDriftMonitor(...
                'hardware', this.hardware, ...
                'clock', this.clock);
           
            
            this.uiTuneFluxDensity = bl12014.ui.TuneFluxDensity(...
                'waferExposureHistory', this.waferExposureHistory, ...
                'uiScannerMA', this.uiMA.uiScanner, ...
                'uiScannerM142', this.uiScannerM142, ...
                'uiReticle', this.uiReticle, ...
                'hardware', this.hardware, ...
                'uiGratingTiltX', this.uiBeamline.uiGratingTiltX, ...
                'clock', this.clock, ...
                'uiClock', this.uiClockTuneFluxDensity ...
            );
        
            this.uiHeightSensorLEDs = bl12014.ui.HeightSensorLEDs(...
                'hardware', this.hardware, ...
                'clock', this.uiClockHeightSensorLEDs ...
            );
        
            this.uiScan = bl12014.ui.Scan(...
                'clock', this.clock, ...
                'uiClock', this.uiClockScan, ...
                'hardware', this.hardware, ...
                'uiReticle', this.uiReticle, ...
                'uiWafer', this.uiWafer, ...
                'uiHeightSensorLEDs', this.uiHeightSensorLEDs, ...
                'uiScannerM142', this.uiScannerM142, ...
                'uiScannerMA', this.uiMA.uiScanner, ...
                'uiVibrationIsolationSystem', this.uiVibrationIsolationSystem, ...
                'uiMfDriftMonitorVibration', this.uiMfDriftMonitorVibration, ...
                'uiMFDriftMonitor', this.uiDriftMonitor, ...
                'uiTuneFluxDensity', this.uiTuneFluxDensity, ...
                'waferExposureHistory', this.waferExposureHistory, ...
                'uiBeamline', this.uiBeamline ...
            );

            
            this.uiCameraLEDs = bl12014.ui.CameraLEDs(...
                'clock', this.uiClockCameraLEDs, ...
                'hardware', this.hardware ...
            );
            this.uiScanResultPlot2x2 = bl12014.ui.ScanResultPlot2x2('clock', this.uiClockScanResultPlot2x2);
            
            this.uiPOCurrent = bl12014.ui.POCurrent(...
                'clock', this.uiClockPOCurrent, ...
                'hardware', this.hardware, ...
                'dWidth', 1700 ...
            );
            
            this.uiLogPlotter = bl12014.ui.LogPlotter(...
                'hardware', this.hardware, ...
                'uiClock', this.uiClockLogPlotter ...
            );
            
            addlistener(this.uiScan.uiPrescriptionTool.uiFemTool, 'eSizeChange', @this.onFemToolSizeChange);
            addlistener(this.uiScan.uiPrescriptionTool, 'eNew', @this.onPrescriptionToolNew);
            addlistener(this.uiScan.uiPrescriptionTool, 'eDelete', @this.onPrescriptionToolDelete);
           
            % Cannot directly pass the function handle of the build method
            % of the bl12014.ui.* instances but I found that passing an
            % anonymous function that calls bl12014.ui.*.build() works
            %
            % Does not work: function handle of method of property
            % st.fhOnClick = @this.uiBeamline.build;
            %
            % Does work: anonymous function that calls uiBeamline.build()
            % st.fhOnClick = @() this.uiBeamline.build()
              
            this.initInterferometry();
           
            this.uiTextDurationLabel = mic.ui.common.Text(...
                'cVal', 'Duration of last timer execution (ms)' ...
            );
            this.uiTextDurationOfTimerExecution = mic.ui.common.Text();
        
            this.loadStateFromDisk();
            
            this.uiButtonListClockTasks = mic.ui.common.Button(...
                'cText', 'List Clock Tasks', ...
                'fhOnClick', @this.onListClockTasks ...
            );
        
            this.uiHardware = bl12014.ui.Hardware(...
                'uiApp', this, ...
                'clock', this.clock, ...
                'uiClock', this.uiClockHardware, ...
                'hardware', this.hardware ...
            );
        
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-current-of-ring.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiCurrentOfRing = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'dWidthName', 50, ...
                'dWidthVal', 50, ...
                'lShowLabels', false, ...
                'lShowInitButton', false, ...
                'fhGet', @() this.hardware.getDCTCorbaProxy().SCA_getBeamCurrent(), ...
                ...'fhGet', @() this.hardware.getALS().getCurrentOfRing(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'current-of-ring'], ...
                'config', uiConfig, ...
                'cLabel', 'ALS mA' ...
            );
        
            this.uiDMIPowerMonitor = bl12014.ui.DMIPowerMonitor(...
                'hardware', this.hardware, ...
                'clock', this.clock, ...
                'uiClock', this.uiClockDMIPowerMonitor ...
            );
        
            this.uiPowerPmacHydraMotMinMonitor = bl12014.ui.PowerPmacHydraMotMinMonitor(...
                'hardware', this.hardware, ...
                'clock', this.clock, ...
                'uiClock', this.uiClockDMIPowerMonitor ...
            );

        end
        
        function onListClockTasks(this, src, evt)
            this.clock.listTasks();
        end
        
        function onCloseRequest(this, src, evt)
            this.fhOnCloseFigure(); % in test, calls this.delete()
        end
            
        function onPrescriptionToolNew(this, src, evt)
            % this.uiScan.refreshPrescriptions();
        end
        
        function onPrescriptionToolDelete(this, src, evt)
            % this.uiScan.refreshPrescriptions();
        end
        
        function onPupilFillNew(this, src, evt)
            % uil property is private, so I exposed a public method
            this.uiScan.uiPrescriptionTool.pupilFillSelect.refreshList();
        end
        
        function onPupilFillDelete(this, src, evt)
            % uil property is private, so I exposed a public method
            this.uiScan.uiPrescriptionTool.pupilFillSelect.refreshList();
        end
        
        function c = file(this)
            mic.Utils.checkDir(this.cDirSave);
            c = fullfile(...
                this.cDirSave, ...
                ['saved-state', '.mat']...
            );
            c = mic.Utils.path2canonical(c);
        end
        
        
        function stopAllUiClocks(this)
            
            this.uiClockHardware.stop();
            this.uiClockNetworkCommunication.stop();
            this.uiClockBeamline.stop();
            this.uiClockM143.stop();
            this.uiClockDCT.stop();
            this.uiClockVibrationIsolationSystem.stop();
            this.uiClockReticle.stop();
            this.uiClockWafer.stop();
            this.uiClockPowerPmacStatus.stop();
            this.uiClockPrescriptionTool.stop();
            this.uiClockScan.stop();
            this.uiClockTempSensors.stop();
            this.uiClockFocusSensor.stop();
            this.uiClockDriftMonitor.stop();
            this.uiClockLSIControl.stop();
            this.uiClockLSIAnalyze.stop();
            this.uiClockScannerM142.stop();
            this.uiClockMA.stop();
            this.uiClockHeightSensorLEDs.stop();
            this.uiClockCameraLEDs.stop();
            this.uiClockScanResultPlot2x2.stop();
            this.uiClockLogPlotter.stop();
            this.uiClockPOCurrent.stop();
            this.uiClockMfDriftMonitorVibration.stop();
            this.uiClockMfDriftMonitor.stop();
            this.uiClockTuneFluxDensity.stop();
            this.uiClockPowerPmacHydraMotMin.stop();
        end
        
        function startUiClockOfActiveTab(this)
            cTab = this.uiTabGroup.getSelectedTabName();
            
            switch cTab
                case 'Beamline'
                    this.uiClockBeamline.start();
                case 'Field Scanner (M142)'
                     this.uiClockScannerM142.start();
                case 'M143'
                    this.uiClockM143.start();
                case 'DCT'
                    this.uiClockDCT.start();
                case 'MA'
                    this.uiClockMA.start();
                case 'VIS'
                    this.uiClockVibrationIsolationSystem.start();
                case 'Drift Monitor Vib'
                    this.uiClockMfDriftMonitorVibration.start();
                case 'Drift Monitor'
                     this.uiClockDriftMonitor.start();
                case 'Reticle'
                    this.uiClockReticle.start();
                case 'Wafer'
                    this.uiClockWafer.start();
                case 'PPMAC Status'
                    this.uiClockPowerPmacStatus.start();
                case 'PPMAC Hydra Mot Min'
                    this.uiClockPowerPmacHydraMotMin.start();
                case 'Pre Tool'
                    this.uiClockPrescriptionTool.start();
                case 'FEM Control'
                    this.uiClockScan.start();
                case 'PO Current'
                    this.uiClockPOCurrent.start();
                case 'Camera LEDs'
                    this.uiClockCameraLEDs.start();
                case 'FEM Plotter'
                    this.uiClockScanResultPlot2x2.start();
                case 'Height Sensor LEDs'
                    this.uiClockHeightSensorLEDs.start();
                case 'Log Plotter'
                    this.uiClockLogPlotter.start();
                case 'Network Status'
                    this.uiClockNetworkCommunication.start();
                case 'Hardware'
                    this.uiClockHardware.start();
                case 'Tune Flux Density'
                    this.uiClockTuneFluxDensity.start();
                    

            end
        end
        
        
        function onUiTabGroup(this)
            
            cTab = this.uiTabGroup.getSelectedTabName();
            lIsBuilt = this.lIsTabBuilt(strcmp(cTab, this.cecTabs));
            
            this.stopAllUiClocks();
            this.startUiClockOfActiveTab();
            
            if lIsBuilt
                % Already built
                return;
            end
            
            % Store that it has been built
            this.lIsTabBuilt(strcmp(cTab, this.cecTabs)) = true;
            hTab = this.uiTabGroup.getTabByName(cTab);
            
            switch cTab
                case 'Beamline'
                    this.uiBeamline.build(hTab, 10, 30);
                case 'Field Scanner (M142)'
                     this.uiScannerM142.build(hTab, 10, 30);
                case 'M143'
                    this.uiM143.build(hTab, 10, 30);
                case 'MA'
                    this.uiMA.build(hTab, 10, 30);
                case 'DCT'
                    this.uiDCT.build(hTab, 10, 30);
                case 'VIS'
                    this.uiVibrationIsolationSystem.build(hTab, 10, 30);
                case 'Drift Monitor Vib'
                    this.uiMfDriftMonitorVibration.build(hTab, 10, 30);
                case 'Drift Monitor'
                     this.uiDriftMonitor.build(hTab, 10, 30);
                case 'Reticle'
                    this.uiReticle.build(hTab, 10, 30);
                case 'Wafer'
                    this.uiWafer.build(hTab, 10, 30);
                case 'PPMAC Status'
                    this.uiPowerPmacStatus.build(hTab, 10, 30);
                case 'PPMAC Hydra Mot Min'
                    this.uiPowerPmacHydraMotMin.build(hTab, 10, 30);
                    this.uiPowerPmacAccel.build(hTab, 10, 600);
                case 'FEM Control'
                    this.uiScan.build(hTab, 10, 30);
                case 'PO Current'
                    this.uiPOCurrent.build(hTab, 10, 30);
                case 'Camera LEDs'
                    this.uiCameraLEDs.build(hTab, 10, 30);
                case 'FEM Plotter'
                    this.uiScanResultPlot2x2.build(hTab, 10, 30);
                case 'Height Sensor LEDs'
                    this.uiHeightSensorLEDs.build(hTab, 10, 30);
                case 'Log Plotter'
                    this.uiLogPlotter.build(hTab, 10, 10);
                case 'Network Status'
                    this.uiNetworkCommunication.build(hTab, 10, 10);
                case 'Hardware'
                    this.uiHardware.build(hTab, 10, 10);
                case 'Tune Flux Density'
                    this.uiTuneFluxDensity.build(hTab, 10, 10);
                    

            end
            
            
        end
        
    end % private
    
    
end