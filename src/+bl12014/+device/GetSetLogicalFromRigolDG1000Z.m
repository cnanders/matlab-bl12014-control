classdef GetSetLogicalFromRigolDG1000Z < mic.interface.device.GetSetLogical
    
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
        
        function this = GetSetLogicalFromRigolDG1000Z(comm, u8Channel)
            this.comm = comm;
            this.u8Channel = u8Channel;
        end
        
        function l = get(this)
            l = this.comm.getIsOn(this.u8Channel);
        end
        
        function set(this, lVal)
            
            if lVal == true
                this.comm.turnOn5VTTL(this.u8Channel);
            else
                this.comm.turnOff5VTTL(this.u8Channel);
            end            
        end
        
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
        
    
end

