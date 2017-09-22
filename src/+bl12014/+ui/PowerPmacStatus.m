classdef PowerPmacStatus < mic.Base
    
    properties (Access = private)
        
        dWidth = 1600
        dHeight = 800
               
    end
    
    properties
               
        % {cell of mic.ui.device.GetLogical m x n}
        uiGetLogicals = {}
        
        % {cell of mic.ui.common.Text 1 x m}
        uiTexts = {}
        
        % {cell of cell 1 x m}
        ceceTypes
        
        cecCsError = {...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_WAFER_COARSE_SOFT_LIMIT, ... 
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_WAFER_COARSE_RUN_TIME, ... 
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_WAFER_COARSE_LIMIT_STOP, ... 
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_WAFER_COARSE_ERROR_STATUS, ... 
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_WAFER_FINE_SOFT_LIMIT, ... 
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_WAFER_FINE_RUN_TIME, ... 
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_WAFER_FINE_LIMIT_STOP, ... 
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_WAFER_FINE_ERROR_STATUS, ... 
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_RETICLE_COARSE_SOFT_LIMIT, ... 
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_RETICLE_COARSE_RUN_TIME, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_RETICLE_COARSE_LIMIT_STOP, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_RETICLE_COARSE_ERROR_STATUS, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_RETICLE_FINE_SOFT_LIMIT, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_RETICLE_FINE_RUN_TIME, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_RETICLE_FINE_LIMIT_STOP, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_RETICLE_FINE_ERROR_STATUS, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_LSI_COARSE_SOFT_LIMIT, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_LSI_COARSE_RUN_TIME, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_LSI_COARSE_LIMIT_STOP, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_ERROR_LSI_COARSE_ERROR_STATUS ...
        };

        cecCsStatus = {...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_WAFER_COARSE_NOT_HOMED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_WAFER_COARSE_TIMEBASE_DEVIATION, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_WAFER_COARSE_PROGRAM_RUNNING, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_WAFER_FINE_NOT_HOMED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_WAFER_FINE_TIMEBASE_DEVIATION, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_WAFER_FINE_PROGRAM_RUNNING, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_RETICLE_COARSE_NOT_HOMED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_RETICLE_COARSE_TIMEBASE_DEVIATION, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_RETICLE_COARSE_PROGRAM_RUNNING, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_RETICLE_FINE_NOT_HOMED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_RETICLE_FINE_TIMEBASE_DEVIATION, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_RETICLE_FINE_PROGRAM_RUNNING, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_LSI_COARSE_NOT_HOMED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_LSI_COARSE_TIMEBASE_DEVIATION, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_CS_STATUS_LSI_COARSE_PROGRAM_RUNNING ...
        };


        cecGlobError = {...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_GLOB_ERROR_HW_CHANGE_ERROR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_GLOB_ERROR_NO_CLOCKS, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_GLOB_ERROR_SYS_PHASE_ERROR_CTR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_GLOB_ERROR_SYS_RT_INT_BUSY_CTR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_GLOB_ERROR_SYS_RT_INT_ERROR_CTR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_GLOB_ERROR_SYS_SERVO_BUSY_CTR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_GLOB_ERROR_SYS_SERVO_ERROR_CTR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_GLOB_ERROR_WDT_FAULT ...
        };

        cecIoInfo = { ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_AT_RETICLE_TRANSFER_POSITION, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_AT_WAFER_TRANSFER_POSITION, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_ENABLE_SYSTEM_IS_ZERO, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_LOCK_RETICLE_POSITION, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_LOCK_WAFER_POSITION, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_RETICLE_POSITION_LOCKED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_SYSTEM_ENABLED_IS_ZERO, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_WAFER_POSITION_LOCKED ...
       }; 

       cecMet50Error = {...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_712_1_NOT_CONNECTED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_712_1_READ_ERROR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_712_1_WRITE_ERROR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_712_2_NOT_CONNECTED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_712_2_READ_ERROR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_712_2_WRITE_ERROR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_C_APP_NOT_RUNNING, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_DMI_STATUS, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_HS_STATUS, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_HYDRA_1_NOT_CONNECTED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_HYDRA_1_MACHINE_ERROR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_HYDRA_2_NOT_CONNECTED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_HYDRA_2_MACHINE_ERROR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_HYDRA_3_NOT_CONNECTED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_HYDRA_3_MACHINE_ERROR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_MOD_BUS_NOT_CONNECTED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_MOXA_NOT_CONNECTED, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_PROXIMITY_SWITCH_WAFER_X_LSI, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_TEMPERATURE_ERROR, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MET50_ERROR_TEMPERATURE_WARNING ...
        };

        cecEncoderError = {...
            ...% Hydra 1
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_WAFER_COARSE_X, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_WAFER_COARSE_Y, ...
            ...% Hyrda 2
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_RETICLE_COARSE_X, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_RETICLE_COARSE_Y, ...
            ...% Hydra 3
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_LSI_COARSE_X, ...
            ...% 712 1
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_WAFER_COARSE_Z, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_WAFER_COARSE_TIP, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_WAFER_COARSE_TILT, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_WAFER_FINE_Z, ...
            ...% 712 2
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_RETICLE_COARSE_Z, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_RETICLE_COARSE_TIP, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_RETICLE_COARSE_TILT, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_RETICLE_FINE_X, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_ENCODER_ERROR_RETICLE_FINE_Y ...
        };

        cecMotorError = {...
            ...% Hydra 1
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_WAFER_COARSE_X, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y, ...
            ...% Hyrda 2
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y, ...
            ...% Hydra 3
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_LSI_COARSE_X, ...
            ...% 712 1
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_WAFER_COARSE_Z, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_WAFER_COARSE_TIP, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_WAFER_COARSE_TILT, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_WAFER_FINE_Z, ...
            ...% 712 2
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Z, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_RETICLE_COARSE_TIP, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_RETICLE_COARSE_TILT, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_RETICLE_FINE_X, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_RETICLE_FINE_Y, ...
            ...% Hydra 1
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_WAFER_COARSE_X_HOMING, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_HOMING, ...
            ...% Hyrda 2
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_HOMING, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_HOMING, ...
            ...% Hydra 3
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_LSI_COARSE_X_HOMING, ...
            ...% Hydra 1
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_WAFER_COARSE_X_ALTERA, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_WAFER_COARSE_Y_ALTERA, ...
            ...% Hyrda 2
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_RETICLE_COARSE_X_ALTERA, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_RETICLE_COARSE_Y_ALTERA, ...
            ...% Hydra 3
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_ERROR_LSI_COARSE_X_ALTERA ...
        };

        cecMotorStatus = { ...
            ...% Hydra 1
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_WAFER_COARSE_X, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_WAFER_COARSE_Y, ...
            ...% Hyrda 2
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_RETICLE_COARSE_X, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_RETICLE_COARSE_Y, ...
            ...% Hydra 3
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_LSI_COARSE_X, ...
            ...% 712 1
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_WAFER_COARSE_Z, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_WAFER_COARSE_TIP, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_WAFER_COARSE_TILT, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_WAFER_FINE_Z, ...
            ...% 712 2
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_RETICLE_COARSE_Z, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_RETICLE_COARSE_TIP, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_RETICLE_COARSE_TILT, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_RETICLE_FINE_X, ...
            bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_MOTOR_STATUS_RETICLE_FINE_Y ...
        };

        cName = 'Power PMAC Status (Updates every 2 sec)'
        hFigure
        
        clock
        dWidthName = 140
        lShowDevice = false
        lShowInitButton = false
        
        %{ cell of char 1xm } list of titles of each status category
        cecTitles 
        
        dWidthColSep = 45
        
        
    end
    
    methods
        
        function this = PowerPmacStatus(varargin)
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            
            this.ceceTypes = {
                this.cecCsError, ...
                this.cecCsStatus, ...
                this.cecMotorError, ...
                this.cecMotorStatus, ...
                this.cecEncoderError, ...
                this.cecGlobError, ...
                this.cecIoInfo, ...
                this.cecMet50Error ...
            };
            
            this.cecTitles = {
                'CS Error', ...
                'CS Status', ...
                'Motor Error', ...
                'Motor Moving', ...
                'Encoder Error', ...
                'Global Error', ...
                'IO Info', ...
                'MET50 Error' ...
            };
            this.init();
            
        end
        
        
        function turnOn(this)
        
            for m = 1 : length(this.ceceTypes)
                for n = 1 : length(this.ceceTypes{m})
                    this.uiGetLogicals{m}{n}.turnOn();
                end
            end
                            
        end
        
        function turnOff(this)
            
            for m = 1 : length(this.ceceTypes)
                for n = 1 : length(this.ceceTypes{m})
                    this.uiGetLogicals{m}{n}.turnOff();
                end
            end
            
        end
        
        function buildUiGetLogicals(this)
            
            dTopStart = 30;
            dTop = dTopStart;
            dLeft = 10;
            dSep = 30;
            
            for m = 1 : length(this.ceceTypes)
                for n = 1 : length(this.ceceTypes{m})
                    this.uiGetLogicals{m}{n}.build(this.hFigure, dLeft, dTop);
                    dTop = dTop + dSep;
                end
                
                % Update dLeft (shift to right)
                dLeft = dLeft + this.dWidthName + this.dWidthColSep + 10;
                % Reset dTop
                dTop = dTopStart;
            end
            
        end
        
        function buildUiTexts(this)
            
            dTopStart = 10;
            dTop = dTopStart;
            dLeft = 10;
            
            for m = 1 : length(this.ceceTypes)
                    
                this.uiTexts{m}.build(this.hFigure, dLeft, dTop, this.dWidthName, 20);
                % Update dLeft (shift to right)
                dLeft = dLeft + this.dWidthName + this.dWidthColSep + 10;
                
            end
            
        end
        
          
        
        function build(this)
            
            this.buildFigure()
            this.buildUiTexts();
            this.buildUiGetLogicals();
                        
                       
        end
        
        function delete(this)
            
            this.msg('delete');
            
            this.turnOff();
                        
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end    
        
        
    end
    
    methods (Access = private)
        
        function buildFigure(this)
            
            % this.connect();
            % this.turnOn();
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', this.cName, ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onFigureCloseRequest ...
            );
        
			drawnow; 
        end
        
        function onFigureCloseRequest(this, src, evt)
            
            this.turnOff();
            this.msg('M143Control.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        
                
        function init(this)
            
            this.msg('init()');
            this.initUiGetLogicals(); 
            this.initUiTexts();
            
        end
        
        function initUiTexts(this)
            
            for m = 1 : length(this.cecTitles)
                this.uiTexts{m} = mic.ui.common.Text(...
                    'cVal', this.cecTitles{m}, ...
                    'dFontSize', 12, ...
                    'cFontWeight', 'bold' ...
                );
            end
        end
        
        
        function initUiGetLogicals(this)
            
            this.msg('initGetLogicals()');
            
            for m = 1 : length(this.ceceTypes)
                for n = 1 : length(this.ceceTypes{m})                    
                    if n == 1
                        % Initialize cell array
                        this.uiGetLogicals{m} = {};
                    end
            
                    lShowLabels = false;                    

                    cPathConfig = fullfile(...
                        bl12014.Utils.pathUiConfig(), ...
                        'get-logical', ...
                        'config-ping.json' ...
                    );
                    config = mic.config.GetSetLogical(...
                        'cPath', cPathConfig ...
                    );

                    % Make label
                    ceWords = strsplit(this.ceceTypes{m}{n}, '-');
                    cLabel = strjoin(ceWords(3:end), ' ');
                    this.uiGetLogicals{m}{n} = mic.ui.device.GetLogical(...
                       'clock', this.clock, ...
                       'config', config, ...
                       'dWidthName', this.dWidthName, ... 
                       'lShowDevice', this.lShowDevice, ...
                       'lShowLabels', lShowLabels, ...
                       'lShowInitButton', this.lShowInitButton, ...
                       'cName', this.ceceTypes{m}{n}, ...
                       'cLabel', cLabel ...
                    );
                end
            end            
        end
        
        
        
    end
    
    
end

