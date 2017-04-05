classdef ExptControl < HandlePlus
    
    % ec
    % A panel with a list of available prescriptions, the ability to queue
    % multiple prescriptions to a new experiment (wafer), start/pause/stop
    % the experiment, checkboxes for booleans pertaining to running the
    % experiment
    
    
    properties (Constant)
       
        dWidth          = 750
        dHeight         = 320
        dPauseTime      = 1
        mJPerCm2PerSec  = 5         % Eventually replace with real num
        
    end
	properties
        
        % In the control panel
        uilPrescriptions            
        uilActive
        uibNewWafer
        uibAddToWafer
        uibPrint
        uicWaferLL
        uicAutoVentAtLL
        
        shutter
        waferControl
        reticleControl
        pupilFill
                
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
          
        clock
        cDir
        cSaveDir    = 'prescriptions'
        cLogDir     = 'logs'
        hPanel
        hFigure
        dListWidth      = 500
        dListHeight     = 150
        cePre           % Store uilActive.ceOptions when FEM starts
         
        
        uitPlay
        
        % Going to have a play/pause button and an abort button.  When you
        % click play the first time, a logical lRun = true will be set.  An
        % abort button will be shown.  Chenging the status of the button
        % will then put us into wait.  Only if we click abort lRun = false
        % will be set and the abort button will be hidden
        
        lRunning = false
        
    end
    
        
    events
        ePreChange
    end
    

    
    methods
        
        
        function this = ExptControl( ...
            clock, ...
            shutter, ...
            waferControl, ...
            reticleControl, ...
            pupilFill)
            
            this.clock              = clock;
            this.shutter            = shutter;
            this.waferControl       = waferControl;
            this.reticleControl     = reticleControl;
            this.pupilFill          = pupilFill;
                        
            % ff    fieldfill?
            % eps   beamline EPS stuff
            % mono  beamine monochromater
                        
            cPath = mfilename('fullpath');
            cFile = mfilename;
            this.cDir = cPath(1:end-length(cFile));
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
                'CloseRequestFcn', @this.handleCloseRequestFcn ...
                );
            
            drawnow;               
            
            dPad = 10;
            dTop = 20;
            
            this.uilPrescriptions.build(this.hFigure, ...
                dPad, ...
                dTop, ...
                this.dListWidth, ...
                this.dListHeight);
            
            dEditWidth = 100;
            dTop = dTop + this.dListHeight + 3*dPad;
            
            this.uibNewWafer.build(this.hFigure, ...
                dPad, ...
                dTop, ...
                dEditWidth, ...
                Utils.dEDITHEIGHT);
            this.uibAddToWafer.build(this.hFigure, ...
                dPad + dEditWidth + dPad, ...
                dTop, ...
                dEditWidth, ...
                Utils.dEDITHEIGHT);
            this.uibPrint.build(this.hFigure, ...
                dPad + dEditWidth + dPad + dEditWidth + dPad, ...
                dTop, ...
                100, ...
                Utils.dEDITHEIGHT);
            
            dTop = dTop + Utils.dEDITHEIGHT + dPad;
            this.uilActive.build(this.hFigure, ...
                dPad, ...
                dTop, ...
                this.dListWidth, ...
                40);
            
           dTop = 30;
           dSep = 20;
           this.uicWaferLL.build(this.hFigure, ...
               dPad + this.dListWidth + dPad, ...
               dTop, ...
               200, ...
               20);
            
           dTop = dTop + dSep;
           this.uicAutoVentAtLL.build(this.hFigure, ...
               dPad + this.dListWidth + dPad, ...
               dTop, ...
               200, ...
               20);
           
           dTop = dTop + 20;
           this.uitPlay.build(this.hFigure, ...
               dPad + this.dListWidth + dPad, ...
               dTop, ...
               200, ...
               Utils.dEDITHEIGHT);
           
           
           dTop = dTop + 20;
           
                      
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
            
            cPath = fullfile(this.cDir, '..', this.cSaveDir);
            ceReturn = Utils.dir2cell(cPath, 'date', 'descend');
            
        end
                    

    end
    
    methods (Access = private)
        
        function init(this)
                       
            this.msg('init()');
            this.uilPrescriptions   = UIList(cell(1,0), 'Prescriptions', false, false, true, true);
            %addlistener(this.uilPrescriptions, 'eDelete', @this.handlePrescriptionsDelete);
            %addlistener(this.uilPrescriptions, 'eChange', @this.handlePrescriptionsChange);
            this.uilPrescriptions.setRefreshFcn(@this.refreshFcn);
            this.uilPrescriptions.refresh();
            
            this.uibNewWafer        = UIButton('New Wafer');
            this.uibAddToWafer      = UIButton('Add To Wafer');
            this.uibPrint           = UIButton('Print');
            
            addlistener(this.uibNewWafer, 'eChange', @this.handleNewWafer);
            addlistener(this.uibAddToWafer, 'eChange', @this.handleAddToWafer);
            addlistener(this.uibPrint, 'eChange', @this.handlePrint);
            
            this.uilActive          = UIList(cell(1,0), 'Added prescriptions', true, true, false, false);
            
            
            this.uicWaferLL         = UICheckbox(false, 'Wafer to LL when done');
            this.uicAutoVentAtLL    = UICheckbox(false, 'Auto vent wafer at LL');
            
            
            st1 = struct();
            st1.lAsk        = false;
            
            st2 = struct();
            st2.lAsk        = true;
            st2.cTitle      = 'Paused';
            st2.cQuestion   = 'The FEM is now paused.  Click "resume" to continue or "abort" to abort the FEM.';
            st2.cAnswer1    = 'Abort';
            st2.cAnswer2    = 'Resume';
            st2.cDefault    = st2.cAnswer2;
            
            this.uitPlay            = UIToggle( ...
                'Start FEM', ...
                'Pause FEM', ...
                false, uint8(0), uint8(0), ...
                st1, ...
                st2);
            
            addlistener(this.uitPlay, 'eChange', @this.handlePlay);
                       
        end
        
        function handlePlay(this, src, evt)
            
            this.msg('handlePlay');
            
            if this.uitPlay.lVal
                this.startFEM();
            end
                       
        end
        
        
        
        function handlePrint(this, src, evt)
            
            % POST to URL (copy code from DCT control software)
            
        end
        
        function handleNewWafer(this, src, evt)
            
            % Purge all items from uilActive
            this.uilActive.ceOptions = cell(1,0);
            this.waferControl.purgeExposures();
            
        end
        
        function handleAddToWafer(this, src, evt)
            
            % Loop through all selected prescriptions and push them to the
            % active list
            
            for k = 1:length(this.uilPrescriptions.ceSelected)
                this.uilActive.append(this.uilPrescriptions.ceSelected{k});
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
            
            this.cePre = this.uilActive.ceOptions;
                       
            % Create new log file
            
            this.createNewLog();
            
            % Tell grating and undulator to go to correct place.
            % *** TO DO ***
                        
            % Loop through prescriptions (k, l, m)
            
            for k = 1:length(this.cePre)
            
                % Load the saved structure associated with the prescription
                
                cFile = fullfile(this.cDir, '..', this.cSaveDir, this.cePre{k});
                
                if exist(cFile, 'file') ~= 0
                    load(cFile); % populates s in local workspace
                    stPre = s;
                else
                    this.abort(sprintf('Could not find prescription file: %s', cFile));
                    return;
                end
                
                % Load the saved structure associated with the pupil fill
                
                cFile = fullfile( ...
                    this.cDir, ...
                    '..', ...
                    stPre.pupilFillSelect.cSaveDir, ...
                    stPre.pupilFillSelect.cSelected ...
                );
                
                if exist(cFile, 'file') ~= 0
                    load(cFile); % populates s in local workspace
                    stPupilFill = s;
                else
                    this.abort(sprintf('Could not find pupilfill file: %s', cFile));
                    return;
                end
                
                if ~this.pupilFill.np.setWavetable(stPupilFill.i32X, stPupilFill.i32Y);
                    
                    
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
                
                
                this.reticleControl.rcs.hioX.setDestRaw(stPre.reticleTool.dX);
                this.reticleControl.rcs.hioY.setDestRaw(stPre.reticleTool.dY);
                
                this.reticleControl.rcs.hioX.moveToDest();
                this.reticleControl.rcs.hioY.moveToDest();
                
                
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
                    
                    if ~this.uitPlay.lVal
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
                        
                        if ~this.uitPlay.lVal
                            this.abort();
                            break;
                        end
                        
                        
                        % Move the wafer (x, y) into position. Note that
                        % the FEM dX and dY are in mm, not m. Also, they
                        % are the position of the FEM on the wafer, not the
                        % position of the stage needed to put the exposure
                        % at that location
                        
                        this.waferControl.wcs.hioX.setDestRaw(-stPre.femTool.dX(dose)*1e-3);
                        this.waferControl.wcs.hioY.setDestRaw(-stPre.femTool.dY(focus)*1e-3);
                        this.waferControl.wcs.hioX.moveToDest();
                        this.waferControl.wcs.hioY.moveToDest();
                        
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
                        
                        this.waferControl.wfs.hioZ.setDestRaw(stPre.femTool.dFocus(focus))
                        this.waferControl.wfs.hioZ.moveToDest();
                        
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
                        this.waferControl.lExposing = true;
                        this.shutter.open();
                        
                        % Wait for the shutter to close
                        
                        if ~this.waitFor(@this.shIsClosed, 'shutter close')
                            this.abort();
                            break;
                        end
                        
                        this.waferControl.lExposing = false;
                        
                                                                        
                        % Write to log
                        
                        this.writeToLog('');
                        
                        % Add an exposure to the plot
                        
                        this.waferControl.addExposure([ ...
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
            this.uitPlay.lVal = false;
            
        end
        
        function handleCloseRequestFcn(this, src, evt)
            delete(this.hFigure);
            % this.saveState();
        end
        
        function abort(this, cMsg)
                           
            if exist('cMsg', 'var') ~= 1
                cMsg = '';
            end
            
            % Cleanup
            this.waferControl.lExposing = false;
            
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

            % Update play/pause
            this.uitPlay.lVal = false;
            
        end
        
        function createNewLog(this)
            
            % Close existing log file
            
        end
        
        function writeToLog(this, cMsg)
            
            
        end
        
        function lReturn = preCheck(this)
           
            
            this.msg('preCheck');
            % Make sure at least one prescription is selected
            
            if (isempty(this.uilActive.ceOptions))
                this.abort('No prescriptions were added. Please add a prescription before starting the FEM.');
                lReturn = false;
                return;
            end
            
            
            % Make sure the shutter is not open (this happens when it is
            % manually overridden)
            
            if(this.shutter.lOpen)
                this.abort('The shutter is open.  Please make sure that it is not manually overridden');
                lReturn = false;
                return; 
            end
            
            % Make sure all valves that get light into the tool are open
            % *** TO DO ***
            
            
            % Check that every single hardware instance that I will control 
            % is active
            
            
            cMsg = '';
            if ~this.reticleControl.rcs.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.reticleControl.rcs.id());
            end
            if ~this.reticleControl.rfs.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.reticleControl.rfs.id());
            end
            if ~this.reticleControl.mod3.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.reticleControl.mod3.id());
            end
            if ~this.waferControl.wcs.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.waferControl.wcs.id());
            end
            if ~this.waferControl.wfs.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.waferControl.wfs.id());
            end
            if ~this.waferControl.hs.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.waferControl.hs.id());
            end
            if ~this.pupilFill.np.isActive()
                cMsg = sprintf('%s\n%s', cMsg, this.pupilFill.np.id());
            end
            
            
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
                strjoin(this.uilActive.ceOptions, '\n\t\t\t--') ...
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
            
            lReturn = this.reticleControl.rcs.hioX.lIsThere && this.reticleControl.rcs.hioY.lIsThere;
            
        end
        
        function lReturn = wcsXYIsThere(this)
           
            lReturn = this.waferControl.wcs.hioX.lIsThere && this.waferControl.wcs.hioY.lIsThere;
            
        end
        
        function lReturn = wfsIsThere(this)
            
            lReturn = this.waferControl.wfs.hioZ.lIsThere;
            
        end
        
        function lReturn = unpaused(this)
            
            lReturn = this.uitPlay.lVal;
            
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
                if ~this.uitPlay.lVal
                    lReturn = false;
                    break;
                else
                    pause(this.dPauseTime);
                end
            end 
            
            lReturn = true;
            
        end
                

    end 
    
    
end