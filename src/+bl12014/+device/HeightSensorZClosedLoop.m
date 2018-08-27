classdef HeightSensorZClosedLoop < mic.interface.device.GetSetNumber
       
    
    properties (Constant)
        
        
    end
    
    properties (SetAccess = private)
        
        cName = 'device-height-sensor-z-closed-loop'
    end
    
    
    
    properties (Access = private)
        
        
        % {< mic.interface.device.GetSetNumber 1x1}
        zWafer
        
        % {< mic.interface.device.GetNumber 1x1}
        zHeightSensor
        
        % {mic.Clock 1x1}
        clock
                
        % {double 1x1} value passed into set() used during the iterative
        % march
        dSetGoal
        
        % {double 1x1} desired tolerance in nm
         % (RM: 8/24) relaxing tolerance level
        dTolerance = 2.0; % Tolerance for hitting HS value
        dToleranceWaferZ = 5; % Tolerance for a single Wafer Z move
        
        % Add some PID controls:
        PID_P = .96
        PID_I = 0
        PID_D = 0
        
        % Set this when each time wafer z changes target
        dCurrentZTarget_nm
        
        % {uint8 1x1 maximum number of moves of the wafer fine z}
        u8MovesMax = uint8(5);
        
        % {logical 1x1} 
        lReady = true
        
        % {mic.Scan 1x1}
        scan
        
        % {double 1x1} number of samples to average when getting a value
        % from the Height Sensor drift monitor
