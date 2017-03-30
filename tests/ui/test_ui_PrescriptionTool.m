[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

% cnanders/matlab-instrument-control
cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));

% fileexchange/jsonlib
cDirJsonLab = fullfile(cDirVendor, 'fileexchange', 'jsonlab-1.2');
addpath(genpath(cDirMic));

purge

ui = bl12014.ui.PrescriptionTool();
ui.build();