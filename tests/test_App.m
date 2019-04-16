if exist('purge', 'file')
    purge;
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% Dependencies

addpath(fullfile(cDirThis, '..', 'src'));
addpath(fullfile(cDirThis, '..', 'mpm-packages'));

% Hardware dependencies are added in bl12014.Hardware

% Required by cwcork cxro.met5.Instruments
cDirMet5InstrumentsConfig = fullfile(cDirVendor, 'cwcork');

app = bl12014.App(...
    'cDirMet5InstrumentsConfig', cDirMet5InstrumentsConfig ...
);
app.build();
 

