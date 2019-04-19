try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% src
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% mpm dependencies
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));

hardware = bl12014.Hardware();
clock = mic.Clock('Master');
uiClock = mic.ui.Clock(clock);

ui = bl12014.ui.DMIPowerMonitor(...
    'hardware', hardware, ...
    'clock', clock, ...
    'uiClock', uiClock ...
);

dWidth = 400;
dHeight = 100;

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



 

