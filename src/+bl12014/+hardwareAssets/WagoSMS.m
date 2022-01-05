classdef WagoSMS < handle
    
    % Modbus communication with EUV Tech SMS
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
        
        % {modbus 1x1}
        comm
      
        % {char 1xm} IP/URL
        cHost = '192.168.10.26'
        
        % {double 1x1} timeout
        dTimeout = 5
        
        ticGetVariables
        tocMin = 0.1;
        
        % {logical} storage for all answers
        lAll = false(1, 10);
        
        
        u8IndexBeamlineOpen = 1
        
        
    end
    
    methods
        
        
        function this = WagoSMS(varargin)
            
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
        
        
        % Returns {double 1xm} of each coil
        function l = getAll(this)
            
            % tic
            
            if ~isempty(this.ticGetVariables)
                if (toc(this.ticGetVariables) < this.tocMin)
                    % Use storage
                    l = this.lAll;
                    % toc
                    % fprintf('PowerPmac.getAll() using cache\n');
                    return;
                end
            end
            
                        
            % Reset tic and update storate
            
            dAddress = 1;
            dNum = 10;
            l = logical(read(this.comm, 'coils', dAddress, dNum));
            this.lAll = l;
            this.ticGetVariables = tic();

            
        end        
        
        function l = getBeamlineOpen(this)
            lAll = this.getAll();
            l = lAll(this.u8IndexBeamlineOpen);
        end
        
        function l = getBeamlineBusy(this)
            lAll = this.getAll();
            l = lAll(this.u8IndexBeamlineBusy);
        end
        
        function l = getOnlineMode(this)
            lAll = this.getAll();
            l = lAll(this.u8IndexOnlineMode);
        end
        
        function l = getRemoteMode(this)
            lAll = this.getAll();
            l = lAll(this.u8IndexRemoteMode);
        end
        
        function l = getSourceOn(this)
            lAll = this.getAll();
            l = lAll(this.u8IndexSourceOn);
        end
        
        function l = getSourceError(this)
            lAll = this.getAll();
            l = lAll(this.u8IndexSourceError);
        end
        
        function l = getVacuumOK(this)
            lAll = this.getAll();
            l = lAll(this.u8IndexVacuumOK);
        end
        
        function l = getRoughingPumpsOK(this)
            lAll = this.getAll();
            l = lAll(this.u8IndexRoughingPumpsOK);
        end
        
        function l = getSystemWarning(this)
            lAll = this.getAll();
            l = lAll(this.u8IndexSystemWarning);
        end
        
        function l = getSystemError(this)
            lAll = this.getAll();
            l = lAll(this.u8IndexSystemError);
        end
        
        
        function setBeamlineOpen(this, lVal)
            write(this.comm, 'coils', this.u8CoilBeamlineOpen, double(lVal))
        end
        
        
       
                    
        
    end
    
    methods (Access = private)
        
        function msg(~, cMsg)
            fprintf('bl12014.hardwareAssets.WagoSMS %s\n', cMsg);
        end
        
        function l = hasProp(this, c)
            
            l = false;
            if ~isempty(findprop(this, c))
                l = true;
            end
            
        end
        
    end
    
    
    
    
        
    
end

