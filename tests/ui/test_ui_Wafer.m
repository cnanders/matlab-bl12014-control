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


clock = mic.Clock('Master');
uiClock = mic.ui.Clock(clock);

hardware = bl12014.Hardware();
hardware.setClock(clock);
waferExposureHistory = bl12014.WaferExposureHistory();
waferExposureHistory.addFakeExposures();

ui = bl12014.ui.Wafer(...
    'clock', clock, ...
    'uiClock', uiClock, ...
    'waferExposureHistory', waferExposureHistory, ...
    'hardware', hardware ...
);

dWidth = 1650;
dHeight = 900;

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



 

