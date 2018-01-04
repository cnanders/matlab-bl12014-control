classdef GetSetLogicalConnect < mic.interface.device.GetSetLogical
    
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
        
        fhGet
        
        % {function_handle 1x1} that returns a logical
        fhSetTrue
        
        % {function_handle 1x1} that returns a logical
        fhSetFalse
        
        % {logical 1x1} if successfully connected to a COMM device
        lConnected = false
        
    end
            
    methods
        
        function this = GetSetLogicalConnect(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
        end
        
        function l = get(this)
            l = this.fhGet();
        end
        
        function set(this, lVal)
            if lVal
                this.fhSetTrue();
            else
                this.fhSetFalse();
            end
        end
        
        function initialize(this)
            % do nothing
        end

        function l = isInitialized(this)
           l = true;
        end
        
    end
        
    
end

