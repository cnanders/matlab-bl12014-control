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


clock = mic.Clock('Master');

ui = bl12014.ui.FocusLog(...
    'uiClock', clock, ...
    'dWidth', 400, ...
    'dHeight', 400, ...
    'dNumResults', 30 ...
);
h = figure();
ui.build(h, 10, 10);


 

