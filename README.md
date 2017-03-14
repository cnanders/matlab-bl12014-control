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

- [github/cnanders/matlab-instrument-control](https://github.com/cnanders/matlab-instrument-control) (for the UI)
- [github/cnanders/matlab-npoint-lc400](https://github.com/cnanders/matlab-npoint-lc400) (for MATLAB USB serial communication with nPoint LC.400 controller)

<a name="project-structure"></a>
# Project Structure

- project
	- vendor
		- github
			- cnanders
                - matlab-scanner-control-npoint **(dependency)**
                - matlab-instrument-control **(dependency)**
                - matlab-npoint-lc400 **(dependency)**	
				- matlab-ieee **(dependency of matlab-npoint-lc400)**
				- matlab-hex **(dependency of matlab-ieee)**
	- src
        - +bl12014
            - +ui
            - +interface
            - +mic-device
    - tests
    - docs
    - README.md
    - CHANGELOG.md