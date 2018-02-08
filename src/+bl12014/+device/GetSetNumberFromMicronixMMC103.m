classdef GetSetNumberFromMicronixMMC103 < mic.interface.device.GetSetNumber
    
    % Translates micronix.MMC103 to mic.interface.device.GetSetNumber
    
    properties (Access = private)
        
        % {< micronix.MMC103 1x1}
        comm
        
        % {uint8 1xm} the axis to control
        u8Axis
        
        % {timer 1x1}
        timer
        
        % {double 1x1} poling delay in seconds.  Each time onBytesAvailable
        % is invoked (whenever the result is available), a new timer is
        % started with this start delay, before invoking onTimer(), which 
        % begins the next read cycle
        dDelay = 1;
        dPeriod = 1;
        
        % {logical 1x1} storage for if the stage has been zeroed after it
        % reaches the index mark following a home command.  The stage has 
        % odd behavior which is that the HOM command does not reset the 
        % encoder and theoretical position to 0 at the index mark.  The
        % setCurrentPositionAsZero() method needs to be called but this
        % then resets the return of getHomed() to false so a second 
        % call of home() needs to be evoked so that getHomed() returns true
        % Bu
        lZeroedAtIndexAfterHome = false
    
    end
    
    methods
        
        function this = GetSetNumberFromMicronixMMC103(comm, u8Axis)
            this.comm = comm;
            this.u8Axis = u8Axis;
            
            if (this.u8Axis == 1)
                
                % Create a timer that is used for the initial home() and
                % setting zero at index marker routine
                
                this.timer = timer(...
                    'Name', 'GetSetNumberFromMicronixMMC103 homing', ...
                    'StartDelay', this.dDelay, ...
                    'Period', this.dPeriod, ...
                    'ExecutionMode', 'fixedDelay', ...
                    'TimerFcn', @this.onTimer ...
                );
            end
        end
        
        function delete(this)
            delete(this.timer)
        end
        
        function d = get(this)
            d = this.comm.getEncoderPosition(this.u8Axis);
        end
        
        function set(this, dVal)
            % moveAbsolute cannot be called again while in motion so always
            % stop motion before issuing a new absolute destination
            this.comm.stopMotion(this.u8Axis)
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
            switch (this.u8Axis)
                case 1
                    this.comm.home(this.u8Axis);
                    
                    if (~this.lZeroedAtIndexAfterHome)
                        % wait for home command to finish executing, then
                        % need to set the current position (which will be the index mark)
                        % to zero
                        
                        if strcmp(this.timer.Running, 'off')
                            start(this.timer);
                        else
                            % fprintf('bl12014.device.GetSetNumberFromMicronixMMC103.initialize() not starting timer. Already running.\n');
                        end
                    end
                    
                case 2
                    % Do nothing, operates in open loop
                    
            end
            
        end
        
        function l = isInitialized(this)
            
            switch (this.u8Axis)
                case 1
                    l = this.comm.getHomed(this.u8Axis) || this.lZeroedAtIndexAfterHome;
                case 2
                    l = true;
            end           
        end
        
    end
    
    
    methods (Access = protected)
        
        function onTimer(this, obj, evt)
            
            lDebug = true;
            lDebug && fprintf('bl12014.device.GetSetNumberFromMicronixMMC103.onTimer()\n');
            
            if (this.isInitialized())
                
                lDebug && fprintf('Initialized, stopping timer; setting zero; initializing again\n');
                
                % stage is now at index marker, set current location to
                % zero.  This will unset the getHomed() return
                
                stop(this.timer);
                
                this.comm.setCurrentPositionAsZero(this.u8Axis)
                this.lZeroedAtIndexAfterHome = true;
                
                
                % issue initialize one more time so that isInitialized() 
                % will return true for remainder of use
                % NO LONGER DOING THIS.  
                % this.initialize()
                
            else 
                lDebug && fprintf('Not initialized, not stopping timer\n');
                % Check again
                % stop(this.timer);
                % start(this.timer); % waits dDelay, then executes onTimer again
            end
        end
        
    end
        
    
end

