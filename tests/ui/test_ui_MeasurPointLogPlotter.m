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

ui = bl12014.ui.MeasurPointLogPlotter();


dWidth = 1650;
dHeight = 900;


dScreenSize = get(0, 'ScreenSize');
h = figure(...
    'Position', [ ...
        (dScreenSize(3) - dWidth)/2 ...
        (dScreenSize(4) - dHeight)/2 ...
        dWidth ...
        dHeight ...
    ] ...
);

ui.build(h, 10, 10);


 

% ui.setFile('C:\Users\metmatlab\Documents\MATLAB\matlab-bl12014-control\src\save\fem-scans\20180524-131704__PRE_20180524-131505__RES_Fuji-1201E__RET_name1_R1C2__ILLUM_.__FEM_7x20\result.json');
