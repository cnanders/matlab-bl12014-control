classdef WaferTTZClosedLoop < mic.Base
    
    properties (Constant)
        dFINE_Z_HIGH_LIMIT = 10000;
        dFINE_Z_LOW_LIMIT = 0;
    end
    
     
    properties
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiTiltX
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiTiltY
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiCoarseZ
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiFineZ  
        
        % {bl12014.ui.HeightSensorLeds 1x1}
        uiHeightSensorLEDs
        
        uibLevel
        hLevelScan
        dLevelScanPeriod = 0.5
        cWaferLevelConfig = 'Wafer-CLTTZ-leveler-coordinates.json'
        stConfigDat
        hProgress
        
        uiSequenceLevelWafer
        uiStateHeightSensorLEDsOn
        
        uiCLTiltX
        uiCLTiltY
        uiCLZ
            
        dTiltXTol = 3; %urad
        dTiltYTol = 3; %urad
        dZTol  = 4; %nm
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 625
        dHeight = 175 
        dWidthStores = 150
        cName = 'wafer-coarse-stage-ttz-closed-loop'
        lShowRange = false
        lShowStores = true
        
        commDeltaTauPowerPmac
        
        commMfDriftMonitorMiddleware
        
        
        % These values go into the
        % bl12014.device.GetSetNumberClosedLoopHeightSensor instances

        % This one is the delay between calling the isReady() method of the
        % controled hardware to see if the hardware has reached the
        % destination. Once it reaches the destination, it calls the
        % sensor.get() method after a delay of dDelay
        
        dStageCheckPeriodZ = 0.1
        dStageCheckPeriodTiltX = 0.1
        dStageCheckPeriodTiltY = 0.1
        
        % No reason for delay here that I can think of since we call the height sensor
        % hardware as sensor.get()
        dDelayZ = 0
        dDelayTiltX = 0
        dDelayTiltY = 0
        
    end
    
    properties (Access = private)
        
        clock
        uiClock
        
        hPanel
        
        dWidthName = 70
        
        % {bl12014.Hardware 1x1}
        hardware
    
        
    end
    
    methods
        
        function this = WaferTTZClosedLoop(varargin)
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
        
        end
        
        
        % DEPRECATED 1/31/19
        function lVal = isLeveled(this)
            
            lVal =  abs(this.stConfigDat.tiltX.value - this.uiCLTiltX.getValCal(this.stConfigDat.tiltX.unit)) <= ...
                        this.stConfigDat.tiltX.displayTol && ...
                    abs(this.stConfigDat.tiltY.value - this.uiCLTiltY.getValCal(this.stConfigDat.tiltY.unit)) <= ...
                        this.stConfigDat.tiltY.displayTol && ...
                    abs(this.stConfigDat.Z.value - this.uiCLZ.getValCal(this.stConfigDat.Z.unit)) <= ...
                    this.stConfigDat.Z.displayTol;
        end
         % DEPRECATED 1/31/19
        function lVal = isMissing(this)
            lVal = abs(this.uiCLTiltX.getValCal(this.stConfigDat.tiltX.unit)) >= 887000 ||...
                    abs(this.uiCLTiltY.getValCal(this.stConfigDat.tiltY.unit)) >= 887000;
            
        end
         % DEPRECATED 1/31/19
        function lVal = isDriftMonitorOff(this)
            % as a proxy, we'll detect if the values are zero:
            lVal = this.uiCLTiltX.getValCal('urad') == 0 && ...
                    this.uiCLTiltY.getValCal('urad') == 0 && ...
                    this.uiCLZ.getValCal('nm') == 0;
        end
         % DEPRECATED 1/31/19
        function updateButtonColor(this)
            if (this.isLeveled())
                this.uibLevel.setColor([.85, 1, .85]);
                this.uibLevel.setText('Wafer is level');
            elseif this.isMissing()
                this.uibLevel.setColor([1, 1, .85]);
                this.uibLevel.setText('No Wafer!');
            elseif this.isDriftMonitorOff()
                this.uibLevel.setColor([1, 1, .85]);
                this.uibLevel.setText('Level Wafer');
            else
                
                this.uibLevel.setColor([1, .85, .85]);
                this.uibLevel.setText('Level Wafer');
            end
            
        end
         % DEPRECATED 1/31/19
        function onLevel(this)
            
            if this.isMissing()
                msgbox('Not leveling wafer because no wafer is detected');
                return
            end
            
            if this.isDriftMonitorOff()
                msgbox('Turn on MFDriftMonitor before leveling wafer');
                return
            end
            
            this.hProgress = waitbar(0, 'Wafer is leveling, please wait...');
            
            % Set up scanner
            fhSetState      = @(~, stState) stState.action();
            fhIsAtState     = @(~, stState) stState.isReady();
            fhAcquire       = @(~, stState) waitbar((stState.idx)/3, this.hProgress);
            fhIsAcquired    = @(~, stState) true;
            fhOnComplete    = @(~, stState) delete(this.hProgress);
            fhOnAbort       = @(~, stState) delete(this.hProgress);
            
            stateList = { ...
                struct('idx', 1, 'action', @()this.setUIFromStoreandGo(this.uiCLTiltX, 'tiltX'), 'isReady', @()this.uiCLTiltX.isReady()), ...
                struct('idx', 2, 'action', @()this.setUIFromStoreandGo(this.uiCLTiltY, 'tiltY'), 'isReady', @()this.uiCLTiltY.isReady()), ...
                struct('idx', 3, 'action', @()this.setUIFromStoreandGo(this.uiCLZ, 'Z'), 'isReady', @()this.uiCLZ.isReady())...
                ...
            };
        
            stRecipe = struct;
            stRecipe.values = stateList; % enumerable list of states that can be read by setState
            stRecipe.unit = struct('unit', 'unit'); % not sure if we need units really, but let's fix later
            
            this.hLevelScan = mic.Scan(this.cName, ...
                                        this.clock, ...
                                        stRecipe, ...
                                        fhSetState, ...
                                        fhIsAtState, ...
                                        fhAcquire, ...
                                        fhIsAcquired, ...
                                        fhOnComplete, ...
                                        fhOnAbort, ...
                                        this.dLevelScanPeriod...
                                        );
            this.hLevelScan.start();
        end
         % DEPRECATED 1/31/19
        function setUIFromStoreandGo(this, ui, cAxisName)
            % Load values from config store:
            dVal = this.stConfigDat.(cAxisName).value;
            cUnit = this.stConfigDat.(cAxisName).unit;
            
            this.setDestAndGo(ui, dVal);            
        end
        
        
        % Need to construct req function handles for GSNFromCLC device
        % implementations: fhGetSensor, fhGetMotor, fhSetMotor,
        % fhIsReadyMotor, dTolearnce
        function device = createCLZdevice(this)
            
            mm2nm           = 1e6;
            
            fhIsReadyMotor  = @() this.uiCoarseZ.isReady() & this.uiFineZ.isReady();
            dTolerance      = this.dZTol;
           
            fhGetSensor     = @() this.hardware.getMfDriftMonitorMiddleware().getSimpleZ();
            fhIsSensorValid = @() this.hardware.getMfDriftMonitorMiddleware().areHSValid();
            fhGetMotor      = @() this.uiFineZ.getValCal('nm');
            fhSetMotor      = @(dMotorDest) this.closedLoopZSet(dMotorDest);
            
            
            device = mic.device.GetSetNumberFromClosedLoopControl(...
                this.uiClock, ...
                fhGetSensor, ...
                fhGetMotor, ...
                fhSetMotor, ...
                fhIsReadyMotor, ...
                dTolerance, ...
                'cName', 'device-closed-loop-z',...
                'dDelay', this.dDelayZ, ...
                'dStageCheckPeriod', this.dStageCheckPeriodZ, ...
                'fhIsSensorValid', fhIsSensorValid ...
            ); % CA decreasing delay from 0.2 to 0.11
        end
        
        
        function closedLoopZSet(this, dMotorDest)
            
            % Need to check if fine z requested move is in range.  If not,
            % compute a coarse Z correction to put fine stage back in
            % center of range.
            dCoarseZCorrection = 0;
            
            nm2mm = 1e-6;
            dCENTER_RANGE = (this.dFINE_Z_HIGH_LIMIT + this.dFINE_Z_LOW_LIMIT)/2;
            
            % If we need a coarse correction, set coarse stage, otherwise
            % set fine stage
            if  dMotorDest >= this.dFINE_Z_HIGH_LIMIT || dMotorDest <= this.dFINE_Z_LOW_LIMIT
                
                % The amount we need to buffer for fine stage is:
                dBuffer = dCENTER_RANGE - this.uiFineZ.getValCalDisplay();
                

                % Since we added this to fine stage, must subtract from
                % coarse stage:
                dCoarseZCorrection = -dBuffer * nm2mm;
               
                % Next we need to make actua desired move, which is
                % difference between current fine value and the motor
                % destination:
                dCoarseZCorrection = dCoarseZCorrection + (dMotorDest - this.uiFineZ.getValCalDisplay()) * nm2mm;
                
                dCurrentCoarseZ = this.uiCoarseZ.getValCalDisplay();
                
                % Set Coarse and fine stages:
                this.setDestAndGo(this.uiCoarseZ, dCurrentCoarseZ + dCoarseZCorrection);
                this.setDestAndGo(this.uiFineZ, dCENTER_RANGE);
                
            else
                % Make a normal fine stage move:
                this.setDestAndGo(this.uiFineZ, dMotorDest);
            end
            
        end
        
        
        function dVal = getFreshHSValue(~, commDriftMonitor, u8idx)
            
            commDriftMonitor.forceUpdate();
            dVal = commDriftMonitor.getHSValue(u8idx); 
            
        end
        
        function device = createCLRxdevice(this)
            mrad2urad = 1e3;
            fhGetMotor      = @() this.uiTiltX.getValCal('urad'); % CNA 2019.02.01 can this be this.uiTiltX.getValCal('urad')?
            fhSetMotor      = @(dVal) this.setMotorTiltX(dVal);
            fhIsReadyMotor  = @() this.uiTiltX.isReady();
            fhIsSensorValid = @() this.hardware.getMfDriftMonitorMiddleware().areHSValid();

            dTolerance      = this.dTiltXTol;
            fhGetSensor             = @() this.hardware.getMfDriftMonitorMiddleware().getHSValue(1) * mrad2urad;
            fhGetSensorDuringMove   = @()this.getFreshHSValue(this.hardware.getMfDriftMonitorMiddleware(), 1) * mrad2urad;   
            
            device = bl12014.device.GetSetNumberClosedLoopHeightSensorTilt(...
                this.uiClock, ...
                fhGetSensor, ... % dont do force update which is computationally expensive
                fhGetSensorDuringMove, ... % during move
                fhGetMotor, ....
                fhSetMotor, ...
                fhIsReadyMotor, ...
                dTolerance,...
                'cName', 'device-closed-loop-rx', ...
                'dDelay', this.dDelayTiltX, ...
                'dStageCheckPeriod', this.dStageCheckPeriodTiltX, ...
                'fhIsSensorValid', fhIsSensorValid ...
            );
        end
        
        function setMotorTiltY(this, dVal)
            this.uiTiltY.setDestCalAndGo(dVal, 'urad')
        end
        
        function setMotorTiltX(this, dVal)
            this.uiTiltX.setDestCalAndGo(dVal, 'urad')
        end
        
        function device = createCLRydevice(this)
            mrad2urad = 1e3;
            
            %{
            deviceTiltYPPMAC = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, ...
                 bl12014.device.GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TILT);
            
            fhGetMotor      = @()deviceTiltYPPMAC.get();% CNA 2019.02.01 can this be this.uiTiltY.getValCal('urad')?
            fhSetMotor      = @(dVal) this.setDestAndGo(this.uiTiltY, dVal);
            fhIsReadyMotor  = @()this.isPPMACReady(deviceTiltYPPMAC, this.uiTiltY);
            dTolerance      = this.dTiltYTol;
            fhGetSensor     = @()this.getFreshHSValue(commDriftMonitor, 2) * mrad2urad; 
            %}
            
            
            fhGetMotor      = @() this.uiTiltY.getValCal('urad');% CNA 2019.02.01 can this be this.uiTiltY.getValCal('urad')?
            fhSetMotor      = @(dVal) this.setMotorTiltY(dVal);
            fhIsReadyMotor  = @() this.uiTiltY.isReady();
            fhIsSensorValid = @() this.hardware.getMfDriftMonitorMiddleware().areHSValid();

            dTolerance      = this.dTiltYTol;
            
            fhGetSensor             = @() this.hardware.getMfDriftMonitorMiddleware().getHSValue(2) * mrad2urad;
            fhGetSensorDuringMove   = @()this.getFreshHSValue(this.hardware.getMfDriftMonitorMiddleware(), 2) * mrad2urad;   
            
            % fhGetSensor     = @() this.getFreshHSValue(this.hardware.getMfDriftMonitorMiddleware(), 2) * mrad2urad; 
            
            device = bl12014.device.GetSetNumberClosedLoopHeightSensorTilt(...
                this.uiClock, ...
                fhGetSensor, ...
                fhGetSensorDuringMove, ...
                fhGetMotor, ...
                fhSetMotor, ...
                fhIsReadyMotor, ...
                dTolerance,...
                'cName', 'device-closed-loop-ry',...
                'dDelay', this.dDelayTiltY, ...
                'dStageCheckPeriod', this.dStageCheckPeriodTiltY, ...
                 'fhIsSensorValid', fhIsSensorValid ...
            );
        end 
        
        function lVal = isPPMACReady(this, commPPMAC, ui)
            cUnit = ui.getUnit().name;
            dError =  ui.getDestCal(cUnit)-  ui.getValCal(cUnit);
            this.msg(sprintf('Destination: %0.2f, Current position: %0.2f, Error: %0.2f\n', ui.getDestCal(cUnit), ui.getValCal(cUnit), dError),  this.u8_MSG_TYPE_SCAN);
            lVal = commPPMAC.isReady();
        end
        
        % Set lambda that edits UI destination before moving so that it
        % looks like it's controlling the UI.
        function setDestAndGo(~, ui, dVal)
            ui.setDestCalDisplay(dVal);
            ui.moveToDest();
        end
        
        function build(this, hParent, dLeft, dTop)
            
            cTitle = sprintf(...
                'Wafer Z,TiltX,TiltY Closed Loop Control: Z -> HS simple Z (%1.1f nm tol), [Rx,Ry] -> HS Calibrated tilt (%1.0f urad tol)', ...
                this.dZTol, ...
                this.dTiltXTol ...
            );
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', cTitle,...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;            

            dTop = 30;
            dLeft = 10;
            dSep = 26;
            

            this.uiStateHeightSensorLEDsOn.build(this.hPanel, dLeft, dTop, 450);
            dTop = dTop + dSep;
            
            this.uiSequenceLevelWafer.build(this.hPanel, dLeft, dTop, 450);
            dTop = dTop + dSep;
            dTop = dTop + 10;
            
            this.uiCLZ.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;

            this.uiCLTiltX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCLTiltY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
                        
