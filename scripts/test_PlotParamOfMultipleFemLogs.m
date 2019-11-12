

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', 'mpm-packages')));

data = PlotParamOfMultipleFemLogs();

