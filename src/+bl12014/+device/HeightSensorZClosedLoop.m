classdef HeightSensorZClosedLoop < mic.interface.device.GetSetNumber
       
    
    properties (Constant)
        
        
    end
    
    properties (SetAccess = private)
        
        cName = 'device-height-sensor-z-closed-loop'
    end
    
    
    
    properties (Access = private)
        
        
        % {< mic.interface.device.GetSetNumber 1x1}
        zWafer
        zWaferCoarse
        
        % {< mic.interface.device.GetNumber 1x1}
        zHeightSensor
        
        % {mic.Clock 1x1}
        clock
                
        % {double 1x1} value passed into set() used during the iterative
        % march
        dSetGoal
        
        % {double 1x1} desired tolerance in nm
        dTolerance = 3; % Tolerance for a single Wafer Z move
        
        
        % Set this when each time wafer z changes target
        dCurrentZTarget_nm
        
        % {uint8 1x1 maximum number of moves of the wafer fine z}
        u8MovesMax = uint8(5);
        
        % Amount of time to wait for stage before timeout
        dStageWaitTime = 30 % seconds
        % Delay between successive polling of stage values
        dStageCheckPeriod = 0.1 %seconds
        
        % {logical 1x1} 
        lReady = true
        lIsCoarseCorrecting = false; % Waiting for deferred action scheduler to finish coarse move
        
        % {mic.Scan 1x1}
        scan
        
        % {double 1x1} number of samples to average when getting a value
        % from the Height Sensor drift monitor
%         u8SampleAverage = 50
%         u8SampleAverageDuringControl = 200;

        % (RM: 8/24) halving values to prevent feedback instability
        u8SampleAverage = 25
        u8SampleAverageDuringControl = 50;
        % {logical 1x1} set to true to debug the scan
        lDebugScan = true
        
        %UI handles for updating goals
        uiZCoarse   = []
        uiZFine     = []
    end
    
    methods
        
        function this = HeightSensorZClosedLoop(clock, zWafer, zWaferCoarse, zHeightSensor, uiZCoarse, uiZFine, varargin)
            

            this.clock = clock;
            this.zWafer = zWafer;
            this.zWaferCoarse = zWaferCoarse;
            this.zHeightSensor = zHeightSensor;
            
            this.uiZCoarse = uiZCoarse;
            this.uiZFine = uiZFine;
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end 
        end
        
        
        % @return {double 1x1} the value of the height sensor in nm
        function d = get(this)
            d = this.zHeightSensor.get();                        
        end
        
        function d = getAveraged(this)
            this.zHeightSensor.setSampleAverage(this.u8SampleAverageDuringControl);
            d = this.zHeightSensor.get();
            this.zHeightSensor.setSampleAverage(this.u8SampleAverage);
        end
        
        function l = isReady(this)
            l = this.lReady;
        end
        
        function stop(this)
            this.zWafer.stop();
            this.zWaferCoarse.stop();
            this.lReady = true;
        end
        
        function initialize(this)
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
        function set(this, dVal)
            this.lReady = false;
            mm2nm = 1e6;
            nm2mm = 1e-6;
            % RM going to redo this.  Turns out "pause" doesn't block
            % threads so we'll just use it to make this code synchronous:
            
            
            % Check if fine move is out of range
            dError                  = dVal - this.readHS();
            dZWaferNm               = this.zWafer.get() * mm2nm;
            dZWaferGoal             = (dZWaferNm + dError) * nm2mm;
            this.dCurrentZTarget_nm = dZWaferGoal * mm2nm;
            
            % If we need a coarse move, then do this first
            if (this.dCurrentZTarget_nm > 10000 || this.dCurrentZTarget_nm < 0)
                this.msg('Requires a coarse move\n', this.u8_MSG_TYPE_SCAN);

                dZErrorFrom5000     = dZWaferNm - 5000;
                dCoarseError        = dError + dZErrorFrom5000;
                dZWaferCoarse       = this.zWaferCoarse.get();
                dZWaferCoarseGoal   = (dZWaferCoarse * mm2nm + dCoarseError) * nm2mm;
                
%                 this.zWaferCoarse.set(dZWaferCoarseGoal);
                this.uiZCoarse.setDestCal(dZWaferCoarseGoal, 'mm');
                this.uiZCoarse.moveToDest();
                
                if (~this.waitForStage(this.zWaferCoarse))
                    this.msg('Z Coarse Stage timed out\n', this.u8_MSG_TYPE_SCAN);
                    this.lReady = true;
                    return
                end
                this.msg('Z Coarse Stage finished moving out\n', this.u8_MSG_TYPE_SCAN);
            end
            
            % Now move fine stage:
            for k = 1:this.u8MovesMax
                this.msg(sprintf('Making fine Z move on iteration %d\n', k), this.u8_MSG_TYPE_SCAN);
                dError                  = dVal - this.readHS();
                dZWaferNm               = this.zWafer.get() * mm2nm;
                
                dZWaferGoal             = (dZWaferNm + dError) * nm2mm;
                this.dCurrentZTarget_nm = dZWaferGoal * mm2nm;
                
