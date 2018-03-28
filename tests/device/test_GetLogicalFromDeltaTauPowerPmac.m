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

comm = deltatau.PowerPmac(...
    'cHostname', '192.168.20.23' ...
);
comm.init();
comm.getAtWaferTransferPosition()
comm.getAtReticleTransferPosition()
comm.getWaferPositionLocked()
comm.getReticlePositionLocked()


device = bl12014.device.GetLogicalFromDeltaTauPowerPmac(...
    comm, ...
    bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_AT_RETICLE_TRANSFER_POSITION ...
);
device.get()

%{
device = bl12014.device.GetLogicalFromDeltaTauPowerPmac(...
    comm, ...
    bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_RETICLE_CAP_2 ...
);
device.get()

device = bl12014.device.GetLogicalFromDeltaTauPowerPmac(...
    comm, ...
    bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_RETICLE_CAP_3 ...
);
device.get()

device = bl12014.device.GetLogicalFromDeltaTauPowerPmac(...
    comm, ...
    bl12014.device.GetLogicalFromDeltaTauPowerPmac.cTYPE_RETICLE_CAP_4 ...
);
device.get()
%}