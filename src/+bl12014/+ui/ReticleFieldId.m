classdef ReticleFieldId < mic.Base
    
    properties
        
        % {mic.ui.common.Edit 1x1}}
        uiRow
        
        % {mic.ui.common.Edit 1x1}}
        uiCol
                
        % {mic.ui.common.PositionRecaller 1x1}
        uiPositionRecaller
                
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 430
        dHeight = 165
        dWidthEdit = 40
        cName = 'ReticleFieldId'
        
    end
    
    properties (Access = private)
        
        
        hPanel
        
        dWidthName = 30


        
    end
    
    methods
        
        function this = ReticleFieldId(varargin)
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
                'Title', this.cName,...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;            

            dTop = 20;
            dLeft = 10;
            dSep = 40;
                        
            this.uiRow.build(this.hPanel, dLeft, dTop, this.dWidthEdit, 24);
            dTop = dTop + dSep;
            
            this.uiCol.build(this.hPanel, dLeft, dTop, this.dWidthEdit, 24);
            dTop = dTop + dSep;
            
            dLeft = 60;
            dTop = 15;
            dWidth = 360;
            this.uiPositionRecaller.build(this.hPanel, dLeft, dTop, dWidth, 140);
            
            

            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end  
        
        
        function st = save(this)
            st = struct();
            st.uiRow = this.uiRow.save();
            st.uiCol = this.uiCol.save();
            
        end
        
        function load(this, st)
            if isfield(st, 'uiRow')
                this.uiRow.load(st.uiRow)
            end
            
            if isfield(st, 'uiCol')
                this.uiCol.load(st.uiCol)
            end
            
        end
        
        
    end
    
    methods (Access = private)
        
         
         
        function initUiRow(this)
            
            this.uiRow = mic.ui.common.Edit(...
                'cType', 'u8', ...
                'cName', [this.cName, 'row'], ...
                'fhDirectCallback', @(src, evt) this.onChangeRow(), ...
                'cLabel', 'Row' ...
            );
        end
        
        function initUiCol(this)
            
            this.uiCol = mic.ui.common.Edit(...
                'cType', 'u8', ...
                'cName', [this.cName, 'col'], ...
                'fhDirectCallback', @(src, evt) this.onChangeCol(), ...
                'cLabel', 'Col' ...
            );
        end
        
        function setSaveName(this)
            
            cVal = sprintf('[%1.0f, %1.0f]', this.uiRow.get(), this.uiCol.get());
            this.uiPositionRecaller.setSaveName(cVal);
        end
        
        
        function onChangeRow(this)
            this.setSaveName();
        end
        
        
        function onChangeCol(this)
            this.setSaveName();
        end
        
  
        function initUiPositionRecaller(this)
            
            cDirThis = fileparts(mfilename('fullpath'));
            cPath = fullfile(cDirThis, '..', '..', 'save', 'position-recaller');
            this.uiPositionRecaller = mic.ui.common.PositionRecaller(...
                'cConfigPath', cPath, ... 
                'cName', [this.cName, '-position-recaller'], ...
                'cTitleOfPanel', 'Position Stores', ...
                'lShowLabelOfList', false, ...
                'lShowLoadButton', false, ...
                'lLoadOnSelect', true, ...
                'hGetCallback', @this.onUiPositionRecallerGet, ...
                'hSetCallback', @this.onUiPositionRecallerSet ...
            );
        end
        
        
        function init(this)
            this.msg('init()');
            this.initUiRow();
            this.initUiCol();
            this.initUiPositionRecaller();
            
        end
        
        % Return list of values from your app
        function dValues = onUiPositionRecallerGet(this)
            dValues = [...
                this.uiRow.get(), ...
                this.uiCol.get(), ...
            ];
        end
        
        % Set recalled values into your app
        function onUiPositionRecallerSet(this, dValues)
             % Update the UI destinations
            this.uiRow.set(uint8(dValues(1)));
            this.uiCol.set(uint8(dValues(2)));
            
        end
        
        
        
    end
    
    
end

