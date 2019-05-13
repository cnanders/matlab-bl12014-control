classdef DCTCorbaProxy < handle
        
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
              
        % {timer 1x1}
        t
        
        % {logical 1x1}
        lOpen = false
    end
    
    methods
        
        function this = DCTCorbaProxy()
            
            this.t = timer(...
                'Name', 'DCT Corba Proxy (Virtual)' ...
            );
            this.t.TimerFcn = @this.onTimer;
            
        end
        
                
        function Abort(this)
            
            if strcmp(this.t.Running, 'on')
            	stop(this.t);
            end
            
            this.lOpen = false;
        end
        
        function l = isOpen(this)
            l = this.lOpen;
        end
        
        % @param {double 1x1} dVal - seconds
        function triggerN(this, dVal)
            stop(this.t);
            this.t.StartDelay = dVal;
            start(this.t);
            this.lOpen = true;
        end
                
    end
    
    methods (Access = protected)
        
        function onTimer(this, src, evt)
            this.lOpen = false;
            stop(this.t)
        end
        
    end
        
    
end

