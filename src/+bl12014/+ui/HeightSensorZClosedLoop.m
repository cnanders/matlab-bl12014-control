classdef HeightSensorZClosedLoop < mic.Base
    
    properties
            
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiZHeightSensor
        
        % {mic.ui.device.GetNumber 1x1}}
        uiZWafer
                
    end
    
    
    properties (SetAccess = private)
        
        dWidthRange = 120
        dWidth = 690
        dHeight = 100
        
        cName = 'ui-height-sensor-closed-loop-z'
        lShowRange = true
        lShowZWafer = true
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 70
        
    end
    
    methods
        
        function this = HeightSensorZClosedLoop(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        function disconnectDeltaTauPowerPmacAndDriftMonitor(this)
            
            this.uiZWafer.turnOff();
            this.uiZWafer.setDevice([]);
            
            this.uiZHeightSensor.turnOff();
            this.uiZHeightSensor.setDevice([]);
            
        end
        
        function connectDeltaTauPowerPmacAndDriftMonitor(this, commDeltaTauPowerPmac, commDriftMonitor)
            
            import bl12014.device.GetSetNumberFromDeltaTauPowerPmac
            import bl12014.device.GetSetTextFromDeltaTauPowerPmac
            import bl12014.device.GetNumberFromSimpleHeightSensorZ
            
            deviceZWafer = GetSetNumberFromDeltaTauPowerPmac(...
                commDeltaTauPowerPmac, ...
                GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_FINE_Z ...
            );

            deviceZHeightSensor = GetNumberFromSimpleHeightSensorZ(commDriftMonitor);

            deviceZHeightSensorControl = bl12014.device.HeightSensorZClosedLoop(...
                this.clock, ...
                deviceZWafer, ...
                deviceZHeightSensor, ...
                'u8MovesMax', uint8(5) ...
            );
        
        
            this.uiZWafer.setDevice(deviceZWafer);
            this.uiZWafer.turnOn();
            this.uiZWafer.syncDestination();
            
            this.uiZHeightSensor.setDevice(deviceZHeightSensorControl);
            this.uiZHeightSensor.turnOn();
            this.uiZHeightSensor.syncDestination();
            
            
        end

        
        function build(this, hParent, dLeft, dTop)
            
            if ~this.lShowZWafer
                this.dHeight = this.dHeight - 25;
            end
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Height Sensor Z Fine (Adjust Fine Z to Achieve Target) (Tol = 1 nm)',...
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
            
            this.uiZHeightSensor.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            if this.lShowZWafer
                this.uiZWafer.build(this.hPanel, dLeft, dTop);
                dTop = dTop + dSep;
            end

            
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
            st.uiZHeightSensor = this.uiZHeightSensor.save();
            st.uiZWafer = this.uiZWafer.save();

        end
        
        function load(this, st)
            if isfield(st, 'uiZHeightSensor')
                this.uiZHeightSensor.load(st.uiZHeightSensor)
            end
            
            if isfield(st, 'uiZWafer')
                this.uiZWafer.load(st.uiZWafer)
            end
            
            
        end
        
        
    end
    
    methods (Access = private)
        
        
        
         
        function initUiZHeightSensor(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-height-sensor-z.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiZHeightSensor = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthDest', 70, ...
                'lShowStores', false, ...
                'cName', sprintf('%s-z-height-sensor-closed-loop', this.cName), ...
                'config', uiConfig, ...
                'dWidthRange', this.dWidthRange, ...
                'lShowRange', this.lShowRange, ...
                'lValidateByConfigRange', true, ...
                'cLabel', 'Z HS' ...
            );
        end
        
        function initUiZWafer(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-fine-stage-z.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiZWafer = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'dWidthDest', 70, ...
                'lShowStores', false, ...
                ... %'dWidthPadRange', 182 + 20, ...
                'cName', sprintf('%s-z-wafer', this.cName), ...
                'config', uiConfig, ...
                'dWidthRange', this.dWidthRange, ...
                'lShowRange', this.lShowRange, ...
                'lValidateByConfigRange', true, ...
                'cLabel', 'Z Wafer' ...
            );
        end
        
        
        function init(this)
            this.msg('init()');
            this.initUiZHeightSensor();
            this.initUiZWafer();
            
        end
        
        
        
    end
    
    
end

