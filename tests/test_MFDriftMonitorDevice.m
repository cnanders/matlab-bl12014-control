
%% TEST CODE ONLY (normally this happens in App)
try
purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', 'src');
addpath(genpath(cDirBl12014));

cDirVendor = fullfile(cDirThis, '..', 'vendor');
cDirMic = fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src');
addpath(genpath(cDirMic));


% Hardware is exposed in the main app
hardware = bl12014.Hardware();
apiDriftMonitor = hardware.getMFDriftMonitor();

%%

% Init interpolant:
dNumAverage = 100; % number of samples to average

% Bypasses Interpolant and uses CWCork slope values.  Probably best for
% determining Z when not at the calibration location
tic;
dSimpleHeight = apiDriftMonitor.getSimpleZ(dNumAverage);
dETime = toc;


fprintf('Height sensor simple z value: %0.3f nm.  Recorded %d samples in %0.3f sec\n', dSimpleHeight, dNumAverage, dETime);



 

