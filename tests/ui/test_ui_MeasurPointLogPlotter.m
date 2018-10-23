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
ui.build();


 

% ui.setFile('C:\Users\metmatlab\Documents\MATLAB\matlab-bl12014-control\src\save\fem-scans\20180524-131704__PRE_20180524-131505__RES_Fuji-1201E__RET_name1_R1C2__ILLUM_.__FEM_7x20\result.json');
