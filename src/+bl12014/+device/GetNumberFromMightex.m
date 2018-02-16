classdef GetNumberFromMightex < mic.interface.device.GetNumber
    
    % Translates keithley.Keithley6482 to mic.interface.device.GetNumber
    
    properties (Access = private)
        
        
        % {uint8 1xm} the channel to read
        u8Channel
            
    end
    
    methods
        
        function this = GetNumberFromMightex(u8Channel)
            this.u8Channel = u8Channel;            
        end
        
        function d = get(this)
            
            calllib('', 
            d = this.comm.read(this.u8Channel);
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