%                 this.zWafer.set(dZWaferGoal);
                this.uiZFine.setDestCal(dZWaferGoal*mm2nm, 'nm');
                this.uiZFine.moveToDest();
                
                if (~this.waitForStage(this.zWafer))
                    this.msg('Z Fine Stage timed out\n', this.u8_MSG_TYPE_SCAN);
                    this.lReady = true;
                    return
                end
                % Recheck error:
                dError                  = dVal - this.readHS();
                this.msg(sprintf('\nClosed loop error is %0.1f nm\n', dError), this.u8_MSG_TYPE_SCAN);
                if (abs(dError) <= this.dTolerance)
                    this.msg('\n**** within tolerance\n', this.u8_MSG_TYPE_SCAN);
                    this.lReady = true;
                    return
                end
                this.msg('Z Fine Stage not within tolerance out\n', this.u8_MSG_TYPE_SCAN);
            end
            
            fprintf('Z fine closed loop failed\n');
            this.lReady = true;
        end
        
        % Waits for a stage to be ready
        % {mic.device 1x1} stage - stage that implements mic.device
        function lSuccess = waitForStage(this, stage)
            dNWaitCycles = this.dStageWaitTime / this.dStageCheckPeriod;
            for k = 1:dNWaitCycles
                if stage.isReady()
                    fprintf('**Stage is ready!!\n');
                    lSuccess = true;
                    return
                end
                fprintf('Stage is NOT ready\n');
                pause(this.dStageCheckPeriod);
            end
             lSuccess = true;
        end  
        
        % Reads height sensor after a short delay
        function dZHeightSensor = readHS(this)
            pause(this.u8SampleAverageDuringControl * 0.001);
            this.zHeightSensor.setSampleAverage(this.u8SampleAverageDuringControl);
            dZHeightSensor = this.zHeightSensor.get();
        end
        
%         
%         
%         % {double 1x1} dVal - desired reading of height sensor z in nm
%         function set_old(this, dVal)
%             
%             this.dSetGoal = dVal;
%             this.lReady = false;
%             
%             % Leverage the mic.Scan class to do a scan.  Values won't
%             % matter since they will be computed in each onSetState call
%                         
%             ceValues = cell(1, this.u8MovesMax);
%             for n = 1 : this.u8MovesMax
%                 ceValues{n} = struct('zWafer', 0);
%             end
%             
%             unit = struct(...
%                 'zWafer', 'nm', ...
%                 'zHeightSensor', 'nm' ...
%             );
%         
%             stRecipe = struct();
%             stRecipe.unit = unit;
%             stRecipe.values = ceValues;
%             
%             dPeriod = 2; 
%             
%             % Need enough time for ethernet to communicate w/ delta tau otherwise the scan will
%             % reach max number of steps and the move command to DeltaTau
%             % will hav enever reached the hardware
%             
%             this.scan = mic.Scan(...
%                 [this.cName, '-scan'], ...
%                 this.clock, ...
%                 stRecipe, ...
%                 @this.onScanSetState, ...
%                 @this.onScanIsAtState, ...
%                 @this.onScanAcquire, ...
%                 @this.onScanIsAcquired, ...
%                 @this.onScanComplete, ...
%                 @this.onScanAbort, ...
%                 dPeriod ...
%             );
% 
%         
%             if this.lDebugScan
%                 this.msg('---------------------------------------------------------', this.u8_MSG_TYPE_SCAN);
%                 cMsg = sprintf(...
%                     'set() starting new scan with check period of %1.0f ms', ...
%                     dPeriod * 1000 ...
%                 );
%                 this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
%             end
%             this.scan.start();
%             
%             
%         end
%         
        
    end
    
    methods (Access = private)
        
