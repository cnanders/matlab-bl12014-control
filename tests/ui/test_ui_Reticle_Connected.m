try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));


% Java SSH2 Communication With DeltaTau Power PMAC Motion Controller (uses JSch)
% needed by github/cnanders/matlab-deltatau-ppmac-met5
javaaddpath(fullfile(cDirVendor, 'cnanderson', 'deltatau-power-pmac-comm-jre1.7.jar'));

addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-deltatau-ppmac-met5', 'src')));

% hardware = bl12014.Hardware();

cTcpipDeltaTau = '192.168.20.23';
commDeltaTauPowerPmac = deltatau.PowerPmac(...
    'cHostname', cTcpipDeltaTau ...
);
commDeltaTauPowerPmac.init();


clock = mic.Clock('Master');

ui = bl12014.ui.Reticle(...
    'clock', clock ...
);

ui.build();
ui.connectDeltaTauPowerPmac(commDeltaTauPowerPmac)


 

