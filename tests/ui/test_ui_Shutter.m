[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirSrc = fullfile(cDirThis, '..', '..', 'src');
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

% src
addpath(genpath(fullfile(cDirSrc)));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-rigol-dg1000z', 'src')));

purge

clock = mic.Clock('Master');

ui = bl12014.ui.Shutter(...
    'clock', clock ...
);

ui.build();




 