%         
%         % @param {struct} stUnit - the unit definition structure 
%         % @param {struct} stState - the state
%         function onScanSetState(this, stUnit, stValue)
%             
%             
%             if this.lIsCoarseCorrecting
%                 return
%             end
%             
%             if this.lDebugScan
%                 this.msg('onScanSetState()', this.u8_MSG_TYPE_SCAN);
%             end
%             
%             this.zHeightSensor.setSampleAverage(this.u8SampleAverageDuringControl);
%             
%             pause(0.3)
%             dZHeightSensor = this.zHeightSensor.get();
%             
%             dError = this.dSetGoal - dZHeightSensor;
%             this.zHeightSensor.setSampleAverage(this.u8SampleAverage);
%             
%             % Command the wafer to change value by to this position
%             if (abs(dError) < this.dTolerance)
%                 
%                 if this.lDebugScan || true
%                     cMsg = [...
%                         'onScanSetState() ', ...
%                         ' value is within tolerance calling scan.stop()', ...
%                         sprintf(' abs(error) = %1.3f nm', abs(dError)), ...
%                         sprintf(' < tolerance of %1.3f nm', this.dTolerance) ...
%                     ];
%                     fprintf(cMsg);
%                     this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
%                 end
%                 
%                this.stop(); % calls onScanAbort()
%             else
%                 
%                  if this.lDebugScan || true
%                     cMsg = [...
%                         'onScanSetState() ', ...
%                         ' value is NOT within tolerance', ...
%                         sprintf(' abs(error) = %1.3f nm', abs(dError)), ...
%                         sprintf(' < tolerance of %1.3f nm', this.dTolerance) ...
%                     ];
%                     fprintf(cMsg);
%                     this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
%                 end
%                 
%                
%                 
%  
%                 % The wafer z raw units are mm.  Need to convert to nm
%                 % then back to mm
%                 mm2nm = 1e6;
%                 nm2mm = 1e-6;
%                 dZWaferNm = this.zWafer.get() * mm2nm;
%                 
%                 dZWaferGoal = (dZWaferNm + dError) * nm2mm;
%                 this.dCurrentZTarget_nm = dZWaferGoal * mm2nm;
%                 
%                 if (this.dCurrentZTarget_nm > 10000 || ...
%                      this.dCurrentZTarget_nm < 0)
% %                 
% %                     cMsg = [...
% %                         sprintf('DID NOT REACH GOAL.\n\n') ...
% %                         sprintf('To achieve the target height sensor value of %1.3f nm,', this.dSetGoal), ...
% %                         sprintf(' wafer fine z needs to move to %1.1f nm,', dZWaferGoal * 1e6), ...
% %                         sprintf(' which is out of the allowed range of the wafer fine z stage.\n\n'), ...
% %                         sprintf('min allowed value of wafer fine z = 0 nm\n'), ...
% %                         sprintf('max allowed value of wafer fine z = 10000 nm\n\n'), ...
% %                         sprintf('Try moving wafer coarse z to bring the height sensor z closer to the target value and repeating.') ...
% %                     ];
% %                     msgbox( ...
% %                         cMsg, ...
% %                         'HeightSensorZClosedLoop Aborted.', ...
% %                         'error', ...
% %                         'modal' ...
% %                     );
% %                     this.scan.stop();
% %                     return;
% 
%  % RM 8/25/18: Going to hack in a coarse adjustment
%                         % here:
%                         
% %                         dFineHSDest     = dZWaferGoal;
% %                         dFineHSCurrent  = this.uiWafer.uiHeightSensorZClosedLoop.uiZHeightSensor.getValCalDisplay();
% %                         dFineZCurrent   = this.uiWafer.uiFineStage.uiZ.getValCalDisplay();
% %                         dFineZDest      = dFineZCurrent + (dFineHSDest - dFineHSCurrent);
% 
% 
%                     this.msg(...
%                         sprintf('Fine HS target value of %0.3f is out of range of fine z stage (requires move to %0.2f), using coarse adjustment\n',...
%                         this.dSetGoal, this.dCurrentZTarget_nm),...
%                         this.u8_MSG_TYPE_SCAN);
%                    
% 
%                     % Make a coarse z correction first before
%                     % making the fine z:
% 
%                     mm2nm = 1e6;
%                     nm2mm = 1e-6;
% 
%                     dZErrorFrom5000     = dZWaferNm - 5000;
%                     dCoarseError        = dError + dZErrorFrom5000;
%                     dZWaferCoarse       = this.zWaferCoarse.get();
%                     dZWaferCoarseGoal   = (dZWaferCoarse * mm2nm + dCoarseError) * nm2mm;
% 
%                     this.zWaferCoarse.set(dZWaferCoarseGoal);
%                     
%                     % Set up deferred action to recursively call this
%                     % method when coarse adjustment is finished
%                     fhCoarseTol  = @() abs(this.zWaferCoarse.get() - dZWaferCoarseGoal)*mm2nm < 50;
%                     this.lIsCoarseCorrecting = true;
%                      
%                     dafSetFineStage = mic.DeferredActionScheduler(...
%                         'clock', this.clock, ...
%                         'fhAction', @()this.handleCoarseZDAFComplete(),...
%                         'fhOnExpire', @()this.handleCoarseZDAFExpire(), ...
%                         'fhTrigger', fhCoarseTol,...
%                         'cName', 'ClosedLoopCoarseZ', ...
%                         'dDelay', 1, ...
%                         'dExpiration', 20, ...
%                         'lShowExpirationMessage', true);
%                     dafSetFineStage.dispatch();
%                     return
% 
%             
%                 end
%                     
%                 
%                 if this.lDebugScan
%                     
%                     cMsg = [...
%                         'onScanSetState() ', ...
%                         sprintf('hs goal = %1.1f nm ', this.dSetGoal) ...
%                     ];
%                     this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
%                     cMsg = [...
%                         'onScanSetState() ', ...
%                         sprintf('hs value with %1.0f sample avg = %1.1f nm', this.u8SampleAverageDuringControl, dZHeightSensor) ...
%                     ];
%                     this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
%                     
%                     cMsg = [...
%                         'onScanSetState()', ...
%                         sprintf(' hs error = %1.3f nm', dError), ...
%                         sprintf(' setting z wafer fine from %1.1f nm to %1.1f nm',  dZWaferNm, dZWaferGoal * 1e6) ...
%                     ];
%                     this.msg(cMsg, this.u8_MSG_TYPE_SCAN)
%                 end
%                 this.zWafer.set(dZWaferGoal);
%             end
%             
%             
%         end
%         
%         function handleCoarseZDAFComplete(this)
%             this.lIsCoarseCorrecting = false;
%         end
%         
%         function handleCoarseZDAFExpire(this)
% 
%                     this.msg('DAF expiring, coarse correction did not resolve, proceeding with fine\n', this.u8_MSG_TYPE_SCAN);
%             this.lIsCoarseCorrecting = false;
%         end
%         
%         
%         % @param {struct} stUnit - the unit definition structure 
%         % @param {struct} stState - the state
%         % @returns {logical} - true if the system is at the state
%         function l = onScanIsAtState(this, stUnit, stValue)
%             
%             % RM: isReady is always true.  We need to use info about the
%             % tolerance:
%             
%             mm2nm = 1e6;
%             dZWaferNm = this.zWafer.get() * mm2nm;
%             
%             l = abs(dZWaferNm - this.dCurrentZTarget_nm) < this.dTolerance ;
%             %|| this.zWafer.isReady();
%             l = l | this.zWafer.isReady();
%             if (l)
%                  fprintf('Wafer z ready: Commanded wafer value: %0.1f, Current Value: %0.1f\n', this.dCurrentZTarget_nm, dZWaferNm)
%             else
%                  fprintf('Wafer z is NOT ready: Commanded wafer value: %0.1f, Current Value: %0.1f\n', this.dCurrentZTarget_nm, dZWaferNm)
%             end
%             if this.lDebugScan
%                 cMsg = [
%                     'onScanIsAtState()', ...
%                     sprintf('wafer fine z = %1.1f nm', this.zWafer.get() * 1e6) ...
%                 ];
%                 this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
%             end
%         end
%         
%             
%         
%         % @param {struct} stUnit - the unit definition structure 
%         % @param {struct} stState - the state (possibly contains 
%         % information about the task to execute during acquire)
%         function onScanAcquire(this, stUnit, stValue)
%             
%             if this.lDebugScan
%                 this.msg('onScanAcquire()', this.u8_MSG_TYPE_SCAN);
%             end
%             
%         end
%         
%         % @param {struct} stUnit - the unit definition structure 
%         % @param {struct} stState - the state
%         % @returns {logical} - true if the acquisition task is complete
%         function l = onScanIsAcquired(this, stUnit, stValue)
%             
%             if this.lDebugScan
%                 this.msg('onScanIsAcquired()', this.u8_MSG_TYPE_SCAN);
%             end
%             l = true;
%         end
%         
%         
%         
%         function onScanAbort(this, stUnit)
%             if this.lDebugScan
%                 this.msg('onScanAbort()', this.u8_MSG_TYPE_SCAN);
%                 this.msg('---------------------------------------------------------', this.u8_MSG_TYPE_SCAN);
%             end
%             this.zHeightSensor.setSampleAverage(this.u8SampleAverage);
%             this.lReady = true; 
%         end
% 
% 
%         function onScanComplete(this, stUnit)
%             if this.lDebugScan
%                 this.msg('onScanComplete()', this.u8_MSG_TYPE_SCAN);
%                 this.msg('---------------------------------------------------------', this.u8_MSG_TYPE_SCAN);
%             end
%             fprintf('Scan completed and never reached value, setting lReady to true\n');
%             this.zHeightSensor.setSampleAverage(this.u8SampleAverage);
%             this.lReady = true;
%         end
        
    end
        
    
end

