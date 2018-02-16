classdef GetSetNumberFromMightex < mic.interface.device.GetSetNumber
        
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
        u8Channel
    end
    
    methods
        
        function this = GetSetNumberFromMightex(u8Channel)
            this.u8Channel = u8Channel;
        end
        
        function d = get(this)
            switch (this.u8Channel)
                case {1, 2, 3, 4, 5, 6}
                    d = 100e-3 + 10e-3 * randn(1);
                otherwise
                    d = 200e-3;
            end
            
        end
        
        function set(this, dVal)
            
            % Nothing
            
        end
        
        function l = isReady(this)
            
          l = true;
            
            
        end
        
        function stop(this)
            
            % Nothing
            
        end
        
        function initialize(this)
            
            % Nothing
            
        end
        
        function l = isInitialized(this)
            
            l = true
            % Nothing
            
        end
        
    end
        
    
end

