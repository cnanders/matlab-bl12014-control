classdef LSI_Control < mic.Base
    
    
    properties
        hardware
        
        cAppPath        = fileparts(mfilename('fullpath'))
        cDataPath
        cConfigPath
        clock = {}
        vendorDevice
        

        
        uiCommDeltaTauPowerPmac

        uicommWaferDoseMonitor
        uicommMFDriftMonitor
        
        
        % Instruments handle
        hInstruments
        
        % Stages
        uiDeviceArrayReticle
        uiDeviceArrayWafer
        
       
    
        oReticleBridges
        

        
        % APIs:
        apiReticle          = []
        apiMFDriftMonitor   = []
        apiWaferDoseMonitor = []
        
        % DMI and dose monitor:
        ceDMIChannelNames = {'DMI-Ret-X', 'DMI-Ret-Y'}
        dDMIDisplayChannels = 1:2
        uiDMIChannels
        uiDoseMonitor

        % Configuration
        uicReticleConfigs
        uicWaferConfigs
        
        uiDeviceMode
        
        uiSLReticle
        uiSLReticleFine
        
        hpStageControls
        hpPositionRecall
        hpMainControls
        
              
        % axes:
        uitgAxes
        hsaAxes
        haScanMonitors = {}
        
        haScanOutput
        
        
        
        % Scans:
        uitgScan
        ceTabList = {'1D-scan', '2D-scan', '3D-scan', '1D Coupled', '2D Coupled'}
        
        
        % Scan setups
        scanHandler
        ss1D
        ss2D
        ss3D
        ssCurrentScanSetup %pointer to current scan setup
        lSaveImagesInScan = false
        dImageSeriesNumber = 0 %Used to keep track of the number of series 
        
        % Scan progress text elements
        uiTextStatus
        uiTextTimeElapsed
        uiTextTimeRemaining
        uiTextTimeComplete
        
        % Keep track of initial state of last scan
        stLastScanState
        
        lAutoSaveImage
        lIsScanAcquiring = false % whether we're currently in a "scan acquire"
        lIsScanning = false
        
        
        % Scan ouput:
        stLastScan
        
        dNumScanOutputAxes
        ceScanCoordinates
        dLinearScanOutput
        dScanOutput
        
        
        ceBinningOptions = {1, 2}
        
        hFigure
        
        
    end
    
    properties (Constant)
        dWidth  = 1750;
        dHeight =  1100;
        
        % Camera modes
        U8CAMERA_MODE_ACQUIRE = 0
        U8CAMERA_MODE_FOCUS = 1
        
        dMultiAxisSeparation = 30;
        
        cHexapodAxisLabels = {'X', 'Y', 'Z', 'Rx', 'Ry', 'Rz'};
        cGoniLabels = {'Goni-Rx', 'Goni-Ry'};
        cReticleLabels = {'Ret-C-X', 'Ret-C-Y', 'Ret-C-Z', 'Ret-C-Rx', 'Ret-C-Ry',...
                         'Ret-F-X', 'Ret-F-Y'};
                     
        cWaferLabels = {'Waf-C-X', 'Waf-C-Y', 'Waf-C-Z'};
        
        ceScanAxisLabels = {'Hexapod X', ...
                        'Hexapod Y', ...
                        'Hexapod Z', ...
                        'Hexapod Rx', ...
                        'Hexapod Rx', ...
                        'Hexapod Rz', ...
                        'Goni X', ...
                        'Goni Y', ...
                        'Ret Crs X', ...
                        'Ret Crs Y', ...
                        'Ret Crs Z', ...
                        'Ret Rx', ...
                        'Ret Ry', ...
                        'Ret Fine X', ...
                        'Ret Fine Y', ...
                        'Waf Crs X', ...
                        'Waf Crs Y', ...
                        'Waf Crs Z', ...
                        'Do Nothing'};
        ceScanOutputLabels = {'Image capture', 'Image intensity', ...
            'Background diff', 'Line Pitch', 'Pause 2s', 'Wafer Diode', 'HS Simple Z', ...
            'HS Cal Z', 'HS Cal Rx', 'HS Cal Ry', 'Image caputure lock conjugate'};
    end
    
    properties (Access = private)
        cDirSave = fileparts(mfilename('fullpath'));
    end
    
    events
        eImageAcquired
        eImageSaved
    end
    
    methods
        
        function this = LSI_Control(varargin)
            
            for k = 1:2:length(varargin)
                this.(varargin{k}) = varargin{k+1};
            end
            
            if isempty(this.clock)
                this.initClock();
            end
            
            
            this.initConfig();
            this.initUi();
            this.initComm();
