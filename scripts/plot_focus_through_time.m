% plot_focus_through_time

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', 'mpm-packages')));


cPath = fullfile(cDirThis, '..', 'src', 'save', 'prescriptions');
cSortBy = 'date';
cSortMode = 'descend';
cFilter = '*.mat';
ceReturn = mic.Utils.dir2cell(cPath, cSortBy, cSortMode, cFilter);

dFocus = zeros(size(ceReturn));
dTime(length(ceReturn)) = datetime; % initialize as datetime, fill in the for loop.
for n = 1 : length(ceReturn)
    cFile = ceReturn{n};
    
    try
        cDateStr = cFile(1:15);
        dt = datetime(cDateStr, 'InputFormat', 'yyyyMMdd-HHmmss');
    catch mE
        fprintf('skipping %s\n', cFile);
        fprintf('First 15 characters are not date\n');
        continue
    end
    
    load(fullfile(cPath, cFile)); % loads {struct} st into workspace
    
    if ~isfield(st, 'uiFemTool')
        continue
    end
    
    if isfield(st.uiFemTool, 'uieFocusCenter')
        dFocus(n) = st.uiFemTool.uieFocusCenter.xVal;
    elseif isfield(st.uiFemTool, 'dFocusCenter')
        dFocus(n) = st.uiFemTool.dFocusCenter;
    end
    dTime(n) = dt;
end

figure
plot(dTime, dFocus, '.b')
