classdef Recorder < mic.Base
    
    % General wrapper around a GetNumber or GetSetNumber that can record its values
    
    properties
        
        cName = 'recorder'
        cUnit % optional.  uses getValCalDisplay if not provided
    end
    
    properties (Access = private)
        lIsRecording
        scan
        dBuffer = []
        
        % {mic.Clock 1x1}
        clock
        
        % {mic.ui.device.GetSetNumber || mic.ui.device.GetNumber}
        ui 
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
                        
            this.init();
            
        end
        
        
        % Returns {logical 1x1} true during recording
        function l = getIsRecording(this)
            l = this.lIsRecording;
        end
        
        % Returns {double 1xn} with all values in the recording cache
        function d = get(this)
            d = this.dBuffer;
        end
        
        function record(this, dNum)
            
            this.lIsRecording = true;
            this.dBuffer = [];
            
            if ~isempty(this.scan)
                this.scan.stop();
            end
            
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
            
            % blocking
            if isempty(cChar)
                this.dBuffer(end + 1) = this.ui.getValCalDisplay();
            else
                this.dBuffer(end + 1) = this.ui.getValCal(this.cUnit);
            end
        end

        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the acquisition task is complete
        function l = onScanIsAcquired(this, stUnit, stValue)
            l = true;
        end


        function onScanAbort(this, stUnit)
        	this.lIsRecording = false;
        end


        function onScanComplete(this, stUnit)
        	this.lIsRecording = false;
        end
        
    end
end

