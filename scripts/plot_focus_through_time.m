% plot_focus_through_time

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(cDirThis, '..', 'mpm-packages')));


cPath = fullfile(cDirThis, '..', 'src', 'save', 'prescriptions');
cSortBy = 'date';
cSortMode = 'descend';
cFilter = '*.mat';
ceReturn = mic.Utils.dir2cell(cPath, cSortBy, cSortMode, cFilter);

dFocus = zeros(size(ceReturn));
dTime(length(ceReturn)) = datetime;
for n = 1 : length(ceReturn)
    cFile = ceReturn{n};
    cDateStr = cFile(1:15);
    load(fullfile(cPath, cFile)); % loads {struct} st into workspace
    
    if isfield(st, 'uieFocusCenter')
        dFocus(n) = st.uiFemTool.uieFocusCenter.xVal;
    elseif isfield(st, 'dFocusCenter')
        dFocus(n) = st.dFocusCenter;
    end
    dTime(n) = datetime(cDateStr, 'InputFormat', 'yyyyMMdd-HHmmss');
end
