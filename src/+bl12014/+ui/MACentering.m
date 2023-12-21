classdef MACentering < mic.Base
    
    properties (Constant)
        scanOutputs =  {'DT-36', 'DT-37', 'MDM'}
        
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

        % axes
        haScanAxis
        ceScanRanges

        dImg = zeros(50)
        dXAxis
        dYAxis

        uiDTVoltage36
        uiDTVoltage37


        cScanLogDir
        
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

            this.uiMDMCurrent.build(hParent, dLeft + 720, 340);


            this.uiDTVoltage36.build(hParent, dLeft + 860, 550);
            this.uiDTVoltage37.build(hParent, dLeft + 860, 610);

            
            dTop = 10;

             % Scans:
             this.ss1D.build(hParent, dLeft, dTop, 850, 210); 
             dTop = dTop + 230;
             this.ss2D.build(hParent, dLeft, dTop, 850, 210);

             this.haScanAxis = axes(...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Position', [dLeft + 1270, 390, 500, 500] ...
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


            this.uiDTVoltage36 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', [this.cName, 'CHannel 36 Volts'], ... 
                'config', mic.config.GetSetNumber(...
                            'cPath',  fullfile(...
                                bl12014.Utils.pathUiConfig(), ...
                                'get-number', ...
                                'config-volts.json' ...
                            ) ...
                         ), ...
                'cLabel', 'DT-36', ...
                'dWidthPadUnit', 277, ...
                'lShowInitButton', true, ...
                'lShowLabels', false, ...
                'fhGet', @() this.hardware.getDataTranslation().getScanDataOfChannel(36), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true ...
            );

            this.uiDTVoltage37 = mic.ui.device.GetNumber(...
            'clock', this.clock, ...
            'cName', [this.cName, 'DT 37 Volts'], ... 
            'config', mic.config.GetSetNumber(...
                        'cPath',  fullfile(...
                            bl12014.Utils.pathUiConfig(), ...
                            'get-number', ...
                            'config-volts.json' ...
                        ) ...
                     ), ...
            'cLabel', 'DT-37', ...
            'dWidthPadUnit', 277, ...
            'lShowInitButton', true, ...
            'lShowLabels', false, ...
            'fhGet', @() this.hardware.getDataTranslation().getScanDataOfChannel(36), ...
            'fhIsVirtual', @() false, ...
            'lUseFunctionCallbacks', true ...
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
                'ceScanAxisLabels', {'DC X', 'DC Y'}, ...
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
                'ceScanAxisLabels', {'DC X', 'DC Y'}, ...
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
        
        function stopScan(this)
            this.lIsScanning = false;
            this.scanHandler.stop();
        end

        function onScanAbort(this, dInitialState, fhSetState, fhIsAtState)
            this.lIsScanning = false;
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
%             this.setupScanOutput(stateList, u8ScanAxisIdx)
            this.lIsScanning = true;
            this.scanHandler.start();
        end

        function dInitialState = getInitialState(this, u8ScanAxisIdx)
            % grab initial state of values:
           dInitialState = struct;
           dInitialState.values = [];
           dInitialState.axes = u8ScanAxisIdx;
        end
        
        function onScanComplete(this, dInitialState, fhSetState)
            this.lIsScanning = false;
            
            % Save data:
            st.ceScanRanges = this.ceScanRanges;
            st.dImg = this.dImg;

            save(fullfile(this.cScanLogDir, [datestr(now, 'yyyy-mm-dd-HH-MM-SS'), '.mat']), 'st');
            fprintf('Saved scan data to %s\n', fullfile(this.cScanLogDir, [datestr(now, 'yyyy-mm-dd-HH-MM-SS'), '.mat']));
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
                end
            end

            this.uiScanner.uiNPointLC400.setWritingIllum(true)
            this.uiScanner.uiNPointLC400.executePupilFillWriteSequence();
        end

        function lOut = areScanAxisDevicesAtState(this, stState)
            dAxes = stState.axes;
            dVals = stState.values;
            

            lOut = ~this.uiScanner.uiNPointLC400.isExecutingPupilFillSequence();

            % fprintf('Scan at state: %d\n', lOut);
        end


        function scanAcquire(this, outputIdx, stateList, u8ScanAxisIdx, lUseDeltas, cAxisNames)
           
        end

        function lAcquisitionFinished = scanIsAcquired(this, stState, outputIdx)
            lAcquisitionFinished = true;

            switch outputIdx
                case 1
                    dAcquiredValue = this.uiDTVoltage36.getValCalDisplay();
                case 2
                    dAcquiredValue = this.uiDTVoltage37.getValCalDisplay();
                case 3
                    dAcquiredValue = this.uiMDMCurrent.uiCurrent.getValRaw();
            end
            
            this.handleUpdateScanOutput(stState, dAcquiredValue)
        end

        function handleUpdateScanSetup(this, ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames, ceScanRanges)

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



        
        function ce = getCommandToggleParams(this) 
             
             ce = {...
                'cTextTrue', 'Turn Off', ...
                'cTextFalse', 'Turn On' ...
            };

         end
          
        
    end
    
    
end

