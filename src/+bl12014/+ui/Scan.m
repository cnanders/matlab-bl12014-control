classdef Scan < mic.Base
    
    % A panel with a list of available prescriptions, the ability to queue
    % multiple prescriptions to a new experiment (wafer), start/pause/stop
    % the experiment, checkboxes for booleans pertaining to running the
    % experiment
    
    
    properties (Constant)
       
        dWidth = 950
        dHeight = 320
        
        dWidthList = 700
        dHeightList = 150
        
        dPauseTime      = 1
        mJPerCm2PerSec  = 5         % Eventually replace with real num
        
    end
    
	properties

        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        uilPrescriptions            
        uilActive
        uibNewWafer
        uibAddToWafer
        uibPrint
        uicWaferLL
        uicAutoVentAtLL
        
        shutter
        uiWafer
        uiReticle
        uiPupilFill
        
        clock
        
        
        cDirThis
        cDirSrc
        cDirPrescriptions
        
        hPanel
        hFigure
        
        cePrescriptions           % Store uilActive.ceOptions when FEM starts
         
        
        uitPlay
        
        uitScanPause
        uibScanAbort
        uibScanStart
        
        % Going to have a play/pause button and an abort button.  When you
        % click play the first time, a logical lRun = true will be set.  An
        % abort button will be shown.  Chenging the status of the button
        % will then put us into wait.  Only if we click abort lRun = false
        % will be set and the abort button will be hidden
        
        lRunning = false
        
        % {mic.StateScan 1x1}
        scan
        
        % {struct 1x1} storage used  and checking if the
        % system has reached a particular state.  The structure has a prop
        % for each configurable prop of the system and each of those has
        % two props: lSetRequired, lSetIssued
        stScanSetContract
        stScanAcquireContract
            
        
    end
    
        
    events
        ePreChange
    end
    

    
    methods
        
        
        function this = Scan(varargin)
            
            
            this.cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSrc = fullfile(this.cDirThis, '..', '..');
            this.cDirPrescriptions = fullfile(...
                this.cDirSrc, ...
                'save', ...
                'prescriptions' ...
            );
        
            
            
            
            
            %{
            this.clock              = clock;
            this.shutter            = shutter;
            this.uiWafer       = uiWafer;
            this.uiReticle     = uiReticle;
            this.uiPupilFill          = uiPupilFill;
                        
            %}
            % ff    fieldfill?
            % eps   beamline EPS stuff
            % mono  beamine monochromater
                        
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
            
        end
        
                
        function build(this)
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name',  'FEM Control',...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onCloseRequestFcn ...
                );
            
            drawnow;               
            
            dPad = 10;
            dTop = 20;
            
            this.uilPrescriptions.build(this.hFigure, ...
                dPad, ...
                dTop, ...
                this.dWidthList, ...
                this.dHeightList);
            
            dEditWidth = 100;
            dTop = dTop + this.dHeightList + 3*dPad;
            
            this.uibNewWafer.build(this.hFigure, ...
                dPad, ...
                dTop, ...
                dEditWidth, ...
                mic.Utils.dEDITHEIGHT);
            this.uibAddToWafer.build(this.hFigure, ...
                dPad + dEditWidth + dPad, ...
                dTop, ...
                dEditWidth, ...
                mic.Utils.dEDITHEIGHT);
            this.uibPrint.build(this.hFigure, ...
                dPad + dEditWidth + dPad + dEditWidth + dPad, ...
                dTop, ...
                100, ...
                mic.Utils.dEDITHEIGHT);
            
            dTop = dTop + mic.Utils.dEDITHEIGHT + dPad;
            this.uilActive.build(this.hFigure, ...
                dPad, ...
                dTop, ...
                this.dWidthList, ...
                40);
            
           dTop = 30;
           dSep = 20;
           this.uicWaferLL.build(this.hFigure, ...
               dPad + this.dWidthList + dPad, ...
               dTop, ...
               200, ...
               20);
            
           dTop = dTop + dSep;
           this.uicAutoVentAtLL.build(this.hFigure, ...
               dPad + this.dWidthList + dPad, ...
               dTop, ...
               200, ...
               20);
           
           dTop = dTop + 20;
           
           this.uibScanStart.build(this.hFigure, ...
               dPad + this.dWidthList + dPad, ...
               dTop, ...
               200, ...
               mic.Utils.dEDITHEIGHT ...
           )
       
           this.uitScanPause.build(this.hFigure, ...
               dPad + this.dWidthList + dPad, ...
               dTop, ...
               200, ...
               mic.Utils.dEDITHEIGHT ...
           );

           dTop = dTop + 30;
           
           this.uibScanAbort.build(this.hFigure, ...
               dPad + this.dWidthList + dPad, ...
               dTop, ...
               200, ...
               mic.Utils.dEDITHEIGHT ...
           );
       
            this.hideScanPauseAbort();
           
                      
        end
        
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
            % Clean up clock tasks
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
                        
        end
        
        function ceReturn = refreshFcn(this)
            ceReturn = mic.Utils.dir2cell(this.cDirPrescriptions, 'date', 'descend', '*.json');
        end
                    

    end
    
    methods (Access = private)
        
        function init(this)
                        
            this.uilPrescriptions = mic.ui.common.List( ...
                'ceOptions', cell(1,0), ...
                'cLabel', 'Prescriptions', ...
                'lShowDelete', false, ...
                'lShowMove', false, ...
                'lShowLabel', true, ...
                'lShowRefresh', true ...
            );
            %addlistener(this.uilPrescriptions, 'eDelete', @this.onPrescriptionsDelete);
            %addlistener(this.uilPrescriptions, 'eChange', @this.onPrescriptionsChange);
            this.uilPrescriptions.setRefreshFcn(@this.refreshFcn);
            this.uilPrescriptions.refresh();
            
            this.uibNewWafer = mic.ui.common.Button('cText', 'New Wafer');
            this.uibAddToWafer = mic.ui.common.Button('cText', 'Add To Wafer');
            this.uibPrint = mic.ui.common.Button('cText', 'Print');
            
            addlistener(this.uibNewWafer, 'eChange', @this.onNewWafer);
            addlistener(this.uibAddToWafer, 'eChange', @this.onAddToWafer);
            addlistener(this.uibPrint, 'eChange', @this.onPrint);
            
            this.uilActive = mic.ui.common.List(...
                'ceOptions', cell(1,0), ...
                'cLabel', 'Added prescriptions', ...
                'lShowDelete', true, ...
                'lShowMove', true, ...
                'lShowLabel', false, ...
                'lShowRefresh', false ...
            );
            this.uicWaferLL = mic.ui.common.Checkbox(...
                'lChecked', false, ...
                'cLabel', 'Wafer to LL when done' ...
            );
            this.uicAutoVentAtLL = mic.ui.common.Checkbox(...
                'lChecked', false, ...
                'cLabel', 'Auto vent wafer at LL' ...
            );
            

            this.uibScanStart = mic.ui.common.Button( ...
                'cText', 'Start' ...
            );
        
            this.uitScanPause = mic.ui.common.Toggle( ...
                'cTextFalse', 'Pause', ...
                'cTextTrue', 'Resume' ...
            );
            
            this.uibScanAbort = mic.ui.common.Button(...
                'cText', 'Abort', ...
                'lAsk', true, ...
                'cMsg', 'The scan is now paused.  Are you sure you want to abort?' ... 
            );
            
            addlistener(this.uibScanAbort, 'ePress', @this.onScanAbortButtonPress)
            addlistener(this.uibScanAbort, 'eChange', @this.onScanAbortButton)
            addlistener(this.uitScanPause, 'eChange', @this.onScanPauseButton);
            addlistener(this.uibScanStart, 'eChange', @this.onScanStartButton);
            
            this.initScanSetContract();
            this.initScanAcquireContract();
                       
        end
        
        function initScanSetContract(this)
            
             ceFields = {...
                'pupilFill', ...
                'reticleX', ...
                'reticleY', ...
                'waferX', ...
                'waferY', ...
                'waferZ' ...
            };

            for n = 1 : length(ceFields)
                this.stScanSetContract.(ceFields{n}).lSetRequired = false;
                this.stScanSetContract.(ceFields{n}).lSetIssued = false;
            end
            
        end
        
        function initScanAcquireContract(this)
            
            ceFields = {...
                'shutter'
            };

            for n = 1 : length(ceFields)
                this.stScanAcquireContract.(ceFields{n}).lRequired = false;
                this.stScanAcquireContract.(ceFields{n}).lIssued = false;
            end
            
        end
        
        % For every field of this.stScanSetContract, set its lSetRequired and 
        % lSetIssued properties to false
        function resetScanSetContract(this)
            
            ceFields = fieldnames(this.stScanSetContract);
            for n = 1 : length(ceFields)
                this.stScanSetContract.(ceFields{n}).lSetRequired = false;
                this.stScanSetContract.(ceFields{n}).lSetIssued = false;
            end
            
        end
        
        function resetScanAcquireContract(this)
            
            ceFields = fieldnames(this.stScanSetContract);
            for n = 1 : length(ceFields)
                this.stScanAcquireContract.(ceFields{n}).lRequired = false;
                this.stScanAcquireContract.(ceFields{n}).lIssued = false;
            end
            
        end
        
        function onScanStartButton(this, src, evt)
            
            this.msg('onScanStartButton');
            
            this.hideScanStart();
            this.showScanPauseAbort();
            this.startNewScan();
                       
        end
        
        function onScanPauseButton(this, ~, ~)
        
            if (this.uitScanPause.get()) % just changed to true, so was playing
                this.scan.pause();
            else
                this.scan.resume();
            end
        end
        
        function onScanAbortButtonPress(this, ~, ~)
            this.scan.pause();
            this.uitScanPause.set(true);
        end
        
        function onScanAbortButton(this, ~, ~)
            this.scan.stop(); % calls onScanAbort()
        end
        
        
        
        function onPrint(this, src, evt)
            
            % POST to URL (copy code from DCT control software)
            
        end
        
        function onNewWafer(this, src, evt)
            
            % Purge all items from uilActive
            this.uilActive.setOptions(cell(1,0));
            this.uiWafer.uiAxes.purgeExposures();
            
        end
        
        function onAddToWafer(this, src, evt)
            
            % Loop through all selected prescriptions and push them to the
            % active list
            
            ceSelected = this.uilPrescriptions.get();
            for k = 1:length(ceSelected)
                this.uilActive.append(ceSelected{k});
            end
            
        end  
        
        function [stRecipe, lError] = buildRecipeFromFile(this, cPath)
           
            cMsg = sprintf('buildRecipeFromFile: %s', cPath);
            this.msg(cMsg);
            
            lError = false;
            
            if strcmp('', cPath) || ...
                isempty(cPath)
                % Has not been set
                lError = true;
                stRecipe = struct();
                return;
            end
                        
            if exist(cPath, 'file') ~= 2
                % File doesn't exist
                lError = true;
                stRecipe = struct();
                
                cMsg = sprintf(...
                    'The recipe file %s does not exist.', ...
                    cPath ...
                );
                cTitle = sprintf('Error reading recipe');
                msgbox(cMsg, cTitle, 'warn')
                
                return;
            end
            
            % File exists
            
            %{
            cStatus = this.uitxStatus.cVal;
            this.uitxStatus.cVal = 'Reading recipe ...';
            drawnow;
            %}
            
            stRecipe = loadjson(cPath);
            
            % this.uitxStatus.cVal = cStatus;
            
            if ~this.validateRecipe(stRecipe)
                lError = true;
                return;
            end

        end
            
        
        
        
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        function onScanSetState(this, stUnit, stValue)
            
            this.resetScanSetContract();
            
            % Update the stScanSetContract properties listed in stValue 
            
            ceFields = fieldnames(stValue);
            for n = 1 : length(ceFields)
                switch ceFields{n}
                    case 'task'
                        % Do nothing
                    otherwise
                        this.stScanSetContract.(ceFields{n}).lSetRequired = true;
                        this.stScanSetContract.(ceFields{n}).lSetIssued = false;
                end
            end

        end


        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the system is at the state
        function lOut = onScanIsAtState(this, stUnit, stValue)
            
            % The complexity of setState(), i.e., lots of 
            % series operations vs. one large parallel operation, dictates
            % how complex this needs to be.  I decided to implement a
            % general approach that will work for the case of complex
            % serial operations.  The idea is that each device (HIO) is
            % wrapped with a lSetRequired and lSetIssued {locical} property.
            %
            % The beginning of setState(), loops through all devices
            % that will be controlled and sets the lSetRequired flag ==
            % true for each one and false for non-controlled devices.  It also sets 
            % lSetIssued === false for all controlled devices.  
            %
            % Once a device move is commanded, the lSetIssued flag is set
            % to true.  These two flags provide a systematic way to check
            % isAtState: loop through all devices being controlled and only
            % return true when every one that needs to be moved has had its
            % move issued and also has isThere / lReady === true.
            
            % Ryan / Antine you might know a better way to do this nested
            % loop / conditional but I wanted readability and debugginb so
            % I made it verbose
            
            lDebug = true;           
            lOut = true;
                        
            ceFields= fieldnames(stValue);
            
            for n = 1:length(ceFields)
                
                cField = ceFields{n};
                
                % special case, skip task
                if strcmp(cField, 'task')
                    continue;
                end
                
                
                if this.stScanSetContract.(cField).lSetRequired
                    if lDebug
                        this.msg(sprintf('onScanIsAtState() %s set is required', cField));
                    end

                    if this.stScanSetContract.(cField).lSetIssued
                        
                        if lDebug
                            this.msg(sprintf('onScanIsAtState() %s set has been issued', cField));
                        end
                        
                        % Check if the set operation is complete
                        
                        lReady = true;
                        
                        switch cField
                            case 'reticleX'
                               if ~this.uiReticle.uiCoarseStage.uiX.getDevice().isReady()
                                   lReady = false;
                               end
                               
                            case 'reticleY'
                               if ~this.uiReticle.uiCoarseStage.uiY.getDevice().isReady()
                                   lReady = false;
                               end
                                
                            case 'waferX'
                                if ~this.uiWafer.uiCoarseStage.uiX.getDevice().isReady()
                                   lReady = false;
                               end
                                
                            case 'waferY'
                                if ~this.uiWafer.uiCoarseStage.uiY.getDevice().isReady()
                                   lReady = false;
                               end
                                
                            case 'waferZ'
                               if ~this.uiWafer.uiFineStage.uiZ.getDevice().isReady()
                                   lReady = false;
                               end
                            case 'pupilFill'
                                % FIX ME
                                
                            otherwise
                                
                                % UNSUPPORTED
                                
                        end
                        
                        
                        if lReady
                        	if lDebug
                                this.msg(sprintf('onScanIsAtState() %s set operation complete', cField));
                            end
 
                        else
                            % still isn't there.
                            if lDebug
                                this.msg(sprintf('onScanIsAtState() %s is still setting', cField));
                            end
                            lOut = false;
                            return;
                        end
                    else
                        % need to move and hasn't been issued.
                        if lDebug
                            this.msg(sprintf('onScanIsAtState() %s set not yet issued', cField));
                        end
                        
                        lOut = false;
                        return;
                    end                    
                else
                    
                    if lDebug
                        this.msg(sprintf('onScanIsAtState() %s N/A', cField));
                    end
                   % don't need to move, this param is OK. Don't false. 
                end
            end
        end


        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state (possibly contains 
        % information about the task to execute during acquire)
        function onScanAcquire(this, stUnit, stValue)
            
            this.resetScanAcquireContract();
            
            
            
            
            % FIX ME
            
            % Pre-exp pause.  xVal prop will return type double
             
            %{
            pause(stPre.femTool.uiePausePreExp.xVal);

            % Calculate the exposure time

            dSec = stPre.femTool.dDose(dose)/this.mJPerCm2PerSec;

            % Set the shutter time (ms)

            this.shutter.uieExposureTime.setVal(dSec*1e3);
            this.uiWafer.uiAxes.setExposing(true);
            this.shutter.open();
            %}
            
        end

        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the acquisition task is complete
        function l = onScanIsAcquired(this, stUnit, stValue)
            l = true;
            
            %{
            
            % Write to log
                        
            this.writeToLog('');

            % Add an exposure to the plot

            this.uiWafer.addExposure([ ...
                stPre.femTool.dX(dose)*1e-3 ...
                stPre.femTool.dY(focus)*1e-3 ...
                dose ...
                length(stPre.femTool.dX) ...
                focus ...
                length(stPre.femTool.dY)] ...
            );
            %}
        end


        function onScanAbort(this, stUnit)
             this.abort();
             this.hideScanPauseAbort();
             this.showScanStart();
             
        end


        function onScanComplete(this, stUnit)
             this.hideScanPauseAbort();
             this.showScanStart();
        end
        
        function showScanStart(this)
            this.uibScanStart.show();
        end
        
        function hideScanStart(this)
            this.uibScanStart.hide();
        end
        
        function showScanPauseAbort(this)
            
            this.uitScanPause.show();
            this.uibScanAbort.show();
        end
        
        function hideScanPauseAbort(this)
            this.uitScanPause.hide();
            this.uibScanAbort.hide();
            
        end
        

        function startNewScan(this)
            
            this.msg('startFEM');
                       
            % Pre-FEM Check
            
            if ~this.preCheck()
                return
            end
            
            % At this point, we have passed all pre-checks and want to
            % actually start moving motors and such.  The experiment/FEM
            % will now begin
            
            % Store all of the selected items in uilActive into a temporary
            % cell 
            
            this.cePrescriptions = this.uilActive.get();
                       
            % Create new log file
            
            this.createNewLog();
            
            % Tell grating and undulator to go to correct place.
            % *** TO DO ***
                        
            % Loop through prescriptions (k, l, m)
            
            for k = 1:length(this.cePrescriptions)
            
                % Build the recipe from .json file (we dogfood our own .json recipes always)
                
                cFile = fullfile(this.cDirPrescriptions, this.cePrescriptions{k});
                [stRecipe, lError] = this.buildRecipeFromFile(cFile); 
                
                if lError 
                    return;
                end
                
                this.scan = mic.StateScan(...
                    this.clock, ...
                    stRecipe, ...
                    @this.onScanSetState, ...
                    @this.onScanIsAtState, ...
                    @this.onScanAcquire, ...
                    @this.onScanIsAcquired, ...
                    @this.onScanComplete, ...
                    @this.onScanAbort ...
                );
                
                this.scan.start();
            end
            
        end
        
        
        function startFEM(this)
            
            this.msg('startFEM');
                       
            % Pre-FEM Check
            
            if ~this.preCheck()
                return
            end
            
            % At this point, we have passed all pre-checks and want to
            % actually start moving motors and such.  The experiment/FEM
            % will now begin
            
            % Store all of the selected items in uilActive into a temporary
            % cell 
            
            this.cePrescriptions = this.uilActive.get();
                       
            % Create new log file
            
            this.createNewLog();
            
            % Tell grating and undulator to go to correct place.
            % *** TO DO ***
                        
            % Loop through prescriptions (k, l, m)
            
            for k = 1:length(this.cePrescriptions)
            
                % Build the recipe from .json file (we dogfood our own .json recipes always)
                
                cFile = fullfile(this.cDirPrescriptions, this.cePrescriptions{k});
                [stRecipe, lError] = this.buildRecipeFromFile(cFile); 
                
                if lError 
                    return;
                end
                
                % Load the saved structure associated with the pupil fill
                
                cFile = fullfile( ...
                    this.cDirPupilFills, ...
                    stPre.uiPupilFillSelect.cSelected ...
                );
                
                if exist(cFile, 'file') ~= 0
                    load(cFile); % populates s in local workspace
                    stPupilFill = s;
                else
                    this.abort(sprintf('Could not find pupilfill file: %s', cFile));
                    return;
                end
                
                if ~this.uiPupilFill.np.setWavetable(stPupilFill.i32X, stPupilFill.i32Y);
                    
                    
                    cQuestion   = ['The nPoint pupil fill scanner is ' ...
                        'not enabled and not scanning the desired ' ...
                        'pupil pattern.  Do you want to run the FEM anyway?'];

                    cTitle      = 'nPoint is not enabled';
                    cAnswer1    = 'Run FEM without pupilfill.';
                    cAnswer2    = 'Abort';
                    cDefault    = cAnswer2;

                    qanswer = questdlg(cQuestion, cTitle, cAnswer1, cAnswer2, cDefault);
                    switch qanswer
                        case cAnswer1;

                        otherwise
                            this.abort('You stopped the FEM because the nPoint is not scanning.');
                            return; 
                    end
                                        
                end
                                
                % Move the reticle into position and wait until it is there
                
                this.msg(sprintf('Moving reticle to (x,y) = (%1.5f, %1.5f)', ...
                    stPre.reticleTool.dX, ...
                    stPre.reticleTool.dY));
                
                
                this.uiReticle.uiCoarseStage.hioX.setDestRaw(stPre.reticleTool.dX);
                this.uiReticle.uiCoarseStage.hioY.setDestRaw(stPre.reticleTool.dY);
                
                this.uiReticle.uiCoarseStage.hioX.moveToDest();
                this.uiReticle.uiCoarseStage.hioY.moveToDest();
                
                
                if ~this.waitFor(@this.rcsIsThere, 'reticle xy')
                    break;
                    this.abort();
                end
                
                
                % Double loop through dose and focus
                
                for dose = 1:length(stPre.femTool.dDose)
                    
                    %{
                    if ~this.lRunning
                        this.abort('');
                        break;
                    end
                    %}
                    
                    if ~this.uitPlay.get()
                        this.abort();
                        break;
                    end
                    
                    for focus = 1:length(stPre.femTool.dFocus)
                       
                        
                        %{
                        if ~this.lRunning
                            this.abort('');
                            break;
                        end
                        %}
                        
                        if ~this.uitPlay.get()
                            this.abort();
                            break;
                        end
                        
                        
                        % Move the wafer (x, y) into position. Note that
                        % the FEM dX and dY are in mm, not m. Also, they
                        % are the position of the FEM on the wafer, not the
                        % position of the stage needed to put the exposure
                        % at that location
                        
                        this.uiWafer.uiCoarseStage.hioX.setDestRaw(-stPre.femTool.dX(dose)*1e-3);
                        this.uiWafer.uiCoarseStage.hioY.setDestRaw(-stPre.femTool.dY(focus)*1e-3);
                        this.uiWafer.uiCoarseStage.hioX.moveToDest();
                        this.uiWafer.uiCoarseStage.hioY.moveToDest();
                        
                        % Wait while it gets there
                        
                        if ~this.waitFor(@this.wcsXYIsThere, 'wafer xy')
                            this.abort();
                            break;
                        end
                                                
                        
                        % TO DO: should this be closed loop with the height
                        % sensor?  Is that done at the controller level or
                        % here?
                        
                        % Move the wafer fine z into position.
                        % Remember that focus is in nm.  For now, assume
                        % the hardware takes units of nm.  Need to think
                        % about this more
                        
                        this.uiWafer.uiFineStage.hioZ.setDestRaw(stPre.femTool.dFocus(focus))
                        this.uiWafer.uiFineStage.hioZ.moveToDest();
                        
                        % Wait while it gets there
                        
                        if ~this.waitFor(@this.wfsIsThere, 'wafer z')
                            this.abort();
                            break;
                        end
                        
                        
                        % Pre-exp pause.  xVal prop will return type double
                        
                        pause(stPre.femTool.uiePausePreExp.xVal);
                        
                        % Calculate the exposure time
                        
                        dSec = stPre.femTool.dDose(dose)/this.mJPerCm2PerSec;
                        
                        % Set the shutter time (ms)
                        
                        this.shutter.uieExposureTime.setVal(dSec*1e3);
                        this.uiWafer.uiAxes.setExposing(true);
                        this.shutter.open();
                        
                        % Wait for the shutter to close
                        
                        if ~this.waitFor(@this.shIsClosed, 'shutter close')
                            this.abort();
                            break;
                        end
                        
                        this.uiWafer.uiAxes.setExposing(false);
                        
                                                                        
                        % Write to log
                        
                        this.writeToLog('');
                        
                        % Add an exposure to the plot
                        
                        this.uiWafer.addExposure([ ...
                            stPre.femTool.dX(dose)*1e-3 ...
                            stPre.femTool.dY(focus)*1e-3 ...
                            dose ...
                            length(stPre.femTool.dX) ...
                            focus ...
                            length(stPre.femTool.dY)] ...
                        );
                        
                    end
                end
                
            end
            
            msgbox('The FEM is done!', 'Finished', 'warn')
                        
            % Update play/pause
            this.uitPlay.set(false);
            
        end
        
        function onCloseRequestFcn(this, src, evt)
            delete(this.hFigure);
            this.hFigure = [];
            % this.saveState();
        end
        
        function abort(this, cMsg)
                           
            if exist('cMsg', 'var') ~= 1
                cMsg = 'The FEM was aborted.';
            end
            
            % Cleanup
            this.uiWafer.uiAxes.setExposing(false);
            
            % Throw message box.
            h = msgbox( ...
                cMsg, ...
                'FEM aborted', ...
                'help', ...
                'modal' ...
            );

            % wait for them to close the message
            % uiwait(h);
            
            this.msg(sprintf('The FEM was aborted: %s', cMsg));
            
            % Write to logs.
            this.writeToLog(sprintf('The FEM was aborted: %s', cMsg));

            this.showScanStart();
            this.hideScanPauseAbort();
            
        end
        
        function createNewLog(this)
            
            % Close existing log file
            
        end
        
        function writeToLog(this, cMsg)
            
            
        end
        
        function lReturn = preCheck(this)
           
            
            this.msg('preCheck');
            % Make sure at least one prescription is selected
            
            if (isempty(this.uilActive.get()))
                this.abort('No prescriptions were added. Please add a prescription before starting the FEM.');
                lReturn = false;
                return;
            end
            
            
            % Make sure the shutter is not open (this happens when it is
            % manually overridden)
            
            %{
            if(this.shutter.lOpen)
                this.abort('The shutter is open.  Please make sure that it is not manually overridden');
                lReturn = false;
                return; 
            end
            %}
            
            % Make sure all valves that get light into the tool are open
            % *** TO DO ***
            
            
            % Check that every single hardware instance that I will control 
            % is active
            
            
            cMsg = '';
            
            % Reticle Coarse Stage
            
            if ~this.uiReticle.uiCoarseStage.uiX.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiReticle.uiCoarseStage.uiX.id());
            end
            
            if ~this.uiReticle.uiCoarseStage.uiY.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiReticle.uiCoarseStage.uiY.id());
            end
            
            if ~this.uiReticle.uiCoarseStage.uiZ.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiReticle.uiCoarseStage.uiZ.id());
            end
            
            if ~this.uiReticle.uiCoarseStage.uiTiltX.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiReticle.uiCoarseStage.uiTiltX.id());
            end
            
            if ~this.uiReticle.uiCoarseStage.uiTiltY.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiReticle.uiCoarseStage.uiTiltY.id());
            end
            
            % Reticle Fine Stage
            
            if ~this.uiReticle.uiFineStage.uiX.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiReticle.uiFineStage.uiX.id());
            end
            
            if ~this.uiReticle.uiFineStage.uiY.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiReticle.uiFineStage.uiY.id());
            end
            
            % Wafer Coarse Stage
            
            if ~this.uiWafer.uiCoarseStage.uiX.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiWafer.uiCoarseStage.uiX.id());
            end
            
            if ~this.uiWafer.uiCoarseStage.uiY.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiWafer.uiCoarseStage.uiY.id());
            end
            
            if ~this.uiWafer.uiCoarseStage.uiZ.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiWafer.uiCoarseStage.uiZ.id());
            end
            
            if ~this.uiWafer.uiCoarseStage.uiTiltX.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiWafer.uiCoarseStage.uiTiltX.id());
            end
            
            if ~this.uiWafer.uiCoarseStage.uiTiltY.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiWafer.uiCoarseStage.uiTiltY.id());
            end
            
            % Wafer Fine Stage
            
            if ~this.uiWafer.uiFineStage.uiZ.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiWafer.uiFineStage.uiZ.id());
            end
            
            
            %{
            if ~this.uiReticle.mod3.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiReticle.mod3.id());
            end
            %}

            
            %{
            if ~this.uiWafer.hs.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiWafer.hs.id());
            end
            if ~this.uiPupilFill.np.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.uiPupilFill.np.id());
            end
            %}
            
            if ~strcmp(cMsg, '')
                
                cQuestion   = sprintf( ...
                    ['The following hardware components are virtualized (not active):' ...
                    '\n %s \n\n' ...
                    'Do you want to continue running the FEM with virtual hardware?'], ...
                    cMsg ...
                );
                
                cTitle      = 'Warning: hardware is virtualized';
                cAnswer1    = 'Run FEM with virtual hardware';
                cAnswer2    = 'Abort';
                cDefault    = cAnswer2;

                qanswer = questdlg(cQuestion, cTitle, cAnswer1, cAnswer2, cDefault);
                switch qanswer
                    case cAnswer1;

                    otherwise
                        this.abort('You stopped the FEM because some hardware was virtualized.');
                        lReturn = false;
                        return; %  exit startFEM() method
                end
            end
            
            
            % Throw up the "Run preseciption(s) ______?" dialog box
                        
            cQuestion   = sprintf( ...
                ['You are about to run the following prescriptions: ' ...
                '\n\n\t\t\t--%s\n\n is that OK?'], ...
                strjoin(this.uilActive.get(), '\n\t\t\t--') ...
            );
            cTitle      = 'Confirm prescriptions';
            cAnswer1    = 'Run FEM';
            cAnswer2    = 'Abort';
            cDefault    = cAnswer1;
            
            qanswer = questdlg(cQuestion, cTitle, cAnswer1, cAnswer2, cDefault);
           
            switch qanswer
                case cAnswer1
                    lReturn = true;
                    return;
                otherwise
                    this.abort('You elected not to run the prescription(s) you had queued.');
                    lReturn = false;
                    return; %  exit startFEM() method
            end
            
            
        end
        
                
        % Helper functions use by waitFor() (see below)
        
        function lReturn = rcsIsThere(this)
            
            lReturn = this.uiReticle.uiCoarseStage.hioX.lIsThere && this.uiReticle.uiCoarseStage.hioY.lIsThere;
            
        end
        
        function lReturn = wcsXYIsThere(this)
           
            lReturn = this.uiWafer.uiCoarseStage.hioX.lIsThere && this.uiWafer.uiCoarseStage.hioY.lIsThere;
            
        end
        
        function lReturn = wfsIsThere(this)
            
            lReturn = this.uiWafer.uiFineStage.hioZ.lIsThere;
            
        end
        
        function lReturn = unpaused(this)
            
            lReturn = this.uitPlay.get();
            
        end
        
        function lReturn = shIsClosed(this)
            
            lReturn = ~this.shutter.lOpen;
            
        end
        
        
        function lReturn = waitFor(this, fh, cMsg)
            
            % @parameter fh   function handle
            % This is a blocking wait 
            
            if exist('cMsg', 'var') ~= 1
                cMsg = '';
            end
                        
            while(~fh())
                this.msg(sprintf('waiting... %s', cMsg));
                
                % Check for abort.  We don't deal with pauses here, cannot
                % pause while we are waiting for something else to finish
                
                % if ~this.lRunning
                if ~this.uitPlay.get()
                    lReturn = false;
                    break;
                else
                    pause(this.dPauseTime);
                end
            end 
            
            lReturn = true;
            
        end
        
        function lOut = validateRecipe(this, stRecipe)
            % FIX ME
            lOut = true;            
        end
                

    end 
    
    
end