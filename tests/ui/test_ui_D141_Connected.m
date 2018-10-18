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

ui = bl12014.ui.D141(...
    'clock', clock ...
);

ui.build();


cTransport = 'tcpip';
cAddress = '192.168.10.26';
m = modbus(cTransport, cAddress, ...
    'Timeout', 5 ...
);
ui.connectWago(m);


 

