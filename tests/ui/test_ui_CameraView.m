try
    purge
end


[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));



ui = bl12014.ui.CameraView('test');
ui.build();
