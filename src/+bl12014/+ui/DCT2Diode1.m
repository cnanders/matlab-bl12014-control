classdef DCT2Diode < mic.Base
    
    properties
        
        % {mic.ui.device.GetNumber 1x1}
        ui
        
    end
    
    
    
    properties (Access = private)
        
        clock
       
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    properties (SetAccess = private)
        
        cName = 'dct2-diode-'
        dHeight = 80
    end
    
    methods
        
        function this = DCT2Diode(varargin)
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
            this.ui.build(this.hParent, dLeft, dTop);
            
        end
        
        
        
        function delete(this)
   
        end  
        
        function st = save(this)
            
            st = struct();
            % st.uiStageY = this.uiStageY.save();
            
        end
        
        function load(this, st)
            %{
            if isfield(st, 'uiStageY')
                this.uiStageY.load(st.uiStageY)
            end
            %}
        end
        
        
    end
    
    
    methods (Access = private)
        
      
        function get(this)
            
            dVolts = this.hardware.getDataTranslation().getScanDataOfChannel(33);
            dGain = this.hardware.getDCT2Sr5702.
            
        end
        
        function initUi(this)
            
            this.msg('initUi()');
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-dct2-current-1.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
        
            this.ui = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', [this.cName, 'measur-point'], ...
                'config', uiConfig, ...
                'cLabel', 'MeasurPoint', ...
                'lShowInitButton', false, ...
                'dWidthPadUnit', 277, ...
                'lShowLabels', false, ...
                'fhGet', @() this.get(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true ...
            );
        end
        
        
        function init(this)
            
            this.msg('init()');
            this.initUiStageY();
            this.initUi();
        end
        
        function onFigureCloseRequest(this, src, evt)
            this.msg('closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        
        
        
    end
    
    
end

