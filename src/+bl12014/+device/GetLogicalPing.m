classdef GetLogicalPing < mic.interface.device.GetLogical
    
    % This device pings the provided IP address.  If the address is
    % reachable, returns true.  Otherwise it returns false
    
    properties (Access = private)
        
        
        % {java.net.InetAddress 1x1}        
        % jInetAddress
        
        % {char 1xm} host name
        cHostname = 'google.com'
        
        % {uint16 1x1} communication port
        u16Port = 80
        
        % {double 1x1} timeout (ms) for the ping test
        dTimeout = 500

    end
    
    
            
    methods
        
        
        %{
        function this = GetLogicalPing(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp(varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            try
                this.jInetAddress = java.net.InetAddress.getByName(this.cHostname);
            catch mE
                this.jInetAddress = [];
            end
        end
        
        function l = get(this)
            
            if isempty(this.jInetAddress)
                l = false;
                return
            end
            
            l = this.jInetAddress.isReachable(this.dTimeout);
            
        end
        
        function initialize(this)
            
        end

        function l = isInitialized(this)
           l = true;
        end
        %}
        
        
        function this = GetLogicalPing(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp(varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            
        end
        
        function l = get(this)
            
            jNetworkDevice = NetworkDevice(this.cHostname, this.u16Port, this.dTimeout);
            try 
                if jNetworkDevice.isReachable()
                    l = true;
                    return;
                else
                    l = false;
                    return;
                end
            catch mE
                l = false;
            end
                       
        end
        
        function initialize(this)
            
        end

        function l = isInitialized(this)
           l = true;
        end
    end
        
end

