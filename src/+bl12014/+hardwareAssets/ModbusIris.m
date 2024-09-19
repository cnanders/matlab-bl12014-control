classdef ModbusIris < handle
    
    % Modbus communication with EUV Tech SMS
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
        
        % {modbus 1x1}
        comm
      
        % {char 1xm} IP/URL
        cHost = '192.168.20.50'
        cPort = 5020
        
    
        
        
    end
    
    methods
        
        
        function this = ModbusIris(varargin)
            
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
                    this.cPort, ...
                    'Timeout', 5 ...
                );
                
            catch mE
                this.comm = [];
                % Will crash the app, but gives lovely stack trace.
                error(getReport(mE));
            end
            
        end

        function dVal = getCounts(this)
            dVal = read(this.comm, 'holdingregs', 1, 1);
        end
        
        % @param {uint8 1x1} - zero-indexed axis
        function setCounts(this, dVal)
            dVal = round(dVal);
            write(this.comm, 'coils', 1, 1);
            write(this.comm, 'holdingregs', 3, dVal);
        end

        function zeroCounts(this)
            write(this.comm, 'coils', 15, 1);
        end

        function abortMove(this)
            write(this.comm, 'coils', 5, 1);
        end
    end
    
    methods (Access = private)
        
        function msg(~, cMsg)
            fprintf('bl12014.hardwareAssets.Iris %s\n', cMsg);
        end
        
        function l = hasProp(this, c)
            
            l = false;
            if ~isempty(findprop(this, c))
                l = true;
            end
            
        end
        
    end
    
    
    
    
        
    
end

