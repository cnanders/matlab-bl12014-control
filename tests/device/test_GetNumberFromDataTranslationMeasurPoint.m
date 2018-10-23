[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');
cDirSrc = fullfile(cDirApp, 'src');
cDirVendor = fullfile(cDirApp, 'vendor');

% src
addpath(genpath(fullfile(cDirSrc)));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'awojdyla', 'matlab-datatranslation-measurpoint', 'src')));

cAddress = '192.168.20.27'

comm = datatranslation.MeasurPoint(cAddress);
                
% Connect the instrument through TCP/IP
comm.connect();

% Enable readout on protected channels
comm.enable();
   
device = bl12014.device.GetNumberFromDataTranslationMeasurPoint(...
    comm, ...
    bl12014.device.GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, ...
    33 ...
);
device.get()
% device.set(false);


