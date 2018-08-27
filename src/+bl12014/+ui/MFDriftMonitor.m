% UI element that controls DMI and HS


classdef MFDriftMonitor < mic.Base
    
    
    properties (Constant)
        dWidth = 1400
        dHeight = 900
        
        cName = 'Drift monitor'
        
        dHS_ZTOL = 0.05; % 50 nm
        dHS_RTOL = 0.01; % 10 URAD
        
        u8DEVICE_DMI            = 1
        u8DEVICE_HEIGHT_SENSOR  = 2
        
        % HS channels:
        u8HS_CHANNEL_1 = 1;
        u8HS_CHANNEL_2 = 2;
        u8HS_CHANNEL_3 = 3;
        u8HS_CHANNEL_4 = 4;
        u8HS_CHANNEL_5 = 5;
        u8HS_CHANNEL_6 = 6;
        
        u8HS_CHANNEL_RX = 7;
        u8HS_CHANNEL_RY = 8;
        u8HS_CHANNEL_Z = 9;
        u8HS_CHANNEL_SZ = 10;
        
        % DMI channels:
        u8DMI_CHANNEL_RETX = 1;
        u8DMI_CHANNEL_RETY = 2;
        u8DMI_CHANNEL_WAFX = 3;
        u8DMI_CHANNEL_WAFY = 4;
        
        ceHSChannelNames = {'HS-Channel-6', 'HS-Channel-5', 'HS-Channel-4', 'HS-Channel-3', ...
            'HS-Channel-2', 'HS-Channel-1', 'HS-Rx', 'HS-Ry', 'HS-Z', 'HS-Simple-Z'}
