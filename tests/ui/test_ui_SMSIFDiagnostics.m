try 
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));


clock = mic.Clock('Master');
hardware = bl12014.Hardware('clock', clock);


ui = bl12014.ui.SMSIFDiagnostics(...
    'hardware', hardware, ...
    'clock', clock ...
);


dWidth = 800;
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

ui.build(h, 100, 100);

 

