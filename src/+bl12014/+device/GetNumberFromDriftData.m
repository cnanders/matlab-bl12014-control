classdef GetNumberFromDriftData < mic.interface.device.GetNumber
    
    % Translates cxro.common.device.motion.Stage to mic.interface.device.GetSetNumber
    
    properties (Access = private)
        
        % {< cxro.common.device.motion.Stage 1x1}
        comm
        
        % {char 1xm} the axis to control
        cType
    end
    
    methods
        
        function this = GetNumberFromDriftData(comm, cType)
            this.comm = comm;
            this.cType = cType;
        end
        
        function d = get(this)
            switch cType
                case 'z'
                    d = this.comm.getzValue();
            end
        end
        
        
        function initialize(this)
            % Nothing
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
        
    
end

