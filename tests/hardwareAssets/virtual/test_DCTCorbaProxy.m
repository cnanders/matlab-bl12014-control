try
    purge
end


[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirApp = fullfile(cDirThis, '..', '..', '..');
cDirSrc = fullfile(cDirApp, 'src');

% Generate a {1x1} SampleData 
a = bl12014.hardwareAssets.virtual.DCTCorbaProxy();


