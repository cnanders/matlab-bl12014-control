classdef HeightSensorRxClosedLoop < mic.Base
    
    properties
            
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiRxHeightSensor
        
        % {mic.ui.device.GetNumber 1x1}}
        uiRxWafer
                
    end
    
    
    properties (SetAccess = private)
        
        dWidthRange = 120
        dWidth = 850
        dHeight = 100
        
        cName = 'ui-height-sensor-closed-loop-rx'
        lShowRange = true
        lShowZWafer = true
        uiParentStageUI = []
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 70
        
    end
    
    methods
        
        function this = HeightSensorRxClosedLoop(varargin)
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
            
            this.uiRxWafer.turnOff();
            this.uiRxWafer.setDevice([]);
            
            this.uiRxHeightSensor.turnOff();
            this.uiRxHeightSensor.setDevice([]);
            
        end
        
        function connectDeltaTauPowerPmacAndDriftMonitor(this, commDeltaTauPowerPmac, commDriftMonitor)
            
            import bl12014.device.GetSetNumberFromDeltaTauPowerPmac
            import bl12014.device.GetSetTextFromDeltaTauPowerPmac
            import bl12014.device.GetNumberFromCalHeightSensor
            
            deviceRxWafer = GetSetNumberFromDeltaTauPowerPmac(...
                commDeltaTauPowerPmac, ...
                GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TIP ...
            );
        
            deviceRxHeightSensor = GetNumberFromCalHeightSensor(commDriftMonitor, 1); % 1 = rx, 2 = ry, 3 = z

            deviceRxHeightSensorControl = bl12014.device.HeightSensorCalClosedLoop(...
                this.clock, ...
                deviceRxWafer, ...
                deviceRxHeightSensor, ...
                this.uiParentStageUI, ...
                'u8MovesMax', uint8(5) ...
            );
        
        
            this.uiRxWafer.setDevice(deviceRxWafer);
            this.uiRxWafer.turnOn();
            this.uiRxWafer.syncDestination();
            
            this.uiRxHeightSensor.setDevice(deviceRxHeightSensorControl);
            this.uiRxHeightSensor.turnOn();
            this.uiRxHeightSensor.syncDestination();
            
            
        end

        
        function build(this, hParent, dLeft, dTop)
            
            if ~this.lShowZWafer
                this.dHeight = this.dHeight - 25;
            end
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Height Sensor Rx closed loop (Tol = 2 urad) (PPMAC + DriftMon)',...
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
            
            this.uiRxHeightSensor.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            if this.lShowZWafer
                this.uiRxWafer.build(this.hPanel, dLeft, dTop);
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
            st.uiRxHeightSensor = this.uiRxHeightSensor.save();
            st.uiRxWafer = this.uiRxWafer.save();

        end
        
        function load(this, st)
            if isfield(st, 'uiRxHeightSensor')
                this.uiRxHeightSensor.load(st.uiRxHeightSensor)
            end
            
            if isfield(st, 'uiRxWafer')
                this.uiRxWafer.load(st.uiRxWafer)
            end
            
            
        end
        
        
    end
    
    methods (Access = private)
        
        
        
         
        function inituiRxHeightSensor(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-rx-hs-cl.json'...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiRxHeightSensor = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthDest', 70, ...
                'lShowStores', true, ...
                'dWidthStores', 200, ...
                'cName', sprintf('%s-rx-height-sensor-closed-loop', this.cName), ...
                'config', uiConfig, ...
                'dWidthRange', this.dWidthRange, ...
                'lShowRange', this.lShowRange, ...
                'lValidateByConfigRange', true, ...
                'cLabel', 'Rx Cal HS' ...
            );
        end
        
        function inituiRxWafer(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-rx-hs.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiRxWafer = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'dWidthDest', 70, ...
                'lShowStores', false, ...
                ... %'dWidthPadRange', 182 + 20, ...
                'cName', sprintf('%s-rx-wafer', this.cName), ...
                'config', uiConfig, ...
                'dWidthRange', this.dWidthRange, ...
                'lShowRange', this.lShowRange, ...
                'lValidateByConfigRange', true, ...
                'cLabel', 'Z Wafer' ...
            );
        end

        
        function init(this)
            this.msg('init()');
            this.inituiRxHeightSensor();
            this.inituiRxWafer();
            
        end
        
        
        
    end
    
    
end

