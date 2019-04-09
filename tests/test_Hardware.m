try
    purge
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirVendor = fullfile(cDirThis, '..', 'vendor');


cDirSrc = fullfile(cDirThis, '..', 'src');

addpath(genpath(cDirSrc));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));


% Required by cwcork cxro.met5.Instruments
cDirMet5InstrumentsConfig = fullfile(cDirVendor, 'cwcork');

addpath(genpath(fullfile(cDirVendor, 'cnanderson')))
hardware = bl12014.Hardware();

[tc, rtd, volt] = hardware.getDataTranslation().channelType()
hardware.getDataTranslation().getScanDataOfChannel(34)
%{
hardware.setIsConnectedMfDriftMonitor(true);
hardware.getMfDriftMonitor().dmiGetAxesOpticalPowerDC()
hardware.getMfDriftMonitor().dmiGetAxesOpticalPower()
%}


hardware.getWebSwitchBeamline().turnOnRelay1()
hardware.getWebSwitchBeamline().turnOnRelay2()
hardware.getWebSwitchBeamline().isOnRelay1()
hardware.getWebSwitchBeamline().isOnRelay2()


