classdef Wafer < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 1900 %1295
        dHeight     = 850
        
    end
    
	properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDeltaTauPowerPmac
        uiCommCxroHeightSensor
        uiCommKeithley6482
        uiCommDataTranslationMeasurPoint
        uiCommMFDriftMonitor
        
                
        uiCoarseStage
        uiLsiCoarseStage
        uiFineStage
        uiHeightSensorZClosedLoop
        uiHeightSensorZClosedLoopCoarse
        uiAxes
        uiDiode
        uiPobCapSensors
        % uiHeightSensor
        uiWorkingMode
       
        
        commDeltaTauPowerPmac = []
        hardware % needed for MFDriftMonitor integration
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
            
            this.commDeltaTauPowerPmac = comm;
            
            if this.uiCommMFDriftMonitor.get()
                this.uiHeightSensorZClosedLoop.connectDeltaTauPowerPmacAndDriftMonitor(...
                    this.commDeltaTauPowerPmac, ...
                    this.hardware.getMFDriftMonitor() ...
                )
            
                this.uiHeightSensorZClosedLoopCoarse.connectDeltaTauPowerPmacAndDriftMonitor(...
                    this.commDeltaTauPowerPmac, ...
                    this.hardware.getMFDriftMonitor() ...
                )
            end
            
            this.uiLsiCoarseStage.connectDeltaTauPowerPmac(comm);
            this.uiCoarseStage.connectDeltaTauPowerPmac(comm);
            this.uiFineStage.connectDeltaTauPowerPmac(comm);
            this.uiWorkingMode.connectDeltaTauPowerPmac(comm);
            
        end
        
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.commDeltaTauPowerPmac = [];
            this.uiLsiCoarseStage.disconnectDeltaTauPowerPmac();
            this.uiCoarseStage.disconnectDeltaTauPowerPmac();
            this.uiFineStage.disconnectDeltaTauPowerPmac();
            this.uiWorkingMode.disconnectDeltaTauPowerPmac();
            this.uiHeightSensorZClosedLoop.disconnectDeltaTauPowerPmacAndDriftMonitor();
            this.uiHeightSensorZClosedLoopCoarse.disconnectDeltaTauPowerPmacAndDriftMonitor();
            
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
            
            %{
            this.uiCommCxroHeightSensor.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            %}
                        
            this.uiCommKeithley6482.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommMFDriftMonitor.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslationMeasurPoint.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            % this.hs.build(this.hFigure, dPad, dTop);
            
            dTop = 10;
            dLeft = 290;
            
            this.uiWorkingMode.build(this.hFigure, dLeft, dTop);
            
            dLeft = 10;
            dTop = 210;
                        
            this.uiCoarseStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiCoarseStage.dHeight + dPad;
            
            this.uiLsiCoarseStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiLsiCoarseStage.dHeight + dPad;
            
            this.uiFineStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiFineStage.dHeight + dPad;
            
            dTopHS = dTop;
            this.uiHeightSensorZClosedLoop.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiHeightSensorZClosedLoop.dHeight + dPad;
            
            this.uiHeightSensorZClosedLoopCoarse.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiHeightSensorZClosedLoopCoarse.dHeight + dPad;
            
            dTopDiode = dTop
            this.uiDiode.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiDiode.dHeight + dPad;
            
            dTop = dTopHS;
            dLeft = 680;
            this.uiPobCapSensors.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiPobCapSensors.dHeight + dPad;
            
            %{
            this.uiHeightSensor.build(this.hFigure, 375, dTopDiode);
            dTop = dTop + this.uiHeightSensor.dHeight + dPad;
            %}
            
            dLeft = 1050;
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
        
            this.uiHeightSensorZClosedLoop = bl12014.ui.HeightSensorZClosedLoop( ...
                'clock', this.clock, ...
                'lShowZWafer', false, ...
                'cName', 'ui-wafer' ...
            );
        
            this.uiHeightSensorZClosedLoopCoarse = bl12014.ui.HeightSensorZClosedLoopCoarse( ...
                'clock', this.clock, ...
                'lShowZWafer', false, ...
                'cName', 'ui-wafer' ...
            );
        
            this.uiDiode = bl12014.ui.WaferDiode(...
                'clock', this.clock ...
            );
            this.uiPobCapSensors = bl12014.ui.PobCapSensors(...
                'clock', this.clock ...
            );
        
            %{
            this.uiHeightSensor = bl12014.ui.HeightSensor( ...
                'clock', this.clock ...
            );
            %}
        
            % this.initUiCommCxroHeightSensor();
            this.initUiCommDeltaTauPowerPmac();
            this.initUiCommDataTranslationMeasurPoint();
            this.initUiCommKeithley6482();
            this.initUiCommMFDriftMonitor();
        
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
        
        function initUiCommMFDriftMonitor(this)
            
           ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
           this.uiCommMFDriftMonitor = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'cName', 'mf-drift-monitor-connect-wafer-ui-module', ...
                'cLabel', 'MFDrift Monitor',...
                'lUseFunctionCallbacks', true, ...
                'fhGet', @() ~isempty(this.hardware.commMFDriftMonitor),...
                'fhSet', @(lVal) mic.Utils.ternEval(lVal, ...
                                    @this.connectDriftMonitor, ...
                                    @this.disconnectDriftMontior...
                                ),...
                'fhIsInitialized', @()true,...
                'fhIsVirtual', @false ...% Never virtualize the connection to real hardware
                ); 
            
        end
        
        %{
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
        %}
        
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
        
        function connectDriftMonitor(this)
            
            if ~isempty(this.commDeltaTauPowerPmac)
                this.uiHeightSensorZClosedLoop.connectDeltaTauPowerPmacAndDriftMonitor(...
                    this.commDeltaTauPowerPmac, ...
                    this.hardware.getMFDriftMonitor() ...
                )
            
                this.uiHeightSensorZClosedLoopCoarse.connectDeltaTauPowerPmacAndDriftMonitor(...
                    this.commDeltaTauPowerPmac, ...
                    this.hardware.getMFDriftMonitor() ...
                )
            end
            
        end
        
        function disconnectDriftMontior(this)
            this.hardware.deleteMFDriftMonitor();
            this.uiHeightSensorZClosedLoop.disconnectDeltaTauPowerPmacAndDriftMonitor();
            this.uiHeightSensorZClosedLoopCoarse.disconnectDeltaTauPowerPmacAndDriftMonitor();
            %this.apiMFDriftMonitor = [];
        end
        
        
    end % private
    
    
end