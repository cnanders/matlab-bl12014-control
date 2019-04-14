try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');


addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-rigol-dg1000z', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-quasar', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-gridded-pupil-fill', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-pupil-fill-generator', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-npoint-lc400-ui', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-npoint-lc400', 'src')));


hardware = bl12014.Hardware();
waferExposureHistory = bl12014.WaferExposureHistory();
waferExposureHistory.addFakeExposures();


clock = mic.Clock('Master');
uiClock = mic.ui.Clock(clock);


uiScannerMA = bl12014.ui.Scanner(...
    'cName', 'ma', ...
    'clock', clock, ...
    'uiClock', uiClock ...
);

uiScannerM142 = bl12014.ui.Scanner(...
    'cName', 'm142', ...
    'clock', clock, ...
    'uiClock', uiClock ...
);

ui = bl12014.ui.TuneFluxDensity(...
    'clock', clock, ...
    'uiClock', uiClock, ...
    'uiScannerMA', uiScannerMA, ...
    'uiScannerM142', uiScannerM142, ...
    'waferExposureHistory', waferExposureHistory ...
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



 

