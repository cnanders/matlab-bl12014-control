try
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));


clock = mic.Clock('master');
hardware = bl12014.Hardware('clock', clock);


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


