classdef HeightSensorRyClosedLoop < mic.Base
    
    properties
            
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiRyHeightSensor
        
        % {mic.ui.device.GetNumber 1x1}}
        uiRyWafer
                
    end
    
    
    properties (SetAccess = private)
        
        dWidthRange = 120
        dWidth = 690
        dHeight = 100
        
        cName = 'ui-height-sensor-closed-loop-ry'
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
        
        function this = HeightSensorRyClosedLoop(varargin)
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
            
            this.uiRyWafer.turnOff();
            this.uiRyWafer.setDevice([]);
            
            this.uiRyHeightSensor.turnOff();
            this.uiRyHeightSensor.setDevice([]);
            
        end
        
        function connectDeltaTauPowerPmacAndDriftMonitor(this, commDeltaTauPowerPmac, commDriftMonitor)
            
            import bl12014.device.GetSetNumberFromDeltaTauPowerPmac
            import bl12014.device.GetSetTextFromDeltaTauPowerPmac
            import bl12014.device.GetNumberFromCalHeightSensor
            
            deviceRyWafer = GetSetNumberFromDeltaTauPowerPmac(...
                commDeltaTauPowerPmac, ...
                GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TILT ...
            );
        
            deviceRyHeightSensor = GetNumberFromCalHeightSensor(commDriftMonitor, 2); % 1 = rx, 2 = ry, 3 = z

            deviceRyHeightSensorControl = bl12014.device.HeightSensorCalClosedLoop(...
                this.clock, ...
                deviceRyWafer, ...
                deviceRyHeightSensor, ...
                this.uiParentStageUI, ...
                'u8MovesMax', uint8(5) ...
            );
        
        
            this.uiRyWafer.setDevice(deviceRyWafer);
            this.uiRyWafer.turnOn();
            this.uiRyWafer.syncDestination();
            
            this.uiRyHeightSensor.setDevice(deviceRyHeightSensorControl);
            this.uiRyHeightSensor.turnOn();
            this.uiRyHeightSensor.syncDestination();
            
            
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
            
            this.uiRyHeightSensor.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            if this.lShowZWafer
                this.uiRyWafer.build(this.hPanel, dLeft, dTop);
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
            st.uiRyHeightSensor = this.uiRyHeightSensor.save();
            st.uiRyWafer = this.uiRyWafer.save();

        end
        
        function load(this, st)
            if isfield(st, 'uiRyHeightSensor')
                this.uiRyHeightSensor.load(st.uiRyHeightSensor)
            end
            
            if isfield(st, 'uiRyWafer')
                this.uiRyWafer.load(st.uiRyWafer)
            end
            
            
        end
        
        
    end
    
    methods (Access = private)
        
        
        
         
        function inituiRyHeightSensor(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-ry-hs-cl.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiRyHeightSensor = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthDest', 70, ...
                'lShowStores', false, ...
                'cName', sprintf('%s-ry-height-sensor-closed-loop', this.cName), ...
                'config', uiConfig, ...
                'dWidthRange', this.dWidthRange, ...
                'lShowRange', this.lShowRange, ...
                'lValidateByConfigRange', true, ...
                'cLabel', 'Ry Cal HS' ...
            );
        end
        
        function inituiRyWafer(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-ry-hs.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiRyWafer = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'dWidthDest', 70, ...
                'lShowStores', false, ...
                ... %'dWidthPadRange', 182 + 20, ...
                'cName', sprintf('%s-ry-wafer', this.cName), ...
                'config', uiConfig, ...
                'dWidthRange', this.dWidthRange, ...
                'lShowRange', this.lShowRange, ...
                'lValidateByConfigRange', true, ...
                'cLabel', 'Z Wafer' ...
            );
        end

        
        
        function init(this)
            this.msg('init()');
            this.inituiRyHeightSensor();
            this.inituiRyWafer();
            
        end
        
        
        
    end
    
    
end

