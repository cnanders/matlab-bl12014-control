clear
close all
clear classes

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirVendor = fullfile(cDirThis, '..', 'vendor');

cDirCwcork = fullfile(cDirVendor, 'cwcork');
javaaddpath(fullfile(cDirCwcork, 'BL1201CorbaProxy.jar'));

bl1201 = cxro.bl1201.beamline.BL1201CorbaProxy();
dSend = 9
dResponse = bl1201.beepTest(dSend)
if dResponse == dSend
    disp('it worked!')
else
    disp('it failed.');
end


bl1201.Mono_FindIndex();