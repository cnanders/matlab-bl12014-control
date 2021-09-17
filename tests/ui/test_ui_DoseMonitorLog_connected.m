try 
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));


clock = mic.Clock('master');
hardware = bl12014.Hardware('clock', clock);
hardware.connectDoseMonitor();
hardware.connectSR570MDM();


ui = bl12014.ui.DoseMonitorLog(...
    'hardware', hardware ...
);

dWidth = 500;
dHeight = 500;
dScreenSize = get(0, 'ScreenSize');
h = figure(...
    'Position', [ ...
        (dScreenSize(3) - dWidth)/2 ...
        (dScreenSize(4) - dHeight)/2 ...
        dWidth ...
        dHeight ...
    ] ...
);



ui.build(h, 10, 10, 300, 300);
ui.appendLatest();
 
