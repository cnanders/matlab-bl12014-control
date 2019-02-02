classdef GetLogicalDeltaTauPowerPmacFromHardware < mic.interface.device.GetLogical
    
    % Translates deltatau.PowerPmac to mic.interface.device.GetSetNumber
    
    properties (Constant)
        
        
        %{
        cTYPE_AT_WAFER_TRANSFER_POSITION = 'at-wafer-transfer-position'
        cTYPE_AT_RETICLE_TRANSFER_POSITION = 'at-reticle-transfer-position'
        cTYPE_WAFER_POSITION_LOCKED = 'wafer-position-locked'
        cTYPE_RETICLE_POSITION_LOCKED = 'reticle-position-locked'
        %}
        
        cTYPE_CATEGORY_CS_ERROR = 'cs-error'
        cTYPE_CATEGORY_CS_STATUS = 'cs-status'
        cTYPE_CATEGORY_MOTOR_ERROR = 'motor-error'
        cTYPE_CATEGORY_MOTOR_STATUS_MOVING = 'motor-status-moving'
        cTYPE_CATEGORY_MOTOR_STATUS_OPEN_LOOP = 'motor-status-open-loop'
        cTYPE_CATEGORY_MOTOR_STATUS_MINUS_LIMIT = 'motor-status-minus-limit'
        cTYPE_CATEGORY_MOTOR_STATUS_PLUS_LIMIT = 'motor-status-plus-limit'
        cTYPE_CATEGORY_ENCODER_ERROR = 'encoder-error'
        cTYPE_CATEGORY_GLOB_ERROR = 'glob-error'
        cTYPE_CATEGORY_IO_INFO = 'io-info'
        cTYPE_CATEGORY_MET50_ERROR = 'met50-error'
        
        %% CsError
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
        
        %% CsStatus
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
        
        cTYPE_MET50_ERROR_712_1_NOT_CONNECTED = 'met50-error-712-1-wsa-not-connected'
        cTYPE_MET50_ERROR_712_1_READ_ERROR = 'met50-error-712-1-wsa-read-error'
        cTYPE_MET50_ERROR_712_1_WRITE_ERROR = 'met50-error-712-1-wsa-write-error'
        cTYPE_MET50_ERROR_712_2_NOT_CONNECTED = 'met50-error-712-2-rsa-not-connected'
        cTYPE_MET50_ERROR_712_2_READ_ERROR = 'met50-error-712-2-rsa-read-error'
        cTYPE_MET50_ERROR_712_2_WRITE_ERROR = 'met50-error-712-2-rsa-write-error'
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
        
        %% Motor status
        
        % Hydra 1
        cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_X = 'motor-status-moving-wafer-coarse-x'
        cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_Y = 'motor-status-moving-wafer-coarse-y'
        % Hyrda 2
        cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_X = 'motor-status-moving-reticle-coarse-x'
        cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_Y = 'motor-status-moving-reticle-coarse-y'
        % Hydra 3
        cTYPE_MOTOR_STATUS_MOVING_LSI_COARSE_X = 'motor-status-moving-lsi-coarse-x'
        % 712 1
        cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_Z = 'motor-status-moving-wafer-coarse-z'
        cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_TIP = 'motor-status-moving-wafer-coarse-tip'
        cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_TILT = 'motor-status-moving-wafer-coarse-tilt'
        cTYPE_MOTOR_STATUS_MOVING_WAFER_FINE_Z = 'motor-status-moving-wafer-fine-z'
        % 712 2
        cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_Z = 'motor-status-moving-reticle-coarse-z'
        cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_TIP = 'motor-status-moving-reticle-coarse-tip'
        cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_TILT = 'motor-status-moving-reticle-coarse-tilt'
        cTYPE_MOTOR_STATUS_MOVING_RETICLE_FINE_X = 'motor-status-moving-reticle-fine-x'
        cTYPE_MOTOR_STATUS_MOVING_RETICLE_FINE_Y = 'motor-status-moving-reticle-fine-y'
        
        
        cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_X = 'motor-status-open-loop-wafer-coarse-x'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_Y = 'motor-status-open-loop-wafer-coarse-y'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_X = 'motor-status-open-loop-reticle-coarse-x'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_Y = 'motor-status-open-loop-reticle-coarse-y'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_LSI_COARSE_X = 'motor-status-open-loop-lsi-coarse-x'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_Z = 'motor-status-open-loop-wafer-coarse-z'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_TIP = 'motor-status-open-loop-wafer-coarse-tip'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_TILT = 'motor-status-open-loop-wafer-coarse-tilt'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_FINE_Z = 'motor-status-open-loop-wafer-fine-z'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_Z = 'motor-status-open-loop-reticle-coarse-z'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_TIP = 'motor-status-open-loop-reticle-coarse-tip'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_TILT = 'motor-status-open-loop-reticle-coarse-tilt'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_FINE_X = 'motor-status-open-loop-reticle-fine-x'
        cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_FINE_Y = 'motor-status-open-loop-reticle-fine-y'
        
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_X = 'motor-status-minus-limit-wafer-coarse-x'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_Y = 'motor-status-minus-limit-wafer-coarse-y'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_X = 'motor-status-minus-limit-reticle-coarse-x'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_Y = 'motor-status-minus-limit-reticle-coarse-y'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_LSI_COARSE_X = 'motor-status-minus-limit-lsi-coarse-x'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_Z = 'motor-status-minus-limit-wafer-coarse-z'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_TIP = 'motor-status-minus-limit-wafer-coarse-tip'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_TILT = 'motor-status-minus-limit-wafer-coarse-tilt'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_FINE_Z = 'motor-status-minus-limit-wafer-fine-z'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_Z = 'motor-status-minus-limit-reticle-coarse-z'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_TIP = 'motor-status-minus-limit-reticle-coarse-tip'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_TILT = 'motor-status-minus-limit-reticle-coarse-tilt'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_FINE_X = 'motor-status-minus-limit-reticle-fine-x'
        cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_FINE_Y = 'motor-status-minus-limit-reticle-fine-y'
        
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_X = 'motor-status-plus-limit-wafer-coarse-x'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_Y = 'motor-status-plus-limit-wafer-coarse-y'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_X = 'motor-status-plus-limit-reticle-coarse-x'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_Y = 'motor-status-plus-limit-reticle-coarse-y'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_LSI_COARSE_X = 'motor-status-plus-limit-lsi-coarse-x'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_Z = 'motor-status-plus-limit-wafer-coarse-z'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_TIP = 'motor-status-plus-limit-wafer-coarse-tip'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_TILT = 'motor-status-plus-limit-wafer-coarse-tilt'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_FINE_Z = 'motor-status-plus-limit-wafer-fine-z'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_Z = 'motor-status-plus-limit-reticle-coarse-z'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_TIP = 'motor-status-plus-limit-reticle-coarse-tip'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_TILT = 'motor-status-plus-limit-reticle-coarse-tilt'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_FINE_X = 'motor-status-plus-limit-reticle-fine-x'
        cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_FINE_Y = 'motor-status-plus-limit-reticle-fine-y'
        
        
        cecTypeCsError = {...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_WAFER_COARSE_SOFT_LIMIT, ... 
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_WAFER_COARSE_RUN_TIME, ... 
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_WAFER_COARSE_LIMIT_STOP, ... 
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_WAFER_COARSE_ERROR_STATUS, ... 
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_WAFER_FINE_SOFT_LIMIT, ... 
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_WAFER_FINE_RUN_TIME, ... 
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_WAFER_FINE_LIMIT_STOP, ... 
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_WAFER_FINE_ERROR_STATUS, ... 
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_RETICLE_COARSE_SOFT_LIMIT, ... 
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_RETICLE_COARSE_RUN_TIME, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_RETICLE_COARSE_LIMIT_STOP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_RETICLE_COARSE_ERROR_STATUS, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_RETICLE_FINE_SOFT_LIMIT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_RETICLE_FINE_RUN_TIME, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_RETICLE_FINE_LIMIT_STOP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_RETICLE_FINE_ERROR_STATUS, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_LSI_COARSE_SOFT_LIMIT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_LSI_COARSE_RUN_TIME, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_LSI_COARSE_LIMIT_STOP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_ERROR_LSI_COARSE_ERROR_STATUS ...
        };

        cecTypeCsStatus = {...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_WAFER_COARSE_NOT_HOMED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_WAFER_COARSE_TIMEBASE_DEVIATION, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_WAFER_COARSE_PROGRAM_RUNNING, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_WAFER_FINE_NOT_HOMED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_WAFER_FINE_TIMEBASE_DEVIATION, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_WAFER_FINE_PROGRAM_RUNNING, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_RETICLE_COARSE_NOT_HOMED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_RETICLE_COARSE_TIMEBASE_DEVIATION, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_RETICLE_COARSE_PROGRAM_RUNNING, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_RETICLE_FINE_NOT_HOMED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_RETICLE_FINE_TIMEBASE_DEVIATION, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_RETICLE_FINE_PROGRAM_RUNNING, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_LSI_COARSE_NOT_HOMED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_LSI_COARSE_TIMEBASE_DEVIATION, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_CS_STATUS_LSI_COARSE_PROGRAM_RUNNING ...
        };


        cecTypeGlobError = {...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_GLOB_ERROR_HW_CHANGE_ERROR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_GLOB_ERROR_NO_CLOCKS, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_GLOB_ERROR_SYS_PHASE_ERROR_CTR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_GLOB_ERROR_SYS_RT_INT_BUSY_CTR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_GLOB_ERROR_SYS_RT_INT_ERROR_CTR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_GLOB_ERROR_SYS_SERVO_BUSY_CTR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_GLOB_ERROR_SYS_SERVO_ERROR_CTR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_GLOB_ERROR_WDT_FAULT ...
        };

        cecTypeIoInfo = { ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_IO_INFO_AT_RETICLE_TRANSFER_POSITION, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_IO_INFO_AT_WAFER_TRANSFER_POSITION, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_IO_INFO_ENABLE_SYSTEM_IS_ZERO, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_IO_INFO_LOCK_RETICLE_POSITION, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_IO_INFO_LOCK_WAFER_POSITION, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_IO_INFO_RETICLE_POSITION_LOCKED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_IO_INFO_SYSTEM_ENABLED_IS_ZERO, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_IO_INFO_WAFER_POSITION_LOCKED ...
       }; 

       cecTypeMet50Error = {...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_712_1_NOT_CONNECTED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_712_1_READ_ERROR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_712_1_WRITE_ERROR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_712_2_NOT_CONNECTED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_712_2_READ_ERROR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_712_2_WRITE_ERROR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_C_APP_NOT_RUNNING, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_DMI_STATUS, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_HS_STATUS, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_HYDRA_1_NOT_CONNECTED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_HYDRA_1_MACHINE_ERROR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_HYDRA_2_NOT_CONNECTED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_HYDRA_2_MACHINE_ERROR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_HYDRA_3_NOT_CONNECTED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_HYDRA_3_MACHINE_ERROR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_MOD_BUS_NOT_CONNECTED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_MOXA_NOT_CONNECTED, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_PROXIMITY_SWITCH_WAFER_X_LSI, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_TEMPERATURE_ERROR, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MET50_ERROR_TEMPERATURE_WARNING ...
        };

        cecTypeEncoderError = {...
            ... Hydra 1
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_WAFER_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_WAFER_COARSE_Y, ...
            ... Hyrda 2
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_RETICLE_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_RETICLE_COARSE_Y, ...
            ... Hydra 3
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_LSI_COARSE_X, ...
            ... 712 1
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_WAFER_COARSE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_WAFER_COARSE_TIP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_WAFER_COARSE_TILT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_WAFER_FINE_Z, ...
            ... 712 2
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_RETICLE_COARSE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_RETICLE_COARSE_TIP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_RETICLE_COARSE_TILT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_RETICLE_FINE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_ENCODER_ERROR_RETICLE_FINE_Y ...
        };

        cecTypeMotorError = {...
            ... Hydra 1
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_WAFER_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y, ...
            ... Hyrda 2
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y, ...
            ... Hydra 3
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_LSI_COARSE_X, ...
            ... 712 1
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_WAFER_COARSE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_WAFER_COARSE_TIP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_WAFER_COARSE_TILT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_WAFER_FINE_Z, ...
            ... 712 2
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_RETICLE_COARSE_TIP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_RETICLE_COARSE_TILT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_RETICLE_FINE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_RETICLE_FINE_Y, ...
            ... Hydra 1
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_WAFER_COARSE_X_HOMING, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_HOMING, ...
            ... Hyrda 2
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_HOMING, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_HOMING, ...
            ... Hydra 3
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_LSI_COARSE_X_HOMING, ...
            ... Hydra 1
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_WAFER_COARSE_X_ALTERA, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_ALTERA, ...
            ... Hyrda 2
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_ALTERA, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_ALTERA, ...
            ... Hydra 3
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_ERROR_LSI_COARSE_X_ALTERA ...
        };

        cecTypeMotorStatusMoving = { ...
            ... Hydra 1
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_Y, ...
            ... Hyrda 2
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_Y, ...
            ... Hydra 3
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_LSI_COARSE_X, ...
            ... 712 1
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_TIP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_TILT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_WAFER_FINE_Z, ...
            ... 712 2
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_TIP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_TILT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_RETICLE_FINE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MOVING_RETICLE_FINE_Y ...
        };

        cecTypeMotorStatusOpenLoop = {...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_Y, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_Y, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_LSI_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_TIP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_TILT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_FINE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_TIP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_TILT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_FINE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_FINE_Y, ...
        };

        cecTypeMotorStatusMinusLimit = {...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_Y, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_Y, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_LSI_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_TIP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_TILT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_FINE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_TIP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_TILT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_FINE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_FINE_Y ...
        };

        cecTypeMotorStatusPlusLimit = {...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_Y, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_Y, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_LSI_COARSE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_TIP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_TILT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_FINE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_Z, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_TIP, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_TILT, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_FINE_X, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_FINE_Y ...
        };
    
        % {cell of {cell of char 1xn} 1 x m}
        % Can use this in a double for loop to easily loop through all
        % types
        ceceTypes = {
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cecTypeCsError, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cecTypeCsStatus, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cecTypeMotorError, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cecTypeMotorStatusMoving, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cecTypeMotorStatusOpenLoop, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cecTypeMotorStatusMinusLimit, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cecTypeMotorStatusPlusLimit, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cecTypeEncoderError, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cecTypeGlobError, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cecTypeIoInfo, ...
            bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware.cecTypeMet50Error ...
        };
    
        % {double 1xm} number of prefix words in the type name that can
        % be skipped / omitted when displaying
        u8WordsToSkip = [3, 3, 3, 4, 5, 5, 5, 3, 3, 3, 3];
            
        
    end
    
    
    properties (Access = private)
        
        % {< bl12014.Hardware 1x1}
        hardware
        
        % {char 1xm} the axis to control (see cAXIS_* constants)
        cAxis
        
        % {char 1xm} see cTYPE_CATEGORY_*
        cTypeCategory
        
        % {char 1xm} see cTYPE_*
        cType
    end
    
    
    properties
        % {cell of char 1xm}
  
        
        
    end
    
    methods
        
        function this = GetLogicalDeltaTauPowerPmacFromHardware(hardware, cType)
            
            this.hardware = hardware;
            this.cType = cType;
            
            switch this.cType
                case this.cecTypeCsError % this is a cell array so any one of these
                    this.cTypeCategory = this.cTYPE_CATEGORY_CS_ERROR;
                case this.cecTypeCsStatus 
                    this.cTypeCategory = this.cTYPE_CATEGORY_CS_STATUS;
                case this.cecTypeEncoderError
                    this.cTypeCategory = this.cTYPE_CATEGORY_ENCODER_ERROR;
                case this.cecTypeGlobError
                    this.cTypeCategory = this.cTYPE_CATEGORY_GLOB_ERROR;
                case this.cecTypeIoInfo
                    this.cTypeCategory = this.cTYPE_CATEGORY_IO_INFO;
                case this.cecTypeMet50Error
                    this.cTypeCategory = this.cTYPE_CATEGORY_MET50_ERROR;
                case this.cecTypeMotorError
                    this.cTypeCategory = this.cTYPE_CATEGORY_MOTOR_ERROR;
                case this.cecTypeMotorStatusMoving
                    this.cTypeCategory = this.cTYPE_CATEGORY_MOTOR_STATUS_MOVING;
                case this.cecTypeMotorStatusOpenLoop
                    this.cTypeCategory = this.cTYPE_CATEGORY_MOTOR_STATUS_OPEN_LOOP;
                case this.cecTypeMotorStatusMinusLimit
                    this.cTypeCategory = this.cTYPE_CATEGORY_MOTOR_STATUS_MINUS_LIMIT;
                case this.cecTypeMotorStatusPlusLimit
                    this.cTypeCategory = this.cTYPE_CATEGORY_MOTOR_STATUS_PLUS_LIMIT;
            end
            
            % fprintf('%s\n', this.cTypeCategory);
                    
        end
        
        
        function l = get(this)
            
            switch this.cTypeCategory
                
                case this.cTYPE_CATEGORY_CS_ERROR
                    l = this.getCsError();
                case this.cTYPE_CATEGORY_CS_STATUS
                    l = this.getCsStatus();
                case this.cTYPE_CATEGORY_MOTOR_ERROR
                    l = this.getMotorError();
                case this.cTYPE_CATEGORY_MOTOR_STATUS_MOVING
                    l = this.getMotorStatusMoving();
                case this.cTYPE_CATEGORY_MOTOR_STATUS_OPEN_LOOP
                    l = this.getMotorStatusOpenLoop();
                case this.cTYPE_CATEGORY_MOTOR_STATUS_MINUS_LIMIT
                    l = this.getMotorStatusMinusLimit();
                case this.cTYPE_CATEGORY_MOTOR_STATUS_PLUS_LIMIT
                    l = this.getMotorStatusPlusLimit();
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
                
        function l = getCsError(this)
            
            switch this.cType
                case this.cTYPE_CS_ERROR_WAFER_COARSE_SOFT_LIMIT
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorWaferCoarseSoftLimit();
                case this.cTYPE_CS_ERROR_WAFER_COARSE_RUN_TIME 
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorWaferCoarseRunTime();
                case this.cTYPE_CS_ERROR_WAFER_COARSE_LIMIT_STOP 
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorWaferCoarseLimitStop();
                case this.cTYPE_CS_ERROR_WAFER_COARSE_ERROR_STATUS
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorWaferCoarseErrorStatus();
                case this.cTYPE_CS_ERROR_WAFER_FINE_SOFT_LIMIT
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorWaferFineSoftLimit();
                case this.cTYPE_CS_ERROR_WAFER_FINE_RUN_TIME
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorWaferFineRunTime();
                case this.cTYPE_CS_ERROR_WAFER_FINE_LIMIT_STOP
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorWaferFineLimitStop();
                case this.cTYPE_CS_ERROR_WAFER_FINE_ERROR_STATUS 
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorWaferFineErrorStatus();
                case this.cTYPE_CS_ERROR_RETICLE_COARSE_SOFT_LIMIT 
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorReticleCoarseSoftLimit();
                case this.cTYPE_CS_ERROR_RETICLE_COARSE_RUN_TIME
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorReticleCoarseRunTime();
                case this.cTYPE_CS_ERROR_RETICLE_COARSE_LIMIT_STOP
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorReticleCoarseLimitStop();
                case this.cTYPE_CS_ERROR_RETICLE_COARSE_ERROR_STATUS
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorReticleCoarseErrorStatus();
                case this.cTYPE_CS_ERROR_RETICLE_FINE_SOFT_LIMIT
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorReticleFineSoftLimit();
                case this.cTYPE_CS_ERROR_RETICLE_FINE_RUN_TIME
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorReticleFineRunTime();
                case this.cTYPE_CS_ERROR_RETICLE_FINE_LIMIT_STOP
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorReticleFineLimitStop();
                case this.cTYPE_CS_ERROR_RETICLE_FINE_ERROR_STATUS
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorReticleFineErrorStatus();
                case this.cTYPE_CS_ERROR_LSI_COARSE_SOFT_LIMIT
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorLsiCoarseSoftLimit();
                case this.cTYPE_CS_ERROR_LSI_COARSE_RUN_TIME
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorLsiCoarseRunTime();
                case this.cTYPE_CS_ERROR_LSI_COARSE_LIMIT_STOP
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorLsiCoarseLimitStop();
                case this.cTYPE_CS_ERROR_LSI_COARSE_ERROR_STATUS
                    l = this.hardware.getDeltaTauPowerPmac().getCsErrorLsiCoarseErrorStatus();
            end
        
        end
        
        function l = getCsStatus(this)
            
            switch this.cType
                
                case this.cTYPE_CS_STATUS_WAFER_COARSE_NOT_HOMED
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusWaferCoarseNotHomed();
                case this.cTYPE_CS_STATUS_WAFER_COARSE_TIMEBASE_DEVIATION
                    l = this.hardware.getDeltaTauPowerPmac().getCsStatusWaferCoarseTimebaseDeviation();
                case this.cTYPE_CS_STATUS_WAFER_COARSE_PROGRAM_RUNNING
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusWaferCoarseProgramRunning();
                case this.cTYPE_CS_STATUS_WAFER_FINE_NOT_HOMED
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusWaferFineNotHomed();
                case this.cTYPE_CS_STATUS_WAFER_FINE_TIMEBASE_DEVIATION
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusWaferFineTimebaseDeviation();
                case this.cTYPE_CS_STATUS_WAFER_FINE_PROGRAM_RUNNING
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusWaferFineProgramRunning();
                case this.cTYPE_CS_STATUS_RETICLE_COARSE_NOT_HOMED
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusReticleCoarseNotHomed();
                case this.cTYPE_CS_STATUS_RETICLE_COARSE_TIMEBASE_DEVIATION
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusReticleCoarseTimebaseDeviation();
                case this.cTYPE_CS_STATUS_RETICLE_COARSE_PROGRAM_RUNNING
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusReticleCoarseProgramRunning();
                case this.cTYPE_CS_STATUS_RETICLE_FINE_NOT_HOMED
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusReticleFineNotHomed();
                case this.cTYPE_CS_STATUS_RETICLE_FINE_TIMEBASE_DEVIATION
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusReticleFineTimebaseDeviation();
                case this.cTYPE_CS_STATUS_RETICLE_FINE_PROGRAM_RUNNING
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusReticleFineProgramRunning();
                case this.cTYPE_CS_STATUS_LSI_COARSE_NOT_HOMED
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusLsiCoarseNotHomed();
                case this.cTYPE_CS_STATUS_LSI_COARSE_TIMEBASE_DEVIATION
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusLsiCoarseTimebaseDeviation();
                case this.cTYPE_CS_STATUS_LSI_COARSE_PROGRAM_RUNNING
                     l = this.hardware.getDeltaTauPowerPmac().getCsStatusLsiCoarseProgramRunning();

            end
        end
        
        function l = getMotorError(this)
            
            switch this.cType
                
                % Hydra 1
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorWaferCoarseX();
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorWaferCoarseY();
                % Hyrda 2
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorReticleCoarseX();
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorReticleCoarseY();
                % Hydra 3
                case this.cTYPE_MOTOR_ERROR_LSI_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorLsiCoarseX();
                % 712 1
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorWaferCoarseZ();
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_TIP
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorWaferCoarseTip();
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_TILT
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorWaferCoarseTilt();
                case this.cTYPE_MOTOR_ERROR_WAFER_FINE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorWaferFineZ();
                % 712 2
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorReticleCoarseZ();
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_TIP
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorReticleCoarseTip();
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_TILT
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorReticleCoarseTilt();
                case this.cTYPE_MOTOR_ERROR_RETICLE_FINE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorReticleFineX();
                case this.cTYPE_MOTOR_ERROR_RETICLE_FINE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorReticleFineY();

                % Hydra 1
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_X_HOMING
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorWaferCoarseXHoming();
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_HOMING
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorWaferCoarseYHoming();
                % Hyrda 2
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_HOMING
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorReticleCoarseXHoming();
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_HOMING
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorReticleCoarseYHoming();
                % Hydra 3
                case this.cTYPE_MOTOR_ERROR_LSI_COARSE_X_HOMING
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorLsiCoarseXHoming();


                % Hydra 1
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_X_ALTERA
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorWaferCoarseXAltera();
                case this.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_ALTERA
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorWaferCoarseYAltera();
                % Hyrda 2
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_ALTERA
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorReticleCoarseXAltera();
                case this.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_ALTERA
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorReticleCoarseYAltera();
                % Hydra 3
                case this.cTYPE_MOTOR_ERROR_LSI_COARSE_X_ALTERA
                    l = this.hardware.getDeltaTauPowerPmac().getMotorErrorLsiCoarseXAltera();
            end
        end
        
        function l = getMotorStatusMoving(this)
            
            switch this.cType
                
                % Hydra 1
                case this.cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusWaferCoarseXIsMoving();
                case this.cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusWaferCoarseYIsMoving();
                % Hyrda 2
                case this.cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusReticleCoarseXIsMoving();
                case this.cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusReticleCoarseYIsMoving();
                % Hydra 3
                case this.cTYPE_MOTOR_STATUS_MOVING_LSI_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusLsiCoarseXIsMoving();
                % 712 1
                case this.cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusWaferCoarseZIsMoving();
                case this.cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_TIP
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusWaferCoarseTipIsMoving();
                case this.cTYPE_MOTOR_STATUS_MOVING_WAFER_COARSE_TILT
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusWaferCoarseTiltIsMoving();
                case this.cTYPE_MOTOR_STATUS_MOVING_WAFER_FINE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusWaferFineZIsMoving();
                % 712 2
                case this.cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusReticleCoarseZIsMoving();
                case this.cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_TIP
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusReticleCoarseTipIsMoving();
                case this.cTYPE_MOTOR_STATUS_MOVING_RETICLE_COARSE_TILT
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusReticleCoarseTiltIsMoving();
                case this.cTYPE_MOTOR_STATUS_MOVING_RETICLE_FINE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusReticleFineXIsMoving();
                case this.cTYPE_MOTOR_STATUS_MOVING_RETICLE_FINE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusReticleFineYIsMoving();
            end
        end
        
        
        
        function l = getMotorStatusOpenLoop(this)
            
            switch this.cType
                
                % Hydra 1
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopWaferCoarseX();
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopWaferCoarseY();
                % Hyrda 2
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopReticleCoarseX();
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopReticleCoarseY();
                % Hydra 3
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_LSI_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopLsiCoarseX();
                % 712 1
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopWaferCoarseZ();
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_TIP
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopWaferCoarseTip();
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_COARSE_TILT
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopWaferCoarseTilt();
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_WAFER_FINE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopWaferFineZ();
                % 712 2
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopReticleCoarseZ();
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_TIP
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopReticleCoarseTip();
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_COARSE_TILT
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopReticleCoarseTilt();
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_FINE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopReticleFineX();
                case this.cTYPE_MOTOR_STATUS_OPEN_LOOP_RETICLE_FINE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusOpenLoopReticleFineY();
            end
        end
        
        
        function l = getMotorStatusMinusLimit(this)
            
            switch this.cType
                
                % Hydra 1
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitWaferCoarseX();
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitWaferCoarseY();
                % Hyrda 2
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitReticleCoarseX();
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitReticleCoarseY();
                % Hydra 3
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_LSI_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitLsiCoarseX();
                % 712 1
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitWaferCoarseZ();
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_TIP
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitWaferCoarseTip();
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_COARSE_TILT
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitWaferCoarseTilt();
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_WAFER_FINE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitWaferFineZ();
                % 712 2
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitReticleCoarseZ();
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_TIP
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitReticleCoarseTip();
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_COARSE_TILT
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitReticleCoarseTilt();
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_FINE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitReticleFineX();
                case this.cTYPE_MOTOR_STATUS_MINUS_LIMIT_RETICLE_FINE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusMinusLimitReticleFineY();
            end
        end
        
        
        function l = getMotorStatusPlusLimit(this)
            
            switch this.cType
                
                % Hydra 1
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitWaferCoarseX();
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitWaferCoarseY();
                % Hyrda 2
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitReticleCoarseX();
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitReticleCoarseY();
                % Hydra 3
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_LSI_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitLsiCoarseX();
                % 712 1
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitWaferCoarseZ();
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_TIP
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitWaferCoarseTip();
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_COARSE_TILT
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitWaferCoarseTilt();
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_WAFER_FINE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitWaferFineZ();
                % 712 2
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitReticleCoarseZ();
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_TIP
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitReticleCoarseTip();
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_COARSE_TILT
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitReticleCoarseTilt();
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_FINE_X
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitReticleFineX();
                case this.cTYPE_MOTOR_STATUS_PLUS_LIMIT_RETICLE_FINE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getMotorStatusPlusLimitReticleFineY();
            end
        end
        
        function l = getEncoderError(this)
            
            switch this.cType
                % Hydra 1
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorWaferCoarseX();
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorWaferCoarseY();
                % Hyrda 2
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorReticleCoarseX();
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorReticleCoarseY();
                % Hydra 3
                case this.cTYPE_ENCODER_ERROR_LSI_COARSE_X
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorLsiCoarseX();
                % 712 1
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorWaferCoarseZ();
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_TIP
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorWaferCoarseTip();
                case this.cTYPE_ENCODER_ERROR_WAFER_COARSE_TILT
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorWaferCoarseTilt();
                case this.cTYPE_ENCODER_ERROR_WAFER_FINE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorWaferFineZ();
                % 712 2
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_Z
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorReticleCoarseZ();
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_TIP
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorReticleCoarseTip();
                case this.cTYPE_ENCODER_ERROR_RETICLE_COARSE_TILT
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorReticleCoarseTilt();
                case this.cTYPE_ENCODER_ERROR_RETICLE_FINE_X
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorReticleFineX();
                case this.cTYPE_ENCODER_ERROR_RETICLE_FINE_Y
                    l = this.hardware.getDeltaTauPowerPmac().getEncoderErrorReticleFineY();
            end
        end
        
        function l = getGlobError(this)
            
            switch this.cType
                
                case this.cTYPE_GLOB_ERROR_HW_CHANGE_ERROR
                    l = this.hardware.getDeltaTauPowerPmac().getGlobErrorHwChangeError();
                case this.cTYPE_GLOB_ERROR_NO_CLOCKS
                    l = this.hardware.getDeltaTauPowerPmac().getGlobErrorNoClocks();
                case this.cTYPE_GLOB_ERROR_SYS_PHASE_ERROR_CTR
                    l = this.hardware.getDeltaTauPowerPmac().getGlobErrorSysPhaseErrorCtr();
                case this.cTYPE_GLOB_ERROR_SYS_RT_INT_BUSY_CTR
                    l = this.hardware.getDeltaTauPowerPmac().getGlobErrorSysRtIntBusyCtr();
                case this.cTYPE_GLOB_ERROR_SYS_RT_INT_ERROR_CTR
                    l = this.hardware.getDeltaTauPowerPmac().getGlobErrorSysRtIntErrorCtr();
                case this.cTYPE_GLOB_ERROR_SYS_SERVO_BUSY_CTR
                    l = this.hardware.getDeltaTauPowerPmac().getGlobErrorSysServoBusyCtr();
                case this.cTYPE_GLOB_ERROR_SYS_SERVO_ERROR_CTR
                    l = this.hardware.getDeltaTauPowerPmac().getGlobErrorSysServoErrorCtr();
                case this.cTYPE_GLOB_ERROR_WDT_FAULT
                    l = this.hardware.getDeltaTauPowerPmac().getGlobErrorWdtFault();
            end
        end
        
        function l = getIoInfo(this)
            
            switch this.cType
                case this.cTYPE_IO_INFO_AT_RETICLE_TRANSFER_POSITION
                    l = this.hardware.getDeltaTauPowerPmac().getIoInfoAtReticleTransferPosition();
                case this.cTYPE_IO_INFO_AT_WAFER_TRANSFER_POSITION
                    l = this.hardware.getDeltaTauPowerPmac().getIoInfoAtWaferTransferPosition();
                case this.cTYPE_IO_INFO_ENABLE_SYSTEM_IS_ZERO
                    l = this.hardware.getDeltaTauPowerPmac().getIoInfoEnableSystemIsZero();
                case this.cTYPE_IO_INFO_LOCK_RETICLE_POSITION
                    l = this.hardware.getDeltaTauPowerPmac().getIoInfoLockReticlePosition();
                case this.cTYPE_IO_INFO_LOCK_WAFER_POSITION
                    l = this.hardware.getDeltaTauPowerPmac().getIoInfoLockWaferPosition();
                case this.cTYPE_IO_INFO_RETICLE_POSITION_LOCKED
                    l = this.hardware.getDeltaTauPowerPmac().getIoInfoReticlePositionLocked();
                case this.cTYPE_IO_INFO_SYSTEM_ENABLED_IS_ZERO
                    l = this.hardware.getDeltaTauPowerPmac().getIoInfoSystemEnabledIsZero();
                case this.cTYPE_IO_INFO_WAFER_POSITION_LOCKED
                    l = this.hardware.getDeltaTauPowerPmac().getIoInfoWaferPositionLocked();
            end
            
        end
        
        function l = getMet50Error(this)
            
            % fprintf('getMet50Error\n');
            switch this.cType
                case this.cTYPE_MET50_ERROR_712_1_NOT_CONNECTED
                    l = this.hardware.getDeltaTauPowerPmac().getMet50Error7121NotConnected();
                case this.cTYPE_MET50_ERROR_712_1_READ_ERROR
                    l = this.hardware.getDeltaTauPowerPmac().getMet50Error7121ReadError();
                case this.cTYPE_MET50_ERROR_712_1_WRITE_ERROR
                    l = this.hardware.getDeltaTauPowerPmac().getMet50Error7121WriteError();
                case this.cTYPE_MET50_ERROR_712_2_NOT_CONNECTED
                    l = this.hardware.getDeltaTauPowerPmac().getMet50Error7122NotConnected();
                case this.cTYPE_MET50_ERROR_712_2_READ_ERROR
                    l = this.hardware.getDeltaTauPowerPmac().getMet50Error7122ReadError();
                case this.cTYPE_MET50_ERROR_712_2_WRITE_ERROR
                    l = this.hardware.getDeltaTauPowerPmac().getMet50Error7122WriteError();
                case this.cTYPE_MET50_ERROR_C_APP_NOT_RUNNING
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorCAppNotRunning();
                case this.cTYPE_MET50_ERROR_DMI_STATUS
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorDmiStatus();
                case this.cTYPE_MET50_ERROR_HS_STATUS
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorHsStatus();
                case this.cTYPE_MET50_ERROR_HYDRA_1_NOT_CONNECTED
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorHydra1NotConnected();
                case this.cTYPE_MET50_ERROR_HYDRA_1_MACHINE_ERROR
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorHydra1MachineError();
                case this.cTYPE_MET50_ERROR_HYDRA_2_NOT_CONNECTED
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorHydra2NotConnected();
                case this.cTYPE_MET50_ERROR_HYDRA_2_MACHINE_ERROR
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorHydra2MachineError();
                case this.cTYPE_MET50_ERROR_HYDRA_3_NOT_CONNECTED
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorHydra2NotConnected();
                case this.cTYPE_MET50_ERROR_HYDRA_3_MACHINE_ERROR
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorHydra3MachineError();
                case this.cTYPE_MET50_ERROR_MOD_BUS_NOT_CONNECTED
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorModBusNotConnected();
                case this.cTYPE_MET50_ERROR_MOXA_NOT_CONNECTED
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorMoxaNotConnected();
                case this.cTYPE_MET50_ERROR_PROXIMITY_SWITCH_WAFER_X_LSI
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorProximitySwitchWaferXLsi();
                case this.cTYPE_MET50_ERROR_TEMPERATURE_ERROR
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorTemperatureError();
                case this.cTYPE_MET50_ERROR_TEMPERATURE_WARNING
                    l = this.hardware.getDeltaTauPowerPmac().getMet50ErrorTemperatureWarning();

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

