classdef GetSetNumberFromExitSlit < mic.interface.device.GetSetNumber
    
    % Wraps functions from vendor/pnaulleau/bl12-exit-slit as
    % a mic.interface.device.GetSetNumber
    
    properties (Access = private)
        
        % { see vendor/pnaulleau/bl12-exit-slit}
        bl12pico
        
    end
    
    methods
        
        function this = GetSetNumberFromExitSlit(bl12pico)
            this.bl12pico = bl12pico;
        end
        
        function d = get(this)
            
            [slit,e,estr] = bl12pico_getSlitGap(this.bl12pico);
            d = slit.gap;
        end
        
        function set(this, dVal)
            fprintf('bl12014.device.GetSetNumberFromExitSlit.set(%1.3f)\n', dVal);
            [e,estr] = bl12pico_setSlitGapNoblock(this.bl12pico, dVal);
            
        end
        
        function l = isReady(this)
            l = true; 
        end
        
        function stop(this)
            [e,estr]=bl12pico_stopAll(this.bl12pico);
        end
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
        
    
end

