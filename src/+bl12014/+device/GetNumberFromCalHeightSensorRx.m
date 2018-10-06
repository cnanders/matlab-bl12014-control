% This is a bridge between getNumber and actual device api

classdef GetNumberFromCalHeightSensor < mic.interface.device.GetNumber
    
    
    properties (Constant)
        
    end
    
    properties (Access = private)
        
        % Handle to the MFDriftMonitor middleware.  Only one of these for
        % all GenNumbers
        api
        
        dCalibratedChannelNumber % 1 = z, 2 = rx, 3 = ry
        dSampleAverage = 50
    end
    
    methods
        
        function this = GetNumberFromCalHeightSensor(apiDriftMonitor, dChannel)
            this.api            = apiDriftMonitor;
            this.dCalibratedChannelNumber = dChannel;
        end
        
        function d = get(this)
            d = this.api.getHeightSensorValue(6 + );
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
        
        function setSampleAverage(this, dN)
            this.dSampleAverage = dN;
        end
    end
    
    
    methods (Access = protected)
        
        
        
    end
        
    
end

