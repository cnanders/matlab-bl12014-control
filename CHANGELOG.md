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

In addition, it will have interface for setting up a 1D scan, similar to NUS software.  It will have min / max values for wavelength, settle delay, all of the stuff that NUS scan had (possibly elapsed time, etc).  Might be worth refactoring some of the time info / prediction into the mic.StateScan class since it is useful any time there is a scan.  Will need to show the plot, allow clicking to set zero.  

-->

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