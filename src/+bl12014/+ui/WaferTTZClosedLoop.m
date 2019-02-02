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
        
        
        uibLevel
        hLevelScan
        dLevelScanPeriod = 0.5
        cWaferLevelConfig = 'Wafer-CLTTZ-leveler-coordinates.json'
        stConfigDat
        hProgress
        
        uiSequenceLevelWafer
        
        uiCLTiltX
        uiCLTiltY
        uiCLZ
            
        dTiltXTol = 3; %urad
        dTiltYTol = 3; %urad
        dZTol  = 4; %nm
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 850
        dHeight = 95       
        cName = 'wafer-coarse-stage-ttz-closed-loop'
        lShowRange = false
        lShowStores = true
        
        commDeltaTauPowerPmac
        
        commMfDriftMonitorMiddleware
        
    end
    
    properties (Access = private)
        
        clock
        uiClock
        
        hPanel
        
        dWidthName = 70
    
        
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
        
        function device = createCLZdevice(this, commPPMAC, commDriftMonitor)
            mm2nm           = 1e6;
            
            
            % Leverage existing PPMAC device implementation for isReady,
            % possibly could use the UIs for this too, 
            deviceCoarseZ = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, ...
                 bl12014.device.GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_Z);
            deviceFineZ = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, ...
                 bl12014.device.GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_FINE_Z);
            
            
            fhIsReadyMotor  = @() deviceCoarseZ.isReady() & deviceFineZ.isReady();
            dTolerance      = this.dZTol;
           
            fhGetSensor     = @()commDriftMonitor.getSimpleZ();
            fhGetMotor      = @()deviceFineZ.get() * mm2nm;
            fhSetMotor      = @(dMotorDest) this.closedLoopZSet(dMotorDest);
            
            
            device = mic.device.GetSetNumberFromClosedLoopControl(...
                this.uiClock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance, ...
                'cName', 'device-closed-loop-z',...
                'dDelay', 0.2);
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
        
        function device = createCLRxdevice(this,  commPPMAC, commDriftMonitor)
            mrad2urad = 1e3;
            
            deviceTiltXPPMAC = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, ...
                 bl12014.device.GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TIP);
            
            fhGetMotor      = @()deviceTiltXPPMAC.get(); % CNA 2019.02.01 can this be this.uiTiltX.getValCal('urad')?
            fhSetMotor      = @(dVal) this.setDestAndGo(this.uiTiltX, dVal);
            fhIsReadyMotor  = @()this.isPPMACReady(deviceTiltXPPMAC, this.uiTiltX);
            dTolerance      = this.dTiltXTol;
            fhGetSensor     = @()this.getFreshHSValue(commDriftMonitor, 1) * mrad2urad;   
            
            
            device = mic.device.GetSetNumberFromClosedLoopControl(...
                this.uiClock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance,...
                'cName', 'device-closed-loop-rx', ...
                'dDelay', 0.5);
        end
        
        function device = createCLRydevice(this,  commPPMAC, commDriftMonitor)
            mrad2urad = 1e3;
            
            deviceTiltYPPMAC = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, ...
                 bl12014.device.GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TILT);
            
            fhGetMotor      = @()deviceTiltYPPMAC.get();% CNA 2019.02.01 can this be this.uiTiltY.getValCal('urad')?
            fhSetMotor      = @(dVal) this.setDestAndGo(this.uiTiltY, dVal);
            fhIsReadyMotor  = @()this.isPPMACReady(deviceTiltYPPMAC, this.uiTiltY);
            dTolerance      = this.dTiltYTol;
            fhGetSensor     = @()this.getFreshHSValue(commDriftMonitor, 2) * mrad2urad; 
            
            
            device = mic.device.GetSetNumberFromClosedLoopControl(...
                this.uiClock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance,...
                'cName', 'device-closed-loop-ry',...
                'dDelay', 0.5);
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
        
        
        function connect(this, commPPMAC, commDriftMonitor)

            % Represent devices implementations from Closed loop control
            deviceCLZ  = this.createCLZdevice(commPPMAC, commDriftMonitor);
            deviceCLRx = this.createCLRxdevice(commPPMAC, commDriftMonitor);
            deviceCLRy = this.createCLRydevice(commPPMAC, commDriftMonitor);
            
            % Set Devices
            this.uiCLZ.setDevice(deviceCLZ);
            this.uiCLTiltX.setDevice(deviceCLRx);
            this.uiCLTiltY.setDevice(deviceCLRy);
            
            % Turn on
            this.uiCLZ.turnOn();
            this.uiCLTiltX.turnOn();
            this.uiCLTiltY.turnOn();
            
            
%             this.uiCLZ.syncDestination();
%             this.uiCLTiltX.syncDestination();
%             this.uiCLTiltY.syncDestination();
            
        end
        
        
        function disconnect(this)
            
            this.uiCLZ.turnOff();
            this.uiCLTiltX.turnOff();
            this.uiCLTiltY.turnOff();
                        
            this.uiCLZ.setDevice([]);
            this.uiCLTiltX.setDevice([]);
            this.uiCLTiltY.setDevice([]);

            
        end

        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wafer Z/T/T Closed Loop Control: Z -> HS simple Z (4 nm tol), [Rx,Ry] -> HS Calibrated tilt (3 urad tol)',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;            

            dTop = 20;
            dLeft = 10;
            dSep = 24;
            

            
            this.uiCLZ.build(this.hPanel, dLeft, dTop);
%             this.uibLevel.build(this.hPanel, dLeft + 590, dTop, 80, 50);
            
            this.uiSequenceLevelWafer.build(this.hPanel, dLeft + 590, dTop, 225);

            
            dTop = dTop + dSep;
            
            
            
            this.uiCLTiltX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCLTiltY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
           
            
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
            
            this.uiCLZ = mic.ui.device.GetSetNumber(...
                'clock', this.uiClock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-z', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
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
                'cPath',  cPathConfig ...
            );
            
            this.uiCLTiltX = mic.ui.device.GetSetNumber(...
                'clock', this.uiClock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-tilt-x-cl', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
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
                'cPath',  cPathConfig ...
            );
            
            this.uiCLTiltY = mic.ui.device.GetSetNumber(...
                'clock', this.uiClock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-tilt-y-cl', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'cLabel', 'HS Cal Rx' ...
            );
        end
        
        
        
        function init(this)
            this.msg('init()');
            
            cDirThis = fileparts(mfilename('fullpath'));
            
            
           

            % Init config
            this.stConfigDat = loadjson(fullfile(cDirThis, '..', '..', 'config', this.cWaferLevelConfig));
            
            % Init button:
            this.uibLevel = mic.ui.common.Button('fhDirectCallback', @(~, ~)this.onLevel(), 'cText', 'Level Wafer');
            
            
            
            this.initUiZ();
            this.initUiTiltX();
            this.initUiTiltY();
            
            this.uiSequenceLevelWafer = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-level-wafer'], ...
                'task', bl12014.Tasks.createSequenceLevelWafer(...
                    [this.cName, 'task-sequence-level-wafer'], ...
                    this.uiCLTiltX, ...
                    this.uiCLTiltY, ...
                    this.uiCLZ, ...
                    this.stConfigDat, ...
                    this.clock ...
                 ), ...
                'clock', this.uiClock ...
            );
            
            this.uiClock.add(@()this.updateButtonColor(), this.id(), 1);
             
        end
        
        
        
    end
    
    
end

