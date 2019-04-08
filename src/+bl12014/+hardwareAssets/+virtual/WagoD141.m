classdef WagoD141 < handle
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
        
        lVal = false;
        
    end
    
    methods
        
        
        function this = WagoD141()
            
            
        end
        
        % Returns {logical 1x1} state of the D141 pneumatic feedthrough
        function l = get(this)
            l = this.lVal;
        end
        
        % Sets the in/out state of the D141 pneumatic feedthrough
        function set(this, lVal)
            this.lVal = lVal;
        end
                
        
    end
     
    
end

