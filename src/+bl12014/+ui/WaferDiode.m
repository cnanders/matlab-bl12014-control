classdef WaferDiode < mic.Base
    
    properties

        % {mic.ui.device.GetNumber 1x1}}
        uiCurrent
        
        
    end
    
    properties (SetAccess = private)
        
        dWidth = 450
        dHeight = 65
        
        cName = 'wafer-diode'
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 70
        dWidthUnit = 180
        dWidthVal = 75
        dWidthPadUnit = 25 %277

        
        configStageY
        configMeasPointVolts
        
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    methods
        
        function this = WaferDiode(varargin)
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
        
        
            
        function turnOn(this)
            this.uiCurrent.turnOn();
        end
        
        function turnOff(this)
            this.uiCurrent.turnOff();
        end
        
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wafer Diode',...
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
                'config-wafer-current.json' ...
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
                'fhGet', @() this.hardware.getKeithley6482Wafer().read(2), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', 'wafer-diode', ...
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

