classdef MotMinReticleDaemon < mic.Base
        
    properties (Constant)
        
        
        
    end
    
	properties
        clock
        hardware
        
                
    end
    

    
    properties (SetAccess = private)
        
        % {double 1x1}
        dTolerance = 0.1 % um
        
        % {double 1x1} seconds - if position is held to within dTolerance
        % for dDuration seconds, MonMin is set to zero for reticle stage
        dDuration = 20 % sec  
        
        
        % {double 1x1} storage 
        dXLast = 0
        dYLast = 0
        
        % {double 1x1} output of tic from last time position changed
        % by more than dTolerance
        dTicReset
        
        cName = 'reticle-mot-min-daemon-'
        
    end
    
        
    

    
    methods
        
        % Constructor
        function this = MotMinReticleDaemon(varargin)
            
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            
            this.dTicReset = tic;
            this.clock.add(@this.onClock, this.id(), 1);
            
        end
        
        
        % Destructor
        function delete(this)
            
            if isvalid(this.clock) && ...
                this.clock.has(this.id())
                this.clock.remove(this.id());
            end
        end
        
        function setMotMinToZero(this)
                            
            if abs(this.hardware.getDeltaTauPowerPmac().getMotMinReticleCoarseX()) > 0.01
                fprintf('MotMinReticleDaemon setting MotMin of ReticleCoarseX to 0. \n');
                fprintf('No moves > %1.1f um during last %1.0f seconds \n', ...
                    this.dTolerance, ...
                    this.dDuration ...
                );
                    
                this.hardware.getDeltaTauPowerPmac().setMotMinReticleCoarseX(0);
            end

            if abs(this.hardware.getDeltaTauPowerPmac().getMotMinReticleCoarseY()) > 0.01
                fprintf('MotMinReticleDaemon setting MotMin of ReticleCoarseY to 0. \n');
                fprintf('No moves > %1.1f um during last %1.0f seconds \n', ...
                    this.dTolerance, ...
                    this.dDuration ...
                );
                this.hardware.getDeltaTauPowerPmac().setMotMinReticleCoarseY(0);
            end
        end
        

    end 
    
    methods (Access = private)
        
        
        function onClock(this, src, evt)
            
            lDebug = false;
            
            
            dXCurrent = this.hardware.getDeltaTauPowerPmac().getXReticleCoarse();
            dYCurrent = this.hardware.getDeltaTauPowerPmac().getYReticleCoarse();
            
            if lDebug
                
                fprintf('MotMinReticleDaemon.onClock() at %1.1f sec dX = %1.3f; dXLast = %1.3f\n', ...
                    toc(this.dTicReset), ...
                    dXCurrent, ...
                    this.dXLast ...
                );
            
                fprintf('MotMinReticleDaemon.onClock() at %1.1f sec dY = %1.3f; dYLast = %1.3f\n', ...
                    toc(this.dTicReset), ...
                    dYCurrent, ...
                    this.dYLast ...
                );
            
            end
            
            if abs(dXCurrent - this.dXLast) > this.dTolerance || ...
               abs(dYCurrent - this.dYLast) > this.dTolerance ...
                
                % Reset
                this.dTicReset = tic;
           
            end
            
            this.dXLast = dXCurrent;
            this.dYLast = dYCurrent;
            
            if toc(this.dTicReset) > this.dDuration
                
                this.setMotMinToZero();
                
            end
            
            
        end
        
    end
    
    
end