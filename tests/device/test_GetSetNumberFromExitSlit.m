[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');
cDirSrc = fullfile(cDirApp, 'src');
cDirVendor = fullfile(cDirApp, 'vendor');

% src
addpath(genpath(cDirSrc));

% dependency (github/cnanders/matlab-instrument-control)
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));

% dependency (naulleau exit slit) 
addpath(genpath(fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v2')));
javaaddpath(fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v2', 'BL12PICOCorbaProxy.jar'));

purge

[comm, e] = bl12pico_attach();
device = bl12014.device.GetSetNumberFromExitSlit(comm);
device.get()

