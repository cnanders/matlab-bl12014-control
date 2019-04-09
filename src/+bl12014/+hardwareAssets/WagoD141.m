classdef WagoD141 < handle
    
    % Modbus communication with Wago IO750 coils that control
    % the D141 pneumatic feedthrough
    
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
        
        
        function this = WagoD141(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}));
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
        function l = get(this)
            
            % when in, coil 3 is true when out coil 1 is true
            l = read(this.comm, 'coils', 3); 
        end
        
        % Sets the in/out state of the D141 pneumatic feedthrough
        function set(this, lVal)
            
            % To insert, set coil 1 to true
            
            % Need to cast logical to double which is what 
            % the write method needs
            
            write(this.comm, 'coils', 1, double(lVal))
        end
                
        
    end
    
    methods (Access = private)
        
        function msg(~, cMsg)
            fprintf('bl12014.hardwareAssets.WagoD141 %s\n', cMsg);
        end
        
        function l = hasProp(this, c)
            
            l = false;
            if ~isempty(findprop(this, c))
                l = true;
            end
            
        end
        
    end
    
    
    
    
        
    
end

