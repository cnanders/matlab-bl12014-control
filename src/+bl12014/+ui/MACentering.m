classdef MACentering < mic.Base
    
    properties (Constant)
        scanOutputs =  {'DT-41', 'DT-42 (popin diode)', 'DT-35 (PO Current)', 'Reticle Diode', 'Subframe Diode', 'IF Diode'};
        
    end
    properties (SetAccess = private)
        
        cConfigPath        = bl12014.Utils.pathUiConfig()
        
        
        % {bl12014.ui.Scanner 1x1}
        uiScanner
        
        % {bl12014.ui.GigECamera 1x1}
        uiGigECamera
        
        % {bl12014.ui.MADiagnostics 1x1}
        uiDiagnostics
        
        % {bl12014.ui.SMSIFDiagnostics 1x1}
        uiSMSIFDiagnostics
        
        uiStateWaferNearPrint
        
        % {bl12014.ui.VPFM 1x1}
        uiVPFM

        uiMDMCurrent
        
        
        % {bl12014.ui.Shutter 1x1}
        uiShutter
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiUndulatorGap
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiSwitch2Outlet2
        
        
        % Scan setups:
        ss1D
        ss2D
        stLastScanState
        scanHandler
        lIsScanning = false

        dInitialState

        % axes
        haScanAxis
        ceScanRanges

        dImg = zeros(50)
        dXAxis
        dYAxis

        uiDTVoltage35
        uiDTVoltage41
        uiDTVoltage42

        uiReticleCoarseStage
        uiReticleAxes

        cScanLogDir

        uiFluxSF
        uiFluxReticle
        
    end
    
    properties (Access = protected)
        
        % {mic.Clock 1x1} must be provided
        clock
        % {mic.ui.Clock 1x1}
        uiClock
        
        
        % {bl12014.Hardware 1x1}
        hardware
                
    end
    
    properties (SetAccess = protected)
        
        cName = 'MACentering'
    end
    
    methods
        
        function this = MACentering(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
 
            
             if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
                       
            this.init();

            this.onFocus();
        
        end

        
        

                
        function build(this, hParent, dLeft, dTop)
            
            this.uiScanner.build(hParent, dLeft, dTop);
            
            % this.uiGigECamera.build(hParent, dLeft + 1250, dTop, 480);

            % this.uiMDMCurrent.build(hParent, dLeft + 720, 340);


            this.uiDTVoltage35.build(hParent, dLeft + 720, 350);
            this.uiDTVoltage41.build(hParent, dLeft + 720, 390);
            this.uiDTVoltage42.build(hParent, dLeft + 720, 430);

            
            dTop = 300;

            this.uiReticleCoarseStage.build(hParent, dLeft, 475);

            this.uiFluxReticle.build(hParent, dLeft, 670);
            this.uiFluxSF.build(hParent, dLeft, 700);



             % Scans:
             this.ss1D.build(hParent, dLeft + 970, 2, 850, 210); 
             dTop = dTop + 210;
             this.ss2D.build(hParent, dLeft + 970, 200, 850, 210);

             this.haScanAxis = axes(...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Position', [dLeft + 1270, 430, 500, 500] ...
             );

            
        end

        function onFocus(this)
            this.uiScanner.uiPupilFillGenerator.onFocus();

        end
        
        
        function cec = getPropsDelete(this)
            cec = {
                'uiScanner', ...
                'uiDiagnostics', ...
                'uiSMSIFDiagnostics', ...
                'uiStateWaferNearPrint', ...
                'uiVPFM', ...
                'uiGigECamera', ...
                'uiShutter', ...
                'uiUndulatorGap', ...
                'uiSwitch2Outlet2', ...
            };
        end
        
        function delete(this)
            
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);  
            cecProps = this.getPropsDelete();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                this.(cProp).delete();
            end
            
        end  
        
        
        function st = save(this)
            st = struct();
            st.uiScanner = this.uiScanner.save();
        end
        
        function load(this, st)
            if isfield(st, 'uiScanner') 
                this.uiScanner.load(st.uiScanner);
            end
        end
        
    end
    
    methods (Access = protected)
       
        
        function init(this)
            
            [cDir, cName, cExt] = fileparts(mfilename('fullpath'));
            cDirSave = mic.Utils.path2canonical(fullfile(...
                cDir, ...
                '..', ...
                '..', ...
                'save', ...
                'scanner-ma' ...
            ));

            this.cScanLogDir =  mic.Utils.path2canonical(fullfile(...
                cDir, ...
                '..', ...
                '..', ...
                'save', ...
                'ma-centering-scanlog' ...
            ));
          

            this.uiMDMCurrent = bl12014.ui.MDMCurrent(...
                'clock', this.uiClock, ...
                'hardware', this.hardware ...
            );

            this.uiDTVoltage35 = mic.ui.device.GetNumber(...
                'clock', this.uiClock, ...
                'cName', [this.cName, 'DT 35 Volts'], ... 
                'config', mic.config.GetSetNumber(...
                            'cPath',  fullfile(...
                                bl12014.Utils.pathUiConfig(), ...
                                'get-number', ...
                                'config-volts.json' ...
                            ) ...
                        ), ...
                'cLabel', 'DT-35 (PO current)', ...
                'dWidthName', 150,...
                'lShowInitButton', false, ...
                'lShowLabels', false, ...
                'fhGet',@() this.getDTChannelVal(35), ...
                'fhIsVirtual', @() false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lUseFunctionCallbacks', true ...
            );

            this.uiDTVoltage41 = mic.ui.device.GetNumber(...
                'clock', this.uiClock, ...
                'cName', [this.cName, 'DT 41 Volts'], ... 
                'config', mic.config.GetSetNumber(...
                            'cPath',  fullfile(...
                                bl12014.Utils.pathUiConfig(), ...
                                'get-number', ...
                                'config-volts.json' ...
                            ) ...
                         ), ...
                'cLabel', 'DT-41', ...
                'dWidthName', 150,...
                'lShowInitButton', false, ...
                'lShowLabels', false, ...
                'fhGet',@() this.getDTChannelVal(41), ...
                'fhIsVirtual', @() false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'lUseFunctionCallbacks', true ...
            );

            this.uiDTVoltage42 = mic.ui.device.GetNumber(...
            'clock', this.uiClock, ...
            'cName', [this.cName, 'DT 42 Volts'], ... 
            'config', mic.config.GetSetNumber(...
                        'cPath',  fullfile(...
                            bl12014.Utils.pathUiConfig(), ...
                            'get-number', ...
                            'config-DT42.json' ...
                        ) ...
                     ), ...
            'cLabel', 'EUVT Popin', ...
            'dWidthName', 150,...
            'lShowInitButton', false, ...
            'lShowLabels', false, ...
            'fhGet', @() this.getDTChannelVal(42), ...
            'fhIsVirtual', @() false, ...
            'lShowRel', false, ...
            'lShowZero', false, ...
            'lUseFunctionCallbacks', true ...
        );

        this.uiFluxReticle = mic.ui.device.GetNumber(...
            'clock', this.uiClock, ...
            'cName', [this.cName, 'ui-flux-reticle'], ... 
                'config', mic.config.GetSetNumber(...
                    'cPath',  fullfile(...
                        bl12014.Utils.pathUiConfig(), ...
                        'get-number', ...
                        'config-amps.json' ...
                    ) ...
                ), ...
            'cLabel', 'Reticle Diode', ...
            'dWidthPadUnit', 277, ...
            'lShowInitButton', false, ...
            'lShowLabels', false, ...
            'fhGet', @() this.hardware.getKeithley6482Reticle().read(1), ...
            'fhIsVirtual', @() false, ...
            'lShowRel', false, ...
            'lShowZero', false, ...
            'lUseFunctionCallbacks', true ...
        );

        this.uiFluxSF = mic.ui.device.GetNumber(...
            'clock', this.uiClock, ...
            'cName', [this.cName, 'ui-flux-sf'], ... 
                'config', mic.config.GetSetNumber(...
                    'cPath',  fullfile(...
                        bl12014.Utils.pathUiConfig(), ...
                        'get-number', ...
                        'config-amps.json' ...
                    ) ...
                ), ...
            'cLabel', 'Subframe Diode', ...
            'dWidthPadUnit', 277, ...
            'lShowInitButton', false, ...
            'lShowLabels', false, ...
            'fhGet', @() this.hardware.getKeithley6482Reticle().read(2), ...
            'fhIsVirtual', @() false, ...
            'lShowRel', false, ...
            'lShowZero', false, ...
            'lUseFunctionCallbacks', true ...
        );


        this.uiReticleCoarseStage = bl12014.ui.ReticleCoarseStage(...
            'cName', [this.cName, 'reticle-coarse-stage'], ...
            'hardware', this.hardware, ...
            'clock', this.uiClock ...
            );
        
        this.uiReticleAxes = bl12014.ui.ReticleAxes(...
            'cName', [this.cName, 'reticle-axes'], ...
            'clock', this.uiClock, ...
            'fhGetIsShutterOpen', @this.uiShutter.uiOverride.get, ...
            'fhGetX', @() this.uiReticleCoarseStage.uiX.getValCal('mm') / 1000, ...
            'fhGetY', @() this.uiReticleCoarseStage.uiY.getValCal('mm') / 1000, ...
            'dWidth', 600, ...
            'dHeight', 600 ...
        );

            this.uiScanner = bl12014.ui.Scanner(...
                'fhGetNPoint', @() this.hardware.getNPointMA(), ...
                'cName', 'DC MA Scanner', ...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                'cDirSave', cDirSave, ...
                'lDCMode', true, ...
                'lShowChooseDir', false, ...   
                'dScale', 0.67 ... % 0.67 rel amp = sig 1
            );
            
        

            this.ss1D = mic.ui.common.ScanSetup( ...
                'cLabel', 'Saved pos', ...
                'ceOutputOptions', this.scanOutputs, ...
                'ceScanAxisLabels', {'DC X', 'DC Y', 'RCX', 'RCY'}, ...
                'dScanAxes', 1, ...
                'cName', '1D-Scan', ...
                'u8selectedDefaults', uint8(1),...
                'cConfigPath', this.cConfigPath, ...
                  'fhOnScanChangeParams', @(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames, ceScanRanges) ...
                    this.handleUpdateScanSetup(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames, ceScanRanges), ...
                'fhOnStopScan', @()this.stopScan, ...
                'fhOnScan', ...
                        @(ceScanStates, u8ScanAxisIdx, lUseDeltas, u8ScanOutputDeviceIdx, cAxisNames)...
                                this.onScan(this.ss1D, ceScanStates, u8ScanAxisIdx, lUseDeltas, u8ScanOutputDeviceIdx, cAxisNames) ...
            );

            this.ss2D = mic.ui.common.ScanSetup( ...
                'cLabel', 'Saved pos', ...
                'ceOutputOptions', this.scanOutputs, ...
                'ceScanAxisLabels', {'DC X', 'DC Y',  'RCX', 'RCY'}, ...
                'dScanAxes', 2, ...
                'cName', '2D-Scan', ...
                'u8selectedDefaults', uint8([1, 2]),...
                'cConfigPath', this.cConfigPath, ...
                'fhOnScanChangeParams', @(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames, ceScanRanges) ...
                    this.handleUpdateScanSetup(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames, ceScanRanges), ...
                'fhOnStopScan', @()this.stopScan, ...
                'fhOnScan', ...
                        @(ceScanStates, u8ScanAxisIdx, lUseDeltas, u8ScanOutputDeviceIdx, cAxisNames)...
                                this.onScan(this.ss2D, ceScanStates, u8ScanAxisIdx, lUseDeltas, u8ScanOutputDeviceIdx, cAxisNames) ...
            );
            
        end
        
        function dVal = getDTChannelVal(this, dChannel)
            dVal = this.hardware.getDataTranslation().getScanDataOfChannel(dChannel);
            % if dChannel == 41
            %      fprintf('channel 41: %0.3f\n', dVal * 1000);
            % end
            % if dChannel == 42
            %      fprintf('channel 42: %0.3f\n', dVal * 1000);
            % end
        end
        
        function stopScan(this)
            this.lIsScanning = false;
            this.scanHandler.stop();


        end

        function onScanAbort(this, dInitialState, fhSetState, fhIsAtState)
            this.lIsScanning = false;
            fhSetState([], dInitialState);

        end
        
       
        function onScan(this, ssScanSetup, stateList, u8ScanAxisIdx, lUseDeltas, u8OutputIdx, cAxisNames)
            
            % If already scanning, then stop:
            if(this.lIsScanning)
                disp('Scan already running...')
                return
            end
                

            dInitialState = this.getInitialState(u8ScanAxisIdx);

            % Save this state:
            this.stLastScanState = dInitialState;

            % If using deltas, modify state to center around current
            % values:
            ceScanRanges = cell(1, length(u8ScanAxisIdx));

            for m = 1:length(u8ScanAxisIdx)
                for k = 1:length(stateList)
                    if lUseDeltas(m)
                        stateList{k}.values(m) = stateList{k}.values(m) + dInitialState.values(m);
                        ceScanRanges{m}(k) = stateList{k}.values(m);
                    else 
                        ceScanRanges{m}(k) = stateList{k}.values(m);
                    end
                end
            end

            this.ceScanRanges = ceScanRanges;
            
            % Build "scan recipe" from scan states 
            stRecipe.values = stateList; % enumerable list of states that can be read by setState
            stRecipe.unit = struct('unit', 'unit'); % not sure if we need units really, but let's fix later
                        
            fhSetState      = @(stUnit, stState) this.setScanAxisDevicesToState(stState);
            fhIsAtState     = @(stUnit, stState) this.areScanAxisDevicesAtState(stState);
            fhAcquire       = @(stUnit, stState) this.scanAcquire(u8OutputIdx, stateList, u8ScanAxisIdx, lUseDeltas, cAxisNames);
            fhIsAcquired    = @(stUnit, stState) this.scanIsAcquired(stState, u8OutputIdx);
            fhOnComplete    = @(stUnit, stState) this.onScanComplete(dInitialState, fhSetState);
            fhOnAbort       = @(stUnit, stState) this.onScanAbort(dInitialState, fhSetState, fhIsAtState);
            dDelay          = 0.4;
            % Create a new scan:
            this.scanHandler = mic.Scan('MA MDM centering scan', ...
                                        this.uiClock, ...
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
%             this.setupScanOutput(stateList, u8ScanAxisIdx)
            this.lIsScanning = true;
            this.scanHandler.start();
        end

        function dInitialState = getInitialState(this, u8ScanAxisIdx)
            % grab initial state of values:
           dInitialState = struct;
           dInitialState.values = [];
           dInitialState.axes = u8ScanAxisIdx;

           % validate start conditions and get initial state
           for k = 1:length(u8ScanAxisIdx)
               dAxis = double(u8ScanAxisIdx(k));
               switch dAxis
                   case 1 % MA DC
                       dInitialState.values(k) = this.uiScanner.uiPupilFillGenerator.getDCX();
                   case 2 % MA DC
                       dInitialState.values(k) = this.uiScanner.uiPupilFillGenerator.getDCY();
                   case 3
                       dInitialState.values(k) = this.uiReticleCoarseStage.uiX.getValCal('mm');
                   case 4
                       dInitialState.values(k) = this.uiReticleCoarseStage.uiY.getValCal('mm');
               end
           end
        end
        
        function onScanComplete(this, dInitialState, fhSetState)
            this.lIsScanning = false;
            
            % Save data:
            st.ceScanRanges = this.ceScanRanges;
            st.dImg = this.dImg;

            save(fullfile(this.cScanLogDir, [datestr(now, 'yyyy-mm-dd-HH-MM-SS'), '.mat']), 'st');
            fprintf('Saved scan data to %s\n', fullfile(this.cScanLogDir, [datestr(now, 'yyyy-mm-dd-HH-MM-SS'), '.mat']));

            % Set back to initial state:
            this.setScanAxisDevicesToState(dInitialState);

        end

        function setScanAxisDevicesToState(this, stState)
            fprintf('Setting axes to state');
            dAxes = stState.axes;
            dVals = stState.values;
            
            for n = 1:length(dAxes)
                dAxis = dAxes(n);
                dVal = dVals(n);
                switch dAxis
                    case 1
                        this.uiScanner.uiPupilFillGenerator.setDCX(dVal);
                    case 2
                        this.uiScanner.uiPupilFillGenerator.setDCY(dVal);
                    case 3
                        % Reticle coarse X:
                        dX = dVal;
                        this.uiReticleCoarseStage.uiX.setDestCal(dX, 'mm');
                        this.uiReticleCoarseStage.uiX.moveToDest();
                    case 4
                        % Reticle coarse Y:
                        dY = dVal;
                        this.uiReticleCoarseStage.uiY.setDestCal(dY, 'mm');
                        this.uiReticleCoarseStage.uiY.moveToDest();
                end
            end

            if any(dAxes == 1) || any(dAxes == 2)
                this.uiScanner.uiNPointLC400.setWritingIllum(true)
                this.uiScanner.uiNPointLC400.executePupilFillWriteSequence();
            end
        end

        function lOut = areScanAxisDevicesAtState(this, stState)
            dAxes = stState.axes;
            dVals = stState.values;
            

            lOut = true;
            for n = 1:length(dAxes)
                dAxis = dAxes(n);
                dVal = dVals(n);
                switch dAxis
                    case {1, 2}
                        lOut = ~this.uiScanner.uiNPointLC400.isExecutingPupilFillSequence();
                    case 3
                        lReady = abs(this.uiReticleCoarseStage.uiX.getValCal('mm') - dVal) <= 0.001;
                        lOut = lOut && lReady;
                        
                        % if lDebug
                        %     cMsg = sprintf('value = %1.3f; goal = %1.3f', ...
                        %         this.uiReticleCoarseStage.uiX.getValCal('mm'), ...
                        %         dVal ...
                        %     );
                        %     this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                        % end
                
                    case 4
                        lReady = abs(this.uiReticleCoarseStage.uiY.getValCal('mm') - dVal) <= 0.001;
                        lOut = lOut && lReady;
                end
            end
           
        end


        function scanAcquire(this, outputIdx, stateList, u8ScanAxisIdx, lUseDeltas, cAxisNames)
           
        end

        function lAcquisitionFinished = scanIsAcquired(this, stState, outputIdx)
            lAcquisitionFinished = true;

            nAve = 1;
            dSum = 0;
            switch outputIdx
                case 1
                    for k = 1:nAve
                        dSum = dSum + this.getDTChannelVal(41);
                    end
                    dAcquiredValue = dSum/nAve;
                case 2
                    for k = 1:nAve
                        dSum = dSum + this.getDTChannelVal(42);
                    end
                    dAcquiredValue = dSum/nAve;
                case 3
                    for k = 1:nAve
                        dSum = dSum + this.getDTChannelVal(35);
                    end
                    dAcquiredValue = dSum/nAve;
                case 4 % Reticle diode
                    dAcquiredValue = this.hardware.getKeithley6482Reticle().read(1);
                case 5 % Subframe diode
                    dAcquiredValue = this.hardware.getKeithley6482Reticle().read(2);    
                case 6 % Subframe diode % 06.28.24 hacking this to read wafer diode instead of SF
                    dAcquiredValue = this.hardware.getKeithley6482Wafer().read(2);                   
            end
            
            this.handleUpdateScanOutput(stState, dAcquiredValue)
        end

        function handleUpdateScanSetup(this, ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames, ceScanRanges)

            dInitialState = this.getInitialState(u8ScanAxisIdx);
            % If using deltas, modify state to center around current
            % values:

            for m = 1:length(u8ScanAxisIdx)
                for k = 1:length(ceScanStates)
                    if lUseDeltas(m)
                        ceScanStates{k}.values(m) = ceScanStates{k}.values(m) + dInitialState.values(m);
                        
                    end
                end
                
                for k = 1:length(ceScanRanges{m})
                    if lUseDeltas(m)
                        ceScanRanges{m}(k) = ceScanRanges{m}(k) + dInitialState.values(m);
                    end
                end
                
                
            end


            this.ceScanRanges = ceScanRanges;



            switch length(ceScanRanges)
                case 1
                    this.dImg = zeros(size(ceScanRanges{1}));
                    plot(this.haScanAxis, ceScanRanges{1}, zeros(size(ceScanRanges{1})), 'b-');

                case 2
                    this.dImg = zeros(length(ceScanRanges{2}), length(ceScanRanges{1}));
                    imagesc(this.haScanAxis, ceScanRanges{1}, ceScanRanges{2}, this.dImg);
  
            end
        end

        function handleUpdateScanOutput(this, stState, dAcquiredValue)
            u8Idx = this.scanHandler.getCurrentStateIndex();
            
            if u8Idx == 0
                this.dImg = zeros(size(this.dImg));
            end
            switch length(stState.axes)
                case 1
                    this.dImg(u8Idx) = dAcquiredValue;
                    plot(this.haScanAxis, this.ceScanRanges{1}, this.dImg, 'b-');

                case 2
                    this.dImg(u8Idx) = dAcquiredValue;
                    imagesc(this.haScanAxis, this.ceScanRanges{1}, this.ceScanRanges{2}, this.dImg);
                    set(this.haScanAxis, 'YDir', 'normal')
                    colorbar
            end
        end


        function saveScan(this)
            1
            
        end

        
        function ce = getCommandToggleParams(this) 
             
             ce = {...
                'cTextTrue', 'Turn Off', ...
                'cTextFalse', 'Turn On' ...
            };

         end
          
        
    end
    
    
end

