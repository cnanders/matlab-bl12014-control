classdef DCTWaferStage < mic.Base
    
    properties
            
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiX
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiY
        
        
        % {mic.ui.common.PositionRecaller 1x1}
        uiPositionRecaller
        
        
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 540
        dHeight = 250           
        cName = 'dct-wafer-stage'
        lShowRange = true
        lShowStores = false
        lShowZero = false
        lShowRel = false
        lShowInitButton = true
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 30
        
        
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    methods
        
        function this = DCTWaferStage(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
        
        end
        
           
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wafer Stage (SmarAct)',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
            dTop = 20;
            dLeft = 10;
            dSep = 24;
            
            this.uiX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep + 10;
            
            dWidth = this.dWidth - 2 * dLeft;
            this.uiPositionRecaller.build(this.hPanel, dLeft, dTop, dWidth, 145);
            
            
        end
        
        function delete(this)
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);  
            this.uiX.delete();
            this.uiY.delete();
            
        end 
        
        
        function cec = getPropsSaved(this)
            cec = {...
                'uiX', ...
                'uiY' ...
            };
        end
        
        
        function st = save(this)
             cecProps = this.getPropsSaved();
            
            st = struct();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                if this.hasProp( cProp)
                    st.(cProp) = this.(cProp).save();
                end
            end

             
        end
        
        function load(this, st)
                        
            cecProps = this.getPropsSaved();
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
        
        function initUiX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-dct-wafer-stage-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            u8Index = 1;
            u8Axis = 1; % hardware channel x/y is 90 degrees from the x/y we want so we switched for GUI
            
            this.uiX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-x', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'lShowInitButton', this.lShowInitButton, ...
                ...
                'fhGet', @() this.hardware.getDCTWaferStage().getPosition(u8Index, u8Axis), ...
                'fhSet', @(dVal) this.hardware.getDCTWaferStage().setPosition(u8Index, u8Axis, dVal), ...
                'fhIsReady', @() ~this.hardware.getDCTWaferStage().getIsMoving(u8Index, u8Axis), ...
                'fhStop', @() this.hardware.getDCTWaferStage().stop(u8Index, u8Axis), ...
                'fhInitialize', @() mic.Utils.evalAll(...
                    @() this.hardware.getDCTWaferStage().findReferenceMark(u8Index, u8Axis) ...
                ), ... % wrap because fhInitialize doesn't expect a return but initializeAxis returns something
                'fhIsInitialized', @() this.hardware.getDCTWaferStage().getIsReferenced(u8Index, u8Axis), ...
                ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'X' ...
            );
        end
        
        function initUiY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-dct-wafer-stage-y.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            u8Index = 1;
            u8Axis = 0; % hardware channel x/y is 90 degrees from the x/y we want so we switched for GUI
            
            this.uiY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-y', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'lShowInitButton', this.lShowInitButton, ...
                ...
                'fhGet', @() this.hardware.getDCTWaferStage().getPosition(u8Index, u8Axis), ...
                'fhSet', @(dVal) this.hardware.getDCTWaferStage().setPosition(u8Index, u8Axis, dVal), ...
                'fhIsReady', @() ~this.hardware.getDCTWaferStage().getIsMoving(u8Index, u8Axis), ...
                'fhStop', @() this.hardware.getDCTWaferStage().stop(u8Index, u8Axis), ...
                'fhInitialize', @() mic.Utils.evalAll(...
                    @() this.hardware.getDCTWaferStage().findReferenceMark(u8Index, u8Axis) ...
                ), ... % wrap because fhInitialize doesn't expect a return but initializeAxis returns something
                'fhIsInitialized', @() this.hardware.getDCTWaferStage().getIsReferenced(u8Index, u8Axis), ...
                ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Y' ...
            );
        end
        

        
        % Return list of values from your app
        function dValues = onUiPositionRecallerGet(this)
            dValues = [...
                this.uiX.getValRaw(), ...
                this.uiY.getValRaw(), ...
            ];
        end
        
        % Set recalled values into your app
        function onUiPositionRecallerSet(this, dValues)
            this.uiX.setDestRaw(dValues(1));
            this.uiY.setDestRaw(dValues(2));
            this.uiX.moveToDest();
            this.uiY.moveToDest();
        end
        
        function initUiPositionRecaller(this)
            
            cDirThis = fileparts(mfilename('fullpath'));
            cPath = fullfile(cDirThis, '..', '..', 'save', 'position-recaller');
            this.uiPositionRecaller = mic.ui.common.PositionRecaller(...
                'cConfigPath', cPath, ... 
                'cName', [this.cName, '-position-recaller'], ...
                'cTitleOfPanel', 'Position Stores', ...
                'lShowLabelOfList', false, ...
                'hGetCallback', @this.onUiPositionRecallerGet, ...
                'hSetCallback', @this.onUiPositionRecallerSet ...
            );
        end
        
        
        function init(this)
            this.msg('init()');
            this.initUiX();
            this.initUiY();
            this.initUiPositionRecaller();
        end
        
        
        
    end
    
    
end

