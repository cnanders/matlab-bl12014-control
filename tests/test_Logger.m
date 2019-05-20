try
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));


clock = mic.Clock('Master');
hardware = bl12014.Hardware('clock', clock);

hardware.connectDataTranslation(); % force real hardware
hardware.connectMfDriftMonitor(); % force real hardware

logger = bl12014.Logger(...
    'hardware', hardware, ...
    'clock', clock ...
);