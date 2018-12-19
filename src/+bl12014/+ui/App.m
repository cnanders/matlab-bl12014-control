classdef App < mic.Base
        
    properties (Constant)
        
        dWidth = 750
        dHeight = 550
        
        lUseDock = true;
                       
    end
    
	properties
        
        cName = 'ui.App'
        
        
        waferExposureHistory
        uiNetworkCommunication
        uiBeamline
        uiShutter
        
        uiM143

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
        uiMfDriftMonitorVibration
        uiButtonListClockTasks
        
        % Eventually make private.
        % Exposing for troubleshooting
        clock
        
        % { mic.ClockGroup 1x1}
        clockNetworkCommunication
        clockBeamline
        clockShutter
       
        clockM143
       
        clockVibrationIsolationSystem
        clockReticle
        clockWafer
        clockPowerPmacStatus
        clockPrescriptionTool
        clockScan
        clockTempSensors
        clockFocusSensor
        clockDriftMonitor
        clockLSIControl
        clockLSIAnalyze
        clockScannerM142
        clockScannerMA
        clockHeightSensorLEDs
        clockCameraLEDs
        clockScanResultPlot2x2
        clockMeasurPointLogPlotter
        clockMADiagnostics
        clockPOCurrent
        clockMfDriftMonitorVibration
        clockMfDriftMonitor

    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        cecTabs = {...
            'Beamline', ...
            'Field Scanner (M142)', ...
            'M143', ...
            'Pupil Scanner (MA)', ...
            'MA Diagnostics', ...
            'VIS', ...
            'Drift Monitor Vib', ...
            'Drift Monitor', ...
            'Reticle', ...
            'Wafer', ...
            'Pre Tool', ...
            'FEM Control', ...
            'PO Current', ...
            'PPMAC Status', ....
            'Camera LEDs', ...
            'MeasurPoint Log', ...
            'Height Sensor LEDs', ...
            'Network Status', ...
            '2x2 Plotter' ...
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
        
        hHardware
        dDelay = 0.5
        dColorOn = [0 0.9 0]
        dColorOff = [0.9 0.9 0.9]
        
        uiTextDurationLabel
        uiTextDurationOfTimerExecution
        
        hFigureNew
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
                    'Position', [50 50 400 250], ... % left bottom width height
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
            this.uiButtonListInterferometry.build(this.hFigure, 10, 10);
            
            
            % Tab-based 
            this.buildNew();
            % this.onUiTabGroup();
            
        end
        
        function buildNew(this)
            
            dWidth = 1850;
            dHeight = 1040;
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigureNew = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name', 'MET5 Control',...
                'Position', [ ...
                (dScreenSize(3) - dWidth)/2 ...
                (dScreenSize(4) - dHeight)/2 ...
                dWidth ...
                dHeight ...
                ],... % left bottom width height
                'Toolbar', 'figure', ... % zoom tools
                'Resize', 'off',...
                'WindowButtonMotionFcn', @this.onFigureWindowMouseMotion, ...
                'WindowButtonDownFcn', @this.onFigureWindowMouseDown, ... % doesn't work if datacursormode is on!
                'HandleVisibility', 'on',... % lets close all close the figure
                ... % 'CloseRequestFcn', @this.onCloseRequest, ...
                'Visible', 'on'...
            );
            this.uiTabGroup.build(this.hFigureNew, 0, 25, dWidth, dHeight - 2);
            
            this.uiTextDurationLabel.build(...
                this.hFigureNew, ...
                10, ... % left
                5, ... % top
                180, ... % width
                12 ...
            );
            this.uiTextDurationOfTimerExecution.build(...
                this.hFigureNew, ...
                190, ... % left
                5, ... % top
                200, ... % width
                12 ...
            );
        
            this.uiButtonListClockTasks.build(this.hFigureNew, 290, 5, 100, 20);
        
            if ~isempty(this.clock) && ...
                ~this.clock.has(this.id())
                this.clock.add(@this.onClock, this.id(), this.dDelay);
            end
            
            
        end
        
        
        function onFigureWindowMouseDown(this, src, evt)
           
            cTab = this.uiTabGroup.getSelectedTabName();
            
            switch cTab
               case 'Beamline'
                    this.uiBeamline.showSetAsZeroIfFigureClickIsInAxes(this.hFigureNew);
               
            end
            
        end
        
        
        function onFigureWindowMouseMotion(this, src, evt)
           
           % this.msg('onWindowMouseMotion()');
           cTab = this.uiTabGroup.getSelectedTabName();
            
           switch cTab
               case 'Beamline'
                    this.uiBeamline.updateAxesCrosshair(this.hFigureNew);
               case 'MeasurPoint Log'
                    this.uiMeasurPointLogPlotter.setTextPlotXPlotYBasedOnAxesCurrentPoint(this.hFigureNew);
           end
           
        end
        
        
        
        
        

        
        
       
        function onClock(this)
            
            cDuration = sprintf('%1.1f', this.clock.getDurationOfLastTimerExecution() * 1000);
            dNum = this.clock.getNumberOfActiveTasks();
            
            cVal = sprintf('%s (%1.0f tasks)', cDuration, dNum);
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
            delete(this.uiBeamline)
            delete(this.uiNetworkCommunication)
            delete(this.uiMADiagnostics)
            delete(this.uiM143)
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
            delete(this.uiMfDriftMonitorVibration);
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
                'uiMADiagnostics', ...
                'uiPOCurrent', ...
                'uiM143', ...
                ...% 'uiVibrationIsolationSystem', ...
                'uiReticle', ...
                'uiWafer', ...
                'uiScanResultPlot2x2', ...
                'uiMeasurPointLogPlotter', ...
                'uiMfDriftMonitorVibration', ...
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
            
            this.clock = mic.Clock('Master');
            
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
                                   
            % Set clock, required for drift monitor middle layer
            this.hHardware.setClock(this.clock);            
            this.clockNetworkCommunication = mic.ClockGroup(this.clock);
            this.clockBeamline = mic.ClockGroup(this.clock);
            this.clockM143 = mic.ClockGroup(this.clock);
            this.clockVibrationIsolationSystem = mic.ClockGroup(this.clock);
            this.clockReticle = mic.ClockGroup(this.clock);
            this.clockWafer = mic.ClockGroup(this.clock);
            this.clockPowerPmacStatus = mic.ClockGroup(this.clock);
            this.clockPrescriptionTool = mic.ClockGroup(this.clock);
            this.clockScan = mic.ClockGroup(this.clock);
            this.clockTempSensors = mic.ClockGroup(this.clock);
            this.clockFocusSensor = mic.ClockGroup(this.clock);
            this.clockDriftMonitor = mic.ClockGroup(this.clock);
            this.clockLSIControl = mic.ClockGroup(this.clock);
            this.clockLSIAnalyze = mic.ClockGroup(this.clock);
            this.clockScannerM142 = mic.ClockGroup(this.clock);
            this.clockScannerMA = mic.ClockGroup(this.clock);
            this.clockHeightSensorLEDs = mic.ClockGroup(this.clock);
            this.clockCameraLEDs = mic.ClockGroup(this.clock);
            this.clockScanResultPlot2x2 = mic.ClockGroup(this.clock);
            this.clockMeasurPointLogPlotter = mic.ClockGroup(this.clock);
            this.clockMADiagnostics = mic.ClockGroup(this.clock);
            this.clockPOCurrent = mic.ClockGroup(this.clock);
            this.clockMfDriftMonitorVibration = mic.ClockGroup(this.clock);
            this.clockMfDriftMonitor = mic.ClockGroup(this.clock);
            
            this.uiNetworkCommunication = bl12014.ui.NetworkCommunication('clock', this.clockNetworkCommunication);
            
            this.uiBeamline = bl12014.ui.Beamline('clock', this.clockBeamline);
            this.uiScannerM142 = bl12014.ui.Scanner(...
                'clock', this.clockScannerM142, ...
                'cName', 'M142 Scanner' ...
            );
            this.uiM143 = bl12014.ui.M143('clock', this.clockM143);
            this.uiReticle = bl12014.ui.Reticle('clock', this.clockReticle);
            this.uiWafer = bl12014.ui.Wafer('clock', this.clockWafer, ...
                'waferExposureHistory', this.waferExposureHistory ...
            );
            this.uiPowerPmacStatus = bl12014.ui.PowerPmacStatus('clock', this.clockPowerPmacStatus);
            this.uiMfDriftMonitorVibration = bl12014.ui.MfDriftMonitorVibration('clock', this.clockMfDriftMonitorVibration);
            this.uiVibrationIsolationSystem = bl12014.ui.VibrationIsolationSystem('clock', this.clockVibrationIsolationSystem);
            this.uiTempSensors = bl12014.ui.TempSensors('clock', this.clockTempSensors);
            this.uiFocusSensor = bl12014.ui.FocusSensor('clock', this.clockFocusSensor);
            this.uiScannerMA = bl12014.ui.Scanner(...
                'clock', this.clockScannerMA, ...
                'cName', 'MA Scanner', ...
                'dScale', 0.67 ... % 0.67 rel amp = sig 1
            );
        
            
            % LSI UIs exist separately.  Check if exists first though
            % because not guaranteed to have this repo:
            this.uiLSIControl = lsicontrol.ui.LSI_Control('clock', this.clockLSIControl, ...
                                                           'hardware', this.hHardware);
            this.uiLSIAnalyze = lsianalyze.ui.LSI_Analyze();
            this.uiDriftMonitor = bl12014.ui.MFDriftMonitor('hardware', this.hHardware, ...
                               'clock', this.clockMfDriftMonitorVibration);
           
            this.uiPrescriptionTool = bl12014.ui.PrescriptionTool();
            this.uiScan = bl12014.ui.Scan(...
                'clock', this.clock, ... % DONT GIVE A CLOCK GROUP!
                'uiShutter', this.uiBeamline.uiShutter.uiShutter, ...
                'uiReticle', this.uiReticle, ...
                'uiWafer', this.uiWafer, ...
                'uiVibrationIsolationSystem', this.uiVibrationIsolationSystem, ...
                'uiMfDriftMonitorVibration', this.uiMfDriftMonitorVibration, ...
                'uiMFDriftMonitor', this.uiDriftMonitor, ...
                'waferExposureHistory', this.waferExposureHistory, ...
                'uiBeamline', this.uiBeamline ...
            );

            this.uiHeightSensorLEDs = bl12014.ui.HeightSensorLEDs(...
                'clock', this.clockHeightSensorLEDs ...
            );
            this.uiCameraLEDs = bl12014.ui.CameraLEDs(...
                'clock', this.clockCameraLEDs ...
            );
            this.uiScanResultPlot2x2 = bl12014.ui.ScanResultPlot2x2('clock', this.clockScanResultPlot2x2);
            
            this.uiMADiagnostics = bl12014.ui.MADiagnostics('clock', this.clockMADiagnostics);
            this.uiPOCurrent = bl12014.ui.POCurrent('clock', this.clockPOCurrent);
            
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
        
        
        function stopAllClockGroups(this)
            
            this.clockNetworkCommunication.stop();
            this.clockBeamline.stop();
            this.clockM143.stop();
            this.clockVibrationIsolationSystem.stop();
            this.clockReticle.stop();
            this.clockWafer.stop();
            this.clockPowerPmacStatus.stop();
            this.clockPrescriptionTool.stop();
            % this.clockScan.stop();
            this.clockTempSensors.stop();
            this.clockFocusSensor.stop();
            this.clockDriftMonitor.stop();
            this.clockLSIControl.stop();
            this.clockLSIAnalyze.stop();
            this.clockScannerM142.stop();
            this.clockScannerMA.stop();
            this.clockHeightSensorLEDs.stop();
            this.clockCameraLEDs.stop();
            this.clockScanResultPlot2x2.stop();
            this.clockMeasurPointLogPlotter.stop();
            this.clockMADiagnostics.stop();
            this.clockPOCurrent.stop();
            this.clockMfDriftMonitorVibration.stop();
            this.clockMfDriftMonitor.stop();
        end
        
        function startClockGroupOfActiveTab(this)
            cTab = this.uiTabGroup.getSelectedTabName();
            
            switch cTab
                case 'Beamline'
                    this.clockBeamline.start();
                case 'Shutter'
                     this.clockShutter.start();
                case 'Field Scanner (M142)'
                     this.clockScannerM142.start();
                case 'M143'
                    this.clockM143.start();
                case 'Pupil Scanner (MA)'
                    this.clockScannerMA.start();
                case 'MA Diagnostics'
                    this.clockMADiagnostics.start();
                case 'VIS'
                    this.clockVibrationIsolationSystem.start();
                case 'Drift Monitor Vib'
                    this.clockMfDriftMonitorVibration.start();
                case 'Drift Monitor'
                     this.clockDriftMonitor.start();
                case 'Reticle'
                    this.clockReticle.start();
                case 'Wafer'
                    this.clockWafer.start();
                case 'PPMAC Status'
                    this.clockPowerPmacStatus.start();
                case 'Pre Tool'
                    this.clockPrescriptionTool.start();
                case 'FEM Control'
                    this.clockScan.start();
                case 'PO Current'
                    this.clockPOCurrent.start();
                case 'Camera LEDs'
                    this.clockCameraLEDs.start();
                case '2x2 Plotter'
                    this.clockScanResultPlot2x2.start();
                case 'Height Sensor LEDs'
                    this.clockHeightSensorLEDs.start();
                case 'MeasurPoint Log'
                    this.clockMeasurPointLogPlotter.start();
                case 'Network Status'
                    this.clockNetworkCommunication.start();
                    

            end
        end
        
        
        function onUiTabGroup(this)
            
            cTab = this.uiTabGroup.getSelectedTabName();
            lIsBuilt = this.lIsTabBuilt(strcmp(cTab, this.cecTabs));
            
            this.stopAllClockGroups();
            this.startClockGroupOfActiveTab();
            
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
                case 'Shutter'
                     this.uiShutter.build(hTab, 10, 30);
                case 'Field Scanner (M142)'
                     this.uiScannerM142.build(hTab, 10, 30);
                case 'M143'
                    this.uiM143.build(hTab, 10, 30);
                case 'Pupil Scanner (MA)'
                    this.uiScannerMA.build(hTab, 10, 30);
                case 'MA Diagnostics'
                    this.uiMADiagnostics.build(hTab, 10, 30);
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
               
                case 'Pre Tool'
                    this.uiPrescriptionTool.build(hTab, 10, 30);
                case 'FEM Control'
                    this.uiScan.build(hTab, 10, 30);
                case 'PO Current'
                    this.uiPOCurrent.build(hTab, 10, 30);
                case 'Camera LEDs'
                    this.uiCameraLEDs.build(hTab, 10, 30);
                case '2x2 Plotter'
                    this.uiScanResultPlot2x2.build(hTab, 10, 30);
                case 'Height Sensor LEDs'
                    this.uiHeightSensorLEDs.build(hTab, 10, 30);
                case 'MeasurPoint Log'
                    this.uiMeasurPointLogPlotter.build(hTab, 10, 10);
                case 'Network Status'
                    this.uiNetworkCommunication.build(hTab, 10, 10);
                    

            end
            
            
        end
        
    end % private
    
    
end