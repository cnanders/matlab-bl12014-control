classdef TempSensors < mic.Base
        
    properties (Constant)
      
        dWidth      = 970
        dHeight     = 505
        
    end
    
	properties
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDeltaTauPowerPmac
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDataTranslationMeasurPoint
        
        uiPobTempSensors
        uiMod3TempSensors
        uiVisTempSensors
        
    end
    
    properties (SetAccess = private)
    
        cName = 'Temp Sensors'
    end
    
    properties (Access = private)
         
        % { mic.clock 1x1} passed in
        clock
        hFigure
        
    end
    
        
    events
                
    end
    

    
    methods
        
        
        function this = TempSensors(varargin)
            
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
            
            import bl12014.device.GetNumberFromDataTranslationMeasurPoint

                        
            deviceReticleCam1 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 1);
            deviceReticleCam2 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 2);
            deviceFiducialCam1 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 3);
            deviceFiducialCam2 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 4);
            deviceMod3Frame1 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 5);
            deviceMod3Frame2 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 6);
            deviceMod3Frame3 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 7);
            deviceMod3Frame4 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 8);
            deviceMod3Frame5 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 9);
            deviceMod3Frame6 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 10);
            
            this.uiMod3TempSensors.uiReticleCam1.setDevice(deviceReticleCam1);
            this.uiMod3TempSensors.uiReticleCam2.setDevice(deviceReticleCam2);
            this.uiMod3TempSensors.uiFiducialCam1.setDevice(deviceFiducialCam1);
            this.uiMod3TempSensors.uiFiducialCam2.setDevice(deviceFiducialCam2);
            this.uiMod3TempSensors.uiFrame1.setDevice(deviceMod3Frame1);
            this.uiMod3TempSensors.uiFrame2.setDevice(deviceMod3Frame2);
            this.uiMod3TempSensors.uiFrame3.setDevice(deviceMod3Frame3);
            this.uiMod3TempSensors.uiFrame4.setDevice(deviceMod3Frame4);
            this.uiMod3TempSensors.uiFrame5.setDevice(deviceMod3Frame5);
            this.uiMod3TempSensors.uiFrame6.setDevice(deviceMod3Frame6);
            
            this.uiMod3TempSensors.uiReticleCam1.turnOn();
            this.uiMod3TempSensors.uiReticleCam2.turnOn();
            this.uiMod3TempSensors.uiFiducialCam1.turnOn();
            this.uiMod3TempSensors.uiFiducialCam2.turnOn();
            this.uiMod3TempSensors.uiFrame1.turnOn();
            this.uiMod3TempSensors.uiFrame2.turnOn();
            this.uiMod3TempSensors.uiFrame3.turnOn();
            this.uiMod3TempSensors.uiFrame4.turnOn();
            this.uiMod3TempSensors.uiFrame5.turnOn();
            this.uiMod3TempSensors.uiFrame6.turnOn();
            
            devicePobFrame1 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 11);
            devicePobFrame2 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 12);
            devicePobFrame3 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 13);
            devicePobFrame4 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 14);
            devicePobFrame5 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 15);
            devicePobFrame6 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 16);
            devicePobFrame7 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 17);
            devicePobFrame8 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 18);
            devicePobFrame9 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 19);
            devicePobFrame10 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 20);
            devicePobFrame11 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 21);
            devicePobFrame12 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, 22);
            
            this.uiPobTempSensors.uiFrame1.setDevice(devicePobFrame1);
            this.uiPobTempSensors.uiFrame2.setDevice(devicePobFrame2);
            this.uiPobTempSensors.uiFrame3.setDevice(devicePobFrame3);
            this.uiPobTempSensors.uiFrame4.setDevice(devicePobFrame4);
            this.uiPobTempSensors.uiFrame5.setDevice(devicePobFrame5);
            this.uiPobTempSensors.uiFrame6.setDevice(devicePobFrame6);
            this.uiPobTempSensors.uiFrame7.setDevice(devicePobFrame7);
            this.uiPobTempSensors.uiFrame8.setDevice(devicePobFrame8);
            this.uiPobTempSensors.uiFrame9.setDevice(devicePobFrame9);
            this.uiPobTempSensors.uiFrame10.setDevice(devicePobFrame10);
            this.uiPobTempSensors.uiFrame11.setDevice(devicePobFrame11);
            this.uiPobTempSensors.uiFrame12.setDevice(devicePobFrame12);
            
            
            this.uiPobTempSensors.uiFrame1.turnOn();
            this.uiPobTempSensors.uiFrame2.turnOn();
            this.uiPobTempSensors.uiFrame3.turnOn();
            this.uiPobTempSensors.uiFrame4.turnOn();
            this.uiPobTempSensors.uiFrame5.turnOn();
            this.uiPobTempSensors.uiFrame6.turnOn();
            this.uiPobTempSensors.uiFrame7.turnOn();
            this.uiPobTempSensors.uiFrame8.turnOn();
            this.uiPobTempSensors.uiFrame9.turnOn();
            this.uiPobTempSensors.uiFrame10.turnOn();
            this.uiPobTempSensors.uiFrame11.turnOn();
            this.uiPobTempSensors.uiFrame12.turnOn();
        end
        
        
        function disconnectDataTranslationMeasurPoint(this)
            
            this.uiMod3TempSensors.uiReticleCam1.turnOff();
            this.uiMod3TempSensors.uiReticleCam2.turnOff();
            this.uiMod3TempSensors.uiFiducialCam1.turnOff();
            this.uiMod3TempSensors.uiFiducialCam2.turnOff();
            this.uiMod3TempSensors.uiFrame1.turnOff();
            this.uiMod3TempSensors.uiFrame2.turnOff();
            this.uiMod3TempSensors.uiFrame3.turnOff();
            this.uiMod3TempSensors.uiFrame4.turnOff();
            this.uiMod3TempSensors.uiFrame5.turnOff();
            this.uiMod3TempSensors.uiFrame6.turnOff();
            
            
            this.uiMod3TempSensors.uiReticleCam1.setDevice([]);
            this.uiMod3TempSensors.uiReticleCam2.setDevice([]);
            this.uiMod3TempSensors.uiFiducialCam1.setDevice([]);
            this.uiMod3TempSensors.uiFiducialCam2.setDevice([]);
            this.uiMod3TempSensors.uiFrame1.setDevice([]);
            this.uiMod3TempSensors.uiFrame2.setDevice([]);
            this.uiMod3TempSensors.uiFrame3.setDevice([]);
            this.uiMod3TempSensors.uiFrame4.setDevice([]);
            this.uiMod3TempSensors.uiFrame5.setDevice([]);
            this.uiMod3TempSensors.uiFrame6.setDevice([]);
            
            
            this.uiPobTempSensors.uiFrame1.turnOff();
            this.uiPobTempSensors.uiFrame2.turnOff();
            this.uiPobTempSensors.uiFrame3.turnOff();
            this.uiPobTempSensors.uiFrame4.turnOff();
            this.uiPobTempSensors.uiFrame5.turnOff();
            this.uiPobTempSensors.uiFrame6.turnOff();
            this.uiPobTempSensors.uiFrame7.turnOff();
            this.uiPobTempSensors.uiFrame8.turnOff();
            this.uiPobTempSensors.uiFrame9.turnOff();
            this.uiPobTempSensors.uiFrame10.turnOff();
            this.uiPobTempSensors.uiFrame11.turnOff();
            this.uiPobTempSensors.uiFrame12.turnOff();
            
            
            this.uiPobTempSensors.uiFrame1.setDevice([]);
            this.uiPobTempSensors.uiFrame2.setDevice([]);
            this.uiPobTempSensors.uiFrame3.setDevice([]);
            this.uiPobTempSensors.uiFrame4.setDevice([]);
            this.uiPobTempSensors.uiFrame5.setDevice([]);
            this.uiPobTempSensors.uiFrame6.setDevice([]);
            this.uiPobTempSensors.uiFrame7.setDevice([]);
            this.uiPobTempSensors.uiFrame8.setDevice([]);
            this.uiPobTempSensors.uiFrame9.setDevice([]);
            this.uiPobTempSensors.uiFrame10.setDevice([]);
            this.uiPobTempSensors.uiFrame11.setDevice([]);
            this.uiPobTempSensors.uiFrame12.setDevice([]);
            
            
            
            
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
                'Name', 'Temp Sensor Monitor', ...
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

            dTop = 10;
            dLeft = 10;
            dPad = 10;
            
            dSep = 30;
            
            this.uiCommDeltaTauPowerPmac.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslationMeasurPoint.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            % this.mod3cap.build(this.hFigure, dPad, dTop);
            
            this.uiPobTempSensors.build(this.hFigure, dLeft, dTop);
            % dTop = dTop + this.uiPobTempSensors.dHeight + dPad;
            dLeft = dLeft + this.uiPobTempSensors.dWidth + dPad;
            
            this.uiMod3TempSensors.build(this.hFigure, dLeft, dTop);
            % dTop = dTop + this.uiMod3TempSensors.dHeight + dPad;
            dLeft = dLeft + this.uiMod3TempSensors.dWidth + dPad;
            
           %  this.uiVisTempSensors.build(this.hFigure, dLeft, dTop);
                     
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end
        
       
        
        
            

    end
    
    methods (Access = private)
 
        
        function init(this)
            
            this.msg('init()');
            
            this.uiPobTempSensors = bl12014.ui.PobTempSensors(...
                'clock', this.clock ...
            );
                       
            this.uiMod3TempSensors = bl12014.ui.Mod3TempSensors(...
                'clock', this.clock ...
            );
        
            %{
            this.uiVisTempSensors = bl12014.ui.VibrationIsolationSystemTempSensors(...
                'clock', this.clock ...
            );
            %}
        
            this.initUiCommDataTranslationMeasurPoint();
            this.initUiCommDeltaTauPowerPmac();
        
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
                'cName', 'data-translation-measur-point-temp-sensors', ...
                'cLabel', 'Data Trans MeasurPoint' ...
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
                'cName', 'delta-tau-power-pmac-temp-sensors', ...
                'cLabel', 'DeltaTau Power PMAC' ...
            );
        
        end
        
        
        function onCloseRequest(this, src, evt)
            this.msg('TempSensorsControl.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
            % this.saveState();
        end
        

    end % private
    
    
end