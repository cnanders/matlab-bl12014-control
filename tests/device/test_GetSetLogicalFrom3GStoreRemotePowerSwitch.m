[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');
cDirSrc = fullfile(cDirApp, 'src');
cDirVendor = fullfile(cDirApp, 'vendor');

% src
addpath(genpath(fullfile(cDirSrc)));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-3gstore-remote-power-switch', 'src')));

cHost = '192.168.10.30';

comm = threegstore.RemotePowerSwitch(...
    'cHost', cHost ...
);
device = bl12014.device.GetSetLogicalFrom3GStoreRemotePowerSwitch(comm, 1);
device.get()
device.set(true);
device.get()
device.set(false);
device.get()


