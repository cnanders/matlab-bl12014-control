%{
% Implements cxro.met5.device.mfdriftmonitor.SampleData
%}
classdef SampleData < handle
    
    
    properties
        
    end
    
    properties (Access = private)
        
        u32DmiData
        u32HsData
    end
    
    methods
        
        function this = SampleData(varargin)
            this.u32DmiData = randi(200, 4, 1) - 100;
            this.u32HsData = randi(50e3, 24, 1) + 425e3;
        end
        
        % Returns {uint32 1 x 4} of most recent HS / DMI 1 kHz data
        % @param {int32 1x1} i32Samples - number of samples, max 10k.
        % @return {uint32 4x1} - four raw DMI values of a 1 ms instant of time
        function u32 = getDmiData(this)
            u32 = this.u32DmiData;
        end
        
        % Returns ADC counts of 12 channels for two 500 us integration
        % windows for a total of 24 values
        % @return {uint32 24x1} - of one ms worth of acquisition time.
        function u32 = getHsData(this)
            u32 = this.u32HsData;
        end
        
        function u8 = getHsDataLength(this)
            u8 = length(this.u32HsData);
        end
        
        function u8 = getDmiDataLength(this)
            u8 = length(this.u32DmiData);
        end
        
        
    end
    
    methods (Access = protected)
        
        
    end
    
    
     
    
end

