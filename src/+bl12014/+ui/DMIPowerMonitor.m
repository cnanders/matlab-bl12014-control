classdef DMIPowerMonitor < mic.Base
    
    properties
        
        % {mic.ui.TaskSequence 1x1}}
        ui
        
    end
    
    
    
    properties (Access = private)
        
        % {mic.Clock 1x1}
        clock
        
        % {mic.Clock | mic.ui.Clock 1x1}
        uiClock
               
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    properties (SetAccess = private)
        
        cName = 'dmi-power-monitor-'
        dHeight = 24
        dWidth = 350
    end
    
    methods
        
        function this = DMIPowerMonitor(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
        
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.ui.build(hParent, dLeft, dTop, this.dWidth);
            
        end
        
        
        
        
        function delete(this)
            
            
            
            
        end  
        
        function st = save(this)
            
             st.uiStageY = this.uiStageY.save();
            
        end
        
        function load(this, st)
            
        end
        
        
    end
    
    
    methods (Access = private)
        
         function initUi(this)
             
             this.ui = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-dmi-power-is-ok'], ...
                'task', bl12014.Tasks.createStateDMIPowerIsOK(...
                    [this.cName, 'state-dmi-power-is-ok'], ...
                    this.hardware, ...
                    this.clock ...
                ), ...
                'lShowButton', false, ...
                'clock', this.uiClock ...
            );
        
        
         end
                
        
        
        
        function init(this)
            
            this.initUi();
        end
        
        
    end
    
    
end