%             this.initHexapodDevice();
%             this.initGoniDevice();
%             this.build();
            
            %this.loadStateFromDisk();
            
            this.initDataPath();
           
            
            
        end
        
        function initDataPath(this)
             % Make data 
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
            this.cDataPath = fullfile(cDirThis, '..', '..', '..', 'Data');
            
            sFils = dir(fullfile(cDirThis, '..', '..', '..'));
            lDataFolderExist = false;
            for k = 1:length(sFils)
                if strcmp(sFils(k).name, 'Data')
                    lDataFolderExist = true;
                end
            end
            if ~lDataFolderExist
                mkdir(this.cDataPath);
            end
                
            
        end
        
        function initComm(this)
             % Instantiate drift monitor immediately, although don't connect
            % yet
            this.apiMFDriftMonitor = this.hardware.getMfDriftMonitorMiddleware();
            
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommDeltaTauPowerPmac = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'fhGet', @() this.hardware.getIsConnectedDeltaTauPowerPmac(), ...
                'fhSet', @(lVal) mic.Utils.ternEval(...
                    lVal, ...
                    @() this.hardware.connectDeltaTauPowerPmac(), ...
                    @() this.hardware.disconnectDeltaTauPowerPmac() ...
                ), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', 'LSI-delta-tau-reticle', ...
                'cLabel', 'Delta Tau Reticle' ...
                );
           
            
            
            this.uicommWaferDoseMonitor = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'dWidthName', 85, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'comm-wafer-dose-monitor-lsi', ...
                'fhGet', @() this.hardware.getIsConnectedKeithley6482Wafer(), ...
                'fhSet', @(lVal) this.hardware.setIsConnectedKeithley6482Wafer(lVal), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', 'wafer-dose-monitor-lsi', ...
                'cLabel', 'Keithley 6482 (Wafer)' ...
            );

            this.uicommMFDriftMonitor = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'dWidthName', 85, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'mf-drift-monitor-lsi', ...
                'cLabel', 'MFDrift Monitor',...
                'lUseFunctionCallbacks', true, ...
                'fhGet', @() (this.apiMFDriftMonitor.isConnected()),...
                'fhSet', @(lVal) mic.Utils.ternEval(lVal, ...
                                    @this.connectDriftMonitor, ...
                                    @this.disconnectDriftMontior...
                                ),...
                'fhIsInitialized', @()true,...
                'fhIsVirtual', @false ...% Never virtualize the connection to real hardware
                );
        end
        
        
        
        function letMeIn(this)
           1;
        end
        
        function initConfig(this)
            this.cConfigPath = fullfile(this.cAppPath, '+config');
           
            for k = 1:7
                this.uicReticleConfigs{k} = mic.config.GetSetNumber(...
                    'cPath', fullfile(this.cConfigPath, sprintf('reticle%d.json', k))...
                    );
            end
            for k = 1:3
                this.uicWaferConfigs{k} = mic.config.GetSetNumber(...
                    'cPath', fullfile(this.cConfigPath, sprintf('wafer%d.json', k))...
                    );
            end
            
            
        end
        
        function initUi(this)
            
           
                       
            
           fhReticleGetters = { @() this.hardware.getDeltaTauPowerPmac().getXReticleCoarse(), ...
               @() this.hardware.getDeltaTauPowerPmac().getYReticleCoarse(), ...
               @() this.hardware.getDeltaTauPowerPmac().getZReticleCoarse(), ...
               @() this.hardware.getDeltaTauPowerPmac().getTiltXReticleCoarse(), ...
               @() this.hardware.getDeltaTauPowerPmac().getTiltYReticleCoarse(), ...
                @() this.hardware.getDeltaTauPowerPmac().getXReticleFine(), ...
               @() this.hardware.getDeltaTauPowerPmac().getYReticleFine(), ...
                    };
            fhReticleSetters = { @(dVal) this.hardware.getDeltaTauPowerPmac().setXReticleCoarse(dVal), ...
               @(dVal) this.hardware.getDeltaTauPowerPmac().setYReticleCoarse(dVal), ...
               @(dVal) this.hardware.getDeltaTauPowerPmac().setZReticleCoarse(dVal), ...
               @(dVal) this.hardware.getDeltaTauPowerPmac().setTiltXReticleCoarse(dVal), ...
               @(dVal) this.hardware.getDeltaTauPowerPmac().setTiltYReticleCoarse(dVal), ...
               @(dVal) this.hardware.getDeltaTauPowerPmac().setXReticleFine(dVal), ...
               @(dVal) this.hardware.getDeltaTauPowerPmac().setYReticleFine(dVal), ...
                    }; 
                
           for k = 1:length(this.cReticleLabels)
               if (k <= 5)
               
               this.uiDeviceArrayReticle{k} = mic.ui.device.GetSetNumber( ...
                   'cName', this.cReticleLabels{k}, ...
                   'clock', this.clock, ...
                   'cLabel', this.cReticleLabels{k}, ...
                   'lShowLabels', false, ...
                   'lShowStores', false, ...
                   'lValidateByConfigRange', true, ...
                   'fhGet', fhReticleGetters{k}, ...
                   'fhSet', fhReticleSetters{k}, ...
                   'fhIsReady', @() ~this.hardware.getDeltaTauPowerPmac().getIsStartedReticleCoarseXYZTipTilt(), ...
                   'fhStop', @() this.hardware.getDeltaTauPowerPmac().stopAll(), ...
                   'fhIsVirtual', @() false, ...
                   'lUseFunctionCallbacks', true, ...
                   'config', this.uicReticleConfigs{k} ...
                   );
               else
                   this.uiDeviceArrayReticle{k} = mic.ui.device.GetSetNumber( ...
                   'cName', this.cReticleLabels{k}, ...
                   'clock', this.clock, ...
                   'cLabel', this.cReticleLabels{k}, ...
                   'lShowLabels', false, ...
                   'lShowStores', false, ...
                   'lValidateByConfigRange', true, ...
                   'fhGet', fhReticleGetters{k}, ...
                   'fhSet', fhReticleSetters{k}, ...
                   'fhIsReady', @() ~this.hardware.getDeltaTauPowerPmac().getIsStartedReticleFineXY(), ...
                   'fhStop', @() this.hardware.getDeltaTauPowerPmac().stopAll(), ...
                   'fhIsVirtual', @() false, ...
                   'lUseFunctionCallbacks', true, ...
                   'config', this.uicReticleConfigs{k} ...
                   );
               end
                   
           end
           
             fhWaferGetters = { @() this.hardware.getDeltaTauPowerPmac().getXWaferCoarse(), ...
               @() this.hardware.getDeltaTauPowerPmac().getYWaferCoarse(), ...
               @() this.hardware.getDeltaTauPowerPmac().getZWaferCoarse(), ...
               @() this.hardware.getDeltaTauPowerPmac().getTiltXWaferCoarse(), ...
               @() this.hardware.getDeltaTauPowerPmac().getTiltYWaferCoarse(), ...
                    };
            fhWaferSetters = { @(dVal) this.hardware.getDeltaTauPowerPmac().setXWaferCoarse(dVal), ...
               @(dVal) this.hardware.getDeltaTauPowerPmac().setYWaferCoarse(dVal), ...
               @(dVal) this.hardware.getDeltaTauPowerPmac().setZWaferCoarse(dVal), ...
               @(dVal) this.hardware.getDeltaTauPowerPmac().setTiltXWaferCoarse(dVal), ...
               @(dVal) this.hardware.getDeltaTauPowerPmac().setTiltYWaferCoarse(dVal), ...
                    }; 
           
           for k = 1:length(this.cWaferLabels)              

               this.uiDeviceArrayWafer{k} = mic.ui.device.GetSetNumber( ...
                   'cName', this.cWaferLabels{k}, ...
                   'clock', this.clock, ...
                   'cLabel', this.cWaferLabels{k}, ...
                   'lShowLabels', false, ...
                   'lShowStores', false, ...
                   'lValidateByConfigRange', true, ...
                   'fhGet', fhWaferGetters{k}, ...
                   'fhSet', fhWaferSetters{k}, ...
                   'fhIsReady', @() ~this.hardware.getDeltaTauPowerPmac().getIsStartedWaferCoarseXYZTipTilt(), ...
                   'fhStop', @() this.hardware.getDeltaTauPowerPmac().stopAll(), ...
                   'fhIsVirtual', @() false, ...
                   'lUseFunctionCallbacks', true, ...
                   'config', this.uicWaferConfigs{k} ...
                   );
           end
            
           % Init UI for getNumbers on DMI and dose monitor
           dWidthName = 55;
           dWidthUnit = 75;
           dWidthVal = 55;
           dWidthPadUnit = 15;
           
           % DMI
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
                    'dWidthName', dWidthName, ...
                    'dWidthUnit', dWidthUnit, ...
                    'dWidthVal', dWidthVal, ...
                    'dWidthPadUnit', dWidthPadUnit, ...
                    'cName', sprintf('lsi-%s', this.ceDMIChannelNames{u8Channel}), ...
                    'config', uiConfig, ...
                    'cLabel', this.ceDMIChannelNames{u8Channel}, ...
                    'lUseFunctionCallbacks', true, ...
                    'lShowZero', false, ...
                    'lShowRel',  false, ...
                    'lShowDevice', false, ...
                    'fhGet', @()this.apiMFDriftMonitor.getDMIValue(u8Channel),...
                    'fhIsReady', @()this.apiMFDriftMonitor.isReady(),...
                    'fhIsVirtual', @()isempty(this.apiMFDriftMonitor) ...
                    );
                
           end
           
           cPathConfig = fullfile(...
               bl12014.Utils.pathUiConfig(), ...
               'get-number', ...
               'config-lsi-hs-simplez.json' ...
               );
           
           uiConfig = mic.config.GetSetNumber(...
               'cPath',  cPathConfig ...
               );
           
           % Dose monitor:
           cPathConfig = fullfile(...
               bl12014.Utils.pathUiConfig(), ...
               'get-number', 'config-wafer-current.json' ...
               );
           
           uiConfig = mic.config.GetSetNumber(...
               'cPath',  cPathConfig ...
               );
           
           this.uiDoseMonitor = mic.ui.device.GetNumber(...
               'clock', this.clock, ...
               'dWidthName', dWidthName, ...
               'dWidthUnit', dWidthUnit, ...
               'dWidthVal', dWidthVal, ...
               'dWidthPadUnit', dWidthPadUnit, ...
               'fhGet', @() this.hardware.getKeithley6482Wafer().read(2), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
               'cName', ['lsi-control-wafer-diode'], ...
               'config', uiConfig, ...
               'cLabel', 'Wafer-Diode', ...
               'lShowZero', false, ...
               'lShowRel',  false, ...
               'lShowDevice', false ); 

            this.uiDoseMonitor.setUnit('nA');

         
            this.uiSLReticle = mic.ui.common.PositionRecaller(...
                'cConfigPath', fullfile(this.cAppPath, '+config'), ...
                'cName', 'Reticle Coarse', ...
                'hGetCallback', @this.getReticleCoarseRaw, ...
                'hSetCallback', @this.setReticleCoarseRaw);
        
            this.uiSLReticleFine = mic.ui.common.PositionRecaller(...
                'cConfigPath', fullfile(this.cAppPath, '+config'), ...
                'cName', 'Reticle Fine', ...
                'hGetCallback', @this.getReticleFineRaw, ...
                'hSetCallback', @this.setReticleFineRaw);
            
            
           
            
            % Scans:
            this.ss1D = mic.ui.common.ScanSetup( ...
                            'cLabel', 'Saved pos', ...
                            'ceOutputOptions', this.ceScanOutputLabels, ...
                            'ceScanAxisLabels', this.ceScanAxisLabels, ...
                            'dScanAxes', 1, ...
                            'cName', '1D-Scan', ...
                            'u8selectedDefaults', uint8(1),...
                            'cConfigPath', fullfile(this.cAppPath, '+config'), ...
                            'fhOnScanChangeParams', @(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames)...
                                                this.updateScanMonitor(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames, 0), ...
                            'fhOnStopScan', @()this.stopScan, ...
                            'fhOnScan', ...
                                    @(ceScanStates, u8ScanAxisIdx, lUseDeltas, u8ScanOutputDeviceIdx, cAxisNames)...
                                            this.onScan(this.ss1D, ceScanStates, u8ScanAxisIdx, lUseDeltas, u8ScanOutputDeviceIdx, cAxisNames) ...
                        );
                    
            this.ss2D = mic.ui.common.ScanSetup( ...
                            'cLabel', 'Saved pos', ...
                            'ceOutputOptions', this.ceScanOutputLabels, ...
                            'ceScanAxisLabels', this.ceScanAxisLabels, ...
                            'dScanAxes', 2, ...
                            'cName', '2D-Scan', ...
                            'u8selectedDefaults', uint8([1, 2]),...
                            'cConfigPath', fullfile(this.cAppPath, '+config'), ...
                            'fhOnScanChangeParams', @(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames)...
                                                this.updateScanMonitor(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames, 0), ...
                            'fhOnStopScan', @()this.stopScan, ...
                            'fhOnScan', ...
                                    @(ceScanStates, u8ScanAxisIdx, lUseDeltas, u8ScanOutputDeviceIdx, cAxisNames)...
                                            this.onScan(this.ss2D, ceScanStates, u8ScanAxisIdx, lUseDeltas, u8ScanOutputDeviceIdx, cAxisNames) ...
                        );
                    
            this.ss3D = mic.ui.common.ScanSetup( ...
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
                    
         
                    
            % Scan setup callback triggers.  Used when tabgroup changes tab
            % focus
            ceScanCallbackTriggers = ...
                {@()this.ss1D.triggerCallback(), ...
                 @()this.ss2D.triggerCallback(), ...
                 @()this.ss3D.triggerCallback(), ...
                 @()this.ssExp1.triggerCallback(), ...
                 @()this.ssExp2.triggerCallback()};
             
            % Scan tab group:
            this.uitgScan = mic.ui.common.Tabgroup('ceTabNames', this.ceTabList, ...
                                                    'fhDirectCallback', ceScanCallbackTriggers);
            % Axes tab group:
            this.uitgAxes = mic.ui.common.Tabgroup('ceTabNames', ...
                {'Camera', 'Scan monitor', 'Scan output', 'Fiducialized moves'});
           
            
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
        

%% INITIALIZE HARDWARE DEVICES

        % Set up hardware connect/disconnects:
        function connectDriftMonitor(this)
             if ~this.apiMFDriftMonitor.isConnected()
                this.apiMFDriftMonitor.connect();
             end
            
        end
        
        function connectDoseMonitor(this)
            this.apiWaferDoseMonitor = this.hardware.getKeithleyWafer();
        end
        
        
        % This uses the old way, not the hardware way
        function connectKeithley6482(this, device)
            uiDevice = bl12014.device.GetNumberFromKeithley6482(device, 2);
            this.uiDoseMonitor.setDevice(uiDevice);
            this.uiDoseMonitor.turnOn();
        end
        
        function disconnectKeithley6482(this)
            this.uiDoseMonitor.turnOff();
            this.uiDoseMonitor.setDevice([]);
        end
        
        function disconnectDriftMontior(this)
             if this.apiMFDriftMonitor.isConnected()
                this.apiMFDriftMonitor.disconnect();
             end

            
        end
        
        function disconnectDoseMonitor(this)
            this.hardware.deleteKeithleyWafer();
            this.apiWaferDoseMonitor = [];
        end
        
        function initClock(this)
            this.clock = mic.Clock('app');
        end
        
        
        
        
%% IMAGE ACQUISITION
        

        
        function stLog = getHardwareLogs(this)
            % Make log structure:
            stLog = struct();
            
            % Add timestamp
            stLog.timeStamp = datestr(now, 31);
            
            stLog.fileName = [];
            
            % Add Hexapod coordinates:
            if isempty(this.apiHexapod)
                stLog.hexapodX = 'off';
                stLog.hexapodY = 'off';
                stLog.hexapodZ = 'off';
                stLog.hexapodRx = 'off';
                stLog.hexapodRy = 'off';
                stLog.hexapodRz = 'off';
            else 
                dHexapodPositions = this.getHexapodRaw();
                stLog.hexapodX = sprintf('%0.6f', dHexapodPositions(1));
                stLog.hexapodY = sprintf('%0.6f', dHexapodPositions(2));
                stLog.hexapodZ = sprintf('%0.6f', dHexapodPositions(3));
                stLog.hexapodRx = sprintf('%0.6f', dHexapodPositions(4));
                stLog.hexapodRy = sprintf('%0.6f', dHexapodPositions(5));
                stLog.hexapodRz = sprintf('%0.6f', dHexapodPositions(6));
            end
            
            % Add Goni coordinates:
            if isempty(this.apiGoni)
                stLog.goniRx = 'off';
                stLog.goniRy = 'off';
            else 
                dGoniPositions = this.getGoniRaw(this);
                stLog.goniRx = sprintf('%0.6f', dGoniPositions(1));
                stLog.goniRy = sprintf('%0.6f', dGoniPositions(2));
            end
            
            % Add Reticle coordinates:
            stLog.reticleCX = this.uiDeviceArrayReticle{1}.getDestRaw();
            stLog.reticleCY = this.uiDeviceArrayReticle{2}.getDestRaw();
            stLog.reticleCZ = this.uiDeviceArrayReticle{3}.getDestRaw();
            stLog.reticleRx = this.uiDeviceArrayReticle{4}.getDestRaw();
            stLog.reticleRy = this.uiDeviceArrayReticle{5}.getDestRaw();
            stLog.reticleFX = this.uiDeviceArrayReticle{6}.getDestRaw();
            stLog.reticleFY = this.uiDeviceArrayReticle{7}.getDestRaw();
            
            % Add temperature and exposure times:
            if isempty(this.apiCamera)
                stLog.cameraTemp = 'off';
                stLog.cameraExposureTime = 'off'; 
            else
                stLog.cameraTemp = sprintf('%0.1f', this.apiCamera.getTemperature());
                stLog.cameraExposureTime = sprintf('%0.4f', this.apiCamera.getExposureTime()); 
            end
            
            % Add DMI reticle x and y values:
            if (~this.apiMFDriftMonitor.isConnected())
                stLog.DMIRetX = 'off';
                stLog.DMIRetY = 'off';
                stLog.HSZ = 'off';
            else
                 this.apiMFDriftMonitor.forceUpdate();
                 stLog.DMIRetX = sprintf('%0.10f', this.apiMFDriftMonitor.getDMIValue(1)); 
                 stLog.DMIRetY = sprintf('%0.10f', this.apiMFDriftMonitor.getDMIValue(2)); 
                 stLog.HSZ = sprintf('%0.10f', this.apiMFDriftMonitor.getSimpleZ(200)); 
            end
           
            
        end
        
        
 %% POSITION RECALL Stage direct access get/set

        
        % -------------------------*****************----------------------
        % Need to implement these methods:
        function positions = getReticleCoarseRaw(this)
            for k = 1:5
                positions(k) = this.uiDeviceArrayReticle{k}.getDestRaw(); %#ok<AGROW>
            end
        end
        
        function setReticleCoarseRaw(this, positions)
            for k = 1:5
                this.uiDeviceArrayReticle{k}.setDestRaw(positions(k));
                this.uiDeviceArrayReticle{k}.moveToDest();
            end
        end
        
        
        
        function positions = getReticleFineRaw(this)
            for k = 6:7
                positions(k) = this.uiDeviceArrayReticle{k}.getDestRaw(); %#ok<AGROW>
            end
        end
        
        function setReticleFineRaw(this, positions)
            for k = 6:7
                this.uiDeviceArrayReticle{k}.setDestRaw(positions(k));
                this.uiDeviceArrayReticle{k}.moveToDest();
            end
        end
        
        function positions = getWaferCoarseRaw(this)
            for k = 1:3
                positions(k) = this.uiDeviceArrayWafer{k}.getDestRaw(); %#ok<AGROW>
            end
        end
        
        function setWaferCoarseRaw(this, positions)
            for k = 1:3
                this.uiDeviceArrayWafer{k}.setDestRaw(positions(k));
                this.uiDeviceArrayWafer{k}.moveToDest();
            end
        end
        % -------------------------*****************----------------------
        
        function syncReticleDestinations(this)
         % Sync edit boxes
            for k = 1:length(this.cReticleLabels)
                this.uiDeviceArrayReticle{k}.syncDestination();
            end
        end
        
        


%% SCAN METHODS

% State array needs to be structure with property values
        function dInitialState = getInitialState(this, u8ScanAxisIdx)
             % grab initial state of values:
            dInitialState = struct;
            dInitialState.values = [];
            dInitialState.axes = u8ScanAxisIdx;
            
            % validate start conditions and get initial state
            for k = 1:length(u8ScanAxisIdx)
                dAxis = double(u8ScanAxisIdx(k));
                switch dAxis
                    case {1, 2, 3, 4, 5, 6} % Hexapod
                        if isempty(this.apiHexapod)
                            fprintf('Hexapod is not connected\n')
                            dInitialState.values(k) = 0;
                            continue
%                             return
                        end
                        
                        dUnit =  this.uiDeviceArrayHexapod{dAxis}.getUnit().name;
                        dInitialState.values(k) = this.uiDeviceArrayHexapod{dAxis}.getValCal(dUnit);
                        
                    case {7, 8} % Goni
                        if isempty(this.apiGoni)
                            fprintf('Goni is not connected\n')
                            dInitialState.values(k) = 0;
                            continue
%                             return
                        end
                        dUnit =  this.uiDeviceArrayGoni{dAxis}.getUnit().name;
                        dInitialState.values(k) = this.uiDeviceArrayGoni{dAxis - 6}.getValCal(dUnit);
                        
                    case {9, 10, 11, 12, 13, 14, 15} % Reticle
%                         if isempty(this.apiReticle)
%                             msgbox('Reticle is not connected\n')
%                             dInitialState.values(k) = 0;
%                             continue
%                             return
%                         end
                        
                        dUnit =  this.uiDeviceArrayReticle{dAxis - 8}.getUnit().name;
                        dInitialState.values(k) = this.uiDeviceArrayReticle{dAxis - 8}.getValCal(dUnit);
                        
                    case {16, 17, 18} % Wafer
                        dUnit =  this.uiDeviceArrayWafer{dAxis - 15}.getUnit().name;
                        dInitialState.values(k) = this.uiDeviceArrayWafer{dAxis - 15}.getValCal(dUnit);
                    case 19 % "do nothing"
                        dInitialState.values(k) = 1;
                        
                end
            end
            
        end
        
        function onScan(this, ssScanSetup, stateList, u8ScanAxisIdx, lUseDeltas, u8OutputIdx, cAxisNames)
            
            % If already scanning, then stop:
            if(this.lIsScanning)
                return
            end
                
            dInitialState = this.getInitialState(u8ScanAxisIdx);
            % Save this state:
            this.stLastScanState = dInitialState;

            
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
                case {1, 2, 3, 4, 11} % Camera output
                   if isempty(this.apiCamera)
                       msgbox('No Camera available for image acquisition')
                       return
                   end
            end
            
            % Prepare conjugate locking
            if u8OutputIdx == 11
                this.lIsConjugateLockEnabled = true;
                
                
                dUnit = this.uiDeviceArrayReticle{3}.getUnit().name;
                dRetZVal = this.uiDeviceArrayReticle{3}.getValCal(dUnit);
                dHSVal = this.apiMFDriftMonitor.getSimpleZ(200);
                fprintf('(LSI-Control) Initializing conjugate locking\n');
                fprintf('\tRet Z initial val: %0.9f\n', dRetZVal);
                fprintf('\tHS Z initial val: %0.3f\n', dHSVal);
                this.dInitialRetZValue = dRetZVal;
                this.dInitialHSSZValue = dHSVal;
            end
            
            % Set series number:
            
            switch u8OutputIdx
                case {1, 4, 11} % Any time image series should be saved
                   if isempty(this.apiCamera)
                       msgbox('No Camera available for image acquisition')
                       return
                   end
                   this.dImageSeriesNumber = this.dImageSeriesNumber + 1;
                   this.lSaveImagesInScan = true;
                   
                otherwise
                   this.lSaveImagesInScan = false;
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
            dDelay          = 0.05;
            % Create a new scan:
            this.scanHandler = mic.Scan('FM-control-scan', ...
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
            this.setupScanOutput(stateList, u8ScanAxisIdx)
            this.lIsScanning = true;
            this.ssCurrentScanSetup = ssScanSetup;
            this.scanHandler.start();
        end
        
        function stopScan(this)
            
            this.scanHandler.stop();
            this.lIsScanning = false;
            this.lIsConjugateLockEnabled = false;
            this.dInitialHSSZValue = 0;
            this.dInitialRetZValue = 0;
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
            lDeferredGoniMove = false;
            for k = 1:length(dAxes)
                switch dAxes(k)
                    case {1, 2, 3, 4, 5, 6} % Hexapod
                        lDeferredHexapodMove = true;
                    case {7, 8} % Goni
                        lDeferredGoniMove = true;
                end
            end
            
            if lDeferredHexapodMove
                dPosHexRaw = zeros(6,1);
                for k = 1:6
                    dPosHexRaw(k) = this.uiDeviceArrayHexapod{k}.getValRaw();  %#ok<AGROW>
                end
            end
            if lDeferredGoniMove
                dPosGoniRaw = zeros(2,1);
                for k = 1:2
                    dPosGoniRaw(k) = this.uiDeviceArrayGoni{k}.getValRaw(); %#ok<AGROW>
                end
            end
            
            
            for k = 1:length(dAxes)
                dVal = dVals(k);
                dAxis = dAxes(k);
                switch dAxis
                    case {1, 2, 3, 4, 5, 6} % Hexapod
                        this.uiDeviceArrayHexapod{dAxis}.setDestCal(dVal);
                        dPosHexRaw(dAxis) = this.uiDeviceArrayHexapod{dAxis}.getDestRaw();
                    case {7, 8} % Goni
                        this.uiDeviceArrayGoni{dAxis - 6}.setDestCal(dVal);
                        dPosHexRaw(dAxis - 6) = this.uiDeviceArrayHexapod{dAxis - 6}.getDestRaw();
                    case {9, 10, 11, 12, 13, 14, 15} % Reticle
                        this.uiDeviceArrayReticle{dAxis - 8}.setDestCal(dVal);
                        this.uiDeviceArrayReticle{dAxis - 8}.moveToDest();
                    case {16, 17, 18} % "wafer"
                        this.uiDeviceArrayWafer{dAxis - 15}.setDestCal(dVal);
                        this.uiDeviceArrayWafer{dAxis - 15}.moveToDest();
                    case 19 % do nothing
                       
                end
            end
            
            
        end
        
        % For isAtState, we assume that if the device is ready then it is
        % at state, since closed loop control is performed in device
        function isAtState = areScanAxisDevicesAtState(this, stState)
            
            dAxes = stState.axes;
            
            for k = 1:length(dAxes)
                dAxis = dAxes(k);
                switch dAxis
                    case {1, 2, 3, 4, 5, 6} % Hexapod
                        if ~this.apiHexapod.isReady()
                            isAtState = false;
                            return
                        end
                    case {7, 8} % Goni
                        if ~this.apiGoni.isReady()
                            isAtState = false;
                            return
                        end
                    case {9, 10, 11, 12, 13, 14, 15} % Reticle
                        
                        % Use isready: ------------------------
%                         retAxis = dAxis - 8;
%                         if this.uiDeviceArrayReticle{retAxis}.getDevice().isReady()
%                             fprintf('(LSI-control) scan: Reticle axis is ready\n');
%                             isAtState = true;
%                             return
%                         else
%                             isAtState = false;
%                             return
%                         end
                        
                        % Use eps tol ----------------------------
                        dUnit           = this.uiDeviceArrayReticle{dAxis - 8}.getUnit().name;
                        dCommandedDest  = this.uiDeviceArrayReticle{dAxis - 8}.getDestCal(dUnit);
                        dAxisPosition   = this.uiDeviceArrayReticle{dAxis - 8}.getValCal(dUnit);
                        dEps            = abs(dCommandedDest - dAxisPosition);
                        fprintf('Commanded destination: %0.3f, Actual pos: %0.3f, eps: %0.4f\n', ...
                            dCommandedDest, dAxisPosition, dEps);
                        dTolerance = 0.004; % scan unit assumed to be mm here
                        if dEps > dTolerance
                            fprintf('Reticle is not within tolerance\n');
                            isAtState = false;
                            return
                        end
    
                    case {16, 17, 18}
                        
                         % Use isready: ------------------------
%                         wafAxis = dAxis - 15;
%                         if this.uiDeviceArrayReticle{wafAxis}.getDevice().isReady()
%                             fprintf('(LSI-control) scan: Wafer axis is ready\n');
%                             isAtState = true;
%                             return
%                         else
%                             isAtState = false;
%                             return
%                         end

                        % Use eps tol ----------------------------
                        dUnit           = this.uiDeviceArrayWafer{dAxis - 15}.getUnit().name;
                        dCommandedDest  = this.uiDeviceArrayWafer{dAxis - 15}.getDestCal(dUnit);
                        dAxisPosition   = this.uiDeviceArrayWafer{dAxis - 15}.getValCal(dUnit);
                        dEps            = abs(dCommandedDest - dAxisPosition);
                        fprintf('Commanded destination: %0.3f, Actual pos: %0.3f, eps: %0.4f\n', ...
                            dCommandedDest, dAxisPosition, dEps);
                        dTolerance = 0.004; % scan unit assumed to be mm here
                        if dEps > dTolerance
                            fprintf('Wafer is not within tolerance\n');
                            isAtState = false;
                            return
                        end
                    case 19 % "do nothing"
                        isAtState = true;
                            return
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
                case {1, 2, 3, 4} % Image caputre
                    
                    % If this a 3D scan using image capture, assume new series 
                    % should be created with each move of top axis
                    if length(u8ScanAxisIdx) == 3 && double(u8Idx) ~= 1
                        % Check if axis 1 has changed:
                        if this.stLastScanState.values(1) ~= stateList{u8Idx}.values(1)
                            % update series number:
                            this.dImageSeriesNumber = this.dImageSeriesNumber + 1;
                            
                            
                        end
                        
                    end
                    
                     % flag that a "scan acquisition" has commenced:
                    this.lIsScanAcquiring = true;
            
                    this.onStartCamera(this.U8CAMERA_MODE_ACQUIRE);
                    % This will call image capture and then save
                    
                case 5 % pause
                    pause(2);
                    
                    % Flag that we are finished
                    this.lIsScanAcquiring = false;
            end
            
            % Set this state as the last scan state:
            this.stLastScanState = stateList{u8Idx};
            
        end
        
        function lAcquisitionFinished = scanIsAcquired(this, stState, outputIdx)
            % outputIdx: {'Image capture', 'Image intensity', 'Line Contrast', 'Line Pitch'}
            
            % Each output should have a value to plot
            dAcquiredValue = 1;
            
            switch outputIdx
                case {1, 2, 3, 4, 11} % Image caputre
                    % For getting image data, Scan is done acquiring when
                    % we set the lIsScanAcquiring boolean to false in
                    % 'onSaveImage'
                    
                    lAcquisitionFinished = ~this.lIsScanAcquiring;
                case 5 % pause
                    dAcquiredValue = rand(1);
                    lAcquisitionFinished = ~this.lIsScanAcquiring;
                case 6 % wafer dose diode
                    
%                     dAcquiredValue = this.apiWaferDoseMonitor.read(2);
                    dAcquiredValue = this.uiDoseMonitor.getValRaw();
                    lAcquisitionFinished = ~this.lIsScanAcquiring;
                    
                case 7 % HS Simple Z
                    dAcquiredValue = this.uiHSSimpleZ.getValRaw();
                    lAcquisitionFinished = ~this.lIsScanAcquiring;
                    
                case {8, 9, 10} % HS Cal Z, Rx, Ry
                    dHSChannel = 11 - outputIdx;
                    dAcquiredValue = this.apiMFDriftMonitor.getHSValue(dHSChannel);
                    lAcquisitionFinished = ~this.lIsScanAcquiring;
                    
            end
            
            % When scan is finished, process results:
            if lAcquisitionFinished
                u8Idx = this.scanHandler.getCurrentStateIndex();
                
                
                switch outputIdx
                    case 2 % Grab camera image and integrate intensity:
                        dImg = this.apiCamera.getImage();
                        dAcquiredValue = sum(dImg(:));
                        
                    case 3 % Integrated background diff
                        dImg = this.apiCamera.getImage();
                        
                        if this.uicbSubtractBackground.get() && ...
                                size(dImg, 1) == size(this.dBackgroundImage, 1) && ...
                                size(dImg, 2) == size(this.dBackgroundImage, 2)
                            dImg = dImg - this.dBackgroundImage;
                        end
                        
                        % Get contrast here:
                        dAcquiredValue = sum(abs(dImg(:)));
                    case 4 % Line pitch
                        dImg = this.apiCamera.getImage();
                        
                        % Get Pitch here:
                        dAcquiredValue = sum(dImg(:));
                end
                
                
                % Send plottable values to scanOutputHandler
                this.handleUpdateScanOutput(u8Idx, stState, dAcquiredValue)
            end
            
        end
        
        function onScanComplete(this, dInitialState, fhSetState)
            this.lIsScanning = false;
            this.lIsConjugateLockEnabled = false;
            this.dInitialHSSZValue = 0;
            this.dInitialRetZValue = 0;
            
            % Reset to initial state on complete
            fhSetState([], dInitialState);
            
            % Reset scan setup pointer:
            this.ssCurrentScanSetup = {};
        end
        
        function onScanAbort(this, dInitialState, fhSetState, fhIsAtState)
            this.lIsScanning = false;
            this.lIsConjugateLockEnabled = false;
            this.dInitialHSSZValue = 0;
            this.dInitialRetZValue = 0;
            
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

            % Reset scan setup pointer:
            this.ssCurrentScanSetup = {};
        end
        
        % Sets up scan output axis to plot the results of a 1-dim or 2-dim
        % scan
        function setupScanOutput(this, stateList, u8ScanAxisIdx)
            this.dNumScanOutputAxes = length(u8ScanAxisIdx);
            this.dLinearScanOutput = zeros(1, length(stateList));
            
            dAxisValues = zeros(length(stateList), length(u8ScanAxisIdx));
            % Assemble all state values for each axis:
            for k = 1:length(stateList)
                dAxisValues(k,:) = stateList{k}.values;
            end
            % sort each column:
            dAxisValues = sort(dAxisValues);
            
            this.ceScanCoordinates = cell(1, length(u8ScanAxisIdx));
            
            for k = 1:length(u8ScanAxisIdx)
                this.ceScanCoordinates{k} = unique(dAxisValues(:,k)');
            end
            
            % make scan output for 1 or 2 axis cases
            switch length(u8ScanAxisIdx)
                case 1
                    this.dScanOutput = nan(1, length(this.ceScanCoordinates{1}));
                case 2
                    dXidx = this.ceScanCoordinates{1};
                    dYidx = this.ceScanCoordinates{2};
                    this.dScanOutput = nan(length(dYidx), length(dXidx));
                case 3
                    dXidx = this.ceScanCoordinates{1};
                    dYidx = this.ceScanCoordinates{2};
                    dZidx = this.ceScanCoordinates{3};
                    this.dScanOutput = zeros(size(meshgrid(dXidx, dYidx, dZidx)));
            end
            
        end
        
        function handleUpdateScanOutput(this, u8Idx, stStateElement, dAcquiredValue)
            % Log linear value:
            this.dLinearScanOutput(u8Idx) = dAcquiredValue;
            
            % make scan output for 1 or 2 axis cases
            switch length(this.ceScanCoordinates)
                case 1
                    dXidx = find(this.ceScanCoordinates{1} == stStateElement.values);
                    this.dScanOutput(dXidx) = dAcquiredValue; %#ok<FNDSB>
                    
                    h = plot(this.haScanOutput, this.ceScanCoordinates{1}, this.dScanOutput);
                    h.HitTest = 'off';
                    this.haScanOutput.ButtonDownFcn = @(src, evt) this.handleScanOutputClick(evt, 1);
                    
                case 2
                    dXidx = find(this.ceScanCoordinates{1} == stStateElement.values(1));
                    dYidx = find(this.ceScanCoordinates{2} == stStateElement.values(2));
                    this.dScanOutput(dYidx, dXidx) = dAcquiredValue; %#ok<FNDSB>
                    
                    h = imagesc(this.haScanOutput, this.ceScanCoordinates{1}, this.ceScanCoordinates{2}, (this.dScanOutput));
                    
                    try
                    dMn = min(this.dScanOutput(~isnan(this.dScanOutput(:))));
                    dMx = max(this.dScanOutput(~isnan(this.dScanOutput(:))));
                    if (~isempty(dMn) && ~isempty(dMx))
                        this.haScanOutput.CLim = [dMn, dMx];
                    else
                        this.haScanOutput.CLim = [0, 1];
                    end
                    
                    catch
                        fprintf(lasterr);
                    end
                    
                    this.haScanOutput.YDir = 'normal';
                    h.HitTest = 'off';
                    this.haScanOutput.ButtonDownFcn = @(src, evt) this.handleScanOutputClick(evt, 2);

                    
                    colorbar(this.haScanOutput);
                case 3
                    dXidx = find(this.ceScanCoordinates{1} == stStateElement.values(1));
                    dYidx = find(this.ceScanCoordinates{2} == stStateElement.values(2));
                    dZidx = find(this.ceScanCoordinates{3} == stStateElement.values(3));
                    this.dScanOutput(dXidx, dYidx, dZidx) = dAcquiredValue; %#ok<FNDSB>
                    
                    % don't do anything right now
            end
        end
        
        % Handles a click inside of the scan output axes
        function handleScanOutputClick(this, evt, nDim)
            % make a clone of last scan state but update the
                        % current value:
            stTargetState = this.stLastScanState;
            if evt.Button > 1 % right click
                switch nDim
                    case 1
                        fprintf('(LSI-control) Scan-output: Context click detected at x = %0.3f\n', ...
                            evt.IntersectionPoint(1));
                        
                        
                        stTargetState.values(1) = evt.IntersectionPoint(1);
                        cMsg = sprintf('Move %s to %0.3f?', ...
                                this.ceScanAxisLabels{stTargetState.axes(1)}, ...
                                evt.IntersectionPoint(1));
                            
                        choice = questdlg(cMsg, 'Move axes', 'Yes','No', 'No');
                        % Handle response
                        switch choice
                            case 'Yes'
                                this.setScanAxisDevicesToState(stTargetState);
                            case 'No'
                                fprintf('scan axis move aborted\n');
                        end
                            
                    case 2
                        fprintf('(LSI-control) Scan-output: Context click detected at [x, y] = [%0.3f, %0.3f]\n', ...
                            evt.IntersectionPoint(1), evt.IntersectionPoint(2));
                        stTargetState.values(1) = evt.IntersectionPoint(1);
                        stTargetState.values(2) = evt.IntersectionPoint(2);
                        
                        cMsg = sprintf('Move [%s, %s] to [%0.3f, %0.3f]?', ...
                                this.ceScanAxisLabels{stTargetState.axes(1)}, ...
                                this.ceScanAxisLabels{stTargetState.axes(2)}, ...
                                evt.IntersectionPoint(1),evt.IntersectionPoint(2));
                            
                        choice = questdlg(cMsg, 'Move axes', 'Yes','No', 'No');
                        % Handle response
                        switch choice
                            case 'Yes'
                                this.setScanAxisDevicesToState(stTargetState);
                            case 'No'
                                fprintf('scan axis move aborted\n');
                        end
                end
            else % button down was a left click, just display the event:
                switch nDim
                    case 1
                        cMsg = sprintf('(LSI-control) Scan-output:Axis %s value: %0.3f\n', ...
                                this.ceScanAxisLabels{stTargetState.axes(1)}, ...
                                evt.IntersectionPoint(1));
                        
                        
                    case 2
                        cMsg = sprintf('(LSI-control) Scan-output:Axes [%s, %s] values: [%0.3f, %0.3f]\n', ...
                                this.ceScanAxisLabels{stTargetState.axes(1)}, ...
                                this.ceScanAxisLabels{stTargetState.axes(2)}, ...
                                evt.IntersectionPoint(1),evt.IntersectionPoint(2));
                end
                fprintf(cMsg);
            end
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
            dYPos = 0.05;
            dYHeight = (.75 - (dNumAxes - 1) * 0.05)/dNumAxes;
            for k = 1:dNumAxes
                kp = dNumAxes - k + 1;
                
                this.haScanMonitors{kp} = ...
                    axes('Parent', this.uitgAxes.getTabByName('Scan monitor'),...
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
        
%% Build main figure
        function build(this)
            
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            % Main figure
            this.hFigure = figure(...
                    'name', 'Interferometer control',...
                    'Units', 'pixels',...
                    'Position', [10 10 this.dWidth this.dHeight],...
                    'numberTitle','off',...
                    'Toolbar','none',...
                    'Menubar','none', ...
                    'Color', [0.7 0.73 0.73], ...
                    'Resize', 'off',...
                    'HandleVisibility', 'on',... % lets close all close the figure
                    'Visible', 'on',...
                    'CloseRequestFcn', @this.onCloseRequest ...
                    );
                
           % Axes:
           
           
           % Main Axes:
           this.uitgAxes.build(this.hFigure, 880, 215, 860, 885);
            
           
          
           
            % Stage panel:
            this.hpStageControls = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Stage control',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'BorderWidth',0, ... 
                'Position', [10 300 490 770] ...
            );
        
            % Scan control panel:
            this.hpPositionRecall = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Position recall and coordinate transform',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'BorderWidth',0, ... 
                'Position', [510 300 360 770] ...
                );
        
            drawnow
        
            % Scan controls:
            this.uitgScan.build(this.hFigure, 10, 815, 860, 280);

             % Scans:
            this.ss1D.build(this.uitgScan.getTabByIndex(1), 10, 10, 850, 230); 
            this.ss2D.build(this.uitgScan.getTabByIndex(2), 10, 10, 850, 230);
            this.ss3D.build(this.uitgScan.getTabByIndex(3), 10, 10, 850, 230);
            this.ssExp1.build(this.uitgScan.getTabByIndex(4), 10, 10, 850, 230);
            this.ssExp2.build(this.uitgScan.getTabByIndex(5), 10, 10, 850, 230);
            
            % Scan progress text elements:
            uitScanMonitor = this.uitgAxes.getTabByName('Scan monitor');
            hScanMonitorPanel = uipanel(uitScanMonitor, ...
                     'units', 'pixels', ...
                     'Position', [1 720 560 100] ...
                     );
            this.uiTextStatus.build(hScanMonitorPanel, 10, 10, 100, 30);
            this.uiTextTimeElapsed.build(hScanMonitorPanel, 250, 10, 100, 30);
            this.uiTextTimeRemaining.build(hScanMonitorPanel, 10, 50, 100, 30);
            this.uiTextTimeComplete.build(hScanMonitorPanel, 250, 50, 100, 30);
            
            % Scan output
            uitScanOutput = this.uitgAxes.getTabByName('Scan output');
            this.haScanOutput = axes('Parent', uitScanOutput, ...
                                 'Units', 'pixels', ...
                                 'Position', [50, 50, 750, 650], ...
                                 'XTick', [], 'YTick', []);     
            
            % Position recall:
            this.uiSLHexapod.build(this.hpPositionRecall, 10, 10, 340, 188);
%             this.uiSLGoni.build(this.hpPositionRecall, 10, 200, 340, 188);
            this.uiSLReticle.build(this.hpPositionRecall, 10, 200, 340, 188);
            this.uiSLReticleFine.build(this.hpPositionRecall, 10, 390, 340, 188);
            
            % Reticle locking:
            this.uicbLockReticle.build(this.hpPositionRecall, 10, 590, 120, 30);
            this.uibSetLRZero.build(this.hpPositionRecall, 150, 590, 80, 30);
            
            this.uitLRInitialRetZ.build(this.hpPositionRecall, 10, 630, 80, 30);
            this.uitLRInitialHS.build(this.hpPositionRecall, 150, 630, 80, 30);
            this.uitLRDeltaRetZ.build(this.hpPositionRecall, 10, 670, 80, 30);
            this.uitLRDeltaHS.build(this.hpPositionRecall, 150, 670, 80, 30);
            this.uitLRConjugateError.build(this.hpPositionRecall, 10, 710, 80, 30);
            
            % Stage UI elements
            dAxisPos = 30;
            dLeft = 20;
           
             % Build comms and axes
            this.uiCommSmarActSmarPod.build(this.hpStageControls, dLeft, dAxisPos - 7);
            this.uibHomeHexapod.build(this.hpStageControls, dLeft + 340, dAxisPos - 5, 95, 20);
            dAxisPos = dAxisPos + 20;
            for k = 1:length(this.cHexapodAxisLabels)
                this.uiDeviceArrayHexapod{k}.build(this.hpStageControls, ...
                    dLeft, dAxisPos);
                dAxisPos = dAxisPos + this.dMultiAxisSeparation;
            end
            dAxisPos = dAxisPos + 20;
            
            % Don't build goni stuff for now
%             this.uiCommSmarActMcsGoni.build(this.hpStageControls,  dLeft, dAxisPos - 7);
%             this.uibHomeGoni.build(this.hpStageControls, dLeft + 340, dAxisPos - 5, 95, 20);
%             dAxisPos = dAxisPos + 20;
%             for k = 1:length(this.cGoniLabels)
%                 this.uiDeviceArrayGoni{k}.build(this.hpStageControls, ...
%                     dLeft, dAxisPos);
%                 dAxisPos = dAxisPos + this.dMultiAxisSeparation;
%             end

            % PPMac reticle and wafer
            this.uiCommDeltaTauPowerPmac.build(this.hpStageControls,  dLeft, dAxisPos - 7);
            dAxisPos = dAxisPos + 20;
            for k = 1:length(this.cReticleLabels)
                this.uiDeviceArrayReticle{k}.build(this.hpStageControls, ...
                    dLeft, dAxisPos);
                if (k == 3)
                    this.uipLRDisableZ = uipanel(...
                        'Parent', this.hpStageControls,...
                        'Units', 'pixels',...
                        'FontWeight', 'Bold',...
                        'Clipping', 'on',...
                        'BorderWidth',0, ...
                        'BackgroundColor',  [1 0.300 0.300, 0.3], ...
                        'Visible', 'off', ...
                        'Position', [dLeft, 5+ this.hpStageControls.Position(4) - dAxisPos - this.dMultiAxisSeparation...
                        , 25, 25] ...
                        );
                end
                if (k == 5)
                    dAxisPos = dAxisPos + this.dMultiAxisSeparation/2;
                end
                dAxisPos = dAxisPos + this.dMultiAxisSeparation;
            end
            
            dAxisPos = dAxisPos + this.dMultiAxisSeparation/2;
            for k = 1:length(this.cWaferLabels)
                 this.uiDeviceArrayWafer{k}.build(this.hpStageControls, ...
                    dLeft, dAxisPos);
                dAxisPos = dAxisPos + this.dMultiAxisSeparation;
            end
            
            dAxisPos = dAxisPos + 15;
            % DMI/Wafer diode connect buttons and GetNumbers
            
            this.uicommWaferDoseMonitor.build(this.hpStageControls,  dLeft, dAxisPos - 7);
            
             this.uicommMFDriftMonitor.build(this.hpStageControls,  dLeft + 230, dAxisPos - 7);
             
             
            dAxisPos = dAxisPos + 20;
            dAxisPos = dAxisPos +  this.dMultiAxisSeparation/2;
            
            this.uiDoseMonitor.build(this.hpStageControls, dLeft, dAxisPos);
            
            this.uiHSSimpleZ.build(this.hpStageControls, dLeft + 230, dAxisPos);
            
            
            
            dAxisPos = dAxisPos +  this.dMultiAxisSeparation;
            
            
           
            dAxisPos = dAxisPos + 25;
            this.uiDMIChannels{1}.build(this.hpStageControls, dLeft, dAxisPos);
            this.uiDMIChannels{2}.build(this.hpStageControls, dLeft + 230, dAxisPos);
            
            % Camera control panel:
            this.hpCameraControls = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Camera control',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'BorderWidth',0, ... 
                'Position', [880 900 860 170] ...
            );
            
            % Camera UI elements
            this.uiDeviceCameraTemperature.build(this.hpCameraControls, 10, 40);            
            this.uiDeviceCameraExposureTime.build(this.hpCameraControls, 10, 70);
            
            this.uiCommPIMTECamera.build    (this.hpCameraControls, 10,  15);
            
            this.uipBinning.build           (this.hpCameraControls, 545, 40, 70, 25);
            this.uiButtonFocus.build        (this.hpCameraControls, 630, 50, 60,  25);
            this.uiButtonAcquire.build      (this.hpCameraControls, 710, 50, 60,  25);
            this.uiButtonStop.build         (this.hpCameraControls, 790, 50, 60,  25);
            
            this.uieImageName.build         (this.hpCameraControls, 180 + 370, 115, 200, 25);
            this.uiButtonSaveImage.build    (this.hpCameraControls, 400 + 370, 130, 80, 20);
           
            this.uiButtonSetBackground.build(this.hpCameraControls,  630, 90, 95, 25);
            this.uicbSubtractBackground.build(this.hpCameraControls, 730, 90, 120, 25);
            
            
            this.uipbExposureProgress.build(this.hpCameraControls, 10, 115);
                  
            % Button colors:
            this.uiButtonAcquire.setText('Acquire')
            this.uiButtonAcquire.setColor(this.dAcquireColor);
            this.uiButtonFocus.setText('Focus')
            this.uiButtonFocus.setColor(this.dFocusColor);
            this.uiButtonStop.setText('STOP');
            this.uiButtonStop.setColor(this.dInactiveColor);
            
        end
        
        function homeHexapod(this)
            if strcmp(questdlg('Would you like to home the Hexapod?'), 'Yes')
                this.apiHexapod.home();
            end
        end
        
        function homeGoni(this)
            if strcmp(questdlg('Would you like to home the Goniometer?'), 'Yes')
                this.apiGoni.home();
            end
        end
        
        

        
    
    end
    
    
    methods (Access = protected)
        
        function onCloseRequest(this, src, evt)
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
        end
        
        function delete(this)
            
            % Clean up clock tasks
            if isvalid(this.clock) && ...
                    this.clock.has(this.id())
                % this.msg('Axis.delete() removing clock task');
                this.clock.remove(this.id());
            end
        end
      
        
        function onToggleAllChange(this, src, evt)
            
            if this.uiToggleAll.get()
                this.turnOnAllDeviceUi();
            else
                this.turnOffAllDeviceUi()
            end
            
        end
        
        
        function onButtonUseDeviceDataChange(this, src, ~)
            
            this.uiDeviceX.getValCalDisplay()
            this.uiDeviceY.getValCalDisplay()
            this.uiDeviceMode.get()
            this.uiDeviceAwesome.get()
            
        end
        
        function saveStateToDisk(this)
            st = this.save();
            save(this.file(), 'st');
            
        end
        
        function loadStateFromDisk(this)
            if exist(this.file(), 'file') == 2
                fprintf('loadStateFromDisk()\n');
                load(this.file()); % populates variable st in local workspace
                this.load(st);
            end
        end
        
        function c = file(this)
            mic.Utils.checkDir(this.cDirSave);
            c = fullfile(...
                this.cDirSave, ...
                ['saved-state', '.mat']...
            );
        end
        
    end
    
end

