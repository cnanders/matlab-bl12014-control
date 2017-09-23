classdef GetLogicalFromDeltaTauPowerPmac < mic.interface.device.GetLogical
    
    % Translates deltatau.PowerPmac to mic.interface.device.GetSetNumber
    
    properties (Constant)
        
        cTYPE_CATEGORY_CS_ERROR = 'cs-error'
        cTYPE_CATEGORY_CS_STATUS = 'cs-status'
        cTYPE_CATEGORY_MOTOR_ERROR = 'motor-error'
        cTYPE_CATEGORY_MOTOR_STATUS = 'motor-status'
        cTYPE_CATEGORY_ENCODER_ERROR = 'encoder-error'
        cTYPE_CATEGORY_GLOB_ERROR = 'glob-error'
        cTYPE_CATEGORY_IO_INFO = 'io-info'
        cTYPE_CATEGORY_MET50_ERROR = 'met50-error'
        
        cTYPE_CS_ERROR_WAFER_COARSE_SOFT_LIMIT = 'cs-error-wafer-coarse-soft-limit'
        cTYPE_CS_ERROR_WAFER_COARSE_RUN_TIME = 'cs-error-wafer-coarse-run-time'
        cTYPE_CS_ERROR_WAFER_COARSE_LIMIT_STOP = 'cs-error-wafer-coarse-limit-stop'
        cTYPE_CS_ERROR_WAFER_COARSE_ERROR_STATUS = 'cs-error-wafer-coarse-error-status'
        cTYPE_CS_ERROR_WAFER_FINE_SOFT_LIMIT = 'cs-error-wafer-fine-soft-limit'
        cTYPE_CS_ERROR_WAFER_FINE_RUN_TIME = 'cs-error-wafer-fine-run-time'
        cTYPE_CS_ERROR_WAFER_FINE_LIMIT_STOP = 'cs-error-wafer-fine-limit-stop'
        cTYPE_CS_ERROR_WAFER_FINE_ERROR_STATUS = 'cs-error-wafer-fine-error-status'
        cTYPE_CS_ERROR_RETICLE_COARSE_SOFT_LIMIT = 'cs-error-reticle-coarse-soft-limit'
        cTYPE_CS_ERROR_RETICLE_COARSE_RUN_TIME = 'cs-error-reticle-coarse-run-time'
        cTYPE_CS_ERROR_RETICLE_COARSE_LIMIT_STOP = 'cs-error-reticle-coarse-limit-stop'
        cTYPE_CS_ERROR_RETICLE_COARSE_ERROR_STATUS = 'cs-error-reticle-coarse-error-status'
        cTYPE_CS_ERROR_RETICLE_FINE_SOFT_LIMIT = 'cs-error-reticle-fine-soft-limit'
        cTYPE_CS_ERROR_RETICLE_FINE_RUN_TIME = 'cs-error-reticle-fine-run-time'
        cTYPE_CS_ERROR_RETICLE_FINE_LIMIT_STOP = 'cs-error-reticle-fine-limit-stop'
        cTYPE_CS_ERROR_RETICLE_FINE_ERROR_STATUS = 'cs-error-reticle-fine-error-status'
        cTYPE_CS_ERROR_LSI_COARSE_SOFT_LIMIT = 'cs-error-lsi-coarse-soft-limit'
        cTYPE_CS_ERROR_LSI_COARSE_RUN_TIME = 'cs-error-lsi-coarse-run-time'
        cTYPE_CS_ERROR_LSI_COARSE_LIMIT_STOP = 'cs-error-lsi-coarse-limit-stop'
        cTYPE_CS_ERROR_LSI_COARSE_ERROR_STATUS = 'cs-error-lsi-coarse-error-status'
        
        
        cTYPE_CS_STATUS_WAFER_COARSE_NOT_HOMED = 'cs-status-wafer-coarse-not-homed'
        cTYPE_CS_STATUS_WAFER_COARSE_TIMEBASE_DEVIATION = 'cs-status-wafer-coarse-timebase-deviation'
        cTYPE_CS_STATUS_WAFER_COARSE_PROGRAM_RUNNING = 'cs-status-wafer-coarse-program-running'
        cTYPE_CS_STATUS_WAFER_FINE_NOT_HOMED = 'cs-status-wafer-fine-not-homed'
        cTYPE_CS_STATUS_WAFER_FINE_TIMEBASE_DEVIATION = 'cs-status-wafer-fine-timebase-deviation'
        cTYPE_CS_STATUS_WAFER_FINE_PROGRAM_RUNNING = 'cs-status-wafer-fine-program-running'
        cTYPE_CS_STATUS_RETICLE_COARSE_NOT_HOMED = 'cs-status-reticle-coarse-not-homed'
        cTYPE_CS_STATUS_RETICLE_COARSE_TIMEBASE_DEVIATION = 'cs-status-reticle-coarse-timebase-deviation'
        cTYPE_CS_STATUS_RETICLE_COARSE_PROGRAM_RUNNING = 'cs-status-reticle-coarse-program-running'
        cTYPE_CS_STATUS_RETICLE_FINE_NOT_HOMED = 'cs-status-reticle-fine-not-homed'
        cTYPE_CS_STATUS_RETICLE_FINE_TIMEBASE_DEVIATION = 'cs-status-reticle-fine-timebase-deviation'
        cTYPE_CS_STATUS_RETICLE_FINE_PROGRAM_RUNNING = 'cs-status-reticle-fine-program-running'
        cTYPE_CS_STATUS_LSI_COARSE_NOT_HOMED = 'cs-status-lsi-coarse-not-homed'
        cTYPE_CS_STATUS_LSI_COARSE_TIMEBASE_DEVIATION = 'cs-status-lsi-coarse-timebase-deviation'
        cTYPE_CS_STATUS_LSI_COARSE_PROGRAM_RUNNING = 'cs-status-lsi-coarse-program-running'
        
        
        %% Global error
        
        cTYPE_GLOB_ERROR_HW_CHANGE_ERROR = 'glob-error-hw-change-errordf'
        cTYPE_GLOB_ERROR_NO_CLOCKS = 'glob-error-no-clocks'
        cTYPE_GLOB_ERROR_SYS_PHASE_ERROR_CTR = 'glob-error-sys-phase-error-ctr'
        cTYPE_GLOB_ERROR_SYS_RT_INT_BUSY_CTR = 'glob-error-rt-int-busy-ctr'
        cTYPE_GLOB_ERROR_SYS_RT_INT_ERROR_CTR = 'glob-error-rt-int-error-ctr'
        cTYPE_GLOB_ERROR_SYS_SERVO_BUSY_CTR = 'glob-error-servo-busy-ctr'
        cTYPE_GLOB_ERROR_SYS_SERVO_ERROR_CTR = 'glob-error-servo-error-ctr'
        cTYPE_GLOB_ERROR_WDT_FAULT = 'glob-error-wdt-fault'
        
        %% IO info
        
        cTYPE_IO_INFO_AT_RETICLE_TRANSFER_POSITION = 'io-info-at-reticle-transfer-position'
        cTYPE_IO_INFO_AT_WAFER_TRANSFER_POSITION = 'io-info-at-wafer-transfer-position'
        cTYPE_IO_INFO_ENABLE_SYSTEM_IS_ZERO = 'io-info-enable-system-is-zero'
        cTYPE_IO_INFO_LOCK_RETICLE_POSITION = 'io-info-lock-reticle-position'
        cTYPE_IO_INFO_LOCK_WAFER_POSITION = 'io-info-lock-wafer-position'
        cTYPE_IO_INFO_RETICLE_POSITION_LOCKED = 'io-info-reticle-position-locked'
        cTYPE_IO_INFO_SYSTEM_ENABLED_IS_ZERO = 'io-info-system-enabled-is-zero'
        cTYPE_IO_INFO_WAFER_POSITION_LOCKED = 'io-info-wafer-position-locked'
        
        %% MET50 error
        
        cTYPE_MET50_ERROR_712_1_NOT_CONNECTED = 'met50-error-712-1-not-connected'
        cTYPE_MET50_ERROR_712_1_READ_ERROR = 'met50-error-712-1-read-error'
        cTYPE_MET50_ERROR_712_1_WRITE_ERROR = 'met50-error-712-1-write-error'
        cTYPE_MET50_ERROR_712_2_NOT_CONNECTED = 'met50-error-712-2-not-connected'
        cTYPE_MET50_ERROR_712_2_READ_ERROR = 'met50-error-712-2-read-error'
        cTYPE_MET50_ERROR_712_2_WRITE_ERROR = 'met50-error-712-2-write-error'
        cTYPE_MET50_ERROR_C_APP_NOT_RUNNING = 'met50-error-c-app-not-running'
        cTYPE_MET50_ERROR_DMI_STATUS = 'met50-error-dmi-status'
        cTYPE_MET50_ERROR_HS_STATUS = 'met50-error-hs-status'
        cTYPE_MET50_ERROR_HYDRA_1_NOT_CONNECTED = 'met50-error-hydra-1-not-connected'
        cTYPE_MET50_ERROR_HYDRA_1_MACHINE_ERROR = 'met50-error-hydra-1-machine-error'
        cTYPE_MET50_ERROR_HYDRA_2_NOT_CONNECTED = 'met50-error-hydra-2-not-connected'
        cTYPE_MET50_ERROR_HYDRA_2_MACHINE_ERROR = 'met50-error-hydra-2-machine-error'
        cTYPE_MET50_ERROR_HYDRA_3_NOT_CONNECTED = 'met50-error-hydra-3-not-connected'
        cTYPE_MET50_ERROR_HYDRA_3_MACHINE_ERROR = 'met50-error-hydra-3-machine-error'
        cTYPE_MET50_ERROR_MOD_BUS_NOT_CONNECTED = 'met50-error-mod-bus-not-connected'
        cTYPE_MET50_ERROR_MOXA_NOT_CONNECTED = 'met50-error-moxa-not-connected'
        cTYPE_MET50_ERROR_PROXIMITY_SWITCH_WAFER_X_LSI = 'met50-error-proximity-switch-wafer-x-lsi'
        cTYPE_MET50_ERROR_TEMPERATURE_ERROR = 'met50-error-temperature-error'
        cTYPE_MET50_ERROR_TEMPERATURE_WARNING = 'met50-error-temperature-warning'
        
        
        %% Encoder error
        
        % Hydra 1
        cTYPE_ENCODER_ERROR_WAFER_COARSE_X = 'encoder-error-wafer-coarse-x'
        cTYPE_ENCODER_ERROR_WAFER_COARSE_Y = 'encoder-error-wafer-coarse-y'
        % Hyrda 2
        cTYPE_ENCODER_ERROR_RETICLE_COARSE_X = 'encoder-error-reticle-coarse-x'
        cTYPE_ENCODER_ERROR_RETICLE_COARSE_Y = 'encoder-error-reticle-coarse-y'
        % Hydra 3
        cTYPE_ENCODER_ERROR_LSI_COARSE_X = 'encoder-error-lsi-coarse-x'
        % 712 1
        cTYPE_ENCODER_ERROR_WAFER_COARSE_Z = 'encoder-error-wafer-coarse-z'
        cTYPE_ENCODER_ERROR_WAFER_COARSE_TIP = 'encoder-error-wafer-coarse-tip'
        cTYPE_ENCODER_ERROR_WAFER_COARSE_TILT = 'encoder-error-wafer-coarse-tilt'
        cTYPE_ENCODER_ERROR_WAFER_FINE_Z = 'encoder-error-wafer-fine-z'
        % 712 2
        cTYPE_ENCODER_ERROR_RETICLE_COARSE_Z = 'encoder-error-reticle-coarse-z'
        cTYPE_ENCODER_ERROR_RETICLE_COARSE_TIP = 'encoder-error-reticle-coarse-tip'
        cTYPE_ENCODER_ERROR_RETICLE_COARSE_TILT = 'encoder-error-reticle-coarse-tilt'
        cTYPE_ENCODER_ERROR_RETICLE_FINE_X = 'encoder-error-reticle-fine-x'
        cTYPE_ENCODER_ERROR_RETICLE_FINE_Y = 'encoder-error-reticle-fine-y'
        
        %% Motor error
        
        % Hydra 1
        cTYPE_MOTOR_ERROR_WAFER_COARSE_X = 'motor-error-wafer-coarse-x'
        cTYPE_MOTOR_ERROR_WAFER_COARSE_Y = 'motor-error-wafer-coarse-y'
        % Hyrda 2
        cTYPE_MOTOR_ERROR_RETICLE_COARSE_X = 'motor-error-reticle-coarse-x'
        cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y = 'motor-error-reticle-coarse-y'
        % Hydra 3
        cTYPE_MOTOR_ERROR_LSI_COARSE_X = 'motor-error-lsi-coarse-x'
        % 712 1
        cTYPE_MOTOR_ERROR_WAFER_COARSE_Z = 'motor-error-wafer-coarse-z'
        cTYPE_MOTOR_ERROR_WAFER_COARSE_TIP = 'motor-error-wafer-coarse-tip'
        cTYPE_MOTOR_ERROR_WAFER_COARSE_TILT = 'motor-error-wafer-coarse-tilt'
        cTYPE_MOTOR_ERROR_WAFER_FINE_Z = 'motor-error-wafer-fine-z'
        % 712 2
        cTYPE_MOTOR_ERROR_RETICLE_COARSE_Z = 'motor-error-reticle-coarse-z'
        cTYPE_MOTOR_ERROR_RETICLE_COARSE_TIP = 'motor-error-reticle-coarse-tip'
        cTYPE_MOTOR_ERROR_RETICLE_COARSE_TILT = 'motor-error-reticle-coarse-tilt'
        cTYPE_MOTOR_ERROR_RETICLE_FINE_X = 'motor-error-reticle-fine-x'
        cTYPE_MOTOR_ERROR_RETICLE_FINE_Y = 'motor-error-reticle-fine-y'
        
        % Hydra 1
        cTYPE_MOTOR_ERROR_WAFER_COARSE_X_HOMING = 'motor-error-wafer-coarse-x-homing'
        cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_HOMING = 'motor-error-wafer-coarse-y-homing'
        % Hyrda 2
        cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_HOMING = 'motor-error-reticle-coarse-x-homing'
        cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_HOMING = 'motor-error-reticle-coarse-y-homing'
        % Hydra 3
        cTYPE_MOTOR_ERROR_LSI_COARSE_X_HOMING = 'motor-error-lsi-coarse-x-homing'
        
        
        % Hydra 1
        cTYPE_MOTOR_ERROR_WAFER_COARSE_X_ALTERA = 'motor-error-wafer-coarse-x-altera'
        cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_ALTERA = 'motor-error-wafer-coarse-y-altera'
        % Hyrda 2
        cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_ALTERA = 'motor-error-reticle-coarse-x-altera'
        cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_ALTERA = 'motor-error-reticle-coarse-y-altera'
        % Hydra 3
        cTYPE_MOTOR_ERROR_LSI_COARSE_X_ALTERA = 'motor-error-lsi-coarse-x-altera'
        
        %% Motor status (is moving)
        
        % Hydra 1
        cTYPE_MOTOR_STATUS_WAFER_COARSE_X = 'motor-status-wafer-coarse-x'
        cTYPE_MOTOR_STATUS_WAFER_COARSE_Y = 'motor-status-wafer-coarse-y'
        % Hyrda 2
        cTYPE_MOTOR_STATUS_RETICLE_COARSE_X = 'motor-status-reticle-coarse-x'
        cTYPE_MOTOR_STATUS_RETICLE_COARSE_Y = 'motor-status-reticle-coarse-y'
        % Hydra 3
        cTYPE_MOTOR_STATUS_LSI_COARSE_X = 'motor-status-lsi-coarse-x'
        % 712 1
        cTYPE_MOTOR_STATUS_WAFER_COARSE_Z = 'motor-status-wafer-coarse-z'
        cTYPE_MOTOR_STATUS_WAFER_COARSE_TIP = 'motor-status-wafer-coarse-tip'
        cTYPE_MOTOR_STATUS_WAFER_COARSE_TILT = 'motor-status-wafer-coarse-tilt'
        cTYPE_MOTOR_STATUS_WAFER_FINE_Z = 'motor-status-wafer-fine-z'
        % 712 2
        cTYPE_MOTOR_STATUS_RETICLE_COARSE_Z = 'motor-status-reticle-coarse-z'
        cTYPE_MOTOR_STATUS_RETICLE_COARSE_TIP = 'motor-status-reticle-coarse-tip'
        cTYPE_MOTOR_STATUS_RETICLE_COARSE_TILT = 'motor-status-reticle-coarse-tilt'
        cTYPE_MOTOR_STATUS_RETICLE_FINE_X = 'motor-status-reticle-fine-x'
        cTYPE_MOTOR_STATUS_RETICLE_FINE_Y = 'motor-status-reticle-fine-y'
        
        
    end
    
    
    properties (Access = private)
        
        % {< deltatau.PowerPmac (MET5) 1x1}
        comm
        
        % {char 1xm} the axis to control (see cAXIS_* constants)
        cAxis
        
        % {char 1xm} see cTYPE_CATEGORY_*
        cTypeCategory
        
        % {char 1xm} see cTYPE_*
        cType
    end
    
    methods
        
        function this = GetLogicalFromDeltaTauPowerPmac(comm, cType)
            
            this.comm = comm;
            this.cType = cType;
            
            cecCsError = {...
                this.cTYPE_CS_ERROR_WAFER_COARSE_SOFT_LIMIT, ... 
                this.cTYPE_CS_ERROR_WAFER_COARSE_RUN_TIME, ... 
                this.cTYPE_CS_ERROR_WAFER_COARSE_LIMIT_STOP, ... 
                this.cTYPE_CS_ERROR_WAFER_COARSE_ERROR_STATUS, ... 
                this.cTYPE_CS_ERROR_WAFER_FINE_SOFT_LIMIT, ... 
                this.cTYPE_CS_ERROR_WAFER_FINE_RUN_TIME, ... 
                this.cTYPE_CS_ERROR_WAFER_FINE_LIMIT_STOP, ... 
                this.cTYPE_CS_ERROR_WAFER_FINE_ERROR_STATUS, ... 
                this.cTYPE_CS_ERROR_RETICLE_COARSE_SOFT_LIMIT, ... 
                this.cTYPE_CS_ERROR_RETICLE_COARSE_RUN_TIME, ...
                this.cTYPE_CS_ERROR_RETICLE_COARSE_LIMIT_STOP, ...
                this.cTYPE_CS_ERROR_RETICLE_COARSE_ERROR_STATUS, ...
                this.cTYPE_CS_ERROR_RETICLE_FINE_SOFT_LIMIT, ...
                this.cTYPE_CS_ERROR_RETICLE_FINE_RUN_TIME, ...
                this.cTYPE_CS_ERROR_RETICLE_FINE_LIMIT_STOP, ...
                this.cTYPE_CS_ERROR_RETICLE_FINE_ERROR_STATUS, ...
                this.cTYPE_CS_ERROR_LSI_COARSE_SOFT_LIMIT, ...
                this.cTYPE_CS_ERROR_LSI_COARSE_RUN_TIME, ...
                this.cTYPE_CS_ERROR_LSI_COARSE_LIMIT_STOP, ...
                this.cTYPE_CS_ERROR_LSI_COARSE_ERROR_STATUS ...
            };

            cecCsStatus = {...
                this.cTYPE_CS_STATUS_WAFER_COARSE_NOT_HOMED, ...
                this.cTYPE_CS_STATUS_WAFER_COARSE_TIMEBASE_DEVIATION, ...
                this.cTYPE_CS_STATUS_WAFER_COARSE_PROGRAM_RUNNING, ...
                this.cTYPE_CS_STATUS_WAFER_FINE_NOT_HOMED, ...
                this.cTYPE_CS_STATUS_WAFER_FINE_TIMEBASE_DEVIATION, ...
                this.cTYPE_CS_STATUS_WAFER_FINE_PROGRAM_RUNNING, ...
                this.cTYPE_CS_STATUS_RETICLE_COARSE_NOT_HOMED, ...
                this.cTYPE_CS_STATUS_RETICLE_COARSE_TIMEBASE_DEVIATION, ...
                this.cTYPE_CS_STATUS_RETICLE_COARSE_PROGRAM_RUNNING, ...
                this.cTYPE_CS_STATUS_RETICLE_FINE_NOT_HOMED, ...
                this.cTYPE_CS_STATUS_RETICLE_FINE_TIMEBASE_DEVIATION, ...
                this.cTYPE_CS_STATUS_RETICLE_FINE_PROGRAM_RUNNING, ...
                this.cTYPE_CS_STATUS_LSI_COARSE_NOT_HOMED, ...
                this.cTYPE_CS_STATUS_LSI_COARSE_TIMEBASE_DEVIATION, ...
                this.cTYPE_CS_STATUS_LSI_COARSE_PROGRAM_RUNNING ...
            };


            cecGlobalError = {...
                this.cTYPE_GLOB_ERROR_HW_CHANGE_ERROR, ...
                this.cTYPE_GLOB_ERROR_NO_CLOCKS, ...
                this.cTYPE_GLOB_ERROR_SYS_PHASE_ERROR_CTR, ...
                this.cTYPE_GLOB_ERROR_SYS_RT_INT_BUSY_CTR, ...
                this.cTYPE_GLOB_ERROR_SYS_RT_INT_ERROR_CTR, ...
                this.cTYPE_GLOB_ERROR_SYS_SERVO_BUSY_CTR, ...
                this.cTYPE_GLOB_ERROR_SYS_SERVO_ERROR_CTR, ...
                this.cTYPE_GLOB_ERROR_WDT_FAULT ...
            };
        
            cecIoInfo = { ...
                this.cTYPE_IO_INFO_AT_RETICLE_TRANSFER_POSITION, ...
                this.cTYPE_IO_INFO_AT_WAFER_TRANSFER_POSITION, ...
                this.cTYPE_IO_INFO_ENABLE_SYSTEM_IS_ZERO, ...
                this.cTYPE_IO_INFO_LOCK_RETICLE_POSITION, ...
                this.cTYPE_IO_INFO_LOCK_WAFER_POSITION, ...
                this.cTYPE_IO_INFO_RETICLE_POSITION_LOCKED, ...
                this.cTYPE_IO_INFO_SYSTEM_ENABLED_IS_ZERO, ...
                this.cTYPE_IO_INFO_WAFER_POSITION_LOCKED ...
           }; 

           cecMet50Error = {...
                this.cTYPE_MET50_ERROR_712_1_NOT_CONNECTED, ...
                this.cTYPE_MET50_ERROR_712_1_READ_ERROR, ...
                this.cTYPE_MET50_ERROR_712_1_WRITE_ERROR, ...
                this.cTYPE_MET50_ERROR_712_2_NOT_CONNECTED, ...
                this.cTYPE_MET50_ERROR_712_2_READ_ERROR, ...
                this.cTYPE_MET50_ERROR_712_2_WRITE_ERROR, ...
                this.cTYPE_MET50_ERROR_C_APP_NOT_RUNNING, ...
                this.cTYPE_MET50_ERROR_DMI_STATUS, ...
                this.cTYPE_MET50_ERROR_HS_STATUS, ...
                this.cTYPE_MET50_ERROR_HYDRA_1_NOT_CONNECTED, ...
                this.cTYPE_MET50_ERROR_HYDRA_1_MACHINE_ERROR, ...
                this.cTYPE_MET50_ERROR_HYDRA_2_NOT_CONNECTED, ...
                this.cTYPE_MET50_ERROR_HYDRA_2_MACHINE_ERROR, ...
                this.cTYPE_MET50_ERROR_HYDRA_3_NOT_CONNECTED, ...
                this.cTYPE_MET50_ERROR_HYDRA_3_MACHINE_ERROR, ...
                this.cTYPE_MET50_ERROR_MOD_BUS_NOT_CONNECTED, ...
                this.cTYPE_MET50_ERROR_MOXA_NOT_CONNECTED, ...
                this.cTYPE_MET50_ERROR_PROXIMITY_SWITCH_WAFER_X_LSI, ...
                this.cTYPE_MET50_ERROR_TEMPERATURE_ERROR, ...
                this.cTYPE_MET50_ERROR_TEMPERATURE_WARNING ...
            };

            cecEncoderError = {...
                ...% Hydra 1
                this.cTYPE_ENCODER_ERROR_WAFER_COARSE_X, ...
                this.cTYPE_ENCODER_ERROR_WAFER_COARSE_Y, ...
                ...% Hyrda 2
                this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_X, ...
                this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_Y, ...
                ...% Hydra 3
                this.cTYPE_ENCODER_ERROR_LSI_COARSE_X, ...
                ...% 712 1
                this.cTYPE_ENCODER_ERROR_WAFER_COARSE_Z, ...
                this.cTYPE_ENCODER_ERROR_WAFER_COARSE_TIP, ...
                this.cTYPE_ENCODER_ERROR_WAFER_COARSE_TILT, ...
                this.cTYPE_ENCODER_ERROR_WAFER_FINE_Z, ...
                ...% 712 2
                this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_Z, ...
                this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_TIP, ...
                this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_TILT, ...
                this.cTYPE_ENCODER_ERROR_RETICLE_FINE_X, ...
                this.cTYPE_ENCODER_ERROR_RETICLE_FINE_Y ...
            };

            cecMotorError = {...
                ...% Hydra 1
                this.cTYPE_MOTOR_ERROR_WAFER_COARSE_X, ...
                this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y, ...
                ...% Hyrda 2
                this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X, ...
                this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y, ...
                ...% Hydra 3
                this.cTYPE_MOTOR_ERROR_LSI_COARSE_X, ...
                ...% 712 1
                this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Z, ...
                this.cTYPE_MOTOR_ERROR_WAFER_COARSE_TIP, ...
                this.cTYPE_MOTOR_ERROR_WAFER_COARSE_TILT, ...
                this.cTYPE_MOTOR_ERROR_WAFER_FINE_Z, ...
                ...% 712 2
                this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Z, ...
                this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_TIP, ...
                this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_TILT, ...
                this.cTYPE_MOTOR_ERROR_RETICLE_FINE_X, ...
                this.cTYPE_MOTOR_ERROR_RETICLE_FINE_Y, ...
                ...% Hydra 1
                this.cTYPE_MOTOR_ERROR_WAFER_COARSE_X_HOMING, ...
                this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_HOMING, ...
                ...% Hyrda 2
                this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_HOMING, ...
                this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_HOMING, ...
                ...% Hydra 3
                this.cTYPE_MOTOR_ERROR_LSI_COARSE_X_HOMING, ...
                ...% Hydra 1
                this.cTYPE_MOTOR_ERROR_WAFER_COARSE_X_ALTERA, ...
                this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_ALTERA, ...
                ...% Hyrda 2
                this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_ALTERA, ...
                this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_ALTERA, ...
                ...% Hydra 3
                this.cTYPE_MOTOR_ERROR_LSI_COARSE_X_ALTERA ...
            };

            cecMotorStatus = { ...
                ...% Hydra 1
                this.cTYPE_MOTOR_STATUS_WAFER_COARSE_X, ...
                this.cTYPE_MOTOR_STATUS_WAFER_COARSE_Y, ...
                ...% Hyrda 2
                this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_X, ...
                this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_Y, ...
                ...% Hydra 3
                this.cTYPE_MOTOR_STATUS_LSI_COARSE_X, ...
                ...% 712 1
                this.cTYPE_MOTOR_STATUS_WAFER_COARSE_Z, ...
                this.cTYPE_MOTOR_STATUS_WAFER_COARSE_TIP, ...
                this.cTYPE_MOTOR_STATUS_WAFER_COARSE_TILT, ...
                this.cTYPE_MOTOR_STATUS_WAFER_FINE_Z, ...
                ...% 712 2
                this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_Z, ...
                this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_TIP, ...
                this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_TILT, ...
                this.cTYPE_MOTOR_STATUS_RETICLE_FINE_X, ...
                this.cTYPE_MOTOR_STATUS_RETICLE_FINE_Y ...
            };
            
            
            
            switch this.cType
                case cecCsError % this is a cell array so any one of these
                    this.cTypeCategory = this.cTYPE_CATEGORY_CS_ERROR;
                case cecCsStatus 
                    this.cTypeCategory = this.cTYPE_CATEGORY_CS_STATUS;
                case cecEncoderError
                    this.cTypeCategory = this.cTYPE_CATEGORY_ENCODER_ERROR;
                case cecGlobalError
                    this.cTypeCategory = this.cTYPE_CATEGORY_GLOB_ERROR;
                case cecIoInfo
                    this.cTypeCategory = this.cTYPE_CATEGORY_IO_INFO;
                case cecMet50Error
                    this.cTypeCategory = this.cTYPE_CATEGORY_MET50_ERROR;
                case cecMotorError
                    this.cTypeCategory = this.cTYPE_CATEGORY_MOTOR_ERROR;
                case cecMotorStatus
                    this.cTypeCategory = this.cTYPE_CATEGORY_MOTOR_STATUS;
            end
            
            % fprintf('%s\n', this.cTypeCategory);
                    
        end
        
                
        function l = getCsError(this)
            
            switch this.cType
                case this.cTYPE_CS_ERROR_WAFER_COARSE_SOFT_LIMIT
                    l = this.comm.getCsErrorWaferCoarseSoftLimit();
                case this.cTYPE_CS_ERROR_WAFER_COARSE_RUN_TIME 
                    l = this.comm.getCsErrorWaferCoarseRunTime();
                case this.cTYPE_CS_ERROR_WAFER_COARSE_LIMIT_STOP 
                    l = this.comm.getCsErrorWaferCoarseLimitStop();
                case this.cTYPE_CS_ERROR_WAFER_COARSE_ERROR_STATUS
                    l = this.comm.getCsErrorWaferCoarseErrorStatus();
                case this.cTYPE_CS_ERROR_WAFER_FINE_SOFT_LIMIT
                    l = this.comm.getCsErrorWaferFineSoftLimit();
                case this.cTYPE_CS_ERROR_WAFER_FINE_RUN_TIME
                    l = this.comm.getCsErrorWaferFineRunTime();
                case this.cTYPE_CS_ERROR_WAFER_FINE_LIMIT_STOP
                    l = this.comm.getCsErrorWaferFineLimitStop();
                case this.cTYPE_CS_ERROR_WAFER_FINE_ERROR_STATUS 
                    l = this.comm.getCsErrorWaferFineErrorStatus();
                case this.cTYPE_CS_ERROR_RETICLE_COARSE_SOFT_LIMIT 
                    l = this.comm.getCsErrorReticleCoarseSoftLimit();
                case this.cTYPE_CS_ERROR_RETICLE_COARSE_RUN_TIME
                    l = this.comm.getCsErrorReticleCoarseRunTime();
                case this.cTYPE_CS_ERROR_RETICLE_COARSE_LIMIT_STOP
                    l = this.comm.getCsErrorReticleCoarseLimitStop();
                case this.cTYPE_CS_ERROR_RETICLE_COARSE_ERROR_STATUS
                    l = this.comm.getCsErrorReticleCoarseErrorStatus();
                case this.cTYPE_CS_ERROR_RETICLE_FINE_SOFT_LIMIT
                    l = this.comm.getCsErrorReticleFineSoftLimit();
                case this.cTYPE_CS_ERROR_RETICLE_FINE_RUN_TIME
                    l = this.comm.getCsErrorReticleFineRunTime();
                case this.cTYPE_CS_ERROR_RETICLE_FINE_LIMIT_STOP
                    l = this.comm.getCsErrorReticleFineLimitStop();
                case this.cTYPE_CS_ERROR_RETICLE_FINE_ERROR_STATUS
                    l = this.comm.getCsErrorReticleFineErrorStatus();
                case this.cTYPE_CS_ERROR_LSI_COARSE_SOFT_LIMIT
                    l = this.comm.getCsErrorLsiCoarseSoftLimit();
                case this.cTYPE_CS_ERROR_LSI_COARSE_RUN_TIME
                    l = this.comm.getCsErrorLsiCoarseRunTime();
                case this.cTYPE_CS_ERROR_LSI_COARSE_LIMIT_STOP
                    l = this.comm.getCsErrorLsiCoarseLimitStop();
                case this.cTYPE_CS_ERROR_LSI_COARSE_ERROR_STATUS
                    l = this.comm.getCsErrorLsiCoarseErrorStatus();
            end
        
        end
        
        function l = getCsStatus(this)
            
            switch this.cType
                
                case this.cTYPE_CS_STATUS_WAFER_COARSE_NOT_HOMED
                     l = this.comm.getCsStatusWaferCoarseNotHomed();
                case this.cTYPE_CS_STATUS_WAFER_COARSE_TIMEBASE_DEVIATION
                    l = this.comm.getCsStatusWaferCoarseTimebaseDeviation();
                case this.cTYPE_CS_STATUS_WAFER_COARSE_PROGRAM_RUNNING
                     l = this.comm.getCsStatusWaferCoarseProgramRunning();
                case this.cTYPE_CS_STATUS_WAFER_FINE_NOT_HOMED
                     l = this.comm.getCsStatusWaferFineNotHomed();
                case this.cTYPE_CS_STATUS_WAFER_FINE_TIMEBASE_DEVIATION
                     l = this.comm.getCsStatusWaferFineTimebaseDeviation();
                case this.cTYPE_CS_STATUS_WAFER_FINE_PROGRAM_RUNNING
                     l = this.comm.getCsStatusWaferFineProgramRunning();
                case this.cTYPE_CS_STATUS_RETICLE_COARSE_NOT_HOMED
                     l = this.comm.getCsStatusReticleCoarseNotHomed();
                case this.cTYPE_CS_STATUS_RETICLE_COARSE_TIMEBASE_DEVIATION
                     l = this.comm.getCsStatusReticleCoarseTimebaseDeviation();
                case this.cTYPE_CS_STATUS_RETICLE_COARSE_PROGRAM_RUNNING
                     l = this.comm.getCsStatusReticleCoarseProgramRunning();
                case this.cTYPE_CS_STATUS_RETICLE_FINE_NOT_HOMED
                     l = this.comm.getCsStatusReticleFineNotHomed();
                case this.cTYPE_CS_STATUS_RETICLE_FINE_TIMEBASE_DEVIATION
                     l = this.comm.getCsStatusReticleFineTimebaseDeviation();
                case this.cTYPE_CS_STATUS_RETICLE_FINE_PROGRAM_RUNNING
                     l = this.comm.getCsStatusReticleFineProgramRunning();
                case this.cTYPE_CS_STATUS_LSI_COARSE_NOT_HOMED
                     l = this.comm.getCsStatusLsiCoarseNotHomed();
                case this.cTYPE_CS_STATUS_LSI_COARSE_TIMEBASE_DEVIATION
                     l = this.comm.getCsStatusLsiCoarseTimebaseDeviation();
                case this.cTYPE_CS_STATUS_LSI_COARSE_PROGRAM_RUNNING
                     l = this.comm.getCsStatusLsiCoarseProgramRunning();

            end
        end
        
        function l = getMotorError(this)
            
            switch this.cType
                
                % Hydra 1
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_X
                    l = this.comm.getMotorErrorWaferCoarseX();
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y
                    l = this.comm.getMotorErrorWaferCoarseY();
                % Hyrda 2
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X
                    l = this.comm.getMotorErrorReticleCoarseX();
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y
                    l = this.comm.getMotorErrorReticleCoarseY();
                % Hydra 3
                case this.cTYPE_MOTOR_ERROR_LSI_COARSE_X
                    l = this.comm.getMotorErrorLsiCoarseX();
                % 712 1
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Z
                    l = this.comm.getMotorErrorWaferCoarseZ();
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_TIP
                    l = this.comm.getMotorErrorWaferCoarseTip();
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_TILT
                    l = this.comm.getMotorErrorWaferCoarseTilt();
                case this.cTYPE_MOTOR_ERROR_WAFER_FINE_Z
                    l = this.comm.getMotorErrorWaferFineZ();
                % 712 2
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Z
                    l = this.comm.getMotorErrorReticleCoarseZ();
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_TIP
                    l = this.comm.getMotorErrorReticleCoarseTip();
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_TILT
                    l = this.comm.getMotorErrorReticleCoarseTilt();
                case this.cTYPE_MOTOR_ERROR_RETICLE_FINE_X
                    l = this.comm.getMotorErrorReticleFineX();
                case this.cTYPE_MOTOR_ERROR_RETICLE_FINE_Y
                    l = this.comm.getMotorErrorReticleFineY();

                % Hydra 1
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_X_HOMING
                    l = this.comm.getMotorErrorWaferCoarseXHoming();
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_HOMING
                    l = this.comm.getMotorErrorWaferCoarseYHoming();
                % Hyrda 2
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_HOMING
                    l = this.comm.getMotorErrorReticleCoarseXHoming();
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_HOMING
                    l = this.comm.getMotorErrorReticleCoarseYHoming();
                % Hydra 3
                case this.cTYPE_MOTOR_ERROR_LSI_COARSE_X_HOMING
                    l = this.comm.getMotorErrorLsiCoarseXHoming();


                % Hydra 1
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_X_ALTERA
                    l = this.comm.getMotorErrorWaferCoarseXAltera();
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_ALTERA
                    l = this.comm.getMotorErrorWaferCoarseYAltera();
                % Hyrda 2
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_ALTERA
                    l = this.comm.getMotorErrorReticleCoarseXAltera();
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_ALTERA
                    l = this.comm.getMotorErrorReticleCoarseYAltera();
                % Hydra 3
                case this.cTYPE_MOTOR_ERROR_LSI_COARSE_X_ALTERA
                    l = this.comm.getMotorErrorLsiCoarseXAltera();
            end
        end
        
        function l = getMotorStatus(this)
            
            switch this.cType
                
                % Hydra 1
                case this.cTYPE_MOTOR_STATUS_WAFER_COARSE_X
                    l = this.comm.getMotorStatusWaferCoarseXIsMoving();
                case this.cTYPE_MOTOR_STATUS_WAFER_COARSE_Y
                    l = this.comm.getMotorStatusWaferCoarseYIsMoving();
                % Hyrda 2
                case this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_X
                    l = this.comm.getMotorStatusReticleCoarseXIsMoving();
                case this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_Y
                    l = this.comm.getMotorStatusReticleCoarseYIsMoving();
                % Hydra 3
                case this.cTYPE_MOTOR_STATUS_LSI_COARSE_X
                    l = this.comm.getMotorStatusLsiCoarseXIsMoving();
                % 712 1
                case this.cTYPE_MOTOR_STATUS_WAFER_COARSE_Z
                    l = this.comm.getMotorStatusWaferCoarseZIsMoving();
                case this.cTYPE_MOTOR_STATUS_WAFER_COARSE_TIP
                    l = this.comm.getMotorStatusWaferCoarseTipIsMoving();
                case this.cTYPE_MOTOR_STATUS_WAFER_COARSE_TILT
                    l = this.comm.getMotorStatusWaferCoarseTiltIsMoving();
                case this.cTYPE_MOTOR_STATUS_WAFER_FINE_Z
                    l = this.comm.getMotorStatusWaferFineZIsMoving();
                % 712 2
                case this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_Z
                    l = this.comm.getMotorStatusReticleCoarseZIsMoving();
                case this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_TIP
                    l = this.comm.getMotorStatusReticleCoarseTipIsMoving();
                case this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_TILT
                    l = this.comm.getMotorStatusReticleCoarseTiltIsMoving();
                case this.cTYPE_MOTOR_STATUS_RETICLE_FINE_X
                    l = this.comm.getMotorStatusReticleFineXIsMoving();
                case this.cTYPE_MOTOR_STATUS_RETICLE_FINE_Y
                    l = this.comm.getMotorStatusReticleFineYIsMoving();
            end
        end
        
        function l = getEncoderError(this)
            
            switch this.cType
                % Hydra 1
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_X
                    l = this.comm.getEncoderErrorWaferCoarseX();
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_Y
                    l = this.comm.getEncoderErrorWaferCoarseY();
                % Hyrda 2
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_X
                    l = this.comm.getEncoderErrorReticleCoarseX();
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_Y
                    l = this.comm.getEncoderErrorReticleCoarseY();
                % Hydra 3
                case this.cTYPE_ENCODER_ERROR_LSI_COARSE_X
                    l = this.comm.getEncoderErrorLsiCoarseX();
                % 712 1
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_Z
                    l = this.comm.getEncoderErrorWaferCoarseZ();
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_TIP
                    l = this.comm.getEncoderErrorWaferCoarseTip();
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_TILT
                    l = this.comm.getEncoderErrorWaferCoarseTilt();
                case this.cTYPE_ENCODER_ERROR_WAFER_FINE_Z
                    l = this.comm.getEncoderErrorWaferFineZ();
                % 712 2
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_Z
                    l = this.comm.getEncoderErrorReticleCoarseZ();
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_TIP
                    l = this.comm.getEncoderErrorReticleCoarseTip();
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_TILT
                    l = this.comm.getEncoderErrorReticleCoarseTilt();
                case this.cTYPE_ENCODER_ERROR_RETICLE_FINE_X
                    l = this.comm.getEncoderErrorReticleFineX();
                case this.cTYPE_ENCODER_ERROR_RETICLE_FINE_Y
                    l = this.comm.getEncoderErrorReticleFineY();
            end
        end
        
        function l = getGlobError(this)
            
            switch this.cType
                
                case this.cTYPE_GLOB_ERROR_HW_CHANGE_ERROR
                    l = this.comm.getGlobErrorHwChangeError();
                case this.cTYPE_GLOB_ERROR_NO_CLOCKS
                    l = this.comm.getGlobErrorNoClocks();
                case this.cTYPE_GLOB_ERROR_SYS_PHASE_ERROR_CTR
                    l = this.comm.getGlobErrorSysPhaseErrorCtr();
                case this.cTYPE_GLOB_ERROR_SYS_RT_INT_BUSY_CTR
                    l = this.comm.getGlobErrorSysRtIntBusyCtr();
                case this.cTYPE_GLOB_ERROR_SYS_RT_INT_ERROR_CTR
                    l = this.comm.getGlobErrorSysRtIntErrorCtr();
                case this.cTYPE_GLOB_ERROR_SYS_SERVO_BUSY_CTR
                    l = this.comm.getGlobErrorSysServoBusyCtr();
                case this.cTYPE_GLOB_ERROR_SYS_SERVO_ERROR_CTR
                    l = this.comm.getGlobErrorSysServoErrorCtr();
                case this.cTYPE_GLOB_ERROR_WDT_FAULT
                    l = this.comm.getGlobErrorWdtFault();
            end
        end
        
        function l = getIoInfo(this)
            
            switch this.cType
                case this.cTYPE_IO_INFO_AT_RETICLE_TRANSFER_POSITION
                    l = this.comm.getIoInfoAtReticleTransferPosition();
                case this.cTYPE_IO_INFO_AT_WAFER_TRANSFER_POSITION
                    l = this.comm.getIoInfoAtWaferTransferPosition();
                case this.cTYPE_IO_INFO_ENABLE_SYSTEM_IS_ZERO
                    l = this.comm.getIoInfoEnableSystemIsZero();
                case this.cTYPE_IO_INFO_LOCK_RETICLE_POSITION
                    l = this.comm.getIoInfoLockReticlePosition();
                case this.cTYPE_IO_INFO_LOCK_WAFER_POSITION
                    l = this.comm.getIoInfoLockWaferPosition();
                case this.cTYPE_IO_INFO_RETICLE_POSITION_LOCKED
                    l = this.comm.getIoInfoReticlePositionLocked();
                case this.cTYPE_IO_INFO_SYSTEM_ENABLED_IS_ZERO
                    l = this.comm.getIoInfoSystemEnabledIsZero();
                case this.cTYPE_IO_INFO_WAFER_POSITION_LOCKED
                    l = this.comm.getIoInfoWaferPositionLocked();
            end
            
        end
        
        function l = getMet50Error(this)
            
            % fprintf('getMet50Error\n');
            switch this.cType
                case this.cTYPE_MET50_ERROR_712_1_NOT_CONNECTED
                    l = this.comm.getMet50Error7121NotConnected();
                case this.cTYPE_MET50_ERROR_712_1_READ_ERROR
                    l = this.comm.getMet50Error7121ReadError();
                case this.cTYPE_MET50_ERROR_712_1_WRITE_ERROR
                    l = this.comm.getMet50Error7121WriteError();
                case this.cTYPE_MET50_ERROR_712_2_NOT_CONNECTED
                    l = this.comm.getMet50Error7122NotConnected();
                case this.cTYPE_MET50_ERROR_712_2_READ_ERROR
                    l = this.comm.getMet50Error7122ReadError();
                case this.cTYPE_MET50_ERROR_712_2_WRITE_ERROR
                    l = this.comm.getMet50Error7122WriteError();
                case this.cTYPE_MET50_ERROR_C_APP_NOT_RUNNING
                    l = this.comm.getMet50ErrorCAppNotRunning();
                case this.cTYPE_MET50_ERROR_DMI_STATUS
                    l = this.comm.getMet50ErrorDmiStatus();
                case this.cTYPE_MET50_ERROR_HS_STATUS
                    l = this.comm.getMet50ErrorHsStatus();
                case this.cTYPE_MET50_ERROR_HYDRA_1_NOT_CONNECTED
                    l = this.comm.getMet50ErrorHydra1NotConnected();
                case this.cTYPE_MET50_ERROR_HYDRA_1_MACHINE_ERROR
                    l = this.comm.getMet50ErrorHydra1MachineError();
                case this.cTYPE_MET50_ERROR_HYDRA_2_NOT_CONNECTED
                    l = this.comm.getMet50ErrorHydra2NotConnected();
                case this.cTYPE_MET50_ERROR_HYDRA_2_MACHINE_ERROR
                    l = this.comm.getMet50ErrorHydra2MachineError();
                case this.cTYPE_MET50_ERROR_HYDRA_3_NOT_CONNECTED
                    l = this.comm.getMet50ErrorHydra2NotConnected();
                case this.cTYPE_MET50_ERROR_HYDRA_3_MACHINE_ERROR
                    l = this.comm.getMet50ErrorHydra3MachineError();
                case this.cTYPE_MET50_ERROR_MOD_BUS_NOT_CONNECTED
                    l = this.comm.getMet50ErrorModBusNotConnected();
                case this.cTYPE_MET50_ERROR_MOXA_NOT_CONNECTED
                    l = this.comm.getMet50ErrorMoxaNotConnected();
                case this.cTYPE_MET50_ERROR_PROXIMITY_SWITCH_WAFER_X_LSI
                    l = this.comm.getMet50ErrorProximitySwitchWaferXLsi();
                case this.cTYPE_MET50_ERROR_TEMPERATURE_ERROR
                    l = this.comm.getMet50ErrorTemperatureError();
                case this.cTYPE_MET50_ERROR_TEMPERATURE_WARNING
                    l = this.comm.getMet50ErrorTemperatureWarning();

            end
            
        end
        
           
        function l = get(this)
            
            switch this.cTypeCategory
                
                case this.cTYPE_CATEGORY_CS_ERROR
                    l = this.getCsError();
                case this.cTYPE_CATEGORY_CS_STATUS
                    l = this.getCsStatus();
                case this.cTYPE_CATEGORY_MOTOR_ERROR
                    l = this.getMotorError();
                case this.cTYPE_CATEGORY_MOTOR_STATUS
                    l = this.getMotorStatus();
                case this.cTYPE_CATEGORY_ENCODER_ERROR
                    l = this.getEncoderError();
                case this.cTYPE_CATEGORY_GLOB_ERROR
                    l = this.getGlobError();
                case this.cTYPE_CATEGORY_IO_INFO
                    l = this.getIoInfo();
                case this.cTYPE_CATEGORY_MET50_ERROR
                    l = this.getMet50Error();
            end
                    
        end
                
        function initialize(this)
            % nothing
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
        
    
end

