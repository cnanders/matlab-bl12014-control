[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');
cDirSrc = fullfile(cDirApp, 'src');
cDirVendor = fullfile(cDirApp, 'vendor');

% src
addpath(genpath(cDirSrc));

% dependency (github/cnanders/matlab-instrument-control)
cDirMic = fullfile(...
    cDirVendor, ...
    'github', ...
    'cnanders', ...
    'matlab-instrument-control', ...
    'src' ...
);
addpath(genpath(cDirMic));

% dependency
cPathJar = fullfile(...
    cDirVendor, ...
    'cwcork', ...
    'bl1201', ...
    'jar_jdk6', ...
    'BL1201CorbaProxy.jar' ...
);
javaaddpath(cPathJar);

purge

jBL1201CorbaProxy = cxro.bl1201.beamline.BL1201CorbaProxy();
            
device = bl12014.device.GetSetNumberFromBL1201CorbaProxy(...
    jBL1201CorbaProxy, ...
    bl12014.device.GetSetNumberFromBL1201CorbaProxy.cDEVICE_UNDULATOR_GAP ...
);

device.get()
% device.isReady()
 

