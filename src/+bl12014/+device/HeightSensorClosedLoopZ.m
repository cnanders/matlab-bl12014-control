classdef HeightSensorClosedLoopZ < mic.interface.device.GetSetNumber
       
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
        
        
        % {< mic.interface.device.GetSetNumber 1x1}
        zWafer
        zHeightSensor
        
        % {mic.Clock 1x1}
        clock
                
        % {double 1x1} value passed into set() used during the iterative
        % march
        dSetGoal
        
        % {double 1x1} desired tolerance in nm
        dTolerance = 1;
        
        % {uint8 1x1 maximum number of moves of the wafer fine z}
        u8MovesMax = uint8(5);
        
        % {logical 1x1} 
        lReady
        
        % {mic.Scan 1x1}
        scan
        
        
        
        % {logical 1x1} set to true to debug the scan
        lDebugScan = true
    end
    
    methods
        
        function this = HeightSensorClosedLoopZ(clock, zWafer, zHeightSensor, varargin)
            
            % Input validation and parsing
            
            p = inputParser;
            addRequired(p, 'clock', @(x) isa(x, 'mic.Clock'))
            addRequired(p, 'zWafer', @(x) isa(x, 'mic.interface.device.GetSetNumber'))
            addRequired(p, 'zHeightSensor', @(x) isa(x, 'mic.interface.device.GetSetNumber'))
            addParameter(p, 'dTolerance', this.dTolerance, @(x) isscalar(x) && isnumeric(x) && x > 0)
            addParameter(p, 'u8MovesMax', this.u8MovesMax, @(x) isscalar(x) && isinteger(x) && x > 0)
            
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
        
        
        
        function d = get(this)
            
            d = this.zHeightSensor.get();
            
                        
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
            
            this.scan = mic.Scan(...
                this.clock, ...
                stRecipe, ...
                @this.onScanSetState, ...
                @this.onScanIsAtState, ...
                @this.onScanAcquire, ...
                @this.onScanIsAcquired, ...
                @this.onScanComplete, ...
                @this.onScanAbort ...
            );

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
            
            dError = this.zHeightSensor.get() - this.dSetGoal
            
            % Command the wafer to change value by to this position
            if (abs(dError) < this.dTolerance)
               this.scan.stop(); % calls onScanAbort()
            else
                this.zWafer
                this.zWafer.set(this.zWafer.get() + dError);
            end
            
            
        end
        
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the system is at the state
        function l = onScanIsAtState(this, stUnit, stValue)
            if this.lDebugScan
                this.msg('onScanIsAtState()', this.u8_MSG_TYPE_SCAN);
            end
            l = this.zWafer.isReady();
        end
        
            
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state (possibly contains 
        % information about the task to execute during acquire)
        function onScanAcquire(this, stUnit, stValue)
            
            if this.lDebugScan
                this.msg('onScanAcquire()', this.u8_MSG_TYPE_SCAN);
            end
            
            % Display new error
            dError = this.zHeightSensor.get() - this.dSetGoal;
            fprintf('HeightSensorClosedLoop.onScanAcquire() error = %1.3f', dError); 
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
                this.msg('onScanAbort()');
            end
            this.lReady = true; 
        end


        function onScanComplete(this, stUnit)
            if this.lDebugScan
                this.msg('onScanComplete()');
            end
            this.lReady = true;
        end
        
    end
        
    
end

