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
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-newfocus-model-8742', 'src')));


cTcpip = '192.168.20.31';
comm = newfocus.Model8742( ...
    'cTcpipHost', cTcpip ...
);
comm.init();
comm.connect();

clock = mic.Clock('Master');

ui = bl12014.ui.MADiagnostics(...
    'clock', clock ...
);

ui.build();
ui.connectNewFocusModel8742(comm)


 

