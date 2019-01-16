try
    purge
end


[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

% Java SSH2 Communication With DeltaTau Power PMAC Motion Controller (uses JSch)
% needed by github/cnanders/matlab-deltatau-ppmac-met5
javaaddpath(fullfile(cDirVendor, 'cnanderson', 'deltatau-power-pmac-comm-jre1.7.jar'));

addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-deltatau-ppmac-met5', 'src')));

cTcpipDeltaTau = '192.168.20.23';
commDeltaTauPowerPmac = deltatau.PowerPmac(...
    'cHostname', cTcpipDeltaTau ...
);
commDeltaTauPowerPmac.init();


clock = mic.Clock('Master');

ui = bl12014.ui.PowerPmacHydraMotMin(...
    'clock', clock ...
);


dWidth = 1100;
dHeight = 800;

dScreenSize = get(0, 'ScreenSize');
h = figure(...
    'Position', [ ...
        (dScreenSize(3) - dWidth)/2 ...
        (dScreenSize(4) - dHeight)/2 ...
        dWidth ...
        dHeight ...
    ] ...
);

ui.build(h, 10, 10);
ui.connectDeltaTauPowerPmac(commDeltaTauPowerPmac)



 

