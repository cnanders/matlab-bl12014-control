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
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-rigol-dg1000z', 'src')));

hardware = bl12014.Hardware();
waferExposureHistory = bl12014.WaferExposureHistory();
waferExposureHistory.addFakeExposures();

%{
cTcpipDeltaTau = '192.168.20.23';
commDeltaTauPowerPmac = deltatau.PowerPmac(...
    'cHostname', cTcpipDeltaTau ...
);
commDeltaTauPowerPmac.init();
%}

clock = mic.Clock('Master');
uiClock = mic.ui.Clock(clock);

ui = bl12014.ui.Wafer(...
    'clock', clock, ...
    'uiClock', uiClock, ...
    'waferExposureHistory', waferExposureHistory, ...
    'hardware', hardware ...
);

dWidth = 1650;
dHeight = 900;

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


 

