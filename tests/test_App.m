[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014
cDirBl12014 = fullfile(cDirThis, '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', 'vendor');
cDirCnanders = fullfile(cDirVendor, 'github', 'cnanders');
addpath(genpath(fullfile(cDirCnanders, 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirCnanders, 'matlab-micronix-mmc-103', 'src')));
addpath(genpath(fullfile(cDirCnanders, 'matlab-newfocus-model-8742', 'src')));
addpath(genpath(fullfile(cDirCnanders, 'matlab-hex', 'src')));
addpath(genpath(fullfile(cDirCnanders, 'matlab-ieee', 'src')));
addpath(genpath(fullfile(cDirCnanders, 'matlab-npoint-lc400', 'src')));
addpath(genpath(fullfile(cDirCnanders, 'matlab-scanner-control-npoint', 'src')));
addpath(genpath(fullfile(cDirCnanders, 'matlab-keithley-6482', 'src')));

addpath(genpath(fullfile(cDirThis, '..', 'vendor', 'pnaulleau', 'bl-1201-exit-slits')));


javaaddpath(fullfile(cDirThis, '..', 'vendor', 'pnaulleau', 'bl-1201-exit-slits', 'BL12PICOCorbaProxy.jar'));

purge

app = bl12014.App();
app.build()


 

