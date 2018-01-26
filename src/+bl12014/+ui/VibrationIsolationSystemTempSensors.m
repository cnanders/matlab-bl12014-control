classdef VibrationIsolationSystemTempSensors < mic.Base
    
    properties

        % {mic.ui.device.GetNumber 1x1}}
        ui1
        
        % {mic.ui.device.GetNumber 1x1}}
        ui2
        
        % {mic.ui.device.GetNumber 1x1}}
        ui3
        
        % {mic.ui.device.GetNumber 1x1}}
        ui4
        
        
        
    end
    
    properties (SetAccess = private)
        
        dWidth = 300
        dHeight = 155
        
        cName = 'Vibration Isolation System TempSensors'
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 30
        dWidthUnit = 90
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = VibrationIsolationSystemTempSensors(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        
        function turnOn(this)
            
            this.ui1.turnOn();
            this.ui2.turnOn();
            this.ui3.turnOn();
            this.ui4.turnOn();
            
            
            
            
        end
        
        function turnOff(this)
            this.ui1.turnOff();
            this.ui2.turnOff();
            this.ui3.turnOff();
            this.ui4.turnOff();
            
            
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'VIS Temp Sensors',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;            

            dTop = 20;
            dLeft = 10;
            dSep = 30;
            
            this.ui1.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.ui2.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui3.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui4.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            
            
           
            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end    
        
        
    end
    
    methods (Access = private)
                
         
        function initUi1(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-vis-temp-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.ui1 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'cName', 'vis-temp-sensor-1', ...
                'config', uiConfig, ...
                'cLabel', '1' ...
            );
        end
        
        function initUi2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-vis-temp-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.ui2 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'cName', 'vis-temp-sensor-2', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'cLabel', '2' ...
            );
        end
        
        function initUi3(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-vis-temp-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.ui3 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'cName', 'vis-temp-sensor-3', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'cLabel', '3' ...
            );
        end
        
        function initUi4(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-vis-temp-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.ui4 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'cName', 'vis-temp-sensor-4', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'cLabel', '1' ...
            );
        end
        
        
        
        
        function init(this)
            this.msg('init()');
            this.initUi1();
            this.initUi2();
            this.initUi3();
            this.initUi4();
            
        end
        
        
    end
    
    
end

