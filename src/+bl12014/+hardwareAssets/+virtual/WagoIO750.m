classdef WagoIO750 < handle
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
        
        lD141 = false;
        
    end
    
    methods
        
        
        function this = WagoIO750()
            
            
        end
        
        % Returns {logical 1x1} state of the D141 pneumatic feedthrough
        function l = getD141(this)
            l = this.lD141;
        end
        
        % Sets the in/out state of the D141 pneumatic feedthrough
        function setD141(this, lVal)
            this.lD141 = lVal;
        end
                
        
    end
     
    
end

