
% Device for GetSetNumber that performs a set operations in closed loop
% until the a specified tolerance is met.
%
% This class has two constructs:
%
% 1) SENSOR - user supplies a getter and a tolerance to "sensor".
% When the value returned by the getter differs from the set destination of
% the GSN by less than the tolerance, the device is said to have reached its state.
%
% 2) MOTOR - user supplies a getter and a setter.  New motor desitination
% is calculated using the sensor error times the "P" value of the supplied
% PID parameters.  Default PID is set to [1, 0, 0] which assumes that the
% sensor and motor have the same units and the same sense.  



classdef GetSetNumberFromClosedLoopControl < mic.interface.device.GetSetNumber
       
    
    properties (Constant)
    end
    
    properties
    end
    
    properties (SetAccess = private)
        cName = 'device-closed-loop-control'
    end
    
    
    properties (Access = private)
        
        % {mic.Clock 1x1}
        clock
        
        % {lambda() 1x1: double - gets the current sensor reading}
        fhGetSensor
        
        % {lambda() 1x1: double - gets the current motor reading}
        fhGetMotor
        
        % {lambda(dVal) 1x1: void - sets the motor to the specified value}
        fhSetMotor
        
        % {lambda() 1x1: boolean - returns if the motor is ready}
        fhIsReadyMotor
        
        % {double 1x1 - specifies the tolerance in default units for acceptance}
        dTolerance
        
        % {double 1x1 - specifies the delay in seconds before checking acceptance condition}
        dDelay = 0
        
        % {double 1x3 specifies the P, I, and D coefficients}
        dPID = [1, 0, 0]
        
        % {uint8 1x1 maximum number of set moves before giving up}
        u8MovesMax = uint8(5);
        
        % Amount of time to wait for set move before timeout
        dStageWaitTime = 30 % seconds
        
        % Delay between successive polling of fhGet calls
        dStageCheckPeriod = 0.4 %seconds
        
        % {logical 1x1} 
        lReady = true
        
         
    end
    
    methods
        
        function this = GetSetNumberFromClosedLoopControl(clock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance, varargin)

            this.clock                  = clock;
            this.fhGetSensor            = fhGetSensor;
            this.fhGetMotor             = fhGetMotor;
            this.fhSetMotor             = fhSetMotor;
            this.fhIsReadyMotor         = fhIsReadyMotor;
            this.dTolerance             = dTolerance;
            
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end 
            
            
        end
        
        
        % @return {double 1x1} the value of the height sensor in nm
        function d = get(this)
            d = this.fhGetSensor();                        
        end
        
        
        function l = isReady(this)
            l = this.lReady;
        end
        
        function stop(this)
            this.stage.stop();
            this.lReady = true;
        end
        
        function initialize(~)
        end
        
        function l = isInitialized(~)
            l = true;
        end
        
        % Called when destination is set
        function set(this, dSensorDestination)
            
            u8iterationCt = 0;
            dLastError = 0;
            
            while abs(dSensorDestination - this.fhGetSensor()) > this.dTolerance
                this.lReady = false;
                u8iterationCt = u8iterationCt + 1;
                
                this.msg(sprintf('Making move move on iteration %d\n', u8iterationCt), this.u8_MSG_TYPE_SCAN);
                
                dErrorSensor    = dSensorDestination - this.fhGetSensor();
                
                dErrorMotorP    = dErrorSensor * this.dPID(1);
                dErrorMotorI    = -dLastError * this.dPID(2);
                dErrorMotorD    = -(dErrorMotorP - dLastError) * this.dPID(3);
                
                dErrorMotor = dErrorMotorP + dErrorMotorI + dErrorMotorD;
                dLastError  = dErrorMotorP;
                
                % Check maximum iteration failure:
                if (u8iterationCt > this.u8MovesMax)
                     this.msg(sprintf('Maximum iterations exceeded, terminating with sensor error val: %0.3f\n', dErrorSensor), this.u8_MSG_TYPE_SCAN);
                     this.lReady = true;
                     return
                end
                
                dDestMotor = this.fhGetMotor() + dErrorMotor;
                
                this.fhSetMotor(dDestMotor);
                
                if (~this.waitForStage(this.fhIsReadyMotor))
                    this.msg('Motor timed out\n', this.u8_MSG_TYPE_SCAN);
                    this.lReady = true;
                    return
                end
                                
                % Delay time to wait for a sensor to update, useful in
                % control systems where the sensor does not react
                % immediately to a motor move
                if (this.dDelay > 0)
                    pause(this.dDelay)
                end
                
            end
            
            this.msg('Close loop complete \n', this.u8_MSG_TYPE_SCAN);
            this.lReady = true;
        end
        
        % Waits for a stage to be ready
        % {mic.device 1x1} stage - stage that implements mic.device
        function lSuccess = waitForStage(this, isReady)
            dNWaitCycles = this.dStageWaitTime / this.dStageCheckPeriod;
            for k = 1:dNWaitCycles
                if isReady()
                    this.msg('** Stage is ready!!\n', this.u8_MSG_TYPE_SCAN);
                    lSuccess = true;
                    return
                end
                this.msg('Stage is NOT ready\n', this.u8_MSG_TYPE_SCAN);
                pause(this.dStageCheckPeriod);
            end
            lSuccess = false;
        end  
        

    end
    
    methods (Access = private)
         
    end
        
    
end

