classdef WaferFocusSensor < mic.Base
    
    properties

        % {mic.ui.device.GetSetNumber 1x1}}
        uiTiltZ
        
        % {mic.ui.device.GetNumber 1x1}}
        uiCurrent
        
    end
    
    properties (SetAccess = private)
        
        dWidth = 600
        dHeight = 100
        
        cName = 'wafer-focus-sensor'
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 70
        dWidthUnit = 80
        dWidthVal = 75
        dWidthPadUnit = 277
        

        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = WaferFocusSensor(varargin)
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
            
            this.uiTiltZ.turnOn();
            this.uiCurrent.turnOn();
            
            
        end
        
        function turnOff(this)
            this.uiTiltZ.turnOff();
            this.uiCurrent.turnOff();
           
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wafer Focus Sensor',...
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
            
            this.uiTiltZ.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiCurrent.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
           
            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end  
        
        function st = save(this)
            st = struct();
            st.uiTiltZ = this.uiTiltZ.save();
            
        end
        
        function load(this, st)
            if isfield(st, 'uiZ')
                this.uiTiltZ.load(st.uiTiltZ)
            end
            
        end
        
        
    end
    
    methods (Access = private)
                
         
        function initUiTiltZ(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-focus-sensor-rot-z.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiTiltZ = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-rot-z', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Rot Z' ...
            );
        end
        
        function initUiCurrent(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-wafer-focus-sensor-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCurrent = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', sprintf('%s-current', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Current' ...
            );
        end
        
        
        
        function init(this)
            this.msg('init()');
            this.initUiTiltZ();
            this.initUiCurrent();
            
        end
        
        
        
    end
    
    
end

