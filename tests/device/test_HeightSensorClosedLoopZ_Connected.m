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
    'cHostname', this.cTcpipDeltaTau ...
);
commDeltaTauPowerPmac.init();
zWafer = GetSetNumberFromDeltaTauPowerPmac(...
    commDeltaTauPowerPmac, ...
    GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_FINE_Z ...
);

%% zHeightSensor from MfDriftMonitor and Ryan

jMet5Instruments = cxro.met5.Instruments(this.cDirMet5InstrumentsConfig);
commMFDriftMonitor = jMet5Instruments.getMfDriftMonitor();
commMFDriftMonitor.connect();
zHeightSensor = %TBD from Ryan


%% device

device = bl12014.device.HeightSensorClosedLoopZ(...
    clock, ...
    zWafer, ...
    zHeightSensor, ...
    'u8MovesMax', uint8(10) ...
);

device.get()
device.set(10);
device.get()
