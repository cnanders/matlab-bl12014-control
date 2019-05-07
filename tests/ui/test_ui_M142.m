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
hardware = bl12014.Hardware();
hardware.setClock(clock);

ui = bl12014.ui.M142(...
    'hardware', hardware, ...
    'clock', clock ...
);

h = figure(); 
ui.build(h, 10, 10);


 

