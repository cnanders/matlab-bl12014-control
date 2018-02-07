<!-- 
TO DO

### ui.Wafer

- When moving stage, need to use correct units.  The ui.WaferAxes always passes SI units

-->

# 1.0.0-alpha.33

- Added `lShowStepNeg`, `lShowStep`, and `lShowStepPos` to `GetSetNumber`

# 1.0.0-alpha.32

- Implemented `save()` and `load()` functionlity across the main `ui.*` classes.  Some of the LSI
stuff still needs to be done.

# 1.0.0-alpha.31

- All code that connects comm instances to UI through `device` instances is now inside of individual UI modules.  This cleaned up the high-level App substantially

# 1.0.0-alpha.30
- Adding methods for LSICamera


# 1.0.0-alpha.29

- `device.GetSetNumberFromMicronixMMC103` now only starts the time in `initialize()` if the timer is not already running.  For repeat calls

# 1.0.0-alpha.28

- Added bl12dev.als.lbl.gov:8451 to `ui.NetworkCommunication`
- In `device.GetSetNumberFromDCTCorbaProxy`, removed references to `this.stage` that were not deleted when class was originally created by saving other GetSetNumber* class as this one.
- `device.GetSetNumberFromDCTCorbaProxy.get()` now shows the last value passed to `set()` if the shutter is open.

# 1.0.0-alpha.27

- `device.GetSetNumberFromBL1201CorbaProxy` removed references to `this.stage` that were not deleted when class was originally created by saving other GetSetNumber* class as this one.
- Adding config information to Beamline -> Grating Tilt X so it can display in nm and eV.
- `ui.NetworkStatus` added `bl12control.als.lbl.gov`
- `ui.NetworkStatus` figured out the correct ports to use for `bl12pico.als.lbl.gov` and `bl12control.als.lbl.gov` by using WireShark and watching the traffic that the Java comm classes create.

# 1.0.0-alpah.26

- `device.GetSetNumberFromExitSlit` now uses `bl12pico_setSlitGapNoblock` instead of `bl12pico_setSlitGap`
- Fixed bug in `App` in `initAndConnectExitSlit`
- Updated `ui.Scanner` to use updated version of `github/cnanders/matlab-npoint-lc400-ui`

# 1.0.0-alpha.25

