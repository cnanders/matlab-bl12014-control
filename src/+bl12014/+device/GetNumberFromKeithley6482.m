classdef GetNumberFromKeithley6482 < mic.interface.device.GetNumber
    
    % Translates keithley.Keithley6482 to mic.interface.device.GetNumber
    
    properties (Access = private)
        
        % {< keithley.Keithley6482 1x1}
        comm
        
        % {uint8 1xm} the channel to read
        u8Channel
            
    end
    
    methods
        
        function this = GetNumberFromKeithley6482(comm, u8Channel)
            this.comm = comm;
            this.u8Channel = u8Channel;            
        end
        
        function d = get(this)
            dNAve = 1;
            dS = zeros(1,dNAve);
            for k = 1:dNAve
                dS(k) = this.comm.read(this.u8Channel);
                
            end
            d = mean(dS);
%             d = this.comm.read(this.u8Channel);
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

