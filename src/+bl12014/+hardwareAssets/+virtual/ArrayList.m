%{
% Implements cxro.met5.device.mfdriftmonitor.ArrayList
%}
classdef ArrayList < handle
    
    
    properties
        
    end
    
    properties (Access = private)
        
        xValues
    end
    
    methods
        
        function this = ArrayList(xValues)
            this.xValues = xValues;
        end
        
        % Returns the element at the specified position in this list.
        % @param {uint32 1x1} u32Index ZERO INDEXED SINCE JAVA INTERFACE
        % @return {x 1x1}
        function x = get(this, u32Index)
            x = this.xValues(u32Index + 1);
        end
        
        % Returns the number of elements in this list.
        % @return {uint32 1x1}
        function u32 = size(this)
            u32 = length(this.xValues);
            
        end
                
    end
    
    methods (Access = protected)
        
        
    end
    
    
     
    
end

