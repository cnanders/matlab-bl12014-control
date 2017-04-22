classdef Connect
    
    % Helper functions to connect hardware com instances "comm" to UI.
    % This will build all devices < mic.interface.device.* and pass them 
    % to the UI with setDevice()
    
    
    properties
    end
    
    methods (Static)
        
        function connectCommSmarActMcsM141ToUiM141(comm, ui)
        end
        
        function connectCommSmarActMcsGoniToUiInterferometry(comm, ui)
        end
        
        function connectCommSmarActSmarPodToUiInterferometry(comm, ui)
        end
    
        function connectCommDataTranslationMeasurPointToUiM141(comm, ui)
        end
        
        function connectCommDataTranslationMeasurPointToUiD141(comm, ui)
        end
        
        function connectCommDataTranslationMeasurPointToUiD142(comm, ui)
        end
        
        function connectCommDataTranslationMeasurPointToUiM143(comm, ui)
        end
        
        function connectCommDataTranslationMeasurPointToUiVis(comm, ui)
        end
        
        function connectCommDataTranslationMeasurPointToUiMetrologyFrame(comm, ui)
        end
        
        function connectCommDataTranslationMeasurPointToUiMod3(comm, ui)
        end
        
        function connectCommDataTranslationMeasurPointToUiPob(comm, ui)
        end

        function connectCommDeltaTauPowerPmacToReticle(comm, ui)
        end
        
        function connectCommDeltaTauPowerPmacToUiWafer(comm, ui)
        end
        
        function connectCommKeithley6482WaferToUiWafer(comm, ui)
        end

        function connectCommKeithley6482ReticleToUiReticle(comm, ui)
        end
        
        function connectCommCxroHeightSensorToUiWafer(comm, ui)
        end
        
        function connectCommCxroBeamlineToUiBeamline(comm, ui)
        end
        
        function connectCommNewFocus8742ToUiM142(comm, ui)
            
        end
        
        function connectCommMicronixMmc103ToUiM142(comm, ui)
            
        end
        
        function connectCommNPointLC400FieldToUiFieldScanner(comm, ui)
            
        end
        
        function connectCommNPointLC400FieldToUiPupilScanner(comm, ui)
            
        end
        
    
    end
    
end

