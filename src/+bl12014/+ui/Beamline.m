classdef Beamline < mic.Base
    
    
    properties (Constant, Access = private)
        
        dWidth = 1500
        % dHeight = 740 % Calculated in buildFigure()
        
        dWidthPadName = 29
        
        dWidthNameComm = 140
        dHeightPanelComm = 145
        
        dWidthPanelRecipe = 800
        dHeightPanelRecipe = 210
        
        dWidthPanelData = 800
        dHeightPanelData = 340
        
        dWidthPanelDevices = 650
        dHeightPanelDevices = 550
        
        dWidthRecipeEdit = 40
        dWidthRecipeButton = 60
        dWidthRecipePopup = 120
        dWidthRecipeUnit = 50
        
        
        dWidthFigurePad = 10
        dHeightFigurePad = 10
        
        dWidthPanelBorder = 0
        dWidthPadH = 10
        
        dHeightUi = 24
        
        dSizeMarker = 8
        
        
        cNameOutputM141Diode = 'output-m141-diode'
        cNameOutputD141Diode = 'output-d141-diode'
        cNameOutputD142Diode = 'output-d142-diode'
        
        cNameDeviceExitSlit = 'exit_slit'
        cNameDeviceUndulatorGap = 'undulator_gap'
        cNameDeviceShutter = 'shutter'
        cNameDeviceGratingTiltX = 'grating_tilt_x'
        cNameDeviceD142StageY = 'd142_stage_y'
        cNameDeviceD141Current = 'measur_point_d141'
        cNameDeviceM141Current = 'measur_point_m141'
        cNameDeviceD142Current = 'measur_point_d142'
        
        
        cScanAcquireTypeM141Current = 'scan_acquire_type_m141_current'
        cScanAcquireTypeD141Current = 'scan_acquire_type_d141_current'
        cScanAcquireTypeD142Current = 'scan_acquire_type_d142_current'

        
        dColorFigure = [200 200 200]./255
        dColorPanelData = [1 1 1]
        
        lDebugScan = true
    end
    
    properties
        
        
        deviceShutterVirtual
        
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommExitSlit
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommBL1201CorbaProxy
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDctCorbaProxy % Previous DCT shutter driver
        
        % {mic.ui.device.GetSetLogical 1x1}
        
        uiCommRigolDG1000Z
        
        % {mic.ui.device.GetSetLogical 1x1} % D142 Diode Current
        uiCommDataTranslationMeasurPoint
        
        % {mic.ui.device.GetSetLogical 1x1} 
        uiCommGalilD142
        
        
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
        uiD141Current
        uiM141Current
        uiD142Current
        
            % {mic.ui.common.PositionRecaller 1x1}
        uiPositionRecaller 
        
        
    end
    
    
    properties (SetAccess = private)

        cName = 'beamline'
        
    end
    
    properties (Access = private)
        
        % {cell of struct} storage of state during each acquire
        ceValues
        
        clock
        
        cDirThis
        % {char 1xm} - full path to the src directory of this application
        cDirSrc
        % {char 1xm} - full path to the directory where scans are saved
        cDirSave
        
        % {char 1xm} - full path to a particular scan (recipe.json +
        % result.json) are saved.  Each scan is saved to a new folder
        cDirScan
        
        hFigure
        hPanelDevices
        hPanelScan
        hPanelData
        hAxes
        % storage for handles returned by plot()
        hLines
        
        dWidthUiDeviceName = 70
        dWidthUiDeviceUnit = 100
        
        configStageY
        configMeasPointVolts 
        
        uiPopupRecipeDevice
        uiEditRecipeStart
        uiEditRecipeStop
        uiEditRecipeSteps
        uiTextRecipeUnit
        uiPopupRecipeOutput
        
        uiTextPlotX
        uiTextPlotY
        
        % {mic.ui.Scan 1x1}
        uiScan
        
        uiScanStatus
         
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
        
        cPathRecipe
        
        % {mic.Scan 1x1}
        scan
    end
    
    methods
        
        function this = Beamline(varargin)
            
            this.cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSrc = fullfile(this.cDirThis, '..', '..');
            this.cDirSave = fullfile(this.cDirSrc, 'save', 'beamline-scans');
            
            mic.Utils.checkDir(this.cDirSave);
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        %{
        function connectKeithley6482(this, comm)
            % Temporary Hack using Keithley to get D141 photo current
            % Need to click "connect" button from Wafer Module since
            % there is not one in this UI
            device = bl12014.device.GetNumberFromKeithley6482(comm, 1);
            this.uiD141Current.setDevice(device);
            this.uiD141Current.turnOn();
        end
        
        function disconnectKeithley6482(this)
            this.uiD141Current.turnOff()
            this.uiD141Current.setDevice([]);
        end
        %}
        
        function connectGalil(this, comm)
            device = bl12014.device.GetSetNumberFromStage(comm, 0);
            this.uiD142StageY.setDevice(device);
            this.uiD142StageY.turnOn()
            this.uiD142StageY.syncDestination()
            
        end
        
        function disconnectGalil(this, comm)
            this.uiD142StageY.turnOff()
            this.uiD142StageY.setDevice([]);
        end
        
        function connectExitSlit(this, comm)
            device = bl12014.device.GetSetNumberFromExitSlitObject(comm, bl12014.device.GetSetNumberFromExitSlitObject.cPROP_GAP);
            this.uiExitSlit.setDevice(device);
            this.uiExitSlit.turnOn();
            this.uiExitSlit.syncDestination();
        end
        
        function disconnectExitSlit(this)
            this.uiExitSlit.turnOff();
            this.uiExitSlit.setDevice([]);
        end
        
        function connectDataTranslationMeasurPoint(this, comm)
            
           import bl12014.device.GetNumberFromDataTranslationMeasurPoint

           %{
           Ch 32: M141
Ch 33: D141
Ch 34: D142
           %}
           device = GetNumberFromDataTranslationMeasurPoint(...
                comm, ...
                GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, ...
                32 ... % M141
            );
            this.uiM141Current.setDevice(device);
            this.uiM141Current.turnOn();  
            
            
            device = GetNumberFromDataTranslationMeasurPoint(...
                comm, ...
                GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, ...
                33 ... % M141
            );
            this.uiD141Current.setDevice(device);
            this.uiD141Current.turnOn();  
           
           
           device = GetNumberFromDataTranslationMeasurPoint(...
                comm, ...
                GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, ...
                34 ... % D142
            );
            this.uiD142Current.setDevice(device);
            this.uiD142Current.turnOn();     

        end
        
        function disconnectDataTranslationMeasurPoint(this)
            
            this.uiM141Current.turnOff();
            this.uiM141Current.setDevice([]);
            
            this.uiD141Current.turnOff();
            this.uiD141Current.setDevice([]);
            
            this.uiD142Current.turnOff();
            this.uiD142Current.setDevice([]);
        end
        
        
        function connectDctCorbaProxy(this, comm)
            device = bl12014.device.GetSetNumberFromDctCorbaProxy(...
                comm, ...
                bl12014.device.GetSetNumberFromDctCorbaProxy.cDEVICE_SHUTTER ...
            );
        
            this.uiShutter.setDevice(device)
            this.uiShutter.turnOn()
        end
        
        function disconnectDctCorbaProxy(this)
            this.uiShutter.turnOff()
            this.uiShutter.setDevice([])
        end
        
        function connectRigolDG1000Z(this, comm)
            
            device = bl12014.device.GetSetNumberFromRigolDG1000Z(comm, 1);
            this.uiShutter.setDevice(device);
            this.uiShutter.turnOn();
                      
        end
        
        function disconnectRigolDG1000Z(this)
            
            this.uiShutter.turnOff();
            this.uiShutter.setDevice([]);
   
        end
        
        
        function connectBL1201CorbaProxy(this, comm)
            deviceUndulatorGap = bl12014.device.GetSetNumberFromBL1201CorbaProxy(...
                comm, ...
                bl12014.device.GetSetNumberFromBL1201CorbaProxy.cDEVICE_UNDULATOR_GAP ...
            );
            deviceGratingTiltX = bl12014.device.GetSetNumberFromBL1201CorbaProxy(...
                comm, ...
                bl12014.device.GetSetNumberFromBL1201CorbaProxy.cDEVICE_GRATING_TILT_X ...
            );
            
            this.uiUndulatorGap.setDevice(deviceUndulatorGap)
            this.uiUndulatorGap.turnOn()
            this.uiUndulatorGap.syncDestination()

            this.uiGratingTiltX.setDevice(deviceGratingTiltX)
            this.uiGratingTiltX.turnOn()
            this.uiGratingTiltX.syncDestination()
            
        end
        
        function disconnectBL1201CorbaProxy(this, comm)
            this.uiUndulatorGap.turnOff()
            this.uiUndulatorGap.setDevice([])
            
            this.uiGratingTiltX.turnOff()
            this.uiGratingTiltX.setDevice([])
            
        end
        
        
        
        
        
        
        
        
        
        function build(this)
            
            this.buildFigure();
            
            this.buildCommUi();
            
            
            this.buildPanelDevices();
            this.buildPanelRecipe();
            %this.buildUiScan();
            this.buildPanelData();
            this.buildAxes();
            
            
        end
        
        function delete(this)
            
            this.msg('delete', this.u8_MSG_TYPE_CLASS_INIT_DELETE);
                        
            
            %{
            % Get properties:
            ceProperties = properties(this);
            
            % Delete all props that are objects and handles
            
            for k = 1:length(ceProperties)
                
                this.msg(sprintf('delete checking prop %s ', ceProperties{k}), this.u8_MSG_TYPE_PROP_DELETE_CHECK);
                
                if  isobject(this.(ceProperties{k}))  | ... 
                    ishandle(this.(ceProperties{k}))
                    
                    this.msg(sprintf('delete deleting %s ', ceProperties{k}), this.u8_MSG_TYPE_PROP_DELETED);
                    delete(this.(ceProperties{k}));
                else
                    cMsg = [ ...
                        sprintf('delete skipping %s', ceProperties{k}), ...
                        sprintf('isobject = %d, ',  isobject(this.(ceProperties{k}))), ...
                        sprintf('ishandle = %d', ishandle(this.(ceProperties{k}))) ...
                    ];
                    this.msg(cMsg, this.u8_MSG_TYPE_PROP_DELETE_SKIPPED);
                end
            end
            %}
            
            
            % delete(this.deviceShutterVirtual)
            
            
            delete(this.uiCommExitSlit)
            delete(this.uiCommBL1201CorbaProxy)
            delete(this.uiCommDctCorbaProxy)
            delete(this.uiCommDataTranslationMeasurPoint)
            delete(this.uiCommGalilD142)
            delete(this.uiExitSlit)
            delete(this.uiUndulatorGap)
            delete(this.uiShutter)
            delete(this.uiGratingTiltX)
            delete(this.uiD142StageY)
            delete(this.uiD141Current)
            delete(this.uiM141Current)
            delete(this.uiD142Current)
        
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
            if isfield(st, 'stUiRecipeStore') 
                this.stUiRecipeStore = st.stUiRecipeStore;
            end
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
                    'WindowButtonDownFcn', @this.onFigureWindowButtonDown, ... % doesn't work if datacursormode is on!
                    'HandleVisibility', 'on', ... % lets close all close the figure
                    'Visible', 'on' ...
                );

                % pan(this.hFigure);
                % zoom(this.hFigure);
                % set(this.hFigure, 'toolbar', 'figure');
                % datacursormode(this.hFigure, 'on');
            end
            
        end
        
        
        function buildPanelData(this)
            
            dLeft = this.dWidthFigurePad;
            dTop = this.dHeightFigurePad  + ...
                ...% this.dHeightPanelComm + ...
                this.dHeightPanelRecipe; % No vertical pad between scan and data panels
            
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
            
            this.uiTextPlotX.build(this.hPanelData, this.dWidthPanelData - 200, 0, 100, 14);
            this.uiTextPlotY.build(this.hPanelData, this.dWidthPanelData - 100, 0, 100, 14);
            
            this.uiTextPlotX.setBackgroundColor([1 1 1]);
            this.uiTextPlotY.setBackgroundColor([1 1 1]);
            
            
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
                'NextPlot', 'add' ... % Important.  Look this up in help makes it so 
                ...% 'ButtonDownFcn', @this.onAxesButtonDown ...
            );
            hold(this.hAxes, 'on');
            this.updatePlot()
            this.updatePlotLabels()
            this.updatePlotXLimits()
            
            % 'FontSize', this.dSizeFont, ...

        end
        
        
        function buildCommUi(this)
            
            return
         
            dTop = 10;
            dLeft = 10;
            dSep = 30;
            
            this.uiCommGalilD142.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslationMeasurPoint.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommExitSlit.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            %{
            this.uiCommDctCorbaProxy.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            %}
            
            this.uiCommRigolDG1000Z.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommBL1201CorbaProxy.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
        end
        
        
        function buildPanelDevices(this)
            
            dLeft = this.dWidthFigurePad + ...
                this.dWidthPanelRecipe + ...
                this.dWidthFigurePad;
            dTop = this.dWidthFigurePad;
            
            %{
            dTop = this.dHeightFigurePad + ...
                this.dHeightPanelComm + ...
                this.dHeightFigurePad + ...
                this.dHeightPanelRecipe + ...
                this.dHeightPanelData + ...
                this.dHeightFigurePad;
           %}
            
            this.hPanelDevices = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Hardware',...
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
                        
            dLeft = 10;
            dSep = 30;
            dSepGroup = 20;
            dTop = 20;
                                    
            
            this.uiCommBL1201CorbaProxy.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
                        
            this.uiGratingTiltX.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiUndulatorGap.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            dTop = dTop + dSepGroup;
            
                        
            this.uiCommExitSlit.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
                        
            this.uiExitSlit.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            dTop = dTop + dSepGroup;
            
            this.uiCommGalilD142.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;            
            this.uiD142StageY.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            dTop = dTop + dSepGroup;
            
            this.uiCommRigolDG1000Z.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            
            %{
            this.uiCommDctCorbaProxy.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            %}
                        
            this.uiShutter.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            dTop = dTop + dSepGroup;
            
             
            this.uiCommDataTranslationMeasurPoint.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiM141Current.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiD141Current.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiD142Current.build(this.hPanelDevices, dLeft, dTop);
            dTop = dTop + dSep;
            dTop = dTop + dSepGroup;
            
        end
        
        function buildPanelRecipe(this)
            
            dLeft = this.dWidthFigurePad;
            dTop = this.dHeightFigurePad; % + ...
                % this.dHeightPanelComm + ...
                % this.dHeightFigurePad;
                        
            this.hPanelScan = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Scan',...
                'BorderWidth', this.dWidthPanelBorder, ...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                    dLeft ...
                    dTop ...
                    this.dWidthPanelRecipe ...
                    this.dHeightPanelRecipe], ...
                    this.hFigure ...
                ) ...
            );
        
            drawnow;
            
        
            
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
            
            
            dTop = 20;
            dLeft = dLeft + 50;
            this.uiPositionRecaller.build(this.hPanelScan, dLeft, dTop, 360, 170);
            
            
            
            dLeft = 20 + this.dWidthRecipePopup + this.dWidthPadH;
            dTop = 60;
            this.uiScan.build(this.hPanelScan, dLeft, dTop);
            
            dTop = 60; 
            dLeft = 20;
            
            
            this.uiPopupRecipeOutput.build( ...
                this.hPanelScan, ...
                dLeft, ...
                dTop, ...
                this.dWidthRecipePopup, ...
                this.dHeightUi ...
            );
        
        
            this.onPopupRecipeDevice();
        
        end
        
        
        function initUiDeviceD142StageY(this)
            
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
                'cName', 'beamline-d142-stage-y', ...
                'config', uiConfig, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthName', this.dWidthUiDeviceName, ...
                'dWidthUnit', this.dWidthUiDeviceUnit, ...
                'lShowLabels', false, ...
                'cLabel', 'D142 Stage Y' ...
            );
        
            addlistener(this.uiD142StageY, 'eUnitChange', @this.onUnitChange);
        end
        
        
        function initUiDeviceD141Current(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-d141-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiD141Current = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', 'beamline-measur-point-d141-diode', ...
                'config', uiConfig, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthName', this.dWidthUiDeviceName, ...
                'dWidthUnit', this.dWidthUiDeviceUnit, ...
                'cLabel', 'D141 Current', ...
                'dWidthPadUnit', 277, ...
                'lShowLabels', false ...
            );
        
            addlistener(this.uiD141Current, 'eUnitChange', @this.onUnitChange);
        end 
        
        
        
        function initUiDeviceM141Current(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-m141-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiM141Current = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', 'beamline-measur-point-m141-diode', ...
                'config', uiConfig, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthName', this.dWidthUiDeviceName, ...
                'dWidthUnit', this.dWidthUiDeviceUnit, ...
                'cLabel', 'M141 Current', ...
                'dWidthPadUnit', 277, ...
                'lShowLabels', false ...
            );
        
            addlistener(this.uiM141Current, 'eUnitChange', @this.onUnitChange);
        end 
        
        
        function initUiDeviceD142Current(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-d142-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiD142Current = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', 'beamline-measur-point-d142-diode', ...
                'config', uiConfig, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthName', this.dWidthUiDeviceName, ...
                'dWidthUnit', this.dWidthUiDeviceUnit, ...
                'cLabel', 'D142 Current', ...
                'dWidthPadUnit', 277, ...
                'lShowLabels', false ...
            );
        
            addlistener(this.uiD142Current, 'eUnitChange', @this.onUnitChange);
        end 
        
        
         
        function initUiDeviceExitSlit(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-gap-of-exit-slit.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiExitSlit = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthName', this.dWidthUiDeviceName, ...
                'dWidthUnit', this.dWidthUiDeviceUnit, ...
                'lShowLabels', false, ...
                'cName', 'beamline-exit-slit', ...
                'config', uiConfig, ...
                'cLabel', 'Exit Slit' ...
            );
        
            addlistener(this.uiExitSlit, 'eUnitChange', @this.onUnitChange);
        end
        
        function initUiDeviceUndulatorGap(this)
            
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
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthName', this.dWidthUiDeviceName, ...
                'dWidthUnit', this.dWidthUiDeviceUnit, ...
                'cName', 'beamline-undulator-gap', ...
                'config', uiConfig, ...
                'cLabel', 'Undulator Gap' ...
            );
        
            addlistener(this.uiUndulatorGap, 'eUnitChange', @this.onUnitChange);
        end
        
        function initUiDeviceShutter(this)
            
            this.deviceShutterVirtual = bl12014.device.ShutterVirtual();
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-shutter-rigol.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiShutter = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthName', this.dWidthUiDeviceName, ...
                'dWidthUnit', this.dWidthUiDeviceUnit, ...
                'cName', 'beamline-shutter', ...
                'config', uiConfig, ...
                'cLabel', 'Shutter' ...
            );
            
        	this.uiShutter.setDeviceVirtual(this.deviceShutterVirtual);
            addlistener(this.uiShutter, 'eUnitChange', @this.onUnitChange);
        end
        
        
        function initUiDeviceGratingTiltX(this)
            
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
                'lShowInitButton', true, ...
                'dWidthName', this.dWidthUiDeviceName, ...
                'dWidthUnit', this.dWidthUiDeviceUnit, ...
                'cName', 'beamline-grating-tilt-x', ...
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
                stDeviceTypeGratingTiltX, ...
                stDeviceTypeUndulatorGap, ...
                stDeviceTypeExitSlit, ...
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
                'cType', 'u16', ... % uint16
                'cLabel', 'Steps' ...
            );
        
            this.uiTextRecipeUnit = mic.ui.common.Text(...
                'lShowLabel', true, ...
                'cLabel', 'Unit', ...
                '...' ...
            );
        
        
        
            stOutputTypeM141Diode = struct( ...
                'cLabel', 'M141 Diode', ...
                'cValue', this.cNameOutputM141Diode ...
            );
            stOutputTypeD141Diode = struct( ...
                'cLabel', 'D141 Diode', ...
                'cValue', this.cNameOutputD141Diode ...
            ); 
            stOutputTypeD142Diode = struct( ...
                'cLabel', 'D142 Diode', ...
                'cValue', this.cNameOutputD142Diode ...
            ); 
            ceOptions = { ...
                stOutputTypeM141Diode, ...
                stOutputTypeD141Diode, ...
                stOutputTypeD142Diode ...
            };
        
            this.uiPopupRecipeOutput = mic.ui.common.PopupStruct(...
                'ceOptions', ceOptions, ...
                'cField', 'cLabel', ...
                'cLabel', 'Output' ...
            );
        
        
            
        
            addlistener(this.uiPopupRecipeDevice, 'eChange', @this.onPopupRecipeDevice);
            addlistener(this.uiEditRecipeStart, 'eChange', @this.onEditRecipeStart);
            addlistener(this.uiEditRecipeStop, 'eChange', @this.onEditRecipeStop);
            addlistener(this.uiEditRecipeSteps, 'eChange', @this.onEditRecipeSteps);
            addlistener(this.uiPopupRecipeOutput, 'eChange', @this.onPopupRecipeOutput);

            
        end
        
        function onPopupRecipeDevice(this, ~, ~)
            
            this.msg('onPopupRecipeDevice()')
            
            % Update values of the edit boxes based on their previous value
            % this recipe device was active
            
            stStore = this.stUiRecipeStore.(this.uiPopupRecipeDevice.get().cValue);
            this.uiEditRecipeStart.setWithoutNotify(stStore.start);
            this.uiEditRecipeStop.setWithoutNotify(stStore.stop);
            this.uiEditRecipeSteps.setWithoutNotify(stStore.steps);

            this.resetScanData();
            this.updatePlotLabels();
            this.updateRecipeUnit();
            
        end
        
        function onPopupRecipeOutput(this, ~, ~)
            
            this.msg('onPopupRecipeOutput')
            
            this.resetScanData();
            this.updatePlotLabels();
        end
        
        
        
        function onEditRecipeStart(this, src, ~)
            this.stUiRecipeStore.(this.uiPopupRecipeDevice.get().cValue).start = src.get();
            this.resetScanData();
        end
      
        function onEditRecipeStop(this, src, ~)
            this.stUiRecipeStore.(this.uiPopupRecipeDevice.get().cValue).stop = src.get();
            this.resetScanData();
        end
        
        function onEditRecipeSteps(this, src, ~)
            this.stUiRecipeStore.(this.uiPopupRecipeDevice.get().cValue).steps = src.get();
            this.resetScanData();
        end
        
        
        
        function init(this)
            this.msg('init()');
            
            this.initUiCommExitSlit();
            this.initUiCommGalil();
            this.initUiCommDataTranslationMeasurPoint();
            this.initUiCommDctCorbaProxy();
            this.initUiCommBL1201CorbaProxy();
            this.initUiCommRigolDG1000Z();
            
            this.initUiDeviceExitSlit();
            this.initUiDeviceUndulatorGap(); % BL1201 Corba Proxy
            this.initUiDeviceShutter(); % DCT Corba Proxy
            this.initUiDeviceGratingTiltX(); % BL1201 Corba Proxy
            this.initUiDeviceD142StageY();
            
            this.initUiDeviceD141Current();
            this.initUiDeviceM141Current();
            this.initUiDeviceD142Current();
            
            this.initUiPositionRecaller();
            
            this.initUiRecipe();
            this.initUiScan()
            this.initUiRecipeStore();
            
            this.initScanAcquireContract();
            this.initScanSetContract();
            
            this.initUiTextPlotX();
            this.initUiTextPlotY();
        end
         
        function onFigureCloseRequest(this, src, evt)
            
            
            this.msg('onFigureCloseRequest()');
            if ~isvalid(this.hFigure)
                return
            end
            
            delete(this.hFigure);
            this.hFigure = [];
            
        end
        
        function onFigureWindowButtonDown(this, src, evt)
            
            this.showSetAsZeroIfAxesIsClicked();
            
        end
        
        
        function onFigureWindowMouseMotion(this, src, evt)
           
           this.msg('onWindowMouseMotion()');
           this.updateAxesCrosshair();
        end 
        
        function onUiScanStart(this, src, evt)
            
            this.msg('onUiScanStart');
            this.resetScanData()
            
            this.cDirScan = this.getScanDir();
            this.cPathRecipe = fullfile(this.cDirScan, 'recipe.json');
            this.saveRecipeToDisk(this.cPathRecipe);
            this.startNewScan();
                       
        end
        
        function onUiScanPause(this, ~, ~)
        
            this.scan.pause();
            this.updateUiScanStatus()
        end
        
        function onUiScanResume(this, ~, ~)
            
            this.scan.resume();
            this.updateUiScanStatus()
            
        end
        
        function onUiScanAbort(this, ~, ~)
            
            this.scan.stop(); % calls onScanAbort()
            
        end
        
        %{
        function onButtonScanStart(this, src, evt)
            
            this.msg('onButtonScanStart');
            
            this.resetScanData()
            this.hideScanStart();
            this.showScanPauseAbort();
            
            this.cPathRecipe = fullfile(this.cDirSave, this.getRecipeName());
            this.saveRecipeToDisk(this.cPathRecipe);
            this.startNewScan();
                       
        end
        
        function onButtonScanPause(this, ~, ~)
        
            if (this.uiToggleScanPause.get()) % just changed to true, so was playing
                this.scan.pause();
            else
                this.scan.resume();
            end
            
            this.updateUiScanStatus()
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
        %}
        
        function startNewScan(this)
            
            [stRecipe, lError] = this.loadRecipeFromDisk(this.cPathRecipe);
            
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

                return;
            end

            
            this.ceValues = cell(size(stRecipe.values));
             
            this.scan = mic.Scan(...
                'ui-beamline-scan', ...
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
                this.uiEditRecipeSteps.get() + uint16(1) ...
            );
            this.dScanDataParam = dValues;
            this.dScanDataValue = zeros(size(dValues)); 
            
            this.updatePlot()
            this.updatePlotXLimits()
            
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
        
        
        function updatePlotXLimits(this)
            
            if  isempty(this.hAxes) || ...
                ~ishandle(this.hAxes)
               
                this.msg('updatePlotLabels() returning due to empty Axes handle');
                return;
            end
            
            dMin = min(this.dScanDataParam);
            dMax = max(this.dScanDataParam);
            if dMin ~= dMax
                xlim(this.hAxes, [dMin dMax]);
            end
            
            
            
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
                '%s Current (%s)', ...
                this.uiPopupRecipeOutput.get().cLabel, ...
                this.uiD141Current.getUnit().name ...
            );
            ylabel(this.hAxes, cLabelY);
        end
        
        function onAxesButtonDown(this)
            this.msg('onAxesButtonDown()') 
        end
        
        
        function c = getPlotLabel(this)
            c = 'test (um)';
        end
        
        function initUiScan(this)
            %{
            this.uiScan = mic.ui.Scan(...
                'cTitle', '', ...
                'dWidth', 210, ...
                'dHeightPadPanel', 30, ...
                'dHeight', this.dHeightPanelRecipe ...
            );
            %}
            this.uiScan = mic.ui.Scan(...
                'cTitle', '', ...
                'dWidthBorderPanel', 0 ...
            );
            addlistener(this.uiScan, 'eStart', @this.onUiScanStart);
            addlistener(this.uiScan, 'ePause', @this.onUiScanPause);
            addlistener(this.uiScan, 'eResume', @this.onUiScanResume);
            addlistener(this.uiScan, 'eAbort', @this.onUiScanAbort);
        end
        
        function initUiRecipeStore(this)
            
            this.stUiRecipeStore = struct();
            
            this.stUiRecipeStore.(this.cNameDeviceExitSlit).start = 35;
            this.stUiRecipeStore.(this.cNameDeviceExitSlit).stop = 350;
            this.stUiRecipeStore.(this.cNameDeviceExitSlit).steps = uint16(10);
            
            this.stUiRecipeStore.(this.cNameDeviceUndulatorGap).start = 38;
            this.stUiRecipeStore.(this.cNameDeviceUndulatorGap).stop = 44;
            this.stUiRecipeStore.(this.cNameDeviceUndulatorGap).steps = uint16(5);
            
            this.stUiRecipeStore.(this.cNameDeviceShutter).start = 5;
            this.stUiRecipeStore.(this.cNameDeviceShutter).stop = 50;
            this.stUiRecipeStore.(this.cNameDeviceShutter).steps = uint16(5);
            
            this.stUiRecipeStore.(this.cNameDeviceGratingTiltX).start = 86;
            this.stUiRecipeStore.(this.cNameDeviceGratingTiltX).stop = 89;
            this.stUiRecipeStore.(this.cNameDeviceGratingTiltX).steps = uint16(20);
            
            this.stUiRecipeStore.(this.cNameDeviceD142StageY).start = 0;
            this.stUiRecipeStore.(this.cNameDeviceD142StageY).stop = 10;
            this.stUiRecipeStore.(this.cNameDeviceD142StageY).steps = uint16(20);
            
           
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
                
                switch this.uiPopupRecipeOutput.get().cValue
                    case this.cNameOutputM141Diode
                        stTask.type = this.cScanAcquireTypeM141Current;
                    case this.cNameOutputD141Diode
                        stTask.type = this.cScanAcquireTypeD141Current;
                    case this.cNameOutputD142Diode
                        stTask.type = this.cScanAcquireTypeD142Current;
                end
                
                stTask.pause = 0.1;
                
                stValue.task = stTask;
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
            end
            
            
            % Add one additional state to set the scanned parameter back to
            % its default value
            stValue = struct();
            stValue.(this.uiPopupRecipeDevice.get().cValue) = this.getValueOfSelectedDevice();
            ceValues{end + 1} = stValue;
            
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
            st.output = this.uiPopupRecipeOutput.get().cValue;
            
        end
        
        function st = getDeviceUnits(this)
            st = struct();
            st.(this.cNameDeviceGratingTiltX) = this.uiGratingTiltX.getUnit().name;
            st.(this.cNameDeviceShutter) = this.uiShutter.getUnit().name;
            st.(this.cNameDeviceExitSlit) = this.uiExitSlit.getUnit().name;
            st.(this.cNameDeviceUndulatorGap) = this.uiUndulatorGap.getUnit().name;
            st.(this.cNameDeviceD142StageY) = this.uiD142StageY.getUnit().name;
            st.(this.cNameDeviceD141Current) = this.uiD141Current.getUnit().name;
            st.(this.cNameDeviceM141Current) = this.uiM141Current.getUnit().name;
            st.(this.cNameDeviceD142Current) = this.uiD142Current.getUnit().name;
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
            
            % All possible things that could be acquired
            ceFields = {...
                this.cNameDeviceD141Current, ...
                this.cNameDeviceM141Current, ...
                this.cNameDeviceD142Current ...
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
        
        function c = getScanDir(this)
           
            % Generate a suggestion for the dir
            % [yyyymmdd-HHMMSS]-[device]-[unit]-[start]-[stop]-[steps]
           
            c = sprintf('%s__%s__%s__%1.1f_%1.1f_%1d', ...
                datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local'), ...
                this.uiPopupRecipeDevice.get().cValue, ...
                this.getRecipeDeviceUnit(), ...
                this.uiEditRecipeStart.get(), ...
                this.uiEditRecipeStop.get(), ...
                this.uiEditRecipeSteps.get() ...
            );
        
            c = fullfile(this.cDirSave, c);
            c = mic.Utils.path2canonical(c);
            mic.Utils.checkDir(c);

            
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
            
            % Update the contract
            
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
                        continue
                    otherwise
                        cUnit = stUnit.(ceFields{n}); 
                        dValue = stValue.(ceFields{n});
                end
                

                switch ceFields{n}
                    case this.cNameDeviceExitSlit
                        this.uiExitSlit.setDestCalDisplay(dValue, cUnit);
                        this.uiExitSlit.moveToDest(); % click
                    case this.cNameDeviceUndulatorGap
                        this.uiUndulatorGap.setDestCalDisplay(dValue, cUnit);
                        this.uiUndulatorGap.moveToDest(); % click
                    case this.cNameDeviceGratingTiltX 
                        this.uiGratingTiltX.setDestCalDisplay(dValue, cUnit);
                        this.uiGratingTiltX.moveToDest(); % click
                    case this.cNameDeviceD142StageY
                        this.uiD142StageY.setDestCalDisplay(dValue, cUnit);
                        this.uiD142StageY.moveToDest(); % click 
                    otherwise
                        % do nothing
                end
                
                
                this.stScanSetContract.(ceFields{n}).lIssued = true;
                cMsg = sprintf('onScanSetState() %s issued move', ceFields{n});
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN)
                
            end
                        

        end

        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stValue - the system state that needs to be reached
        % @returns {logical} - true if the system is at the state
        function lOut = onScanIsAtState(this, stUnit, stValue)

            lOut = true;

            this.updateUiScanStatus()
            
            stContract = this.stScanSetContract;
            ceFields= fieldnames(stContract);

            for n = 1:length(ceFields)

                cField = ceFields{n};

                % special case, skip task
                if strcmp(cField, 'task')
                    continue;
                end


                if stContract.(cField).lRequired

                    if stContract.(cField).lIssued

                        % !!! REQUIRED CODE !!! 
                        %
                        % Check if the set operation on the current device is
                        % complete by calling isReady() on devices.  This will
                        % often be a switch on cField that does something like:
                        % this.uiStage.getDevice().isReady()

                        switch ceFields{n}
                            case this.cNameDeviceExitSlit
                                lReady = this.uiExitSlit.getDevice().isReady();
                            case this.cNameDeviceUndulatorGap
                                lReady = this.uiUndulatorGap.getDevice().isReady();
                            case this.cNameDeviceGratingTiltX 
                                lReady = this.uiGratingTiltX.getDevice().isReady();
                            case this.cNameDeviceD142StageY
                                lReady = this.uiD142StageY.getDevice().isReady();
                            otherwise
                                lReady = true;
                                % do nothing
                        end

                        % !!! END REQUIRED CODE !!!

                        if lReady
                            if this.lDebugScan
                                this.msg(sprintf('onScanIsAtState() %s required, issued, complete', cField), this.u8_MSG_TYPE_SCAN);
                            end

                        else
                            if this.lDebugScan
                                this.msg(sprintf('onScanIsAtState() %s required, issued, incomplete', cField), this.u8_MSG_TYPE_SCAN);
                            end
                            lOut = false;
                            return;
                        end
                    else
                        if this.lDebugScan
                            this.msg(sprintf('onScanIsAtState() %s required, not issued.', cField), this.u8_MSG_TYPE_SCAN);
                        end

                        lOut = false;
                        return;
                    end                    
                else

                    if this.lDebugScan
                        this.msg(sprintf('onScanIsAtState() %s not required', cField), this.u8_MSG_TYPE_SCAN);
                    end
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
            
            stTask = stValue.task;
            
            % Update the contract
            switch stTask.type
                case this.cScanAcquireTypeD141Current
                    this.stScanAcquireContract.(this.cNameDeviceD141Current).lRequired = true;
                    this.stScanAcquireContract.(this.cNameDeviceD141Current).lIssued = false;
                case this.cScanAcquireTypeM141Current
                    this.stScanAcquireContract.(this.cNameDeviceM141Current).lRequired = true;
                    this.stScanAcquireContract.(this.cNameDeviceM141Current).lIssued = false;
                case this.cScanAcquireTypeD142Current
                    this.stScanAcquireContract.(this.cNameDeviceD142Current).lRequired = true;
                    this.stScanAcquireContract.(this.cNameDeviceD142Current).lIssued = false;
                
                otherwise
                    % Do nothing
            end
            
            % Execute the acquisition
            
            switch stTask.type
                
                case this.cScanAcquireTypeM141Current
                    
                    % Pause
                    pause(stTask.pause);
                    
                    % Get the state of the system
                    stValue = this.getState(stUnit);
                    this.ceValues{this.scan.u8Index} = stValue;
            
                    % Update the plot data with MeasurPoint value
                    this.dScanDataValue(this.scan.u8Index) = stValue.(this.cNameDeviceM141Current);
                                        
                    % Update the contract lIssued
                    this.stScanAcquireContract.(this.cNameDeviceM141Current).lIssued = true;
                    
                case this.cScanAcquireTypeD141Current
                    
                    %{
                    % Open the shutter
                    this.uiShutter.setDestCal(10000, 'ms');
                    this.uiShutter.moveToDest();
                    
                    %}
                    
                    % Pause
                    pause(stTask.pause);
                    
                    % Get the state of the system
                    stValue = this.getState(stUnit);
                    this.ceValues{this.scan.u8Index} = stValue;
            
                    % Update the plot data with MeasurPoint value
                    this.dScanDataValue(this.scan.u8Index) = stValue.(this.cNameDeviceD141Current);
                    
                    % TO DO
                    % Overwrite goal value of param with measured value
                    % this.dScanDataParam(this.scan.u8Index) = stValue.(this.uiPopupDeviceName.get().cValue)
                    
                    %{
                    % Close the shutter
                    this.uiShutter.stop();
                    %}
                    
                    % Update the contract lIssued
                    this.stScanAcquireContract.(this.cNameDeviceD141Current).lIssued = true;
                    
                case this.cScanAcquireTypeD142Current
                    
                    % Pause
                    pause(stTask.pause);
                    
                    % Get the state of the system
                    stValue = this.getState(stUnit);
                    this.ceValues{this.scan.u8Index} = stValue;
            
                    % Update the plot data with MeasurPoint value
                    this.dScanDataValue(this.scan.u8Index) = stValue.(this.cNameDeviceD142Current);
                                        
                    % Update the contract lIssued
                    this.stScanAcquireContract.(this.cNameDeviceD142Current).lIssued = true;
                    
                
                otherwise 
                    % do nothing
            end
            
            this.updateUiScanStatus();
            
        end

        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the acquisition task is complete
        function lOut = onScanIsAcquired(this, stUnit, stValue)

            lOut = true;
            
            stContract = this.stScanAcquireContract;
            ceFields= fieldnames(stContract);

            for n = 1:length(ceFields)

                cField = ceFields{n};

                if stContract.(cField).lRequired

                    if stContract.(cField).lIssued

                        % !!! REQUIRED CODE !!! 
                        % Check if the set operation on the current device is
                        % complete by calling isReady() on devices.  This will
                        % often be a switch on cField that does something like:
                        % this.uiStage.getDevice().isReady()
                        
                        
                        lReady = true;

                        % !!! END REQUIRED CODE !!!

                        if lReady
                            if this.lDebugScan
                                this.msg(sprintf('onScanIsAcquired() %s required, issued, complete', cField), this.u8_MSG_TYPE_SCAN);
                            end

                        else
                            if this.lDebugScan
                                this.msg(sprintf('onScanIsAcquired() %s required, issued, incomplete', cField), this.u8_MSG_TYPE_SCAN);
                            end
                            lOut = false;
                            return;
                        end
                    else
                        if this.lDebugScan
                            this.msg(sprintf('onScanIsAcquired() %s required, not issued.', cField), this.u8_MSG_TYPE_SCAN);
                        end

                        lOut = false;
                        return;
                    end                    
                else

                    if this.lDebugScan
                        this.msg(sprintf('onScanIsAcquired() %s not required', cField), this.u8_MSG_TYPE_SCAN);
                    end
                end
            end
            
            this.updatePlot();
        end


        function onScanAbort(this, stUnit)
        	 this.saveScanResults(stUnit, true);
             this.updateUiScanStatus()
        end


        function onScanComplete(this, stUnit)
             this.saveScanResults(stUnit);
             this.uiScan.reset();
             this.updateUiScanStatus()
        end
       
        % Validte a recipe structure.  
        function l = validateRecipe(this, stRecipe)
            l = true;
        end
        
        function updateUiScanStatus(this)
            
           this.uiScan.setStatus(this.scan.getStatus()); 
            
        end
        
        function saveScanResults(this, stUnit, lAborted)
            this.msg('saveScanResults()');
            
            if nargin <3
                lAborted = false;
            end
            this.saveScanResultsJson(stUnit, lAborted);
            this.saveScanResultsCsv(stUnit, lAborted);
        end
        
        function saveScanResultsJson(this, stUnit, lAborted)
       
            this.msg('saveScanResultsJson()');
             
            switch lAborted
                case true
                    cName = 'result-aborted.json';
                case false
                    cName = 'result.json';
            end
            
            cPath = fullfile(...
                this.cDirScan, ... % cDirScan
                cName ...
            );
        
            stResult = struct();
            stResult.recipe = this.cPathRecipe;
            stResult.unit = stUnit;
            stResult.values = this.ceValues;
            
            stOptions = struct();
            stOptions.FileName = cPath;
            stOptions.Compact = 0;
            
            
            savejson('', stResult, stOptions);     

        end
        
        
        function saveScanResultsCsv(this, stUnit, lAborted)
        
            this.msg('saveScanResultsCsv()');
            
            switch lAborted
                case true
                    cName = 'result-aborted.csv';
                case false
                    cName = 'result.csv';
            end
            
            cPath = fullfile(...
                this.cDirScan, ... 
                cName ...
            );
            
            if isempty(this.ceValues)
                return
            end
            
            % Open the file
            fid = fopen(cPath, 'w');

            % Write the header
            % Device
            fprintf(fid, '# "%s"\n', this.uiPopupRecipeDevice.get().cValue);
            
            % Write the field names
            ceNames = fieldnames(this.ceValues{1});
            for n = 1:length(ceNames)
                fprintf(fid, '%s,', ceNames{n});
            end
            fprintf(fid, '\n');

            % Write values
            for n = 1 : length(this.ceValues)
                stValue = this.ceValues{n};
                if ~isstruct(stValue)
                    continue
                end
                ceNames = fieldnames(stValue);
                for m = 1 : length(ceNames)
                    switch ceNames{m}
                        case 'time'
                            fprintf(fid, '%s,', stValue.(ceNames{m}));
                        otherwise
                            fprintf(fid, '%1.3e,', stValue.(ceNames{m}));
                    end
                end
                fprintf(fid, '\n');
            end

            % Close the file
            fclose(fid);

        end
        
        % Returns the value of whatever device is selected from the list of
        % devices in the scan panel.  This is used to set the scanned
        % device to its pre-scan value at the end of the scan
        function d = getValueOfSelectedDevice(this)
            
            switch this.uiPopupRecipeDevice.get().cValue
                case this.cNameDeviceExitSlit
                    d = this.uiExitSlit.getValCalDisplay();
                case this.cNameDeviceUndulatorGap
                    d = this.uiUndulatorGap.getValCalDisplay();
                case this.cNameDeviceGratingTiltX 
                    d = this.uiGratingTiltX.getValCalDisplay();
                case this.cNameDeviceD142StageY
                    d = this.uiD142StageY.getValCalDisplay();
                otherwise
                    % do nothing
            end
            
        end
        
        function st = getState(this, stUnit)
            
        	st = struct();
            st.(this.cNameDeviceM141Current) = this.uiM141Current.getValCal(stUnit.(this.cNameDeviceM141Current));
            st.(this.cNameDeviceD141Current) = this.uiD141Current.getValCal(stUnit.(this.cNameDeviceD141Current));
            st.(this.cNameDeviceD142Current) = this.uiD142Current.getValCal(stUnit.(this.cNameDeviceD142Current));
            st.(this.cNameDeviceExitSlit) = this.uiExitSlit.getValCal(stUnit.(this.cNameDeviceExitSlit));
            st.(this.cNameDeviceUndulatorGap) = this.uiUndulatorGap.getValCal(stUnit.(this.cNameDeviceUndulatorGap));
            st.(this.cNameDeviceGratingTiltX) = this.uiGratingTiltX.getValCal(stUnit.(this.cNameDeviceGratingTiltX));
            st.(this.cNameDeviceD142StageY) = this.uiD142StageY.getValCal(stUnit.(this.cNameDeviceD142StageY));
            st.time = datestr(datevec(now), 'yyyy-mm-dd HH:MM:SS', 'local');

        end
        
        function initUiCommDctCorbaProxy(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommDctCorbaProxy = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', this.dWidthNameComm, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%-dct-corba-proxy', this.cName), ...
                'cLabel', 'DCT Corba Proxy' ...
            );
        
        end
        
        function initUiCommBL1201CorbaProxy(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommBL1201CorbaProxy = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', this.dWidthNameComm, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-bl1201-corba-proxy', this.cName), ...
                'cLabel', 'BL1201 Corba Proxy' ...
            );
        
        end
        
        function initUiCommExitSlit(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommExitSlit = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', this.dWidthNameComm, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-exit-slit', this.cName), ...
                'cLabel', 'Exit Slit' ...
            );
        
        end
        
        function initUiCommDataTranslationMeasurPoint(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommDataTranslationMeasurPoint = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', this.dWidthNameComm, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-data-translation-measur-point', this.cName), ...
                'cLabel', 'DataTrans MeasurPoint' ...
            );
        
        end
        
        function initUiCommGalil(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommGalilD142 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', this.dWidthNameComm, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-galil-d142', this.cName), ...
                'cLabel', 'Galil' ...
            );
        
        end
        
        function initUiCommRigolDG1000Z(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommRigolDG1000Z = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
               'dWidthName', this.dWidthNameComm, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'rigol-dg1000z', ...
                'cLabel', 'Rigol DG1000Z' ...
            );
        
        end
        
        
        function initUiPositionRecaller(this)
            
            cDirThis = fileparts(mfilename('fullpath'));
            cPath = fullfile(cDirThis, '..', '..', 'save', 'position-recaller');
            this.uiPositionRecaller = mic.ui.common.PositionRecaller(...
                'cConfigPath', cPath, ... 
                'cName', [this.cName, '-position-recaller'], ...
                'cTitleOfPanel', 'Stored Scans', ...
                'lShowLabelOfList', false, ...
                'hGetCallback', @this.onUiPositionRecallerGet, ...
                'hSetCallback', @this.onUiPositionRecallerSet ...
            );
        end
        
        
        % Return list of values from your app
        function dValues = onUiPositionRecallerGet(this)
            
             % Cast as double for storage. If don't do this, the uint8
             % returned by getSelectedIndex() will cast the doubles
             % returned by get() to int and you turn floats to ints

            dValues = [...
                double(this.uiPopupRecipeDevice.getSelectedIndex()), ...
                double(this.uiEditRecipeStart.get()), ...
                double(this.uiEditRecipeStop.get()), ...
                double(this.uiEditRecipeSteps.get()), ...
                double(this.uiPopupRecipeOutput.getSelectedIndex()) ...
            ];
        
            
        end
        
        % Set recalled values into your app
        function onUiPositionRecallerSet(this, dValues)
            
            % Have to cast from double to correct type
            this.uiPopupRecipeDevice.setSelectedIndex(uint8(dValues(1)))
            this.uiEditRecipeStart.set(dValues(2))
            this.uiEditRecipeStop.set(dValues(3))
            this.uiEditRecipeSteps.set(uint16(dValues(4)))
            this.uiPopupRecipeOutput.setSelectedIndex(uint8(dValues(5)))
                        
        end
        
        
        function showSetAsZeroIfAxesIsClicked(this)
            
            % If the mouse is inside the axes, turn the cursor into a
           % crosshair, else make sure it is an arrow
           
           if ~ishandle(this.hFigure)
               return;
           end
           
           if ~ishandle(this.hAxes)
               return;
           end
           
          
           dCursor = get(this.hFigure, 'CurrentPoint');     % [left bottom]
           dAxes = get(this.hAxes, 'Position');             % [left bottom width height]
           dPoint = get(this.hAxes, 'CurrentPoint');
           
           dPositionPanel = get(this.hPanelData, 'Position');
           
           if isempty(dAxes)
               return;
           end
           
           dCursorLeft =    dCursor(1);
           dCursorBottom =  dCursor(2);
           
           % Need to include left/bottom of container panel to get correct
           % left / bottom of the Axes since its Position is relative to
           % its parent
           
           dAxesLeft =      dAxes(1) + dPositionPanel(1);
           dAxesBottom =    dAxes(2) + dPositionPanel(2);
           dAxesWidth =     dAxes(3);
           dAxesHeight =    dAxes(4);
           
           if   dCursorLeft >= dAxesLeft && ...
                dCursorLeft <= dAxesLeft + dAxesWidth && ...
                dCursorBottom >= dAxesBottom && ...
                dCursorBottom <= dAxesBottom + dAxesHeight
            
                
                cePrompt = {'Original Calibrated Value:', 'New Calibrated Value:'};
                cTitle = 'Set Clicked Position As Zero?';
                dLines = 1;
                ceDefaultAns = {...
                    sprintf('%1.3f', dPoint(1, 1)), ...
                    '0' ...
                };
                stOptions = struct(...
                    'Resize', 'on' ...
                );
                ceAnswer = inputdlg(...
                    cePrompt,...
                    cTitle,...
                    dLines,...
                    ceDefaultAns, ...
                    stOptions ...
                );

                if isempty(ceAnswer)
                    return
                end
                
                this.uiGratingTiltX.setValToNewVal(...
                    str2double(ceAnswer{1}), ...
                    str2double(ceAnswer{2}) ...
                );

   
           
           end
            
        end
        
        
        function updateAxesCrosshair(this)
            
           % If the mouse is inside the axes, turn the cursor into a
           % crosshair, else make sure it is an arrow
           
           if ~ishandle(this.hFigure)
               return;
           end
           
           if ~ishandle(this.hAxes)
               return;
           end
           
          
           dCursor = get(this.hFigure, 'CurrentPoint');     % [left bottom]
           dAxes = get(this.hAxes, 'Position');             % [left bottom width height]
           dPoint = get(this.hAxes, 'CurrentPoint');
           
           dPositionPanel = get(this.hPanelData, 'Position');
           
           if isempty(dAxes)
               return;
           end
           
           dCursorLeft =    dCursor(1);
           dCursorBottom =  dCursor(2);
           
           % Need to include left/bottom of container panel to get correct
           % left / bottom of the Axes since its Position is relative to
           % its parent
           
           dAxesLeft =      dAxes(1) + dPositionPanel(1);
           dAxesBottom =    dAxes(2) + dPositionPanel(2);
           dAxesWidth =     dAxes(3);
           dAxesHeight =    dAxes(4);
           
           if   dCursorLeft >= dAxesLeft && ...
                dCursorLeft <= dAxesLeft + dAxesWidth && ...
                dCursorBottom >= dAxesBottom && ...
                dCursorBottom <= dAxesBottom + dAxesHeight
            
                if strcmp(get(this.hFigure, 'Pointer'), 'arrow')
                    set(this.hFigure, 'Pointer', 'crosshair')
                end
                
                this.uiTextPlotX.set(sprintf('x: %1.3f', dPoint(1, 1)));
                this.uiTextPlotY.set(sprintf('y: %1.3e', dPoint(1, 2)));
           else
                if ~strcmp(get(this.hFigure, 'Pointer'), 'arrow')
                    set(this.hFigure, 'Pointer', 'arrow')
                end
                this.uiTextPlotX.set('x: [hover]');
                this.uiTextPlotY.set('y: [hover]');
           end
        end
        
        function initUiTextPlotX(this)
            
            this.uiTextPlotX = mic.ui.common.Text(...
                'cLabel', 'x: ' ...
            );
            
            
        end
        
        
        function initUiTextPlotY(this)
            this.uiTextPlotY = mic.ui.common.Text(...
                'cLabel', 'y: ' ...
            );
        end
        
    end
    
    
end




