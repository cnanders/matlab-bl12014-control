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
        
        dWidthFigurePad = 10
        dHeightFigurePad = 10
        
        dWidthPanelBorder = 0
        dWidthPadH = 15
        
        dHeightUi = 24
        
        dSizeMarker = 8
        
        stDeviceTypeExitSlit = struct(...
            'cLabel', 'Exit Slit', ...
            'cValue', 'exit_slit' ...
        )
        stDeviceTypeUndulatorGap = struct(...
            'cLabel', 'Undulator Gap', ...
            'cValue', 'undulator_gap' ...
        )
        stDeviceTypeShutter = struct( ...
            'cLabel', 'Shutter', ...
            'cValue', 'shutter' ...
        )
        stDeviceTypeGratingTiltX = struct( ...
            'cLabel', 'Grating Tilt X', ...
            'cValue', 'grating_tilt_x' ...
        )
        stDeviceTypeD142StageY = struct( ...
            'cLabel', 'D142 Stage Y', ...
            'cValue', 'd142_stage_y' ...
        )
        
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
        uiMeasurPointD142Volts
        
        
    end
    
    
    properties (SetAccess = private)

        cName = 'Beamline'
        
    end
    
    properties (Access = private)
        
        clock
        
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
        
        
        uiToggleScanPause
        uiButtonScanAbort
        uiButtonScanStart
         
        % Stores the values of the start, stop, steps of each device type.
        % When the device popup switches, the start, stop, steps initialize
        % to the last stored values for that device type
        stUiRecipeStore
        
        uiTextUnit
        
        % {double 1xm} x axis on 1D plot storage for the value of the scanned parameter
        dScanDataParam  
        % {double 1xm} y axis on 1D plot storage for the acquired valued
        dScanDataValue
        
        
    end
    
    methods
        
        function this = Beamline(varargin)
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
            this.uiMeasurPointD142Volts.turnOn();
            
        end
        
        function turnOff(this)
            this.uiExitSlit.turnOff();
            this.uiUndulatorGap.turnOff();
            this.uiShutter.turnOff();
            this.uiGratingTiltX.turnOff();
            this.uiTiltY.turnOff();
            this.uiD142StageY.turnOff();
            this.uiMeasurPointD142Volts.turnOff();
            
        end
        
        
        
        
        
        function build(this)
            
            this.buildFigure();
            
            this.buildPanelRecipe();
            this.buildUiRecipe()
            this.buildPanelData();
            this.buildAxes();
            return
            this.buildPanelDevices();
            this.buildUiDevices()
            
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
            
            this.uiMeasurPointD142Volts.build(this.hPanelDevices, dLeft, dTop);
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
        end
        
        
        function initUiMeasurPointD142Volts(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-d142-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiMeasurPointD142Volts = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', 'measur-point-d142-diode', ...
                'config', uiConfig, ...
                'dWidthName', this.dWidthName, ...
                'cLabel', 'MeasurPoint (D142)', ...
                'dWidthPadUnit', 277, ...
                'lShowLabels', false ...
            );
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
        end
        
        function initUiRecipe(this)
            
            ceOptions = { ...
                this.stDeviceTypeExitSlit, ...
                this.stDeviceTypeUndulatorGap, ...
                this.stDeviceTypeShutter, ...
                this.stDeviceTypeGratingTiltX, ...
                this.stDeviceTypeD142StageY ...
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
        
            addlistener(this.uiPopupRecipeDevice, 'eChange', @this.onPopupRecipeDevice);
            addlistener(this.uiEditRecipeStart, 'eChange', @this.onEditRecipeStart)
            addlistener(this.uiEditRecipeStop, 'eChange', @this.onEditRecipeStop)
            addlistener(this.uiEditRecipeSteps, 'eChange', @this.onEditRecipeSteps)
        end
        
        function onPopupRecipeDevice(this, src, evt)
            
            this.msg('onPopupRecipeDevice()')
            this.uiEditRecipeStart.setWithoutNotify(this.stUiRecipeStore.(this.uiPopupRecipeDevice.get().cValue).start);
            this.uiEditRecipeStop.setWithoutNotify(this.stUiRecipeStore.(this.uiPopupRecipeDevice.get().cValue).stop);
            this.uiEditRecipeSteps.setWithoutNotify(this.stUiRecipeStore.(this.uiPopupRecipeDevice.get().cValue).steps);

            this.resetScanData();
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
            this.initUiMeasurPointD142Volts();
            
            this.initUiRecipe();
            this.initUiScan();
            
            this.initUiRecipeStore();
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
        
            xlabel(this.hAxes, this.getPlotLabel());
            ylabel(this.hAxes, sprintf('I (%s)', 'A'));
            
        end
        
        function onAxesButtonDown(this)
            this.msg('onAxesButtonDown()') 
        end
        
        
        function c = getPlotLabel(this)
            c = 'test (um)';
        end
        
        
        function initUiRecipeStore(this)
            
            this.stUiRecipeStore = struct();
            
            this.stUiRecipeStore.(this.stDeviceTypeExitSlit.cValue).start = 35;
            this.stUiRecipeStore.(this.stDeviceTypeExitSlit.cValue).stop = 350;
            this.stUiRecipeStore.(this.stDeviceTypeExitSlit.cValue).steps = uint8(10);
            
            this.stUiRecipeStore.(this.stDeviceTypeUndulatorGap.cValue).start = 38;
            this.stUiRecipeStore.(this.stDeviceTypeUndulatorGap.cValue).stop = 44;
            this.stUiRecipeStore.(this.stDeviceTypeUndulatorGap.cValue).steps = uint8(5);
            
            this.stUiRecipeStore.(this.stDeviceTypeShutter.cValue).start = 5;
            this.stUiRecipeStore.(this.stDeviceTypeShutter.cValue).stop = 50;
            this.stUiRecipeStore.(this.stDeviceTypeShutter.cValue).steps = uint8(5);
            
            this.stUiRecipeStore.(this.stDeviceTypeGratingTiltX.cValue).start = 86;
            this.stUiRecipeStore.(this.stDeviceTypeGratingTiltX.cValue).stop = 89;
            this.stUiRecipeStore.(this.stDeviceTypeGratingTiltX.cValue).steps = uint8(20);
            
            this.stUiRecipeStore.(this.stDeviceTypeD142StageY.cValue).start = 0;
            this.stUiRecipeStore.(this.stDeviceTypeD142StageY.cValue).stop = 10;
            this.stUiRecipeStore.(this.stDeviceTypeD142StageY.cValue).steps = uint8(20);
            
           
        end
        
    end
    
    
end

