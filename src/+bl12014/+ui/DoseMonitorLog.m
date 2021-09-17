classdef DoseMonitorLog < mic.ui.common.List
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        dLatest = 0
        
    end
    
    properties (Access=private)

        hardware
        
    end
    
    methods 
        
        function this = DoseMonitorLog(varargin)
            
                        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            % Check hardware
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.lShowDelete = false;
            this.lShowMove = false;
            this.lShowRefresh = false;
            this.cLabel = 'MDM (unit = 1M photoelectrons)';
            
            
        end
        
        
        function this = appendLatest(this)
                
            dVal = this.hardware.getDoseMonitor().getCharge(this.hardware.getSR570MDM().getSensitivity());
            
            dVal = dVal/ 1e6; % millions of electrons
            
            dVal = round(dVal);
            
            this.dLatest = dVal;
            
            cVal = num2str(dVal);
            this.append(cVal);
            %% 
            
        end
        
        
        function dVal = getLatest(this)
            dVal = this.dLatest;
        end
        
 
    end
    
end

