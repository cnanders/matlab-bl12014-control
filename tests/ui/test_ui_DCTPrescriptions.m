try
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));

cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');
cDirJsonLab = fullfile(cDirVendor, 'fileexchange', 'jsonlab-1.2');

purge


dWidth = 1100;
dHeight = 720;

dScreenSize = get(0, 'ScreenSize');
h = figure(...
    'Position', [ ...
        (dScreenSize(3) - dWidth)/2 ...
        (dScreenSize(4) - dHeight)/2 ...
        dWidth ...
        dHeight ...
    ] ...
);

ui = bl12014.ui.DCTPrescriptions();
ui.build(h, 10, 10);