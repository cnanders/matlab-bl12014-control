
% Implements a subset of cxro.common.device.motion.Stage that is useful
% for integrationg into mic.  Also 

classdef StageFilter < mic.Base
    
    
    properties
        
    end
    
    properties (Access = private)
        
        % cxro.common.device.motion.Stage || bl12014.hardwareAssets.virtual.Stage
        stage
        
        % {cell of bl12014.Buffer 1xn} for storing previous values
        bufferAnalog = {}
        bufferPosition = {}
        
        % {double 1xn}  The buffers for each axis are generated on-demand and 
        % may be out of order.  This stores the axis of each element of bufferAnalog
        % and bufferPosition. 
        dAxesOfAnalogBuffers = []
        dAxesOfPositionBuffers = []
        
        % {double 1x1}
        dSizeOfFilter = 3;
        
        
        
    end
    
    methods
        
        function this = StageFilter(varargin)
            
            
             for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
             end
            
            
            if ~isa(this.stage, 'bl12014.hardwareAssets.virtual.Stage') && ...
               ~isa(this.stage, 'cxro.common.device.motion.Stage')
                error('stage must be a bl12014.hardwareAssets.virtual.Stage or cxro.common.device.motion.Stage');
            end
            
            
            
            
        end
        
        
        % @param {uint8 1x1} - zero-indexed axis
        % @return {double 1x1}
        function d = getAxisAnalog(this, u8Axis)
            
            if ~ismember(u8Axis, this.dAxesOfAnalogBuffers)
                % buffer does not exist
                fprintf('middleware.StageFilter initialzing bl12014.Buffer for axis %s analog', u8Axis);
                this.bufferAnalog{end + 1} = bl12014.Buffer(this.dSizeOfFilter);
                this.dAxesOfAnalogBuffers(end + 1) = u8Axis;
            end
                
            % Get index of this axis
            dIndex = find(this.dAxesOfAnalogBuffers == u8Axis);
            this.bufferAnalog{dIndex}.push(this.stage.getAxisAnalog(u8Axis));
            d = this.bufferAnalog{dIndex}.avg();
            
        end
        
        
        % @param {uint8 1x1} - zero-indexed axis
        % @return {double 1x1}
        function d = getAxisPosition(this, u8Axis)
            
            if ~ismember(u8Axis, this.dAxesOfPositionBuffers)
                % buffer does not exist
                fprintf('middleware.StageFilter initialzing bl12014.Buffer for axis %s position', u8Axis);
                this.bufferPosition{end + 1} = bl12014.Buffer(this.dSizeOfFilter);
                this.dAxesOfPositionBuffers(end + 1) = u8Axis;
            end
            
            % Get index of this axis
            dIndex = find(this.dAxesOfPositionBuffers == u8Axis);
            this.bufferPosition{dIndex}.push(this.stage.getAxisPosition(u8Axis));
            d = this.bufferPosition{dIndex}.avg();
        end
        
        % @param {uint8 1x1} - zero-indexed axis
        function moveAxisAbsolute(this, u8Axis, dVal)
            this.stage.moveAxisAbsolute(u8Axis, dVal)
        end
        
        % @param {uint8 1x1} - zero-indexed axis
        % @return {logical 1x1} 
        function l = getAxisIsReady(this, u8Axis)
            l = this.stage.getAxisIsReady(u8Axis);
        end
        
        % @param {uint8 1x1} - zero-indexed axis
        function stopAxisMove(this, u8Axis)
            this.stage.stopAxisMove(u8Axis);
        end
        
        % Initializes a single axis
        % @param {uint8 1x1} - zero-indexed axis
        % @return {logical 1x1} The real thing returns a java.util.concurrent.Future<Result>
        % this is a cheat 
        function l = initializeAxis(this, u8Axis)
            l = this.stage.initializeAxis(u8Axis);
        end
        
        % @param {uint8 1x1} - zero-indexed axis
        % @return {logical 1x1} 
        function l = getAxisIsInitialized(this, u8Axis)
            l = this.stage.getAxisIsInitialized(u8Axis);
        end
        
        function reset(this, u8Axis)
            this.stage.reset(u8Axis);
        end
        
        % Initializes all axes
        % @return {logical 1x1} The real thing returns a java.util.concurrent.Future<Result>
        % this is a cheat 
        function l = initializeAxes(this)
            l = this.stage.initializeAxes();
        end
        
        function connect(this)
            this.stage.connect();
        end
        
        function disconnect(this)
            this.stage.disconnect();
        end
        
        
        
    end
    
    methods (Access = protected)
        
        
    end
    
    
     
    
end