%             this.uibLevel.build(this.hPanel, dLeft + 590, dTop, 80, 50);
            
            
            
           
            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end 
        
        function st = save(this)
            st = struct();
            st.uiCLZ = this.uiCLZ.save();
            st.uiCLTiltX = this.uiCLTiltX.save();
            st.uiCLTiltX = this.uiCLTiltX.save();
        end
        
        function load(this, st)
        end
        
        
    end
    
    methods (Access = private)
        
         function onFigureCloseRequest(this, src, evt)
            this.msg('WaferTTZClosedLoop.closeRequestFcn()');
            delete(this.hPanel);
         end
        
       
        
        function initUiZ(this)
            
        
         cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-fine-stage-z-cl.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            device  = this.createCLZdevice();
            
            this.uiCLZ = mic.ui.device.GetSetNumber(...
                'clock', this.uiClock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'dWidthStores', this.dWidthStores, ...
                'cName', sprintf('%s-z', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'fhGet', @device.get, ...
                'fhSet', @device.set, ...
                'fhIsReady', @device.isReady, ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'HS Simple Z' ...
            );
        
        
        end
        
        
        function initUiTiltX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-rx-hs-cl.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig, ...
                'dDelay', 1.5 ...
            );
        
            device = this.createCLRxdevice();
            
            this.uiCLTiltX = mic.ui.device.GetSetNumber(...
                'clock', this.uiClock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'dWidthStores', this.dWidthStores, ...
                'cName', sprintf('%s-tilt-x-cl', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'fhGet', @device.get, ...
                'fhSet', @device.set, ...
                'fhIsReady', @device.isReady, ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'HS Cal Rx' ...
            );
        end
        
        function initUiTiltY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-ry-hs-cl.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig, ...
                'dDelay', 1.5 ...
            );
        
            device = this.createCLRydevice();
            
            this.uiCLTiltY = mic.ui.device.GetSetNumber(...
                'clock', this.uiClock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'dWidthStores', this.dWidthStores, ...
                'cName', sprintf('%s-tilt-y-cl', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'fhGet', @device.get, ...
                'fhSet', @device.set, ...
                'fhIsReady', @device.isReady, ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'HS Cal Ry' ...
            );
        end
        
        
        
        function init(this)
            this.msg('init()');
            
            cDirThis = fileparts(mfilename('fullpath'));

            % Init config
            cPath = fullfile(cDirThis, '..', '..', 'config', this.cWaferLevelConfig);
            % this.stConfigDat = loadjson(cPath);
            
            fid = fopen(cPath, 'r');
            cText = fread(fid, inf, 'uint8=>char');
            fclose(fid);
            this.stConfigDat = jsondecode(cText');
            
            
            % Init button:
            cText = sprintf('Level Wafer (%1.1f, %1.1f, %1.1f)', ...
                this.stConfigDat.tiltX.value, ...
                this.stConfigDat.tiltY.value, ...
                this.stConfigDat.Z.value ...
            );
            this.uibLevel = mic.ui.common.Button('fhDirectCallback', @(~, ~)this.onLevel(), 'cText', cText);
            
            
            
            this.initUiZ();
            this.initUiTiltX();
            this.initUiTiltY();
            this.initUiHeightSensorLeds();
            
            
            this.uiSequenceLevelWafer = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-level-wafer'], ...
                'task', bl12014.Tasks.createSequenceLevelWafer(...
                    [this.cName, 'task-sequence-level-wafer'], ...
                    this, ...
                    ...this.uiHeightSensorLEDs, ...
                    this.clock ...
                 ), ...
                'clock', this.uiClock ...
            );
        
            this.uiStateHeightSensorLEDsOn = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-height-sensor-leds-on'], ...
                'task', bl12014.Tasks.createStateHeightSensorLEDsOn(...
                    [this.cName, 'state-height-sensor-leds-on'], ...
                    this.uiHeightSensorLEDs, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
            
%             this.uiClock.add(@()this.updateButtonColor(), this.id(), 1);
             
        end
        
        function initUiHeightSensorLeds(this)
            
            
            % Height Sensor LEDS for easy turnon before level if needed
            this.uiHeightSensorLEDs = bl12014.ui.HeightSensorLEDs(...
                'cName', [this.cName, 'height-sensor-leds'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        end
        
                    
        
        
    end
    
    
end

