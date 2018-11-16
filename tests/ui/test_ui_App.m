try
    purge;
end


[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 pkg
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

% addpath(genpath(fullfile(cDirVendor, 'github', 'awojdyla', 'matlab-datatranslation-measurpoint', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-hex', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-ieee', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-npoint-lc400', 'src')));
% addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-scanner-control-npoint', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-keithley-6482', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-deltatau-ppmac-met5', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-quasar', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-pupil-fill-generator', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-npoint-lc400-ui', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-rigol-dg1000z', 'src')));

hardware = bl12014.Hardware();

ui = bl12014.ui.App(...
   'hHardware', hardware ...
);
ui.build();

%{
cb = @(src, evt) (fprintf('x %1.3f, y %1.3f \n', evt.stData.dX, evt.stData.dY));
addlistener(ui, 'eClickField', cb);
%}


 

