[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');
cDirSrc = fullfile(cDirApp, 'src');
cDirVendor = fullfile(cDirApp, 'vendor');

% src
addpath(genpath(cDirSrc));

% dependencies
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-mightex-led-controller', 'src')));

purge

import bl12014.device.GetSetNumberFromMightexUniversalLedController

comm = mightex.UniversalLedController(...
    'u8DeviceIndex', 0 ...
);
comm.init();


device = GetSetNumberFromMightexUniversalLedController(...
    comm, ...
    1 ...
);
device.get()

device.set(300)
device.get()

comm.delete();
