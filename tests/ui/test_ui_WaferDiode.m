try 
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));


purge

clock = mic.Clock('Master');
hardware = bl12014.Hardware('clock', clock);


ui = bl12014.ui.WaferDiode(...
    'hardware', hardware, ...
    'clock', clock ...
);

h = figure();
ui.build(h, 10, 10);


 

