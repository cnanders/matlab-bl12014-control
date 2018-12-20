purge

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

% cnanders/matlab-instrument-control
cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));


hDYMO = bl12014.hardwareAssets.middleware.DymoLabelWriter450();



%% test print label

hDYMO.printLabel();



%% Test updating a field

hDYMO.setField('cPrescription', 'manny');

hDYMO.printLabel();