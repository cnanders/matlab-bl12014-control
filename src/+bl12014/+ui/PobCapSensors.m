classdef PobCapSensors < mic.Base
    
    properties

        % {mic.ui.device.GetNumber 1x1}}
        uiCap1
        
        % {mic.ui.device.GetNumber 1x1}}
        uiCap2
        
        % {mic.ui.device.GetNumber 1x1}}
        uiCap3
        
        % {mic.ui.device.GetNumber 1x1}}
        uiCap4
        
        
        
    end
    
    properties (SetAccess = private)
        
        dWidth = 600
        dHeight = 160
        
        cName = 'POB Cap Sensors'
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 70
        dWidthUnit = 80
        dWidthVal = 75
        dWidthPadUnit = 280
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = PobCapSensors(varargin)
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
            
            this.uiCap1.turnOn();
            this.uiCap2.turnOn();
            this.uiCap3.turnOn();
            this.uiCap4.turnOn();
            
            
            
            
        end
        
        function turnOff(this)
            this.uiCap1.turnOff();
            this.uiCap2.turnOff();
            this.uiCap3.turnOff();
            this.uiCap4.turnOff();
            
            
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'POB Cap Sensors',...
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
            
            this.uiCap1.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiCap2.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCap3.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCap4.build(this.hPanel, dLeft, dTop);
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
                
         
        function initUiCap1(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-pob-cap-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCap1 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'pob-cap-sensor-1', ...
                'config', uiConfig, ...
                'cLabel', '1' ...
            );
        end
        
        function initUiCap2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-pob-cap-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCap2 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'pob-cap-sensor-2', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'cLabel', '2' ...
            );
        end
        
        function initUiCap3(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-pob-cap-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCap3 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'pob-cap-sensor-3', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'cLabel', '3' ...
            );
        end
        
        function initUiCap4(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-pob-cap-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCap4 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'pob-cap-sensor-4', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'cLabel', '4' ...
            );
        end
        
       
        
        
        
        function init(this)
            this.msg('init()');
            this.initUiCap1();
            this.initUiCap2();
            this.initUiCap3();
            this.initUiCap4();
            
            
        end
        
        
        
    end
    
    
end

