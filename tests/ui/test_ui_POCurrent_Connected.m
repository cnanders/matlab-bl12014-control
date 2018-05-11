try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-keithley-6482', 'src')));


cTcpip = '192.168.20.28';
comm = keithley.Keithley6482(...
    'cTcpipHost', cTcpip, ...
    'u16TcpipPort', 4001, ...
    'cConnection', keithley.Keithley6482.cCONNECTION_TCPCLIENT ...
);

clock = mic.Clock('Master');

ui = bl12014.ui.POCurrent(...
    'clock', clock ...
);

ui.build();
ui.connectKeithley6482(comm)


 

