classdef Wafer < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 1600 %1295
        dHeight     = 845
        
    end
    
	properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDeltaTauPowerPmac
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommCxroHeightSensor
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommKeithley6482
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDataTranslationMeasurPoint
        
                
        uiCoarseStage
        uiLsiCoarseStage
        uiFineStage
        uiAxes
        uiDiode
        uiPobCapSensors
        uiHeightSensor
        uiWorkingMode
       
    end
    
    properties (SetAccess = private)
        
        hFigure
        
    end
    
    properties (Access = private)
                      
        clock
        dDelay = 0.15
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = Wafer(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            this.init();
            
            
        end
        
        
        function connectDataTranslationMeasurPoint(this, comm)
            deviceCap1 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, 9);
            deviceCap2 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, 10);
            deviceCap3 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, 11);
            deviceCap4 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, 12);
        
            this.uiPobCapSensors.uiCap1.setDevice(deviceCap1);
            this.uiPobCapSensors.uiCap2.setDevice(deviceCap2);
            this.uiPobCapSensors.uiCap3.setDevice(deviceCap3);
            this.uiPobCapSensors.uiCap4.setDevice(deviceCap4);
            
            this.uiPobCapSensors.uiCap1.turnOn();
            this.uiPobCapSensors.uiCap2.turnOn();
            this.uiPobCapSensors.uiCap3.turnOn();
            this.uiPobCapSensors.uiCap4.turnOn();
        end
        
        function disconnectDataTranslationMeasurPoint(this)

            this.uiPobCapSensors.uiCap1.turnOff();
            this.uiPobCapSensors.uiCap2.turnOff();
            this.uiPobCapSensors.uiCap3.turnOff();
            this.uiPobCapSensors.uiCap4.turnOff();
            
            this.uiPobCapSensors.uiCap1.setDevice([]);
            this.uiPobCapSensors.uiCap2.setDevice([]);
            this.uiPobCapSensors.uiCap3.setDevice([]);
            this.uiPobCapSensors.uiCap4.setDevice([]);
                
        end
        
        
        
        function connectKeithley6482(this, comm)
           % Wafer
            deviceCh1 = bl12014.device.GetNumberFromKeithley6482(comm, 2);
            this.uiDiode.uiCurrent.setDevice(deviceCh1);
            this.uiDiode.uiCurrent.turnOn();
                        
            % Wafer Focus Sensor
            %{
            deviceCh2 = bl12014.device.GetNumberFromKeithley6482(comm, 2);
            this.uiApp.uiWaferFocusSensor.uiCurrent.setDevice(deviceCh2);
            this.uiApp.uiWaferFocusSensor.uiCurrent.turnOn();
            %} 
            
        end
        
        function disconnectKeithely6482(this)
            this.uiDiode.uiCurrent.turnOff()
            this.uiDiode.uiCurrent.setDevice([]);
            
            %{
            this.uiApp.uiWaferFocusSensor.uiDiode.turnOff()
            this.uiApp.uiWaferFocusSensor.ui.uiDiode.setDevice([]);
            %} 
            
        end
        
        function connectDeltaTauPowerPmac(this, comm)
            
            import bl12014.device.GetSetNumberFromDeltaTauPowerPmac
            import bl12014.device.GetSetTextFromDeltaTauPowerPmac
            
            % Devices
            deviceWorkingMode = GetSetTextFromDeltaTauPowerPmac(comm, GetSetTextFromDeltaTauPowerPmac.cTYPE_WORKING_MODE);
            deviceCoarseX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_X);
            deviceCoarseY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_Y);
            deviceCoarseZ = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_Z);
            deviceCoarseTiltX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TIP);
            deviceCoarseTiltY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TILT);
            deviceFineZ = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_FINE_Z);
            deviceCoarseXLsi = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_LSI_COARSE_X);
            
            % Set Devices
            this.uiWorkingMode.ui.setDevice(deviceWorkingMode);
            this.uiCoarseStage.uiX.setDevice(deviceCoarseX);
            this.uiCoarseStage.uiY.setDevice(deviceCoarseY);
            this.uiCoarseStage.uiZ.setDevice(deviceCoarseZ);
            this.uiCoarseStage.uiTiltX.setDevice(deviceCoarseTiltX);
            this.uiCoarseStage.uiTiltY.setDevice(deviceCoarseTiltY);
            this.uiFineStage.uiZ.setDevice(deviceFineZ);
            this.uiLsiCoarseStage.uiX.setDevice(deviceCoarseXLsi);
            
            % Turn on
            this.uiWorkingMode.ui.turnOn();
            this.uiCoarseStage.uiX.turnOn();
            this.uiCoarseStage.uiY.turnOn();
            this.uiCoarseStage.uiZ.turnOn();
            this.uiCoarseStage.uiTiltX.turnOn();
            this.uiCoarseStage.uiTiltY.turnOn();
            this.uiLsiCoarseStage.uiX.turnOn();
            this.uiFineStage.uiZ.turnOn();
            
            
            %this.uiWorkingMode.ui.syncDestination();
            this.uiCoarseStage.uiX.syncDestination();
            this.uiCoarseStage.uiY.syncDestination();
            this.uiCoarseStage.uiZ.syncDestination();
            this.uiCoarseStage.uiTiltX.syncDestination();
            this.uiCoarseStage.uiTiltY.syncDestination();
            this.uiLsiCoarseStage.uiX.syncDestination();
            this.uiFineStage.uiZ.syncDestination();
            
        end
        
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.uiWorkingMode.ui.turnOff();
            this.uiCoarseStage.uiX.turnOff();
            this.uiCoarseStage.uiY.turnOff();
            this.uiCoarseStage.uiZ.turnOff();
            this.uiCoarseStage.uiTiltX.turnOff();
            this.uiCoarseStage.uiTiltY.turnOff();
            this.uiLsiCoarseStage.uiX.turnOff();
            this.uiFineStage.uiZ.turnOff();
                        
            this.uiWorkingMode.ui.setDevice([]);
            this.uiCoarseStage.uiX.setDevice([]);
            this.uiCoarseStage.uiY.setDevice([]);
            this.uiCoarseStage.uiZ.setDevice([]);
            this.uiCoarseStage.uiTiltX.setDevice([]);
            this.uiCoarseStage.uiTiltY.setDevice([]);
            this.uiLsiCoarseStage.uiX.setDevice([]);
            this.uiFineStage.uiZ.setDevice([]);
            
        end
        
        
        
        
        function build(this)
                        
            % Figure
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name', 'Wafer Control',...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onCloseRequestFcn ...
                );
            
            % There is a bug in the default 'painters' renderer when
            % drawing stacked patches.  This is required to make ordering
            % work as expected
            
            % set(this.hFigure, 'renderer', 'OpenGL');
            
            drawnow;

            dTop = 10;
            dPad = 10;
            dLeft = 10;
            dSep = 30;

            this.uiCommDeltaTauPowerPmac.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommCxroHeightSensor.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
                        
            this.uiCommKeithley6482.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslationMeasurPoint.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            % this.hs.build(this.hFigure, dPad, dTop);
            
            this.uiWorkingMode.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiWorkingMode.dHeight + dPad;
            
            this.uiCoarseStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiCoarseStage.dHeight + dPad;
            
            
            
            this.uiFineStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiFineStage.dHeight + dPad;
            
            this.uiLsiCoarseStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiLsiCoarseStage.dHeight + dPad;
            
            dTopDiode = dTop
            this.uiDiode.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiDiode.dHeight + dPad;
            
            this.uiPobCapSensors.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiPobCapSensors.dHeight + dPad;
            
            
            this.uiHeightSensor.build(this.hFigure, 375, dTopDiode);
            dTop = dTop + this.uiHeightSensor.dHeight + dPad;
            
            dLeft = 750;
            dTop = 10;
            this.uiAxes.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiAxes.dHeight + dPad;
           
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
            
            if (isvalid(this.clock))
                this.clock.remove(this.id());
            end
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
        end
        
        function st = save(this)
            st = struct();
            st.uiCoarseStage = this.uiCoarseStage.save();
            st.uiFineStage = this.uiFineStage.save();
            st.uiLsiCoarseStage = this.uiLsiCoarseStage.save();
        end
        
        function load(this, st)
            if isfield(st, 'uiCoarseStage')
                this.uiCoarseStage.load(st.uiCoarseStage)
            end
            
            if isfield(st, 'uiLsiCoarseStage')
                this.uiLsiCoarseStage.load(st.uiLsiCoarseStage)
            end
            
            if isfield(st, 'uiFineStage')
                this.uiFineStage.load(st.uiFineStage)
            end
        end
               
        
        function onClock(this)
            
            % Make sure the hggroup of the carriage is at the correct
            % location.  
            
            dX = this.uiCoarseStage.uiX.getValCal('mm') / 1000;
            dY = this.uiCoarseStage.uiY.getValCal('mm') / 1000;
            this.uiAxes.setStagePosition(dX, dY);
            
            
            dXLsi = this.uiLsiCoarseStage.uiX.getValCal('mm') / 1000;
            this.uiAxes.setXLsi(dXLsi);
                        
        end
        
    end
    
    methods (Access = private)
        
        function init(this)
            
            this.msg('init()');
            
            this.uiWorkingMode = bl12014.ui.PowerPmacWorkingMode(...
                'cName', 'wafer-pmac-working-mode', ...
                'clock', this.clock ...
            );
        
            this.uiCoarseStage = bl12014.ui.WaferCoarseStage(...
                'clock', this.clock ...
            );
        
            this.uiLsiCoarseStage = bl12014.ui.LsiCoarseStage(...
                'clock', this.clock ...
            );
            this.uiFineStage = bl12014.ui.WaferFineStage(...
                'clock', this.clock ...
            );
        
            this.uiDiode = bl12014.ui.WaferDiode(...
                'clock', this.clock ...
            );
            this.uiPobCapSensors = bl12014.ui.PobCapSensors(...
                'clock', this.clock ...
            );
            this.uiHeightSensor = bl12014.ui.HeightSensor( ...
                'clock', this.clock ...
            );
        
            this.initUiCommCxroHeightSensor();
            this.initUiCommDeltaTauPowerPmac();
            this.initUiCommDataTranslationMeasurPoint();
            this.initUiCommKeithley6482();
        
            dHeight = this.dHeight - 20;
            this.uiAxes = bl12014.ui.WaferAxes( ...
                'dWidth', dHeight, ...
                'dHeight', dHeight ...
            );
            
                        
            % this.hs     = HeightSensor(this.clock);
            this.clock.add(@this.onClock, this.id(), this.dDelay);

        end
        
        function initUiCommDataTranslationMeasurPoint(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommDataTranslationMeasurPoint = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'data-translation-measur-point-wafer', ...
                'cLabel', 'DataTrans MeasurPoint' ...
            );
        
        end
        
        function initUiCommDeltaTauPowerPmac(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommDeltaTauPowerPmac = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'delta-tau-power-pmac-wafer', ...
                'cLabel', 'DeltaTau Power PMAC' ...
            );
        
        end
        
        function initUiCommCxroHeightSensor(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommCxroHeightSensor = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'cxro-height-sensor', ...
                'cLabel', 'CXRO Height Sensor' ...
            );
        
        end
        
        function initUiCommKeithley6482(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommKeithley6482 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'keithley-6482-wafer', ...
                'cLabel', 'Keithley 6482 (Wafer)' ...
            );
        
        end
        
        
        function onCloseRequestFcn(this, src, evt)
            
            delete(this.hFigure);
            this.hFigure = [];
            % this.saveState();
            
        end
        
        
    end % private
    
    
end