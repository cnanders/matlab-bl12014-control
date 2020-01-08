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
        
        % Returns { java.util.ArrayList<cxro.met5.device.mfdriftmonitor.SampleData> 1xn} of most recent HS / DMI 1 kHz data
        % @param {unt32 1x1} u32Samples - number of samples, max 10k.
       
        function list = getSampleData(this, u32Samples)
          
            if u32Samples > this.u32Capacity
                u32Samples = this.u32Capacity;
            end
            
            % Matlab classes to mimic interface of the Java classes used
            % by the real MfDriftMonitor class
            
            import bl12014.hardwareAssets.virtual.SampleData
            import bl12014.hardwareAssets.virtual.ArrayList
            
            samples(1, u32Samples) = bl12014.hardwareAssets.virtual.SampleData();
            for k = 1 : u32Samples
                samples(1, k) = bl12014.hardwareAssets.virtual.SampleData();
            end
            
            list = ArrayList(samples);
                
        end
        
        % Returns capacity of SampleData buffer.
        function u32 = getSampleDataBufferCapacity(this)
            u32 = this.u32Capacity;
            
        end
        
        % Returns current size of SampleData buffer.
        function u32 = getSampleDataBufferSize(this)
            u32 = this.u32Capacity;
        end
        
        % Returns approximate Optical Power for all axes.
        % @return {double 4x1}
        function d = dmiGetAxesOpticalPower(this)
            d = randn(4, 1) * 0.1 + 5;
        end
            
        % Returns approximate Optical DC Power for all axes.
        % @return {double 4x1}
        function d = dmiGetAxesOpticalPowerDC(this)
            d = randn(4, 1) * 0.1 + 5;
        end
        
        function monitorStart(this)
            
        end
        
        
        function monitorStop(this)
            
        end
        
        
        
    end
    
    methods (Access = protected)
        
        
    end
    
    
     
    
end

