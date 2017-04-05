[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));

purge

clock = mic.Clock('master');

uiReticle = bl12014.ui.Reticle('clock', clock);
uiWafer = bl12014.ui.Wafer('clock', clock);
uiShutter = bl12014.ui.Shutter('clock', clock);
            

ui = bl12014.ui.Scan(...
    'clock', clock, ...
    'uiShutter', uiShutter, ...
    'uiReticle', uiReticle, ...
    'uiWafer', uiWafer ...
);
ui.build();

%{
cb = @(src, evt) (fprintf('x %1.3f, y %1.3f \n', evt.stData.dX, evt.stData.dY));
addlistener(ui, 'eClickField', cb);
%}


 

