classdef GetLogicalConnect < mic.interface.device.GetLogical
    
    % This device will be used with a quasi-hack of the 
    % mic.ui.device.GetLogical UI control
    %
    % When the mic.ui.device.GetLogical init button is pressed,
    % the initialize() method is evoked. Use the method to call
    % a provided function that returns a logical and use the returned logical to
    % update the isInitialized property.  
    %
    % Let get() always return true.
    % we won't be displaying the logical state.  Since isInitialized is
    % called on a timer, the UI will display the correct state
    
    properties (Access = private)
        
        % {function_handle 1x1} that returns a logical
        fh
        
    end
            
    methods
        
        function this = GetLogicalConnect(fh)
            this.fh = fh;
        end
        
        function l = get(this)
            l = true;
        end
        
        function initialize(this)
            this.fh();
        end

        function l = isInitialized(this)
           l = this.fh();
        end
        
    end
        
    
end

