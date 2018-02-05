purge

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');
cDirMet5InstrumentsConfig = fullfile(cDirVendor, 'cwcork');

cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));

% Add lsipath:
cDirLSI = fullfile(cDirVendor, 'github', 'ryanmiyakawa', 'LSI-control');
addpath(genpath(cDirLSI));


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
cMode = 'real';

switch cMode
    case 'virtual'
        APIDriftMonitor     = bl12014.hardware.VirtualMFDriftMonitor('clock', clock);
    case 'real'
        
        % Grab api for drift monitor
        jMet5Instruments    = cxro.met5.Instruments(cDirMet5InstrumentsConfig);
        CWCDriftMonitorAPI  = jMet5Instruments.getMfDriftMonitor();
        
        APIDriftMonitor     = bl12014.hardware.MFDriftMonitor(...
                            'javaAPI', CWCDriftMonitorAPI, ...
                            'clock', clock);
        
        % Grab api for hexapod
        CWCHexapodAPI = jMet5Instruments.getLsiHexapod();
        APIHexapod =  lsicontrol.javaAPI.CXROJavaStageAPI(...
                                  'jStage', CWCHexapodAPI);
end


% Set the UI device to the drift monitor:
ui = bl12014.ui.MFDriftMonitor('apiDriftMonitor', APIDriftMonitor,...
                                'apiHexapod', APIHexapod, ...
                                'clock', clock);


ui.build( 10, 10);


 

