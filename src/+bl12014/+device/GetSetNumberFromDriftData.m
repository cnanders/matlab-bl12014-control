classdef GetSetNumberFromDriftData < mic.interface.device.GetSetNumber
    
    % Translates cxro.common.device.motion.Stage to mic.interface.device.GetSetNumber
    
    properties (Access = private)
        
        % {< cxro.common.device.motion.Stage 1x1}
        comm
        
        % {uint8 1xm} the axis to control
        u8Axis
    end
    
    methods
        
        function this = GetSetNumberFromDriftData(comm, u8Axis)
            this.comm = comm;
            this.u8Axis = u8Axis;
        end
        
        function d = get(this)
            d = this.comm.getAxisPosition(this.u8Axis);
        end
        
        function set(this, dVal)
            % this.comm.setAxisPosition(this.u8Axis, dVal);
            this.comm.moveAxisAbsolute(this.u8Axis, dVal);
        end
        
        function l = isReady(this)
            l = this.comm.getAxisIsReady(this.u8Axis);
        end
        
        function stop(this)
            this.comm.stopAxisMove(this.u8Axis);
        end
        
        function initialize(this)
            this.comm.initializeAxis(this.u8Axis)
        end
        
        function l = isInitialized(this)
            l = this.comm.getAxisIsInitialized(this.u8Axis);
        end
        
    end
        
    
end

