% This is a bridge between getNumber and actual device api

classdef GetNumberFromSimpleHeightSensorZ < mic.interface.device.GetNumber
    
    
    properties (Constant)
        
    end
    
    properties (Access = private)
        
        % Handle to the MFDriftMonitor middleware.  Only one of these for
        % all GenNumbers
        api
        
        dSampleAverage = 50
    end
    
    methods
        
        function this = GetNumberFromSimpleHeightSensorZ(apiDriftMonitor)
            this.api            = apiDriftMonitor;
        end
        
        function d = get(this)
            d = this.api.getSimpleZ(this.dSampleAverage);
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

