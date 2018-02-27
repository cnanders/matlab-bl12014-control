classdef GetNumberFromStageEncoder < mic.interface.device.GetNumber
    
    % Translates cxro.common.device.motion.Stage to mic.interface.device.GetSetNumber
    
    properties (Access = private)
        
        % {< cxro.common.device.motion.Stage 1x1}
        stage
        
        % {uint8 1xm} the axis to control
        u8Axis
    end
    
    methods
        
        function this = GetNumberFromStageEncoder(stage, u8Axis)
            this.stage = stage;
            this.u8Axis = u8Axis;
        end
        
        function d = get(this)
            d = this.stage.getAxisAnalog(this.u8Axis);
        end
        
        function initialize(this)
            this.stage.initializeAxis(this.u8Axis)
        end
        
        function l = isInitialized(this)
            l = this.stage.getAxisIsInitialized(this.u8Axis);
        end
        
    end
        
    
end

