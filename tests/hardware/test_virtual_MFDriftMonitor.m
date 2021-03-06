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
a = bl12014.hardwareAssets.virtual.MFDriftMonitor();

samples = a.getSampleData(10);
samples.get(1).getDmiData()
samples.get(1).getHsData()

samples.get(2).getDmiData()
samples.get(2).getHsData()