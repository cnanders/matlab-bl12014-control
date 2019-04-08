classdef BL1201CorbaProxy < handle
        
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
        
        dGap = 40.24;
        dMono = 13.5
        
    end
    
    methods
        
        function this = BL1201CorbaProxy()
            
        end
        
        
        %% SCA (Undulator)
        
        function d = SCA_getIDGap(this)
            d = this.dGap;
        end
        
        function SCA_setIDGap(this, dVal)
            this.dGap = dVal;
        end
        
        % For some reason the real version of this returns the opposite of
        % what the value says so retutn false
        function l = SCA_getIDMotionComplete(this)
            l = false;
        end
        
        
        %% Mono
        
        
        
        function d = Mono_GetPositionRaw(this)
            d = this.dMono;
        end
        
        function Mono_MoveRaw(this, dVal)
            this.dMono = dVal;    
        end
        
        function l = Mono_MotionCompleteRaw(this, dTolerance)
            l = true;
        end
                
        function Mono_StopMove(this)
        end
                
        function Mono_FindIndex(this)
        end
        
        
    end
        
    
end

