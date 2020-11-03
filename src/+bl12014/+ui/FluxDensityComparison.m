classdef FluxDensityComparison < mic.Base
        
    properties (Constant)
       
        cNameReticleRowAndCol = 'reticleRowAndCol'
        cNameReticleRow = 'reticleRow'
        cNameReticleCol = 'reticleCol'
        cNameReticleLevel = 'reticleLevel'
        cNameDiode = 'diode'
        
        cTYPE_REF = 'ref'
        cTYPE_TEST = 'test'
        
        dWidth      = 630 
        dHeight     = 700
        dPeriodOfScan = 1;
        
        dWidthAxes = 540;
        dHeightAxes = 200;
        dWidthUiScan = 400;
        dSizeFont = 14

    end
    
	properties
        
        uiReticle
        uiDiode
        uiScan
        % {bl12014.Recorder 1x1}
        recorder 
        
    end
    
    properties (SetAccess = private)
        
        cName = 'flux-density-comparison'
        
        % {struct 1x1} stores config date loaded from +bl12014/config/tune-flux-density-coordinates.json
        cDirSave
    end
    
    properties (Access = private)
           
        % props for storing scan progress
        dCountOfScan = 1
        dLengthOfScan = 10
        dNumToRecord = 10;
        
        clock
        uiClock
        dDelay = 0.5
        
        hProgress
        
        % {mic.Scan 1x1}
        scan
        
        % {bl12014.Hardware 1x1}
        hardware
        
      
                
        hAxes
        uiProgressBar
        uiReticleFieldIds
        
        
        stScanSetContract = struct()
        stScanAcquireContract = struct()
        uiStateReticleLevel
        
        hPlot1
        hPlot2
        
        uiTextRef
        uiTextTest
        uiTextRatio
        uiTextStatus
        
        dCurrentRef = []
        dCurrentTest = []
        
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
        
            dLeft = 10;
            dTop = 20;
            dPad = 20;
            
            this.uiReticleFieldIds.build(hPanel, dLeft, dTop)
            dTop = dTop + this.uiReticleFieldIds.dHeight + dPad;
            
            dLeft = 200;
            this.uiScan.build(...
                hPanel,...
                dLeft, ...
                dTop);
            
            dTop = dTop + this.uiScan.dHeight + 20;
            dLeft = 60;
            this.hAxes = axes(...
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
       
            
            dTop = dTop + this.dHeightAxes + 30;
            
            dWidth = this.dWidth / 3 - 20;
            dHeight = 80;
            this.uiTextRef.build(hPanel, dLeft, dTop, dWidth, dHeight);
            this.uiTextTest.build(hPanel, dLeft + dWidth, dTop, dWidth, dHeight);
            this.uiTextRatio.build(hPanel, dLeft + 2 * dWidth, dTop, dWidth, dHeight);
            % Put at very buttom
            
            dLeft = 0;
            dTop = this.dHeight - 20;
            
            this.uiProgressBar.build(...
                hPanel, ...
                dLeft, ...
                dTop, ...
                this.dWidth, ...
                20 ...
            ); 
            dLeft = 0;
            this.uiTextStatus.build(hPanel, 20, dTop - 40, this.dWidth - 20, 2 * this.dSizeFont + 5);
            
        end

        
               
    end
    
    methods (Access = private)
        
        function init(this)
            
            this.initScanSetContract();
            this.initScanAcquireContract();
            
            this.uiReticleFieldIds = bl12014.ui.ReticleFieldIds(...
                'fhOnChange', @this.onChangeReticleFieldIds ...
            );
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
        
            this.uiDiode = bl12014.ui.WaferDiode(...
                'hardware', this.hardware, ...
                'clock', this.clock ...
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
            
            
            this.recorder = bl12014.Recorder(...
                'clock', this.clock, ...
                'cUnit', "mJ/cm2/s (clear field)", ...
                'ui', this.uiDiode.uiCurrent ...
            );
        
            this.uiTextRef = mic.ui.common.Text(...
                'dFontSize', this.dSizeFont, ...
                'lShowLabel', true, ...
                'cLabel', 'Ref:');
            this.uiTextTest = mic.ui.common.Text(...
                'dFontSize', this.dSizeFont, ...
                'lShowLabel', true, ...
                'cLabel', 'Test:');
            this.uiTextRatio = mic.ui.common.Text(...
                'dFontSize', this.dSizeFont, ...
                'lShowLabel', true, ...
                'cLabel', 'Ratio (Test/Ref):');
            this.uiTextStatus = mic.ui.common.Text(...
                'dFontSize', this.dSizeFont, ...
                'lShowLabel', false, ...
                'cLabel', 'Status:');

        end
        
        
        function onChangeReticleFieldIds(this)
            
            cVal = sprintf('Start [%1.0f,%1.0f] vs. [%1.0f,%1.0f]', ...
                this.uiReticleFieldIds.uiRow1.get(), ...
                this.uiReticleFieldIds.uiCol1.get(), ...
                this.uiReticleFieldIds.uiRow2.get(), ...
                this.uiReticleFieldIds.uiCol2.get() ...
            );
            this.uiScan.setStartLabel(cVal);
                        
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
            
            
            % Reset state
            this.dCurrentRef = [];
            this.dCurrentTest = [];
            this.uiTextRatio.set('Pending ...');
            this.uiTextRef.set('Pending ...');
            this.uiTextTest.set('Pending ...');
            
            if ~isempty(this.hPlot1)
                this.hPlot1.XData = [];
                this.hPlot1.YData = [];
            end
            
            if ~isempty(this.hPlot2)
                this.hPlot2.XData = [];
                this.hPlot2.YData = [];
            end
            
            % Build 
            
            
            stUnit = struct();
            
            ceValues = cell(0);
            
            % reticle ref field xy
            
            %{
            stValue = struct();
            stValue.(this.cNameReticleRow) = this.uiReticleFieldIds.uiRow1.get();
            ceValues{end+1} = stValue;

            stValue = struct();
            stValue.(this.cNameReticleCol) = this.uiReticleFieldIds.uiCol1.get();
            ceValues{end+1} = stValue;
            %}
            
            % special case where can't do parallel moves for x and y since
            % it is a coupled axis from the hardware perspetive.
            
            stValue = struct();
            stValue.(this.cNameReticleRowAndCol) = struct();
            stValue.(this.cNameReticleRowAndCol).row = this.uiReticleFieldIds.uiRow1.get();
            stValue.(this.cNameReticleRowAndCol).col = this.uiReticleFieldIds.uiCol1.get();
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
            %{
            stValue = struct();
            stValue.(this.cNameReticleRow) = this.uiReticleFieldIds.uiRow2.get();
            ceValues{end+1} = stValue;

            stValue = struct();
            stValue.(this.cNameReticleCol) = this.uiReticleFieldIds.uiCol2.get();
            ceValues{end+1} = stValue;
            %}
            
            % special case where can't do parallel moves for x and y since
            % it is a coupled axis from the hardware perspetive.
            
            stValue = struct();
            stValue.(this.cNameReticleRowAndCol) = struct();
            stValue.(this.cNameReticleRowAndCol).row = this.uiReticleFieldIds.uiRow2.get();
            stValue.(this.cNameReticleRowAndCol).col = this.uiReticleFieldIds.uiCol2.get();
            ceValues{end+1} = stValue;
            
             % reticle level
            stValue = struct();
            stValue.(this.cNameReticleLevel) = 2;
            ceValues{end+1} = stValue;
            
            % record diode
            stValue = struct();
            stValue.(this.cNameDiode) = this.cTYPE_TEST;
            ceValues{end+1} = stValue;

            this.dCountOfScan = 1;
            this.dLengthOfScan = length(ceValues) - 2 + 2 * this.dNumToRecord;
        
            
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
        
        
        function cec = getContractProps(this)
            cec = {...
                'lRequired', ...
                'lIssued', ...
                'lAchieved', ...
            };
        end
        
        function initScanSetContract(this)

            ceFields = { ...
                this.cNameReticleRowAndCol, ...
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
                    case this.cNameReticleRowAndCol
                        lReadyRow = this.uiReticle.uiReticleFiducializedMove.uiRow.isReady();
                        lReadyCol = this.uiReticle.uiReticleFiducializedMove.uiCol.isReady();
                        stContract.(cField).lAchieved = lReadyRow && lReadyCol;

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
            lDebug = true;

                        
            stContract = this.stScanAcquireContract;
            ceFields= fieldnames(stContract);
            
            dCount = this.dCountOfScan  ...
                + length(this.dCurrentRef) ...
                + length(this.dCurrentTest);
            
            this.uiProgressBar.set(dCount / this.dLengthOfScan);

            
            if ~any(isfield(stValue, ceFields))
                if lDebug
                    cMsg = sprintf('%s no acquire for this state', cFn);
                    this.msg(cMsg,  this.u8_MSG_TYPE_SCAN);
                end
                return
            end
            
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
                
                
                % stValue.(cField) will be either:
                % cTYPE_REF = 'ref'
                % cTYPE_TEST = 'test'
                
                stContract.(cField).lAchieved = ~this.recorder.getIsRecording();
                
                dY = this.recorder.get();
                dX = 1 : length(dY);
                
                % Generate the plots
                switch stValue.(cField)
                case this.cTYPE_REF
                    if isempty(this.hPlot1)
                        cLineSpec = '.-r';
                        this.hPlot1 = plot(this.hAxes, dX, dY, cLineSpec);
                        hold(this.hAxes, 'on')
                    else 
                        this.hPlot1.XData = dX;
                        this.hPlot1.YData = dY;
                        cecLabels = {'Ref', 'Test'};
                        legend(this.hAxes, cecLabels);
                    end
                           
                case this.cTYPE_TEST
                    if isempty(this.hPlot2)
                        cLineSpec = '.-b';
                    	this.hPlot2 = plot(this.hAxes, dX, dY, cLineSpec);
                        hold(this.hAxes, 'on')
                    else 
                        this.hPlot2.XData = dX;
                        this.hPlot2.YData = dY;
                        cecLabels = {'Ref', 'Test'};
                        legend(this.hAxes, cecLabels);
                    end
                end
                
                dMean = abs(mean(dY));
                dStd = std(dY);
                dPV = abs(max(dY) - min(dY));
                
                ceVal = {...
                    sprintf('Mean: %1.3f', dMean), ...
                    sprintf('Std: %1.3f (%1.1f%%)', dStd, dStd/dMean*100), ...
                    sprintf('PV: %1.3f (%1.1f%%)', dPV, dPV/dMean*100) ...
                };
                
                switch stValue.(cField)
                    case this.cTYPE_REF
                        this.uiTextRef.set(ceVal);
                        this.dCurrentRef = dY;
                    case this.cTYPE_TEST
                        this.uiTextTest.set(ceVal);
                        this.dCurrentTest = dY;
                end
                
                    
                %{
                st = struct();
                st.dMean = abs(mean(dValues));
                st.dStd = std(dValues);
                st.dPV = abs(max(dValues) - min(dValues)); 
                %}
                
                % do any other thing you want to do here!
                
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
                   case this.cNameReticleRowAndCol
                        dRow = double(stValue.(cField).row);
                        dCol = double(stValue.(cField).col);
                        this.uiReticle.uiReticleFiducializedMove.uiRow.setDestRaw(dRow);
                        this.uiReticle.uiReticleFiducializedMove.uiCol.setDestRaw(dCol);
                        this.uiReticle.uiReticleFiducializedMove.makeFiducializedMove();
                        cStatus = sprintf('Moving reticle to row,col %1.0f,%1.0f ...', dRow, dCol);
                        this.uiTextStatus.set(cStatus);
                    case this.cNameReticleRow
                        dRow = double(stValue.(cField));
                        this.uiReticle.uiReticleFiducializedMove.uiRow.setDestCal(dRow, 'cell');
                        this.uiReticle.uiReticleFiducializedMove.uiRow.moveToDest();
                        cStatus = sprintf('Moving reticle to row %1.0f ...', dRow);
                        this.uiTextStatus.set(cStatus);
                        
                    case this.cNameReticleCol
                        dCol = double(stValue.(cField));
                        this.uiReticle.uiReticleFiducializedMove.uiCol.setDestCal(dCol, 'cell');
                        this.uiReticle.uiReticleFiducializedMove.uiCol.moveToDest();
                        cStatus = sprintf('Moving reticle to col %1.0f ...', dCol);
                        this.uiTextStatus.set(cStatus);
                    case this.cNameReticleLevel
                        if this.hardware.getIsConnectedDeltaTauPowerPmac()
                            this.uiStateReticleLevel.execute();
                            cStatus = sprintf('Leveling the reticle ...');
                            this.uiTextStatus.set(cStatus);
                        end
                end
                
                this.stScanSetContract.(cField).lIssued = true;

            end
        end



        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state (possibly contains information about the task to execute during acquire)
        function onScanAcquire(this, stUnit, stValue)
            
            % return if the state value doesn't contain any
            % of the acquire properties
            
            cFn = 'onScanAcquire';
            lDebug = true;
            
            this.dCountOfScan = this.dCountOfScan + 1;
            
            ceFields = fieldnames(this.stScanAcquireContract);
            if ~any(isfield(stValue, ceFields))
                if lDebug
                    cMsg = sprintf('%s no acquire for this state', cFn);
                    this.msg(cMsg,  this.u8_MSG_TYPE_SCAN);
                end
                return
            end
            
            for n = 1 : length(ceFields)
                cField = ceFields{n};
                
                this.stScanAcquireContract.(cField).lRequired = true;
                        
                switch cField
                case this.cNameDiode
                    this.recorder.record(10);
                    cStatus = sprintf('Recording current from wafer diode ...');
                    this.uiTextStatus.set(cStatus);
                end
                this.stScanAcquireContract.(cField).lIssued = true;

            end

        end


        function onScanAbort(this, stUnit)

        end


        function onScanComplete(this, stUnit)
             this.uiScan.reset();
             this.updateUiScanStatus();
             
             this.uiTextStatus.set('Complete!');
             
             dVal = mean(this.dCurrentTest) / mean(this.dCurrentRef);
             cVal = sprintf('%1.2f', dVal);
             this.uiTextRatio.set(cVal);
        end

        
    end % private
    
    
end