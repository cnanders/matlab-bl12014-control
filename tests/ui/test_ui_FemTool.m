try
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));



clock = mic.Clock('Master');

ui = bl12014.ui.FemTool();


dWidth = 800;
dHeight = 700;

dScreenSize = get(0, 'ScreenSize');
            
h = figure( ...
    'Position', [ ...
        (dScreenSize(3) - dWidth)/2 ...
        (dScreenSize(4) - dHeight)/2 ...
        dWidth ...
        dHeight ...
     ] ...
);
ui.build(h, 10, 10);


cb = @(src, evt) (fprintf('femTool eSizeChange\n'));
addlistener(ui, 'eSizeChange', cb);


 

