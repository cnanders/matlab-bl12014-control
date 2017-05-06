classdef GetSetNumberFromNewFocusModel8742 < mic.interface.device.GetSetNumber
    
    % Translates newfocus.Model8742 to mic.interface.device.GetSetNumber
    
    properties (Access = private)
        
        % {< newfocus.Model8742 1x1}
        comm
        
        % {uint8 1xm} the axis to control
        u8Axis
    end
    
    methods
        
        function this = GetSetNumberFromNewFocusModel8742(comm, u8Axis)
            this.comm = comm;
            this.u8Axis = u8Axis;
        end
        
        function d = get(this)
            d = this.comm.getPosition(this.u8Axis);
        end
        
        function set(this, dVal)
            this.comm.moveToTargetPosition(this.u8Axis, dVal);
        end
        
        function l = isReady(this)
            l = this.comm.getMotionDoneStatus(this.u8Axis);
        end
        
        function stop(this)
            this.comm.stop(this.u8Axis);
        end
        
        function initialize(this)
            % Don't know what to do here
            % this.comm.initializeAxis(this.u8Axis)
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
        
    
end

