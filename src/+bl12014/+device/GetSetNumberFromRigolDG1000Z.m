classdef GetSetNumberFromRigolDG1000Z < mic.interface.device.GetSetNumber
    
    % Translates rigol.DG1000Z to mic.interface.device.GetSetNumber
    
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
        
        % {< cxro.bl1201.beamline.RigolDG1000Z 1x1}
        comm
        
        % {uint8 1x1}
        u8Channel
        
    end
    
    methods
        
        function this = GetSetNumberFromRigolDG1000Z(comm, u8Channel)
            this.comm = comm;
            this.u8Channel = u8Channel;
        end
        
        function d = get(this)
            
            l = this.comm.getIsOn(this.u8Channel);
            if l == true
                d = 1;
            else
                d = 0;
            end
                        
        end
        
        function set(this, dVal)
            
            this.comm.trigger5VTTLPulse(this.u8Channel, dVal)
            
        end
        
        function l = isReady(this)
            
            d = this.get();
            if d == 0
                l = true;
            else 
                l = false;
            end
            
            
        end
        
        function stop(this)
            
            this.comm.turnOff5VTTL(this.u8Channel);
            
        end
        
        function initialize(this)
            
            
        end
        
        function l = isInitialized(this)
            
            l = true;
            
        end
        
    end
        
    
end