%         u8SampleAverage = 50
%         u8SampleAverageDuringControl = 200;

        % (RM: 8/24) halving values to prevent feedback instability
        u8SampleAverage = 15
        u8SampleAverageDuringControl = 50;
        % {logical 1x1} set to true to debug the scan
        lDebugScan = true
    end
    
    methods
        
        function this = HeightSensorZClosedLoop(clock, zWafer, zHeightSensor, varargin)
            
            % Input validation and parsing
            
            p = inputParser;
            addRequired(p, 'clock', @(x) isa(x, 'mic.Clock'))
            addRequired(p, 'zWafer', @(x) isa(x, 'mic.interface.device.GetSetNumber'))
            addRequired(p, 'zHeightSensor', @(x) isa(x, 'mic.interface.device.GetNumber')) % also has method setSampleAverage
            addParameter(p, 'dTolerance', this.dTolerance, @(x) isscalar(x) && isnumeric(x) && x > 0)
            addParameter(p, 'u8MovesMax', this.u8MovesMax, @(x) isscalar(x) && isinteger(x) && x > 0)
            addParameter(p, 'cName', this.cName, @(x) ischar(x));
            
            parse(p, clock, zWafer, zHeightSensor, varargin{:});

            this.clock = p.Results.clock;
            this.zWafer = p.Results.zWafer;
            this.zHeightSensor = p.Results.zHeightSensor;
            
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
        
        % {double 1x1} dVal - desired reading of height sensor z in nm
        function set(this, dVal)
            
            this.dSetGoal = dVal;
            this.lReady = false;
            
            % Leverage the mic.Scan class to do a scan.  Values won't
            % matter since they will be computed in each onSetState call
                        
            ceValues = cell(1, this.u8MovesMax);
            for n = 1 : this.u8MovesMax
                ceValues{n} = struct('zWafer', 0);
            end
            
            unit = struct(...
                'zWafer', 'nm', ...
                'zHeightSensor', 'nm' ...
            );
        
            stRecipe = struct();
            stRecipe.unit = unit;
            stRecipe.values = ceValues;
            
            dPeriod = 0.5; 
            
            % Need enough time for ethernet to communicate w/ delta tau otherwise the scan will
            % reach max number of steps and the move command to DeltaTau
            % will hav enever reached the hardware
            
            this.scan = mic.Scan(...
                [this.cName, '-scan'], ...
                this.clock, ...
                stRecipe, ...
                @this.onScanSetState, ...
                @this.onScanIsAtState, ...
                @this.onScanAcquire, ...
                @this.onScanIsAcquired, ...
                @this.onScanComplete, ...
                @this.onScanAbort, ...
                dPeriod ...
            );

        
            if this.lDebugScan
                this.msg('---------------------------------------------------------', this.u8_MSG_TYPE_SCAN);
                cMsg = sprintf(...
                    'set() starting new scan with check period of %1.0f ms', ...
                    dPeriod * 1000 ...
                );
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
            end
            this.scan.start();
            
            
        end
        
        function l = isReady(this)
            
            l = this.lReady;
            
        end
        
        function stop(this)
            
            this.scan.stop();
            this.lReady = true;
            
        end
        
        function initialize(this)
            
            
        end
        
        function l = isInitialized(this)
            
            l = true;
            
        end
        
    end
    
    methods (Access = private)
        
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        function onScanSetState(this, stUnit, stValue)
            
            if this.lDebugScan
                this.msg('onScanSetState()', this.u8_MSG_TYPE_SCAN);
            end
            
            this.zHeightSensor.setSampleAverage(this.u8SampleAverageDuringControl);
            
            
            dZHeightSensor = this.zHeightSensor.get();
            
            dError = this.dSetGoal - dZHeightSensor;
            this.zHeightSensor.setSampleAverage(this.u8SampleAverage);
            
            % Command the wafer to change value by to this position
            if (abs(dError) < this.dTolerance)
                
                if this.lDebugScan || true
                    cMsg = [...
                        'onScanSetState() ', ...
                        ' calling scan.stop()', ...
                        sprintf(' abs(error) = %1.3f nm', abs(dError)), ...
                        sprintf(' < tolerance of %1.3f nm', this.dTolerance) ...
                    ];
                fprintf(cMsg);
                    this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                end
                
               this.scan.stop(); % calls onScanAbort()
            else
 
                % The wafer z raw units are mm.  Need to convert to nm
                % then back to mm
                mm2nm = 1e6;
                nm2mm = 1e-6;
                dZWaferNm = this.zWafer.get() * mm2nm;
                
                dZWaferGoal = (dZWaferNm + dError) * nm2mm;
                this.dCurrentZTarget_nm = dZWaferGoal * mm2nm;
                
                % Abort if new wafer z goal is out of range:
                if (dZWaferGoal > 10000 * nm2mm || ...
                    dZWaferGoal < 0)
                
                    cMsg = [...
                        sprintf('DID NOT REACH GOAL.\n\n') ...
                        sprintf('To achieve the target height sensor value of %1.3f nm,', this.dSetGoal), ...
                        sprintf(' wafer fine z needs to move to %1.1f nm,', dZWaferGoal * 1e6), ...
                        sprintf(' which is out of the allowed range of the wafer fine z stage.\n\n'), ...
                        sprintf('min allowed value of wafer fine z = 0 nm\n'), ...
                        sprintf('max allowed value of wafer fine z = 10000 nm\n\n'), ...
                        sprintf('Try moving wafer coarse z to bring the height sensor z closer to the target value and repeating.') ...
                    ];
                    msgbox( ...
                        cMsg, ...
                        'HeightSensorZClosedLoop Aborted.', ...
                        'error', ...
                        'modal' ...
                    );
                    this.scan.stop();
                    return;
                end
                    
                
                if this.lDebugScan
                    
                    cMsg = [...
                        'onScanSetState() ', ...
                        sprintf('hs goal = %1.1f nm ', this.dSetGoal) ...
                    ];
                    this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                    cMsg = [...
                        'onScanSetState() ', ...
                        sprintf('hs value with %1.0f sample avg = %1.1f nm', this.u8SampleAverageDuringControl, dZHeightSensor) ...
                    ];
                    this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                    
                    cMsg = [...
                        'onScanSetState()', ...
                        sprintf(' hs error = %1.3f nm', dError), ...
                        sprintf(' setting z wafer fine from %1.1f nm to %1.1f nm',  dZWaferNm, dZWaferGoal * 1e6) ...
                    ];
                    this.msg(cMsg, this.u8_MSG_TYPE_SCAN)
                end
                this.zWafer.set(dZWaferGoal);
            end
            
            
        end
        
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the system is at the state
        function l = onScanIsAtState(this, stUnit, stValue)
            
            l = this.zWafer.isReady();
            % RM: isReady is always true.  We need to use info about the
            % tolerance:
            
            mm2nm = 1e6;
            dZWaferNm = this.zWafer.get() * mm2nm;
            
            l = abs(dZWaferNm - this.dCurrentZTarget_nm) < this.dToleranceWaferZ;
              
            if (l)
                fprintf('Wafer z is ready')
            else
                 fprintf('Wafer z is NOT ready: Commanded wafer value: %0.1f, Current Value: %0.1f\n', this.dCurrentZTarget_nm, dZWaferNm)
            end
            if this.lDebugScan
                cMsg = [
                    'onScanIsAtState()', ...
                    sprintf('wafer fine z = %1.1f nm', this.zWafer.get() * 1e6) ...
                ];
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
            end
        end
        
            
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state (possibly contains 
        % information about the task to execute during acquire)
        function onScanAcquire(this, stUnit, stValue)
            
            if this.lDebugScan
                this.msg('onScanAcquire()', this.u8_MSG_TYPE_SCAN);
            end
            
        end
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the acquisition task is complete
        function l = onScanIsAcquired(this, stUnit, stValue)
            
            if this.lDebugScan
                this.msg('onScanIsAcquired()', this.u8_MSG_TYPE_SCAN);
            end
            l = true;
        end
        
        
        
        function onScanAbort(this, stUnit)
            if this.lDebugScan
                this.msg('onScanAbort()', this.u8_MSG_TYPE_SCAN);
                this.msg('---------------------------------------------------------', this.u8_MSG_TYPE_SCAN);
            end
            this.zHeightSensor.setSampleAverage(this.u8SampleAverage);
            this.lReady = true; 
        end


        function onScanComplete(this, stUnit)
            if this.lDebugScan
                this.msg('onScanComplete()', this.u8_MSG_TYPE_SCAN);
                this.msg('---------------------------------------------------------', this.u8_MSG_TYPE_SCAN);
            end
            this.zHeightSensor.setSampleAverage(this.u8SampleAverage);
            this.lReady = true;
        end
        
    end
        
    
end

