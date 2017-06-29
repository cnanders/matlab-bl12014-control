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
        
        % {function_handle 1x1} that returns a logical
        fhConnect
        
        % {function_handle 1x1} that returns a logical
        fhDisconnect
        
        % {logical 1x1} if successfully connected to a COMM device
        lConnected = false
        
    end
            
    methods
        
        function this = GetSetLogicalConnect(varargin)
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
        end
        
        function l = get(this)
            l = this.lConnected;
        end
        
        function set(this, lVal)
            if lVal
                this.lConnected = this.fhConnect();
            else
                this.fhDisconnect();
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

