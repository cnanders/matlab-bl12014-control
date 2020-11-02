classdef PowerPmacHydraMotMinMonitor < mic.Base
        
    properties (Constant)
       
        dWidth  = 300
        
    end
    
	properties
        
        
        
    end
    
    properties (SetAccess = private)
        
        hPanel
        cName = 'ppmac-hydra-mot-min-monitor-'
        
        uiWorkingMode
        uiMotMin
    
        uiStateOn
        uiSequenceOn
        
        
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
        
        
        function this = PowerPmacHydraMotMinMonitor(varargin)
            
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
            dWidthSequences = 24;
            this.uiStateOn.build(hParent, dLeft, dTop, this.dWidth);
            dLeft = dLeft + this.dWidth - dWidthSequences;
            this.uiSequenceOn.build(hParent, dLeft, dTop, dWidthSequences); 
            dTop = dTop + dSep;

            
            this.uiClock.add(@this.onClock, this.id(), this.dDelay);
            
                        
        end
        
        function cec = getPropsDelete(this)
            
            cec = {...
                'uiWorkingMode', ...
                'uiMotMin', ...
                'uiStateOn', ...
                'uiSequenceOn', ...
            };
        
        end
        
        %% Destructor
        
        function delete(this)
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);  
            this.uiClock.remove(this.id());
            
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
        
        
        function onClock(this, ~, ~)
              
            
            % Show the turn on Wafer?
            if this.uiStateOn.isDone()
                if ~this.uiSequenceOn.isExecuting()
                    this.uiSequenceOn.hide();
                end
            else
                this.uiSequenceOn.show();
            end

        end
        
        function init(this)
            
            this.msg('init()');
            
            this.uiWorkingMode = bl12014.ui.PowerPmacWorkingMode(...
                'cName', [this.cName, 'pmac-working-mode'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        
            this.uiMotMin = bl12014.ui.PowerPmacHydraMotMin(...
                'cName', [this.cName, 'ppmac-hydra-mot-min'], ...
                'hardware', this.hardware, ...
                'uiClock', this.uiClock, ...
                'clock', this.clock ...
            );
        
            
            this.uiStateOn = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-hydras-on'], ...
                'task', bl12014.Tasks.createStateHydrasOn(...
                    [this.cName, 'state-hydras-on'], ...
                    this.hardware, ...
                    this.clock ...
                ), ...
                'lShowButton', false, ...
                'clock', this.uiClock ...
            );

            this.uiSequenceOn = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-turn-on-wafer-and-reticle-hydra'], ...
                'task', bl12014.Tasks.createSequenceTurnOnWaferAndReticleHydra(...
                    [this.cName, 'task-sequence-turn-on-wafer-and-reticle-hydra'], ...
                    this.uiMotMin, ...
                    this.uiWorkingMode.uiWorkingMode, ...
                    this.clock ...
                 ), ...
                 'lShowStatus', false, ...
                'lShowIsDone', false, ...
                'clock', this.uiClock ...
            );
        
            
        
        end
        
        
        
        
        
        
    end % private
    
    
end