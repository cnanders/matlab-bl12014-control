# About

MATLAB UI for controlling beamline 12.0.1.4 of the [Advanced Light Source]() at [Lawrence Berkeley National Laboratory]()

# Installation

1. Clone this repo and the repos of all [dependencies](#dependencies) into the MATLAB “vendor” directory as shown in [Project Structure](#project-structure)

2. Add this library and all dependencies to the MATLAB path, e.g., 

```matlab
addpath(genpath('vendor/github/cnanders/matlab-instrument-control/src'));
addpath(genpath('vendor/github/cnanders/matlab-npoint-lc400/src'));
addpath(genpath('vendor/github/cnanders/matlab-scanner-control-npoint'));
addpath(genpath('vendor/github/cnanders/matlab-ieee/src'));
addpath(genpath('vendor/github/cnanders/matlab-hex/src'));

```

<a name="dependencies"></a>
## Dependencies

- [https://github.com/awojdyla/matlab-datatranslation-measurpoint](https://github.com/awojdyla/matlab-datatranslation-measurpoint)
- [https://github.com/cnanders/matlab-keithley-6482](https://github.com/cnanders/matlab-keithley-6482)
- [https://github.com/cnanders/matlab-scanner-control-npoint](https://github.com/cnanders/matlab-scanner-control-npoint)
- [https://github.com/cnanders/matlab-micronix-mmc-103](https://github.com/cnanders/matlab-micronix-mmc-103)
- [https://github.com/cnanders/matlab-newfocus-model-8742](https://github.com/cnanders/matlab-newfocus-model-8742)
- [https://github.com/cnanders/matlab-instrument-control](https://github.com/cnanders/matlab-instrument-control) (for the UI)
- [https://github.com/cnanders/matlab-npoint-lc400](https://github.com/cnanders/matlab-npoint-lc400) (for MATLAB USB serial communication with nPoint LC.400 controller)
- [JSONlab](https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files)

<a name="project-structure"></a>
# Project Structure

- project/
	- vendor/
		- github/
			- cnanders/
                - matlab-scanner-control-npoint/ **(dependency)**
                - matlab-instrument-control/ **(dependency)**
                - matlab-npoint-lc400/ **(dependency)**	
				- matlab-ieee/ **(dependency of matlab-npoint-lc400)**
				- matlab-hex/ **(dependency of matlab-ieee)**
	- src/
        - +bl12014/
            - +ui/
            - +interface/
            - +mic-device/
    - tests/
    - docs/
    - README.md
    - CHANGELOG.md



# STOP READING HERE.  RANDOM BRAINSTORMING BELOW

# Thoughts / Philosophy on Project Structure

There are two ways the UI can be connected to real hardware.  

## Option A

- +bl12014/
  - +ui/
    - Reticle.m
    - Wafer.m
    - M141.m
  - Reticle.m
  - Wafer.m
  - M141.m

The idea here would be that `bl12014.Reticle` is a container that connects a piece of harware to a UI, e.g.:

```matlab
properties

  % {bl12014.ui.Reticle 1x1}
  uiReticle

  % {deltatau.pmac.Pmac 1x1}
  deltaTauPmac

  % {< mic.interface.device.GetSetNumber 1x1}
  deviceGetSetNumberCoarseX

  % {< mic.interface.device.GetSetNumber 1x1}
  deviceGetSetNumberCoarseY

end

methods
  initHardware(this)
    this.deltaTauPmac = deltatau.pmac.Pmac(); 
  end

  % Initialize mic devices to be given to UI
  initDevices(this)
    this.deviceGetSetNumberCoarseX = bl12014.device.PmacToGetSetNumber(this.deltaTauPmac, 'reticle-coarse-x');
    this.deviceGetSetNumberCoarseY = bl12014.device.PmacToGetSetNumber(this.deltaTauPmac, 'reticle-coarse-y');
  end
end
```

This organization has the benefit that `bl12014.Reticle`, `bl12014.Wafer`, and `bl12014.M141` can be instantiated independently, if desired.  The downside is that in the case of the reticle and wafer, for example, which are both controlled through the same COM interface to the Delta Tau, only one instance of `deltatau.pmac.Pmac` should be allowed to exist at any given time.  Instantiating `bl12014.Reticle` and `bl12014.Wafer`, if each were fully encapsulated would create two instances of `deltatau.pmac.Pmac`.

Another option would be to pass a single instance of `deltatau.pmac.Pmac` into `bl12014.Reticle` and `bl12014.Wafer` when each is created.  This requires a higher-level Container above them that holds the reference to `deltatau.pmac.Pmac`.  The top-level Container could hold references to all hardware COM instances so there is only ever one instance of each COM class

The top-level Container could contain a UI for building each possible COM and also UI for showing the UI of each low-level component.  The upside of this approach is that it enables hardware COM to be brought on independently and allows each Container to have a unit test.  I almost like the idea of adopting the term container and putting all of the containers in a +container namespace.

Containers are passed instances of hardware COM, build `devices`, and call `setDevice()` on all `mic.ui.device.*` UI controls

But there still needs to be one place where all UI can talk to each other, right?  Scan works by programatically controlling UI.

Maybe containers are passed a UI instance and a hardware and their job is to deal with creating devices from the hardware.  If this were the case, then there can still be a big uiApp that has the UI for everything.
bl12014.App would create all hardwareCOM instances

### E.g. bl12014.container.Reticle

```matlab
properties (Access = private)

  % {bl12014.ui.Reticle 1x1}
  ui

  % {deltatau.pmac.Pmac 1x1}
  deltaTauPmac

  % {< mic.interface.device.GetSetNumber 1x1}
  deviceGetSetNumberCoarseX

  % {< mic.interface.device.GetSetNumber 1x1}
  deviceGetSetNumberCoarseY
end


methods
  function this = Reticle(ui, deltaTauPmac)
    this.ui = ui;
    this.deltaTauPmac = deltaTauPmac
  end

  function connect(this)
    this.deviceGetSetNumberCoarseX = bl12014.device.PmacToGetSetNumber(this.deltaTauPmac, 'reticle-coarse-x');
    this.deviceGetSetNumberCoarseY = bl12014.device.PmacToGetSetNumber(this.deltaTauPmac, 'reticle-coarse-y');

    this.ui.uiCoarseStage.uiX.setDevice(this.deviceGetSetNumberCoarseX);
    this.ui.uiCoarseStage.uiY.setDevice(this.deviceGetSetNumberCoarseY);

  end
end

```

Then the top-level class would look like

```matlab
properties

end

methods
  function initContainers(this)
    this.containerReticle = bl12014.container.Reticle(this.uiApp.uiReticle, this.deltaTauPmac);
    this.containerWafer = bl12014.container.Wafer(this.uiApp.uiWafer, this.deltaTauPmac);

  end

  // There would be buttons that call the connect() method 
end


```

Need to be able to test each UI connnected to real hardware independently.  This container paradigm is the way to do it.

Can imagine the top-level UI having something like a COM button for every available COM

CommDeltaTau
CommDataTrans
CommKeithley

as these are initialized, then the option to connect various UIs becomes available?  Behind the scenes, this is the abilit to build a container for a specific UI.  Certain UIs may require multiple COM to be enabled before they can be connected.

I have decided we definitely need the container layer no matter what.  The option is at the top-level do we want to try and encapsulate creation of each container.  For example if one Comm system is down, makes sense that the entire thing wouldn't crash.  Probably want this. Maybe each UI can list the COMMs that it requires.

Another option is that as each CommDeltaTau is enabled, all devices it supplies are created and all of the UI that use those devices have setDevice() called? Maybe each Container connects a specic piece COMM to a specific piece of hardware? and when that com is initialized, all Containers.  Then they should be called connectors and do they need to be classes?  Seems more like they can be functions.  Possibly this is the way to go

I think there are only two places we need these functions - in App and in tests.  connectUiReticleToCommDeltaTau(uiReticle, deltaTauPmac)
connectUiWaferToCommDeltaTau(uiWafer, deltaTauPmac)
I like this!


Then a test builds all required Comm instances, calls the connector functions, and builds the UI.

