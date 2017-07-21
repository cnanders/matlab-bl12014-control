classdef Connect
    
    % Helper functions to connect hardware com instances "comm" to UI.
    % This will build all devices < mic.interface.device.* and pass them 
    % to the UI with setDevice()
    
    
    properties
    end
    
    methods (Static)
        
        %{
        function connectCommWagoToUiD141(comm, ui)
            device = bl12014.device.GetSetLogicalFromWago(comm, 1);
            ui.uiStageY.setDevice(device);            
        end
        %}
        
        
        function connectCommSmarActMcsM141ToUiM141(comm, ui)
            % {< mic.interface.device.GetSetNumber}
            deviceX = bl12014.device.GetSetNumberFromStage(comm, 1);

            % {< mic.interface.device.GetSetNumber}
            deviceTiltX = bl12014.device.GetSetNumberFromStage(comm, 2);

            % {< mic.interface.device.GetSetNumber}
            deviceTiltY = bl12014.device.GetSetNumberFromStage(comm, 3);
            
            ui.uiStageX.setDevice(deviceX);
            ui.uiStageTiltX.setDevice(deviceTiltX);
            ui.uiStageTiltY.setDevice(deviceTiltY);
            
        end
        
        function disconnectCommSmarActMcsM141ToUiM141(ui)
            
            ui.uiStageX.setDevice([]);
            ui.uiStageTiltX.setDevice([]);
            ui.uiStageTiltY.setDevice([]);
            
        end
        
        function connectCommSmarActMcsGoniToUiInterferometry(comm, ui)
            
        end
        
        function disconnectCommSmarActMcsGoniToUiInterferometry(comm, ui)
            
        end
        
        function connectCommSmarActSmarPodToUiInterferometry(comm, ui)
            
        end
        
        function disconnectCommSmarActSmarPodToUiInterferometry(comm, ui)
            
        end
    
        function connectCommDataTranslationMeasurPointToUiM141(comm, ui)
            
            u8Channel = 1;
            % {< mic.interface.device.GetNumber}
            device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, u8Channel);
            ui.uiMeasurPointVolts.setDevice(device);
        end
        
        function disconnectCommDataTranslationMeasurPointToUiM141(ui)
            
            ui.uiMeasurPointVolts.setDevice([]);
        end
        
        %{
        function connectCommDataTranslationMeasurPointToUiD141(comm, ui)
            
        end
        %}
        
        function connectCommDataTranslationMeasurPointToUiD142(comm, ui)
            
            u8Channel = 2;
            
            % {< mic.interface.device.GetNumber}
            device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, u8Channel);
            
            ui.uiMeasurPointVolts.setDevice(device);
        end
        
        function disconnectCommDataTranslationMeasurPointToUiD142(ui)
            
            ui.uiMeasurPointVolts.setDevice([]);
        end
        
        
        function connectCommGalilToUiM143(comm, ui)
            
            u8Channel = 3;
            
            % {< mic.interface.device.GetNumber}
            device = bl12014.device.GetSetNumberFromGalil(comm, u8Channel);
            ui.uiStageY.setDevice(device);
            
        end
        
        function disconnectCommGalilToUiM143(ui)
            ui.uiStageY.setDevice([]);
        end
        
        function connectCommGalilToUiD142(comm, ui)
            
            u8Channel = 2;
            
            % {< mic.interface.device.GetNumber}
            device = bl12014.device.GetSetNumberFromGalil(comm, u8Channel);
            ui.uiStageY.setDevice(device);
            
        end
        
        function disconnectCommGalilToUiD142(ui)
            ui.uiStageY.setDevice([]);
        end
        
        function connectCommDataTranslationMeasurPointToUiM143(comm, ui)
            
            u8Channel = 3;
            % {< mic.interface.device.GetNumber}
            device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, u8Channel);
            
            ui.uiMeasurPointVolts.setDevice(device);
            
        end
        
        function disconnectCommDataTranslationMeasurPointToUiM143(ui)
            
            ui.uiMeasurPointVolts.setDevice([]);
            
        end
        
        function connectCommDataTranslationMeasurPointToUiVis(comm, ui)
            
        end
        
        function disconnectCommDataTranslationMeasurPointToUiVis(ui)
            
        end
        
        function connectCommDataTranslationMeasurPointToUiTempSensors(comm, ui)
            
            % {< mic.interface.device.GetNumber}
            deviceReticleCam1 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 1);
            deviceReticleCam2 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 1);
            deviceFiducialCam1 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 1);
            deviceFiducialCam2 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 1);
            deviceMod3Frame1 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 1);
            deviceMod3Frame2 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 1);
            deviceMod3Frame3 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 1);
            deviceMod3Frame4 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 1);
            deviceMod3Frame5 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 1);
            deviceMod3Frame6 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 1);
            
            ui.uiMod3TempSensors.uiReticleCam1.setDevice(deviceReticleCam1);
            ui.uiMod3TempSensors.uiReticleCam2.setDevice(deviceReticleCam2);
            ui.uiMod3TempSensors.uiFiducialCam1.setDevice(deviceFiducialCam1);
            ui.uiMod3TempSensors.uiFiducialCam2.setDevice(deviceFiducialCam2);
            ui.uiMod3TempSensors.uiFrame1.setDevice(deviceMod3Frame1);
            ui.uiMod3TempSensors.uiFrame2.setDevice(deviceMod3Frame2);
            ui.uiMod3TempSensors.uiFrame3.setDevice(deviceMod3Frame3);
            ui.uiMod3TempSensors.uiFrame4.setDevice(deviceMod3Frame4);
            ui.uiMod3TempSensors.uiFrame5.setDevice(deviceMod3Frame5);
            ui.uiMod3TempSensors.uiFrame6.setDevice(deviceMod3Frame6);
            
            devicePobFrame1 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 11);
            devicePobFrame2 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 12);
            devicePobFrame3 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 13);
            devicePobFrame4 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 14);
            devicePobFrame5 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 15);
            devicePobFrame6 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 16);
            devicePobFrame7 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 17);
            devicePobFrame8 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 18);
            devicePobFrame9 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 19);
            devicePobFrame10 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 20);
            devicePobFrame11 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 21);
            devicePobFrame12 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 22);
            
            ui.uiPobTempSensors.uiFrame1.setDevice(devicePobFrame1);
            ui.uiPobTempSensors.uiFrame2.setDevice(devicePobFrame2);
            ui.uiPobTempSensors.uiFrame3.setDevice(devicePobFrame3);
            ui.uiPobTempSensors.uiFrame4.setDevice(devicePobFrame4);
            ui.uiPobTempSensors.uiFrame5.setDevice(devicePobFrame5);
            ui.uiPobTempSensors.uiFrame6.setDevice(devicePobFrame6);
            ui.uiPobTempSensors.uiFrame7.setDevice(devicePobFrame7);
            ui.uiPobTempSensors.uiFrame8.setDevice(devicePobFrame8);
            ui.uiPobTempSensors.uiFrame9.setDevice(devicePobFrame9);
            ui.uiPobTempSensors.uiFrame10.setDevice(devicePobFrame10);
            ui.uiPobTempSensors.uiFrame11.setDevice(devicePobFrame11);
            ui.uiPobTempSensors.uiFrame12.setDevice(devicePobFrame12);
            
        end
        
        function disconnectCommDataTranslationMeasurPointToUiTempSensors(ui)
            
            ui.uiMod3TempSensors.uiReticleCam1.setDevice([]);
            ui.uiMod3TempSensors.uiReticleCam2.setDevice([]);
            ui.uiMod3TempSensors.uiFiducialCam1.setDevice([]);
            ui.uiMod3TempSensors.uiFiducialCam2.setDevice([]);
            ui.uiMod3TempSensors.uiFrame1.setDevice([]);
            ui.uiMod3TempSensors.uiFrame2.setDevice([]);
            ui.uiMod3TempSensors.uiFrame3.setDevice([]);
            ui.uiMod3TempSensors.uiFrame4.setDevice([]);
            ui.uiMod3TempSensors.uiFrame5.setDevice([]);
            ui.uiMod3TempSensors.uiFrame6.setDevice([]);
            
            
            ui.uiPobTempSensors.uiFrame1.setDevice([]);
            ui.uiPobTempSensors.uiFrame2.setDevice([]);
            ui.uiPobTempSensors.uiFrame3.setDevice([]);
            ui.uiPobTempSensors.uiFrame4.setDevice([]);
            ui.uiPobTempSensors.uiFrame5.setDevice([]);
            ui.uiPobTempSensors.uiFrame6.setDevice([]);
            ui.uiPobTempSensors.uiFrame7.setDevice([]);
            ui.uiPobTempSensors.uiFrame8.setDevice([]);
            ui.uiPobTempSensors.uiFrame9.setDevice([]);
            ui.uiPobTempSensors.uiFrame10.setDevice([]);
            ui.uiPobTempSensors.uiFrame11.setDevice([]);
            ui.uiPobTempSensors.uiFrame12.setDevice([]);
            
        end
        
        function connectCommDataTranslationMeasurPointToUiMetrologyFrame(comm, ui)
        end
        
        function disconnectCommDataTranslationMeasurPointToUiMetrologyFrame(ui)
        end
        
        function connectCommDataTranslationMeasurPointToUiReticle(comm, ui)
            % Mod3 cap sensors are in Reticle UI
            
            % {< mic.interface.device.GetNumber}
            deviceCap1 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 21);
            deviceCap2 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 22);
            deviceCap3 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 23);
            deviceCap4 = bl12014.device.GetNumberFromDataTranslationMeasurPoint(comm, 24);

                
            ui.uiMod3CapSensors.uiCap1.setDevice(deviceCap1);
            ui.uiMod3CapSensors.uiCap2.setDevice(deviceCap2);
            ui.uiMod3CapSensors.uiCap3.setDevice(deviceCap3);
            ui.uiMod3CapSensors.uiCap4.setDevice(deviceCap4);
            
        end
        
        
        
        function disconnectCommDataTranslationMeasurPointToUiWafer(ui)
            % POB cap sensors are in Wafer UI
             
            ui.uiPobCapSensors.uiCap1.setDevice([]);
            ui.uiPobCapSensors.uiCap2.setDevice([]);
            ui.uiPobCapSensors.uiCap3.setDevice([]);
            ui.uiPobCapSensors.uiCap4.setDevice([]);
            
        end
        
        %{
        function connectCommDataTranslationMeasurPointToUiMod3(comm, ui)
            
        end
        
        function connectCommDataTranslationMeasurPointToUiPob(comm, ui)
            
        end
        %}
        

        function connectCommDeltaTauPowerPmacToReticle(comm, ui)
        end
        
        function disconnectCommDeltaTauPowerPmacToReticle(ui)
        end
        
        function connectCommDeltaTauPowerPmacToUiWafer(comm, ui)
        end
        
        function disconnectCommDeltaTauPowerPmacToUiWafer(ui)
        end
        
        
        function connectCommKeithley6482WaferToUiFocusSensor(comm, ui)
            
            % {< mic.interface.device.GetNumber}
            device = bl12014.device.GetNumberFromKeithley6482(comm, 2);
            ui.uiDiode.setDevice(device);
            ui.uiDiode.turnOn();
        end
        
        function disconnectCommKeithley6482WaferToUiFocusSensor(ui)
            
            ui.uiDiode.turnOff()
            ui.uiDiode.setDevice([]);
            
        end
        
        function connectCommSmarActToUiFocusSensor(comm, ui)
                        
        end
        
        function disconnectCommSmarActToUiFocusSensor(ui)
            
        end

        
        function connectCommKeithley6482WaferToUiWafer(comm, ui)
            
            % {< mic.interface.device.GetNumber}
            device = bl12014.device.GetNumberFromKeithley6482(comm, 1);
            ui.uiDiode.uiCurrent.setDevice(device);
            ui.uiDiode.uiCurrent.turnOn();
            
        end
        
        function disconnectCommKeithley6482WaferToUiWafer(ui)
            
            ui.uiDiode.uiCurrent.turnOff()
            ui.uiDiode.uiCurrent.setDevice([]);
            
        end

        function connectCommKeithley6482ReticleToUiReticle(comm, ui)
            
            % {< mic.interface.device.GetNumber}
            device = bl12014.device.GetNumberFromKeithley6482(comm, 1);
            ui.uiDiode.uiCurrent.setDevice(device);
            ui.uiDiode.uiCurrent.turnOn();
            
        end
        
        function disconnectCommKeithley6482ReticleToUiReticle(ui)
            
            ui.uiDiode.uiCurrent.turnOff()
            ui.uiDiode.uiCurrent.setDevice([]);
        end
        
        function connectCommCxroHeightSensorToUiWafer(comm, ui)
        end
        
        function disconnectCommCxroHeightSensorToUiWafer(ui)
        end
        
        function connectCommCxroBeamlineToUiBeamline(comm, ui)
        end
        
        function disconnectCommCxroBeamlineToUiBeamline(ui)
        end
        
        function connectCommNewFocusModel8742ToUiM142(comm, ui)

            % {< mic.interface.device.GetSetNumber}
            deviceTiltX = bl12014.device.GetSetNumberFromNewFocusModel8742(comm, 2); % 2

            % {< mic.interface.device.GetSetNumber}
            deviceTiltYMf = bl12014.device.GetSetNumberFromNewFocusModel8742(comm, 1); % 1
            
            % {< mic.interface.device.GetSetNumber}
            deviceTiltYMfr = bl12014.device.GetSetNumberFromNewFocusModel8742(comm, 3);
            
            ui.uiStageTiltX.setDevice(deviceTiltX);
            ui.uiStageTiltYMf.setDevice(deviceTiltYMf);
            ui.uiStageTiltYMfr.setDevice(deviceTiltYMfr);
            
            ui.uiStageTiltX.turnOn()
            ui.uiStageTiltYMf.turnOn()
            ui.uiStageTiltYMfr.turnOn()
            
        end
        
        function disconnectCommNewFocusModel8742ToUiM142(ui)

            ui.uiStageTiltX.turnOff()
            ui.uiStageTiltYMf.turnOff()
            ui.uiStageTiltYMfr.turnOff()
            
            
            ui.uiStageTiltX.setDevice([]);
            ui.uiStageTiltYMf.setDevice([]);
            ui.uiStageTiltYMfr.setDevice([]);
            
            
            
        end
        
        % @param {micronix.MMC103 1x1} comm
        % @param {bl12014.ui.M142 1x1} ui
        function connectCommMicronixMmc103ToUiM142(comm, ui)
            
            % {< mic.interface.device.GetSetNumber}
            deviceX = bl12014.device.GetSetNumberFromMicronixMMC103(comm, 1);
            
            % {< mic.interface.device.GetSetNumber}
            deviceTiltZMfr = bl12014.device.GetSetNumberFromMicronixMMC103(comm, 2);
            
            ui.uiStageX.setDevice(deviceX);
            ui.uiStageTiltZMfr.setDevice(deviceTiltZMfr);
            
            ui.uiStageX.turnOn()
            ui.uiStageTiltZMfr.turnOn()
            
        end
        
        function disconnectCommMicronixMmc103ToUiM142(ui)
            
            
            ui.uiStageX.turnOff()
            ui.uiStageTiltZMfr.turnOff()
            
            ui.uiStageX.setDevice([]);
            ui.uiStageTiltZMfr.setDevice([]);
            
            
        end
        
        function connectCommNPointLC400FieldToUiFieldScanner(comm, ui)
            
        end
        
        function disconnectCommNPointLC400FieldToUiFieldScanner(ui)
            
        end
        
        function connectCommNPointLC400FieldToUiPupilScanner(comm, ui)
            
        end
        
        function disconnectCommNPointLC400FieldToUiPupilScanner(ui)
            
        end
        
    
    end
    
end

