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

% dependency (jar/jdk7/MET5Instruments.jar)
cPathJar = fullfile(...
    cDirApp, ...
    'jar', ...
    'jdk7', ...
    'Sins2Instruments.jar' ...
);
javaaddpath(cPathJar);


purge

jMet5Instruments = cxro.met5.Instruments();
jM141Stage = jMet5Instruments.getM141Stage();
            
deviceGetSetNumber = bl12014.device.GetSetNumberFromStage(jM141Stage, uint8(1));
deviceGetSetNumber.get()
 

