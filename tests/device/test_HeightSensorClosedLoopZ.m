[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));


purge

clock = mic.Clock('Master');


zWafer = mic.device.GetSetNumber(...
    'clock', clock, ...
    'cName', 'height-sensor-closed-loop-z-wafer' ...
);
zHeightSensor = mic.device.GetSetNumber(...
    'clock', clock, ...
    'cName', 'height-sensor-closed-loop-z-height-sensor' ...
);

device = bl12014.device.HeightSensorClosedLoopZ(...
    clock, ...
    zWafer, ...
    zHeightSensor, ...
    'u8MovesMax', uint8(10) ...
);

device.get()
device.set(10);
device.get()
