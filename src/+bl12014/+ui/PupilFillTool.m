classdef PupilFillTool < mic.Base
    
    
	properties (Constant)
    
    end
    
    
    properties
            
    end
    
    properties (SetAccess = private)
        
        dWidth              = 420;
        dHeight             = 190;
        
    end
    
    properties (Access = private)
                              
        hPanel
        cDir
        uilOptions
        cDirThis
        cDirSrc
        cDirSave
        
        uitQA
                                
    end
    
        
    events
        
        eSizeChange
        
    end
    

    
    methods
        
        
        function this = PupilFillTool(varargin)
            
            this.cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSrc = fullfile(this.cDirThis, '..', '..');
            this.cDirSave = fullfile(this.cDirSrc, 'save', 'scanner-pupil');
        
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end 
            
            this.init();   
        end
        
                
        function build(this, hParent, dLeft, dTop)
                                    
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Pupil Fill',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
			drawnow;
            
            dPad = 10;
            this.uilOptions.build(this.hPanel, ...
                10, ...
                20, ...
                this.dWidth - 20, ...
                this.dHeight - 3*dPad - mic.Utils.dEDITHEIGHT ...
            );
        
            this.uitQA.build(...
                this.hPanel, ...
                10, ...
                160, ...
                30, ...
                20 ...
            );
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
                        
        end
        
        
        
        % @return {char 1xm} selected pupil fill
        function c = get(this)
            ceSelected = this.uilOptions.get();
            if ~isempty(ceSelected)
                c = ceSelected{1};
            else 
                % Throw an error
            end
        end
        
        % @return {struct} state to save
        function st = save(this)
            % Store the name of the selected fill.  Try to select it on
            % load
            st = struct();
            st.cSelected = this.get();
        end
        
        % @param {struct} state to load.  See save() for struct props
        function load(this, st)
            
            % strcmp returns a {logical} list
            lMatches = strcmp(st.cSelected, this.uilOptions.getOptions());
            if any(lMatches)
                this.uilOptions.setSelectedIndexes(uint8(find(lMatches)));
            end
        end


    end
    
    methods (Access = private)
        
        function init(this)
              
            this.msg('init()');
            this.uilOptions = mic.ui.common.List(...
                'ceOptions', cell(1,0), ...
                'cLabel', '', ...
                'lShowDelete', true, ...
                'lShowMove', true, ...
                'lShowLabel', false, ...
                'lShowRefresh', true ...
            );
            this.uilOptions.setRefreshFcn(@this.refresh);
            this.uilOptions.refresh();
            
            this.uitQA = mic.ui.common.Toggle(...
                'cTextTrue', 'X', ...
                'cTextFalse', 'OK' ...
            );
            
            addlistener(this.uilOptions, 'eChange', @this.onOptionsChange);
            addlistener(this.uitQA, 'eChange', @this.onQA);

            
            
        end
        
        function ceReturn = refresh(this)
            ceReturn = mic.Utils.dir2cell(this.cDirSave, 'date', 'descend', '*.mat');
        end
        
        function onOptionsChange(this, ~, ~)
            
            %{
            ceSelected = this.uilOptions.get();
            if ~isempty(ceSelected)
                this.cSelected = ceSelected{1};
            end
            %}
        end
        
        function onQA(this, ~, ~)
            
            if this.uitQA.get()
                set(this.hPanel, ...
                    'BackgroundColor', [1 .6 1] ...
                );
            else
                set(this.hPanel, ...
                    'BackgroundColor', [.94 .94 .94] ...
                );
            end
            
        end
        
    end 
    
    
end