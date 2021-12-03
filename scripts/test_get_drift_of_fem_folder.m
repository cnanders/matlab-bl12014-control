% [cDirThis, cNa201210-001-JSR_1__FEM_D20xF9__20201210-094031__20201210-094137me, cExt] = fileparts(mfilename('fullpath'));

% Dependencies
%{
addpath(genpath(fullfile(cDirThis, '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', 'mpm-packages', 'matlab-instrument-control')));
%}

% cFolder = '200702-004-MET8__FEM_D13xF11__20200702-150119__20200702-150820';

% cPathOfDir = fullfile(cDirThis, '..', 'src', 'save', 'fem-scans', cFolder);

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cPathOfDir = fullfile(cDirThis, '..', 'src', 'save', 'fem-scans');
cPathOfDir = mic.Utils.path2canonical(cPathOfDir); 
cPathOfDir = uigetdir(cPathOfDir, 'Choose a FEM log directory');

h = figure('Name', cPathOfDir);
h2 = axes(h);

bl12014.MfDriftMonitorUtilities.quiverDriftOfStageDuringFEM( ...
    'cPathOfDir', cPathOfDir, ...
        'h', h2, ...
        'cTitle', 'Wafer Stage Drift (nm)', ...
        ...'lShowAxis', false, ...
        ...'lShowLabels', false, ...
       ... 'lShowColorbar', false, ...
        'lNormalize', true, ...
        'dMax', 10, ...
        'dWidthOfAxesBorder', 1, ...
        'lShowTitle', true ...
        );

return;




            