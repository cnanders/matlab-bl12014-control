[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

cDirMic = fullfile(cDirVendor, ...
    'github', ...
    'cnanders', ...
    'matlab-instrument-control', ...
    'src'...
);
addpath(genpath(cDirMic));

purge

ui = bl12014.ui.App(...
    'cTitleButtonList', 'UI', ...
    'dWidthButtonButtonList', 200 ...
);
h = figure(...
    'Position', [50 50 300 700] ... % left bottom width height
);
ui.build(h, 10, 10);

%{
cb = @(src, evt) (fprintf('x %1.3f, y %1.3f \n', evt.stData.dX, evt.stData.dY));
addlistener(ui, 'eClickField', cb);
%}


 

