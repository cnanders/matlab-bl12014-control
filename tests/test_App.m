if exist('purge', 'file')
    purge;
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirVendor = fullfile(cDirThis, '..', 'vendor');

% src
cDirBl12014 = fullfile(cDirThis, '..', 'src');
addpath(genpath(cDirBl12014));

% UI dependencies
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'ryanmiyakawa', 'LSI-control')));
addpath(genpath(fullfile(cDirVendor, 'github', 'ryanmiyakawa', 'LSI-analyze')));
addpath(genpath(fullfile(cDirVendor, 'github', 'ryanmiyakawa', 'ryan_toolbox')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-quasar', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-gridded-pupil-fill', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-pupil-fill-generator', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-npoint-lc400-ui', 'src')));

% Hardware dependencies are added in bl12014.Hardware

% 12.0.1 Exit Slit
%addpath(genpath(fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v2')));
%javaaddpath(fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v2', 'BL12PICOCorbaProxy.jar'));

try
    addpath(genpath(fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v3')));
    javaaddpath(fullfile(cDirVendor, 'pnaulleau', 'bl-1201-exit-slit-v3', 'BL12PICOCorbaProxy.jar'));
end

% MET5 devices built by Carl Cork
javaaddpath(fullfile(cDirVendor, 'cwcork', 'Met5Instruments.jar'));
% Required by cwcork cxro.met5.Instruments
cDirMet5InstrumentsConfig = fullfile(cDirVendor, 'cwcork');

% BL 12.0.1 Undulator, mono grating angle.  Does not have methods for shutter
javaaddpath(fullfile(cDirVendor, 'cwcork', 'bl1201', 'jar_jdk6', 'BL1201CorbaProxy.jar'));

% BL 12.0.1 Shutter
javaaddpath(fullfile(cDirVendor, 'cwcork', 'bl1201', 'jar_jdk6', 'DctCorbaProxy.jar'));

% Java SSH2 Communication With DeltaTau Power PMAC Motion Controller (uses JSch)
% needed by github/cnanders/matlab-deltatau-ppmac-met5
javaaddpath(fullfile(cDirVendor, 'cnanderson', 'deltatau-power-pmac-comm-jre1.7.jar'));

% Java utility to check if a network device (host + port) is reachable
% Used by GetLogicalPing
javaaddpath(fullfile(cDirVendor, 'cnanderson', 'network-device-jre1.7.jar'));

addpath(genpath(fullfile(cDirVendor, 'cnanderson')));


app = bl12014.App(...
    'cDirMet5InstrumentsConfig', cDirMet5InstrumentsConfig ...
);
app.build();

% Start the logger
try 
    test_MeasurPointLogger
end
 

