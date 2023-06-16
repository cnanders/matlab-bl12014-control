classdef PowerPmacHydraMotMinGradLowNormHighMonitor < mic.Base
        
    properties (Constant)
       
        dWidth  = 300
        
    end
    
	properties
        
        
        
    end
    
    properties (SetAccess = private)
        
        hPanel
        cName = 'ppmac-hydra-mot-min-grad-low-norm-high-monitor-'
        ui
        
        
    end
    
    properties (Access = private)
                      
        clock
        uiClock
        dDelay = 0.5
        
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = PowerPmacHydraMotMinGradLowNormHighMonitor(varargin)
            
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
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
            
            
        end
        
        
        function build(this, hParent, dLeft, dTop)
                    
            
            dSep = 30;
            this.ui.build(hParent, dLeft, dTop, this.dWidth);
            
        end
        
        function cec = getPropsDelete(this)
            
            cec = {...
                'ui', ...
            };
        
        end
        
        %% Destructor
        
        function delete(this)
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);  
            
            cecProps = this.getPropsDelete();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                cMsg = sprintf('delete() deleting %s', cProp);
                this.msg(cMsg, this.u8_MSG_TYPE_CLASS_DELETE);  
                this.(cProp).delete();
            end
            
        end
        
        function st = save(this)
            st = struct();
            
        end
        
        function load(this, st)
        end
        
    end
    
    methods (Access = private)
        
        function init(this)
            
            this.msg('init()');
            
            this.ui = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui'], ...
                'task', bl12014.Tasks.createStatePpmacHydraMotMinMotGradLowNormHighOK(...
                    [this.cName, 'state'], ...
                    this.hardware, ...
                    this.clock ...
                ), ...
                'dDelay', 0.25, ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
        end
        
        
        
        
        
        
    end % private
    
    
end