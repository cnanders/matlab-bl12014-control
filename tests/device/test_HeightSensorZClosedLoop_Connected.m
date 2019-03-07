[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));

purge

%% Clock

clock = mic.Clock('Master');


%% zWafer from DeltaTauPowerPmac

import bl12014.device.GetSetNumberFromDeltaTauPowerPmac

cTcpipDeltaTau = '192.168.20.23';
commDeltaTauPowerPmac = deltatau.PowerPmac(...
    'cHostname', cTcpipDeltaTau ...
);
commDeltaTauPowerPmac.init();
zWafer = GetSetNumberFromDeltaTauPowerPmac(...
    commDeltaTauPowerPmac, ...
    GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_FINE_Z ...
);

%% zHeightSensor from MfDriftMonitor and Ryan

% Hardware is exposed in the main app
hardware = bl12014.Hardware();
apiDriftMonitor = hardware.getMfDriftMonitorMiddleware();

% Instantiate a HS device accessor:
zHeightSensor = bl12014.device.GetNumberFromSimpleHeightSensorZ(apiDriftMonitor);

% You can set the number of samples to average:
zHeightSensor.setSampleAverage(50);

%% device

device = bl12014.device.HeightSensorZClosedLoop(...
    clock, ...
    zWafer, ...
    zHeightSensor, ...
    'cName', 'device-height-sensor-z-closed-loop', ...
    'u8MovesMax', uint8(10) ...
);

device.get()
% device.set(10);
% device.get()
