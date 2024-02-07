% Define the root folder containing the directories
rootFolder = '../src/save/fem-scans'; % Change this to your folder path

tic
% Get a list of all subfolders

% Get a list of all subfolders
allSubFolders = genpath(rootFolder);
% Split into a cell array using the semicolon delimiter.
listOfFolderNames = strsplit(allSubFolders, ';');

% Remove empty cells if any
listOfFolderNames = listOfFolderNames(~cellfun('isempty',listOfFolderNames));

numberOfFolders = length(listOfFolderNames);

% Define the names of the variables to be extracted
varNames = {'time', 'x_wafer_coarse_mm', 'y_wafer_coarse_mm', 'tilt_x_wafer_coarse_urad', 'tilt_y_wafer_coarse_urad', ...
            'z_wafer_coarse_mm', 'x_reticle_coarse_mm', 'y_reticle_coarse_mm', 'tilt_x_reticle_coarse_urad', 'tilt_y_reticle_coarse_urad','z_height_sensor_nm', 'cap_1_reticle_V', ...
            'cap_2_reticle_V', 'cap_3_reticle_V', 'cap_4_reticle_V', ...
            'tilt_x_reticle_cap_urad', 'tilt_y_reticle_cap_urad', ...
            'z_reticle_cap_um', 'z_reticle_coarse_mm', 'cap_1_wafer_V', ...
            'cap_2_wafer_V', 'cap_3_wafer_V', 'cap_4_wafer_V', ...
            'tilt_x_wafer_cap_urad', 'tilt_y_wafer_cap_urad'};

% Initialize a structure to store the data
dataStruct = struct();
for v = 1:length(varNames)
    dataStruct.(varNames{v}).data = [];
    dataStruct.(varNames{v}).folderName = {};
end

% Process all subfolders
kStop = numberOfFolders;
% kStop = 4;

for k = 1 :kStop
    
    % Get this folder and print it out.
    thisFolder = listOfFolderNames{k};
    fprintf('Processing folder %d/%d %s\n',k,kStop, thisFolder);
    
    % Specify the file name
    fileName = fullfile(thisFolder, 'result.csv');
    a = dir(fileName);
    if ~isempty(a) && strcmp(a.name, 'result.csv')
        
%         exist(fileName, 'file')
       % Open the file
       fileID = fopen(fileName, 'r');
       
       % Read the first line (header)
       headerLine = fgetl(fileID);
       
       % Read the second line (first row of data)
       dataLine = fgetl(fileID);
       
       % Close the file
       fclose(fileID);
       
       if length(headerLine) <= 1 || length(dataLine) <= 1
           continue
       end
       
       % Convert the header line to a cell array of field names
       headerFields = strsplit(headerLine, ',');
       
       % Convert the data line to a cell array of strings
       dataFields = strsplit(dataLine, ',');
       
       % Find the index of 'time' in the header
       timeIndex = find(strcmp(headerFields, 'time'));
       
       % Process the data
       try
           
           if all(ismember(varNames, headerFields))
               
               for v = 1:length(varNames)
                   fieldIndex = find(strcmp(headerFields, varNames{v}));
                   if isempty(fieldIndex)
                       warning('Field %s not found in file %s', varNames{v}, fileName);
                   else
                       if strcmp(varNames(v), 'time')
                           % Convert 'time' to datetime
                           dataStruct.(varNames{v}).data = [dataStruct.(varNames{v}).data, datetime(dataFields{fieldIndex}, 'InputFormat', 'yyyy-MM-dd HH:mm:ss')];
                       else
                           % Convert other fields to double
                           dataStruct.(varNames{v}).data = [dataStruct.(varNames{v}).data, str2double(dataFields{fieldIndex})];
                       end
                       dataStruct.(varNames{v}).folderName = [dataStruct.(varNames{v}).folderName; thisFolder];
                   end
               end
           end
       catch
            disp(lasterr)
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
    dataStruct.(varNames{v}).data = dataStruct.(varNames{v}).data(sortIdx);
    if v > 1  % Avoid sorting folder names for non-time data
        dataStruct.(varNames{v}).folderName = dataStruct.(varNames{v}).folderName(sortIdx);
    end
end

toc

% Now 'dataStruct' contains the sorted data from all folders, ready for plotting
