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



stResults = dir(cPathOfDir);


% Filter results to folders containing the following pattern in the name
cPattern = '21121';

% Initialize empty structure with correct fields
stResultsFilt = struct(stResults(1));
stResultsFilt(1) = [];

for n = 1:length(stResults)
    if startsWith(stResults(n).name, cPattern)
        if stResults(n).isdir
            stResultsFilt(end+1) = stResults(n);
        end
    end        
end

% Plot

dNumCols = 6;
if length(stResultsFilt) < dNumCols
    dNumCols = length(stResultsFilt);
end

dNumRows = floor((length(stResultsFilt) -1) / dNumCols) + 1;

dLeft = 0;
dBottom = 0;
dWidth = 1;
dHeight = 1;
dPosition = [dLeft dBottom dWidth dHeight];
hFigure = figure(...
    'name', cPattern, ...
    'menubar', 'none', ...
    'toolbar', 'none', ...
    'units','normalized', ...
    'outerposition', dPosition ...
);

lShowTitle = false;

for n = 1: length(stResultsFilt)
    
    % Fill row by row
    dCol = mod(n - 1, dNumCols) + 1;
    dRow = floor((n-1) / dNumCols) + 1;
    
    
    dWidth = 1/dNumCols;
    dHeight = 1/dNumRows;
    dLeft = dWidth * (dCol - 1);
    dBottom = 1 - dRow * dHeight;
    dPosition = [dLeft dBottom dWidth dHeight];
    h2 = axes(...
        'units', 'normalized', ...
        'position', dPosition, ...
        'box', 'on');
    
    % h2 = subplot(dNumRows, dNumCols, n);
    cPath = fullfile(stResultsFilt(n).folder, stResultsFilt(n).name);
    cTitle = stResultsFilt(n).name(1:11);
    bl12014.MfDriftMonitorUtilities.quiverDriftOfStageDuringFEM(...
        'cPathOfDir', cPath, ...
        'h', h2, ...
        'cTitle', cTitle, ...
        'lShowAxis', false, ...
        'lShowLabels', false, ...
        'lShowColorbar', false, ...
        'lNormalize', true, ...
        'dMax', 10, ...
        'dWidthOfAxesBorder', 2, ...
        'lShowTitle', false ...
    );
    drawnow;
end






            