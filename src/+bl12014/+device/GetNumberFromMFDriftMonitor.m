% This is a bridge between getNumber and actual device api

classdef GetNumberFromMFDriftMonitor < mic.interface.device.GetNumber
    
    
    properties (Constant)
        u8DEVICE_DMI = 1
        u8DEVICE_HEIGHT_SENSOR_CHANNEL = 2
        u8DEVICE_HEIGHT_SENSOR_POSITION = 3
        
    end
    
    properties (Access = private)
        
        % Handle to the MFDriftMonitor middleware.  Only one of these for
        % all GenNumbers
        api
        
        % {uint8 1xm} the channel to read
        u8Channel
        
        % {uint8 1xm} the channel to read
        u8DeviceType
            

    end
    
    methods
        
        function this = GetNumberFromMFDriftMonitor(...
                apiDevice, u8DeviceType, u8Channel, dNumSampleAverage)
            
            this.api            = bl12014.deviceMiddleware.MFDriftMonitorAPI(...
                                    apiDevice, dNumSampleAverage);
                                
            this.u8DeviceType   = u8DeviceType;
            this.u8Channel      = u8Channel;
            
        end
        
        function d = get(this)
            % Get a sample:
            this.api.getSampleDataAvg(this.dNumSampleAverage);
            
            % This data 
            
            
            switch this.u8DeviceType
                case this.u8DEVICE_DMI
                    
                case this.u8DEVICE_HEIGHT_SENSOR
                   
            end
            
        end
                
        function l = isReady(this)
            l = true;  
        end
        
        
        function initialize(this)
            % do nothing
        end
        
        function l = isInitialized(this)
            l = true;         
        end
        
    end
    
    
    methods (Access = protected)
        
        
        
    end
        
    
end

