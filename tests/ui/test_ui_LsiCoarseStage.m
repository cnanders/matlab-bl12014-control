try 
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));


clock = mic.Clock('Master');
hardware = bl12014.Hardware('clock', clock);


ui = bl12014.ui.LsiCoarseStage(...
    'cName', 'test', ...
    'hardware', hardware, ...
    'clock', clock ...
);

ui2 = bl12014.ui.LsiCoarseStage(...
    'cName', 'test2', ...
    'hardware', hardware, ...
    'clock', clock ...
);

h = figure();
ui.build(h, 10, 10);
ui2.build(h, 10, 100);


 

