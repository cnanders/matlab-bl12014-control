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
        
        % W === wafer
        % R === reticle
        % LSI === lateral sheraring interferometer
        % C = coarse
        cWCX_MOT_MIN = 'wcx-mot-min'
        cWCY_MOT_MIN = 'wcy-mot-min'
        cRCX_MOT_MIN = 'rcx-mot-min'
        cRCY_MOT_MIN = 'rcy-mot-min'
        cLSICX_MOT_MIN = 'lsicx-mot-min'
        
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
                case this.cWCX_MOT_MIN
                    d = this.comm.getWaferCoarseXMotMin();
                case this.cWCY_MOT_MIN
                    d = this.comm.getWaferCoarseYMotMin();
                case this.cRCX_MOT_MIN
                    d = this.comm.getReticleCoarseXMotMin();
                case this.cRCY_MOT_MIN
                    d = this.comm.getReticleCoarseYMotMin();  
                case this.cLSICX_MOT_MIN
                    d = this.comm.getLsiCoarseXMotMin();     
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
            
            if isnan(dVal)
                fprintf('GetSetNumberFromDeltaTauPowerPmac.set() passed NaN. Skipping\n');
                return
            end
            
            switch this.cAxis
                
                case this.cWCX_MOT_MIN
                    cCmd = sprintf('Hydra1UMotMinNorm1=%1.3f', dVal);
                    this.comm.command(cCmd);
                case this.cWCY_MOT_MIN
                    cCmd = sprintf('Hydra1UMotMinNorm2=%1.3f', dVal);
                    this.comm.command(cCmd);
                case this.cRCX_MOT_MIN
                    cCmd = sprintf('Hydra2UMotMinNorm1=%1.3f', dVal);
                    this.comm.command(cCmd);
                case this.cRCY_MOT_MIN
                    cCmd = sprintf('Hydra2UMotMinNorm2=%1.3f', dVal);
                    this.comm.command(cCmd);  
                case this.cLSICX_MOT_MIN
                    cCmd = sprintf('Hydra3UMotMinNorm1=%1.3f', dVal);
                    this.comm.command(cCmd); 
                    
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
                
                case {...
                    this.cWCX_MOT_MIN, ...
                    this.cWCY_MOT_MIN, ...
                    this.cRCX_MOT_MIN, ...
                    this.cRCY_MOT_MIN, ...
                    this.cLSICX_MOT_MIN ...
                    }
                    l = true;
                case {...
                    this.cAXIS_WAFER_COARSE_X, ...
                    this.cAXIS_WAFER_COARSE_Y, ...
                    this.cAXIS_WAFER_COARSE_Z, ...
                    this.cAXIS_WAFER_COARSE_TIP, ...
                    this.cAXIS_WAFER_COARSE_TILT ...
                    }
                    l = ~this.comm.getWaferCoarseXYZTipTiltStarted();
                case { ...
                   this.cAXIS_RETICLE_COARSE_X, ...
                   this.cAXIS_RETICLE_COARSE_Y, ...
                   this.cAXIS_RETICLE_COARSE_Z, ...
                   this.cAXIS_RETICLE_COARSE_TIP, ...
                   this.cAXIS_RETICLE_COARSE_TILT, ...
                    }
                    l = ~this.comm.getReticleCoarseXYZTipTiltStarted(); 
                case this.cAXIS_WAFER_FINE_Z
                    l = ~this.comm.getWaferFineZStarted();  
                case { ...
                        this.cAXIS_RETICLE_FINE_X, ...
                        this.cAXIS_RETICLE_FINE_Y ...
                     }
                    l = ~this.comm.getReticleFineXYStarted();
                case this.cAXIS_LSI_COARSE_X
                    l = ~this.comm.getLSICoarseXStarted();
            end
            
            
            %{
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
            %}
            
            if ~isscalar(l)
                fprintf('GetSetNumberFromDeltaTauPowerPmac.isReady() received non scalar from comm, returning false\n');
                l = false;
                return
            end
            
            if ~islogical(l)
                fprintf('GetSetNumberFromDeltaTauPowerPmac.isReady() received non logical from comm, returning false\n');
                l = false;
                return;
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

