classdef ReticleDiode < mic.Base
    
    properties

        % {mic.ui.device.GetNumber 1x1}}
        uiCurrent
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiComm
        
    end
    
    properties (SetAccess = private)
        
        dWidth = 600
        dHeight = 65
        
        cName = 'reticle-diode'
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 70
        dWidthUnit = 80
        dWidthVal = 75
        dWidthPadUnit = 277
        
        configStageY
        configMeasPointVolts
        
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    methods
        
        function this = ReticleDiode(varargin)
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
                'Title', 'Reticle Diode',...
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
            
            this.uiCurrent.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
           
            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end    
        
        
    end
    
    methods (Access = private)
                
         
        function initUiCurrent(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-reticle-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCurrent = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'reticle-diode', ...
                'fhGet', @() this.hardware.getKeithley6482Reticle().read(1), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'config', uiConfig, ...
                'cLabel', 'Current' ...
            );
        end
        
        
        
        
        
        function init(this)
            this.msg('init()');
            this.initUiCurrent();
            
        end
        
        
        
    end
    
    
end

