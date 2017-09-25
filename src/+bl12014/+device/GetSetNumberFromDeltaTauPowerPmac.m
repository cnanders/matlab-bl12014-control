classdef GetSetNumberFromDeltaTauPowerPmac < mic.interface.device.GetSetNumber
    
    % Translates deltatau.PowerPmac to mic.interface.device.GetSetNumber
    
    properties (Constant)
        
        cAXIS_WAFER_COARSE_X = 'wafer-coarse-x'
        cAXIS_WAFER_COARSE_Y = 'wafer-coarse-y'
        cAXIS_WAFER_COARSE_Z = 'wafer-coarse-z'
        cAXIS_WAFER_COARSE_TIP = 'wafer-coarse-tip'
        cAXIS_WAFER_COARSE_TILT = 'wafer-coarse-tilt'
        cAXIS_WAFER_FINE_Z = 'wafer-fine-z'
        
        cAXIS_LSI_COARSE_X = 'lsi-coarse-x'
        
        cAXIS_RETICLE_COARSE_X = 'reticle-coarse-x'
        cAXIS_RETICLE_COARSE_Y = 'reticle-coarse-y'
        cAXIS_RETICLE_COARSE_Z = 'reticle-coarse-z'
        cAXIS_RETICLE_COARSE_TIP = 'reticle-coarse-tip'
        cAXIS_RETICLE_COARSE_TILT = 'reticle-coarse-tilt'
        cAXIS_RETICLE_FINE_X = 'reticle-fine-x'
        cAXIS_RETICLE_FINE_Y = 'reticle-fine-y'
        
    end
    
    
    properties (Access = private)
        
        % {< deltatau.PowerPmac (MET5) 1x1}
        comm
        
        % {char 1xm} the axis to control (see cAXIS_* constants)
        cAxis
    end
    
    methods
        
        function this = GetSetNumberFromDeltaTauPowerPmac(comm, cAxis)
            this.comm = comm;
            this.cAxis = cAxis;
        end
        
        function d = get(this)
            
            switch this.cAxis
                case this.cAXIS_WAFER_COARSE_X
                    d = this.comm.getWaferCoarseX();
                case this.cAXIS_WAFER_COARSE_Y
                    d = this.comm.getWaferCoarseY();
                case this.cAXIS_WAFER_COARSE_Z
                    d = this.comm.getWaferCoarseZ();
                case this.cAXIS_WAFER_COARSE_TIP
                    d = this.comm.getWaferCoarseTip();
                case this.cAXIS_WAFER_COARSE_TILT
                    d = this.comm.getWaferCoarseTilt();
                case this.cAXIS_WAFER_FINE_Z
                    d = this.comm.getWaferFineZ();
                case this.cAXIS_LSI_COARSE_X
                    d = this.comm.getLsiCoarseX();
                case this.cAXIS_RETICLE_COARSE_X
                    d = this.comm.getReticleCoarseX();
                case this.cAXIS_RETICLE_COARSE_Y
                    d = this.comm.getReticleCoarseY();
                case this.cAXIS_RETICLE_COARSE_Z
                    d = this.comm.getReticleCoarseZ();
                case this.cAXIS_RETICLE_COARSE_TIP
                    d = this.comm.getReticleCoarseTip();
                case this.cAXIS_RETICLE_COARSE_TILT
                    d = this.comm.getReticleCoarseTilt();
                case this.cAXIS_RETICLE_FINE_X
                    d = this.comm.getReticleFineX();
                case this.cAXIS_RETICLE_FINE_Y
                    d = this.comm.getReticleFineY();
            end
                    
        end
        
        function set(this, dVal)
            switch this.cAxis
                case this.cAXIS_WAFER_COARSE_X
                    this.comm.setWaferCoarseX(dVal);
                case this.cAXIS_WAFER_COARSE_Y
                    this.comm.setWaferCoarseY(dVal);
                case this.cAXIS_WAFER_COARSE_Z
                    this.comm.setWaferCoarseZ(dVal);
                case this.cAXIS_WAFER_COARSE_TIP
                    this.comm.setWaferCoarseTip(dVal);
                case this.cAXIS_WAFER_COARSE_TILT
                    this.comm.setWaferCoarseTilt(dVal);
                case this.cAXIS_WAFER_FINE_Z
                    this.comm.setWaferFineZ(dVal);
                case this.cAXIS_LSI_COARSE_X
                    this.comm.setLsiCoarseX(dVal);
                case this.cAXIS_RETICLE_COARSE_X
                    this.comm.setReticleCoarseX(dVal);
                case this.cAXIS_RETICLE_COARSE_Y
                    this.comm.setReticleCoarseY(dVal);
                case this.cAXIS_RETICLE_COARSE_Z
                    this.comm.setReticleCoarseZ(dVal);
                case this.cAXIS_RETICLE_COARSE_TIP
                    this.comm.setReticleCoarseTip(dVal);
                case this.cAXIS_RETICLE_COARSE_TILT
                    this.comm.setReticleCoarseTilt(dVal);
                case this.cAXIS_RETICLE_FINE_X
                    this.comm.setReticleFineX(dVal);
                case this.cAXIS_RETICLE_FINE_Y
                    this.comm.setReticleFineY(dVal);
            end
        end
        
        function l = isReady(this)
            switch this.cAxis
                case this.cAXIS_WAFER_COARSE_X
                    l = ~this.comm.getMotorStatusWaferCoarseXIsMoving();
                case this.cAXIS_WAFER_COARSE_Y
                    l = ~this.comm.getMotorStatusWaferCoarseYIsMoving();
                case this.cAXIS_WAFER_COARSE_Z
                    l = ~this.comm.getMotorStatusWaferCoarseZIsMoving();
                case this.cAXIS_WAFER_COARSE_TIP
                    l = ~this.comm.getMotorStatusWaferCoarseTipIsMoving();
                case this.cAXIS_WAFER_COARSE_TILT
                    l = ~this.comm.getMotorStatusWaferCoarseTiltIsMoving();
                case this.cAXIS_WAFER_FINE_Z
                    l = ~this.comm.getMotorStatusWaferFineZIsMoving();
                case this.cAXIS_LSI_COARSE_X
                    l = ~this.comm.getMotorStatusLsiCoarseXIsMoving();
                case this.cAXIS_RETICLE_COARSE_X
                    l = ~this.comm.getMotorStatusReticleCoarseXIsMoving();
                case this.cAXIS_RETICLE_COARSE_Y
                    l = ~this.comm.getMotorStatusReticleCoarseYIsMoving();
                case this.cAXIS_RETICLE_COARSE_Z
                    l = ~this.comm.getMotorStatusReticleCoarseZIsMoving();
                case this.cAXIS_RETICLE_COARSE_TIP
                    l = ~this.comm.getMotorStatusReticleCoarseTipIsMoving();
                case this.cAXIS_RETICLE_COARSE_TILT
                    l = ~this.comm.getMotorStatusReticleCoarseTiltIsMoving();
                case this.cAXIS_RETICLE_FINE_X
                    l = ~this.comm.getMotorStatusReticleFineXIsMoving();
                case this.cAXIS_RETICLE_FINE_Y
                    l = ~this.comm.getMotorStatusReticleFineXIsMoving();
            end
        end
        
        function stop(this)
            
            % unknown - email to PI 2017.08.02
            this.comm.stopAll();
            
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

