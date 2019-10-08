

classdef Buffer < handle
    
    % abbr = win    
   	
    properties (Constant)
       
        
    end
    
    
    properties
                
        dBuffer

    end
    
    properties (Access = private)
                
        dSize
        dPushes = 0;
       
    end
    
    events
        
    end
    
       
    methods (Static)
        
    end
    
    methods
        
        
        function this = Buffer(dSize)
            
            this.dSize      = dSize;
            this.dBuffer    = zeros(1, this.dSize);
            
        end
        
        function push(this, dVal)
            
           % circshift sucks 
           % this.dBuffer     = circshift(this.dBuffer', 1)';
           
           this.dBuffer     = [dVal, this.dBuffer(1:end-1)];           
           this.dPushes     = this.dPushes + 1;
                   
        end
        
        
        function dReturn = avg(this)
            
            if this.dPushes == 0
                dReturn = 0;
                return
            end
            
            if this.dPushes < this.dSize
                % return average of populated values
                dReturn = mean(this.dBuffer(1 : this.dPushes));
                return;
            end
            
            dReturn = mean(this.dBuffer);
            
        end
        
        function lReturn = full(this)
            
            lReturn = this.dPushes >= this.dSize;
            
        end
        
        function purge(this)
           
            this.dPushes = 0;
            this.dBuffer = zeros(1, this.dSize);
            
        end
        
                
    end
end
    
    
    