- Added dependency on [MATLAB nPoint LC400 UI](https://github.com/cnanders/matlab-npoint-lc400-ui)
- Added dependency on [MATLAB Pupil Fill Generator](https://github.com/cnanders/matlab-pupil-fill-generator)
- Added dependency on [MATLAB Quasar](https://github.com/cnanders/matlab-quasar)
- Refactored MA Scanner and M142 Scanner UI to use MATLAB nPoint LC400 UI and MATLAB Pupil Fill Generator UI to incorporate quasar illumination and make the separation of hardware instances and UI consistent with the rest of the application
- Named all `timers` throughout codebase

### `ui.Beamline`, `ui.Shutter`

- Updated `delete()` methods so they properly delete all children that should be deleted

# 1.0.0-alpha.24

- Updated all of the `ui.*` classes to use `u8_MSG_TYPE_*` msg types in the constructor varargin assignment

# 1.0.0-alpha.23

### App

- in `delete()` method, reversed order.  Call disconnectAll() then delete the parent UI 
- Returning in most UI to device linking functions Ryan built as they caused crashes.

# 1.0.0-alpha.22

### App

- Linked Keithley6482 comm to `ui.Reticle` and `ui.Wafer`
- Commendted out code that was setting up ui.LSIConnect GetSetLogicalConnects since it was crashing

### README.md

- Updated README.md with imporved documentation for depencies

# 1.0.0-alpha.21

### device.GetLogicalFromDeltaTauPowerPmac

- Added support for additional motor status statuses
- Exposed lists of the supported types

### ui.M141

- Commented UI for tiltX and tiltY since no low-level controls

### ui.PowerPmacStatus

- Added new UI for all statuses that were added to device.GetLogicalFromDeltaTauPowerPmac

### ui.Reticle\*, ui.Wafer\*

- Updated config files to include limits
- Updated UI to show limit ranges
- Added fix for when NaN values are passed to the callbacks that update the ZoomPanAxis

# 1.0.0-alpha.20-ryan

### bl12014

- Adding `destroyAndDisconnectMet5Instruments` to `destroyAndDisconnectAll`.  Not disconnecting MET5Instruments jar was causing problems when the app is reloaded.

- Adding LSI stage disconnect routines for hexapod, reticle and goni

- Wrapped LSI init in a try, since this is in a separate repo for now

- Updated `connectCommDeltaTauPowerPmacToUiLsi` to integrate reticle control in the LSI UI.  

- Updated `initAndConnectSmarActMcsGoni` and `initAndConnectSmarActSmarPod` to plug into the coupled-axis control framework required for LSI

- Added buttons in main uiApp to launch LSI control and plugged in LSI UI.  LSI analyze ui is built but not properly integrated yet.

- LSIControl can be cloned from https://github.com/ryanmiyakawa/LSI-control.git and is expected to be found in vendor/github/rhmiyakawa/

# 1.0.0-alpha.20

### ui.PowerPmacStatus

- Updated `build()` method.  If figure exists, it now brings figure to front and returns.  If figure does not exist, it builds normally.

### device.GetSetNumberFromDeltaTauPowerPmac

- Completed the `stop()` method by calling `stopAll()` method of underlying comm class.

### bl12014.device.GetLogicalFromDeltaTauPowerPmac

- Completed

### bl12014.ui.PowerPmacWorkingMode

- Built new UI panel to set / get working mode

### bl12014.ui.Reticle, bl12014.ui.Wafer

- Integrated bl12014.ui.PowerPmacWorkingMode into both of these


### bl12014.ui.PowerPmacStatus

- Added a "connect to DeltaTau Power PMAC" button at the top

### bl12014.App

- Wired the connect logical to bl12014.ui.PowerPmacStatus
- Wired bl12014.ui.PowerPmacStatus into the initAndConnect / destroyAndDisconnect methods for PowerPmac
- Refactored the initAndConnect / destroyAndDisconnect methods for PowerPmac with some helper functions that hanldle each main UI panel that the comm connects to

# 1.0.0-alpha.19

### bl12014.ui.PowerPmacStatus

- UI that shows every status / error flag that the Power PMAC exposes

### bl12014.App

- Now show error message in the initAndConnect*() methods in the `catch` block
- Integrated the Galil that controls D142

# 1.0.0-alpha.18

### bl12014.device.GetLogicalPing

- Updated it to use more rubust java class that establishes a  `Socket` connection with the server on the specified port

### bl12014.ui.NetworkCommunication

- Added port to all device configurations

# 1.0.0-alpha.17

- Partial build of src/+bl12014/+device/GetSetNumberFromDeltaTauPowerPMAC.m

### bl12014.device.GetLogicalPing

- This device, which extends `mic.interface.device.GetLogical`, pings the provided IP address.  If the address is reachable, it returns true.  Otherwise it returns false.

### bl12014.ui.NetworkCommunication

- New UI to show status of network communication with every device



# 1.0.0-alpha.16

- Added `tests/test_network_communication` which performs a ping for every device that the software can communicate with
- Integrating correct IPs for devices in App.

# 1.0.0-alpha.15

- Added `cName` property (SetAccess = private) to several of the `bl12014.ui` classes and use it when setting the `cName` of the `mic.ui.device.*` instances to avoid name conflicts in the project when multiple `mic.ui.device.*` communicate with the same comm.


# 1.0.0-alpha.14

- Integrated `DctCorbaProxy` into `App`
- Integrated `BL1201CorbaProxy` into `App`
- Built `bl12014.device.GetSetNumberFromDctCorbaProxy`
- Built `bl12014.device.GetSetNumberFromBL1201CorbaProxy`
- Updated `bl12014.ui.Beamline` with `uiCommDctCorbaProxy` and `uiCommBL1201CorbaProxy`

# 1.0.0-alpha.13

- Renamed UI for controlling hardware comm to `uiComm*`
- Made UI for diodes consistent throughout.  Now called `uiCurrent`
- Linked SmarAct rotary stage for `WaferFocusSensor` into `App`
- Linked Galil stages for `M143` and `D142` into `App`
- Built `FocusSensor`, which is a temporary UI that contains most of the elements that I believe will be needed for the final UI

# 1.0.0-alpha.12

- Removed `Connect` class and put everything in `App`.  Simpler this way

# 1.0.0-alpha.11

- Linked Keithley6482Wafer into App and Connect
- Created `bl12014.ui.ReticleDiode`
- Created `bl12014.ui.WaferDiode`
- Integrated `bl12014.ui.ReticleDiode` into `bl12014.ui.Reticle`
- Integrated `bl12014.ui.WaferDiode` into `bl12014.ui.Wafer`

# 1.0.0-alpha.10

- Linked ScannerControl (MA and M142) into the App and they are incorporated into `save()` and `load()` to persist their state across sessions.

# 1.0.0-alpha.9

- Linked Micronix MMC 103 into App and Connect
- Linked NewFocus Model 8742 into App and Connect
- Connect now calls `turnOn()` method of `mic.ui.device.*` instances after it sets their device
- Updated config for M142 tiltX, tiltYMf, tiltYMfr to use counts instead of deg


# 1.0.0-alpha.8

### bl12014.ui.PobCapSensors

- New UI panel to show reading from MeasurPoint for each cap sensor of POB (they look at the wafer)

### bl12014.ui.PobTempSensors

- New UI panel to show reading from MeasurPoint for each RTD (12) attached to POB

### bl12014.ui.Mod3CapSensors

- New UI panel to show reading from MeasurPoint for each cap sensor of Mod3 (they look at the reticle)

### bl12014.ui.Mod3TempSensors

- New UI panel to show reading from MeasurePoint for each RTD (?) attached to the Mod3

### bl12014.ui.TempSensors

- New UI that shows all temp sensors

### bl12014.ui.HeightSensor

- New UI panel for the height sensor channel values (possibly will add tiltX, tiltY, avgZ later)

### bl12014.ui.Reticle

- Incorporated `bl12014.ui.Mod3CapSensors`

### bl12014.ui.Wafer

- Incorporated `bl12014.ui.PobCapSensors`
- Incorporated `bl12014.ui.HeightSensor`

### bl12014.ui.App

- New button to launch `bl12014.ui.TempSensors`

### bl12014.device.GetSetNumberFromMicronixMMC103

- New

### bl12014.device.GetSetNumberFromNewFocusModel8742

- New

### bl12014.Connect

- Linked about half of the hardware comm to the UI through the `bl12014.device.*` instances


# 1.0.0-alpha.7

### bl12014.ui.M143

- Build this component and added it to `bl12014.ui.App`


### bl12014.ui.App

- Refactored the list of structures used for the `mic.ui.common.ButtonList` so their order can easily be changed.
- Added button for M143


# 1.0.0-alpha.6

### bl12014.ui.PrescriptionTool

- Now has option to choose the directory the prescriptions are saved to
- Improved layout
- `save()` and `load()` methdos


### bl12014.ui.Scan

- Refactored to use new `mic.ui.Scan` UI for controlling the scan and displaying scan progress
- Now has option to choose the directory of the prescriptions that can be added to the wafer
- Improved layout
- `save()` and `load()` methdos

### bl12014.ui.App

- `save()` and `load()` methdos
- `saveToDisk()` and `loadFromDisk()` methods to persist state of the application across sessions

# 1.0.0-alpha.5

### bl12014.ui.Beamline
- Refactored to use new `mic.ui.Scan` UI for controlling the scan and displaying scan progress
- Now saves scan results and the `recipe.json` and `result.json` files are each saved to their own unique directory that includes a timestamp and identiying information about the scan
- Now saves `result.csv`
- Now properly saves `result.*` files when the scan is aborted

# 1.0.0-alpha.4

### bl12014.ui.Beamline

- New UI class to store the undulator gap, mono grating tilt (or wav through conversion), exit slit, shutter, d142 stage y, and MeasurPoint channel with d142 diode connected.


### bl12014.ui.WaferAxes

- Build crosshairs for the wafer and the chief ray that change thickness on zoom so they can be viewed zoomed out and zoomed in while preserving the field of view that they occupy
- Added support for FEM preview associated with the prescription and a FEM preview associated with the scan.  Each has its own `add()` and `delete()` methods

### bl12014.ui.FemTool

- While `load()` is being evoked, now suppresses `notify` calls during the load process while multiple `mic.ui.common.Edit` are being updated and instead issues one single event at the end.

### bl12014.ui.Beamline renamed to bl12014.ui.App

- Now listens for size changes from `bl12014.ui.FemTool` and updates the FEM preview on `bl12014.ui.WaferAxes`
- Now listens for `eDelete` and `eNew` events from `bl12014.ui.PrescriptionTool` and refreshes the list of available prescriptions in `bl12014.ui.Scan`

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
