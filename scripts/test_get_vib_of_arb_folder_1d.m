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

cecFolders = regexp(cPathOfDir,filesep,'split');

cSortBy = 'date';
cSortMode = 'ascend';
cFilter = '*.txt';
cecFiles = mic.Utils.dir2cell(...
    cPathOfDir, ...
    cSortBy, ...
    cSortMode, ...
    cFilter ...
);

dRmsDriftX = zeros(1, length(cecFiles)); 
dRmsDriftY = zeros(1, length(cecFiles));

dPVDriftX = zeros(1, length(cecFiles)); 
dPVDriftY = zeros(1, length(cecFiles));
dts = NaT(1, length(cecFiles)); % array of "Not a time" datetimes


for j = 1 : length(cecFiles) 

    cName = cecFiles{j};
    cPath = fullfile(cPathOfDir, cName);

    ceData = bl12014.MfDriftMonitorUtilities.getDataFromLogFile(cPath);
    ceData = bl12014.MfDriftMonitorUtilities.removePartialsFromFileData(ceData);
    dDmi = bl12014.MfDriftMonitorUtilities.getDmiPositionFromFileData(ceData);

    dRmsDriftX(j) = std(dDmi(5, :));
    dRmsDriftY(j) = std(dDmi(6, :));
    
    dPVDriftX(j) = max(dDmi(5, :)) - min(dDmi(5, :));
    dPVDriftY(j) = max(dDmi(6, :)) - min(dDmi(6, :));
    
    [cPath, cNameNoExt, cExt] = fileparts(cName);
    dts(j) = datetime(cNameNoExt, 'InputFormat', 'yyyyMMdd-HHmmss');
        
end

figure('Name', cecFolders{end});
hold on
plot(dts, dPVDriftX, '.-r');
cTitle = [...
    'Vibration (nm PV) ', ...
    sprintf('avg = %1.2f, ', mean2(dRmsDriftFem)), ...
    sprintf('std = %1.2f, ', std2(dRmsDriftFem)), ...
    sprintf('min = %1.2f, ', min(min(dRmsDriftFem))), ...
    sprintf('max = %1.2f', max(max(dRmsDriftFem))) ...
];
title(cTitle);
xlabel('Time')
ylabel('Vibration (nm) PV')
