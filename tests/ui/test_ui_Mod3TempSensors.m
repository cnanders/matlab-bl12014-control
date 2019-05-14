try
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));



clock = mic.Clock('Master');

ui = bl12014.ui.Mod3TempSensors(...
    'clock', clock ...
);

h = figure()
ui.build(h, 10, 10);


 

