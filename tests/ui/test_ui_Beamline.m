try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');

% src
cDirBl12014 = fullfile(cDirApp, 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirApp, 'vendor');

cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));


clock = mic.Clock('Master');
hardware = bl12014.Hardware();
uiClock = mic.ui.Clock(clock);

ui = bl12014.ui.Beamline(...
    'hardware', hardware, ...
    'uiClock', uiClock, ...
    'clock', clock ...
);


dWidth = 1900;
dHeight = 1000;
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


 

