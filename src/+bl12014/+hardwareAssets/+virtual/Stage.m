
% Implements a subset of cxro.common.device.motion.Stage that is useful
% for integrationg into mic

classdef Stage < handle
    
    
    properties
        
    end
    
    properties (Access = private)
        
        dVals = [];
        lInitializeds = []
    end
    
    methods
        
        function this = Stage(varargin)
            
        end
        
        
        % @param {uint8 1x1} - zero-indexed axis
        % @return {double 1x1}
        function d = getAxisAnalog(this, u8Axis)
            if length(this.dVals) < (u8Axis + 1)
                d = 0;
            else
                d = this.dVals(u8Axis + 1);
            end
        end
        
        
        % @param {uint8 1x1} - zero-indexed axis
        % @return {double 1x1}
        function d = getAxisPosition(this, u8Axis)
            if length(this.dVals) < (u8Axis + 1)
                d = 0;
            else
                d = this.dVals(u8Axis + 1);
            end
        end
        
        % @param {uint8 1x1} - zero-indexed axis
        function moveAxisAbsolute(this, u8Axis, dVal)
            this.dVals(u8Axis + 1) = dVal;
        end
        
        % @param {uint8 1x1} - zero-indexed axis
        % @return {logical 1x1} 
        function l = getAxisIsReady(this, u8Axis)
            l = true;
        end
        
        % @param {uint8 1x1} - zero-indexed axis
        function stopAxisMove(this, u8Axis)
        end
        
        % Initializes a single axis
        % @param {uint8 1x1} - zero-indexed axis
        % @return {logical 1x1} The real thing returns a java.util.concurrent.Future<Result>
        % this is a cheat 
        function l = initializeAxis(this, u8Axis)
            this.lInitializeds(u8Axis + 1) = true;
            l = true;
        end
        
        % @param {uint8 1x1} - zero-indexed axis
        % @return {logical 1x1} 
        function l = getAxisIsInitialized(this, u8Axis)
            if length(this.lInitializeds) < (u8Axis + 1)
                l = false;
            else
                l = this.lInitializeds(u8Axis + 1);
            end
        end
        
        function reset(this, u8Axis)
            
        end
        
        % Initializes all axes
        % @return {logical 1x1} The real thing returns a java.util.concurrent.Future<Result>
        % this is a cheat 
        function l = initializeAxes(this)
            l = true;
        end
        
        function connect(this)
            
        end
        
        function disconnect(this)
            
            
        end
        
        
        
    end
    
    methods (Access = protected)
        
        
    end
    
    
     
    
end

