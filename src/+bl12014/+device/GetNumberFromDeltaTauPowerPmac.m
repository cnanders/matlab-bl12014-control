classdef GetNumberFromDeltaTauPowerPmac < mic.interface.device.GetNumber
    
    % Translates datatranslation.MeasurPoint to mic.interface.device.GetNumber
    
    properties (Constant)
        cTYPE_RETICLE_CAP_1 = 'reticle-cap-1'
        cTYPE_RETICLE_CAP_2 = 'reticle-cap-2'
        cTYPE_RETICLE_CAP_3 = 'reticle-cap-3'
        cTYPE_RETICLE_CAP_4 = 'reticle-cap-4'
        
        cTYPE_WAFER_CAP_1 = 'wafer-cap-1'
        cTYPE_WAFER_CAP_2 = 'wafer-cap-2'
        cTYPE_WAFER_CAP_3 = 'wafer-cap-3'
        cTYPE_WAFER_CAP_4 = 'wafer-cap-4'
    end
    
    properties (Access = private)
        
        % {< deltatau.PowerPmac 1x1}
        comm
        
        % {char 1xm} see Constants cTYPE_*
        cType
            
    end
    
    methods
        
        function this = GetNumberFromDeltaTauPowerPmac(comm, cType)
            this.comm = comm;
            this.cType = cType;
        end
        
        function d = get(this)
            switch this.cType
                case this.cTYPE_RETICLE_CAP_1
                    d = this.comm.getVoltageReticleCap1();
                case this.cTYPE_RETICLE_CAP_2
                    d = this.comm.getVoltageReticleCap2();
                case this.cTYPE_RETICLE_CAP_3
                    d = this.comm.getVoltageReticleCap3();
                case this.cTYPE_RETICLE_CAP_4
                    d = this.comm.getVoltageReticleCap4();
                case this.cTYPE_WAFER_CAP_1
                    d = this.comm.getAcc28EADCValue(3,0);
                case this.cTYPE_WAFER_CAP_2
                    d = this.comm.getAcc28EADCValue(3,1);
                case this.cTYPE_WAFER_CAP_3
                    d = this.comm.getAcc28EADCValue(3,2);
                case this.cTYPE_WAFER_CAP_4
                    d = this.comm.getAcc28EADCValue(3,3);
            end
            
        end
                
        function l = isReady(this)
            l = true;  
        end
        
        
        function initialize(this)
            % do nothing
        end
        
        function l = isInitialized(this)
            l = true;         
        end
        
    end
    
    
    methods (Access = protected)
        
        
        
    end
        
    
end

