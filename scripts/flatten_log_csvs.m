% plot_focus_through_time

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', 'mpm-packages')));


% crate output folder if it does not exist
cPathOutputDir = fullfile(cDirThis, '..', 'src', 'save', 'fem-scans-flat-logs');
if ~exist(cPathOutputDir, 'dir')
  mkdir(cPathOutputDir);
end


cPath = fullfile(cDirThis, '..', 'src', 'save', 'fem-scans');
cSortBy = 'date';
cSortMode = 'descend';
cFilter = '*';
ceReturn = mic.Utils.dir2cell(cPath, cSortBy, cSortMode, cFilter);

cecIgnore = {'.', '..', '.DS_Store'};


for n = 1 : length(ceReturn)
    cVal = ceReturn{n};
    
    % skip in ignore list 
    if any(strcmp(cecIgnore, cVal))
        continue
    end
    
    cPathFull = fullfile(cPath, cVal);
    
    % skip if not dir
    if ~isdir(cPathFull)
        continue
    end
    
    % get .csv contents of dir
    cPathCsv = fullfile(cPathFull, '*.csv');
    st = dir(cPathCsv);
    
    % skip if no .csv file inside
    if isempty(st)
        continue
    end
    
    
    for n = 1 : length(st)
        
        cPathInputFile = fullfile(cPathFull, st(n).name);
        cPathOutputFile = fullfile(cPathOutputDir, [cVal, '-', st(n).name]);

        % skip copying if output file already exists
        if exist(cPathOutputFile, 'file') == 2
            fprintf('aready exists.\n');
            continue
        end

        try
            copyfile(cPathInputFile, cPathOutputFile);

        catch mE
            error(mE)
        end
        fprintf('Creating: %s\n', cPathOutputFile);
    end
   
end

fprintf('Done!\n');
