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



ui = bl12014.ui.Scanner(...
    'fhGetNPoint', @() hardware.getNPointMA(), ...
    'cName', 'ma', ...
    'uiClock', uiClock, ...
    'clock', clock ...
);

dWidth = 1650;
dHeight = 800;

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


% ui.setStarredIlluminationByName('1Pole_off0_rot90_min35_max55_num3_dwell2_xoff0_yoff0_per100_filthz400_dt24.mat');



 

