mpm if exist('purge', 'file')
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


% Required by cwcork cxro.met5.Instruments
cDirMet5InstrumentsConfig = fullfile(cDirVendor, 'cwcork');




app = bl12014.App(...
    'cDirMet5InstrumentsConfig', cDirMet5InstrumentsConfig ...
);
app.build();
 

