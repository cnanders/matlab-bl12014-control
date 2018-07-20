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

try
    addpath(genpath(fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v3')));
    javaaddpath(fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v3', 'BL12PICOCorbaProxy.jar'));
end

clock = mic.Clock('Master');

ui = bl12014.ui.ExitSlit(...
    'clock', clock ...
);

ui.build();


commExitSlit = bl12pico_slits;
[e,estr] = commExitSlit.checkServer();
if e
    commExitSlit = [];
    error('Problem attaching to pico server');
    return;
end

ui.connectExitSlit(commExitSlit);

