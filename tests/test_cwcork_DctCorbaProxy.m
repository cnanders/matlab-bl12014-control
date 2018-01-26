clear
clc
close all
clear classes

javaaddpath('DctCorbaProxy.jar');
dct = cxro.bl1201.dct.DctCorbaProxy();
dct.beepTest(9)

dSend = 9
dResponse = dct.beepTest(dSend)
if dResponse == dSend
    disp('it worked!')
else
    disp('it failed.');
end