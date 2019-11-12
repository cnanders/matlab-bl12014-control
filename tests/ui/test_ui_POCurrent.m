try 
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));

clock = mic.Clock('Master');
hardware = bl12014.Hardware('clock', clock);
hardware.connectDataTranslation(); % force real hardware
% hardware.getDataTranslation().setFilterTypeToRaw() % if you dont
            % it uses its internal 16 point rolling averaging filter (1.6
            % seconds)
            
            % echo the filter type:
            
hardware.getDataTranslation().getFilterType()

%% Run this code to set the filter type to RAW (remove 16-sample averaging)
% This class assumes that the DT is already configured by the main met5
% control software
%{
hardware.getDataTranslation().abortScan();
hardware.getDataTranslation().setFilterTypeToRaw();
hardware.getDataTranslation().initiateScan();
%}

ui = bl12014.ui.POCurrent(...
    'dWidth', 1200, ...
    'dHeight', 400, ...
    'hardware', hardware, ...
    'clock', clock ...
);

dWidth = 1300;
dHeight = 500;

dScreenSize = get(0, 'ScreenSize');
h = figure(...
    'Position', [ ...
        (dScreenSize(3) - dWidth)/2 ...
        (dScreenSize(4) - dHeight)/2 ...
        dWidth ...
        dHeight ...
    ] ...
);

ui.build(h, 10, 10);


 

