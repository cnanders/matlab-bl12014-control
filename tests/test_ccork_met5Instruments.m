[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirVendor = fullfile(cDirThis, '..', 'vendor');

% dependency
cDirCwcork = fullfile(cDirVendor, 'cwcork');
javaaddpath(fullfile(cDirCwcork, 'Met5Instruments.jar'));

% make canonical path
jFile = java.io.File(cDirCwcork);
c = char(jFile.getCanonicalPath);

try
    jMet5Instruments = cxro.met5.Instruments();
    fprintf('success\n');
catch mE
    jMet5Instruments = [];
    throw(mE)
    fprintf('fail\n');
end


 

