classdef GetNumberFromMFDriftMonitor < mic.interface.device.GetNumber
    
    
    properties (Constant)
        cTYPE_TEMP_THERMOCOUPLE = 'temp-thermocouple'
        cTYPE_TEMP_RTD = 'temp-rtd'
        cTYPE_VOLTAGE = 'voltage'
    end
    
    properties (Access = private)
        
        api
        
        % {uint8 1xm} the channel to read
        u8Channel
        
        % {char 1xm} see Constants cTYPE_*
        cType
            
    end
    
    methods
        
        function this = GetNumberFromMFDriftMonitor(api, cType, varargin)
            this@mic.ui.common.ScanSetup(varargin{:});
            
            this.comm = comm;
            this.cType = cType;
            
            
        end
        
        function d = get(this)
            switch this.cType
                case this.cTYPE_TEMP_RTD
                    d = this.comm.measure_temperature_rtd(this.u8Channel);
                case this.cTYPE_TEMP_THERMOCOUPLE
                    d = this.comm.measure_temperature_tc(this.u8Channel);
                case this.cTYPE_VOLTAGE
                    d = this.comm.measure_voltage(this.u8Channel);
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

