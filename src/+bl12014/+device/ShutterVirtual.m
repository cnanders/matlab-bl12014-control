classdef ShutterVirtual < mic.interface.device.GetSetNumber

    properties (Access = private)
        
        lOpen = false
        % {timer 1x1}
        t
        
        lIsInitialized = false
        
    end


    properties
        cName;
    end

            
    methods
        
        function this = ShutterVirtual()
            this.t = timer(...
                'Name', 'Shutter Virtual' ...
            );
            this.t.TimerFcn = @this.onTimer;
        end

        function dReturn = get(this)
            if this.lOpen
                dReturn = 0.5; % Slope is 2 and want it to show 1
            else
                dReturn = 0;
            end
            
            % dReturn = double(this.lOpen);
        end


        function lIsReady = isReady(this)
            lIsReady = ~this.lOpen;
        end
        
        
        function set(this, dDest)

            % Create a timer that executes after dDest * 2 ms
            stop(this.t);
            this.t.StartDelay = dDest * 2e-3;
            start(this.t);
            this.lOpen = true;

        end 

        function stop(this)
            
            if strcmp(this.t.Running, 'on')
            	stop(this.t);
            end
            this.lOpen = false;
        end

       
        function delete(this)

            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);
            this.stop();
            delete(this.t)

        end
        
        
        function initialize(this)
            this.lIsInitialized = true;
        end
        
        function l = isInitialized(this)
            l = this.lIsInitialized;
        end
        
        

    end %methods
    
    methods (Access = protected)
        
        function onTimer(this, src, evt)
            this.lOpen = false;
            stop(this.t)
        end
        
    end
    
end %class
    

            
            
            
        