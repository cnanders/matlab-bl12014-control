classdef FluxDensityComparison < mic.Base
        
    properties (Constant)
       
        cNameReticleRowAndCol = 'reticleRowAndCol'
        cNameReticleRow = 'reticleRow'
        cNameReticleCol = 'reticleCol'
        cNameReticleLevel = 'reticleLevel'
        cNameDiode = 'diode'
        
        
        cTYPE_REF = 'ref'
        cTYPE_TEST = 'test'
        dWidth      = 700 
        dHeight     = 600
        dPeriodOfScan = 1;
        
        dWidthAxes = 600;
        dHeightAxes = 200;
        dWidthUiScan = 400;

    end
    
	properties
        
        uiReticle
        uiDiode
        uiScan
        
    end
    
    properties (SetAccess = private)
        
        cName = 'flux-density-comparison'
        
        % {struct 1x1} stores config date loaded from +bl12014/config/tune-flux-density-coordinates.json
        cDirSave
    end
    
    properties (Access = private)
                      
        clock
        uiClock
        dDelay = 0.5
        
        hProgress
        
        % {mic.Scan 1x1}
        scan
        
        % {bl12014.Hardware 1x1}
        hardware
        
        dFluxDensityAcc1 = [] % accumulated during calibration
        dFluxDensityAcc2 = []
                
        hAxesSave
        uiProgressBar
        uiReticleFieldIds
        
        
        stScanSetContract = struct()
        stScanAcquireContract = struct()
        uiStateReticleLevel
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = FluxDensityComparison(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSave = fullfile( ...
                cDirThis, ...
                '..', ...
                '..', ...
                'save', ...
                'flux-density-comparison' ...
            );
            
        
            if ~isa(this.uiReticle, 'bl12014.ui.Reticle')
                    error('uiReticle must be bl12014.ui.Reticle');
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock mic.ui.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
            
        end
        

        
        
        
        
                        
        
        %% Destructor
        
        
        
        function delete(this)
                        
            
                        
        end
        function build(this, hParent, dLeft, dTop)
            
            
            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Field Contamination Comparison',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
            dLeft = 20;
            dTop = 20;
            dPad = 20;
            
            this.uiReticleFieldIds.build(hPanel, dTop, dLeft)
            dTop = dTop + this.uiReticleFieldIds.dHeight + dPad;
            
            this.hAxesSave = axes(...
                'Parent', hPanel,...
                'Units', 'pixels',...
                'Position',mic.Utils.lt2lb([...
                    dLeft, ...
                    dTop, ...
                    this.dWidthAxes,...
                    this.dHeightAxes], hPanel),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                ...'DataAspectRatio',[1 1 1],...
                'HandleVisibility','on'...
           );
       
            cecLabels = {'Ref', 'Test'}
            legend(this.hAxesSave, cecLabels);
       
            dTop = dTop + this.dHeightAxes + dPad;
            this.uiProgressBar.build(...
                hPanel, ...
                dLeft, ...
                dTop, ...
                this.dWidthAxes, ...
                10 ...
            ); 
        
            dTop = dTop + 30;
        
            this.uiScan.build(...
                hPanel,...
                dLeft, ...
                dTop);
                            
       
            
        end

        
               
    end
    
    methods (Access = private)
        
        function init(this)
            
            this.initScanSetContract();
            this.initScanAcquireContract();
            
            this.uiReticleFieldIds = bl12014.ui.ReticleFieldIds();
            this.uiProgressBar = mic.ui.common.ProgressBar();
%             this.uiButtonMeasure = mic.ui.common.Button(...
%                 'fhOnClick', @this.onClickMeasure, ...
%                 'cText', 'Measure' ...
%             );
        
            this.uiStateReticleLevel = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-reticle-reticle-level'], ...
                'task', bl12014.Tasks.createSequenceLevelReticle(...
                    [this.cName, 'state-reticle-level'], ...
                    this.uiReticle.uiReticleTTZClosedLoop, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiScan = mic.ui.Scan(...
                'dWidthBorderPanel', 0, ...
                'dWidth', this.dWidthUiScan, ...
                'cTitle', '', ...
                'dWidthButton', 200, ...
                'dHeightPadPanel', 0, ...
                'dWidthPadPanel', 0 ...
            );
            addlistener(this.uiScan, 'eStart', @this.onUiScanStart);
            addlistener(this.uiScan, 'ePause', @this.onUiScanPause);
            addlistener(this.uiScan, 'eResume', @this.onUiScanResume);
            addlistener(this.uiScan, 'eAbort', @this.onUiScanAbort);
            
        end
        
        function updateUiScanStatus(this)
           this.uiScan.setStatus(this.scan.getStatus()); 
        end
        
        
         function onUiScanStart(this, src, evt)
            this.msg('onUiScanStart');
            this.startNewScan();
        end
        
        function onUiScanPause(this, ~, ~)
            this.scan.pause();
            this.updateUiScanStatus()
        end
        
        function onUiScanResume(this, ~, ~)
            this.scan.resume();
            this.updateUiScanStatus()

        end
        
        function onUiScanAbort(this, ~, ~)
            this.scan.stop(); % calls onScanAbort()
        end
        
        
        function startNewScan(this, ~, ~)
            
            stUnit = struct();
            
            ceValues = cell(0);
            
            % reticle ref field xy
            stValue = struct();
            stValue.(this.cNameReticleRow) = this.uiReticleFieldIds.uiRow1.get();
            ceValues{end+1} = stValue;

            stValue = struct();
            stValue.(this.cNameReticleCol) = this.uiReticleFieldIds.uiCol1.get();
            ceValues{end+1} = stValue;
            
            % reticle level
            stValue = struct();
            stValue.(this.cNameReticleLevel) = 1;
            ceValues{end+1} = stValue;
            
            % record diode
            stValue = struct();
            stValue.(this.cNameDiode) = this.cTYPE_REF;
            ceValues{end+1} = stValue;

            
            % reticle test field xy
            stValue = struct();
            stValue.(this.cNameReticleRow) = this.uiReticleFieldIds.uiRow2.get();
            ceValues{end+1} = stValue;

            stValue = struct();
            stValue.(this.cNameReticleCol) = this.uiReticleFieldIds.uiCol2.get();
            ceValues{end+1} = stValue;
            
             % reticle level
            stValue = struct();
            stValue.(this.cNameReticleLevel) = 2;
            ceValues{end+1} = stValue;
            
            % record diode
            stValue = struct();
            stValue.(this.cNameDiode) = this.cTYPE_TEST;
            ceValues{end+1} = stValue;

            
            stRecipe = struct();
            stRecipe.unit = struct();
            stRecipe.values = ceValues;
            
            this.scan = mic.Scan(...
                [this.cName, 'scan'], ...
                this.clock, ...
                stRecipe, ...
                @this.onScanSetState, ...
                @this.onScanIsAtState, ...
                @this.onScanAcquire, ...
                @this.onScanIsAcquired, ...
                @this.onScanComplete, ...
                @this.onScanAbort, ...
                0.25 ... % Need larger than the PPMAC cache period of 0.2 s
            );

            this.scan.start();
            
        end
        
                    
        % Returns {struct 1x1}
        % @return st.dMean {double 1x1} mean
        % @return st.dStd { double 1x1} standard deviation
        % @return st.dPV { double 1x1} peak-to-valley
        
            
        function st = recordTimeAveragedFluxDensity(this, cType)
            
            % Build up an average flux density over 10 seconds
            % with a progress bar
            
            this.lAbortSave = false;
            this.uiProgressBar.show();
                        
            dValues = [];
            dNum = 20;
            
            switch (cType)
            case this.cTYPE_REF
                hPlot = this.hPlot1;
            case this.cTYPE_TEST
                hPlot = this.hPlot2;
            end
            
            for n = 1 : dNum
                
                if this.lAbortSave
                    return
                end
                
                dValues(end + 1) = this.uiDiode.uiCurrent.getValCal("mJ/cm2/s (clear field)");
                  
                if isempty(hPlot)
                    hPlot = plot(1 : n, dValues,'.-');
                    ylabel(this.hAxesSave, 'mJ/cm2/s');
                else
                    hPlot.XData = 1 : n;
                    hPlot.YData = dValues;
                end
                
                this.uiProgressBar.set(n / dNum);
                pause(0.7);
            end
            
            st = struct();
            st.dMean = abs(mean(dValues));
            st.dStd = std(dValues);
            st.dPV = abs(max(dValues) - min(dValues));   
            
            this.uiProgressBar.hide();
                            
        end
        
        function cec = getContractProps(this)
            cec = {...
                'lRequired', ...
                'lIssued', ...
                'lAchieved', ...
            };
        end
        
        function initScanSetContract(this)

            ceFields = { ...
                this.cNameReticleRow, ...
                this.cNameReticleCol, ...
                this.cNameReticleLevel, ...
             };
         
            ceProps = this.getContractProps();

            for n = 1 : length(ceFields)
                for m = 1 : length(ceProps)
                    this.stScanSetContract.(ceFields{n}).(ceProps{m}) = false;
                end
            end

        end

        function initScanAcquireContract(this)

            return;
            
            ceFields = {...
                this.cNameDiode
            };
        
            ceProps = this.getContractProps();

            for n = 1 : length(ceFields)
                for m = 1 : length(ceProps)
                    this.stScanAcquireContract.(ceFields{n}).(ceProps{m}) = false;
                end
            end

        end

        function resetScanSetContract(this)

            ceFields = fieldnames(this.stScanSetContract);
            ceProps = this.getContractProps();
            for n = 1 : length(ceFields)
                for m = 1 : length(ceProps)
                    this.stScanSetContract.(ceFields{n}).(ceProps{m}) = false;
                end
            end

        end

        function resetScanAcquireContract(this)

            ceFields = fieldnames(this.stScanAcquireContract);
            ceProps = this.getContractProps();
            for n = 1 : length(ceFields)
                for m = 1 : length(ceProps)
                    this.stScanAcquireContract.(ceFields{n}).(ceProps{m}) = false;
                end
            end

        end


        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stValue - the system state that needs to be reached
        % @returns {logical} - true if the system is at the state
        function lOut = onScanIsAtState(this, stUnit, stValue)

                        this.updateUiScanStatus()

                        
            cFn = 'onScanIsAtState';
            lOut = true; % default
            stContract = this.stScanSetContract;
            ceFields= fieldnames(stContract);
            lDebug = true;

            for n = 1:length(ceFields)

                cField = ceFields{n};

                % special case, skip fields that are part of acquire
                if strcmp(cField, 'diode')
                    continue;
                end

                if ~stContract.(cField).lRequired
                    if lDebug
                        cMsg = sprintf('%s %s not required',cFn, cField);
                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                    end
                    continue
                end
                
                if ~stContract.(cField).lIssued
                    if lDebug
                        cMsg = sprintf('%s %s required, not issued.', cFn, cField);
                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                    end

                    lOut = false;
                    return;
                end
                
                if stContract.(cField).lAchieved
                    if lDebug
                        cMsg = sprintf('%s %s required, issued, achieved.', cFn, cField);
                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                    end
                    continue
                end
                
                % !!! UPDATE ACHIEVED !!!
                
                switch cField
                    case this.cNameReticleRow
                        stContract.(cField).lAchieved = this.uiReticle.uiReticleFiducializedMove.uiRow.isReady();
                    case this.cNameReticleCol
                        stContract.(cField).lAchieved = this.uiReticle.uiReticleFiducializedMove.uiCol.isReady();
                    case this.cNameReticleLevel
                        if this.hardware.getIsConnectedDeltaTauPowerPmac()
                            stContract.(cField).lAchieved = this.uiStateReticleLevel.isDone();
                        else
                            stContract.(cField).lAchieved = true;
                        end
                end
                
                % !!! END REQUIRED CODE !!!

                if ~stContract.(cField).lAchieved
                    % still isn't there.
                    if lDebug
                        cMsg = sprintf('%s %s required, issued, incomplete.', cFn, cField);
                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                    end
                    lOut = false;
                    return;
                else 
                    if lDebug
                        cMsg = sprintf('%s %s required, issued, achieved.', cFn, cField);
                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                    end
                    
                end
            end
        end


        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the acquisition task is complete
        function lOut = onScanIsAcquired(this, stUnit, stValue)

            lOut = true;
            cFn = 'onScanIsAcquired';
            stContract = this.stScanAcquireContract;
            ceFields= fieldnames(stContract);
            lDebug = true;

            for n = 1:length(ceFields)

                cField = ceFields{n};

                if ~stContract.(cField).lRequired
                    if lDebug
                        cMsg = sprintf('%s %s not required', cFn, cField);
                        this.msg(cMsg,  this.u8_MSG_TYPE_SCAN);
                    end
                    continue
                end
                

                if ~stContract.(cField).lIssued
                    if lDebug
                        cMsg = sprintf('%s %s required, not issued.', cFn, cField);
                        this.msg(cMsg,  this.u8_MSG_TYPE_SCAN);
                    end

                    lOut = false;
                    return;
                end
                
                if stContract.(cField).lAchieved
                    if lDebug
                        cMsg = sprintf('%s %s required, issued, achieved.', cFn, cField);
                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                    end
                    continue
                end

                % !!! UPDATE ACHIEVED !!! 
                % Check if the set operation on the current device is
                % complete by calling isReady() on devices.  This will
                % often be a switch on cField that does something like:
                % this.uiDeviceStage.getDevice().isReady()

                % !!! END  !!!

                if ~stContract.(cField).lAchieved
                    if lDebug
                        cMsg = sprintf('%s %s required, issued, incomplete', cFn, cField);
                        this.msg(cMsg,  this.u8_MSG_TYPE_SCAN);
                    end
                    lOut = false;
                    return;
                else
                    if lDebug
                        cMsg = sprintf('%s %s required, issued, achieved.', cFn, cField);
                        this.msg(cMsg, this.u8_MSG_TYPE_SCAN);
                    end
                end
            end

        end
        
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        function onScanSetState(this, stUnit, stValue)
            
            cFn = 'onScanSetState';
            lDebug = true;
            this.resetScanSetContract();
            
            ceFields = fieldnames(stValue);
            for n = 1 : length(ceFields)
                cField = ceFields{n};
                
                % special case, skip fields that are part of acquire
                if strcmp(cField, 'diode')
                    continue;
                end
                
                this.stScanSetContract.(cField).lRequired = true;
                        
               switch cField
                    case this.cNameReticleRow
                        this.uiReticle.uiReticleFiducializedMove.uiRow.setDestCal(double(stValue.(cField)), 'cell');
                        this.uiReticle.uiReticleFiducializedMove.uiRow.moveToDest();
                    case this.cNameReticleCol
                        this.uiReticle.uiReticleFiducializedMove.uiCol.setDestCal(double(stValue.(cField)), 'cell');
                        this.uiReticle.uiReticleFiducializedMove.uiCol.moveToDest();
                    case this.cNameReticleLevel
                        if this.hardware.getIsConnectedDeltaTauPowerPmac()
                            this.uiStateReticleLevel.execute();
                        end
                end
                
                this.stScanSetContract.(cField).lIssued = true;

            end
        end



        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state (possibly contains information about the task to execute during acquire)
        function onScanAcquire(this, stUnit, stValue)

        end


        function onScanAbort(this, stUnit)

        end


        function onScanComplete(this, stUnit)
             this.uiScan.reset();
             this.updateUiScanStatus();
        end

        
    end % private
    
    
end