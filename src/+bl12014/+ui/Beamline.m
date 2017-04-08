classdef Beamline < mic.Base
    
    
    properties (Constant, Access = private)
        
        dWidth = 620
        dHeight = 680
        
        dWidthPanelScan = 600
        dHeightPanelScan = 80
        
        dWidthPanelData = 600
        dHeightPanelData = 340
        
        dWidthPanelDevices = 600
        dHeightPanelDevices = 225
        
        dWidthRecipeEdit = 60
        dWidthRecipeButton = 60
        dWidthRecipePopup = 150
        dWidthRecipeUnit = 50
        
        
        dWidthFigurePad = 10
        dHeightFigurePad = 10
        
        dWidthPanelBorder = 0
        dWidthPadH = 10
        
        dHeightUi = 24
        
        dSizeMarker = 8
        
        
        cNameDeviceExitSlit = 'exit_slit'
        cNameDeviceUndulatorGap = 'undulator_gap'
        cNameDeviceShutter = 'shutter'
        cNameDeviceGratingTiltX = 'grating_tilt_x'
        cNameDeviceD142StageY = 'd142_stage_y'
        cNameDeviceMeasurPointD142 = 'measur_point_d142'
        
        
        
        dColorFigure = [200 200 200]./255
        dColorPanelData = [1 1 1]
    end
    
    properties
        
        % {< mic.interface.device.GetSetNumber}
        deviceExitSlit
        
        % {< mic.interface.device.GetSetNumber}
        deviceUndulatorGap
        
        % {< mic.interface.device.GetSetNumber}
        deviceGratingTiltX
        
        % {< mic.interface.device.GetSetNumber}
        deviceShutter
        
        
        
        
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiExitSlit
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiUndulatorGap
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiShutter
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiGratingTiltX
        
         % {mic.ui.device.GetSetNumber 1x1}
        uiD142StageY
        
        % {mic.ui.device.GetNumber 1x1}
        uiMeasurPointD142
        
        
    end
    
    
    properties (SetAccess = private)

        cName = 'Beamline'
        
    end
    
    properties (Access = private)
        
        clock
        
        cDirThis
        cDirSrc
        cDirSave
        
        hFigure
        hPanelDevices
        hPanelScan
        hPanelScanPlot
        hPanelData
        hAxes
        % storage for handles returned by plot()
        hLines
        
        dWidthName = 70
        
        configStageY
        configMeasPointVolts 
        
        uiPopupRecipeDevice
        uiEditRecipeStart
        uiEditRecipeStop
        uiEditRecipeSteps
        uiTextRecipeUnit
        
        uiToggleScanPause
        uiButtonScanAbort
        uiButtonScanStart
         
        % Stores the values of the start, stop, steps of each device type.
        % When the device popup switches, the start, stop, steps initialize
        % to the last stored values for that device type
        stUiRecipeStore
        
        
        % {double 1xm} x axis on 1D plot storage for the value of the scanned parameter
        dScanDataParam  
        % {double 1xm} y axis on 1D plot storage for the acquired valued
        dScanDataValue
        
        stScanAcquireContract
        stScanSetContract
        
        cNameRecipe
        
        
    end
    
    methods
        
        function this = Beamline(varargin)
            
            this.cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSrc = fullfile(this.cDirThis, '..', '..');
            this.cDirSave = fullfile(this.cDirSrc, 'save', 'beamline-scans');
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        
        function turnOn(this)
            
            this.uiExitSlit.turnOn();
            this.uiUndulatorGap.turnOn();
            this.uiShutter.turnOn();
            this.uiGratingTiltX.turnOn();
            this.uiTiltY.turnOn();
            this.uiD142StageY.turnOn();
            this.uiMeasurPointD142.turnOn();
            
        end
        
        function turnOff(this)
            this.uiExitSlit.turnOff();
            this.uiUndulatorGap.turnOff();
            this.uiShutter.turnOff();
            this.uiGratingTiltX.turnOff();
            this.uiTiltY.turnOff();
            this.uiD142StageY.turnOff();
            this.uiMeasurPointD142.turnOff();
            
        end
        
        
        
        
        
        function build(this)
            
            this.buildFigure();
            this.buildPanelDevices();
            this.buildUiDevices()
            this.buildPanelRecipe();
            this.buildUiRecipe()
            this.buildPanelData();
            this.buildAxes();
            
            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end

        end
        
        
        function st = save(this)
            st = struct();
            st.stUiRecipeStore = this.stUiRecipeStore;
            
        end
        
        function  load(this, st)
            this.stUiRecipeStore = st.stUiRecipeStore;
        end
        
    end
    
    methods (Access = private)
        
        function buildFigure(this)
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            else 
            
                
                dHeight = this.dHeightFigurePad + ...
                    this.dHeightPanelScan + ...
                    this.dHeightPanelData + ...
                    this.dHeightFigurePad + ...
                    this.dHeightPanelDevices + ...
                    this.dHeightFigurePad;
                
                dScreenSize = get(0, 'ScreenSize');
                this.hFigure = figure( ...
                    'NumberTitle', 'off', ...
                    'MenuBar', 'none', ...
                    'Name', 'Beamline Control', ...
                    'Color', this.dColorFigure, ...
                    'CloseRequestFcn', @this.onFigureCloseRequest, ...
                    'Position', [ ...
                        (dScreenSize(3) - this.dWidth)/2 ...
                        (dScreenSize(4) - dHeight)/2 ...
                        this.dWidth ...
                        dHeight ...
                     ],... % left bottom width height
                    'Resize', 'off', ... 
                    'WindowButtonMotionFcn', @this.onFigureWindowMouseMotion, ...
                    'HandleVisibility', 'on', ... % lets close all close the figure
                    'Visible', 'on' ...
                );

                % pan(this.hFigure);
                % zoom(this.hFigure);
                % set(this.hFigure, 'toolbar', 'figure');
                datacursormode(this.hFigure, 'on');
            end
            
        end
        
        
        function buildPanelData(this)
            
            dLeft = this.dWidthFigurePad;
            dTop = this.dHeightFigurePad + this.dHeightPanelScan; % No vertical pad between scan and data panels
            this.hPanelData = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', '',...
                'BorderWidth', this.dWidthPanelBorder, ...
                'Clipping', 'on',...
                'BackgroundColor', this.dColorPanelData, ...
                'Position', mic.Utils.lt2lb([ ...
                    dLeft ...
                    dTop ...
                    this.dWidthPanelData ...
                    this.dHeightPanelData], ...
                    this.hFigure ...
                ) ...
            );
        
			drawnow; 
            
        end
        
        function buildAxes(this)
            
            dWidthPadL = 50;
            dWidthPadR = 20;
            dHeightPadT = 20;
            dHeightPadB = 50;
            dWidth = this.dWidthPanelData - dWidthPadL - dWidthPadR;
            dTop = dHeightPadT;
            dLeft = dWidthPadL;
            dHeight = this.dHeightPanelData -  dHeightPadT - dHeightPadB;
            
            this.hAxes = axes(...
                'Parent', this.hPanelData, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, dWidth, dHeight], this.hPanelData),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on', ... 
                'NextPlot', 'add', ... % Important.  Look this up in help makes it so 
                'ButtonDownFcn', @this.onAxesButtonDown ...
            );
            hold(this.hAxes, 'on');

            % 'FontSize', this.dSizeFont, ...

        end
        
        function buildPanelDevices(this)
            
            dLeft = this.dWidthFigurePad;
            dTop = this.dHeightFigurePad + ...
                this.dHeightPanelScan + ...
                this.dHeightPanelData + ...
                this.dHeightFigurePad;
            
            this.hPanelDevices = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Devices',...
                'BorderWidth', this.dWidthPanelBorder, ...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                    dLeft ...
                    dTop ...
                    this.dWidthPanelDevices ...
                    this.dHeightPanelDevices], ...
                    this.hFigure ...
                ) ...
            );
        
			drawnow; 
            
        end
        
        function buildUiDevices(this)

            dTop = 20;
            dLeft = 10;
            dSep = 30;
            
            this.uiExitSlit.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiUndulatorGap.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiShutter.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiGratingTiltX.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiD142StageY.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiMeasurPointD142.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            
        end
        
        function buildPanelRecipe(this)
            
            dLeft = this.dWidthFigurePad;
            dTop = this.dHeightFigurePad;
            this.hPanelScan = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Scan',...
                'BorderWidth', this.dWidthPanelBorder, ...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                    dLeft ...
                    dTop ...
                    this.dWidthPanelScan ...
                    this.dHeightPanelScan], ...
                    this.hFigure ...
                ) ...
            );
        
            drawnow;
            
        end
        
        function buildUiRecipe(this)
            
            dTop = 20;
            dLeft = 20;
            
            this.uiPopupRecipeDevice.build( ...
                this.hPanelScan, ...
                dLeft, ...
                dTop, ...
                this.dWidthRecipePopup, ...
                this.dHeightUi ...
            );
            dLeft = dLeft + this.dWidthRecipePopup + this.dWidthPadH;
            
            this.uiTextRecipeUnit.build( ...
                this.hPanelScan, ...
                dLeft, ...
                dTop, ...
                this.dWidthRecipeUnit, ...
                this.dHeightUi ...
            );
            dLeft = dLeft + this.dWidthRecipeUnit + this.dWidthPadH;
            
            this.uiEditRecipeStart.build( ...
                this.hPanelScan, ...
                dLeft, ...
                dTop, ...
                this.dWidthRecipeEdit, ...
                this.dHeightUi ...
            );
            dLeft = dLeft + this.dWidthRecipeEdit + this.dWidthPadH;
                                                
            this.uiEditRecipeStop.build( ...
                this.hPanelScan, ...
                dLeft, ...
                dTop, ...
                this.dWidthRecipeEdit, ...
                this.dHeightUi ...
            );
            dLeft = dLeft + this.dWidthRecipeEdit + this.dWidthPadH;
            
            this.uiEditRecipeSteps.build( ...
                this.hPanelScan, ...
                dLeft, ...
                dTop, ...
                this.dWidthRecipeEdit, ...
                this.dHeightUi ...
            );
            dLeft = dLeft + this.dWidthRecipeEdit + this.dWidthPadH;
            
            dTop = dTop + 12;
            this.uiButtonScanStart.build( ...
                this.hPanelScan, ...
                dLeft, ...
                dTop, ...
                this.dWidthRecipeButton, ...
                this.dHeightUi ...
            );
        
            this.uiToggleScanPause.build( ...
                this.hPanelScan, ...
                dLeft, ...
                dTop, ...
                this.dWidthRecipeButton, ...
                this.dHeightUi ...
            );
            dLeft = dLeft + this.dWidthRecipeButton + this.dWidthPadH;
            % dTop = dTop + 30
            
            this.uiButtonScanAbort.build( ...
                this.hPanelScan, ...
                dLeft, ...
                dTop, ...
                this.dWidthRecipeButton, ...
                this.dHeightUi ...
            );
        
            this.hideScanPauseAbort();
            this.onPopupRecipeDevice();
        
        end
        
        
        function initUiD142StageY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-d142-stage-y.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiD142StageY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', 'd142-stage-y', ...
                'config', uiConfig, ...
                'dWidthName', this.dWidthName, ...
                'lShowLabels', false, ...
                'cLabel', 'D142 Stage Y' ...
            );
        
            addlistener(this.uiD142StageY, 'eUnitChange', @this.onUnitChange);
        end
        
        
        function initUiMeasurPointD142(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-d142-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiMeasurPointD142 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', 'measur-point-d142-diode', ...
                'config', uiConfig, ...
                'dWidthName', this.dWidthName, ...
                'cLabel', 'MeasurPoint (D142)', ...
                'dWidthPadUnit', 277, ...
                'lShowLabels', false ...
            );
        
            addlistener(this.uiMeasurPointD142, 'eUnitChange', @this.onUnitChange);
        end 
         
        function initUiExitSlit(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-exit-slits.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiExitSlit = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'cName', 'exit-slit', ...
                'config', uiConfig, ...
                'cLabel', 'Exit Slit' ...
            );
        
            addlistener(this.uiExitSlit, 'eUnitChange', @this.onUnitChange);
        end
        
        function initUiUndulatorGap(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-undulator-gap.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiUndulatorGap = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', 'undulator-gap', ...
                'config', uiConfig, ...
                'cLabel', 'Undulator Gap' ...
            );
        
            addlistener(this.uiUndulatorGap, 'eUnitChange', @this.onUnitChange);
        end
        
        function initUiShutter(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-shutter.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiShutter = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', 'shutter', ...
                'config', uiConfig, ...
                'cLabel', 'Shutter' ...
            );
        
            addlistener(this.uiShutter, 'eUnitChange', @this.onUnitChange);
        end
        
        
        function initUiGratingTiltX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-grating-tilt-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiGratingTiltX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', 'grating-tilt-x', ...
                'config', uiConfig, ...
                'cLabel', 'Grating Tilt X' ...
            );
        
            addlistener(this.uiGratingTiltX, 'eUnitChange', @this.onUnitChange);
        end
        
        function initUiRecipe(this)
            
        
            stDeviceTypeExitSlit = struct(...
                'cLabel', 'Exit Slit', ...
                'cValue', this.cNameDeviceExitSlit ...
            );
            stDeviceTypeUndulatorGap = struct(...
                'cLabel', 'Undulator Gap', ...
                'cValue', this.cNameDeviceUndulatorGap ...
            );
            stDeviceTypeShutter = struct( ...
                'cLabel', 'Shutter', ...
                'cValue', this.cNameDeviceShutter ...
            );
            stDeviceTypeGratingTiltX = struct( ...
                'cLabel', 'Grating Tilt X', ...
                'cValue', this.cNameDeviceGratingTiltX ...
            );
            stDeviceTypeD142StageY = struct( ...
                'cLabel', 'D142 Stage Y', ...
                'cValue', this.cNameDeviceD142StageY ...
            );  
            ceOptions = { ...
                stDeviceTypeExitSlit, ...
                stDeviceTypeUndulatorGap, ...
                stDeviceTypeShutter, ...
                stDeviceTypeGratingTiltX, ...
                stDeviceTypeD142StageY ...
            };
        
            
        
            this.uiPopupRecipeDevice = mic.ui.common.PopupStruct(...
                'ceOptions', ceOptions, ...
                'cField', 'cLabel', ...
                'cLabel', 'Device' ...
            );
        
            this.uiEditRecipeStart = mic.ui.common.Edit(...
                'cType', 'd', ... % double
                'cLabel', 'Start' ...
            );
            
            this.uiEditRecipeStop = mic.ui.common.Edit(...
                'cType', 'd', ... % double
                'cLabel', 'Stop' ...
            );
        
            this.uiEditRecipeSteps = mic.ui.common.Edit(...
                'cType', 'u8', ... % uint8
                'cLabel', 'Steps' ...
            );
        
            this.uiTextRecipeUnit = mic.ui.common.Text(...
                'lShowLabel', true, ...
                'cLabel', 'Unit', ...
                '...' ...
            );
        
            addlistener(this.uiPopupRecipeDevice, 'eChange', @this.onPopupRecipeDevice);
            addlistener(this.uiEditRecipeStart, 'eChange', @this.onEditRecipeStart);
            addlistener(this.uiEditRecipeStop, 'eChange', @this.onEditRecipeStop);
            addlistener(this.uiEditRecipeSteps, 'eChange', @this.onEditRecipeSteps);
        end
        
        function onPopupRecipeDevice(this, src, evt)
            
            this.msg('onPopupRecipeDevice()')
            
            stStore = this.stUiRecipeStore.(this.uiPopupRecipeDevice.get().cValue);
            this.uiEditRecipeStart.setWithoutNotify(stStore.start);
            this.uiEditRecipeStop.setWithoutNotify(stStore.stop);
            this.uiEditRecipeSteps.setWithoutNotify(stStore.steps);

            this.resetScanData();
            this.updatePlotLabels();
            this.updateRecipeUnit();
            
        end
        
        function onEditRecipeStart(this, src, evt)
            this.stUiRecipeStore.(this.uiPopupRecipeDevice.get().cValue).start = src.get();
            this.resetScanData();
        end
      
        function onEditRecipeStop(this, src, evt)
            this.stUiRecipeStore.(this.uiPopupRecipeDevice.get().cValue).stop = src.get();
            this.resetScanData();
        end
        
        function onEditRecipeSteps(this, src, evt)
            this.stUiRecipeStore.(this.uiPopupRecipeDevice.get().cValue).steps = src.get();
            this.resetScanData();
        end
        
        function initUiScan(this)
            
            this.uiButtonScanStart = mic.ui.common.Button(...
                'cText', 'Start' ...
            );
            
            this.uiToggleScanPause = mic.ui.common.Toggle(...
                'cTextFalse', 'Pause', ...
                'cTextTrue', 'Resume' ...
            );
        
            this.uiButtonScanAbort = mic.ui.common.Button(...
                'cText', 'Abort', ...
                'lAsk', true, ...
                'cMsg', 'The scan is now paused.  Are you sure you want to abort?' ... 
            );
            
            addlistener(this.uiButtonScanAbort, 'ePress', @this.onButtonScanAbortPress);
            addlistener(this.uiButtonScanAbort, 'eChange', @this.onButtonScanAbort);
            addlistener(this.uiToggleScanPause, 'eChange', @this.onButtonScanPause);
            addlistener(this.uiButtonScanStart, 'eChange', @this.onButtonScanStart);
        
        end
        
        function init(this)
            this.msg('init()');
            this.initUiExitSlit();
            this.initUiUndulatorGap();
            this.initUiShutter();
            this.initUiGratingTiltX();
            this.initUiD142StageY()
            this.initUiMeasurPointD142();
            
            this.initUiRecipe();
            this.initUiScan();
            this.initUiRecipeStore();
            
            this.initScanAcquireContract();
            this.initScanSetContract();
        end
         
        function onFigureCloseRequest(this, src, evt)
            
            this.msg('onFigureCloseRequest()');
            if ~isvalid(this.hFigure)
                return
            end
            
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        function onFigureWindowMouseMotion(this, src, evt)
           
           % this.msg('onWindowMouseMotion()');
           % this.updateAxesCrosshair();
        end 
        
        function onButtonScanStart(this, src, evt)
            
            this.msg('onButtonScanStart');
            
            this.hideScanStart();
            this.showScanPauseAbort();
            
            this.cNameRecipe = this.getRecipeName();
            this.saveRecipeToDisk(this.cNameRecipe);
            this.startNewScan();
                       
        end
        
        function onButtonScanPause(this, ~, ~)
        
            if (this.uiToggleScanPause.get()) % just changed to true, so was playing
                this.scan.pause();
            else
                this.scan.resume();
            end
        end
        
        function onButtonScanAbortPress(this, ~, ~)
            this.scan.pause();
            this.uiToggleScanPause.set(true);
        end
        
        function onButtonScanAbort(this, ~, ~)
            this.scan.stop(); % calls onScanAbort()
        end
        
        function showScanStart(this)
            this.uiButtonScanStart.show();
        end
        
        function hideScanStart(this)
            this.uiButtonScanStart.hide();
        end
        
        function showScanPauseAbort(this)
            
            this.uiToggleScanPause.show();
            this.uiButtonScanAbort.show();
        end
        
        function hideScanPauseAbort(this)
            this.uiToggleScanPause.hide();
            this.uiButtonScanAbort.hide();
            
        end
        
        function startNewScan(this)
            
            [stRecipe, lError] = this.loadRecipeFromDisk(this.cNameRecipe);
            
            if lError 
                cMsg = 'There was an error building the scan recipe from the .json file.';
                
                % Throw message box.
                h = msgbox( ...
                    cMsg, ...
                    'Scan aborted', ...
                    'help', ...
                    'modal' ...
                );

                % wait for them to close the message
                % uiwait(h);

                this.showScanStart();
                this.hideScanPauseAbort();
                return;
            end

            this.scan = mic.StateScan(...
                this.clock, ...
                stRecipe, ...
                @this.onScanSetState, ...
                @this.onScanIsAtState, ...
                @this.onScanAcquire, ...
                @this.onScanIsAcquired, ...
                @this.onScanComplete, ...
                @this.onScanAbort ...
            );

            this.scan.start();
            
        end
        
        function resetScanData(this)
            
            this.msg('resetScanData()');
            
            dValues = linspace(...
                this.uiEditRecipeStart.get(), ...
                this.uiEditRecipeStop.get(), ...
                this.uiEditRecipeSteps.get() + uint8(1) ...
            );
            this.dScanDataParam = dValues;
            this.dScanDataValue = zeros(size(dValues)); 
            
            this.updatePlot()
            
        end
        
        function updatePlot(this)
            
            if  isempty(this.hAxes) || ...
                ~ishandle(this.hAxes)
               
                this.msg('updatePlot() returning due to empty Axes handle');
                return;
            end
            
            if ~isempty(this.hLines) && ishandle(this.hLines)
                delete(this.hLines);
            end
            
           
            this.hLines = plot(...
                this.hAxes, ...
                this.dScanDataParam, this.dScanDataValue, '.-r', ...
                'MarkerSize', this.dSizeMarker ...
            );
        
            
            
        end
        
        function updatePlotLabels(this)
            
            if  isempty(this.hAxes) || ...
                ~ishandle(this.hAxes)
               
                this.msg('updatePlotLabels() returning due to empty Axes handle');
                return;
            end
            
            cLabelX = sprintf(...
                '%s (%s)', ...
                this.uiPopupRecipeDevice.get().cLabel, ...
                this.getRecipeDeviceUnit() ...
            );
            xlabel(this.hAxes, cLabelX);
            
            cLabelY = sprintf(...
                'MeasurPoint D142 (%s)', ...
                this.uiMeasurPointD142.getUnit().name ...
            );
            ylabel(this.hAxes, cLabelY);
        end
        
        function onAxesButtonDown(this)
            this.msg('onAxesButtonDown()') 
        end
        
        
        function c = getPlotLabel(this)
            c = 'test (um)';
        end
        
        
        function initUiRecipeStore(this)
            
            this.stUiRecipeStore = struct();
            
            this.stUiRecipeStore.(this.cNameDeviceExitSlit).start = 35;
            this.stUiRecipeStore.(this.cNameDeviceExitSlit).stop = 350;
            this.stUiRecipeStore.(this.cNameDeviceExitSlit).steps = uint8(10);
            
            this.stUiRecipeStore.(this.cNameDeviceUndulatorGap).start = 38;
            this.stUiRecipeStore.(this.cNameDeviceUndulatorGap).stop = 44;
            this.stUiRecipeStore.(this.cNameDeviceUndulatorGap).steps = uint8(5);
            
            this.stUiRecipeStore.(this.cNameDeviceShutter).start = 5;
            this.stUiRecipeStore.(this.cNameDeviceShutter).stop = 50;
            this.stUiRecipeStore.(this.cNameDeviceShutter).steps = uint8(5);
            
            this.stUiRecipeStore.(this.cNameDeviceGratingTiltX).start = 86;
            this.stUiRecipeStore.(this.cNameDeviceGratingTiltX).stop = 89;
            this.stUiRecipeStore.(this.cNameDeviceGratingTiltX).steps = uint8(20);
            
            this.stUiRecipeStore.(this.cNameDeviceD142StageY).start = 0;
            this.stUiRecipeStore.(this.cNameDeviceD142StageY).stop = 10;
            this.stUiRecipeStore.(this.cNameDeviceD142StageY).steps = uint8(20);
            
           
        end
        
        function onUnitChange(this, src, evt)
           this.updatePlotLabels(); 
           this.updateRecipeUnit();
        end
        
        function updateRecipeUnit(this, src, evt)
            this.uiTextRecipeUnit.set(this.getRecipeDeviceUnit());
        end
        
        function c = getRecipeDeviceUnit(this)
            switch this.uiPopupRecipeDevice.get().cValue
                case 'grating_tilt_x'
                    c = this.uiGratingTiltX.getUnit().name;
                case 'shutter'
                    c = this.uiShutter.getUnit().name;
                case 'exit_slit'
                    c = this.uiExitSlit.getUnit().name;
                case 'undulator_gap'
                    c = this.uiUndulatorGap.getUnit().name;
                case 'd142_stage_y'
                    c = this.uiD142StageY.getUnit().name;
                otherwise 
                    c = 'unknown';
            end
        end
        
        
        function stRecipe = getRecipe(this)
            
            ceValues = cell(1, length(this.dScanDataParam));
            u8Count = 1;
            for dParam = this.dScanDataParam 
                stValue = struct();
                stValue.(this.uiPopupRecipeDevice.get().cValue) = dParam;
                
                stTask = struct();
                stTask.pause = 0.5;
                
                stValue.task = stTask;
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
            end
            
            stRecipe = struct();
            stRecipe.meta = this.getRecipeMeta();
            stRecipe.unit = this.getDeviceUnits();
            stRecipe.values = ceValues;
        end
        
        function st = getRecipeMeta(this)
            
            st = struct();
            st.device = this.uiPopupRecipeDevice.get().cValue;
            st.start = this.uiEditRecipeStart.get();
            st.stop = this.uiEditRecipeStop.get();
            st.steps = this.uiEditRecipeSteps.get();
            
        end
        
        function st = getDeviceUnits(this)
            st = struct();
            st.(this.cNameDeviceGratingTiltX) = this.uiGratingTiltX.getUnit().name;
            st.(this.cNameDeviceShutter) = this.uiShutter.getUnit().name;
            st.(this.cNameDeviceExitSlit) = this.uiExitSlit.getUnit().name;
            st.(this.cNameDeviceUndulatorGap) = this.uiUndulatorGap.getUnit().name;
            st.(this.cNameDeviceD142StageY) = this.uiD142StageY.getUnit().name;
            st.(this.cNameDeviceMeasurPointD142) = this.uiMeasurPointD142.getUnit().name;
        end
        
        % For every field of this.stScanSetContract, set its lSetRequired and 
        % lSetIssued properties to false
        
        function resetScanSetContract(this)
            
            ceFields = fieldnames(this.stScanSetContract);
            for n = 1 : length(ceFields)
                this.stScanSetContract.(ceFields{n}).lRequired = false;
                this.stScanSetContract.(ceFields{n}).lIssued = false;
            end
            
        end
        
        function resetScanAcquireContract(this)
            
            ceFields = fieldnames(this.stScanAcquireContract);
            for n = 1 : length(ceFields)
                this.stScanAcquireContract.(ceFields{n}).lRequired = false;
                this.stScanAcquireContract.(ceFields{n}).lIssued = false;
            end
            
        end
        
        function initScanSetContract(this)
            
            ceFields = { ...
                this.cNameDeviceGratingTiltX, ...
                this.cNameDeviceShutter, ...
                this.cNameDeviceExitSlit, ...
            	this.cNameDeviceUndulatorGap, ...
            	this.cNameDeviceD142StageY ...
             };
             

            for n = 1 : length(ceFields)
                this.stScanSetContract.(ceFields{n}).lRequired = false;
                this.stScanSetContract.(ceFields{n}).lIssued = false;
            end
            
        end
        
        function initScanAcquireContract(this)
            
            ceFields = {...
                this.cNameDeviceMeasurPointD142
            };

            for n = 1 : length(ceFields)
                this.stScanAcquireContract.(ceFields{n}).lRequired = false;
                this.stScanAcquireContract.(ceFields{n}).lIssued = false;
            end
            
        end
        
        function saveRecipeToDisk(this, cPath)
                        
            % Config for savejson function
            stOptions = struct();
            stOptions.FileName = cPath;
            stOptions.Compact = 0; 
            
            stRecipe = this.getRecipe();
            

            % !! IMPORTANT !!
            % savejson() cannot accept structures that contain double
            % quotes.  Use single quotes for strings in the recipe
            savejson('', stRecipe, stOptions); 
               
        end
        
        function c = getRecipeName(this)
           
            % Generate a suggestion for the filename
            % [yyyymmdd-HHMMSS]-[device]-[unit]-[start]-[stop]-[steps]
           
            c = sprintf('%s__%s__%s__%1.1f_%1.1f_%1dx%1d', ...
                datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local'), ...
                this.uiPopupRecipeDevice.get().cValue, ...
                this.getRecipeDeviceUnit(), ...
                this.uiEditRecipeStart.get(), ...
                this.uiEditRecipeStop.get(), ...
                this.uiEditRecipeSteps.get() ...
            );
            
        end
        
        function [stRecipe, lError] = loadRecipeFromDisk(this, cPath)
           
            cMsg = sprintf('loadRecipeFromDisk: %s', cPath);
            this.msg(cMsg);
            
            lError = false;
            
            if strcmp('', cPath) || ...
                isempty(cPath)
                % Has not been set
                lError = true;
                stRecipe = struct();
                return;
            end
                        
            if exist(cPath, 'file') ~= 2
                % File doesn't exist
                lError = true;
                stRecipe = struct();
                
                cMsg = sprintf(...
                    'The recipe file %s does not exist.', ...
                    cPath ...
                );
                cTitle = sprintf('Error reading recipe');
                msgbox(cMsg, cTitle, 'warn')
                
                return;
            end
            
            % File exists
            
            %{
            cStatus = this.uitxStatus.cVal;
            this.uitxStatus.cVal = 'Reading recipe ...';
            drawnow;
            %}
            
            stRecipe = loadjson(cPath);
            
            % this.uitxStatus.cVal = cStatus;
            
            if ~this.validateRecipe(stRecipe)
                lError = true;
                return;
            end

        end
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        function onScanSetState(this, stUnit, stValue)
            
            this.resetScanSetContract();
            
            % Update the stScanSetContract properties listed in stValue 
            
            ceFields = fieldnames(stValue);
            for n = 1 : length(ceFields)
                switch ceFields{n}
                    case 'task'
                        % Do nothing
                    otherwise
                        this.stScanSetContract.(ceFields{n}).lRequired = true;
                        this.stScanSetContract.(ceFields{n}).lIssued = false;
                end
            end
            
            % Move to new state.   Setting the state programatically does
            % exactly what would happen if the user were to do it manually
            % with the UI. I.E., we programatically update the UI and
            % programatically "click" UI buttons.
            
            for n = 1 : length(ceFields)
                
                
                switch ceFields{n}
                    case 'task'
                        % Do nothing
                    otherwise
                        cUnit = stUnit.(ceFields{n}); 
                        dValue = stValue.(ceFields{n});
                end
                
                switch ceFields{n}
                    case 'reticleX'
                        this.uiReticle.uiCoarseStage.uiX.setDestCalDisplay(dValue, cUnit);
                        this.uiReticle.uiCoarseStage.uiX.moveToDest(); % click
                        this.stScanSetContract.(ceFields{n}).lIssued = true;
                    case 'reticleY'
                        this.uiReticle.uiCoarseStage.uiY.setDestCalDisplay(dValue, cUnit);
                        this.uiReticle.uiCoarseStage.uiY.moveToDest(); % click
                        this.stScanSetContract.(ceFields{n}).lIssued = true;
                    case 'waferX'
                        this.uiWafer.uiCoarseStage.uiX.setDestCalDisplay(dValue, cUnit);
                        this.uiWafer.uiCoarseStage.uiX.moveToDest(); % click
                        this.stScanSetContract.(ceFields{n}).lIssued = true;
                    case 'waferY'
                        this.uiWafer.uiCoarseStage.uiY.setDestCalDisplay(dValue, cUnit);
                        this.uiWafer.uiCoarseStage.uiY.moveToDest(); % click
                        this.stScanSetContract.(ceFields{n}).lIssued = true;
                    case 'waferZ'
                        this.uiWafer.uiFineStage.uiZ.setDestCalDisplay(dValue, cUnit);
                        this.uiWafer.uiFineStage.uiZ.moveToDest();  % click
                        this.stScanSetContract.(ceFields{n}).lIssued = true;
                    case 'pupilFill'
                        % FIX ME
                        this.stScanSetContract.(ceFields{n}).lIssued = true;
                        
                        %{

                        
                        % Load the saved structure associated with the pupil fill
                
                        cFile = fullfile( ...
                            this.cDirPupilFills, ...
                            stPre.uiPupilFillSelect.cSelected ...
                        );

                        if exist(cFile, 'file') ~= 0
                            load(cFile); % populates s in local workspace
                            stPupilFill = s;
                        else
                            this.abort(sprintf('Could not find pupilfill file: %s', cFile));
                            return;
                        end
                        if ~this.uiPupilFill.np.setWavetable(stPupilFill.i32X, stPupilFill.i32Y);

                            cQuestion   = ['The nPoint pupil fill scanner is ' ...
                                'not enabled and not scanning the desired ' ...
                                'pupil pattern.  Do you want to run the FEM anyway?'];

                            cTitle      = 'nPoint is not enabled';
                            cAnswer1    = 'Run FEM without pupilfill.';
                            cAnswer2    = 'Abort';
                            cDefault    = cAnswer2;

                            qanswer = questdlg(cQuestion, cTitle, cAnswer1, cAnswer2, cDefault);
                            switch qanswer
                                case cAnswer1;

                                otherwise
                                    this.abort('You stopped the FEM because the nPoint is not scanning.');
                                    return; 
                            end

                        end
                        %}
                        
                    otherwise
                        % do nothing
                        
                end
                
                
                
            end
                        

        end


        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the system is at the state
        function lOut = onScanIsAtState(this, stUnit, stValue)
            
            % The complexity of setState(), i.e., lots of 
            % series operations vs. one large parallel operation, dictates
            % how complex this needs to be.  I decided to implement a
            % general approach that will work for the case of complex
            % serial operations.  The idea is that each device (HIO) is
            % wrapped with a lSetRequired and lSetIssued {locical} property.
            %
            % The beginning of setState(), loops through all devices
            % that will be controlled and sets the lSetRequired flag ==
            % true for each one and false for non-controlled devices.  It also sets 
            % lSetIssued === false for all controlled devices.  
            %
            % Once a device move is commanded, the lSetIssued flag is set
            % to true.  These two flags provide a systematic way to check
            % isAtState: loop through all devices being controlled and only
            % return true when every one that needs to be moved has had its
            % move issued and also has isThere / lReady === true.
            
            % Ryan / Antine you might know a better way to do this nested
            % loop / conditional but I wanted readability and debugginb so
            % I made it verbose
            
            lDebug = true;           
            lOut = true;
                        
            ceFields= fieldnames(stValue);
            
            for n = 1:length(ceFields)
                
                cField = ceFields{n};
                
                % special case, skip task
                if strcmp(cField, 'task')
                    continue;
                end
                
                
                if this.stScanSetContract.(cField).lRequired
                    if lDebug
                        this.msg(sprintf('onScanIsAtState() %s set is required', cField));
                    end

                    if this.stScanSetContract.(cField).lIssued
                        
                        if lDebug
                            this.msg(sprintf('onScanIsAtState() %s set has been issued', cField));
                        end
                        
                        % Check if the set operation is complete
                        
                        lReady = true;
                        %{
                        switch cField
                            case 'reticleX'
                               if ~this.uiReticle.uiCoarseStage.uiX.getDevice().isReady()
                                   lReady = false;
                               end
                               
                            case 'reticleY'
                               if ~this.uiReticle.uiCoarseStage.uiY.getDevice().isReady()
                                   lReady = false;
                               end
                                
                            case 'waferX'
                                if ~this.uiWafer.uiCoarseStage.uiX.getDevice().isReady()
                                   lReady = false;
                               end
                                
                            case 'waferY'
                                if ~this.uiWafer.uiCoarseStage.uiY.getDevice().isReady()
                                   lReady = false;
                               end
                                
                            case 'waferZ'
                               if ~this.uiWafer.uiFineStage.uiZ.getDevice().isReady()
                                   lReady = false;
                               end
                            case 'pupilFill'
                                % FIX ME
                                
                            otherwise
                                
                                % UNSUPPORTED
                                
                        end
                        %}
                        
                        if lReady
                        	if lDebug
                                this.msg(sprintf('onScanIsAtState() %s set operation complete', cField));
                            end
 
                        else
                            % still isn't there.
                            if lDebug
                                this.msg(sprintf('onScanIsAtState() %s is still setting', cField));
                            end
                            lOut = false;
                            return;
                        end
                    else
                        % need to move and hasn't been issued.
                        if lDebug
                            this.msg(sprintf('onScanIsAtState() %s set not yet issued', cField));
                        end
                        
                        lOut = false;
                        return;
                    end                    
                else
                    
                    if lDebug
                        this.msg(sprintf('onScanIsAtState() %s N/A', cField));
                    end
                   % don't need to move, this param is OK. Don't false. 
                end
            end
        end


        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state (possibly contains 
        % information about the task to execute during acquire)
        function onScanAcquire(this, stUnit, stValue)
            
            this.resetScanAcquireContract();
            
            % If stValue does not have a "task" or "action" prop, return
            
            if ~isfield(stValue, 'task')
                return
            end
            
            % Should eventually have a "type" property associated with the
            % task that can be switched on.  "type", "data" which is a
            % struct.  
            % 
            % One type would be "exposure"
            
           
            
        end

        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the acquisition task is complete
        function lOut = onScanIsAcquired(this, stUnit, stValue)

            lDebug = true;           
            lOut = true;
            
            if ~isfield(stValue, 'task')
                return
            end
                        
            ceFields= fieldnames(this.stScanAcquireContract);
            
            for n = 1:length(ceFields)
                
                cField = ceFields{n};
                
                if this.stScanAcquireContract.(cField).lRequired
                    if lDebug
                        this.msg(sprintf('onScanIsAtState() %s set is required', cField));
                    end

                    if this.stScanAcquireContract.(cField).lIssued
                        
                        if lDebug
                            this.msg(sprintf('onScanIsAtState() %s set has been issued', cField));
                        end
                        
                        % Check if the set operation is complete
                        
                        lReady = true;
                        
                        %{
                        switch cField
                            case 'shutter'
                               if ~this.uiShutter.uiShutter.getDevice().isReady()
                                   lReady = false;
                               end
                                 
                            otherwise
                                
                                % UNSUPPORTED
                                
                        end
                        %}
                        
                        if lReady
                        	if lDebug
                                this.msg(sprintf('onScanIsAtState() %s set complete', cField));
                            end
 
                        else
                            % still isn't there.
                            if lDebug
                                this.msg(sprintf('onScanIsAtState() %s set still setting', cField));
                            end
                            lOut = false;
                            return;
                        end
                    else
                        % need to move and hasn't been issued.
                        if lDebug
                            this.msg(sprintf('onScanIsAtState() %s set not yet issued', cField));
                        end
                        
                        lOut = false;
                        return;
                    end                    
                else
                    
                    if lDebug
                        this.msg(sprintf('onScanIsAtState() %s set is not required', cField));
                    end
                   % don't need to move, this param is OK. Don't false. 
                end
            end
            
            
        end


        function onScanAbort(this, stUnit)
             this.hideScanPauseAbort();
             this.showScanStart();
        end


        function onScanComplete(this, stUnit)
             this.hideScanPauseAbort();
             this.showScanStart();
        end
        

        
    end
    
    
end

