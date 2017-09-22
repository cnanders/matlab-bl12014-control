%purge

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirVendor = fullfile(cDirThis, '..', 'vendor');

% src
cDirBl12014 = fullfile(cDirThis, '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies

addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-micronix-mmc-103', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-newfocus-model-8742', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-hex', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-ieee', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-npoint-lc400', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-scanner-control-npoint', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-keithley-6482', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-deltatau-ppmac-met5', 'src')));

addpath(genpath(fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slits')));
javaaddpath(fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slits', 'BL12PICOCorbaProxy.jar'));

javaaddpath(fullfile(cDirVendor, 'cwcork', 'Met5Instruments.jar'));
javaaddpath(fullfile(cDirVendor, 'cwcork', 'bl1201', 'jar_jdk6', 'BL1201CorbaProxy.jar'));
javaaddpath(fullfile(cDirVendor, 'cwcork', 'bl1201', 'jar_jdk6', 'DctCorbaProxy.jar'));


javaaddpath(fullfile(cDirVendor, 'cnanderson', 'deltatau-power-pmac-comm-jre1.7.jar'));

% Used by GetLogicalPing
javaaddpath(fullfile(cDirVendor, 'cnanderson', 'network-device-jre1.7.jar'));


% Required by cwcork cxro.met5.Instruments
cDirMet5InstrumentsConfig = fullfile(cDirVendor, 'cwcork');


app = bl12014.App(...
    'cDirMet5InstrumentsConfig', cDirMet5InstrumentsConfig ...
);
app.build();


 

