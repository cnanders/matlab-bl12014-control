classdef HeightSensorZClosedLoopCoarse < mic.interface.device.GetSetNumber
       
    % On set(), sends wafer fine z to middle of range (5000 nm), then
    % iteratively marces wafer fine z until height sensor reads desired
    % value within a tolernace of 50 nm default
    
    properties (Constant)
        
        
    end
    
    properties (SetAccess = private)
        
        cName = 'fix-me'
    end
    
    
    
    properties (Access = private)
        
        % {< mic.interface.device.GetSetNumber 1x1}
        zWaferFine
        
        % {< mic.interface.device.GetSetNumber 1x1}
        zWaferCoarse
        
        % {< mic.interface.device.GetNumber 1x1}
        zHeightSensor
        
        % {mic.Clock 1x1}
        clock
                
        % {double 1x1} value passed into set() used during the iterative
        % march
        dSetGoal
        
        % {double 1x1} desired tolerance in nm
        dTolerance = 50;
        
        % {uint8 1x1 maximum number of moves of the wafer fine z}
        u8MovesMax = uint8(5);
        
        % {logical 1x1} 
        lReady = true
        
        % {mic.Scan 1x1}
        scan
        
        % {double 1x1} number of samples to average when getting a value
        % from the Height Sensor drift monitor
        u8SampleAverage = 50
        u8SampleAverageDuringControl = 50;
        
        % {logical 1x1} set to true to debug the scan
        lDebugScan = true
    end
    
    methods
        
        function this = HeightSensorZClosedLoopCoarse(clock, zWaferFine, zWaferCoarse, zHeightSensor, varargin)
            
            % Input validation and parsing
            
            p = inputParser;
            addRequired(p, 'clock', @(x) isa(x, 'mic.Clock') || isa(x, 'mic.ui.Clock'))
            addRequired(p, 'zWaferFine', @(x) isa(x, 'mic.interface.device.GetSetNumber'))
            addRequired(p, 'zWaferCoarse', @(x) isa(x, 'mic.interface.device.GetSetNumber'))
            addRequired(p, 'zHeightSensor', @(x) isa(x, 'mic.interface.device.GetNumber')) % also has method setSampleAverage
            addParameter(p, 'dTolerance', this.dTolerance, @(x) isscalar(x) && isnumeric(x) && x > 0)
            addParameter(p, 'u8MovesMax', this.u8MovesMax, @(x) isscalar(x) && isinteger(x) && x > 1)
            addParameter(p, 'cName', this.cName, @(x) ischar(x));
            
            parse(p, clock, zWaferFine, zWaferCoarse, zHeightSensor, varargin{:});

            this.clock = p.Results.clock;
            this.zWaferFine = p.Results.zWaferFine;
            this.zWaferCoarse = p.Results.zWaferCoarse;
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
                if n == 1
                    % On first state, move wafer fine to center of range
                    ceValues{n} = struct('zWaferFine', 0);
                else
                    % On all other states, adjust wafer coarse
                    ceValues{n} = struct('zWaferCoarse', 0);
                end
            end
            
            unit = struct(...
                'zWaferFine', 'nm', ... % raw units are mm
                'zWaferCoarse', 'nm', ... % raw units are mm
                'zHeightSensor', 'nm' ... % raw units are nm
            );
        
            stRecipe = struct();
            stRecipe.unit = unit;
            stRecipe.values = ceValues;
            
            dPeriod = 0.5;
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
                dPeriod ... % giving enough time for communication with DeltaTauPMAC
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
        function onScanSetState1(this, stUnit, stValue)
            
            
            if this.lDebugScan
                cMsg = [...
                  'onScanSetState1() setting zWaferFine to middle of range (5000 nm)' ...
                ];
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
            end
            
            
            % send to middle of range; units are mm
            this.zWaferFine.set(5000 * 1e-6);
            
        end
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        function onScanSetState(this, stUnit, stValue)
            
            
            if isfield(stValue, 'zWaferFine')
                this.onScanSetState1(stUnit, stValue)
                return
            end
            
            
            if this.lDebugScan
                this.msg('onScanSetState()', this.u8_MSG_TYPE_SCAN);
            end
            
            this.zHeightSensor.setSampleAverage(this.u8SampleAverageDuringControl);
            dZHeightSensor = this.zHeightSensor.get();
            dError = this.dSetGoal - dZHeightSensor;
            this.zHeightSensor.setSampleAverage(this.u8SampleAverage);
            
            % Command the wafer to change value by to this position
            if (abs(dError) < this.dTolerance)
                
                if this.lDebugScan
                    
                    
                    
                    
                    cMsg = [...
                        'onScanSetState() ', ...
                        ' calling scan.stop()', ...
                        sprintf(' error = %1.3f nm', dError), ...
                        sprintf(' < tolerance of %1.3f nm', this.dTolerance) ...
                    ];
                    this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                end
                
               this.scan.stop(); % calls onScanAbort()
            else
 
                % The wafer z raw units are mm.  Need to convert to nm
                % then back to mm
                mm2nm = 1e6;
                nm2mm = 1e-6;
                dZWafer = this.zWaferCoarse.get();
                dZWaferGoal = (dZWafer * mm2nm + dError) * nm2mm;
                
                dZWaferCoarseMax = 1;
                dZWaferCoarseMin = -1;
                if (dZWaferGoal > dZWaferCoarseMax || ...
                    dZWaferGoal < dZWaferCoarseMin)
                
                    cMsg = [...
                        sprintf('DID NOT REACH GOAL.\n\n') ...
                        sprintf('To achieve the target height sensor value of %1.3f nm,', this.dSetGoal), ...
                        sprintf(' wafer coarse z needs to move to %1.1f nm,', dZWaferGoal * 1e6), ...
                        sprintf(' which is out of the allowed range of the wafer fine z stage.\n\n'), ...
                        sprintf('min allowed value of wafer fine z = %1.1f mm\n', dZWaferCoarseMin), ...
                        sprintf('max allowed value of wafer fine z = %1.1f mm\n\n', dZWaferCoarseMax), ...
                    ];
                    msgbox( ...
                        cMsg, ...
                        'HeightSensorZClosedLoopCoarse Aborted.', ...
                        'error', ...
                        'modal' ...
                    );
                    this.scan.stop();
                    return;
                end
                    
                
                if this.lDebugScan
                    
                    cMsg = [...
                        'onScanSetState() ', ...
                        sprintf('hs goal = %1.3f nm ', this.dSetGoal) ...
                    ];
                    this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                   cMsg = [...
                        'onScanSetState() ', ...
                        sprintf('hs value with %1.0f sample avg = %1.3f', this.u8SampleAverageDuringControl, dZHeightSensor) ...
                    ];
                    this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                    cMsg = [...
                        'onScanSetState()', ...
                        sprintf(' hs error = %1.3f nm', dError), ...
                        sprintf(' setting zWaferCoarse from %1.1f nm to %1.1f nm', dZWafer * 1e6, dZWaferGoal * 1e6) ...
                    ];
                    this.msg(cMsg, this.u8_MSG_TYPE_SCAN)
                end
                this.zWaferCoarse.set(dZWaferGoal);
            end
            
            
        end
        
        
        function l = onScanIsAtState1(this, stUnit, stValue)
            if this.lDebugScan
                cMsg = [...
                    'onScanIsAtState1() ', ...
                    sprintf(...
                        'zWaferFine = %1.3f nm', ...
                        this.zWaferFine.get() * 1e6 ...
                    ) ...
                ];
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
            end
            l = this.zWaferFine.isReady();
        end
        
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the system is at the state
        function l = onScanIsAtState(this, stUnit, stValue)
            
            if isfield(stValue, 'zWaferFine')
                l = this.onScanIsAtState1(stUnit, stValue);
                return
            end
            
            
            if this.lDebugScan
                cMsg = [
                    'onScanIsAtState()', ...
                    sprintf('wafer coarse z = %1.1f nm', this.zWaferCoarse.get() * 1e6) ...
                ];
                this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
            end
            l = this.zWaferCoarse.isReady();
            % this.zWaferCoarse.get()
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

