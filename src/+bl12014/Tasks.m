classdef Tasks < mic.Base
        
    properties (Constant)
       
        cRecipeM142Default = 'Serpentine_sigx25_numx9_offx0_sigy5_numy5_offy0_scale1_per20_filthz2000_dt24_20181219-150012-gridified-repeat.mat';
        
    end
    
	properties
        
       
    end
    
    properties (SetAccess = private)
        
        
        
    end
    
    properties (Access = private)
                    
        
        
        
       
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = Tasks()
            
                        
            
        end
        
    end
    
    methods (Static)
        
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.TuneFluxDensity}
        % @param {mic.Clock 1x1}
        
        function task = createStateUndulatorIsCalibrated(cName, ui, clock)
            
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(ui, 'bl12014.ui.TuneFluxDensity')
                error('ui must be bl12014.ui.TuneFluxDensity');
            end
            
            ceTasks = {
                mic.Task.fromUiGetSetNumberWithGoalGetter(...
                    ui.uiUndulatorGap, ... mic.ui.device.GetSetNumbern
                    @() ui.getGapOfUndulatorCalibrated(), ... goal getter
                    0.02, ... Tolerance
                    'mm', ... Unit
                    'Gap of Undulator' ...
                ), ...
            };

                        
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Gap of Undulator @CalVal' ...
            );
            
        end
        
        
        function task = createStateExitSlitIsCalibrated(cName, ui, clock)
            
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(ui, 'bl12014.ui.TuneFluxDensity')
                error('ui must be bl12014.ui.TuneFluxDensity');
            end
            
            ceTasks = {
                mic.Task.fromUiGetSetNumberWithGoalGetter(...
                    ui.uiExitSlit.uiGap, ... mic.ui.device.GetSetNumber
                    @() ui.getGapOfExitSlitCalibrated(), ... goal getter
                    1, ... Tolerance
                    'um', ... Unit
                    'Gap of Exit Slit' ...
                ), ...
            };

                        
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Gap Exit Slit @CalVal' ...
            );
            
        end
        
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.Shutter 1x1}
        % @param {mic.Clock 1x1}
        function task = createStateShutterIsOpen(cName, ui, clock)
            
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(ui, 'bl12014.ui.Shutter')
                error('ui must be bl12014.ui.Shutter');
            end
            
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', {...
                    mic.Task.fromUiGetSetLogical(ui.uiOverride, true, 'Shutter') ...
                }, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Shutter is open' ...
            );
            
        end
        
        
        % Returns a {mic.Task} that that does nothing on fhExecute but that
        % fhIsDone checks the LC400 to make sure that its last loaded
        % recipe matches the desired recipe and that the LC400 is
        % on/moving/scanning
        % @param {char 1xm} cName - app-wide unique name
        % @param {npoint.ui.LC400 1x1}
        % @param {mic.Clock 1x1}
        function task = createStateMAScanningAnnular3585(cName, ui, clock)
            
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(ui, 'npoint.ui.LC400')
                error('ui must be npoint.ui.LC400');
            end
           
            % cNameOfRecipe = 'Annular-40-80.mat'; % testing
            cNameOfRecipe = 'Tune-Flux-Density-Ring.mat'; % testing
            
            [cDir] = fileparts(mfilename('fullpath'));
            
            cDir = mic.Utils.path2canonical(fullfile(...
                cDir, ...
                '..', ...
                'save', ...
                'scanner-ma', ...
                'starred' ...
            ));
        
            cPathOfRecipe = fullfile(...
                cDir, ...
                cNameOfRecipe ...
            );
       
            ceTasks = {...
                mic.Task(...
                   'fhIsDone', @() strcmpi(ui.getPathOfRecipe(), cPathOfRecipe), ...
                   'fhGetMessage', @() sprintf('MA recipe is %s', cPathOfRecipe) ...
                )...
                mic.Task(...
                    'fhIsDone', @() ui.uiGetSetLogicalActive.get(), ...
                    'fhGetMessage', @() 'MA is physically moving' ...
                )
            };
                
            % Return a sequence
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'MA Scanning Tune Flux Density Ring' ...
            );
        end
        
        
        % Returns a {mic.Task} that that does nothing on fhExecute but that
        % fhIsDone checks the LC400 to make sure that its last loaded
        % recipe matches the desired recipe and that the LC400 is
        % on/moving/scanning
        % @param {char 1xm} cName - app-wide unique name
        % @param {npoint.ui.LC400 1x1}
        % @param {mic.Clock 1x1}
        function task = createStateM142ScanningDefault(cName, ui, clock)
            
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(ui, 'npoint.ui.LC400')
                error('ui must be npoint.ui.LC400');
            end
           
            
            [cDir] = fileparts(mfilename('fullpath'));
            
            cDir = mic.Utils.path2canonical(fullfile(...
                cDir, ...
                '..', ...
                'save', ...
                'scanner-m142', ...
                'starred' ...
            ));
        
            cPathOfRecipe = fullfile(...
                cDir, ...
                bl12014.Tasks.cRecipeM142Default ...
            );
       
            % Checks if the LC400 is loaded and if the hardware is 
            ceTasks = {...
                mic.Task(...
                   'fhIsDone', @() strcmpi(ui.getPathOfRecipe(), cPathOfRecipe), ...
                   'fhGetMessage', @() sprintf('M142 recipe is %s', cPathOfRecipe) ...
                )...
                mic.Task(...
                    'fhIsDone', @() ui.uiGetSetLogicalActive.get(), ...
                    'fhGetMessage', @() 'M142 is physically moving' ...
                )
            };
                
            % Return a sequence
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'M142 is scanning standard pattern' ...
            );
        end
        
        
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.Scanner 1x1}
        % @param {mic.Clock 1x1}
        function task = createSequenceSetM142ToDefault(cName, uiScanner, clock)
            
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(uiScanner, 'bl12014.ui.Scanner')
                error('uiScanner must be bl12014.ui.Scanner');
            end
            
            % Create a task that loads a recipe into the PupilFillGenerator
            % and waits for it to populate its local buffer with the newly
            % calculated waveform from the newly loaded recipe
            
            
            task1 = mic.Task(...
                'fhExecute', @() uiScanner.uiPupilFillGenerator.setStarredByName(bl12014.Tasks.cRecipeM142Default), ...
                'fhIsDone', @() uiScanner.uiPupilFillGenerator.isDone(), ...
                'fhGetMessage', 'Building M142 waveform' ...
            );
         
            % Return a sequence
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', {...
                    task1, ...
                    uiScanner.uiNPointLC400.getSequenceWriteIllum() ...
                }, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Set M142 to default' ...
            );
        end
        
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.Scanner 1x1}
        % @param {mic.Clock 1x1}
        function task = createSequenceSetMAToAnnular3585(cName, uiScanner, clock)
            
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(uiScanner, 'bl12014.ui.Scanner')
                error('uiScanner must be bl12014.ui.Scanner');
            end
            
            % Create a task that loads a recipe into the PupilFillGenerator
            % and waits for it to populate its local buffer with the newly
            % calculated waveform from the newly loaded recipe
            
            % FIXME cVal in production
            cNameOfRecipe = 'Annular-40-80.mat';
            
            task1 = mic.Task(...
                'fhExecute', @() uiScanner.uiPupilFillGenerator.setStarredByName(cNameOfRecipe), ...
                'fhIsDone', @() uiScanner.uiPupilFillGenerator.isDone(), ...
                'fhGetMessage', 'Loading recipe into PupilFillGenerator' ...
            );
         
            % Return a sequence
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', {...
                    task1, ...
                    uiScanner.uiNPointLC400.getSequenceWriteIllum() ...
                }, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Set MA To Annular 40-80' ...
            );
        
        
            % 
        end
        
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.PowerPmacHydraMotMin 1x1}
        % @param {bl12014.ui.PowerPmacWorkingMode 1x1}
        % @param {mic.Clock 1x1}
        function task = createSequenceTurnOnWaferAndReticleHydra(cName, uiMotMin, uiWorkingMode, clock)
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(uiWorkingMode, 0, 0.1, 'mode', 'Working Mode'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui1, 3.5, 0.1, 'A', 'WCX MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui2, 3, 0.1, 'A', 'WCY MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui3, 4, 0.1, 'A', 'RCX MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui4, 4, 0.1, 'A', 'RCY MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiWorkingMode, 1, 0.1, 'mode', 'Working Mode') ...
            };
            
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Turn On Wafer+Reticle' ...
            );
        end
        
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.PowerPmacHydraMotMin 1x1}
        % @param {bl12014.ui.PowerPmacWorkingMode 1x1}
        % @param {mic.Clock 1x1}
        function task = createSequenceTurnOnWaferHydra(cName, uiMotMin, uiWorkingMode, clock)
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(uiWorkingMode, 0, 0.1, 'mode', 'Working Mode'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui1, 3.5, 0.1, 'A', 'WCX MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui2, 3, 0.1, 'A', 'WCY MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiWorkingMode, 1, 0.1, 'mode', 'Working Mode') ...
            };
            
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Turn On Wafer' ...
            );
        end
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.PowerPmacHydraMotMin 1x1}
        % @param {bl12014.ui.PowerPmacWorkingMode 1x1}
        % @param {mic.Clock 1x1}
        function task = createSequenceTurnOffWaferHydra(cName, uiMotMin, uiWorkingMode, clock)
            
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(uiWorkingMode, 0, 0.1, 'mode', 'Working Mode'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui1, 0, 0.1, 'A', 'WCX MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui2, 0, 0.1, 'A', 'WCY MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiWorkingMode, 1, 0.1, 'mode', 'Working Mode') ...
            };
            
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Turn Off Wafer' ...
            );
        end
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.PowerPmacHydraMotMin 1x1}
        % @param {bl12014.ui.PowerPmacWorkingMode 1x1}
        % @param {mic.Clock 1x1}
        function task = createSequenceTurnOffAllHydras(cName, uiMotMin, uiWorkingMode, clock)
            
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(uiWorkingMode, 0, 0.1, 'mode', 'Working Mode'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui1, 0, 0.1, 'A', 'WCX MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui2, 0, 0.1, 'A', 'WCY MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui3, 0, 0.1, 'A', 'RCX MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui4, 0, 0.1, 'A', 'RCY MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui5, 0, 0.1, 'A', 'LSIX MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiWorkingMode, 1, 0.1, 'mode', 'Working Mode') ...
            };
            
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Turn Off All' ...
            );
        end
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.PowerPmacHydraMotMin 1x1}
        % @param {mic.Clock 1x1}
        function task = createStateWaferHydraOn(cName, uiMotMin, clock)
               
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui1, 3.5, 0.1, 'A'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui2, 3, 0.1, 'A'), ...
            };
            
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Wafer On' ...
            );
        end
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.PowerPmacHydraMotMin 1x1}
        % @param {mic.Clock 1x1}
        function task = createStateReticleHydraOn(cName, uiMotMin, clock)
                
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui3, 4, 0.1, 'A'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui4, 4, 0.1, 'A'), ...
            };
            
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Reticle On' ...
            );
        end
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.PowerPmacHydraMotMin 1x1}
        % @param {mic.Clock 1x1}
        function task = createStateLsiHydraOn(cName, uiMotMin, clock)
                
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui5, 4, 0.1, 'A') ...
            };
            
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'LSI On' ...
            );
        end
        
        %{
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.ReticleCoarseStage 1x1} ui
        % @param {mic.Clock 1x1}
        function task = createStateReticleStageAtClearField(cName, ui, clock)
                
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
        
            if ~isa(ui, 'bl12014.ui.ReticleFiducializedMove')
                error('ui must be bl12014.ui.ReticleFiducializedMove');
            end
            
            % Fiducializatoin from 2019.04.04
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(ui.uiX, 64.38, 0.1, 'mm', 'Reticle Coarse X'), ...
                mic.Task.fromUiGetSetNumber(ui.uiY, 19.785, 0.1, 'mm', 'Reticle Coarse Y'), ...
                ... %mic.Task.fromUiGetSetNumber(ui.uiZ, 0, 0.01, 'mm', 'Reticle Coarse Z') ...
            };
            
                    
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Reticle at Clear Field' ...
            );
        end
        
        %}
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {mic.ui.device.GetSetNumber 1x1} ui - get it from
        % ui.Beamline.uiGratingTiltX
        % @param {mic.Clock 1x1}
        function task = createStateMonoGratingAtEUV(...
                cName, ...
                ui, ...
                clock ...
        )
    
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(ui, 'mic.ui.device.GetSetNumber')
                error('ui must be mic.ui.device.GetSetNumber');
            end
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(ui, 13.5, 0.01, 'wav (nm)', 'Mono Grating'), ...
            };
                    
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Mono Grating at EUV' ...
            );
   
        end
        
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.ReticleFiducializedMove 1x1} ui
        % @param {mic.Clock 1x1}
        function task = createStateReticleStageAtClearField(...
                cName, ...
                ui, ...
                clock)
                
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(ui, 'bl12014.ui.ReticleFiducializedMove')
                error('ui must be bl12014.ui.ReticleFiducializedMove');
            end
            
            %{
            if ~isa(uiReticleTTZClosedLoop, 'bl12014.ui.ReticleTTZClosedLoop')
                error('uiReticleTTZClosedLoop must be bl12014.ui.ReticleTTZClosedLoop');
            end
            %}
            
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(ui.uiRow, 1, 0.01, 'cell', 'Reticle to Row 1'), ...
                mic.Task.fromUiGetSetNumber(ui.uiCol, 19, 0.01, 'cell', 'Reticle to Col 19'), ...
            };
                    
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Reticle at Clear Field' ...
            );
        end
        
        
        
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.WaferCoarseStage 1x1} ui
        % @param {mic.Clock 1x1}
        function task = createStateWaferStageAtDiode(cName, ui, clock)
                
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(ui.uiX, -103.45, 0.01, 'mm', 'Wafer Coarse X'), ...
                mic.Task.fromUiGetSetNumber(ui.uiY, 6.95, 0.01, 'mm', 'Wafer Coarse Y'), ...
                mic.Task.fromUiGetSetNumber(ui.uiZ, 0.313, 0.01, 'mm', 'Wafer Coarse Z'), ...
            };
            
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', 'Wafer at Diode' ...
            );
        end
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.Hardware 1x1} ui
        % @param {mic.Clock 1x1}
        function task = createStateHardwareConnected(cName, ui, clock)

            ceTasks = {...
                mic.Task.fromUiGetSetLogical(ui.uiALS, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiDeltaTauPowerPmac, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiDataTranslationMeasurPoint, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiMfDriftMonitor, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiMfDriftMonitorMiddleware, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiKeithleyWafer, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiKeithleyReticle, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiWebSwitchBeamline, true), ...
                ...mic.Task.fromUiGetSetLogical(ui.uiWebSwitchEndstation, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiWebSwitchVis, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiBL1201CorbaProxy, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiRigol, true), ...
                ...mic.Task.fromUiGetSetLogical(ui.uiSmarActM141, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiWagoD141, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiExitSlit, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiGalilD142, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiGalilM143, true), ...
                ... This  hardware has remote power that needs to be on.
                ...mic.Task.fromUiGetSetLogical(ui.uiGalilVis, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiMightex1, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiMightex2, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiNPointM142, true), ...
                mic.Task.fromUiGetSetLogical(ui.uiNPointMA, true), ...
             };
         
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.25, ...
                'cDescription', 'Connect All Hardware' ...
            );
            
        end
        
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.HeightSensorLEDs 1x1} ui
        % @param {mic.Clock 1x1}
        function task = createStateHeightSensorLEDsOn(cName, ui, clock)
                
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(ui.ui1, 850, 0.01, 'mA', 'Height Sensor LED Ch 1'), ...
                mic.Task.fromUiGetSetNumber(ui.ui2, 1000, 0.01, 'mA', 'Height Sensor LED Ch 2'), ...
                mic.Task.fromUiGetSetNumber(ui.ui3, 1000, 0.01, 'mA', 'Height Sensor LED Ch 3'), ...
                mic.Task.fromUiGetSetNumber(ui.ui4, 800, 0.01, 'mA', 'Height Sensor LED Ch 4'), ...
                mic.Task.fromUiGetSetNumber(ui.ui5, 750, 0.01, 'mA', 'Height Sensor LED Ch 5'), ...
                mic.Task.fromUiGetSetNumber(ui.ui6, 900, 0.01, 'mA', 'Height Sensor LED Ch 6') ...
            };
            
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.25, ...
                'cDescription', 'Height Sensor LEDs On' ...
            );
        end
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.HeightSensorLEDs 1x1} ui
        % @param {mic.Clock 1x1}
        function task = createStateHeightSensorLEDsOff(cName, ui, clock)
                
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(ui.ui1, 0, 0.01, 'mA', 'Height Sensor LED Ch 1'), ...
                mic.Task.fromUiGetSetNumber(ui.ui2, 0, 0.01, 'mA', 'Height Sensor LED Ch 2'), ...
                mic.Task.fromUiGetSetNumber(ui.ui3, 0, 0.01, 'mA', 'Height Sensor LED Ch 3'), ...
                mic.Task.fromUiGetSetNumber(ui.ui4, 0, 0.01, 'mA', 'Height Sensor LED Ch 4'), ...
                mic.Task.fromUiGetSetNumber(ui.ui5, 0, 0.01, 'mA', 'Height Sensor LED Ch 5'), ...
                mic.Task.fromUiGetSetNumber(ui.ui6, 0, 0.01, 'mA', 'Height Sensor LED Ch 6') ...
            };
            
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.25, ...
                'cDescription', 'Height Sensor LEDs Off' ...
            );
        end
        
        % Sequence that:
        % - reticle at clear field
        % - wafer at diode
        % - height sensor LEDs off
        % - shutter open
        % - MA scanning annular 35/85
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.ReticleFiducializedMove 1x1}
        % @param {bl12014.ui.WaferCoarseStage 1x1}
        % @param {bl12014.ui.WaferCoarseStage 1x1}
        % @param {mic.Clock 1x1}
        function task = createSequencePrepForTuningFluxDensity(...
                cName, ...
                uiReticle, ...
                uiReticleTTZClosedLoop, ...
                uiWafer, ...
                uiLEDs, ...
                uiScannerMA, ...
                uiScannerM142, ...
                uiShutter, ...
                clock)
                
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(uiReticle, 'bl12014.ui.ReticleFiducializedMove')
                error('uiReticle must be bl12014.ui.ReticleFiducializedMove');
            end
            
            if ~isa(uiReticleTTZClosedLoop, 'bl12014.ui.ReticleTTZClosedLoop')
                error('uiReticleTTZClosedLoop must be bl12014.uiReticleTTZClosedLoop');
            end
            
            if ~isa(uiWafer, 'bl12014.ui.WaferCoarseStage')
                error('uiWafer must be bl12014.ui.WaferCoarseStage');
            end
            
            if ~isa(uiLEDs, 'bl12014.ui.HeightSensorLEDs')
                error('uiLEDs must be bl12014.ui.HeightSensorLEDs');
            end
            
            if ~isa(uiScannerMA, 'bl12014.ui.Scanner')
                error('uiScannerMA must be bl12014.ui.Scanner');
            end
            
            if ~isa(uiScannerM142, 'bl12014.ui.Scanner')
                error('uiScannerM142 must be bl12014.ui.Scanner');
            end
            
            if ~isa(uiShutter, 'bl12014.ui.Shutter')
                error('uiShutter must be bl12014.ui.Shutter');
            end
            
            ceTasks = {...
                bl12014.Tasks.createStateReticleStageAtClearField(...
                    [cName, 'reticle-stage-at-clear-field'], ...
                    uiReticle, ...
                    clock ...
                ), ...
                bl12014.Tasks.createSequenceLevelReticle(...
                    [cName, 'reticle-is-level'], ...
                    uiReticleTTZClosedLoop, ...
                    clock ...
                ), ...
                bl12014.Tasks.createStateWaferStageAtDiode(...
                    [cName, 'wafer-stage-at-diode'], ...
                    uiWafer, ...
                    clock ...
                ), ...
                bl12014.Tasks.createStateHeightSensorLEDsOff(...
                    [cName, 'height-sensor-leds-off'], ...
                    uiLEDs, ...
                    clock ...
                ), ...
                bl12014.Tasks.createSequenceSetMAToAnnular3585(...
                    [cName, 'set-ma-to-annular-3585'], ...
                    uiScannerMA, ...
                    clock ...
                ), ...
                bl12014.Tasks.createSequenceSetM142ToDefault(...
                    [cName, 'set-m142-to-default'], ...
                    uiScannerM142, ...
                    clock ...
                ), ...
                bl12014.Tasks.createStateShutterIsOpen(...
                    [cName, 'shutter-is-open'], ...
                    uiShutter, ...
                    clock ...
                ), ...
            };
            
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.1, ...
                'cDescription', 'Prep Reticle, Wafer, HS LEDs, Shutter, M142 Scan, MA Scan' ...
            );
        end
        
        
        
        % Sequence that:
        % - Sets wafer rx, ry, and z based on config data
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.WaferTTZClosedLoop 1x1} ui
        % @param {mic.Clock 1x1}
        function task = createSequenceLevelWafer(...
                cName, ...
                ui, ...
                ...uiHeightSensorLEDs, ...
                clock)
                
            
            if ~isa(ui, 'bl12014.ui.WaferTTZClosedLoop')
                error('ui must be bl12014.ui.WaferTTZClosedLoop');
            end
            
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            cDirThis = fileparts(mfilename('fullpath'));
            cPathConfig = fullfile(...
                cDirThis, ...
                '..', ...
                'config', ...
                'Wafer-CLTTZ-leveler-coordinates.json' ...
            );
            stConfigDat = loadjson(cPathConfig);
            
            %{
            I had debated on making it turn on the HS LEDs but decided
            against it
            bl12014.Tasks.createStateHeightSensorLEDsOn(...
                [cName, 'height-sensor-leds-on'], ...
                uiHeightSensorLEDs, ...
                clock ...
            ), ...
            %}

            ceTasks = {...
                mic.Task.fromUiGetSetNumber(ui.uiCLZ, ...
                    stConfigDat.Z.value, ...
                    stConfigDat.Z.displayTol, ...
                    stConfigDat.Z.unit, ...
                    'Wafer Z'), ...
                mic.Task.fromUiGetSetNumber(ui.uiCLTiltX, ...
                    stConfigDat.tiltX.value, ...
                    stConfigDat.tiltX.displayTol, ...
                    stConfigDat.tiltX.unit, ...
                    'Wafer Tilt X'), ...
                mic.Task.fromUiGetSetNumber(ui.uiCLTiltY, ...
                    stConfigDat.tiltY.value, ...
                    stConfigDat.tiltY.displayTol, ...
                    stConfigDat.tiltY.unit, ...
                    'Wafer Tilt Y'), ...
                mic.Task.fromUiGetSetNumber(ui.uiCLZ, ...
                    stConfigDat.Z.value, ...
                    stConfigDat.Z.displayTol, ...
                    stConfigDat.Z.unit, ...
                    'Wafer Z'), ...
            };
            
            cDescription = sprintf('Level Wafer (x %1.0fum, y %1.0fum, z %1.0fnm)', ...
                stConfigDat.tiltX.value, ...
                stConfigDat.tiltY.value, ...
                stConfigDat.Z.value ...
            );
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', cDescription ...
            );
        end
        
         % Sequence that:
        % - Sets RETICLE rx, ry, and z based on config data
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.ReticleTTZClosedLoop} ui
        % @param {mic.Clock 1x1}
        function task = createSequenceLevelReticle(...
                cName, ...
                ui, ...
                clock)
               
            if ~isa(ui, 'bl12014.ui.ReticleTTZClosedLoop')
                error('ui must be bl12014.ui.ReticleTTZClosedLoop');
            end
            
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            
            cDirThis = fileparts(mfilename('fullpath'));
            cPathConfig = fullfile(...
                cDirThis, ...
                '..', ...
                'config', ...
                'Reticle-CLTTZ-leveler-coordinates.json' ...
            );
            stConfigDat = loadjson(cPathConfig);

            ceTasks = {...
                mic.Task.fromUiGetSetNumber(ui.uiCLZ, ...
                    stConfigDat.Z.value, ...
                    stConfigDat.Z.displayTol, ...
                    stConfigDat.Z.unit, ...
                    'Ret Z'), ...
                mic.Task.fromUiGetSetNumber(ui.uiCLTiltX, ...
                    stConfigDat.tiltX.value, ...
                    stConfigDat.tiltX.displayTol, ...
                    stConfigDat.tiltX.unit, ...
                    'Ret Tilt X'), ...
                mic.Task.fromUiGetSetNumber(ui.uiCLTiltY, ...
                    stConfigDat.tiltY.value, ...
                    stConfigDat.tiltY.displayTol, ...
                    stConfigDat.tiltY.unit, ...
                    'Ret Tilt Y'), ...
                mic.Task.fromUiGetSetNumber(ui.uiCLZ, ...
                    stConfigDat.Z.value, ...
                    stConfigDat.Z.displayTol, ...
                    stConfigDat.Z.unit, ...
                    'Ret Z') ...
            };
            
            cDescription = sprintf('Level Reticle (x %1.0fum, y %1.0fum, z %1.0fnm)', ...
                stConfigDat.tiltX.value, ...
                stConfigDat.tiltY.value, ...
                stConfigDat.Z.value ...
            );
            task = mic.TaskSequence(...
                'cName', cName, ...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cDescription', cDescription ...
            );
        end
    end 
    
    
end