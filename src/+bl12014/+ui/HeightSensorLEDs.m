classdef HeightSensorLEDs < mic.Base
    
    properties

        % {mic.ui.device.GetSetNumber 1x1}}
        ui1
        ui2
        ui3
        ui4
        ui5
        ui6
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommMightex
        
        
        
    end
    
    properties (SetAccess = private)
        
        dWidth = 475
        dHeight = 255
        
        cName = 'Height Sensor LEDs'
        
        lShowStores = false
        lShowZero = false
        lShowRel = false
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        hFigure
        
        dWidthName = 70
        dWidthUnit = 80
        dWidthVal = 75
        dWidthPadUnit = 25 % 280

        
    end
    
    methods
        
        function this = HeightSensorLEDs(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        function connectMightex1(this)
            
            device = bl12014.device.GetSetNumberFromMightexUniversalLedController(1);
            this.ui1.setDevice(device);
            this.ui1.turnOn();
            this.ui1.syncDestination();
            
            device = bl12014.device.GetSetNumberFromMightexUniversalLedController(2);
            this.ui2.setDevice(device);
            this.ui2.turnOn();
            this.ui2.syncDestination();
            
            device = bl12014.device.GetSetNumberFromMightexUniversalLedController(3);
            this.ui3.setDevice(device);
            this.ui3.turnOn();
            this.ui3.syncDestination();
            
            device = bl12014.device.GetSetNumberFromMightexUniversalLedController(4);
            this.ui4.setDevice(device);
            this.ui4.turnOn();
            this.ui4.syncDestination();
            
        end
        
        function connectMightex2(this, comm)
            
            device = bl12014.device.GetSetNumberFromMightexUniversalLedController(1);
            this.ui5.setDevice(device);
            this.ui5.turnOn();
            this.ui5.syncDestination();
            
            device = bl12014.device.GetSetNumberFromMightexUniversalLedController(2);
            this.ui6.setDevice(device);
            this.ui6.turnOn();
            this.ui6.syncDestination();
        end
        
        
        function disconnectMightex(this)
            
            this.ui1.turnOff();
            this.ui1.setDevice([]);
            
            this.ui2.turnOff();
            this.ui2.setDevice([]);
            
            this.ui3.turnOff();
            this.ui3.setDevice([]);
            
            this.ui4.turnOff();
            this.ui4.setDevice([]);
            
            
        end
        
        function disconnectMightex2(this)
            
            this.ui5.turnOff();
            this.ui5.setDevice([]);
            
            this.ui6.turnOff();
            this.ui6.setDevice([]);
        end
        
        

        function build(this) % , hParent, dLeft, dTop
            
            %{
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Height Sensor LEDs',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
            %}
            
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');

            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'Height Sensor LEDs', ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onCloseRequest ...
            );
            
            
			drawnow;            

            dTop = 20;
            dLeft = 10;
            dSep = 30;
            
            this.uiCommMightex.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 5 + dSep;
            
            this.ui1.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.ui2.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui3.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui4.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui5.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui6.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end    
        
        
    end
    
    methods (Access = private)
                
         
        function onCloseRequest(this, src, evt)
            this.msg('HeightSensorLEDs.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        function initUi1(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-height-sensor-led.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.ui1 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'height-sensor-led-1', ...
                'config', uiConfig, ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'cLabel', 'z 5:30 (1)' ...
            );
        end
        
        function initUi2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-height-sensor-led.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.ui2 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'height-sensor-led-2', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'cLabel', 'z 9:30 (2)' ...
            );
        end
        
        function initUi3(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-height-sensor-led.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.ui3 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'height-sensor-led-3', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'cLabel', 'z 1:30 (3)' ...
            );
        end
        
        function initUi4(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-height-sensor-led.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.ui4 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'height-sensor-led-4', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'cLabel', 'ang 0:30 (4)' ...
            );
        end
        
        function initUi5(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-height-sensor-led.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.ui5 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'height-sensor-led-5', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'cLabel', 'ang 4:30 (5)' ...
            );
        end
        
        function initUi6(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-height-sensor-led.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.ui6 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'height-sensor-led-6', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'cLabel', 'ang 8:30 (6)' ...
            );
        end
        
        
        function initUiCommMightex(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommMightex = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'mightex-height-sensor-leds', ...
                'cLabel', 'Mightex LED Controller' ...
            );
        
        end
        
       
        
        
        
        function init(this)
            this.msg('init()');
            this.initUi1();
            this.initUi2();
            this.initUi3();
            this.initUi4();
            this.initUi5();
            this.initUi6();
            this.initUiCommMightex();
            
            
        end
        
        
        
    end
    
    
end

