<!-- 
TO DO


### UI for Exit Slits

- Most likeley a single mic.ui.GetSetNumber

### UI for Mono

- mic.ui.GetSetNumbers:
  - wav, grating
- mic.ui.GetSetLogical:
  - diode insertion
- mic.ui.GetNumber:
  - diode current (MeasurPoint?)

In addition, it will have interface for setting up a 1D scan, similar to NUS software.  It will have min / max values for wavelength, settle delay, all of the stuff that NUS scan had (possibly elapsed time, etc).  Will need to show the plot, allow clicking to set zero. 

 

### ui.Wafer

- When moving stage, need to use correct units.  The ui.WaferAxes always passes SI units

-->

# 1.0.0-alpha.4


### bl12014.ui.WaferAxes

- Build crosshairs for the wafer and the chief ray that change thickness on zoom so they can be viewed zoomed out and zoomed in while preserving the field of view that they occupy
- Added support for FEM preview associated with the prescription and a FEM preview associated with the scan.  Each has its own `add()` and `delete()` methods

### bl12014.ui.FemTool

- While `load()` is being evoked, now suppresses `notify` calls during the load process while multiple `mic.ui.common.Edit` are being updated and instead issues one single event at the end.

### bl12014.ui.Beamline

- Now listens for size changes from `bl12014.ui.FemTool` and updates the FEM preview on `bl12014.ui.WaferAxes`
- Now listens for `bl12014.ui.PrescriptionTool` `eNew` event and refreshes the list of available prescriptions in `bl12014.ui.Scan`

### bl12014.ui.ProcessTool

- Now using Hungarian notaion in `save()` and `load()`.
- Fixed a typo on one of the properties in `save()` and `load()`

### bl12014.ui.PrescriptionTool

- Now saves `fem` and `process` parameters to the recipe `.json` file.

### bl12014.ui.Scan

- Fixed bug with `stScanAcquireContract` not setting `lRequired` = `true` for the `shutter` property.
- As prescriptions are added and removed from the upcoming scan, the FEM preview of each one is added to the `ui.WaferAxes`.

### bl12014.ui.Shutter

- Build this class and incorporated it into `bl12014.ui.Scan` and `bl12014.ui.Beamline`

# 1.0.0-alpha.3

### bl12014.ui.Scan

This is the class that creates a `mic.StateScan` to carry out a prescription recipe.  

### bl12014.ui.PrescriptionTool

- Builds JSON state scan recipe of a FEM + reticle position + pupil fill to be consumed by `mic.StateScan`
- Stores the UI state of each recipe in a .mat file and the UI is updated whenever a recipe is selected

### bl12014.ui.ReticleTool, ProcessTool, FemTool, PupilTool
- Added `save()` and `load()` methods
- Refactored to use the refactored API of `mic.ui.common.List` and `Popup*` from v1.0.0-beta.5 of MIC.
- Added `uitQA` property to each that is a `mic.ui.common.Toggle` that changes the color of the panel when clicked.  The idea is the user can click these after they have verified a particular section of the recipe.  I would like the panel to change back to the default color whenever something changes.  This is still in progress.

# 1.0.0-alpha.2

- Fixed reference to legacy Utils.lt2lb.  Now using mic.Utils.lt2lb
- UI for
  - WaferCoarseStage
  - WaferFineStage
  - Wafer
- Refactored WaferAxes out of Wafer, improved documentation and built a test
- Refactored ReticleAxes out of Reticle, improved documentation and built a test

# 1.0.0-alpha.1

- UI for:
  - M141
  - M142
  - D141
  - D142
  - Reticle
  - ReticleCoarseStage
  - ReticleFineStage

- moved /pkg to /src 

# 1.0.0-alpha.0

- Initial project structure and dependencies