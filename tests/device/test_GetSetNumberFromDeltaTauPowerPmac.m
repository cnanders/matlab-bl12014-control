[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');
cDirSrc = fullfile(cDirApp, 'src');
cDirVendor = fullfile(cDirApp, 'vendor');

% src
addpath(genpath(cDirSrc));

% dependencies
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-deltatau-ppmac-met5', 'src')));
javaaddpath(fullfile(cDirVendor, 'cnanderson', 'deltatau-power-pmac-comm-jre1.7.jar'));

purge

import bl12014.device.GetSetNumberFromDeltaTauPowerPmac

comm = deltatau.PowerPmac(...
    'cHostname', '192.168.20.23' ...
);
comm.init();
comm.getReticleCoarseX()

%%
deviceWaferCoarseX = GetSetNumberFromDeltaTauPowerPmac(...
    comm, ...
    GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_X...
);
deviceWaferCoarseX.get()

%%
deviceWaferCoarseY = GetSetNumberFromDeltaTauPowerPmac(...
    comm, ...
    GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_Y...
);
deviceWaferCoarseY.get()

%%
deviceReticleCoarseX = GetSetNumberFromDeltaTauPowerPmac(...
    comm, ...
    GetSetNumberFromDeltaTauPowerPmac.cAXIS_RETICLE_COARSE_X...
);
deviceReticleCoarseX.get()

comm.delete();
