classdef PowerPmacHydraMotMinSimple < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 130
        dHeight     = 80
        
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
        
        % {bl12014.Hardware 1x1}
        hardware
        
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
            %{
            this.uiStateLsiOn.build(this.hPanel, dLeft, dTop, dWidthStates);
            dTop = dTop + dSep;
            %}
            
            dLeft = dLeft + dWidthStates + 10;
            dTop = 20;
            
            %this.uiSequenceTurnOnWaferAndReticle.build(this.hPanel, dLeft, dTop, dWidthSequences); 
            %dTop = dTop + dSep;
            
            this.uiSequenceTurnOnWafer.build(this.hPanel, dLeft, dTop, dWidthSequences); 
            dTop = dTop + dSep;
            
            this.uiSequenceTurnOnReticle.build(this.hPanel, dLeft, dTop, dWidthSequences); 
            dTop = dTop + dSep;
            
            %this.uiSequenceTurnOffAll.build(this.hPanel, dLeft, dTop, dWidthSequences); 
            %this.uiSequenceTurnOffAll.hide();
            
            
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
              
            
            % Show the turn on Wafer?
            if this.uiStateWaferOn.isDone()
                if ~this.uiSequenceTurnOnWafer.isExecuting()
                    this.uiSequenceTurnOnWafer.hide();
                end
            else
                this.uiSequenceTurnOnWafer.show();
            end
            
            % Show the turn on Reticle?
            if this.uiStateReticleOn.isDone()
                if ~this.uiSequenceTurnOnReticle.isExecuting()
                    this.uiSequenceTurnOnReticle.hide();
                end
            else
                this.uiSequenceTurnOnReticle.show();
            end
            
            
            %{
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
            %}
            
            
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
        
            this.uiSequenceTurnOnReticle = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-turn-on-reticle-hydra'], ...
                'task', bl12014.Tasks.createSequenceTurnOnReticleHydra(...
                    [this.cName, 'task-sequence-turn-on-reticle-hydra'], ...
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