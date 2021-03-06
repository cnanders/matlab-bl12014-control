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


uiReticle = bl12014.ui.Reticle(...
    'clock', clock, ...
    'hardware', hardware, ...
    'uiClock', uiClock ...
);
uiWafer = bl12014.ui.Wafer(...
    'clock', clock, ...
    'hardware', hardware, ...
    'uiClock', uiClock ...
);
uiShutter = bl12014.ui.Shutter( ...
    'clock', clock, ...
    'hardware', hardware, ...
    'uiClock', uiClock ...
);
uiBeamline = bl12014.ui.Beamline( ...
    'clock', clock, ...
    'hardware', hardware, ...
    'uiClock', uiClock ...
);  

uiScannerMA = bl12014.ui.Scanner(...
    'fhGetNPoint', @() hardware.getNPointMA(), ...
    'cName', 'ma', ...
    'clock', clock, ...
    'uiClock', uiClock ...
);

uiScannerM142 = bl12014.ui.Scanner(...
    'fhGetNPoint', @() hardware.getNPointMA(), ...
    'cName', 'm142', ...
    'clock', clock, ...
    'uiClock', uiClock ...
);


waferExposureHistory = bl12014.WaferExposureHistory();
waferExposureHistory.addFakeExposures();

uiTuneFluxDensity = bl12014.ui.TuneFluxDensity(...
    'clock', clock, ...
    'hardware', hardware, ...
    'uiClock', uiClock, ...
    'uiReticle', uiReticle, ...
    'uiGratingTiltX', uiBeamline.uiGratingTiltX, ...
    'uiScannerMA', uiScannerMA, ...
    'uiScannerM142', uiScannerM142 ...
);

%{

20.02.03 STILL MISSING THESE THINGS

                'uiHeightSensorLEDs', this.uiHeightSensorLEDs, ...
                'uiVibrationIsolationSystem', this.uiVibrationIsolationSystem, ...
                'uiMfDriftMonitorVibration', this.uiMfDriftMonitorVibration, ...
                'uiMFDriftMonitor', this.uiDriftMonitor, ...

%}
ui = bl12014.ui.Scan(...
    'clock', clock, ...
    'uiClock', uiClock, ...
    'hardware', hardware, ...
    'waferExposureHistory', waferExposureHistory, ...
    'uiShutter', uiShutter, ...
    'uiReticle', uiReticle, ...
    'uiWafer', uiWafer, ...
    'uiScannerMA', uiScannerMA, ...
    'uiTuneFluxDensity', uiTuneFluxDensity, ...
    'uiBeamline', uiBeamline, ...
    'uiScannerM142', uiScannerM142 ...
);

dWidth = 1750;
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


 
