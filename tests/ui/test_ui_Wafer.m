try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));




hardware = bl12014.Hardware();

clock = mic.Clock('Master');

ui = bl12014.ui.Wafer(...
    'clock', clock, ...
    'hardware', hardware ...
);

ui.build();
ui.


 

