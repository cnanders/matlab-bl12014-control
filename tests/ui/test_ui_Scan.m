try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-rigol-dg1000z', 'src')));



clock = mic.Clock('master');
hardware = bl12014.Hardware();
uiClock = mic.ui.Clock(clock);


uiReticle = bl12014.ui.Reticle('clock', clock, 'hardware', hardware, 'uiClock', uiClock);
uiWafer = bl12014.ui.Wafer('clock', clock, 'hardware', hardware, 'uiClock', uiClock);
uiShutter = bl12014.ui.Shutter('clock', clock, 'hardware', hardware, 'uiClock', uiClock);
uiBeamline = bl12014.ui.Beamline('clock', clock, 'hardware', hardware, 'uiClock', uiClock);  

waferExposureHistory = bl12014.WaferExposureHistory();
waferExposureHistory.addFakeExposures();

ui = bl12014.ui.Scan(...
    'clock', clock, ...
    'waferExposureHistory', waferExposureHistory, ...
    'uiShutter', uiShutter, ...
    'uiReticle', uiReticle, ...
    'uiWafer', uiWafer ...
);

dWidth = 1650;
dHeight = 900;
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

%{
cb = @(src, evt) (fprintf('x %1.3f, y %1.3f \n', evt.stData.dX, evt.stData.dY));
addlistener(ui, 'eClickField', cb);
%}


 

