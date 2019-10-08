try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));



clock = mic.Clock('Master');
hardware = bl12014.Hardware('clock', clock);

if ~contains(cDirThis, 'cnanderson') && ...
   ~contains(cDirThis, 'ryanmiyakawa')

    hardware.connectWebSwitchVis(); % force real hardware (connects WebSwitch VIS, turns on power to relay1 - VIS Galil)
    hardware.connectGalilVis(); % connects to VIS galil

end


ui = bl12014.ui.VibrationIsolationSystem(...
    'hardware', hardware, ...
    'uiClock', clock, ...
    'clock', clock ...
);

dWidth = 1200;
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

ui.build(h, 10, 10);
