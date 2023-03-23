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
dFocus = zeros(1, length(cecFiles)); 
dDose = zeros(1, length(cecFiles)); 

dNumCols = 100;
if length(cecFiles) < dNumCols
    dNumCols = length(cecFiles);
end

dNumRows = floor((length(cecFiles) -1) / dNumCols) + 1;


for j = 1 : length(cecFiles) 

    cName = cecFiles{j};
    cPath = fullfile(cPathOfDir, cName);

    ceData = bl12014.MfDriftMonitorUtilities.getDataFromLogFile(cPath);
    ceData = bl12014.MfDriftMonitorUtilities.removePartialsFromFileData(ceData);
    dDmi = bl12014.MfDriftMonitorUtilities.getDmiPositionFromFileData(ceData);

    dRmsDriftX(j) = std(dDmi(5, :));
    dRmsDriftY(j) = std(dDmi(6, :));
    
    % Fill row by row
    dCol = mod(j - 1, dNumCols) + 1;
    dRow = floor((j-1) / dNumCols) + 1;
    
    dFocus(j) = dRow;
    dDose(j) = dCol;
    
    
    
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

prompt = {'Enter the vibration spec in nm:'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'1.1'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

if length(answer) > 0
    dRmsSpec = str2num(answer{1});
else
    return
end


% For worst-case, take the max X and Y

lXIsMax = dRmsDriftXFem > dRmsDriftYFem;

dRmsDriftFem = zeros(size(dRmsDriftXFem));

dRmsDriftFem(lXIsMax) = dRmsDriftXFem(lXIsMax);
dRmsDriftFem(~lXIsMax) = dRmsDriftYFem(~lXIsMax);

dRmsDriftPass = dRmsDriftFem <= dRmsSpec;
dRmsDriftXPass = dRmsDriftXFem <= dRmsSpec;
dRmsDriftYPass = dRmsDriftYFem <= dRmsSpec;

colormapPassFail = [1 0 0; 0 1 0];
colormapNormal = 'parula';

figure('Name', cecFolders{end});

h1 = subplot(211);
imagesc(dRmsDriftFem)
colorbar
%axis(h1, 'image')
colormap(h1, colormapNormal) 
cTitle = [...
    'Vibration (nm RMS) ', ...
    sprintf('avg = %1.2f, ', mean2(dRmsDriftFem)), ...
    sprintf('std = %1.2f, ', std2(dRmsDriftFem)), ...
    sprintf('min = %1.2f, ', min(min(dRmsDriftFem))), ...
    sprintf('max = %1.2f', max(max(dRmsDriftFem))) ...
];
title(cTitle);
xlabel('Dose Col')
ylabel('Focus Col')

h2 = subplot(212);
imagesc(dRmsDriftPass)
colormap(h2, colormapPassFail)
colorbar
cTitle = sprintf('pass (green) / fail (red) (< %1.1f nm RMS)', dRmsSpec);
title(cTitle);
xlabel('Dose Col')
ylabel('Focus Col')

return

% X and Y separate

figure('Name', cecFolders{end});



h1 = subplot(221);
imagesc(dRmsDriftXFem)
colorbar
%axis(h1, 'image')
title('x');
colormap(h1, colormapNormal)

h2 = subplot(222);
imagesc(dRmsDriftYFem)
colorbar
%axis(h2, 'image')
title('y');
colormap(h2, colormapNormal)

h3 = subplot(223);
imagesc(dRmsDriftXPass)
colormap(h3, colormapPassFail)
colorbar
cTitle = sprintf('x pass (green) / fail (red) (< %1.1f nm RMS)', dRmsSpec);
title(cTitle);

h4 = subplot(224);
imagesc(dRmsDriftYPass)
colormap(h4, colormapPassFail)
colorbar
cTitle = sprintf('y pass (green) / fail (red) (< %1.1f nm RMS)', dRmsSpec);
title(cTitle);


       



            