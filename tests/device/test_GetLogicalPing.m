[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..');
cDirSrc = fullfile(cDirApp, 'src');
cDirVendor = fullfile(cDirApp, 'vendor');

% src
addpath(genpath(cDirSrc));

% dependency (github/cnanders/matlab-instrument-control)
cDirMic = fullfile(...
    cDirVendor, ...
    'github', ...
    'cnanders', ...
    'matlab-instrument-control', ...
    'src' ...
);
addpath(genpath(cDirMic));

% dependency
% javaaddpath(fullfile(cDirVendor, 'cnanderson', 'NetworkDevice.class'));
javaaddpath(fullfile(cDirVendor, 'cnanderson', 'network-device-jre1.7.jar'));


clc

cHostname = 'apple.com';

device = bl12014.device.GetLogicalPing(...
    'cHostname', cHostname, ...
    'dTimeout', 500 ...
);
device.get()

cHostname = 'cns.als.lbl.gov';
u16Port = 8888;

device = bl12014.device.GetLogicalPing(...
    'cHostname', cHostname, ...
    'dTimeout', 500, ...
    'u16Port', u16Port ...
);
device.get()
 

