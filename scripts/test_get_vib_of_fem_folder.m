[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% Dependencies

addpath(genpath(fullfile(cDirThis, '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', 'mpm-packages')));

cFolder = '20191220-123533__PRE_20191220-123445__RES_YATU1032__FEM_D15xF11__Cal 2 f2x contact';

% cPathOfDir = fullfile(cDirThis, '..', 'src', 'save', 'fem-scans', cFolder);
cPathOfDir = fullfile(cDirThis, '..', 'src', 'save', 'fem-scans');
cPathOfDir = mic.Utils.path2canonical(cPathOfDir); 
cPathOfDir = uigetdir(cPathOfDir, 'Choose a FEM log directory');

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
dFocus = zeros(1, length(cecFiles)); 
dDose = zeros(1, length(cecFiles)); 


for j = 1 : length(cecFiles) 

    cName = cecFiles{j};
    cPath = fullfile(cPathOfDir, cName);

    ceData = bl12014.MfDriftMonitorUtilities.getDataFromLogFile(cPath);
    ceData = bl12014.MfDriftMonitorUtilities.removePartialsFromFileData(ceData);
    dDmi = bl12014.MfDriftMonitorUtilities.getDmiPositionFromFileData(ceData);

    dRmsDriftX(j) = std(dDmi(5, :));
    dRmsDriftY(j) = std(dDmi(6, :));
    
    [dDoseNow, dFocusNow] = bl12014.MfDriftMonitorUtilities.getDoseAndFocusFromLogFilename(cName);
    dFocus(j) = dFocusNow;
    dDose(j) = dDoseNow;
    
end

% unset index shot, written first
dRmsDriftX(1) = [];
dRmsDriftY(1) = [];
dFocus(1) = [];
dDose(1) = [];

% build fem matrix

dNumDose = max(dDose);
dNumFocus = max(dFocus);

dRmsDriftXFem = zeros(dNumFocus, dNumDose);
dRmsDriftYFem = zeros(dNumFocus, dNumDose);

for j = 1 : length(dRmsDriftX)
    dRmsDriftXFem(dFocus(j), dDose(j)) = dRmsDriftX(j);
    dRmsDriftYFem(dFocus(j), dDose(j)) = dRmsDriftY(j);
end


figure
subplot(121)
imagesc(dRmsDriftXFem)
colorbar
axis image

subplot(122)
imagesc(dRmsDriftYFem)
colorbar
axis image
    

       



            