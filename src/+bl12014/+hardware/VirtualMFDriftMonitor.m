% This is a bridge between hardware device and MATLAB UI

classdef VirtualMFDriftMonitor < bl12014.hardware.MFDriftMonitor
    
    
    properties
        lIsConnected = false
    end
    
    properties (Access = private)
    end
    
    methods
        
        function this = VirtualMFDriftMonitor(varargin)
            this@bl12014.hardware.MFDriftMonitor(varargin{:});
        end
        
        function connect(this)
            if ~this.isConnected()
                this.lIsConnected = true;
            end
        end
        
        function disconnect(this)
            if this.isConnected()
                this.lIsConnected = false;
            end
        end
        
        function lVal = isConnected(this)
            lVal = this.lIsConnected;
        end
        
        function l = isReady(this)
            l = this.lIsConnected;
        end  
    end
    
    methods (Access = protected)
         % Updates HS and DMI data from actual device
        function updateChannelData(this)

                this.dHSChannelData = [1, 2, 3, 4, 5, 6]';
                
                
                this.dDMIData = [1, 2 ; 3, 4];

        end
        
        
        function initInterpolants(this)
            % load stCalibrationData
%             this.initCalibrationInterpolant(stCalibrationData);
            this.initGeometricInterpolant();
        end
        
        
        
    end
    
    
     
    
end

