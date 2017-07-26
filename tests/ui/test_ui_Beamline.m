[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');

% src
cDirBl12014 = fullfile(cDirApp, 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirApp, 'vendor');

cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));


purge

clock = mic.Clock('Master');

ui = bl12014.ui.Beamline(...
    'clock', clock ...
);

ui.build();


 

