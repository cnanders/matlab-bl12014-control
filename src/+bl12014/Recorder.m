classdef Recorder < mic.Base
    
    % Records specified num of values from a GetNumber or GetSetNumber and
    % stores them
    
    properties
        
        cName = 'recorder'
    end
    
    properties (Access = private)
        
        % props for storing scan progress
        dCountOfScan = 1
        dLengthOfScan = 10
        lDebug = true
        
        
        lIsRecording
        scan
        dBuffer = []
        
        % {mic.Clock 1x1}
        clock
        
        % {mic.ui.device.GetSetNumber || mic.ui.device.GetNumber}
        ui 
        
        cUnit % optional.  uses getValCalDisplay if not provided

    end
    
    methods
        function this = Recorder(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.ui, 'mic.ui.device.GetSetNumber') && ...
               ~isa(this.ui, 'mic.ui.device.GetNumber') 
                error('ui must be mic.ui.device.Get*Number');
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clocki must be mic.Clock');
            end
            
%             if ~isa(this.cUnit, 'char')
%                 error('cUnit must be provided and be type char');
%             end
                                    
        end
        
        
        % Returns {logical 1x1} true during recording
        function l = getIsRecording(this)
            l = this.lIsRecording;
        end
        
        % Returns {double 1x1} in [0:1]
        function d = getProgress(this)
            d = this.dCountOfScan / this.dLengthOfScan;
        end
        
        % Returns {double 1xn} with all values in the recording cache
        function d = get(this)
            d = this.dBuffer;
        end
        
        function record(this, dNum)
            
            if nargin == 1
                dNum = 10;
            end
            
            if ~isempty(this.scan) && ...
                ~this.scan.getIsStopped()
                this.scan.stop();
            end
            
            
            this.lIsRecording = true;
            this.dCountOfScan = 0; % reset
            this.dLengthOfScan = dNum;
            
            this.dBuffer = [];
            
            ceValues = cell(1, dNum); % cell array of empty since we know what we are doing each time
            stRecipe = struct();
            stRecipe.unit = struct();
            stRecipe.values = ceValues;
            
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
                0.2 ... % Need larger than the PPMAC cache period of 0.2 s
            );

            this.scan.start();
        end
        
    end
    
    methods (Access = protected)
        
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        function onScanSetState(this, stUnit, stValue)

        end


        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the system is at the state
        function l = onScanIsAtState(this, stUnit, stValue)
            l = true;
        end


        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state (possibly contains information about
        % the task to execute during acquire)
        function onScanAcquire(this, stUnit, stValue)
            
            if isempty(this.cUnit)
                cUnit = this.ui.getUnit().name; % use current UI unit
            else
                cUnit = this.cUnit; % use set unit
            end
            
            this.dBuffer(end + 1) = this.ui.getValCal(cUnit);
            
            this.dCountOfScan = this.dCountOfScan + 1;
            if this.lDebug
                cMsg = sprintf('%s onScanAcquire %1.0f of %1.0f: %1.3f %s', ...
                    this.cName, ...
                    this.dCountOfScan, ...
                    this.dLengthOfScan, ...
                    this.dBuffer(end), ...
                    cUnit ...
                );
                this.msg(cMsg, this.u8_MSG_STYLE_SCAN);
            end
            
        end

        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the acquisition task is complete
        function l = onScanIsAcquired(this, stUnit, stValue)
            l = true;
        end


        function onScanAbort(this, stUnit)
        	this.resetScanState();
        end


        function onScanComplete(this, stUnit)
        	this.resetScanState();
        end
        
        function resetScanState(this)
            this.lIsRecording = false;
            this.dCountOfScan = 0;
        end
        
    end
end

