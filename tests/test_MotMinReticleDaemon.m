try
    purge
end


[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

addpath(genpath(fullfile(cDirThis, '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', 'mpm-packages')));

clock = mic.Clock('Master');
hardware = bl12014.Hardware('clock', clock);

daemon = bl12014.MotMinReticleDaemon(...
    'hardware', hardware, ...
    'clock', clock ...
);

hardware.getDeltaTauPowerPmac().setMotMinReticleCoarseX(4);
hardware.getDeltaTauPowerPmac().setMotMinReticleCoarseY(4);