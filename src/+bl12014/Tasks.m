classdef Tasks < mic.Base
        
    properties (Constant)
       
        
        
    end
    
	properties
        
       
    end
    
    properties (SetAccess = private)
        
        
        
    end
    
    properties (Access = private)
                    
        
        
        % {mic.TaskSequence 1x1}
        turnOnWaferHydra
        turnOnReticleHydra
        turnOnLsiHydra
       
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = Tasks(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
                       
            
        end
        
        % @param {bl12014.ui.App 1x1} uiApp
        % @param {mic.Clock 1x1} clock (NOT mic.ui.Clock)
        function populateTasks(this, uiApp, clock)
            
            this.turnOnWaferHydra = this.createTurnOnWaferHydra(uiApp, clock);
            this.turnOnReticleHydra = this.createTurnOnReticleHydra(uiApp, clock);
            this.turnOnLsiHydra = this.createTurnOnLsiHydra(uiApp, clock);
        end
        
        
        function task = getTurnOnWaferHydra(this)
            
        end

    end
    
    
    methods (Access = private)
        
        function task = createTurnOnWaferHydra(this, uiApp, clock)
            
            ceTasks = {...
                mic.Task.fromUiGetSetText(uiApp.uiWafer.uiWorkingMode.uiWorkingMode, '0'), ...
                mic.Task.fromUiGetSetNumber(uiApp.uiWafer.uiMotMin.ui1, 4, 0.1, 'A'), ...
                mic.Task.fromUiGetSetNumber(uiApp.uiWafer.uiMotMin.ui2, 4, 0.1, 'A'), ...
                mic.Task.fromUiGetSetText(uiApp.uiWafer.uiWorkingMode.uiWorkingMode, '1') ...
            };
            
            task = mic.TaskSequence(...
                'clock', clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'cName', 'Turn On Wafer Hydra' ...
            );
        end
        
        
        function task = createTurnOnReticleHydra(this)
            task = {}
        end
        
        function task = createTurnOnLsiHydra(this)
            task = {}
        end
        
        
        
        
    end 
    
    
end