try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));


clock = mic.Clock('Master');

weh = bl12014.WaferExposureHistory();
weh.addFakeExposures();
% weh.setIsExposing(true);

ui = bl12014.ui.WaferAxes(...
    'clock', clock, ...
    'fhGetIsShutterOpen', @() false, ...
    'fhGetXOfWafer', @() 10/1000, ...
    'fhGetYOfWafer', @() 5/1000, ...
    'fhGetXOfLsi', @() 400/1000, ...
    'waferExposureHistory', weh, ...
    'cName', 'test' ...
);


dWidth = 800;
dHeight = 700;

dScreenSize = get(0, 'ScreenSize');
            
h = figure( ...
    'Position', [ ...
        (dScreenSize(3) - dWidth)/2 ...
        (dScreenSize(4) - dHeight)/2 ...
        dWidth ...
        dHeight ...
     ] ...
);
% set(h,'renderer','zbuffer')
ui.build(h, 10, 10);

 

