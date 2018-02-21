classdef GetSetNumberFromExitSlitObject < mic.interface.device.GetSetNumber
    
    % Wraps functions from vendor/pnaulleau/bl12-exit-slit as
    % a mic.interface.device.GetSetNumber
    
    properties (Access = private)
        
        % { see vendor/pnaulleau/bl12-exit-slit}
        comm
        
    end
    
    methods
        
        function this = GetSetNumberFromExitSlitObject(comm)
            this.comm = comm;
        end
        
        function d = get(this)
            
            [slit,e,estr] = this.comm.getSlitGap();
            d = slit.gap;
        end
        
        function set(this, dVal)
            fprintf('bl12014.device.GetSetNumberFromExitSlitObject.set(%1.3f)\n', dVal);
            [e,estr] = this.comm.setSlitGap(dVal);
            
        end
        
        function l = isReady(this)
            l = this.comm.CLstatus == 0;
        end
        
        function stop(this)
           % [e,estr]= this.comm.stopAll();
           [e,estr]= this.comm.abortAll();
        end
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
        
    
end

