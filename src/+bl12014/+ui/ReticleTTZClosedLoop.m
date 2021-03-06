classdef ReticleTTZClosedLoop < mic.Base
    
    properties (Constant)
    end
    
     
    properties
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiTiltX
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiTiltY
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiCoarseZ
        
        uiCapSensors
        
        uibLevel
        hLevelScan
        dLevelScanPeriod = 0.5
        cReticleLevelConfig = 'Reticle-CLTTZ-leveler-coordinates.json'
        stConfigDat
        hProgress
       
        uiSequenceLevelReticle
        
        uiCLTiltX
        uiCLTiltY
        uiCLZ
            
        dTiltXTol = 3; %urad
        dTiltYTol = 3; %urad
        dZTol  = 0.1; %um
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 575
        dWidthStores = 100;
        dHeight = 150        
        cName = 'reticle-coarse-stage-ttz-closed-loop'
        lShowRange = false
        lShowStores = true
        
 
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
        
        function this = ReticleTTZClosedLoop(varargin)
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
            lVal = this.uiCapSensors.uiCap3.getValCal('V') < -9.99 || ...
                this.uiCapSensors.uiCap2.getValCal('V') < -9.99 ;
            
         
            
        end
        % DEPRECATED 1/31/19
        function updateButtonColor(this)
            if (this.isLeveled())
                this.uibLevel.setColor([.85, 1, .85]);
                this.uibLevel.setText('Reticle is level');
            elseif this.isMissing()
                this.uibLevel.setColor([1, 1, .85]);
                this.uibLevel.setText('Reticle pos invalid');
            else 
                this.uibLevel.setColor([1, .85, .85]);
                this.uibLevel.setText('Level Reticle');
            end
            
        end
        % DEPRECATED 1/31/19
         function onLevel(this)
             
            if this.isMissing()
                msgbox('Not leveling reticle because reticle is not in cap sensor range');
                return
            end
            
            this.hProgress = waitbar(0, 'Reticle is leveling, please wait...');
            
            % Set up scanner
            fhSetState      = @(~, stState) stState.action();
            fhIsAtState     = @(~, stState) stState.isReady();
            fhAcquire       = @(~, stState) waitbar((stState.idx)/3, this.hProgress);
            fhIsAcquired    = @(~, stState) true;
            fhOnComplete    = @(~, stState) delete(this.hProgress);
            fhOnAbort       = @(~, stState) [];
            
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
            
            this.setDestAndGo(ui, dVal, cUnit);            
        end
        
        
        
        % Need to construct req function handles for GSNFromCLC device
        % implementations: fhGetSensor, fhGetMotor, fhSetMotor,
        % fhIsReadyMotor, dTolearnce
        
        function dVal = getCapSensorRxRyZ(this, idx)
            [dTiltX, dTiltY, dZ] = this.uiCapSensors.getTiltXAndTiltYAndZ();
            switch(idx)
                case 1
                    dVal = dZ;
                case 2
                    dVal = dTiltX * pi / 180 * 1e6;
                case 3 
                    dVal = dTiltY * pi / 180 * 1e6;
            end
        end
        
        function device = createCLZdevice(this)
            mm2um           = 1e3;
            
            % Leverage existing PPMAC device implementation for isReady,
            % possibly could use the UIs for this too, 
            %{
            deviceCoarseZ = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, ...
                 bl12014.device.GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_Z);
              
            fhIsReadyMotor  = @() deviceCoarseZ.isReady();
            dTolerance      = this.dZTol;
           
            fhGetSensor     = @()this.getCapSensorRxRyZ(1);
            fhGetMotor      = @()this.uiCoarseZ.getValCal('um');
            fhSetMotor      = @(dMotorDest)  this.setDestAndGo(this.uiCoarseZ, dMotorDest, 'um');
            %}
            
            
            % CA 2019.02.01
            fhGetMotor      = @() this.uiCoarseZ.getValCal('um');
            fhSetMotor      = @(dVal) this.uiCoarseZ.setDestCalAndGo(dVal, 'um');
            fhIsReadyMotor  = @() this.uiCoarseZ.isReady();
            dTolerance      = this.dZTol;
            fhGetSensor     = @() this.getCapSensorRxRyZ(1);
            
            device = mic.device.GetSetNumberFromClosedLoopControl(...
                this.uiClock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance, ...
                'cName', 'reticle-closed-loop-z',...
                'dDelay', 1, ...
                'dPID', [-1, 0, 0]);
        end
        
        
        function device = createCLRxdevice(this)
            
            %{
            deviceTiltXPPMAC = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, ...
                 bl12014.device.GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_TIP);
            
            fhGetMotor      = @()deviceTiltXPPMAC.get();
            fhSetMotor      = @(dVal) this.setDestAndGo(this.uiTiltX, dVal, 'urad');
            fhIsReadyMotor  = @()deviceTiltXPPMAC.isReady();
            dTolerance      = this.dTiltXTol;
            fhGetSensor     = @()this.getCapSensorRxRyZ(2);
            %}
            
            % CA 2019.02.01
            fhGetMotor      = @() this.uiTiltX.getValCal('urad');
            fhSetMotor      = @(dVal) this.uiTiltX.setDestCalAndGo( dVal, 'urad');
            fhIsReadyMotor  = @() this.uiTiltX.isReady();
            dTolerance      = this.dTiltXTol;
            fhGetSensor     = @()this.getCapSensorRxRyZ(2);
            
            
            device = mic.device.GetSetNumberFromClosedLoopControl(...
                this.uiClock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance,...
                'cName', 'device-closed-loop-rx', ...
                'dDelay', 0.5,...
                'dPID', [1, 0, 0]);
        end
        
        function device = createCLRydevice(this)
            
            %{
            deviceTiltYPPMAC = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, ...
                 bl12014.device.GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_TILT);
            
            fhGetMotor      = @() deviceTiltYPPMAC.get();
            fhSetMotor      = @(dVal) this.setDestAndGo(this.uiTiltY, dVal, 'urad');
            fhIsReadyMotor  = @()deviceTiltYPPMAC.isReady();
            dTolerance      = this.dTiltYTol;
            fhGetSensor     = @()this.getCapSensorRxRyZ(3);
            %}
            
            % CA 2019.02.01
            fhGetMotor      = @() this.uiTiltY.getValCal('urad');
            fhSetMotor      = @(dVal) this.uiTiltY.setDestCalAndGo(dVal, 'urad');
            fhIsReadyMotor  = @() this.uiTiltY.isReady();
            dTolerance      = this.dTiltYTol;
            fhGetSensor     = @() this.getCapSensorRxRyZ(3);
            
            
            device = mic.device.GetSetNumberFromClosedLoopControl(...
                this.uiClock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance,...
                'cName', 'device-closed-loop-ry',...
                'dDelay', 0.5,...
                'dPID', [-1, 0, 0]);
        end
        
        % Set lambda that edits UI destination before moving so that it
        % looks like it's controlling the UI.
        function setDestAndGo(~, ui, dVal, unit)
            ui.setDestCal(dVal, unit);
            ui.moveToDest();
        end
        
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Reticle Z, TiltX, TiltY Cap Sensor Closed Loop',...
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
            
            % this.uibLevel.build(this.hPanel, dLeft + 590, dTop, 80, 50);
            this.uiSequenceLevelReticle.build(this.hPanel, dLeft, dTop, 300);
            dTop = dTop + dSep;
            dTop = dTop + 10;
            
            this.uiCLZ.build(this.hPanel, dLeft, dTop);
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
                'config-reticle-coarse-stage-z-cl.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            device = this.createCLZdevice();
            
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
                'cLabel', 'Cap Z' ...
            );
        
        
        end
        
        
        function initUiTiltX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-reticle-coarse-stage-tilt-x-cl.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
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
                'cLabel', 'Cap TiltX' ...
            );
        end
        
        function initUiTiltY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-reticle-coarse-stage-tilt-y-cl.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
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
                'cLabel', 'Cap TiltY' ...
            );
        end
        
        
        
        function init(this)
            this.msg('init()');
            
            cDirThis = fileparts(mfilename('fullpath'));
            
           


            % Init config
            cPath = fullfile(cDirThis, '..', '..', 'config', this.cReticleLevelConfig);
            % this.stConfigDat = loadjson(cPath);
            
            fid = fopen(cPath, 'r');
            cText = fread(fid, inf, 'uint8=>char');
            fclose(fid);
            this.stConfigDat = jsondecode(cText');
            
            % Init button:
            
            % Init button:
            
            %Deprecated
            this.uibLevel = mic.ui.common.Button('fhDirectCallback', @(~, ~)this.onLevel(), 'cText', 'Level Reticle');
            
%              this.uiClock.add(@()this.updateButtonColor(), this.id(), 1);
            
            this.initUiZ();
            this.initUiTiltX();
            this.initUiTiltY();
            
             this.uiSequenceLevelReticle = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-level-reticle'], ...
                'task', bl12014.Tasks.createSequenceLevelReticle(...
                    [this.cName, 'task-sequence-level-reticle'], ...
                    this, ...
                    this.clock ...
                 ), ...
                'clock', this.uiClock ...
            );
        end
        
        
        
    end
    
    
end

