[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

cDirMic = fullfile(...
    cDirVendor, ...
    'github', ...
    'cnanders', ...
    'matlab-instrument-control', ...
    'src' ...
);
addpath(genpath(cDirMic));


purge

device = bl12014.device.ShutterVirtual();

 

