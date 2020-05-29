try 
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));

clock = mic.Clock('Master');
hardware = bl12014.Hardware('clock', clock);

exposures = bl12014.DCTExposures();
exposures.addFakeExposures();
exposures.addFakePre();
exposures.addFakeScan();

ui = bl12014.ui.DCTStages(...
    'uiClock', clock, ...
    'hardware', hardware, ...
    'exposures', exposures ...
);

uiAxes = bl12014.ui.DCTWaferAxes(...
    'clock', clock, ...
    'hardware', hardware, ...
    'exposures', exposures ...
);

dWidth = 1400;
dHeight = 800;

dScreenSize = get(0, 'ScreenSize');
            
h = figure( ...
    'Position', [ ...
        (dScreenSize(3) - dWidth)/2 ...
        (dScreenSize(4) - dHeight)/2 ...
        dWidth ...
        dHeight ...
     ] ...
);
uiAxes.build(h, 10, 10);
ui.build(h, uiAxes.dWidth + 30, 100);

 

