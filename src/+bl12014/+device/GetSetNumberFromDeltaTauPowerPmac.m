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
        cMOT_MIN_WCX = 'wcx-mot-min'
        cMOT_MIN_WCY = 'wcy-mot-min'
        cMOT_MIN_RCX = 'rcx-mot-min'
        cMOT_MIN_RCY = 'rcy-mot-min'
        cMOT_MIN_LSIX = 'lsicx-mot-min'
        
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
                case this.cMOT_MIN_WCX
                    d = this.comm.getMotMinWaferCoarseX();
                case this.cMOT_MIN_WCY
                    d = this.comm.getMotMinWaferCoarseY();
                case this.cMOT_MIN_RCX
                    d = this.comm.getMotMinReticleCoarseX();
                case this.cMOT_MIN_RCY
                    d = this.comm.getMotMinReticleCoarseY();  
                case this.cMOT_MIN_LSIX
                    d = this.comm.getMotMinLsiCoarseX();     
                case this.cAXIS_WAFER_COARSE_X
                    d = this.comm.getXWaferCoarse();
                case this.cAXIS_WAFER_COARSE_Y
                    d = this.comm.getYWaferCoarse();
                case this.cAXIS_WAFER_COARSE_Z
                    d = this.comm.getZWaferCoarse();
                case this.cAXIS_WAFER_COARSE_TIP
                    d = this.comm.getTiltXWaferCoarse();
                case this.cAXIS_WAFER_COARSE_TILT
                    d = this.comm.getTiltYWaferCoarse();
                case this.cAXIS_WAFER_FINE_Z
                    d = this.comm.getZWaferFine();
                case this.cAXIS_LSI_COARSE_X
                    d = this.comm.getXLsiCoarse();
                case this.cAXIS_RETICLE_COARSE_X
                    d = this.comm.getXReticleCoarse();
                case this.cAXIS_RETICLE_COARSE_Y
                    d = this.comm.getYReticleCoarse();
                case this.cAXIS_RETICLE_COARSE_Z
                    d = this.comm.getZReticleCoarse();
                case this.cAXIS_RETICLE_COARSE_TIP
                    d = this.comm.getTiltXReticleCoarse();
                case this.cAXIS_RETICLE_COARSE_TILT
                    d = this.comm.getTiltYReticleCoarse();
                case this.cAXIS_RETICLE_FINE_X
                    d = this.comm.getXReticleFine();
                case this.cAXIS_RETICLE_FINE_Y
                    d = this.comm.getYReticleFine();
            end
                    
        end
        
        function set(this, dVal)
            
            if isnan(dVal)
                fprintf('GetSetNumberFromDeltaTauPowerPmac.set() passed NaN. Skipping\n');
                return
            end
            
            switch this.cAxis
                
                case this.cMOT_MIN_WCX
                    cCmd = sprintf('Hydra1UMotMinNorm1=%1.3f', dVal);
                    this.comm.command(cCmd);
                case this.cMOT_MIN_WCY
                    cCmd = sprintf('Hydra1UMotMinNorm2=%1.3f', dVal);
                    this.comm.command(cCmd);
                case this.cMOT_MIN_RCX
                    cCmd = sprintf('Hydra2UMotMinNorm1=%1.3f', dVal);
                    this.comm.command(cCmd);
                case this.cMOT_MIN_RCY
                    cCmd = sprintf('Hydra2UMotMinNorm2=%1.3f', dVal);
                    this.comm.command(cCmd);  
                case this.cMOT_MIN_LSIX
                    cCmd = sprintf('Hydra3UMotMinNorm1=%1.3f', dVal);
                    this.comm.command(cCmd); 
                    
                case this.cAXIS_WAFER_COARSE_X
                    this.comm.setXWaferCoarse(dVal);
                case this.cAXIS_WAFER_COARSE_Y
                    this.comm.setYWaferCoarse(dVal);
                case this.cAXIS_WAFER_COARSE_Z
                    this.comm.setZWaferCoarse(dVal);
                case this.cAXIS_WAFER_COARSE_TIP
                    this.comm.setTiltXWaferCoarse(dVal);
                case this.cAXIS_WAFER_COARSE_TILT
                    this.comm.setTiltYWaferCoarse(dVal);
                case this.cAXIS_WAFER_FINE_Z
                    this.comm.setZWaferFine(dVal);
                case this.cAXIS_LSI_COARSE_X
                    this.comm.setXLsiCoarse(dVal);
                case this.cAXIS_RETICLE_COARSE_X
                    this.comm.setXReticleCoarse(dVal);
                case this.cAXIS_RETICLE_COARSE_Y
                    this.comm.setYReticleCoarse(dVal);
                case this.cAXIS_RETICLE_COARSE_Z
                    this.comm.setZReticleCoarse(dVal);
                case this.cAXIS_RETICLE_COARSE_TIP
                    this.comm.setTiltXReticleCoarse(dVal);
                case this.cAXIS_RETICLE_COARSE_TILT
                    this.comm.setTiltYReticleCoarse(dVal);
                case this.cAXIS_RETICLE_FINE_X
                    this.comm.setXReticleFine(dVal);
                case this.cAXIS_RETICLE_FINE_Y
                    this.comm.setYReticleFine(dVal);
            end
        end
        
        function l = isReady(this)
            
            switch this.cAxis
                
                case {...
                    this.cMOT_MIN_WCX, ...
                    this.cMOT_MIN_WCY, ...
                    this.cMOT_MIN_RCX, ...
                    this.cMOT_MIN_RCY, ...
                    this.cMOT_MIN_LSIX ...
                    }
                    l = true;
                case {...
                    this.cAXIS_WAFER_COARSE_X, ...
                    this.cAXIS_WAFER_COARSE_Y, ...
                    this.cAXIS_WAFER_COARSE_Z, ...
                    this.cAXIS_WAFER_COARSE_TIP, ...
                    this.cAXIS_WAFER_COARSE_TILT ...
                    }
                    l = ~this.comm.getIsStartedWaferCoarseXYZTipTilt();
                case { ...
                   this.cAXIS_RETICLE_COARSE_X, ...
                   this.cAXIS_RETICLE_COARSE_Y, ...
                   this.cAXIS_RETICLE_COARSE_Z, ...
                   this.cAXIS_RETICLE_COARSE_TIP, ...
                   this.cAXIS_RETICLE_COARSE_TILT, ...
                    }
                    l = ~this.comm.getIsStartedReticleCoarseXYZTipTilt(); 
                case this.cAXIS_WAFER_FINE_Z
                    l = ~this.comm.getIsStartedWaferFineZ();  
                case { ...
                        this.cAXIS_RETICLE_FINE_X, ...
                        this.cAXIS_RETICLE_FINE_Y ...
                     }
                    l = ~this.comm.getIsStartedReticleFineXY();
                case this.cAXIS_LSI_COARSE_X
                    l = ~this.comm.getIsStartedLsiCoarseX();
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

