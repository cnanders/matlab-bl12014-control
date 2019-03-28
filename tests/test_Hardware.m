try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirVendor = fullfile(cDirThis, '..', 'vendor');


cDirSrc = fullfile(cDirThis, '..', 'src');

addpath(genpath(cDirSrc));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));


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



hardware = bl12014.Hardware();

[tc, rtd, volt] = hardware.getDataTranslation().channelType()

%{
hardware.setIsConnectedMfDriftMonitor(true);
hardware.getMfDriftMonitor().dmiGetAxesOpticalPowerDC()
hardware.getMfDriftMonitor().dmiGetAxesOpticalPower()
%}


hardware.getWebSwitchBeamline().turnOnRelay1()
hardware.getWebSwitchBeamline().turnOnRelay2()
hardware.getWebSwitchBeamline().isOnRelay1()
hardware.getWebSwitchBeamline().isOnRelay2()


