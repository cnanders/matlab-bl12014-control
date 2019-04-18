try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 src
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% mpm dependencies
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));

clock = mic.Clock('Master');
uiClock = mic.ui.Clock(clock);

ui = bl12014.ui.Scanner(...
    'cName', 'ma', ...
    'uiClock', uiClock, ...
    'clock', clock ...
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


% ui.setStarredIlluminationByName('1Pole_off0_rot90_min35_max55_num3_dwell2_xoff0_yoff0_per100_filthz400_dt24.mat');



 

