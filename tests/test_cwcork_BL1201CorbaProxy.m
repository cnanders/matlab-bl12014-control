clear
close all
clear classes

javaaddpath('BL1201CorbaProxy.jar');
bl1201 = cxro.bl1201.beamline.BL1201CorbaProxy();
dSend = 9
dResponse = bl1201.beepTest(dSend)
if dResponse == dSend
    disp('it worked!')
else
    disp('it failed.');
end

