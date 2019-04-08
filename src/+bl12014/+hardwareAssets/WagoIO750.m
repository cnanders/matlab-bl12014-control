classdef WagoIO750 < handle
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
        
        % {modbus 1x1}
        comm
      
        % {char 1xm} IP/URL
        cHost = '192.168.10.26'
        
        % {double 1x1} timeout
        dTimeout = 5
        
    end
    
    methods
        
        
        function this = WagoIO750(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            
            try
                % modbus requires instrument control toolbox
                cTransport = 'tcpip';
                this.comm = modbus(...
                    cTransport, ...
                    this.cHost, ...
                    'Timeout', this.dTimeout ...
                );
                
            catch mE
                this.comm = [];
                % Will crash the app, but gives lovely stack trace.
                error(getReport(mE));
                
            end
            
        end
        
        % Returns {logical 1x1} state of the D141 pneumatic feedthrough
        function l = getD141(this)
            
            % when in, coil 3 is true when out coil 1 is true
            l = read(this.comm, 'coils', 3); 
        end
        
        % Sets the in/out state of the D141 pneumatic feedthrough
        function setD141(this, lVal)
            
            % To insert, set coil 1 to true
            
            % Need to cast logical to double which is what 
            % the write method needs
            
            write(this.comm, 'coils', 1, double(lVal))
        end
                
        
    end
    
    methods (Access = private)
        
        function msg(~, cMsg)
            fprintf('bl12014.hardwareAssets.WagoIO750 %s\n', cMsg);
        end
        
        function l = hasProp(this, c)
            
            l = false;
            if ~isempty(findprop(this, c))
                l = true;
            end
            
        end
        
    end
    
    
    
    
        
    
end

