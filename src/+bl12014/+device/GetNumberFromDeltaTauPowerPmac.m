classdef GetNumberFromDeltaTauPowerPmac < mic.interface.device.GetNumber
    
    % Translates datatranslation.MeasurPoint to mic.interface.device.GetNumber
    
    properties (Constant)
        cTYPE_RETICLE_CAP_1 = 'reticle-cap-1'
        cTYPE_RETICLE_CAP_2 = 'reticle-cap-2'
        cTYPE_RETICLE_CAP_3 = 'reticle-cap-3'
        cTYPE_RETICLE_CAP_4 = 'reticle-cap-4'

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
                    d = this.comm.getReticleCap1V();
                case this.cTYPE_RETICLE_CAP_2
                    d = this.comm.getReticleCap2V();
                case this.cTYPE_RETICLE_CAP_3
                    d = this.comm.getReticleCap3V();
                case this.cTYPE_RETICLE_CAP_4
                    d = this.comm.getReticleCap4V();
                
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

