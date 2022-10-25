classdef DiodeBL12012 < mic.Base
    
    properties
                
        % {mic.ui.device.GetNumber 1x1}
        uiCurrent
        
    end
    
    
    
    properties (Access = private)
        
        clock
        dWidth = 400
       
        hPanel
                
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    properties (SetAccess = private)
        
        cName = 'diode-bl12012-'
         dHeight = 50
    end
    
    methods
        
        function this = DiodeBL12012(varargin)
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
                'Title', 'Diode BL12012',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
            dLeft = 0;
            dTop = 15;
                        
            this.uiCurrent.build(this.hPanel, dLeft, dTop);
            
        end
        
        
        
        function delete(this)
                        
            
        end  
        
        function st = save(this)
            
            st = struct();
            
        end
        
        function load(this, st)
            
        end
        
        
    end
    
    
    methods (Access = private)
        
                
        
        function initUiCurrent(this)
            
            this.msg('initUiCurrent()');
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-diode-bl12012.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiCurrent = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', [this.cName, 'measur-point'], ...
                'config', uiConfig, ...
                'cLabel', 'SR570 to MeasurPoint Ch 40', ...
                'lShowInitButton', false, ...
                'dWidthName', 150, ...
                'lShowLabels', false, ...
                'fhGet', @() this.hardware.getDataTranslation().getScanDataOfChannel(40), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true ...
            );
        end
        
        
        function init(this)
            
            this.msg('init()');
            this.initUiCurrent();
        end
        
        function onFigureCloseRequest(this, src, evt)
            this.msg('closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        
        
        
    end
    
    
end

