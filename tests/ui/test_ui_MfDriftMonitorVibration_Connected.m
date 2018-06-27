try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');


addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'cnanderson')));



% MET5 devices built by Carl Cork
javaaddpath(fullfile(cDirVendor, 'cwcork', 'Met5Instruments.jar'));
cDirMet5InstrumentsConfig = fullfile(cDirVendor, 'cwcork');

jMet5Instruments = cxro.met5.Instruments(cDirMet5InstrumentsConfig);
commMfDriftMonitor = jMet5Instruments.getMfDriftMonitor();
commMfDriftMonitor.connect();

clock = mic.Clock('Master');

ui = bl12014.ui.MfDriftMonitorVibration(...
    'clock', clock ...
);

ui.connectMfDriftMonitor(commMfDriftMonitor);
ui.build();
 

