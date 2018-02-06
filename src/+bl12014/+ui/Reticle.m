classdef Reticle < mic.Base
        
    properties (Constant)
      
        dWidth      = 1515
        dHeight     = 775
        
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
        uiFineStage
        uiAxes
        uiDiode
        uiMod3CapSensors
        uiWorkingMode
    end
    
    properties (SetAccess = private)
    
        cName = 'Reticle'
    end
    
    properties (Access = private)
                      
        clock
        hFigure
        dDelay = 0.5
        
    end
    
        
    events
                
    end
    

    
    methods
        
        
        function this = Reticle(varargin)
            
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
            return
            
            deviceCap1 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, 5);
            deviceCap2 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, 6);
            deviceCap3 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, 7);
            deviceCap4 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, 8);
            
            this.uiMod3CapSensors.uiCap1.setDevice(deviceCap1);
            this.uiMod3CapSensors.uiCap2.setDevice(deviceCap2);
            this.uiMod3CapSensors.uiCap3.setDevice(deviceCap3);
            this.uiMod3CapSensors.uiCap4.setDevice(deviceCap4);
            
            this.uiMod3CapSensors.uiCap1.turnOn();
            this.uiMod3CapSensors.uiCap2.turnOn();
            this.uiMod3CapSensors.uiCap3.turnOn();
            this.uiMod3CapSensors.uiCap4.turnOn();
        end
        
        function disconnectDataTranslationMeasurPoint(this)
            
            return
            this.uiMod3CapSensors.uiCap1.turnOff();
            this.uiMod3CapSensors.uiCap2.turnOff();
            this.uiMod3CapSensors.uiCap3.turnOff();
            this.uiMod3CapSensors.uiCap4.turnOff();
            
            this.uiMod3CapSensors.uiCap1.setDevice([]);
            this.uiMod3CapSensors.uiCap2.setDevice([]);
            this.uiMod3CapSensors.uiCap3.setDevice([]);
            this.uiMod3CapSensors.uiCap4.setDevice([]);
        end
        
        
        
        function connectKeithley6482(this, comm)
            deviceCh1 = bl12014.device.GetNumberFromKeithley6482(comm, 1);
            this.uiDiode.uiCurrent.setDevice(deviceCh1);
            this.uiDiode.uiCurrent.turnOn();
        end
        
        function disconnectKeithley6482(this)
            this.uiDiode.uiCurrent.turnOff()
            this.uiDiode.uiCurrent.setDevice([]);
        end
        
        
        function connectDeltaTauPowerPmac(this, comm)
            
            import bl12014.device.GetSetNumberFromDeltaTauPowerPmac
            import bl12014.device.GetSetTextFromDeltaTauPowerPmac
            
            % Devices
            deviceWorkingMode = GetSetTextFromDeltaTauPowerPmac(comm, GetSetTextFromDeltaTauPowerPmac.cTYPE_WORKING_MODE);
            deviceCoarseX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_X);
            deviceCoarseY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_Y);
            deviceCoarseZ = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_Z);
            deviceCoarseTiltX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_TIP);
            deviceCoarseTiltY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_TILT);
            deviceFineX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_FINE_X);
            deviceFineY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_FINE_Y);
            
             % Set Devices 
            this.uiWorkingMode.ui.setDevice(deviceWorkingMode);
            this.uiCoarseStage.uiX.setDevice(deviceCoarseX);
            this.uiCoarseStage.uiY.setDevice(deviceCoarseY);
            this.uiCoarseStage.uiZ.setDevice(deviceCoarseZ);
            this.uiCoarseStage.uiTiltX.setDevice(deviceCoarseTiltX);
            this.uiCoarseStage.uiTiltY.setDevice(deviceCoarseTiltY);
            this.uiFineStage.uiX.setDevice(deviceFineX);
            this.uiFineStage.uiY.setDevice(deviceFineY);
            
            % Turn on
            this.uiWorkingMode.ui.turnOn();
            this.uiCoarseStage.uiX.turnOn();
            this.uiCoarseStage.uiY.turnOn();
            this.uiCoarseStage.uiZ.turnOn();
            this.uiCoarseStage.uiTiltX.turnOn();
            this.uiCoarseStage.uiTiltY.turnOn();
            this.uiFineStage.uiX.turnOn();
            this.uiFineStage.uiY.turnOn();
            
        end
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.uiWorkingMode.ui.turnOff();
            this.uiCoarseStage.uiX.turnOff();
            this.uiCoarseStage.uiY.turnOff();
            this.uiCoarseStage.uiZ.turnOff();
            this.uiCoarseStage.uiTiltX.turnOff();
            this.uiCoarseStage.uiTiltY.turnOff();
            this.uiFineStage.uiX.turnOff();
            this.uiFineStage.uiY.turnOff();
            
            this.uiWorkingMode.ui.setDevice([]);
            this.uiCoarseStage.uiX.setDevice([]);
            this.uiCoarseStage.uiY.setDevice([]);
            this.uiCoarseStage.uiZ.setDevice([]);
            this.uiCoarseStage.uiTiltX.setDevice([]);
            this.uiCoarseStage.uiTiltY.setDevice([]);
            this.uiFineStage.uiX.setDevice([]);
            this.uiFineStage.uiY.setDevice([]);
            
           
            
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
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'Reticle Control', ...
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
            
            % There is a bug in the default 'painters' renderer when
            % drawing stacked patches.  This is required to make ordering
            % work as expected
            
            set(this.hFigure, 'renderer', 'OpenGL');
            
            drawnow;

            dTop = 10;
            dPad = 10;
            dLeft = 10;
            dSep = 30;
            
            
            this.uiCommDeltaTauPowerPmac.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommKeithley6482.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslationMeasurPoint.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            % this.mod3cap.build(this.hFigure, dPad, dTop);
            
            this.uiWorkingMode.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiWorkingMode.dHeight + dPad;
            
            this.uiCoarseStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiCoarseStage.dHeight + dPad;
            
            this.uiFineStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiFineStage.dHeight + dPad;
            
            this.uiDiode.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiDiode.dHeight + dPad;
            
            this.uiMod3CapSensors.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiMod3CapSensors.dHeight + dPad;
            
            dLeft = 750;
            dTop = 10;
            this.uiAxes.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiAxes.dHeight + dPad;
                        
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
            
            % Clean up clock tasks
            
            if (isvalid(this.clock))
                this.clock.remove(this.id());
            end
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end
        
       
        
        
            

    end
    
    methods (Access = private)
        
        
        
        function onClock(this)
            
            % Make sure the hggroup of the carriage is at the correct
            % location.  
            
            
            dX = this.uiCoarseStage.uiX.getValCal('mm') / 1000;
            dY = this.uiCoarseStage.uiY.getValCal('mm') / 1000;
            this.uiAxes.setStagePosition(dX, -dY); % Flip y so screen corresponds to plan view
                        
        end
        
        
        function init(this)
            
            this.msg('init()');
            
            this.uiWorkingMode = bl12014.ui.PowerPmacWorkingMode(...
                'cName', 'reticle-pmac-working-mode', ...
                'clock', this.clock ...
            );
            this.uiCoarseStage = bl12014.ui.ReticleCoarseStage(...
                'clock', this.clock ...
            );
                       
            this.uiFineStage = bl12014.ui.ReticleFineStage(...
                'clock', this.clock ...
            );
        
            this.uiDiode = bl12014.ui.ReticleDiode(...
                'clock', this.clock ...
            );
                
            dHeight = this.dHeight - 20;
            this.uiAxes = bl12014.ui.ReticleAxes(...
                'dWidth', dHeight, ...
                'dHeight', dHeight ...
            );
        
            this.uiMod3CapSensors = bl12014.ui.Mod3CapSensors(...
                'clock', this.clock ...
            );
        
            this.initUiCommDataTranslationMeasurPoint();
            this.initUiCommDeltaTauPowerPmac();
            this.initUiCommKeithley6482();
        
            addlistener(this.uiAxes, 'eClickField', @this.onUiAxesClickField);
            this.clock.add(@this.onClock, this.id(), this.dDelay);

        end
        
        
        function onCloseRequest(this, src, evt)
            this.msg('ReticleControl.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
            % this.saveState();
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
                'cName', 'data-translation-measur-point-reticle', ...
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
                'cName', 'delta-tau-power-pmac-reticle', ...
                'cLabel', 'DeltaTau Power PMAC' ...
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
                'cName', 'keithley-6482-reticle', ...
                'cLabel', 'Keithley 6482' ...
            );
        
        end
        
       
        
        function onUiAxesClickField(this, src, evt)
                       
            this.uiCoarseStage.uiX.setDestCalDisplay(-evt.stData.dX);
            this.uiCoarseStage.uiY.setDestCalDisplay(-evt.stData.dY);
            this.uiCoarseStage.uiX.moveToDest();
            this.uiCoarseStage.uiY.moveToDest();            
            
        end
        

    end % private
    
    
end