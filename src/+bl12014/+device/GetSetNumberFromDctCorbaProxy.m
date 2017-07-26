classdef GetSetNumberFromDctCorbaProxy < mic.interface.device.GetSetNumber
    
    % Translates cxro.common.device.motion.Stage to mic.interface.device.GetSetNumber
    
    
    properties (Constant)
        
        cDEVICE_SHUTTER = 'shutter'
    end
    
    
    properties (Access = private)
        
        % {< cxro.bl1201.beamline.DCTCorbaProxy 1x1}
        comm
        
        % {char 1xm} the device to control
        cDevice
        
        
    end
    
    methods
        
        function this = GetSetNumberFromDctCorbaProxy(comm, cDevice)
            this.comm = comm;
            this.cDevice = cDevice;
        end
        
        function d = get(this)
            switch (this.cDevice)
                case this.cDEVICE_SHUTTER
                    d = this.comm.IsOpen();
                
            end
            
        end
        
        function set(this, dVal)
            
            switch (this.cDevice)
                case this.cDEVICE_SHUTTER
                    this.comm.TriggerN(dVal)
                
            end
            
            
            this.stage.setAxisPosition(this.u8Axis, dVal);
        end
        
        function l = isReady(this)
            
            switch (this.cDevice)
                case this.cDEVICE_SHUTTER
                    l = ~this.comm.IsOpen();
            end
            
            
        end
        
        function stop(this)
            
            switch (this.cDevice)
                case this.cDEVICE_SHUTTER
                    this.comm.Abort()
            end
            
        end
        
        function initialize(this)
            
            switch (this.cDevice)
                case this.cDEVICE_SHUTTER
                    % do nothing                
            end
            
            this.stage.initializeAxis(this.u8Axis)
        end
        
        function l = isInitialized(this)
            
            switch (this.cDevice)
                case this.cDEVICE_SHUTTER
                    l = true;
                                                        
            end
            
        end
        
    end
        
    
end

