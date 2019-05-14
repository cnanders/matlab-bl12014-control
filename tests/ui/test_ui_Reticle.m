try 
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));


clock = mic.Clock('Master');
uiClock = mic.ui.Clock(clock);
hardware = bl12014.Hardware('clock', clock);



ui = bl12014.ui.Reticle(...
    'hardware', hardware, ...
    'clock', clock, ...
    'uiClock', uiClock ...
);

dWidth = 1650;
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
 

