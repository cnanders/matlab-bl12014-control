classdef FocusLog < mic.Base
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        cDirSave
        cName
        dWidth = 300
        dHeight = 300
        dNumCharsPre = 40
        dNumResults = 20
        
        
    end
    
    properties (Access=private)
        uiTextHistory
        hPanel
        uiClock
        cDirThis
    end
    
    methods 
        
        function this = FocusLog(varargin)
            
            
            cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSave = fullfile(cDirThis, '..', '..', 'save', 'fem-scans');
                        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
        end
        
        
        function init(this)
            this.uiTextHistory = mic.ui.common.Text(...
                'lShowLabel', false, ...
                'cLabel', 'Focus of last 20 non-aborted FEMs (updates every 60s)');
        end
        
        
        function build(this, hParent, dLeft, dTop)
            
    
            cTitle = sprintf('Focus of last %1.0f non-aborted FEMs (updates every min)', this.dNumResults);
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', cTitle,...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                    dLeft ...
                    dTop ...
                    this.dWidth...
                    this.dHeight], ...
                    hParent ...
                ) ...
            );
        
            dLeft = 10;
            dTop = 20;
        
            this.uiTextHistory.build(this.hPanel, dLeft, dTop, this.dWidth - 2*dLeft, this.dHeight - 2*dTop);
            this.update();
            
            this.uiClock.add(@this.onClock, this.id(), 60);

            
        end
        
        function onClock(this, ~, ~)
            this.update();
        end
        
        function update(this)
            
            lDebug = false;
            
            cPathOfDir = mic.Utils.path2canonical(this.cDirSave);
            stResults = dir(cPathOfDir);
            
            % create a list of datenum of each returned item
            dDates = [stResults.datenum];
            
            % sort and store the indexes
            [dDatesSorted, dIdx] = sort(dDates, 'descend');
            
            cecValues = {};
            
            n = 1; % initialize index 
            
            while length(cecValues) < this.dNumResults
                if length(dIdx) < n
                    break
                end
                dIndex = dIdx(n);
                
                cName =  stResults(dIndex).name;
                % skip macos defaults
                if any(strcmpi(cName, {'.', '..'}))
                    n = n + 1;
                    continue
                end
                
                % check for the result.json file inside
                cPath = fullfile(cPathOfDir, cName, 'result.json');
                if java.io.File(cPath).exists % WAY FASTER than exist(cPath, 'file') == 2
                    if lDebug
                        fprintf('%s\n', cName);
                    end
                    % try reading the log to extract the prescription
                    try
                        fid = fopen(cPath, 'r');
                        cText = fread(fid, inf, 'uint8=>char');
                        fclose(fid);
                        stResult = jsondecode(cText');
                        
                        % prescription
                        cPre = stResult.recipe;
                        
                        % try reading the prescription to extract center
                        % focus
                        try 
                            fid = fopen(cPre, 'r');
                            cText = fread(fid, inf, 'uint8=>char');
                            fclose(fid);
                            stResult = jsondecode(cText');
                            
                            dFocus = stResult.fem.dFocusCenter;
                            if lDebug
                                fprintf('%1.0f\n', dFocus);
                            end
                            
                            cecValues{end+1} = sprintf('%1.0f   %s', dFocus, cName(1:this.dNumCharsPre));
                        catch
                            if lDebug
                                fprintf('could not read/parse %s file', cPre);
                            end
                            n = n + 1;
                            continue
                        end
                    catch
                        if lDebug
                            fprintf('could not read/parse log %s file', cPath);
                        end
                        n = n + 1;
                        continue
                    end
                end
                
                n = n + 1;
            end
            
            this.uiTextHistory.set(cecValues);
                        
        end
        
    end
    
end

