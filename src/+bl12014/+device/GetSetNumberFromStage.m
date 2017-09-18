classdef GetSetNumberFromStage < mic.interface.device.GetSetNumber
    
    % Translates cxro.common.device.motion.Stage to mic.interface.device.GetSetNumber
    
    properties (Access = private)
        
        % {< cxro.common.device.motion.Stage 1x1}
        stage
        
        % {uint8 1xm} the axis to control
        u8Axis
    end
    
    methods
        
        function this = GetSetNumberFromStage(stage, u8Axis)
            this.stage = stage;
            this.u8Axis = u8Axis;
        end
        
        function d = get(this)
            d = this.stage.getAxisPosition(this.u8Axis);
        end
        
        function set(this, dVal)
            % this.stage.setAxisPosition(this.u8Axis, dVal);
            this.stage.moveAxisAbsolute(this.u8Axis, dVal);
        end
        
        function l = isReady(this)
            l = this.stage.getAxisIsReady(this.u8Axis);
        end
        
        function stop(this)
            this.stage.stopAxisMove(this.u8Axis);
        end
        
        function initialize(this)
            this.stage.initializeAxis(this.u8Axis)
        end
        
        function l = isInitialized(this)
            l = this.stage.getAxisIsInitialized(this.u8Axis);
        end
        
    end
        
    
end

