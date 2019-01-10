classdef PowerPmacHydraMotMinSimple < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 325
        dHeight     = 110
        
    end
    
	properties
        
        
        
    end
    
    properties (SetAccess = private)
        
        hPanel
        cName = 'ppmac-hydra-mot-min-simple-'
        
        uiWorkingMode
        uiMotMin
    
        uiStateWaferOn
        uiStateReticleOn
        uiStateLsiOn
        
        uiSequenceTurnOnWaferAndReticle
        uiSequenceTurnOnWafer
        uiSequenceTurnOffAll
        uiSequenceTurnOnReticle
        
    end
    
    properties (Access = private)
                      
        clock
        uiClock
        dDelay = 0.5
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = PowerPmacHydraMotMinSimple(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            this.init();
            
            
        end
        
   
        
        function connectDeltaTauPowerPmac(this, comm)
                            
            this.uiWorkingMode.connectDeltaTauPowerPmac(comm);
            this.uiMotMin.connectDeltaTauPowerPmac(comm);
            
        end
        
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.uiWorkingMode.disconnectDeltaTauPowerPmac();
            this.uiMotMin.disconnectDeltaTauPowerPmac();
                        
        end
        
        
        
        
        function build(this, hParent, dLeft, dTop)
                    
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'PPMAC Hydra Power',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
            dTop = 20;
            dLeft = 10;
            dSep = 30;
            
            dWidthStates = 95;
            dWidthSequences = 200;
            
            this.uiStateWaferOn.build(this.hPanel, dLeft, dTop, dWidthStates);
            dTop = dTop + dSep;
            this.uiStateReticleOn.build(this.hPanel, dLeft, dTop, dWidthStates);
            dTop = dTop + dSep;
            this.uiStateLsiOn.build(this.hPanel, dLeft, dTop, dWidthStates);
            dTop = dTop + dSep;
            
            dLeft = dLeft + dWidthStates + 10;
            dTop = 20;
            this.uiSequenceTurnOnWaferAndReticle.build(this.hPanel, dLeft, dTop, dWidthSequences); 
            dTop = dTop + dSep;
            this.uiSequenceTurnOffAll.build(this.hPanel, dLeft, dTop, dWidthSequences); 
            this.uiSequenceTurnOffAll.hide();
            
            if ~isempty(this.uiClock) && ...
                ~this.uiClock.has(this.id())
                this.uiClock.add(@this.onClock, this.id(), this.dDelay);
            end
                        
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            %{
            if ~isempty(this.uiClock) && ...
                isvalid(this.uiClock) && ...
                this.uiClock.has(this.id())
                this.msg('delete() removing clock task', this.u8_MSG_TYPE_INFO); 
                this.uiClock.remove(this.id());
            end
            %}
            
            
        end
        
        function st = save(this)
            st = struct();
            
        end
        
        function load(this, st)
        end
            
               
        
        
        
        
        
    end
    
    methods (Access = private)
        
        
        function onClock(this, ~, ~)
                
            % Show the turn off all?
            if this.uiStateLsiOn.isDone() || ...
               this.uiStateReticleOn.isDone() || ...
               this.uiStateWaferOn.isDone()
                this.uiSequenceTurnOffAll.show();
            elseif this.uiSequenceTurnOffAll.isExecuting()
                this.uiSequenceTurnOffAll.show();
            else
                this.uiSequenceTurnOffAll.hide();
            end
            
            % Enable the turn off all?
            if this.uiSequenceTurnOnWaferAndReticle.isExecuting()
                this.uiSequenceTurnOffAll.disable();
            else
                this.uiSequenceTurnOffAll.enable();
            end
            
            % Enable the turn on?
            if this.uiSequenceTurnOffAll.isExecuting()
                this.uiSequenceTurnOnWaferAndReticle.disable()
            else
                this.uiSequenceTurnOnWaferAndReticle.enable()
            end
            
            
            
        end
        
        function init(this)
            
            this.msg('init()');
            
            this.uiWorkingMode = bl12014.ui.PowerPmacWorkingMode(...
                'cName', [this.cName, 'pmac-working-mode'], ...
                'clock', this.uiClock ...
            );
        
            this.uiMotMin = bl12014.ui.PowerPmacHydraMotMin(...
                'cName', [this.cName, 'ppmac-hydra-mot-min'], ...
                'clock', this.uiClock ...
            );
        
            
            this.uiStateWaferOn = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-state-wafer-hydra-on'], ...
                'task', bl12014.Tasks.createStateWaferHydraOn(...
                    [this.cName, 'task-sequence-state-wafer-hydra-on'], ...
                    this.uiMotMin, ...
                    this.clock ...
                ), ...
                'lShowButton', false, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateReticleOn = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-state-reticle-hydra-on'], ...
                'task', bl12014.Tasks.createStateReticleHydraOn(...
                    [this.cName, 'task-sequence-state-reticle-hydra-on'], ...
                    this.uiMotMin, ...
                    this.clock ...
                ), ...
                'lShowButton', false, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateLsiOn = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-state-lsi-hydra-on'], ...
                'task', bl12014.Tasks.createStateLsiHydraOn(...
                    [this.cName, 'task-sequence-state-lsi-hydra-on'], ...
                    this.uiMotMin, ...
                    this.clock ...
                ), ...
                'lShowButton', false, ...
                'clock', this.uiClock ...
            );
        
            this.uiSequenceTurnOnWaferAndReticle = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-turn-on-wafer-and-reticle-hydra'], ...
                'task', bl12014.Tasks.createSequenceTurnOnWaferAndReticleHydra(...
                    [this.cName, 'task-sequence-turn-on-wafer-and-reticle-hydra'], ...
                    this.uiMotMin, ...
                    this.uiWorkingMode.uiWorkingMode, ...
                    this.clock ...
                 ), ...
                'lShowIsDone', false, ...
                'clock', this.uiClock ...
            );
        
            this.uiSequenceTurnOnWafer = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-turn-on-wafer-hydra'], ...
                'task', bl12014.Tasks.createSequenceTurnOnWaferHydra(...
                    [this.cName, 'task-sequence-turn-on-wafer-hydra'], ...
                    this.uiMotMin, ...
                    this.uiWorkingMode.uiWorkingMode, ...
                    this.clock ...
                 ), ...
                'lShowIsDone', false, ...
                'clock', this.uiClock ...
            );
        
            this.uiSequenceTurnOffAll = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-turn-off-all-hydras'], ...
                'task', bl12014.Tasks.createSequenceTurnOffAllHydras(...
                    [this.cName, 'task-sequence-turn-off-all-hydras'], ...
                    this.uiMotMin, ...
                    this.uiWorkingMode.uiWorkingMode, ...
                    this.clock ...
                 ), ...
                'lShowIsDone', false, ...
                'clock', this.uiClock ...
            );
        
        end
        
        
        
        
        
        
    end % private
    
    
end