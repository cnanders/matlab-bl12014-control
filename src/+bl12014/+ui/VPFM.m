classdef VPFM < mic.Base
    
    properties
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiStageX
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 590
                
        hPanel
        
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    properties (SetAccess = private)
        
        cName = 'vpfm-'
        dHeight = 70
    end
    
    methods
        
        function this = VPFM(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
        
        end
        
    
        
                
        function build(this, hParent, dLeft, dTop)
            
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'VPFM',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
            dLeft = 0;
            dTop = 15;
            dSep = 30;
            
          
            this.uiStageX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            

            
        end
        
        
       
        
        
        function delete(this)
            
            
            
        end   
        
        function st = save(this)
            st = struct();
            st.uiStageX = this.uiStageX.save();
        end
        
        function load(this, st)
            if isfield(st, 'uiStageY')
                this.uiStageX.load(st.uiStageX)
            end
        end
        
        
    end
    
    methods (Access = private)
        
        
        
         
        function initUiStageX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-vpfm-stage-x-nm.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-x', this.cName), ...
                'config', uiConfig, ...
                'lShowInitButton', true, ...
                'fhGet', @() double(this.hardware.getSmarActVPFM().getPosition(0)), ...
                'fhSet', @(dVal) this.hardware.getSmarActVPFM().goToPositionAbsolute(0, dVal), ...
                'fhIsReady', @() ~this.hardware.getSmarActVPFM().getIsMoving(0), ...
                'fhStop', @() [], ...
                'fhInitialize', @() mic.Utils.evalAll(...
                    @() this.hardware.getSmarActVPFM().findReferenceMark(0) ...
                ), ... % wrap because fhInitialize doesn't expect a return but initializeAxis returns something
                'fhIsInitialized', @() this.hardware.getSmarActVPFM.getIsReferenced(0), ...            
                %{
                'fhGet', @() this.hardware.getSmarActVPFM().getAxisPosition(0), ...
                'fhSet', @(dVal) this.hardware.getSmarActVPFM().moveAxisAbsolute(0, dVal), ...
                'fhIsReady', @() this.hardware.getSmarActVPFM().getAxisIsReady(0), ...
                'fhStop', @() this.hardware.getSmarActVPFM().stopAxisMove(0), ...
                'fhInitialize', @() mic.Utils.evalAll(...
                    @() this.hardware.getSmarActVPFM().initializeAxis(0) ...
                ), ... % wrap because fhInitialize doesn't expect a return but initializeAxis returns something
                'fhIsInitialized', @() this.hardware.getSmarActVPFM.getAxisIsInitialized(0), ...
                %}
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'X' ...
            );
        end
        
        
        
        function init(this)
            
            this.msg('init');
            
            this.initUiStageX();
           
        end
        
         
        
    end
    
    
end

