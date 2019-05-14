try
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));



% fileexchange/jsonlib
cDirJsonLab = fullfile(cDirVendor, 'fileexchange', 'jsonlab-1.2');
addpath(genpath(cDirMic));

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

ui = bl12014.ui.PrescriptionTool();
ui.build(h, 100, 100);