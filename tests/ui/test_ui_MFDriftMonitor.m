purge

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));


cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');
cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));

clock = mic.Clock('Master');


% Normally will import this API from hardware class
hardware = bl12014.Hardware();

cMode = 'real';

switch cMode
    case 'virtual'
        APIDriftMonitor     = hardware.getMFDriftMonitorVirtual();
    case 'real'
        APIDriftMonitor     = hardware.getMFDriftMonitor();
        APIHexapod          = hardware.getLSIHexapod();
end


% Set the UI device to the drift monitor:
ui = bl12014.ui.MFDriftMonitor('hardware', hardware, ...
                               'clock', clock);


ui.build( 10, 10);


 

