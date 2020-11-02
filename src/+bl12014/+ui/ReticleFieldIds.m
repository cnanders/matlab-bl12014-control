classdef ReticleFieldIds < mic.Base
    
    properties
        
        % {mic.ui.common.Edit 1x1}}
        uiRow1
        
        % {mic.ui.common.Edit 1x1}}
        uiCol1
        
         % {mic.ui.common.Edit 1x1}}
        uiRow2
        
        % {mic.ui.common.Edit 1x1}}
        uiCol2
                
        % {mic.ui.common.PositionRecaller 1x1}
        uiPositionRecaller
                
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 600
        dHeight = 165
        dWidthEdit = 60
        cName = 'Reticle-Field-Ids'
        
    end
    
    properties (Access = private)
        
        
        hPanel
        
        dWidthName = 30
        
        fhOnChange = @() [] % set to executed code if anything changes


        
    end
    
    methods
        
        function this = ReticleFieldIds(varargin)
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
            dSep = 80;
            dLeftCol2 = 80;
                        
            this.uiRow1.build(this.hPanel, dLeft, dTop, this.dWidthEdit, 24);
            
            dLeft = dLeftCol2;
            
            
            this.uiCol1.build(this.hPanel, dLeft, dTop, this.dWidthEdit, 24);
            dTop = dTop + dSep;
            
            dLeft = 10;
            this.uiRow2.build(this.hPanel, dLeft, dTop, this.dWidthEdit, 24);
            dLeft = dLeftCol2;
            
            this.uiCol2.build(this.hPanel, dLeft, dTop, this.dWidthEdit, 24);
            dTop = dTop + dSep;
            
            
            dLeft = 170;
            dTop = 15;
            dWidth = 420;
            this.uiPositionRecaller.build(this.hPanel, dLeft, dTop, dWidth, 140);
            
            

            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end  
        
        function cec = getSaveLoadProps(this)
            cec = {...
                'uiRow1', ...
                'uiCol1', ...
                'uiRow2', ...
                'uiCol2', ...
             };
        end
        
        
        function st = save(this)
            cecProps = this.getSaveLoadProps();
            
            st = struct();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                if this.hasProp( cProp)
                    st.(cProp) = this.(cProp).save();
                end
            end
             
        end
        
        function load(this, st)
                        
            cecProps = this.getSaveLoadProps();
            for n = 1 : length(cecProps)
               cProp = cecProps{n};
               if isfield(st, cProp)
                   if this.hasProp( cProp )
                        this.(cProp).load(st.(cProp))
                   end
               end
            end
                        
        end
        
    end
    
    methods (Access = private)
        
         
         
        function initUiRow1(this)
            
            this.uiRow1 = mic.ui.common.Edit(...
                'cType', 'u8', ...
                'cName', [this.cName, 'row1'], ...
                'fhDirectCallback', @(src, evt) this.onChangeRow(), ...
                'cLabel', 'Ref Row' ...
            );
        end
        
        function initUiCol1(this)
            
            this.uiCol1 = mic.ui.common.Edit(...
                'cType', 'u8', ...
                'cName', [this.cName, 'col1'], ...
                'fhDirectCallback', @(src, evt) this.onChangeCol(), ...
                'cLabel', 'Ref Col' ...
            );
        end
        
        function initUiRow2(this)
            
            this.uiRow2 = mic.ui.common.Edit(...
                'cType', 'u8', ...
                'cName', [this.cName, 'row2'], ...
                'fhDirectCallback', @(src, evt) this.onChangeRow(), ...
                'cLabel', 'Test Row' ...
            );
        end
        
        function initUiCol2(this)
            
            this.uiCol2 = mic.ui.common.Edit(...
                'cType', 'u8', ...
                'cName', [this.cName, 'col2'], ...
                'fhDirectCallback', @(src, evt) this.onChangeCol(), ...
                'cLabel', 'Test Col' ...
            );
        end
        
        function setSaveName(this)
            
            cVal = sprintf('ref[%1.0f,%1.0f] vs. test[%1.0f,%1.0f]', ...
                this.uiRow1.get(), ...
                this.uiCol1.get(), ...
                this.uiRow2.get(), ...
                this.uiCol2.get() ...
            );
            this.uiPositionRecaller.setSaveName(cVal);
        end
        
        
        function onChangeRow(this)
            this.setSaveName();
            this.fhOnChange();
        end
        
        
        function onChangeCol(this)
            this.setSaveName();
            this.fhOnChange();
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
                'dWidthLoadSave', 180, ...
                'hGetCallback', @this.onUiPositionRecallerGet, ...
                'hSetCallback', @this.onUiPositionRecallerSet ...
            );
        end
        
        
        function init(this)
            this.msg('init()');
            this.initUiRow1();
            this.initUiCol1();
            this.initUiRow2();
            this.initUiCol2();
            this.initUiPositionRecaller();
            
        end
        
        % Return list of values from your app
        function dValues = onUiPositionRecallerGet(this)
            dValues = [...
                this.uiRow1.get(), ...
                this.uiCol1.get(), ...
                this.uiRow2.get(), ...
                this.uiCol2.get(), ...
            ];
        end
        
        % Set recalled values into your app
        function onUiPositionRecallerSet(this, dValues)
             % Update the UI destinations
            this.uiRow1.set(uint8(dValues(1)));
            this.uiCol1.set(uint8(dValues(2)));
            this.uiRow2.set(uint8(dValues(3)));
            this.uiCol2.set(uint8(dValues(4)));
            
        end
        
        
        
    end
    
    
end

