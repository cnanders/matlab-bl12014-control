[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');
cDirSrc = fullfile(cDirApp, 'src');
cDirVendor = fullfile(cDirApp, 'vendor');

% src
addpath(genpath(fullfile(cDirSrc)));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));

cTransport = 'tcpip';
cAddress = '192.168.10.26';

m = modbus(cTransport, cAddress, ...
    'Timeout', 5 ...
);
   
device = bl12014.device.GetSetLogicalFromWagoIO750(m, 'd141');
device.get()
% device.set(false);


