[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..');
cDirSrc = fullfile(cDirApp, 'src');
cDirVendor = fullfile(cDirApp, 'vendor');

% src
addpath(genpath(fullfile(cDirSrc)));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'awojdyla', 'matlab-datatranslation-measurpoint', 'src')));

cAddress = '192.168.20.27';
mp = datatranslation.MeasurPoint(cAddress);             
% Connect the instrument through TCP/IP
mp.connect();
% Enable readout on protected channels
mp.enable();
   

%% Get all channel hardware types (These cannot be set)
[tc, rtd, volt] = mp.channelType();
fprintf('Hardware configuration:\n');
fprintf('TC   sensor channels = %s\n',num2str(tc,'%1.0f '))
fprintf('RTD  sensor channels = %s\n',num2str(rtd,'%1.0f '))
fprintf('Volt sensor channels = %s\n',num2str(volt,'%1.0f '))


%% Get all sensor types (can set each hardware type to various sensors)
fprintf('Sensor type of each channel:\n');
mp.getSensorType()

%% Measure all channels

%% Measure on mixed channels
channel_list = 0 : 47;
[readings, channel_map] = mp.measure_multi(channel_list);

cDir = 'C:\Users\metmatlab\Documents\Logs\DataTranslation';
cName = 'log.csv';
cPath = fullfile(cDir, cName);

if (exist(cDir, 'dir') ~= 7)
    mkdir(cDir);
end

createNewLogFile(mp, cPath);
t = createLoggingTimer(mp, cPath);
start(t);
    
    




