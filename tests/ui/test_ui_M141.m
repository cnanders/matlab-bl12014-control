try
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));


clock = mic.Clock('Master');

ui = bl12014.ui.M141(...
    'clock', clock ...
);

dWidth = 1000;
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


 