%         ceHSChannelNames = {'HS-6: ang 8:30', 'HS-5: ang 4:30', 'HS-4: ang 0:30', 'HS-3: Z 1:30', ...
%             'HS-2: Z 9:30', 'HS-1: Z 5:30', 'HS-Rx', 'HS-Ry', 'HS-Z', 'HS-Simple-Z'}
        
        ceDMIChannelNames = {'DMI-Ret-X', 'DMI-Ret-Y', 'DMI-Wafer-X', 'DMI-Wafer-Y'}
        
        ceDMIPowerNames = {'Ret-U AC', 'Ret-V AC', 'Waf-U AC', 'Waf-V AC'; 'Ret-U DC', 'Ret-V DC','Waf-U DC', 'Waf-V DC'}
        
        ceScanAxisLabels = {'Hexapod-Z', 'Hexapod-Rx', 'Hexapod-Ry', 'Wafer-Z', 'Wafer-Rx', 'Wafer-Ry'}
        ceScanOutputLabels = {'Height sensor channels'};
        
        cHexapodAxisLabels = { 'Z', 'Rx', 'Ry'};
        cWaferLabels = { 'Waf-Z', 'Waf-Rx', 'Waf-Ry'};
                     
        
        
    end
    
    properties
        cAppPath        = fileparts(mfilename('fullpath'))
        cPRConfigPath     = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'config', 'position-recaller');

        
        
    end
    
    properties (SetAccess = private)
        % Channels to display, set these variables to a subset of this list
        % to show less channels
        dHeightSensorDisplayChannels = 1:10
        dDMIDisplayChannels = 1:4
        dDMI
        dDMIScanningTime
        dHS
        dHSScanningTime
        % Number of samples that are averaged
        dNumAve = 10
        
        
        
        % UI ELEMENTS
        
        hFigure % main figure
        
        % Two main tabs
        uitgMode
        
        % UI Connect
        uicConnectDriftMonitor
        
        % UI:Monitor
        
        % UI:Montor:DMI
        hpDMI
        uiDMIChannels
        haDMI
        uibClearDMI
        uicbDMIChannels
        uicbDMIDrift
        uieUpdateInterval
        
        uiDMIACPower
        uiDMIDCPower
        
        % UI:Montor:HS
        hpHS
        uiHeightSensorChannels
        haHS
        uibClearHS
        uibResetDMI
        uicbHeightSensorChannels

        
        % UI:Wafer-level
        
        haLevelMonitors
        uieZTarget
        uieRxTarget
        uieRyTarget
        uibLevel
        uiSLLevelCoordinateLoader
        uibClearLevelPlots
        
        % UI:Calibrate
        uicConnectHexapod
        uicConnectWafer
       
        
        
        
        
        % Scanner:
        scanHandler
        ssCalibration
        lIsScanning = false
        dCalibrationData = []
        dZIdx
        dRxIdx
        dRyIdx
        haScanMonitors = {}
        hpScanMonitor
        
        uiSLCalibration
        cLastCalibrationPath
        stActiveInterpolant
        cDefaultInterpolantPath = fullfile(fileparts(mfilename('fullpath')),...
             '..', '..', 'config', 'interpolants', 'cal-interp_2018-08-22_16.12.mat')
        
        
        % Scan progress text elements
        
        
        uiTextStatus
        uiTextTimeElapsed
        uiTextTimeRemaining
        uiTextTimeComplete
        
        % APIs and stages
        apiDriftMonitor     = []
        apiHexapod          = []
        apiWafer            = []
        oHexapodBridges
        uiDeviceArrayHexapod
        uiDeviceArrayWafer
        
        
        % Configuration
        uicHexapodConfigs
        uicWaferConfigs
        
        
        % Calibration text:
        uitCalibrationText
        
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        hardware
        
        
        dWidthName = 70
        dWidthUnit = 80
        dWidthVal = 75
        dWidthPadUnit = 30
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = MFDriftMonitor(varargin)
            for k = 1:2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            
            this.init();
            
        end
        
        function lVal = isAPIOn(this)
            lVal = ~isempty(this.apiDriftMonitor) && this.apiDriftMonitor.isConnected() && this.apiDriftMonitor.isReady() && ...
                ~isempty(this.hardware.commMFDriftMonitor);
        end
        
        function init(this)
            
            
            
            % Init DriftMonitor Hardware comm (connect button)
            this.uicConnectDriftMonitor = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'mf-drift-monitor', ...
                'cLabel', 'MFDrift Monitor',...
                'lUseFunctionCallbacks', true, ...
                'fhGet', @()this.isAPIOn,...
                'fhSet', @(lVal) mic.Utils.ternEval(lVal, ...
                                   @this.connectDriftMonitor, ...
                                   @this.disconnectDriftMontior...
                                ),...
                'fhIsInitialized', @()true,... 
                'fhIsVirtual', @false ...
                );
            
            this.uitCalibrationText = mic.ui.common.Text(...
                'lShowLabel', false, ...
                'dFontSize', 30, ... 
                'cFontWeight', 'bold', ...
                'cVal', 'Height sensor calibration interpolant:cal-interp_2018-08-22_16.12.mat' ...
                );
           
            
             ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

        
        
            this.uicConnectHexapod = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'smarpod-dm', ...
                'cLabel', 'SmarPod' ...
                );
            
  
            
            this.uicConnectWafer = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'delta-tau-wafer-dm', ...
                'cLabel', 'Delta Tau Wafer' ...
                );

        
            % Stage init:

            % Init stage device UIs
            cLSIConfigPath = fullfile(this.cAppPath, '..', '..', '..', 'vendor', 'github', 'ryanmiyakawa', 'LSI-Control',...
                    '+lsicontrol', '+ui', '+config');
            for k = 1:length(this.cHexapodAxisLabels)
                this.uicHexapodConfigs{k} = mic.config.GetSetNumber(...
                    'cPath', fullfile(cLSIConfigPath, sprintf('hex%d-dm.json', k + 2))...
                    );
                this.uiDeviceArrayHexapod{k} = mic.ui.device.GetSetNumber( ...
                    'cName', [this.cHexapodAxisLabels{k}, '-dm'], ...
                    'clock', this.clock, ...
                    'cLabel', this.cHexapodAxisLabels{k}, ...
                    'lShowLabels', false, ...
                    'lShowStores', false, ...
                    'lValidateByConfigRange', true, ...
                    'config', this.uicHexapodConfigs{k} ...
                    );
            end
            
            cWaferConfigPath = fullfile(this.cAppPath, '..', '..', 'config', 'get-set-number');
            ceWaferConfigNames = {
                'config-wafer-coarse-stage-z-dm.json', ...
                'config-wafer-coarse-stage-tilt-x-dm.json', ...
                'config-wafer-coarse-stage-tilt-y-dm.json'};
            for k = 1:length(this.cWaferLabels)
                
                this.uicWaferConfigs{k} = mic.config.GetSetNumber(...
                    'cPath', fullfile(cWaferConfigPath, ceWaferConfigNames{k})...
                    );
                
                this.uiDeviceArrayWafer{k} = mic.ui.device.GetSetNumber( ...
                    'cName', [this.cWaferLabels{k} , '-dm'], ...
                    'clock', this.clock, ...
                    'cLabel', this.cWaferLabels{k}, ...
                    'lShowLabels', false, ...
                    'lShowStores', false, ...
                    'lValidateByConfigRange', true, ...
                    'config', this.uicWaferConfigs{k} ...
                    );
            end
            
           
                
            
            % MAIN TABGROUP:
            this.uitgMode = ...
                mic.ui.common.Tabgroup('ceTabNames', ...
                {'Monitor', 'Wafer-level', 'Calibrate'});
            
            
            % UI:Monitor:
            
            % Init Height sensor UIs
            for k = 1:length(this.dHeightSensorDisplayChannels)
                u8Channel = this.dHeightSensorDisplayChannels(k);
                
                cPathConfig = fullfile(...
                    bl12014.Utils.pathUiConfig(), ...
                    'get-number', ...
                    sprintf('config-%s.json', this.ceHSChannelNames{u8Channel}) ...
                    );
                
                uiConfig = mic.config.GetSetNumber(...
                    'cPath',  cPathConfig ...
                    );
                
                this.uiHeightSensorChannels{k} = mic.ui.device.GetNumber(...
                    'clock', this.clock, ...
                    'dWidthName', this.dWidthName, ...
                    'dWidthUnit', this.dWidthUnit, ...
                    'dWidthVal', this.dWidthVal, ...
                    'dWidthPadUnit', this.dWidthPadUnit, ...
                    'cName', this.ceHSChannelNames{u8Channel}, ...
                    'config', uiConfig, ...
                    'cLabel', this.ceHSChannelNames{u8Channel}, ...
                    'lUseFunctionCallbacks', true, ...
                    'lShowZero', (k >= 7), ...
                    'lShowRel',  (k >= 7), ...
                    'lShowDevice', false, ...
                    'fhGet', @()this.apiDriftMonitor.getHeightSensorValue(u8Channel),...
                    'fhIsReady', @()this.apiDriftMonitor.isReady(),...
                    'fhIsVirtual',  @()isempty(this.apiDriftMonitor)...
                    );
                this.uicbHeightSensorChannels{k}= mic.ui.common.Checkbox(...
                    'cLabel',this.ceHSChannelNames{u8Channel},...
                    'fhDirectCallback', @(src, evt)this.cb(src));
                
                % By default plot hs rx, ry, rz:
                if any(k == [7, 8, 9])
                    this.uicbHeightSensorChannels{k}.set(true);
                else
                    this.uicbHeightSensorChannels{k}.set(false);
                end
            end
            
            
            % Init DMI sensor UI
            for k = 1:length(this.dDMIDisplayChannels)
                u8Channel = this.dDMIDisplayChannels(k);
                
                cPathConfig = fullfile(...
                    bl12014.Utils.pathUiConfig(), ...
                    'get-number', ...
                    sprintf('config-%s.json', this.ceDMIChannelNames{u8Channel}) ...
                    );
                
                uiConfig = mic.config.GetSetNumber(...
                    'cPath',  cPathConfig ...
                    );
                
                this.uiDMIChannels{k} = mic.ui.device.GetNumber(...
                    'clock', this.clock, ...
                    'dWidthName', this.dWidthName, ...
                    'dWidthUnit', this.dWidthUnit, ...
                    'dWidthVal', this.dWidthVal, ...
                    'dWidthPadUnit', this.dWidthPadUnit, ...
                    'cName', this.ceDMIChannelNames{u8Channel}, ...
                    'config', uiConfig, ...
                    'cLabel', this.ceDMIChannelNames{u8Channel}, ...
                    'lUseFunctionCallbacks', true, ...
                    'lShowZero', false, ...
                    'lShowRel',  false, ...
                    'lShowDevice', false, ...
                    'fhGet', @()this.apiDriftMonitor.getDMIValue(u8Channel),...
                    'fhIsReady', @()this.apiDriftMonitor.isReady(),...
                    'fhIsVirtual',  @()isempty(this.apiDriftMonitor)...
                    );
                this.uicbDMIChannels{k}= mic.ui.common.Checkbox(...
                    'cLabel',this.ceDMIChannelNames{u8Channel},...
                    'fhDirectCallback', @(src, evt)this.cb(src));
            end
            for k = 1:2
                ceDriftNames = {'Drift X', 'Drift Y'};
                this.uicbDMIDrift{k} = mic.ui.common.Checkbox(...
                    'cLabel' ,ceDriftNames{k},...
                    'fhDirectCallback', @(src, evt)this.cb(src));
            end
            for k = 1:size(this.ceDMIPowerNames, 2)
                this.uiDMIACPower =  mic.ui.device.GetNumber(...
                    'clock', this.clock, ...
                    'dWidthName', this.dWidthName, ...
                    'dWidthUnit', this.dWidthUnit, ...
                    'dWidthVal', this.dWidthVal, ...
                    'dWidthPadUnit', this.dWidthPadUnit, ...
                    'cName', this.ceDMIPowerNames{1, k}, ...
                    'config', uiConfig, ...
                    'cLabel', this.ceDMIPowerNames{1, k}, ...
                    'lUseFunctionCallbacks', true, ...
                    'lShowZero', false, ...
                    'lShowRel',  false, ...
                    'lShowDevice', false, ...
                    'fhGet', @()this.apiDriftMonitor.getACPower(k),...
                    'fhIsReady', @()this.apiDriftMonitor.isReady(),...
                    'fhIsVirtual',  @()isempty(this.apiDriftMonitor)...
                    );
                 this.uiDMIDCPower =  mic.ui.device.GetNumber(...
                    'clock', this.clock, ...
                    'dWidthName', this.dWidthName, ...
                    'dWidthUnit', this.dWidthUnit, ...
                    'dWidthVal', this.dWidthVal, ...
                    'dWidthPadUnit', this.dWidthPadUnit, ...
                    'cName', this.ceDMIPowerNames{2, k}, ...
                    'config', uiConfig, ...
                    'cLabel', this.ceDMIPowerNames{2, k}, ...
                    'lUseFunctionCallbacks', true, ...
                    'lShowZero', false, ...
                    'lShowRel',  false, ...
                    'lShowDevice', false, ...
                    'fhGet', @()this.apiDriftMonitor.getDCPower(k),...
                    'fhIsReady', @()this.apiDriftMonitor.isReady(),...
                    'fhIsVirtual',  @()isempty(this.apiDriftMonitor)...
                    );
            end
            
            % Init DMI power
            
           % bl12014.hardwareAssets.middleware.MFDriftMonitor.getDMIValue(1)
           % this.uiDMIChannels{1}.get()
            this.uieUpdateInterval    = mic.ui.common.Edit('cLabel', 'Interval(s)', 'cType', 'd');
            this.uieUpdateInterval.set(0.5);
            this.uibClearDMI    = mic.ui.common.Button('cText', 'Clear Plot', 'fhDirectCallback', @(src, evt)this.cb(src));
            this.uibClearHS     = mic.ui.common.Button('cText', 'Clear Plot', 'fhDirectCallback', @(src, evt)this.cb(src));
            this.uibResetDMI    = mic.ui.common.Button('cText', 'Zero DMI', 'fhDirectCallback', @(src, evt)this.cb(src));
            
            
            % UI:wafer-level:
            this.uiSLLevelCoordinateLoader = mic.ui.common.PositionRecaller(...
                'cConfigPath',  fullfile(fileparts(mfilename('fullpath')), '..', '..', 'config'), ...
                'cName', 'Wafer level coordinates', ...
                'hGetCallback', @this.getWaferLoadCoordinates, ...
                'hSetCallback', @this.setWaferLoadCoordinates);
            
            this.uieZTarget     = mic.ui.common.Edit('cLabel', 'Z target (um)', 'cType', 'd');
            this.uieRxTarget    = mic.ui.common.Edit('cLabel', 'Rx target (mRad)', 'cType', 'd');
            this.uieRyTarget    = mic.ui.common.Edit('cLabel', 'Ry target (mRad)', 'cType', 'd');
            
            this.uibLevel       = mic.ui.common.Button('cText', 'Level Wafer', 'fhDirectCallback', @(src, evt)this.cb(src));
            
            this.uibClearLevelPlots = mic.ui.common.Button('cText', 'Clear Plots', 'fhDirectCallback', @(src, evt)this.cb(src));
            
            this.uieZTarget.set(350);
            this.uieRxTarget.set(-3);
            this.uieRyTarget.set(-1);
            
            % UI:Calibrate:
            
            this.ssCalibration = mic.ui.common.ScanSetup( ...
                'cLabel', 'Saved pos', ...
                'ceOutputOptions', this.ceScanOutputLabels, ...
                'ceScanAxisLabels', this.ceScanAxisLabels, ...
                'dScanAxes', 3, ...
                'cName', '3D-Scan', ...
                'u8selectedDefaults', uint8([1, 2, 3]),...
                'cConfigPath', this.cPRConfigPath, ...
                'fhOnScanChangeParams', @(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames)...
                this.updateScanMonitor(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames, 0), ...
                'fhOnStopScan', @()this.stopScan, ...
                'fhOnScan', ...
                @(ceScanStates, u8ScanAxisIdx, lUseDeltas, u8ScanOutputDeviceIdx, cAxisNames)...
                this.onScan(this.ssCalibration, ceScanStates, u8ScanAxisIdx, lUseDeltas, u8ScanOutputDeviceIdx, cAxisNames) ...
                );
            
            
            % Save/Load Calibrations
             this.uiSLCalibration = mic.ui.common.PositionRecaller(...
                'cConfigPath',  fullfile(fileparts(mfilename('fullpath')), '..', '..', 'config'), ...
                'cName', 'Calibration interpolant', ...
                'lDisableSave', true, ... 
                'hGetCallback', @this.getCalibration, ...
                'hSetCallback', @this.setCalibration);
            
            
            
            % Scan text elements:
             % Scan progress text elements:
            dStatusFontSize = 14;
            this.uiTextStatus = mic.ui.common.Text(...
                'cLabel', 'Status', ...
                'lShowLabel', true, ...
                'dFontSize', dStatusFontSize, ... 
                'cFontWeight', 'bold', ...
                'cVal', ' ' ...
                );
            this.uiTextTimeElapsed = mic.ui.common.Text(...
                'cLabel', 'Elapsed', ...
                'lShowLabel', true, ...
                'dFontSize', dStatusFontSize, ... 
                'cFontWeight', 'bold', ...
                'cVal', ' ' ...
                );
            this.uiTextTimeRemaining = mic.ui.common.Text(...
                'cLabel', 'Remaining', ...
                'lShowLabel', true, ...
                'dFontSize', dStatusFontSize, ... 
                'cFontWeight', 'bold', ...
                'cVal', ' ' ...
                );
            this.uiTextTimeComplete = mic.ui.common.Text(...
                'cLabel', 'Complete', ...
                'lShowLabel', true, ...
                'cFontWeight', 'bold', ...
                'cVal', ' ' ...
                );
            this.uiTextTimeComplete.setFontSize(dStatusFontSize);
            this.uiTextTimeElapsed.setFontSize(dStatusFontSize);
            this.uiTextTimeRemaining.setFontSize(dStatusFontSize);
            this.uiTextStatus.setFontSize(dStatusFontSize);
            
            
            
            
        end
        
        %% Accessor:
        
        % Gets X and Y reticle values separately from normal update loop
        function dVal = getReticleDMIValues(this)
            this.apiDriftMonitor.forceUpdate();
            dVal = [this.apiDriftMonitor.getDMIValue(1);this.apiDriftMonitor.getDMIValue(2)];
        end
        
        function dVal = getHSValues(this)
            this.apiDriftMonitor.forceUpdate();
             dVal = [this.apiDriftMonitor.getHeightSensorValue(7); this.apiDriftMonitor.getHeightSensorValue(8);  this.apiDriftMonitor.getHeightSensorValue(9)];
        end
        
        %% Calibration S/L handlers:
        function setCalibration(this, dVal)
            this.cLastCalibrationPath = dVal;
            [~, p, e] = fileparts(dVal);
            this.uitCalibrationText.set(sprintf('Height sensor calibration interpolant: %s', [p, e]));
            
            load(dVal);
            
            this.apiDriftMonitor.setInterpolant(stCalibrationData);
            this.stActiveInterpolant = stCalibrationData;
            msgbox(sprintf('Set calibration interpolant to: %s', p));
        end
        
        function dVal = getCalibration(this)
            dVal = regexprep(this.cLastCalibrationPath, '\', '/');
        end
        
        
        function setWaferLoadCoordinates(this, dVal)
            this.uieZTarget.set(dVal(1));
            this.uieRxTarget.set(dVal(2));
            this.uieRyTarget.set(dVal(3));
        end
        
        function dVal = getWaferLoadCoordinates(this)
            dZTarget  = this.uieZTarget.get();
            dRxTarget = this.uieRxTarget.get();
            dRyTarget = this.uieRyTarget.get();
            
            dVal = [dZTarget, dRxTarget, dRyTarget];
        end
        %% Hardware init:
        % Set up hardware connect/disconnects:
        function connectDriftMonitor(this)
            if ~this.isAPIOn()
                this.apiDriftMonitor = this.hardware.getMFDriftMonitor();
            end
            if ~isempty(this.clock)&&~this.clock.has(this.id())
                this.clock.add(@this.onClock, this.id(), 1);
                this.uieUpdateInterval.disable();
            end
            
            % Init interpolant:
            this.setCalibration(this.cDefaultInterpolantPath);
            this.apiDriftMonitor.start();
            this.apiDriftMonitor.setDMIZero();
            
        end
        

        function disconnectDriftMontior(this)
            this.hardware.deleteMFDriftMonitor();
            this.apiDriftMonitor = [];
            this.disconnectMiddleware();
            this.uieUpdateInterval.enable();
            
            
        end
        
        function disconnectMiddleware(this)
            if isvalid(this.clock) &&  this.clock.has(this.id())
                this.clock.remove(this.id());
            end
        end
        
         % Builds hexapod java api, connecting getSetNumber UI elements
        % to the appropriate API hooks.  Device is already connected
        function setHexapodDeviceAndEnable(this, device)
            
            % Instantiate javaStageAPIs for communicating with devices
            this.apiHexapod 	= lsicontrol.javaAPI.CXROJavaStageAPI(...
                                  'jStage', device);
           
            % Check if we need to index stage:
            if (~this.apiHexapod.isInitialized())
                if strcmp(questdlg('Hexapod is not referenced. Index now?'), 'Yes')
                    this.apiHexapod.home();
                     % Wait till hexapod has finished move:
                    dafHexapodHome = mic.DeferredActionScheduler(...
                        'clock', this.clock, ...
                        'fhAction', @()this.setHexapodDeviceAndEnable(device),...
                        'fhTrigger', @()this.apiHexapod.isInitialized(),...
                        'cName', 'DASHexapodIndexing', ...
                        'dDelay', 0.5, ...
                        'dExpiration', 10, ...
                        'lShowExpirationMessage', true);
                    dafHexapodHome.dispatch();
                
                end
                return % Return in either case, only proceed if initialized
            end
            
            % Use coupled-axis bridge to create single axis control
            dSubR = [0 -1 0 ; -1 0 0; 0 0 1];
            dHexapodR = [dSubR, zeros(3); zeros(3), dSubR];  
            for k = 1:3
                this.oHexapodBridges{k} = lsicontrol.device.CoupledAxisBridge(this.apiHexapod, k + 2, 6);
                this.oHexapodBridges{k}.setR(dHexapodR);
                this.uiDeviceArrayHexapod{k}.setDevice(this.oHexapodBridges{k});
                this.uiDeviceArrayHexapod{k}.turnOn();
                this.uiDeviceArrayHexapod{k}.syncDestination();
            end
        end
        
        % Resets api, bridges, and disconnects hardware device.
        function disconnectHexapod(this)
            for k = 1:3
                this.oHexapodBridges{k} = [];
                this.uiDeviceArrayHexapod{k}.turnOff();
                this.uiDeviceArrayHexapod{k}.setDevice([]);
            end
            
            % Disconnect the stage:
            this.apiHexapod.disconnect();
            
            % Delete the Stage API
            this.apiHexapod = [];
        end
        
        % Set up wafer
        function setWaferAxisDevice(this, device, index)
            this.uiDeviceArrayWafer{index}.setDevice(device);
            this.uiDeviceArrayWafer{index}.turnOn();
            this.uiDeviceArrayWafer{index}.syncDestination();
        end
        
        
        function disconnectWaferAxisDevice(this, index)
            this.uiDeviceArrayWafer{index}.turnOff();
            this.uiDeviceArrayWafer{index}.setDevice([]);
        end
        
        function onClock(this)
            try
            
                if ~this.isAPIOn()
                    this.disconnectMiddleware();
                    return
                end
                %DMI Scanning
                plotDMI=[];
                dZVals = [];
                dRxVals = [];
                dRyVals = [];
                
                lgdDMI=[];
                DMIValue=zeros(length(this.dDMIDisplayChannels),1);
                for k=1:length(this.dDMIDisplayChannels)
                    if ~isempty(this.apiDriftMonitor)
                        DMIValue(k,1)=this.uiDMIChannels{k}.getValCalDisplay;
                    else
                        DMIValue(k,1)=randn(1);
                    end
                end
                this.dDMI(1:length(this.dDMIDisplayChannels),end+1)=DMIValue;
                this.dDMIScanningTime(end+1)=length(this.dDMIScanningTime)*this.uieUpdateInterval.get();
                for k=1:length(this.dDMIDisplayChannels)
                    if this.uicbDMIChannels{k}.get()
                        plotDMI(end+1,:)=this.dDMI(k,:);
                        lgdDMI{end+1}=this.ceDMIChannelNames{k};
                    end
                end
                
                % Plot DMI difference channels:
                ceDifferenceChannelNames = {'X drift', 'Y drift'};
                for k = 1:2
                    if this.uicbDMIDrift{k}.get()
                       
                        if k == 1 % X
                            % Ret fine X points toward 03:00, wafer coarse x
                            % also points to 09:00
                             plotDMI(end+1,: )= 5*this.dDMI(k + 2,:) + this.dDMI(k,:);
                        elseif k == 2 % Y
                             % in y, reticle fine y and wafer y point in
                            % opposite physical directions.  reticle fine y
                            % points to 12:00; wafer coarse y points to 06:00
                             plotDMI(end+1,: )= -5*this.dDMI(k + 2,:) + this.dDMI(k,:);
                        end
                        lgdDMI{end+1}=ceDifferenceChannelNames{k};
                    end
                end
                
               
                %HS Scanning
                plotHS=[];
                lgdHS=[];
                HSValue=zeros(length(this.dHeightSensorDisplayChannels),1);
                for k=1:length(this.dHeightSensorDisplayChannels)
                    if ~isempty(this.apiDriftMonitor)
                        HSValue(k,1)=this.uiHeightSensorChannels{k}.getValCalDisplay();
                    else
                        HSValue(k,1)=randn(1);
                    end
                end
                this.dHS(1:length(this.dHeightSensorDisplayChannels),end+1)=HSValue; 
                this.dHSScanningTime(end+1)=length(this.dHSScanningTime)*this.uieUpdateInterval.get();
                for k=1:length(this.dHeightSensorDisplayChannels)
                    if this.uicbHeightSensorChannels{k}.get()
                        plotHS(end+1,:)=this.dHS(k,:);
                        lgdHS{end+1}=this.ceHSChannelNames{k};
                    end
                    
                end
                dZVals(end+1, :) = this.dHS(9,:);
                dRxVals(end+1, :) = this.dHS(7,:);
                dRyVals(end+1, :) = this.dHS(8,:);
                
                
                % plot only if monitor tab is active
                if strcmp(this.uitgMode.getSelectedTabName(), 'Monitor')
                    % Plot dmi
                    if ~isempty(plotDMI)
                        plot(this.haDMI, this.dDMIScanningTime,plotDMI);legend(this.haDMI,lgdDMI, 'location', 'southwest');
                    end
                    this.haDMI.Title.String = 'DMI trace';
                    this.haDMI.XLabel.String = 'Scan Time (s)';
                    this.haDMI.YLabel.String = 'Unit';
                    
                    % Plot HS
                    if ~isempty(plotHS)
                        plot(this.haHS, this.dHSScanningTime,plotHS);legend(this.haHS,lgdHS, 'location', 'southwest');
                    end
                    this.haHS.Title.String = 'Height sensor trace';
                    this.haHS.XLabel.String = 'Scan Time (s)';
                    this.haHS.YLabel.String = 'Unit';
                end
                
                % Plot on wafer level if tab is active
                if strcmp(this.uitgMode.getSelectedTabName(), 'Wafer-level')
                    plot(this.haLevelMonitors{1}, this.dHSScanningTime, dZVals, 'k');
                    plot(this.haLevelMonitors{2}, this.dHSScanningTime, dRxVals, 'k');
                    plot(this.haLevelMonitors{3}, this.dHSScanningTime, dRyVals, 'k');
                    
                    this.haLevelMonitors{1}.NextPlot = 'add';
                    this.haLevelMonitors{2}.NextPlot = 'add';
                    this.haLevelMonitors{3}.NextPlot = 'add';
                    
                    % Show targets:
                    dZTarget = this.uieZTarget.get();
                    dRxTarget = this.uieRxTarget.get();
                    dRyTarget = this.uieRyTarget.get();
                    
                    dZH = dZTarget + this.dHS_ZTOL/2;
                    dZL = dZTarget - this.dHS_ZTOL/2;
                    dRxH = dRxTarget + this.dHS_RTOL/2;
                    dRxL = dRxTarget - this.dHS_RTOL/2;
                    dRyH = dRyTarget + this.dHS_RTOL/2;
                    dRyL = dRyTarget - this.dHS_RTOL/2;
                    
                    dFirstIdx = this.dHSScanningTime(1);
                    dLastIdx = this.dHSScanningTime(end);
                    
                    % Plot centerline
                    plot(this.haLevelMonitors{1}, [dFirstIdx, dLastIdx], dZTarget*[1, 1], 'g');
                    plot(this.haLevelMonitors{2}, [dFirstIdx, dLastIdx], dRxTarget*[1, 1], 'g');
                    plot(this.haLevelMonitors{3}, [dFirstIdx, dLastIdx], dRyTarget*[1, 1], 'g');
                    
                    
                    % Plot H/L tol
                    plot(this.haLevelMonitors{1}, [dFirstIdx, dLastIdx], dZH*[1, 1], 'm');
                    plot(this.haLevelMonitors{1}, [dFirstIdx, dLastIdx], dZL*[1, 1], 'm');
                    plot(this.haLevelMonitors{2}, [dFirstIdx, dLastIdx], dRxH*[1, 1], 'm');
                    plot(this.haLevelMonitors{2}, [dFirstIdx, dLastIdx], dRxL*[1, 1], 'm');
                    plot(this.haLevelMonitors{3}, [dFirstIdx, dLastIdx], dRyH*[1, 1], 'm');
                    plot(this.haLevelMonitors{3}, [dFirstIdx, dLastIdx], dRyL*[1, 1], 'm');
                    
                    this.haLevelMonitors{1}.Title.String = sprintf('Z');
                    this.haLevelMonitors{2}.Title.String = sprintf('Rx');
                    this.haLevelMonitors{3}.Title.String = sprintf('Ry');
                    
                    this.haLevelMonitors{1}.NextPlot = 'replace';
                    this.haLevelMonitors{2}.NextPlot = 'replace';
                    this.haLevelMonitors{3}.NextPlot = 'replace';
                    
                end
                
                
            catch mE
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
                %         %AW(5/24/13) : Added a timer stop when the axis instance has been
                %         %deleted
                %         if (strcmp(mE.identifier,'MATLAB:class:InvalidHandle'))
                %                 %msgbox({'Axis Timer has been stopped','','NON-CRITICAL ERROR','This textbox is here for debugging error'});
                %                 stop(this.t);
                %         else
                %             this.msg(mE.message);
                %         end

                % CA 2016 remove the task from the timer
%                 if isvalid(this.clock) && ...
%                         this.clock.has(this.id())
%                     this.clock.remove(this.id());
%                 end

               % error(mE);
            end
        end
        
        function cb(this, src)
            switch src
                
                case this.uibClearDMI
                    this.dDMI=[];
                    this.dDMIScanningTime=[];
                    
                case {this.uibClearHS, this.uibClearLevelPlots}
                    this.dHS=[];
                    this.dHSScanningTime=[];
                case this.uibResetDMI
                    this.apiDriftMonitor.setDMIZero();
            end
        end
      
        
        
        %% CALIBRATION SCAN HANDLERS
        function dInitialState = getInitialState(this, u8ScanAxisIdx)
            % grab initial state of values:
            dInitialState = struct;
            dInitialState.values = [];
            dInitialState.axes = u8ScanAxisIdx;
            
            % validate start conditions and get initial state
            for k = 1:length(u8ScanAxisIdx)
                dAxis = double(u8ScanAxisIdx(k));
                switch dAxis
                    case {1, 2, 3} % Hexapod
                        if isempty(this.apiHexapod)
                            dInitialState.values(k) = 0;
                            continue
                        end
                        
                        dUnit =  this.uiDeviceArrayHexapod{dAxis}.getUnit().name;
                        dInitialState.values(k) = this.uiDeviceArrayHexapod{dAxis}.getValCal(dUnit);
                        
                    case {4, 5, 6} % wafer
                       
                        
                        dUnit =  this.uiDeviceArrayWafer{dAxis - 3}.getUnit().name;
                        dInitialState.values(k) = this.uiDeviceArrayWafer{dAxis - 3}.getValCal(dUnit);
                        
                end
            end
            
        end
        
        function onScan(this, ssScanSetup, stateList, u8ScanAxisIdx, lUseDeltas, u8OutputIdx, cAxisNames)
            
            % If already scanning, then stop:
            if(this.lIsScanning)
                return
            end
            
            dInitialState = this.getInitialState(u8ScanAxisIdx);
            
            
            % If using deltas, modify state to center around current
            % values:
            for m = 1:length(u8ScanAxisIdx)
                if lUseDeltas(m)
                    for k = 1:length(stateList)
                        stateList{k}.values(m) = stateList{k}.values(m) + dInitialState.values(m);
                    end
                end
            end
            
            % validate output conditions
            switch u8OutputIdx
                case 1 % HS channels
                    dNStates = length(stateList);
                    this.dCalibrationData = zeros(dNStates, 6);
                    this.dZIdx = zeros(dNStates, 1);
                    this.dRxIdx = zeros(dNStates, 1);
                    this.dRyIdx = zeros(dNStates, 1);
        
                    if ~(this.apiDriftMonitor.isConnected())
                        msgbox('Drift monitor is not connected')
                        return
                    end
            end
                        
            
            % Build "scan recipe" from scan states
            stRecipe.values = stateList; % enumerable list of states that can be read by setState
            stRecipe.unit = struct('unit', 'unit'); % not sure if we need units really, but let's fix later
            
            fhSetState      = @(stUnit, stState) this.setScanAxisDevicesToState(stState);
            fhIsAtState     = @(stUnit, stState) this.areScanAxisDevicesAtState(stState);
            fhAcquire       = @(stUnit, stState) this.scanAcquire(u8OutputIdx, stateList, u8ScanAxisIdx, lUseDeltas, cAxisNames);
            fhIsAcquired    = @(stUnit, stState) this.scanIsAcquired(stState, u8OutputIdx);
            fhOnComplete    = @(stUnit, stState) this.onScanComplete(dInitialState, fhSetState);
            fhOnAbort       = @(stUnit, stState) this.onScanAbort(dInitialState, fhSetState, fhIsAtState);
            dDelay          = 0.2;
            % Create a new scan:
            this.scanHandler = mic.Scan('mf-drift-monitor-calibration', ...
                this.clock, ...
                stRecipe, ...
                fhSetState, ...
                fhIsAtState, ...
                fhAcquire, ...
                fhIsAcquired, ...
                fhOnComplete, ...
                fhOnAbort, ...
                dDelay...
                );
            
            % Start scanning
            this.lIsScanning = true;
            this.scanHandler.start();
        end
        
        function stopScan(this)
            
            this.scanHandler.stop();
            this.lIsScanning = false;
        end
        
        function updateScanProgress(this)
            stScanProgress = this.scanHandler.getStatus();
            
            % Scan progress text elements:
            this.uiTextStatus.set(sprintf('%0.1f %%', stScanProgress.dProgress * 100) );
            this.uiTextTimeElapsed.set(sprintf('%s', stScanProgress.cTimeElapsed));
            this.uiTextTimeRemaining.set(sprintf('%s', stScanProgress.cTimeRemaining) );
            this.uiTextTimeComplete.set(sprintf('%s', stScanProgress.cTimeComplete) );
            
        end
        
       
        
        
        % Sets device to enumerated state
        function setScanAxisDevicesToState(this, stState)
            dAxes = stState.axes;
            dVals = stState.values;
            
            % For coupled-axis stages, we need to defer movement till at
            % the end to avoid multiple commands to same stage when
            % stage is not ready yet
            
            % find out if hexapod is moving
            lDeferredHexapodMove = false;
            for k = 1:length(dAxes)
                switch dAxes(k)
                    case {1, 2, 3} % Hexapod
                        lDeferredHexapodMove = true;
                end
            end
            
            if lDeferredHexapodMove
                dPosHexRaw = zeros(6,1);
                for k = 1:3
                    dPosHexRaw(k + 2) = this.uiDeviceArrayHexapod{k}.getValRaw();  %#ok<AGROW>
                end
            end
            
            
            for k = 1:length(dAxes)
                dVal = dVals(k);
                dAxis = dAxes(k);
                switch dAxis
                    case {1, 2, 3} % Hexapod: generate deferred move
                        this.uiDeviceArrayHexapod{dAxis}.setDestCal(dVal);
                        dPosHexRaw(dAxis + 2) = this.uiDeviceArrayHexapod{dAxis}.getDestRaw();
                   
                    case {4, 5, 6} % wafer: move now
                        this.uiDeviceArrayWafer{dAxis - 3}.setDestCal(dVal);
                        this.uiDeviceArrayWafer{dAxis - 3}.moveToDest();
                end
            end
            
            if lDeferredHexapodMove
                this.uiDeviceArrayHexapod{1}.getDevice().moveAllAxesRaw(dPosHexRaw);
            end
            
        end
        
        % For isAtState, we assume that if the device is ready then it is
        % at state, since closed loop control is performed in device
        function isAtState = areScanAxisDevicesAtState(this, stState)
            
            dAxes = stState.axes;
            
            for k = 1:length(dAxes)
                dAxis = dAxes(k);
                switch dAxis
                    case {1, 2, 3} % Hexapod
                        if ~this.apiHexapod.isReady()
                            isAtState = false;
                            return
                        end
                    case {4, 5, 6} % wafer
                        if ~this.uiDeviceArrayWafer{dAxis - 3}.getDevice().isReady()
                            isAtState = false;
                            return
                        end
                        
                        dUnit =  this.uiDeviceArrayWafer{dAxis - 3}.getUnit().name;
                        dCommandedDest = this.uiDeviceArrayWafer{dAxis - 3}.getDestCal(dUnit);
                        dAxisPosition = this.uiDeviceArrayWafer{dAxis - 3}.getValCal(dUnit);
                        dEps = abs(dCommandedDest - dAxisPosition);
                        fprintf('Commanded destination: %0.3f, Actual pos: %0.3f, eps: %0.4f\n', ...
                            dCommandedDest, dAxisPosition, dEps);
                        dTolerance = 0.01; % scan unit assumed to be mm here
                        %                         if ~this.uiDeviceArrayReticle{retAxis}.getDevice().isReady() || ...
                        if dEps > dTolerance
                            
                            fprintf('Wafer is within tolerance\n');
                            isAtState = false;
                            return
                        end
                        isAtState = true;
                end
            end
            
            isAtState = true;
        end
        
        function scanAcquire(this, outputIdx, stateList, u8ScanAxisIdx, lUseDeltas, cAxisNames)
             
            % Notify scan progress that we are at state idx: u8Idx:
            u8Idx = this.scanHandler.getCurrentStateIndex();
            this.updateScanMonitor(stateList, u8ScanAxisIdx, lUseDeltas, cAxisNames, u8Idx);
            
            % Notify progress monitor
            this.updateScanProgress();
            
            
            
            % outputIdx: {'Image capture', 'Image intensity', 'Line Contrast', 'Line Pitch', 'Pause 2s'}
            switch outputIdx
                case 1
                    % Read off HS channel values and store
                    % Update HS:
                    this.apiDriftMonitor.forceUpdate();
                    
                    dHSValues = zeros(6,1);
                    for k = 1:6
                        dHSValues(k) = this.apiDriftMonitor.getHeightSensorValue(k);
                    end
                    this.dCalibrationData(u8Idx, 1:6) = dHSValues';
                    this.dZIdx(u8Idx) = stateList{u8Idx}.values(1);
                    this.dRxIdx(u8Idx) =  stateList{u8Idx}.values(2);
                    this.dRyIdx(u8Idx) =  stateList{u8Idx}.values(3);
                    
            end
            
            
        end
        
        function lAcquisitionFinished = scanIsAcquired(this, stState, outputIdx)
            % outputIdx: {'Image capture', 'Image intensity', 'Line Contrast', 'Line Pitch'}
            
            % Each output should have a value to plot
            dAcquiredValue = 1;
            
            switch outputIdx
                case 1
                    % Notify that we are finished acquiring.
            end
            
            % We can immediately resolve this since processing will happen
            % synchronously
            lAcquisitionFinished = true;
        end
        
        function onScanComplete(this, dInitialState, fhSetState)
            this.lIsScanning = false;
            % Reset to initial state on complete
            fhSetState([], dInitialState);
            
            scanRanges = this.ssCalibration.getScanRanges();
            

            cInterpolantsPath = fullfile(fileparts(mfilename('fullpath')), '..', '..', 'config', 'interpolants');
            cInterpolantName = sprintf('cal-interp_%s', datestr(now, 'yyyy-mm-dd_HH.MM'));
            % Build interpolant structure:
            stCalibrationData = struct;
            stCalibrationData.dChannelReadings = this.dCalibrationData;
            stCalibrationData.zIdx = scanRanges{1} + dInitialState.values(1);
            stCalibrationData.RxIdx = scanRanges{2} + dInitialState.values(2);
            stCalibrationData.RyIdx = scanRanges{3} + dInitialState.values(3);
            
            cCalibrationPath = [cInterpolantsPath, filesep, cInterpolantName, '.mat'];
            save(cCalibrationPath, 'stCalibrationData')
            % add this to save list
            
            this.cLastCalibrationPath = cCalibrationPath;
            this.uiSLCalibration.programmaticSave(cInterpolantName);
        end
        
        function onScanAbort(this, dInitialState, fhSetState, fhIsAtState)
            this.lIsScanning = false;
            % Reset to inital state on abort, but wait for scan to complete
            % current move before resetting:
            dafScanAbort = mic.DeferredActionScheduler(...
                'clock', this.clock, ...
                'fhAction', @()fhSetState([], dInitialState),...
                'fhTrigger', @()fhIsAtState([], dInitialState),... % Just needs a dummy state here
                'cName', 'DASScanAbortReset', ...
                'dDelay', 0.5, ...
                'dExpiration', 10, ...
                'lShowExpirationMessage', true);
            dafScanAbort.dispatch();

        end
        
      
        
        % This will be called anytime scan parameters or the scan tab is
        % changed
        function updateScanMonitor(this, stateList, u8ScanAxisIdx, lUseDeltas, cAxisNames, u8Idx)
            
            
            shiftedStateList = stateList;
            if (u8Idx == 0) % We haven't started scanning yet so make a proper prieview of relative scan WRT initial state
                if (any(lUseDeltas))
                    dInitialState = this.getInitialState(u8ScanAxisIdx);
                else
                    dInitialState = [];
                end

                % If using deltas, modify state to center around current
                % values:
                
                for m = 1:length(u8ScanAxisIdx)
                    if lUseDeltas(m)
                        for k = 1:length(stateList)
                            shiftedStateList{k}.values(m) = stateList{k}.values(m) + dInitialState.values(m);
                        end
                    end
                end
            end
            
            % Plot states on scan monitor tabgroup:
            for k = 1:length(this.haScanMonitors)
                delete(this.haScanMonitors{k});
            end
            
            dNumAxes = length(u8ScanAxisIdx);
            dYPos = 0.1;
            dYHeight = (.85 - (dNumAxes - 1) * 0.05)/dNumAxes;
            for k = 1:dNumAxes
                kp = dNumAxes - k + 1;
                
                this.haScanMonitors{kp} = ...
                    axes('Parent', this.hpScanMonitor,...
                   'XTick', [0, 1], ...
                   'YTick', [0, 1], ...
                   'Position', [0.1, dYPos, .8, dYHeight], ... 
                    'FontSize', 12);
                dYPos = dYPos + 0.05 + dYHeight;
                ylabel(this.haScanMonitors{kp}, cAxisNames{kp});
            end
            
            % Don't need to update 
            if isempty(stateList)
                return
            end
            
            
            % unpack state into axes:
            stateData = [];
            for k = 1:length(shiftedStateList)
                state = shiftedStateList{k};
                for m = 1:dNumAxes
                    stateData(m, k) = state.values(m);
                end
                
            end
            for m = 1:dNumAxes
                plot(this.haScanMonitors{m}, 1:length(stateList), stateData(m, :), 'k');
                this.haScanMonitors{m}.NextPlot = 'add';
                if u8Idx > 0
                     plot(this.haScanMonitors{m}, double(u8Idx), stateData(m, double(u8Idx)),...
                         'ko', 'LineWidth', 1, 'MarkerFaceColor', [.3, 1, .3], 'MarkerSize', 5);
                end
                ylabel(this.haScanMonitors{m}, cAxisNames{m});
                this.haScanMonitors{m}.NextPlot = 'replace';
            end
            
           
        end
        
        
        %% BUILD
        function build(this, dLeft, dTop)
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            % build the main window
            this.hFigure = figure(...
                'name', 'Drift Monitor (DMI and Height Sensor)',...
                'Units', 'pixels',...
                'Position', [5+dLeft, 5+dTop,  this.dWidth, this.dHeight],...
                'numberTitle','off',...
                'Toolbar','none',...
                'Menubar','none', ...
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onCloseRequest ...
                );
            
            
            this.uitgMode.build(this.hFigure, 10, 100, this.dWidth - 20, this.dHeight - 100)
            uitMonitor      = this.uitgMode.getTabByName('Monitor');
            uitWaferLevel   = this.uitgMode.getTabByName('Wafer-level');
            uitCalibrate    = this.uitgMode.getTabByName('Calibrate');
            
            
            
            
            dTop = 20;
            dLeft = 10;
            
            % Connect button above tabs:
            this.uicConnectDriftMonitor.build(this.hFigure, dLeft, dTop);
            
            this.uitCalibrationText.build(this.hFigure, dLeft + 320, dTop + 5, 400, 30);
            
            
            this.hpDMI = uipanel(...
                'Parent', uitMonitor,...
                'Units', 'pixels',...
                'Title', 'DMI',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                600 ...
                700], uitMonitor) ...
                );
            
            this.hpHS = uipanel(...
                'Parent', uitMonitor,...
                'Units', 'pixels',...
                'Title', 'Height Sensor',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                625 ...
                dTop ...
                700 ...
                700], uitMonitor) ...
                );
            
            
            this.haDMI = axes('Parent', this.hpDMI, ...
                                 'Units', 'pixels', ...
                                 'Position', [50, 350, 430, 300], ...
                                 'XTick', [], 'YTick', []);
            this.uibClearDMI.build  (this.hpDMI, 500, 330, 80, 20); 
            
            this.uibResetDMI.build  (this.hpDMI, 500, 360, 80, 20);
            %this.uieUpdateInterval.build  (this.hpDMI, 500, 50, 80, 20);
                             
            this.haHS = axes('Parent',  this.hpHS, ...
             'Units', 'pixels', ...
             'Position', [70, 350, 450, 300], ...
             'XTick', [], 'YTick', []);
            this.uibClearHS.build  (this.hpHS, 550, 330, 80, 20);  
            drawnow;
            
            dLeft = 10;
            dSep = 40;
            dTop = 400;
            dWidthPadCol = 300;
            
            for k = 1:length(this.uiDMIChannels)
                this.uiDMIChannels{k}.build(this.hpDMI, dLeft, dTop);
                this.uicbDMIChannels{k}.build(this.hpDMI, 500, 70+k*35,100, 20);
                this.uicbDMIChannels{k}.set(true);
                dTop = dTop + mic.Utils.tern(mod(k,2) == 1, dSep, 2*dSep);
            end
            for k = 1:2
                this.uicbDMIDrift{k}.build(this.hpDMI, 500, 70+(k + length(this.uiDMIChannels))*35, 100, 20);
                this.uicbDMIDrift{k}.set(true);
            end
            
            dLeft = 10;
            dSep = 40;
            dTop = 400;
            dWidthPadCol = 400;
            this.uiHeightSensorChannels{9}.build(this.hpHS, dLeft, dTop); 
            this.uiHeightSensorChannels{10}.build(this.hpHS, dLeft + 350, dTop);
            dTop = dTop + dSep;
            this.uiHeightSensorChannels{7}.build(this.hpHS, dLeft, dTop); dTop = dTop + dSep;
            this.uiHeightSensorChannels{8}.build(this.hpHS, dLeft, dTop); dTop = dTop + dSep;
            dTop = dTop + dSep;
            
            for k = 1:3
                this.uiHeightSensorChannels{k}.build(this.hpHS, dLeft, dTop);
                this.uiHeightSensorChannels{k + 3}.build(this.hpHS, dLeft+ dWidthPadCol, dTop);
                dTop = dTop + dSep;
            end
            dTop = dTop + 15;
            
            for k=1:10
                this.uicbHeightSensorChannels{k}.build(this.hpHS, 550, 20+k*27, 100, 20);
            end
            
            
            % Wafer level tab
            for k = 1:3
                this.haLevelMonitors{k} = axes('Parent',  uitWaferLevel, ...
                                         'Units', 'pixels', ...
                                         'Position', [50 + 450*(k-1), 350, 370, 370], ...
                                         'XTick', [], 'YTick', []);
            end
            
            this.uiSLLevelCoordinateLoader.build(uitWaferLevel, 500, 500, 370, 250);
            this.uieZTarget.build(uitWaferLevel, 50, 500, 110, 20);
            this.uieRxTarget.build(uitWaferLevel, 50, 550, 110, 20);
            this.uieRyTarget.build(uitWaferLevel, 50, 600, 110, 20);
            this.uibLevel.build(uitWaferLevel, 250, 613, 150, 25);
            this.uibClearLevelPlots.build(uitWaferLevel, 250, 563, 150, 25);
            
            % Calibrate Tab:
            dLeft = 10;
            dSep = 40;
            dTop = 10;
            
            this.uicConnectHexapod.build(uitCalibrate, dLeft, dTop)
            dTop = dTop + dSep;
            this.uicConnectWafer.build(uitCalibrate, dLeft, dTop)
            
            this.ssCalibration.build(uitCalibrate, 10, 20, 850, 270);
            
            
            % Stages:
            dSep = 45;
            dTop = dTop + 40;
           
            dTop0 = dTop;
            for k = 1:length(this.cHexapodAxisLabels)
                this.uiDeviceArrayHexapod{k}.build(uitCalibrate, ...
                    dLeft, dTop);
                dTop = dTop + dSep;
            end
             dTop = dTop + dSep;
            dLeft = dLeft;
            
            for k = 1:length(this.cWaferLabels)
                this.uiDeviceArrayWafer{k}.build(uitCalibrate, ...
                    dLeft, dTop);
                if (k == 5)
                    dTop = dTop + dSep;
                end
                dTop = dTop + dSep;
            end
            
            hScanProgress = uipanel(uitCalibrate, ...
                     'units', 'pixels', ...
                     'Position', [1200 30 150 250] ...
                     );
                 
                 
            this.uiSLCalibration.build(uitCalibrate, 850, 30, 340, 250);
            
            
            this.uiTextStatus.build(hScanProgress, 10, 10, 100, 30);
            this.uiTextTimeElapsed.build(hScanProgress, 10, 60, 100, 30);
            this.uiTextTimeRemaining.build(hScanProgress, 10, 110, 100, 30);
            this.uiTextTimeComplete.build(hScanProgress, 10, 160, 100, 30);
            
            this.hpScanMonitor = uipanel(uitCalibrate, ...
                     'units', 'pixels', ...
                     'Position', [496 290 855 465] ...
                     );
            
            
        end
       
        function delete(this, src, evt)
           1
           
        end
        
        function onCloseRequest(this, src, evt)
            
            this.clock.stop();
            delete(this.clock);
            
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
        end
        
        
    end
    
    methods (Access = private)
        
        
        
        
    end
    
    
end

