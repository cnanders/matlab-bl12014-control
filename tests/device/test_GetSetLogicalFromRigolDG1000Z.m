[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');
cDirSrc = fullfile(cDirApp, 'src');
cDirVendor = fullfile(cDirApp, 'vendor');

% src
addpath(genpath(fullfile(cDirSrc)));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-rigol-dg1000z', 'src')));

cHost = '192.168.10.40';
u16Port = 5555;

comm = rigol.DG1000Z(...
    'cHost', cHost, ...
    'u16Port', u16Port ...
);
comm.idn()     
device = bl12014.device.GetSetLogicalFromRigolDG1000Z(comm, 1);
device.get()
device.set(true);


