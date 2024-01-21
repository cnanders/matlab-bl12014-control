% Define the root folder containing the directories
rootFolder = '../src/save/fem-scans'; % Change this to your folder path

% Get a list of all subfolders

% Get a list of all subfolders
allSubFolders = genpath(rootFolder);
% Split into a cell array using the semicolon delimiter.
listOfFolderNames = strsplit(allSubFolders, ':');

% Remove empty cells if any
listOfFolderNames = listOfFolderNames(~cellfun('isempty',listOfFolderNames));

numberOfFolders = length(listOfFolderNames);

% Define the names of the variables to be extracted
varNames = ["time", "tilt_x_wafer_coarse_urad", "tilt_y_wafer_coarse_urad", ...
            "z_wafer_coarse_mm", "z_height_sensor_nm", "cap_1_reticle_V", ...
            "cap_2_reticle_V", "cap_3_reticle_V", "cap_4_reticle_V", ...
            "tilt_x_reticle_cap_urad", "tilt_y_reticle_cap_urad", ...
            "z_reticle_cap_um", "z_reticle_coarse_mm", "cap_1_wafer_V", ...
            "cap_2_wafer_V", "cap_3_wafer_V", "cap_4_wafer_V", ...
            "tilt_x_wafer_cap_urad", "tilt_y_wafer_cap_urad"];

% Initialize a structure to store the data
dataStruct = struct();
for v = 1:length(varNames)
    dataStruct.(varNames(v)).data = [];
    dataStruct.(varNames(v)).folderName = {};
end

% Process all subfolders
for k = 1 : numberOfFolders
    % Get this folder and print it out.
    thisFolder = listOfFolderNames{k};
    fprintf('Processing folder %s\n', thisFolder);
    
    % Specify the file name
    fileName = fullfile(thisFolder, 'result.csv');
    if exist(fileName, 'file')
        % Read the CSV file
        fileData = readtable(fileName, 'ReadVariableNames', true, 'ReadRowNames', false);
        
        % Check if all required columns are present
        if all(ismember(varNames, fileData.Properties.VariableNames))
            % Convert 'time' to datetime and extract only the first row of data
            fileData.time = datetime(fileData.time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
            timeValue = fileData.time(1);

            % Extract and store the numeric data
            for v = 2:length(varNames) % Start from 2 to skip 'time'
                numericData = fileData{1, varNames(v)};
                dataStruct.(varNames(v)).data = [dataStruct.(varNames(v)).data, numericData];
                dataStruct.(varNames(v)).folderName = [dataStruct.(varNames(v)).folderName; thisFolder];
            end
            
            % Store the time data separately
            dataStruct.(varNames(1)).data = [dataStruct.(varNames(1)).data, timeValue];
            dataStruct.(varNames(1)).folderName = [dataStruct.(varNames(1)).folderName; thisFolder];
        else
            warning('Missing one or more required columns in %s', fileName);
        end
    else
        warning('%s does not exist.', fileName);
    end
end

% Sort the data according to 'time'
% Convert 'time' data to datetime for sorting
timeData = datetime(dataStruct.time.data, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
[~, sortIdx] = sort(timeData);
for v = 1:length(varNames)
    dataStruct.(varNames(v)).data = dataStruct.(varNames(v)).data(sortIdx);
    if v > 1  % Avoid sorting folder names for non-time data
        dataStruct.(varNames(v)).folderName = dataStruct.(varNames(v)).folderName(sortIdx);
    end
end

% Now 'dataStruct' contains the sorted data from all folders, ready for plotting
