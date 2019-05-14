try 
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));


clock = mic.Clock('Master');
hardware = bl12014.Hardware('clock', clock);


ui = bl12014.ui.ReticleFineStage(...
    'hardware', hardware, ...
    'clock', clock ...
);

h = figure();
ui.build(h, 10, 10);


 

