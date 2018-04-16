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
        uiListDir
        cDirThis
        cDirSrc
        cDirSave
        
        uitQA
        
        dWidthBorderPanel = 0
                                
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
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
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
                'BorderWidth', this.dWidthBorderPanel, ...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
			drawnow;
            
            dPad = 10;
            this.uiListDir.build(this.hPanel, ...
                10, ...
                20, ...
                this.dWidth - 20, ...
                this.dHeight - 3*dPad - mic.Utils.dEDITHEIGHT ...
            );
        
            this.uitQA.build(...
                this.hPanel, ...
                this.dWidth - 60, ...
                160, ...
                40, ...
                24 ...
            );
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
                        
        end
        
        
        
        % @return {char 1xm} selected pupil fill
        function c = get(this)
            ceSelected = this.uiListDir.get();
            if ~isempty(ceSelected)
                c = ceSelected{1};
            else 
                % Throw an error
            end
        end
        
        
        function st = save(this)
            st = struct();
        	st.uiListDir = this.uiListDir.save();
        end
        
        function load(this, st)
            
            if isfield(st, 'uiListDir') 
                this.uiListDir.load(st.uiListDir);
            end
        end


    end
    
    methods (Access = private)
        
        function init(this)
              
            this.msg('init()');
            this.uiListDir = mic.ui.common.ListDir(...
                'cLabel', '', ...
                'cDir', this.cDirSave, ...
                'lShowDelete', false, ...
                'lShowMove', false, ...
                'lShowLabel', false, ...
                'lShowRefresh', true ...
            );
            
            this.uitQA = mic.ui.common.Toggle(...
                'cTextTrue', 'X', ...
                'cTextFalse', 'OK' ...
            );
            
            addlistener(this.uitQA, 'eChange', @this.onQA);
            
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