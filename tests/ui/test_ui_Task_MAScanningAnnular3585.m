[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% bl12014 src
cDirBl12014 = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirBl12014));

% dependencies
cDirVendor = fullfile(cDirThis, '..', '..', 'vendor');

addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-instrument-control', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-quasar', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-gridded-pupil-fill', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-pupil-fill-generator', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-npoint-lc400-ui', 'src')));
addpath(genpath(fullfile(cDirVendor, 'github', 'cnanders', 'matlab-npoint-lc400', 'src')));
purge

clock = mic.Clock('Master');

ui = bl12014.ui.Scanner(...
    'cName', 'ma', ...
    'clock', clock ...
);

dWidth = 1650;
dHeight = 900;

dScreenSize = get(0, 'ScreenSize');
h = figure(...
    'Position', [ ...
        (dScreenSize(3) - dWidth)/2 ...
        (dScreenSize(4) - dHeight)/2 ...
        dWidth ...
        dHeight ...
    ] ...
);

ui.build(h, 10, 10);


state = bl12014.Tasks.createStateMAScanningAnnular3585('state', ui.uiNPointLC400, clock);
sequence = bl12014.Tasks.createSequenceSetMAToAnnular3585('sequence', ui, clock);

uiState = mic.ui.TaskSequence(...
    'cName', 'ui-state', ...
    'task', state, ...
    'lShowButton', false, ...
    'clock', clock ...
);
  

uiSequence = mic.ui.TaskSequence(...
    'cName', 'ui-sequence', ...
    'task', sequence, ...
    'lShowButton', true, ...
    'lShowIsDone', false, ...
    'clock', clock ...
);
  


uiState.build(h, 500, 500, 300);
uiSequence.build(h, 500, 550, 300);

 
