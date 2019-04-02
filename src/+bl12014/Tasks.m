classdef Tasks < mic.Base
        
    properties (Constant)
       
        
        
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
           
            cNameOfRecipe = 'Annular-40-80.mat'; % testing
            
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
                'cDescription', 'MA Scanning Annular 35-85' ...
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
           
            cNameOfRecipe = '1Pole_off0_rot90_min35_max55_num3_dwell2_xoff0_yoff0_per100_filthz400_dt24.mat';
            cNameOfRecipe = 'Default.mat'; % testing
            
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
                cNameOfRecipe ...
            );
       
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
            
            % FIXME cVal in production
            cNameOfRecipe = 'default.mat';
            
            task1 = mic.Task(...
                'fhExecute', @() uiScanner.uiPupilFillGenerator.setStarredByName(cNameOfRecipe), ...
                'fhIsDone', @() uiScanner.uiPupilFillGenerator.isDone(), ...
                'fhGetMessage', 'Loading recipe into M142 signal generator' ...
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
                mic.Task.fromUiGetSetNumber(uiMotMin.ui1, 4, 0.1, 'A', 'WCX MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui2, 4, 0.1, 'A', 'WCY MotMin'), ...
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
                mic.Task.fromUiGetSetNumber(uiMotMin.ui1, 4, 0.1, 'A', 'WCX MotMin'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui2, 4, 0.1, 'A', 'WCY MotMin'), ...
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
                mic.Task.fromUiGetSetNumber(uiMotMin.ui1, 4, 0.1, 'A'), ...
                mic.Task.fromUiGetSetNumber(uiMotMin.ui2, 4, 0.1, 'A'), ...
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
        
        % @param {char 1xm} cName - app-wide unique name
        % @param {bl12014.ui.ReticleCoarseStage 1x1} ui
        % @param {mic.Clock 1x1}
        function task = createStateReticleStageAtClearField(cName, ui, clock)
                
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            ceTasks = {...
                mic.Task.fromUiGetSetNumber(ui.uiX, 64.5, 0.01, 'mm', 'Reticle Coarse X'), ...
                mic.Task.fromUiGetSetNumber(ui.uiY, 19.08, 0.01, 'mm', 'Reticle Coarse Y'), ...
                mic.Task.fromUiGetSetNumber(ui.uiZ, 0, 0.01, 'mm', 'Reticle Coarse Z') ...

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
                'dPeriod', 0.5, ...
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
        % @param {bl12014.ui.ReticleCoarseStage 1x1}
        % @param {bl12014.ui.WaferCoarseStage 1x1}
        % @param {bl12014.ui.WaferCoarseStage 1x1}
        % @param {mic.Clock 1x1}
        function task = createSequencePrepForTuningFluxDensity(...
                cName, ...
                uiReticle, ...
                uiWafer, ...
                uiLEDs, ...
                uiScannerMA, ...
                uiScannerM142, ...
                uiShutter, ...
                clock)
                
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(uiReticle, 'bl12014.ui.ReticleCoarseStage')
                error('uiReticle must be bl12014.ui.ReticleCoarseStage');
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
        % @param {bl12014.ui.GetSetNumber (from closedLoopControl) 1x1}
        % @param {bl12014.ui.GetSetNumber (from closedLoopControl) 1x1}
        % @param {bl12014.ui.GetSetNumber (from closedLoopControl) 1x1}
        % @param {struct} config data storing destination values
        % @param {mic.Clock 1x1}
        function task = createSequenceLevelWafer(...
                cName, ...
                uiCLTiltX, ...
                uiCLTiltY, ...
                uiCLZ, ...
                stConfigDat, ...
                clock)
                
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            

            ceTasks = {...
                mic.Task.fromUiGetSetNumber(uiCLTiltX, ...
                    stConfigDat.tiltX.value, ...
                    stConfigDat.tiltX.displayTol, ...
                    stConfigDat.tiltX.unit, ...
                    'Wafer Tilt X'), ...
                mic.Task.fromUiGetSetNumber(uiCLTiltY, ...
                    stConfigDat.tiltY.value, ...
                    stConfigDat.tiltY.displayTol, ...
                    stConfigDat.tiltY.unit, ...
                    'Wafer Tilt Y'), ...
                mic.Task.fromUiGetSetNumber(uiCLZ, ...
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
        % @param {bl12014.ui.GetSetNumber (from closedLoopControl) 1x1}
        % @param {bl12014.ui.GetSetNumber (from closedLoopControl) 1x1}
        % @param {bl12014.ui.GetSetNumber (from closedLoopControl) 1x1}
        % @param {struct} config data storing destination values
        % @param {mic.Clock 1x1}
        function task = createSequenceLevelReticle(...
                cName, ...
                uiCLTiltX, ...
                uiCLTiltY, ...
                uiCLZ, ...
                stConfigDat, ...
                clock)
                
            if ~isa(clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end

            ceTasks = {...
                mic.Task.fromUiGetSetNumber(uiCLTiltX, ...
                    stConfigDat.tiltX.value, ...
                    stConfigDat.tiltX.displayTol, ...
                    stConfigDat.tiltX.unit, ...
                    'Ret Tilt X'), ...
                mic.Task.fromUiGetSetNumber(uiCLTiltY, ...
                    stConfigDat.tiltY.value, ...
                    stConfigDat.tiltY.displayTol, ...
                    stConfigDat.tiltY.unit, ...
                    'Ret Tilt Y'), ...
                mic.Task.fromUiGetSetNumber(uiCLZ, ...
                    stConfigDat.Z.value, ...
                    stConfigDat.Z.displayTol, ...
                    stConfigDat.Z.unit, ...
                    'Ret Z'), ...
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