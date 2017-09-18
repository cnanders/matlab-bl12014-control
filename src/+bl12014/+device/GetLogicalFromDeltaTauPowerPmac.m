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
                cTYPE_CS_ERROR_WAFER_COARSE_SOFT_LIMIT, ... 
                cTYPE_CS_ERROR_WAFER_COARSE_RUN_TIME, ... 
                cTYPE_CS_ERROR_WAFER_COARSE_LIMIT_STOP, ... 
                cTYPE_CS_ERROR_WAFER_COARSE_ERROR_STATUS, ... 
                cTYPE_CS_ERROR_WAFER_FINE_SOFT_LIMIT, ... 
                cTYPE_CS_ERROR_WAFER_FINE_RUN_TIME, ... 
                cTYPE_CS_ERROR_WAFER_FINE_LIMIT_STOP, ... 
                cTYPE_CS_ERROR_WAFER_FINE_ERROR_STATUS, ... 
                cTYPE_CS_ERROR_RETICLE_COARSE_SOFT_LIMIT, ... 
                cTYPE_CS_ERROR_RETICLE_COARSE_RUN_TIME, ...
                cTYPE_CS_ERROR_RETICLE_COARSE_LIMIT_STOP, ...
                cTYPE_CS_ERROR_RETICLE_COARSE_ERROR_STATUS, ...
                cTYPE_CS_ERROR_RETICLE_FINE_SOFT_LIMIT, ...
                cTYPE_CS_ERROR_RETICLE_FINE_RUN_TIME, ...
                cTYPE_CS_ERROR_RETICLE_FINE_LIMIT_STOP, ...
                cTYPE_CS_ERROR_RETICLE_FINE_ERROR_STATUS, ...
                cTYPE_CS_ERROR_LSI_COARSE_SOFT_LIMIT, ...
                cTYPE_CS_ERROR_LSI_COARSE_RUN_TIME, ...
                cTYPE_CS_ERROR_LSI_COARSE_LIMIT_STOP, ...
                cTYPE_CS_ERROR_LSI_COARSE_ERROR_STATUS ...
            };

            cecCsStatus = {...
                cTYPE_CS_STATUS_WAFER_COARSE_NOT_HOMED, ...
                cTYPE_CS_STATUS_WAFER_COARSE_TIMEBASE_DEVIATION, ...
                cTYPE_CS_STATUS_WAFER_COARSE_PROGRAM_RUNNING, ...
                cTYPE_CS_STATUS_WAFER_FINE_NOT_HOMED, ...
                cTYPE_CS_STATUS_WAFER_FINE_TIMEBASE_DEVIATION, ...
                cTYPE_CS_STATUS_WAFER_FINE_PROGRAM_RUNNING, ...
                cTYPE_CS_STATUS_RETICLE_COARSE_NOT_HOMED, ...
                cTYPE_CS_STATUS_RETICLE_COARSE_TIMEBASE_DEVIATION, ...
                cTYPE_CS_STATUS_RETICLE_COARSE_PROGRAM_RUNNING, ...
                cTYPE_CS_STATUS_RETICLE_FINE_NOT_HOMED, ...
                cTYPE_CS_STATUS_RETICLE_FINE_TIMEBASE_DEVIATION, ...
                cTYPE_CS_STATUS_RETICLE_FINE_PROGRAM_RUNNING, ...
                cTYPE_CS_STATUS_LSI_COARSE_NOT_HOMED, ...
                cTYPE_CS_STATUS_LSI_COARSE_TIMEBASE_DEVIATION, ...
                cTYPE_CS_STATUS_LSI_COARSE_PROGRAM_RUNNING ...
            };


            cecGlobalError = {...
                cTYPE_GLOB_ERROR_HW_CHANGE_ERROR, ...
                cTYPE_GLOB_ERROR_NO_CLOCKS, ...
                cTYPE_GLOB_ERROR_SYS_PHASE_ERROR_CTR, ...
                cTYPE_GLOB_ERROR_SYS_RT_INT_BUSY_CTR, ...
                cTYPE_GLOB_ERROR_SYS_RT_INT_ERROR_CTR, ...
                cTYPE_GLOB_ERROR_SYS_SERVO_BUSY_CTR, ...
                cTYPE_GLOB_ERROR_SYS_SERVO_ERROR_CTR, ...
                cTYPE_GLOB_ERROR_WDT_FAULT ...
            };
        
            cecIoInfo = { ...
                cTYPE_IO_INFO_AT_RETICLE_TRANSFER_POSITION, ...
                cTYPE_IO_INFO_AT_WAFER_TRANSFER_POSITION, ...
                cTYPE_IO_INFO_ENABLE_SYSTEM_IS_ZERO, ...
                cTYPE_IO_INFO_LOCK_RETICLE_POSITION, ...
                cTYPE_IO_INFO_LOCK_WAFER_POSITION, ...
                cTYPE_IO_INFO_RETICLE_POSITION_LOCKED, ...
                cTYPE_IO_INFO_SYSTEM_ENABLED_IS_ZERO, ...
                cTYPE_IO_INFO_WAFER_POSITION_LOCKED ...
           }; 

           cecMet50Error = {...
                cTYPE_MET50_ERROR_712_1_NOT_CONNECTED, ...
                cTYPE_MET50_ERROR_712_1_READ_ERROR, ...
                cTYPE_MET50_ERROR_712_1_WRITE_ERROR, ...
                cTYPE_MET50_ERROR_712_2_NOT_CONNECTED, ...
                cTYPE_MET50_ERROR_712_2_READ_ERROR, ...
                cTYPE_MET50_ERROR_712_2_WRITE_ERROR, ...
                cTYPE_MET50_ERROR_C_APP_NOT_RUNNING, ...
                cTYPE_MET50_ERROR_DMI_STATUS, ...
                cTYPE_MET50_ERROR_HS_STATUS, ...
                cTYPE_MET50_ERROR_HYDRA_1_NOT_CONNECTED, ...
                cTYPE_MET50_ERROR_HYDRA_1_MACHINE_ERROR, ...
                cTYPE_MET50_ERROR_HYDRA_2_NOT_CONNECTED, ...
                cTYPE_MET50_ERROR_HYDRA_2_MACHINE_ERROR, ...
                cTYPE_MET50_ERROR_HYDRA_3_NOT_CONNECTED, ...
                cTYPE_MET50_ERROR_HYDRA_3_MACHINE_ERROR, ...
                cTYPE_MET50_ERROR_MOD_BUS_NOT_CONNECTED, ...
                cTYPE_MET50_ERROR_MOXA_NOT_CONNECTED, ...
                cTYPE_MET50_ERROR_PROXIMITY_SWITCH_WAFER_X_LSI, ...
                cTYPE_MET50_ERROR_TEMPERATURE_ERROR, ...
                cTYPE_MET50_ERROR_TEMPERATURE_WARNING ...
            };

            cecEncoderError = {...
                ...% Hydra 1
                cTYPE_ENCODER_ERROR_WAFER_COARSE_X, ...
                cTYPE_ENCODER_ERROR_WAFER_COARSE_Y, ...
                ...% Hyrda 2
                cTYPE_ENCODER_ERROR_RETICLE_COARSE_X, ...
                cTYPE_ENCODER_ERROR_RETICLE_COARSE_Y, ...
                ...% Hydra 3
                cTYPE_ENCODER_ERROR_LSI_COARSE_X, ...
                ...% 712 1
                cTYPE_ENCODER_ERROR_WAFER_COARSE_Z, ...
                cTYPE_ENCODER_ERROR_WAFER_COARSE_TIP, ...
                cTYPE_ENCODER_ERROR_WAFER_COARSE_TILT, ...
                cTYPE_ENCODER_ERROR_WAFER_FINE_Z, ...
                ...% 712 2
                cTYPE_ENCODER_ERROR_RETICLE_COARSE_Z, ...
                cTYPE_ENCODER_ERROR_RETICLE_COARSE_TIP, ...
                cTYPE_ENCODER_ERROR_RETICLE_COARSE_TILT, ...
                cTYPE_ENCODER_ERROR_RETICLE_FINE_X, ...
                cTYPE_ENCODER_ERROR_RETICLE_FINE_Y ...
            };

            cecMotorError = {...
                ...% Hydra 1
                cTYPE_MOTOR_ERROR_WAFER_COARSE_X, ...
                cTYPE_MOTOR_ERROR_WAFER_COARSE_Y, ...
                ...% Hyrda 2
                cTYPE_MOTOR_ERROR_RETICLE_COARSE_X, ...
                cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y, ...
                ...% Hydra 3
                cTYPE_MOTOR_ERROR_LSI_COARSE_X, ...
                ...% 712 1
                cTYPE_MOTOR_ERROR_WAFER_COARSE_Z, ...
                cTYPE_MOTOR_ERROR_WAFER_COARSE_TIP, ...
                cTYPE_MOTOR_ERROR_WAFER_COARSE_TILT, ...
                cTYPE_MOTOR_ERROR_WAFER_FINE_Z, ...
                ...% 712 2
                cTYPE_MOTOR_ERROR_RETICLE_COARSE_Z, ...
                cTYPE_MOTOR_ERROR_RETICLE_COARSE_TIP, ...
                cTYPE_MOTOR_ERROR_RETICLE_COARSE_TILT, ...
                cTYPE_MOTOR_ERROR_RETICLE_FINE_X, ...
                cTYPE_MOTOR_ERROR_RETICLE_FINE_Y, ...
                ...% Hydra 1
                cTYPE_MOTOR_ERROR_WAFER_COARSE_X_HOMING, ...
                cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_HOMING, ...
                ...% Hyrda 2
                cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_HOMING, ...
                cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_HOMING, ...
                ...% Hydra 3
                cTYPE_MOTOR_ERROR_LSI_COARSE_X_HOMING, ...
                ...% Hydra 1
                cTYPE_MOTOR_ERROR_WAFER_COARSE_X_ALTERA, ...
                cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_ALTERA, ...
                ...% Hyrda 2
                cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_ALTERA, ...
                cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_ALTERA, ...
                ...% Hydra 3
                cTYPE_MOTOR_ERROR_LSI_COARSE_X_ALTERA ...
            };

            cecMotorStatus = { ...
                ...% Hydra 1
                cTYPE_MOTOR_STATUS_WAFER_COARSE_X, ...
                cTYPE_MOTOR_STATUS_WAFER_COARSE_Y, ...
                ...% Hyrda 2
                cTYPE_MOTOR_STATUS_RETICLE_COARSE_X, ...
                cTYPE_MOTOR_STATUS_RETICLE_COARSE_Y, ...
                ...% Hydra 3
                cTYPE_MOTOR_STATUS_LSI_COARSE_X, ...
                ...% 712 1
                cTYPE_MOTOR_STATUS_WAFER_COARSE_Z, ...
                cTYPE_MOTOR_STATUS_WAFER_COARSE_TIP, ...
                cTYPE_MOTOR_STATUS_WAFER_COARSE_TILT, ...
                cTYPE_MOTOR_STATUS_WAFER_FINE_Z, ...
                ...% 712 2
                cTYPE_MOTOR_STATUS_RETICLE_COARSE_Z, ...
                cTYPE_MOTOR_STATUS_RETICLE_COARSE_TIP, ...
                cTYPE_MOTOR_STATUS_RETICLE_COARSE_TILT, ...
                cTYPE_MOTOR_STATUS_RETICLE_FINE_X, ...
                cTYPE_MOTOR_STATUS_RETICLE_FINE_Y ...
            };
            
            
            
            switch cType
                case cecCsError
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
                    
        end
        
                
        function l = getCsError(this)
            
            l = true;
            switch this.cType
                case this.cTYPE_CS_ERROR_WAFER_COARSE_SOFT_LIMIT 
                case this.cTYPE_CS_ERROR_WAFER_COARSE_RUN_TIME 
                case this.cTYPE_CS_ERROR_WAFER_COARSE_LIMIT_STOP 
                case this.cTYPE_CS_ERROR_WAFER_COARSE_ERROR_STATUS 
                case this.cTYPE_CS_ERROR_WAFER_FINE_SOFT_LIMIT 
                case this.cTYPE_CS_ERROR_WAFER_FINE_RUN_TIME 
                case this.cTYPE_CS_ERROR_WAFER_FINE_LIMIT_STOP 
                case this.cTYPE_CS_ERROR_WAFER_FINE_ERROR_STATUS 
                case this.cTYPE_CS_ERROR_RETICLE_COARSE_SOFT_LIMIT 
                case this.cTYPE_CS_ERROR_RETICLE_COARSE_RUN_TIME
                case this.cTYPE_CS_ERROR_RETICLE_COARSE_LIMIT_STOP
                case this.cTYPE_CS_ERROR_RETICLE_COARSE_ERROR_STATUS
                case this.cTYPE_CS_ERROR_RETICLE_FINE_SOFT_LIMIT
                case this.cTYPE_CS_ERROR_RETICLE_FINE_RUN_TIME
                case this.cTYPE_CS_ERROR_RETICLE_FINE_LIMIT_STOP
                case this.cTYPE_CS_ERROR_RETICLE_FINE_ERROR_STATUS
                case this.cTYPE_CS_ERROR_LSI_COARSE_SOFT_LIMIT
                case this.cTYPE_CS_ERROR_LSI_COARSE_RUN_TIME
                case this.cTYPE_CS_ERROR_LSI_COARSE_LIMIT_STOP
                case this.cTYPE_CS_ERROR_LSI_COARSE_ERROR_STATUS
            end
        
        end
        
        function l = getCsStatus(this)
            
            l = false;
            switch this.cType
                
                case this.cTYPE_CS_STATUS_WAFER_COARSE_NOT_HOMED
                case this.cTYPE_CS_STATUS_WAFER_COARSE_TIMEBASE_DEVIATION
                case this.cTYPE_CS_STATUS_WAFER_COARSE_PROGRAM_RUNNING
                case this.cTYPE_CS_STATUS_WAFER_FINE_NOT_HOMED
                case this.cTYPE_CS_STATUS_WAFER_FINE_TIMEBASE_DEVIATION
                case this.cTYPE_CS_STATUS_WAFER_FINE_PROGRAM_RUNNING
                case this.cTYPE_CS_STATUS_RETICLE_COARSE_NOT_HOMED
                case this.cTYPE_CS_STATUS_RETICLE_COARSE_TIMEBASE_DEVIATION
                case this.cTYPE_CS_STATUS_RETICLE_COARSE_PROGRAM_RUNNING
                case this.cTYPE_CS_STATUS_RETICLE_FINE_NOT_HOMED
                case this.cTYPE_CS_STATUS_RETICLE_FINE_TIMEBASE_DEVIATION
                case this.cTYPE_CS_STATUS_RETICLE_FINE_PROGRAM_RUNNING
                case this.cTYPE_CS_STATUS_LSI_COARSE_NOT_HOMED
                case this.cTYPE_CS_STATUS_LSI_COARSE_TIMEBASE_DEVIATION
                case this.cTYPE_CS_STATUS_LSI_COARSE_PROGRAM_RUNNING

            end
        end
        
        function l = getMotorError(this)
            
            l = true;
            switch this.cType
                
                % Hydra 1
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_X
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y
                % Hyrda 2
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y
                % Hydra 3
                case this.cTYPE_MOTOR_ERROR_LSI_COARSE_X
                % 712 1
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Z
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_TIP
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_TILT
                case this.cTYPE_MOTOR_ERROR_WAFER_FINE_Z
                % 712 2
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Z
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_TIP
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_TILT
                case this.cTYPE_MOTOR_ERROR_RETICLE_FINE_X
                case this.cTYPE_MOTOR_ERROR_RETICLE_FINE_Y

                % Hydra 1
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_X_HOMING
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_HOMING
                % Hyrda 2
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_HOMING
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_HOMING
                % Hydra 3
                case this.cTYPE_MOTOR_ERROR_LSI_COARSE_X_HOMING


                % Hydra 1
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_X_ALTERA
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_ALTERA
                % Hyrda 2
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_ALTERA
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_ALTERA
                % Hydra 3
                case this.cTYPE_MOTOR_ERROR_LSI_COARSE_X_ALTERA
            end
        end
        
        function l = getMotorStatus(this)
            
            l = false;
            switch this.cType
                
                % Hydra 1
                case this.cTYPE_MOTOR_STATUS_WAFER_COARSE_X
                case this.cTYPE_MOTOR_STATUS_WAFER_COARSE_Y
                % Hyrda 2
                case this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_X
                case this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_Y
                % Hydra 3
                case this.cTYPE_MOTOR_STATUS_LSI_COARSE_X
                % 712 1
                case this.cTYPE_MOTOR_STATUS_WAFER_COARSE_Z
                case this.cTYPE_MOTOR_STATUS_WAFER_COARSE_TIP
                case this.cTYPE_MOTOR_STATUS_WAFER_COARSE_TILT
                case this.cTYPE_MOTOR_STATUS_WAFER_FINE_Z
                % 712 2
                case this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_Z
                case this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_TIP
                case this.cTYPE_MOTOR_STATUS_RETICLE_COARSE_TILT
                case this.cTYPE_MOTOR_STATUS_RETICLE_FINE_X
                case this.cTYPE_MOTOR_STATUS_RETICLE_FINE_Y
            end
        end
        
        function l = getEncoderError(this)
            
            l = true;
            switch this.cType
                % Hydra 1
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_X
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_Y
                % Hyrda 2
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_X
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_Y
                % Hydra 3
                case this.cTYPE_ENCODER_ERROR_LSI_COARSE_X
                % 712 1
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_Z
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_TIP
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_TILT
                case this.cTYPE_ENCODER_ERROR_WAFER_FINE_Z
                % 712 2
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_Z
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_TIP
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_TILT
                case this.cTYPE_ENCODER_ERROR_RETICLE_FINE_X
                case this.cTYPE_ENCODER_ERROR_RETICLE_FINE_Y
            end
        end
        
        function l = getGlobError(this)
            
            l = false;
            switch this.cType
                
                case this.cTYPE_GLOB_ERROR_HW_CHANGE_ERROR
                case this.cTYPE_GLOB_ERROR_NO_CLOCKS
                case this.cTYPE_GLOB_ERROR_SYS_PHASE_ERROR_CTR
                case this.cTYPE_GLOB_ERROR_SYS_RT_INT_BUSY_CTR
                case this.cTYPE_GLOB_ERROR_SYS_RT_INT_ERROR_CTR
                case this.cTYPE_GLOB_ERROR_SYS_SERVO_BUSY_CTR
                case this.cTYPE_GLOB_ERROR_SYS_SERVO_ERROR_CTR
                case this.cTYPE_GLOB_ERROR_WDT_FAULT
            end
        end
        
        function l = getIoInfo(this)
            
            l = true;
            switch this.cType
                case this.cTYPE_IO_INFO_AT_RETICLE_TRANSFER_POSITION
                case this.cTYPE_IO_INFO_AT_WAFER_TRANSFER_POSITION
                case this.cTYPE_IO_INFO_ENABLE_SYSTEM_IS_ZERO
                case this.cTYPE_IO_INFO_LOCK_RETICLE_POSITION
                case this.cTYPE_IO_INFO_LOCK_WAFER_POSITION
                case this.cTYPE_IO_INFO_RETICLE_POSITION_LOCKED
                case this.cTYPE_IO_INFO_SYSTEM_ENABLED_IS_ZERO
                case this.cTYPE_IO_INFO_WAFER_POSITION_LOCKED
            end
            
        end
        
        function l = getMet50Error(this)
            
            l = true;
            
            switch this.cType
                case this.cTYPE_MET50_ERROR_712_1_NOT_CONNECTED
                case this.cTYPE_MET50_ERROR_712_1_READ_ERROR
                case this.cTYPE_MET50_ERROR_712_1_WRITE_ERROR
                case this.cTYPE_MET50_ERROR_712_2_NOT_CONNECTED
                case this.cTYPE_MET50_ERROR_712_2_READ_ERROR
                case this.cTYPE_MET50_ERROR_712_2_WRITE_ERROR
                case this.cTYPE_MET50_ERROR_C_APP_NOT_RUNNING
                case this.cTYPE_MET50_ERROR_DMI_STATUS
                case this.cTYPE_MET50_ERROR_HS_STATUS
                case this.cTYPE_MET50_ERROR_HYDRA_1_NOT_CONNECTED
                case this.cTYPE_MET50_ERROR_HYDRA_1_MACHINE_ERROR
                case this.cTYPE_MET50_ERROR_HYDRA_2_NOT_CONNECTED
                case this.cTYPE_MET50_ERROR_HYDRA_2_MACHINE_ERROR
                case this.cTYPE_MET50_ERROR_HYDRA_3_NOT_CONNECTED
                case this.cTYPE_MET50_ERROR_HYDRA_3_MACHINE_ERROR
                case this.cTYPE_MET50_ERROR_MOD_BUS_NOT_CONNECTED
                case this.cTYPE_MET50_ERROR_MOXA_NOT_CONNECTED
                case this.cTYPE_MET50_ERROR_PROXIMITY_SWITCH_WAFER_X_LSI
                case this.cTYPE_MET50_ERROR_TEMPERATURE_ERROR
                case this.cTYPE_MET50_ERROR_TEMPERATURE_WARNING

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

