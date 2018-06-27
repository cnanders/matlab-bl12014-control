%{
% Implements a subset of cxro.met5.device.mfdriftmonitor
%}
classdef MFDriftMonitor < handle
    
    
    properties
        
    end
    
    properties (Access = private)
        
        u32Capacity = 1e4;
    end
    
    methods
        
        function this = MFDriftMonitor(varargin)
            
        end
        
        % Returns {java.util.ArrayList<SampleData>} of most recent HS / DMI 1 kHz data
        % @param {unt32 1x1} u32Samples - number of samples, max 10k.
       
        function samples = getSampleData(this, u32Samples)
          
            if u32Samples > this.u32Capacity
                u32Samples = this.u32Capacity;
            end
            
            import bl12014.hardwareAssets.virtual.SampleData
            samples(1, u32Samples) = bl12014.hardwareAssets.virtual.SampleData();
            for k = 1 : u32Samples
                samples(1, k) = bl12014.hardwareAssets.virtual.SampleData();
            end
                
        end
        
        % Returns capacity of SampleData buffer.
        function u32 = getSampleDataBufferCapacity(this)
            u32 = this.u32Capacity;
            
        end
        
        % Returns current size of SampleData buffer.
        function u32 = getSampleDataBufferSize(this)
            u32 = this.u32Capacity;
        end
        
        
    end
    
    methods (Access = protected)
        
        
    end
    
    
     
    
end

