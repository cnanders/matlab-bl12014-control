classdef GetSetNumberFromBL1201CorbaProxy < mic.interface.device.GetSetNumber
    
    % Translates cxro.common.device.motion.Stage to mic.interface.device.GetSetNumber
    
    
    properties (Constant)
        
        cDEVICE_UNDULATOR_GAP = 'undulator_gap'
        cDEVICE_GRATING_TILT_X = 'grating_tilt_x'
    end
    
    
    properties (Access = private)
        
        % {< cxro.bl1201.beamline.BL1201CorbaProxy 1x1}
        comm
        
        % {char 1xm} the device to control
        cDevice
        
        % {double 1x1} storage of the undulator goal to build own isThere()
        % method
        dGoalUndulator
        
        lMonoIsInitialized = false;
    end
    
    methods
        
        function this = GetSetNumberFromBL1201CorbaProxy(comm, cDevice)
            this.comm = comm;
            this.cDevice = cDevice;
        end
        
        function d = get(this)
            switch (this.cDevice)
                case this.cDEVICE_UNDULATOR_GAP
                    d = this.comm.SCA_getIDGap();
                case this.cDEVICE_GRATING_TILT_X
                    d = this.comm.Mono_GetPositionRaw();
            end
            
        end
        
        function set(this, dVal)
            
            switch (this.cDevice)
                case this.cDEVICE_UNDULATOR_GAP
                    this.comm.SCA_setIDGap(dVal);
                    this.dGoalUndulator = dVal;
                                        
                case this.cDEVICE_GRATING_TILT_X
                    this.comm.Mono_MoveRaw(dVal);
                
            end
            
            
        end
        
        function l = isReady(this)
            
            switch (this.cDevice)
                case this.cDEVICE_UNDULATOR_GAP
                    % there is no 'is_there' method so need to build our
                    % own
                    
                    %{
                    dError = this.comm.SCA_getIDGap() - this.dGoalUndulator;
                    if (abs(dError) > 0.1) 
                        l = true;
                    else
                        l = false;
                    end
                    %}
                    l = ~this.comm.SCA_getIDMotionComplete();
                                        
                case this.cDEVICE_GRATING_TILT_X
                    l = logical(this.comm.Mono_MotionCompleteRaw(50));
                
            end
            
            
        end
        
        function stop(this)
            
            switch (this.cDevice)
                case this.cDEVICE_UNDULATOR_GAP
                    % No access to this functionality
                    % If it is gained, need to update dGoalUndulator so 
                    % isThere can use it
                    
                case this.cDEVICE_GRATING_TILT_X
                    this.comm.Mono_StopMove();
                
            end
            
        end
        
        function initialize(this)
            
            switch (this.cDevice)
                case this.cDEVICE_UNDULATOR_GAP
                    % do nothing
                    
                case this.cDEVICE_GRATING_TILT_X
                    this.lMonoIsInitialized = this.comm.Mono_FindIndex();
                    
                
            end
            
        end
        
        function l = isInitialized(this)
            
            switch (this.cDevice)
                case this.cDEVICE_UNDULATOR_GAP
                    l = true;
                                        
                case this.cDEVICE_GRATING_TILT_X
                    l = this.lMonoIsInitialized;
                
            end
            
        end
        
    end
        
    
end

