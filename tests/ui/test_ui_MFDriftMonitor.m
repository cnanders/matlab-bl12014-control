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
% 
% cMode = 'real';
% 
% switch cMode
%     case 'virtual'
%         APIDriftMonitor     = hardware.getMfDriftMonitorMiddlewareVirtual();
%     case 'real'
%         APIDriftMonitor     = hardware.getMfDriftMonitorMiddleware();
%         APIHexapod          = hardware.getLSIHexapod();
% end


% Set the UI device to the drift monitor:
ui = bl12014.ui.MFDriftMonitor('hardware', hardware, ...
                               'clock', clock);


dWidth = 1200;
dHeight = 700;

dScreenSize = get(0, 'ScreenSize');
h = figure(...
    'Position', [ ...
        (dScreenSize(3) - dWidth)/2 ...
        (dScreenSize(4) - dHeight)/2 ...
        dWidth ...
        dHeight ...
    ] ...
);

ui.build(h, 10, 10);


 

