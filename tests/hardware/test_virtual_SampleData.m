try
    purge
end


[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');
cDirSrc = fullfile(cDirApp, 'src');
cDirVendor = fullfile(cDirApp, 'vendor');

addpath(genpath(fullfile(cDirSrc)));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));

% Generate a {1x1} SampleData 
a = bl12014.hardwareAssets.virtual.SampleData();
a.getDmiData()
a.getHsData()

% Generate a {1xn} Sample Data
dNum = 100;
b(1, dNum) = bl12014.hardwareAssets.virtual.SampleData();
for k = 1 : dNum
    b(1, k) = bl12014.hardwareAssets.virtual.SampleData();
end