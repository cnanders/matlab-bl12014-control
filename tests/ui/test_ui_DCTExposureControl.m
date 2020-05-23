try 
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));


clock = mic.Clock('master');
uiClock = mic.ui.Clock(clock);
hardware = bl12014.Hardware('clock', clock);



uiBeamline = bl12014.ui.Beamline( ...
    'clock', clock, ...
    'hardware', hardware, ...
    'uiClock', uiClock ...
);  

uiScannerM142 = bl12014.ui.Scanner(...
    'fhGetNPoint', @() hardware.getNPointMA(), ...
    'cName', 'm142', ...
    'clock', clock, ...
    'uiClock', uiClock ...
);

exposures = bl12014.DCTExposures();

uiFluxDensity = bl12014.ui.DCTFluxDensity(...
    'clock', clock, ...
    'hardware', hardware, ...
    'uiClock', uiClock, ...
    'uiGratingTiltX', uiBeamline.uiGratingTiltX, ...
    'uiScannerM142', uiScannerM142 ...
);

ui = bl12014.ui.DCTExposureControl(...
    'clock', clock, ...
    'uiClock', uiClock, ...
    'hardware', hardware, ...
    'exposures', exposures, ...
    'uiFluxDensity', uiFluxDensity, ...
    'uiScannerM142', uiScannerM142, ...
    'uiBeamline', uiBeamline ...
);

dWidth = 1750;
dHeight = 700;
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




 
