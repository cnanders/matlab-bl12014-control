[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');
cDirSrc = fullfile(cDirApp, 'src');
cDirVendor = fullfile(cDirApp, 'vendor');

% src
addpath(genpath(cDirSrc));

% dependency (github/cnanders/matlab-instrument-control)
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));

% dependency (naulleau exit slit) 
addpath(genpath(fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v3')));
javaaddpath(fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v3', 'BL12PICOCorbaProxy.jar'));

purge

comm = bl12pico_slits;

[e,estr] = comm.checkServer();
if e
    error('Problem attaching to pico server');
end

device = bl12014.device.GetSetNumberFromExitSlitObject(comm);
device.get()

