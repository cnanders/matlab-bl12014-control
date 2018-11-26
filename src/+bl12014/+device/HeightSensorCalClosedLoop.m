classdef HeightSensorCalClosedLoop < mic.interface.device.GetSetNumber
       
    
    properties (Constant)
        
        
    end
    
    properties
       
    end
    
    properties (SetAccess = private)
        
        cName = 'device-height-sensor-cal-closed-loop'
    end
    
    
    
    properties (Access = private)
        
        
        % {< mic.interface.device.GetSetNumber 1x1}
        stage
        
        % {< mic.interface.device.GetNumber 1x1}
        calHeightSensor
        
        % {mic.Clock 1x1}
        clock
                
        % {double 1x1} value passed into set() used during the iterative
        % march
        dSetGoal
        
        % {double 1x1} desired tolerance in nm
        dTolerance = 2; % Tolerance for a single Wafer Z move
        
        
        % Set this when each time wafer z changes target
        dCurrentZTarget_urad
        
        % {uint8 1x1 maximum number of moves of the wafer fine z}
        u8MovesMax = uint8(5);
        
        % Amount of time to wait for stage before timeout
        dStageWaitTime = 30 % seconds
        % Delay between successive polling of stage values
        dStageCheckPeriod = 0.4 %seconds
        
        % {logical 1x1} 
        lReady = true
        lIsCoarseCorrecting = false; % Waiting for deferred action scheduler to finish coarse move
        
        % {mic.Scan 1x1}
        scan
        
        % {double 1x1} number of samples to average when getting a value
        % from the Height Sensor drift monitor
%         u8SampleAverage = 50
%         u8SampleAverageDuringControl = 200;

        % (RM: 8/24) halving values to prevent feedback instability
        u8SampleAverage = 25
        u8SampleAverageDuringControl = 50;
        % {logical 1x1} set to true to debug the scan
        lDebugScan = true
        
         %UI handles for updating goals
        uiStage 
         
    end
    
    methods
        
        function this = HeightSensorCalClosedLoop(clock, stage, calHeightSensor, uiStage, varargin)
            

            this.clock = clock;
            this.stage = stage;
            this.calHeightSensor = calHeightSensor;
            this.uiStage = uiStage;
            
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
            d = this.calHeightSensor.get();                        
        end
        
        
        function l = isReady(this)
            l = this.lReady;
        end
        
        function stop(this)
            this.stage.stop();
            this.lReady = true;
        end
        
        function initialize(this)
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
        function set(this, dVal)
            this.lReady = false;
             this.msg('\n****setting ready to false\n', this.u8_MSG_TYPE_SCAN);
             
             
            dUradToMrad = 1/1000;
            dMradToUrad = 1000;
            % Now move fine stage:
            for k = 1:this.u8MovesMax
                this.msg(sprintf('Making move move on iteration %d\n', k), this.u8_MSG_TYPE_SCAN);
                dError                  = dVal - this.readHS();
                dstageURad               = this.stage.get() ;
                
                dstageGoal             = (dstageURad + dError*dMradToUrad);
                
                this.dCurrentZTarget_urad = dstageGoal ;
                
                this.uiStage.setDestCal(dstageGoal, 'urad');
                this.uiStage.moveToDest();
                
%                 this.stage.set(dstageGoal);
                if (~this.waitForStage(this.stage))
                    this.msg('Z Fine Stage timed out\n', this.u8_MSG_TYPE_SCAN);
                    this.lReady = true;
                    return
                end
                % Recheck error:
                dError                  = dVal - this.readHS();
                this.msg(sprintf('\nClosed loop error is %0.1f nm\n', dError), this.u8_MSG_TYPE_SCAN);
                if (abs(dError) <= this.dTolerance)
                    this.msg('\n**** within tolerance, setting ready to true\n', this.u8_MSG_TYPE_SCAN);
                    this.lReady = true;
                    return
                end
                this.msg('cal Stage not within tolerance out\n', this.u8_MSG_TYPE_SCAN);
            end
            
            fprintf('Cal closed loop failed\n');
            this.lReady = true;
        end
        
        % Waits for a stage to be ready
        % {mic.device 1x1} stage - stage that implements mic.device
        function lSuccess = waitForStage(this, stage)
            dNWaitCycles = this.dStageWaitTime / this.dStageCheckPeriod;
            for k = 1:dNWaitCycles
                if stage.isReady()
                    fprintf('**Stage is ready!!\n');
                    lSuccess = true;
                    return
                end
                fprintf('Stage is NOT ready\n');
                pause(this.dStageCheckPeriod);
            end
             lSuccess = true;
        end  
        
        % Reads height sensor after a short delay
        function dcalHeightSensor = readHS(this)
            pause(0.5);
            dcalHeightSensor = this.calHeightSensor.get();
        end
        
%     
        
    end
    
    methods (Access = private)
         
    end
        
    
end

