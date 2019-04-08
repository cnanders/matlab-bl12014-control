classdef GetSetNumberFromMightexUniversalLedController < mic.interface.device.GetSetNumber
    
    % Translates cxro.common.device.motion.Stage to mic.interface.device.GetSetNumber
    
    properties (Access = private)
        
        % {< mightex.UniversalLedController 1x1}
        comm
        
        % {uint8 1xm} the axis to control
        u8Channel
    end
    
    methods
        
        function this = GetSetNumberFromMightexUniversalLedController(comm, u8Channel)
            this.comm = comm;
            this.u8Channel = u8Channel;
        end
        
        function d = get(this)
            % st = this.comm.getChannelData(this.u8Channel);
            % d = st.Normal_CurrentSet;
            d = this.comm.getCurrentNormalModeCached(this.u8Channel);
        end
        
        function set(this, dVal)
            this.comm.setNormalModeCurrent(this.u8Channel, dVal);
        end
        
        function l = isReady(this)
            l = true;
        end
        
        function stop(this)
            
        end
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
        
    
end

