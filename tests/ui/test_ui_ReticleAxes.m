try
    purge
catch mE
end

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', '..', 'src')));
addpath(genpath(fullfile(cDirThis, '..', '..', 'mpm-packages')));


clock = mic.Clock('Master');

ui = bl12014.ui.ReticleAxes(...
    'dWidth', 400, ...
    'dHeight', 400, ...
    'clock', clock ...
);


dWidth = 800;
dHeight = 800;

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

cb = @(src, evt) (fprintf('x %1.3f, y %1.3f \n', evt.stData.dX, evt.stData.dY));
addlistener(ui, 'eClickField', cb);


 

