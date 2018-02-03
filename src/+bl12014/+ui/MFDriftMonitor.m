% UI element that controls DMI and HS

classdef MFDriftMonitor < mic.Base
    
    
    properties (Constant)
        dWidth = 1400
        dHeight = 900
        
        cName = 'Drift monitor'
        
        
        
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
        
        % DMI channels:
        u8DMI_CHANNEL_RETX = 1;
        u8DMI_CHANNEL_RETY = 2;
        u8DMI_CHANNEL_WAFX = 3;
        u8DMI_CHANNEL_WAFY = 4;
        
        ceHSChannelNames = {'HS-Channel-1', 'HS-Channel-2', 'HS-Channel-3', 'HS-Channel-4', ...
            'HS-Channel-5', 'HS-Channel-6', 'HS-Rx', 'HS-Ry', 'HS-Z'}
        ceDMIChannelNames = {'DMI-Ret-X', 'DMI-Ret-Y', 'DMI-Wafer-X', 'DMI-Wafer-Y'}
        
        ceScanAxisLabels = {'Hexapod-Rx', 'Hexapod-Ry', 'Hexapod-Z', 'Wafer-Rx', 'Wafer-Ry', 'Wafer-Z'}
        ceScanOutputLabels = {'Height sensor channels'};
        
    end
    
    properties
        cAppPath        = fileparts(mfilename('fullpath'))

        
        
    end
    
    properties (SetAccess = private)
        % Channels to display, set these variables to a subset of this list
        % to show less channels
        dHeightSensorDisplayChannels = 1:9
        dDMIDisplayChannels = 1:4
        
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
        
        
        % UI:Montor:HS
        hpHS
        uiHeightSensorChannels
        
        
        
        
        % UI:Calibrate
        uicConnectHexapod
        uicConnectWafer
       
        
        uiDeviceArrayHexapod
        uiDeviceArrayWafer
        
        
        % Scanner:
        scanHandler
        ssCalibration
        lIsScanning = false
        
        % Scan progress text elements
        uiTextStatus
        uiTextTimeElapsed
        uiTextTimeRemaining
        uiTextTimeComplete
        
        
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        apiWaferStage
        apiHexapod
        apiDriftMonitor = []
        
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
            
            if isempty(this.apiDriftMonitor)
                msgbox('MFDriftMonitor must be initialized with a Hardware device');
                error('Reinit MFDriftMonitor with a hardware device');
            end
            
            this.init();
            
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
                'cLabel', 'MFDrift Monitor' ...
                );
            
            % Decide what should happen when comm is
            % connected/disconnected:
            this.uicConnectDriftMonitor.setDevice(...
                bl12014.device.GetSetLogicalConnect(...
                'fhGet',        @()this.apiDriftMonitor.isConnected() && this.apiDriftMonitor.isReady(), ...
                'fhSetTrue',    @()this.apiDriftMonitor.connect(), ...
                'fhSetFalse',   @()this.apiDriftMonitor.disconnect() ...
                )...
                );
            % Don't know where this code is but i think we need to do this:
            this.uicConnectDriftMonitor.turnOn();
            
            
            this.uicConnectHexapod = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'Hexapod', ...
                'cLabel', 'Hexapod' ...
                );
            
            % Decide what should happen when comm is
            % connected/disconnected:
            this.uicConnectHexapod.setDevice(...
                bl12014.device.GetSetLogicalConnect(...
                'fhGet',        @()true, ...
                'fhSetTrue',    @()[], ...
                'fhSetFalse',   @()[] ...
                )...
                );
            % Don't know where this code is but i think we need to do this:
            this.uicConnectHexapod.turnOn();
            
            this.uicConnectWafer = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'Wafer', ...
                'cLabel', 'Wafer' ...
                );
            
            % Decide what should happen when comm is
            % connected/disconnected:
            this.uicConnectWafer.setDevice(...
                bl12014.device.GetSetLogicalConnect(...
                'fhGet',        @()true, ...
                'fhSetTrue',    @()[], ...
                'fhSetFalse',   @()[] ...
                )...
                );
            % Don't know where this code is but i think we need to do this:
            this.uicConnectWafer.turnOn();
        
        
            
            
            
            % MAIN TABGROUP:
            this.uitgMode = ...
                mic.ui.common.Tabgroup('ceTabNames', ...
                {'Monitor', 'Calibrate'});
            
            
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
                    'lShowZero', false, ...
                    'lShowRel',  false, ...
                    'lShowDevice', false, ...
                    'fhGet', @()this.apiDriftMonitor.getHeightSensorValue(u8Channel),...
                    'fhIsReady', @()this.apiDriftMonitor.isReady()...
                    );
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
                    'fhIsReady', @()this.apiDriftMonitor.isReady()...
                    );
            end
            
            % UI:Calibrate:
            
            this.ssCalibration = mic.ui.common.ScanSetup( ...
                'cLabel', 'Saved pos', ...
                'ceOutputOptions', this.ceScanOutputLabels, ...
                'ceScanAxisLabels', this.ceScanAxisLabels, ...
                'dScanAxes', 3, ...
                'cName', '3D-Scan', ...
                'u8selectedDefaults', uint8([1, 2, 3]),...
                'cConfigPath', fullfile(this.cAppPath, '+config'), ...
                'fhOnScanChangeParams', @(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames)...
                this.updateScanMonitor(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames, 0), ...
                'fhOnStopScan', @()this.stopScan, ...
                'fhOnScan', ...
                @(ceScanStates, u8ScanAxisIdx, lUseDeltas, u8ScanOutputDeviceIdx, cAxisNames)...
                this.onScan(this.ss3D, ceScanStates, u8ScanAxisIdx, lUseDeltas, u8ScanOutputDeviceIdx, cAxisNames) ...
                );
            
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
                        dInitialState.values(k) = this.uiDeviceArrayHexapod{dAxis}.getDestCal(dUnit);
                        
                    case {4, 5, 6} % wafer
                        if isempty(this.apiWaferStage)
                            %                             msgbox('Reticle is not connected\n')
                            dInitialState.values(k) = 0;
                            continue
                            %                             return
                        end
                        
                        dUnit =  this.uiDeviceArrayWafer{dAxis}.getUnit().name;
                        dInitialState.values(k) = this.uiDeviceArrayWafer{dAxis - 3}.getDestCal(dUnit);
                        
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
            this.scanHandler = mic.Scan(this.clock, ...
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
            this.setupScanOutput(stateList, u8ScanAxisIdx)
            this.lIsScanning = true;
            this.ssCurrentScanSetup = ssScanSetup;
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
                for k = 1:6
                    dPosHexRaw(k) = this.uiDeviceArrayHexapod{k}.getValRaw();  %#ok<AGROW>
                end
            end
            
            
            for k = 1:length(dAxes)
                dVal = dVals(k);
                dAxis = dAxes(k);
                switch dAxis
                    case {1, 2, 3} % Hexapod: generate deferred move
                        this.uiDeviceArrayHexapod{dAxis}.setDestCal(dVal);
                        dPosHexRaw(dAxis) = this.uiDeviceArrayHexapod{dAxis}.getDestRaw();
                   
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
            
            % Reset scan setup pointer:
            this.ssCurrentScanSetup = {};
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
            
            
        
            
            
        end
        
        
        %% BUILD
        function build(this, dLeft, dTop)
            
            % build the main window
            this.hFigure = figure(...
                'name', 'Drift Monitor (DMI and Height Sensor)',...
                'Units', 'pixels',...
                'Position', [5, 5,  this.dWidth, this.dHeight],...
                'handlevisibility','off',... %out of reach gcf
                'numberTitle','off',...
                'Toolbar','none',...
                'Menubar','none');
            
            
            this.uitgMode.build(this.hFigure, 10, 10, this.dWidth - 20, this.dHeight - 100)
            uitMonitor      = this.uitgMode.getTabByName('Monitor');
            uitCalibrate    = this.uitgMode.getTabByName('Calibrate');
            
            
            dTop = 20;
            dLeft = 10;
            
            % Connect button above tabs:
            this.uicConnectDriftMonitor.build(this.hFigure, dLeft, dTop)
            
            
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
            
            drawnow;
            
            dLeft = 10;
            dSep = 40;
            dTop = 400;
            dWidthPadCol = 300;
            
            for k = 1:length(this.uiDMIChannels)
                this.uiDMIChannels{k}.build(this.hpDMI, dLeft, dTop);
                dTop = dTop + mic.Utils.tern(mod(k,2) == 1, dSep, 2*dSep);
                
            end
            
            dLeft = 10;
            dSep = 40;
            dTop = 400;
            dWidthPadCol = 400;
            this.uiHeightSensorChannels{9}.build(this.hpHS, dLeft, dTop); dTop = dTop + dSep;
            this.uiHeightSensorChannels{7}.build(this.hpHS, dLeft, dTop); dTop = dTop + dSep;
            this.uiHeightSensorChannels{8}.build(this.hpHS, dLeft, dTop); dTop = dTop + dSep;
            dTop = dTop + dSep;
            
            for k = 1:3
                this.uiHeightSensorChannels{k}.build(this.hpHS, dLeft, dTop);
                this.uiHeightSensorChannels{k + 3}.build(this.hpHS, dLeft+ dWidthPadCol, dTop);
                dTop = dTop + dSep;
            end
            dTop = dTop + 15;
            
            
            % Calibrate Tab:
            dLeft = 10;
            dSep = 40;
            dTop = 10;
            
            this.uicConnectHexapod.build(uitCalibrate, dLeft, dTop)
            dTop = dTop + dSep;
            this.uicConnectWafer.build(uitCalibrate, dLeft, dTop)
            
            this.ssCalibration.build(uitCalibrate, 10, 20, 850, 270);
            
            
            
            
        end
        
        function delete(this)
            
            this.msg('delete');
            
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end
        
        
    end
    
    methods (Access = private)
        
        
        
        
    end
    
    
end

