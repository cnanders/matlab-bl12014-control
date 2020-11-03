
[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', 'src');
addpath(genpath(cDirBl12014));

[cFile, cDir] = uigetfile(...
    '*.txt', ...
    'Select a dmi log file' ...
);

if isequal(cFile, 0)
   return; % User clicked "cancel"
end

cPath = cFile;
ceData = bl12014.MfDriftMonitorUtilities.getDataFromLogFile(cPath);
ceData = bl12014.MfDriftMonitorUtilities.removePartialsFromFileData(ceData);
dZ = bl12014.MfDriftMonitorUtilities.getHeightSensorZFromFileData(ceData);
dXY = bl12014.MfDriftMonitorUtilities.getDmiPositionFromFileData(ceData);


figure
plot(dXY')
legend({'x reticle', 'y reticle', 'x wafer', 'y wafer', 'x aerial image', 'y aerial image'})
ylabel('nm')
xlabel('ms');

dXAerialImage = dXY(5,:);
dXAerialImage = dXAerialImage - mean(dXAerialImage);


dYAerialImage = dXY(6,:);
dYAerialImage = dYAerialImage - mean(dYAerialImage);


figure
plot(dXAerialImage);
hold on
plot(dYAerialImage);
legend({'x aerial image', 'y aerial image'})
ylabel('nm')
xlabel('ms');





