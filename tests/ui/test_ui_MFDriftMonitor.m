[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));


purge


clock = mic.Clock('Master');


% Get JAVA drift monitor from MET5Instrumenbts and connect

% UI has a uiComm button (connect/disconnect/status).  This button
% needs to have its "device" set to: gslcCommMFDriftMonitor, a dumb
% inline device (that has has three functions:
% fhGet: returns the existence of the Drift Monitor JAVA device
% fhSetTrue: What to do on connect
% fhSetFalse: what to do on disconnect

% We won't bother with that here, just



% Normally will import this API from hardware class
cMode = 'virtual';

switch cMode
    case 'virtual'
        APIDriftMonitor     = bl12014.hardware.VirtualMFDriftMonitor(clock);
    case 'real'
        jMet5Instruments    = cxro.met5.Instruments(this.cDirMet5InstrumentsConfig);
        CWCDriftMonitorAPI  = this.jMet5Instruments.getMfDriftMonitor();
        
        APIDriftMonitor     = bl12014.hardware.MFDriftMonitor(CWDriftMonitorAPI, clock);
        API
        
end


% Set the UI device to the drift monitor:
ui = bl12014.ui.MFDriftMonitor('apiDriftMonitor', APIDriftMonitor, 'clock', clock);



ui.build( 10, 10);


 

