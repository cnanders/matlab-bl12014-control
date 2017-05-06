classdef GetSetNumberFromMicronixMMC103 < mic.interface.device.GetSetNumber
    
    % Translates micronix.MMC103 to mic.interface.device.GetSetNumber
    
    properties (Access = private)
        
        % {< micronix.MMC103 1x1}
        comm
        
        % {uint8 1xm} the axis to control
        u8Axis
    end
    
    methods
        
        function this = GetSetNumberFromMicronixMMC103(comm, u8Axis)
            this.comm = comm;
            this.u8Axis = u8Axis;
        end
        
        function d = get(this)
            d = this.comm.getPosition(this.u8Axis);
        end
        
        function set(this, dVal)
            this.comm.moveAbsolute(this.u8Axis, dVal);
        end
        
        function l = isReady(this)
            l = this.comm.getIsStopped(this.u8Axis);
        end
        
        function stop(this)
            this.comm.stopMotion(this.u8Axis);
        end
        
        function initialize(this)
            % Don't know what stuff to call here
            % this.comm.initializeAxis(this.u8Axis)
        end
        
        function l = isInitialized(this)
            l = true;
            % l = this.comm.getAxisIsInitialized(this.u8Axis);
        end
        
    end
        
    
end

