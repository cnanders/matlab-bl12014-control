classdef PrescriptionTool < mic.Base
    
    % A figure that lets you configure:
    %
    %   Process
    %   Reticle
    %   Pupilfill
    %   FEM
    %
    % in order to create a complete prescription for running the MET. It
    % lets you save the prescription and checks to make sure you don't
    % overwrite an existing file.  The entire goal is to save .mat files to
    % met5gui/prescriptions.
    % 
    % This panel does not contain a mic.ui.common.List with all of the available
    % prescriptinos. It is intended that the list is shown in the
    % ExptControl panel and all support code to handle deleting
    % prescriptions and such needs to live in ExptControl
    %
    % This method will dispatch eNew anytime a new pre is added and a
    % listener should tell ExptControl to append a new pre to the end of
    % its list
    % 
    % Later on, I might think it was dumb to not have the prescription list
    % here (for code organization purposes).  The decision, however, was
    % based on UX.  I want the "control" panel to feel like you are
    % choosing available prescriptions to add to your wafer, I don't want
    % it to feel like you have to go to the "PrescriptionTool" panel and "send" a
    % prescription over to the control panel. Either way the same code
    % needs to exist. 
    %
    % I think I moved away from this.
   
    
    properties (Constant)
       
        dWidth          = 620
        dHeight         = 600
        dColorFigure = [200 200 200]./255

                
    end
    
	properties
        
        uieName
        
        uieVibration
        uieTimeToSettle
        
        uicbFadeY
        uieFadeY

        uicbUseFastMode
        uicbSkipIndex
        
        uiProcessTool              
        uiReticleTool                
        uiPupilFillTool            
        uiFemTool                  
                
    end
    
    properties (SetAccess = private)
        
        uiListPrescriptions
    
    end
    
    properties (Access = private)
          
        hParent
        hPanel
        hPanelSaved
        hDock
        cDirThis
        cDirSrc
        
        
        
        uiButtonSave         % button for saving
        uiButtonOverwrite
        
        % For undo/redo
        % Use implementation from Redux since it is standard
        % http://redux.js.org/docs/recipes/ImplementingUndoHistory.html
        
        % {cell of struct}
        cestStatesPast
        % {struct}
        stStatePresent
        % {cell of struct}
        cestStatesFuture 
                
        dWidthBorderPanel = 0
    
    end
    
        
    events
        
        eDelete
        eSizeChange
        eNew
        
    end
    

    
    methods
        
        
        function this = PrescriptionTool(varargin)
            
            
            this.cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSrc = fullfile(this.cDirThis, '..', '..');
            
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end 
            
            
            this.init();
            
        end
        
        function cec = getSaveLoadProps(this)
            cec = {...
                'uieName', ...
                'uieVibration', ...
                'uieTimeToSettle', ...
                'uieFadeY', ...
                'uicbFadeY', ...
                'uicbUseFastMode', ...
                ...'uiPupilFillTool', ...
                'uiListPrescriptions', ...
                'uiFemTool', ... 
             };
        end
        
        
        function st = save(this)
             cecProps = this.getSaveLoadProps();
            
            st = struct();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                if this.hasProp( cProp)
                    st.(cProp) = this.(cProp).save();
                end
            end

             
        end
        
        function load(this, st)
                        
            cecProps = this.getSaveLoadProps();
            for n = 1 : length(cecProps)
               cProp = cecProps{n};
               if isfield(st, cProp)
                   if this.hasProp( cProp )
                        this.(cProp).load(st.(cProp))
                   end
               end
            end
            
        end
        
        
        
        
        
        function build(this, hParent, dLeft, dTop)
             
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Prescription Builder',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
           
                        
            % set(hParent, 'renderer', 'OpenGL'); % Enables proper stacking
            dPad = 10;
            dLeft = 10;
            dTop = 15;
            
            
            %{
            this.uiReticleTool.build(...
                this.hPanel, ...
                dLeft, ...
                dTop);
            this.uiPupilFillTool.build( ...
                this.hPanel, ...
                dLeft, ...
                100); % dTop + this.uiReticleTool.dHeight + dPad
            dLeft = dLeft +  this.uiReticleTool.dWidth + dPad;
            %}
            
            
            %{
            this.uiProcessTool.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop);
            
            dLeft = dLeft + this.uiProcessTool.dWidth + dPad;
            %}
            
            dWidth = 200;
            dHeight = 24;
            
            this.uieName.build(...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                dHeight ...
           );
       
            dLeft = dLeft + dWidth + 10;
            dWidth = 75;
            this.uieVibration.build(...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                dHeight ...
           );
       
            dLeft = dLeft + dWidth + 10;
            this.uieTimeToSettle.build(...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                dHeight ...
           );
                        
            dLeft = dLeft + dWidth + 10;
            
            this.uicbFadeY.build(...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                dHeight ...
            );

            this.uicbUseFastMode.build(...
                this.hPanel, ...
                dLeft, ...
                dTop  + 20, ...
                dWidth, ...
                dHeight ...
            );

            this.uicbSkipIndex.build(...
                this.hPanel, ...
                dLeft + 80, ...
                dTop , ...
                dWidth + 40, ...
                dHeight ...
            )

            dLeft = dLeft + dWidth + 10;            
            this.uieFadeY.build(...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                dHeight ...
           );
            if this.uicbFadeY.get() && ~this.uicbUseFastMode.get()
                this.uieFadeY.show()
            else
                this.uieFadeY.hide();
            end

            
            
        
        
            dTop = dTop + dHeight + 15 + dPad;
            dLeft = 10;
            
            this.uiFemTool.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop);

            dTop = dTop + this.uiFemTool.dHeight;
            
            dLeft = dLeft + 10;
            dHeightList = 250;
            this.uiListPrescriptions.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                this.dWidth - 4*dPad, ... - this.uiProcessTool.dWidth, ...
                dHeightList);
            
            this.uiListPrescriptions.refresh();
            
            
            dWidthButton = 120;
            dTopButtons = dTop + dHeightList - 35;
            dLeft = dLeft + 10;
            this.uiButtonSave.build( ...
                this.hPanel, ...
                dLeft, ...
                dTopButtons, ...
                dWidthButton, ...
                24);
            
            dLeft = dLeft + dWidthButton + 10;
            this.uiButtonOverwrite.build( ...
                this.hPanel, ...
                dLeft, ...
                dTopButtons, ...
                dWidthButton, ...
                24);
            

                                              
        end
        
        
        
        %% Destructor
        
        function delete(this)
            

                        
        end
        


        
        function stRecipe = getRecipeFastCoupledMode(this)

        
            % Combine unrelated tasks into a single state
            
            ceValues = cell(1, length(this.uiFemTool.dX) * length(this.uiFemTool.dY) + 1);
            
            % Use first state to set reticle field and pupil fill 
            
            u8Count = 1;
            
            
            if ~this.uicbSkipIndex.get()
                % SET WORKING MODE TO 5
                stValue = struct();
                stValue.workingMode = 5; % allow xy move
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;

                
                % Reticle and wafer: Ret XY, Wafer XY, 
                stValue = struct();
                    stValue.xyReticleFine = [5, 5];

                    %%  Index shot
                    mMid = ceil(length(this.uiFemTool.dDose)/2);
                    nMid = ceil(length(this.uiFemTool.dFocus)/2);


                    % x position on wafer you want the exposure to be
                    dXVal = -this.uiFemTool.dX(1); 
                    % y position on wafer you want exposure to be
                    if length(this.uiFemTool.dY) > 1
                        dYStep = this.uiFemTool.dY(2) - this.uiFemTool.dY(1);
                    else
                        dYStep = .2;
                    end
                    dYVal = -(this.uiFemTool.dY(1) - dYStep); % STEP FIX ME;

                    stValue.waferXY = [dXVal, dYVal]; 

                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                
                
                % DMI-based settle of motion of reticle fine xy from big move to index shot to
                % dissipate
                if this.uieTimeToSettle.get() > 0.1
                    stValue = struct();
                    stSettle = struct();
                    stSettle.value = this.uieVibration.get();
                    stSettle.time = this.uieTimeToSettle.get();
                    stValue.settle = stSettle;
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
                end

                % Wafer Z then drift control
                stValue = struct();
                stValue.waferZThenDriftControl = this.uiFemTool.dFocus(nMid);
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                
                % WORKING MODE 4
                stValue = struct();
                stValue.workingMode = 4; % drift closed loop for exposure
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                

                % EXPOSE
                    stValue = struct();
                    stValue.type = 'exposure';

                    % Exposure task this info is used to color the exposures
                    stTask = struct();
                    stTask.dose = this.uiFemTool.dDose(mMid);
                    stTask.femCols = length(this.uiFemTool.dDose);
                    stTask.femCol = mMid;
                    stTask.femRows = length(this.uiFemTool.dFocus);
                    stTask.femRow = nMid;

                    stValue.task = stTask;

                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
            end % end index
        
            
            % WORKING MODE 5
            stValue = struct();
            stValue.workingMode = 5; % drift closed loop for exposure
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
            
            % Horizontal Serp
            % FEM for each focus (m), do each dose (n)

            for m = 1 : length(this.uiFemTool.dFocus) % rows
                % y position on wafer you want the exposure to be
                % stValue = struct();
                % stValue.waferY = -this.uiFemTool.dY(m); 
                % ceValues{u8Count} = stValue;
                % u8Count = u8Count + 1; 

                dWaferY = -this.uiFemTool.dY(m); 

                for n = 1 : length(this.uiFemTool.dDose) % cols

                    % tRACKING OFF, WAFER/RET MOVES
                    stValue = struct();
                        dX = -this.uiFemTool.dX;
                        dDose = this.uiFemTool.dDose;

                        stValue.tracking = 'stop';
                        ceValues{u8Count} = stValue;

                        stValue.xyReticleFine = [5, 5];
                        stValue.waferXY = [dX(n), dWaferY];

                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
                   


                    % DMI-based settle of motion of reticle fine xy from big move to index shot to
                    % dissipate
                    if this.uieTimeToSettle.get() > 0.1
                        stValue = struct();
                        stSettle = struct();
                        stSettle.value = this.uieVibration.get();
                        stSettle.time = this.uieTimeToSettle.get();
                        stValue.settle = stSettle;
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                    end

                     % Wafer Z then drift control
                    stValue = struct();
                    stValue.waferZThenDriftControl = this.uiFemTool.dFocus(m);
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;

                    % WORKING MODE 4
                    stValue = struct();
                    stValue.workingMode = 4; % Drift closed loop for exposure
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
                    
                    % EXPOSE
                    stValue = struct();
                    stValue.type = 'exposure';

                    stTask = struct();
                    stTask.dose = dDose(n); % cant use this since the flip each row. this.uiFemTool.dDose(n);
                    stTask.femCols = length(this.uiFemTool.dDose);
                    stTask.femRows = length(this.uiFemTool.dFocus);
                    
                    stTask.femRow = m;
                    stTask.femCol = n;

                    % Enough time for resonant motion of frame excited from stage move
                    % to settle
                    % stTask.pausePreExpose = 5;

                    stValue.task = stTask;

                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
                    
                    % 2022.01 update to open the SMS slow shutter (glass plate)
                    % 2024.01 no longer do this
                    % stValue = struct();
                    % stValue.smsSlowShutter = false;
                    % ceValues{u8Count} = stValue;
                    % u8Count = u8Count + 1;


                    % wm_RUN
                    stValue = struct();
                    stValue.workingMode = 5;
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;

                end
            end

            % Stop drift monitor tracking
            stValue = struct();
            stValue.tracking = 'stop';
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
               
            stUnit = struct();
            stUnit.waferX = 'mm';
            stUnit.waferY = 'mm';
            stUnit.waferZ = 'nm';
            stUnit.reticleX = 'mm';
            stUnit.reticleY = 'mm';
            stUnit.xReticleFine = 'um';
            stUnit.yReticleFine = 'um';
            stUnit.pupilFill = 'n/a';
            stUnit.workingMode = 'n/a';
            
            stRecipe = struct();
            stRecipe.process = this.uiProcessTool.savePublic();
            stRecipe.fem = this.uiFemTool().savePublic();
            stRecipe.unit = stUnit;
            stRecipe.values = ceValues;

        end
        
        function stRecipe = getRecipeFadeY(this)
            
            ceValues = cell(1, length(this.uiFemTool.dX) * length(this.uiFemTool.dY) + 1);
            
             u8Count = 1;
                        
            % Use other states for wafer pos and exposure task FEM
            % working mode to allow  x y move
            stValue = struct();
            stValue.workingMode = 5; % allow xy move
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;

            
            % Center the reticle fine stage in x and y
            
            stValue = struct();
            stValue.xReticleFine = 5;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
            stValue = struct();
            stValue.yReticleFine = 5;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
            %%  Index shot
            
            mMid = ceil(length(this.uiFemTool.dDose)/2);
            nMid = ceil(length(this.uiFemTool.dFocus)/2);
            

            % x position on wafer you want the exposure to be
            stValue = struct();
            stValue.waferX = -this.uiFemTool.dX(1); 
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
            % y position on wafer you want exposure to be
            if length(this.uiFemTool.dY) > 1
                dYStep = this.uiFemTool.dY(2) - this.uiFemTool.dY(1);
            else
                dYStep = .2;
            end
            
            stValue = struct();
            stValue.waferY = -(this.uiFemTool.dY(1) - dYStep); % STEP FIX ME; 
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
             % Start drift monitor tracking
            stValue = struct();
            stValue.tracking = 'start';
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;

            
            % DMI-based settle vibration
            if this.uieTimeToSettle.get() > 0.1
                stValue = struct();
                stSettle = struct();
                stSettle.value = this.uieVibration.get();
                stSettle.time = this.uieTimeToSettle.get();
                stValue.settle = stSettle;
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
            end
            
           
            
             % WM 4 (drift control)
            %{
            stValue = struct();
            stValue.workingMode = 4; % Drift closed loop for exposure
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            %}
            
          
            
            % wait for acc of aerial image to settle
            stValue = struct();
            stValue.waitForAccOfAIToSettle = true;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
            % wait for velocity of aerial image to settle
            stValue = struct();
            stValue.waitForVelOfAIToSettle = true;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
             % WFZ
            stValue = struct();
            stValue.waferZ = this.uiFemTool.dFocus(nMid);
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
           
            
            % fadeY
            stValue = struct();
            stFadeY = struct();
            stFadeY.value = this.uieFadeY.get();
            stFadeY.dose = this.uiFemTool.dDose(mMid);
            stValue.fadeY = stFadeY;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
           
            
            % 2022.01 update to open the SMS slow shutter (glass plate)
            stValue = struct();
            stValue.smsSlowShutter = true;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            

            % State
            stValue = struct();
            stValue.type = 'exposure';

            % Exposure task this info is used to color the exposures
            stTask = struct();
            stTask.dose = this.uiFemTool.dDose(mMid);
            stTask.femCols = length(this.uiFemTool.dDose);
            stTask.femCol = mMid;
            stTask.femRows = length(this.uiFemTool.dFocus);
            stTask.femRow = nMid;
            
            % Enough time for resonant motion of frame excited from stage move
            % to settle
            % stTask.pausePreExpose = 30; % FIX ME

            stValue.task = stTask;

            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
            % 2022.01 update to close the SMS slow shutter (glass plate)
            stValue = struct();
            stValue.smsSlowShutter = false;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
            % wm_RUN
            %{
            stValue = struct();
            stValue.workingMode = 5;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            %}
            
            % stop fadeY
            stValue = struct();
            stValue.stopFadeY = true;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
            % Stop drift monitor tracking
            stValue = struct();
            stValue.tracking = 'stop';
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
                            
            % Horizontal Serp

            lSerpentine = false;

            for m = 1 : length(this.uiFemTool.dFocus) % rows

                % y position on wafer you want the exposure to be
                stValue = struct();
                stValue.waferY = -this.uiFemTool.dY(m); 
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1; 

                for n = 1 : length(this.uiFemTool.dDose) % cols

                    % For even numbered columns, expose the row in reverse
                    % order so there are never large wafer z changes during
                    % the FEM and never any large wafer y changes during
                    % FEM

                    dX = -this.uiFemTool.dX;
                    dDose = this.uiFemTool.dDose;

                    if lSerpentine && mod(m, 2) == 0 % even row, flip order of cols
                        dX = flip(dX);
                        dDose = flip(dDose);
                    end


                    stValue = struct();
                    stValue.waferX = dX(n); 
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;

                    % Center the reticle fine stage in x and y

                    stValue = struct();
                    stValue.xReticleFine = 5;
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;

                    stValue = struct();
                    stValue.yReticleFine = 5;
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
                    
                     % Start drift monitor tracking after WFZ
                      % 2022.06: Important to have this before the waif for
                      % Acc and waitForVel to settle because resetting the
                      % DMI will artifically inflate the accel and velocity
                      % values.  Need to make sure that the velocity used
                      % in the fadeY function represents actual velocity
                      % and not something artifically altered by issuing
                      % the start/stop tracking
                    
                      
                    stValue = struct();
                    stValue.tracking = 'start';
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
                    
                    % DMI-based vibration settle
                    if this.uieTimeToSettle.get() > 0.1
                        stValue = struct();
                        stSettle = struct();
                        stSettle.value = this.uieVibration.get();
                        stSettle.time = this.uieTimeToSettle.get();
                        stValue.settle = stSettle;
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                    end


                     
                    
                    
                    
                    
                    % wait for acc of aerial image to settle
                    stValue = struct();
                    stValue.waitForAccOfAIToSettle = true;
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;

                    % wait for velocity of aerial image to settle
                    stValue = struct();
                    stValue.waitForVelOfAIToSettle = true;
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
                    
                    
                    % Val you want HS to read during exposure
                    
                    stValue = struct();
                    stValue.waferZ = this.uiFemTool.dFocus(m);
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;

                   

                    % fadeY
                    stValue = struct();
                    stFadeY = struct();
                    stFadeY.value = this.uieFadeY.get();
                    stFadeY.dose = dDose(n);
                    stValue.fadeY = stFadeY;
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
                    
                     % run exposure NEED TO USE SINGLE QUOTES IN RECIPE for struct2json
                     %{
                    stValue = struct();
                    stValue.workingMode = 4; % Drift closed loop for exposure
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
                     %}

                    % 2022.01 update to open the SMS slow shutter (glass plate)
                    stValue = struct();
                    stValue.smsSlowShutter = true;
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;


                    % Exposure task 
                    stValue = struct();
                    stValue.type = 'exposure';

                    stTask = struct();
                    stTask.dose = dDose(n); % cant use this since the flip each row. this.uiFemTool.dDose(n);
                    stTask.femCols = length(this.uiFemTool.dDose);
                    stTask.femRows = length(this.uiFemTool.dFocus);

                    stTask.femRow = m;

                    if lSerpentine && mod(m, 2) == 0
                        % even rows go backwards through cols  cols go backwards through rows
                        % n = row index
                        % m = col index
                        stTask.femCol = length(this.uiFemTool.dDose) + 1 - n;
                    else
                        stTask.femCol = n;
                    end

                    % Enough time for resonant motion of frame excited from stage move
                    % to settle
                    % stTask.pausePreExpose = 5;

                    stValue.task = stTask;

                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;

                    % 2022.01 update to open the SMS slow shutter (glass plate)
                    stValue = struct();
                    stValue.smsSlowShutter = false;
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;

                    
                    % wm_RUN
                    %{
                    stValue = struct();
                    stValue.workingMode = 5;
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
                    %}
                    
                    % stop fadeY
                    stValue = struct();
                    stValue.stopFadeY = true;
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;

                    % Stop drift monitor tracking
                    stValue = struct();
                    stValue.tracking = 'stop';
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
                    
                    

                end
               
                
            end
                                
            stUnit = struct();
            stUnit.waferX = 'mm';
            stUnit.waferY = 'mm';
            stUnit.waferZ = 'nm';
            stUnit.reticleX = 'mm';
            stUnit.reticleY = 'mm';
            stUnit.xReticleFine = 'um';
            stUnit.yReticleFine = 'um';
            stUnit.pupilFill = 'n/a';
            stUnit.workingMode = 'n/a';
            
            stRecipe = struct();
            stRecipe.process = this.uiProcessTool.savePublic();
            stRecipe.fem = this.uiFemTool().savePublic();
            stRecipe.unit = stUnit;
            stRecipe.values = ceValues;
            
            
            
        end
        
        
        function stRecipe = getRecipe(this)
            
            if this.uicbUseFastMode.get()
                % stRecipe = this.getRecipeFastMode();
                stRecipe = this.getRecipeFastCoupledMode();
                return
            end
            if this.uicbFadeY.get()
                stRecipe = this.getRecipeFadeY();
                return
            end
            
            
            % There is order to the states.
            % We need to move stage (x,y)
            % once there, move height sensor z via wafer coarse and fine z closed loop,
            % once there, set working mode to drift control
            % once there, perform exposure task
            % when exposure task is done, set working mode to normal
            % Is it possible to achieve this with one state?
            
            ceValues = cell(1, length(this.uiFemTool.dX) * length(this.uiFemTool.dY) + 1);
            
            % Use first state to set reticle field and pupil fill 
            
            u8Count = 1;
            
            %{
            stValue = struct();
            stValue.type = 'setup';
            stValue.reticleX = this.uiReticleTool.dX;
            stValue.reticleY = this.uiReticleTool.dY;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            %}
            
            % stValue.pupilFill = this.uiPupilFillTool.get();
            
            % Use other states for wafer pos and exposure task FEM
            % working mode to allow  x y move
            stValue = struct();
            stValue.workingMode = 5; % allow xy move
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;

            
            % Center the reticle fine stage in x and y
            
            stValue = struct();
            stValue.xReticleFine = 5;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
            stValue = struct();
            stValue.yReticleFine = 5;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
            %%  Index shot
            
            if ~this.uicbSkipIndex.get()
                mMid = ceil(length(this.uiFemTool.dDose)/2);
                nMid = ceil(length(this.uiFemTool.dFocus)/2);
                

                % x position on wafer you want the exposure to be
                stValue = struct();
                stValue.waferX = -this.uiFemTool.dX(1); 
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                
                % y position on wafer you want exposure to be
                if length(this.uiFemTool.dY) > 1
                    dYStep = this.uiFemTool.dY(2) - this.uiFemTool.dY(1);
                else
                    dYStep = .2;
                end
                stValue = struct();
                stValue.waferY = -(this.uiFemTool.dY(1) - dYStep); % STEP FIX ME; 
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;

            
            
                
                % Pause long time for motion of reticle fine xy from big move to index shot to
                % dissipate
                %{
                stValue = struct();
                stValue.pause = 10;
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                %}
                
                % DMI-based settle of motion of reticle fine xy from big move to index shot to
                % dissipate
                if this.uieTimeToSettle.get() > 0.1
                    stValue = struct();
                    stSettle = struct();
                    stSettle.value = this.uieVibration.get();
                    stSettle.time = this.uieTimeToSettle.get();
                    stValue.settle = stSettle;
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1;
                end
            
            %{
                % Val you want HS to read during exposure
                stValue = struct();
                stValue.waferZ = this.uiFemTool.dFocus(nMid);
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;

                % Start drift monitor tracking 
                stValue = struct();
                stValue.tracking = 'start';
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                
                % run exposure NEED TO USE SINGLE QUOTES IN RECIPE for struct2json
                stValue = struct();
                stValue.workingMode = 4; % drift closed loop for exposure
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;

                %}

                % 2021.10 update to start drift control immediately after WFZ
                stValue = struct();
                stValue.waferZThenDriftControl = this.uiFemTool.dFocus(nMid);
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                
                stValue = struct();
                stValue.workingMode = 4; % drift closed loop for exposure
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                
                % 2022.01 update to open the SMS slow shutter (glass plate)
                stValue = struct();
                stValue.smsSlowShutter = true;
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                

                % State
                stValue = struct();
                stValue.type = 'exposure';

                % Exposure task this info is used to color the exposures
                stTask = struct();
                stTask.dose = this.uiFemTool.dDose(mMid);
                stTask.femCols = length(this.uiFemTool.dDose);
                stTask.femCol = mMid;
                stTask.femRows = length(this.uiFemTool.dFocus);
                stTask.femRow = nMid;
                
                % Enough time for resonant motion of frame excited from stage move
                % to settle
                % stTask.pausePreExpose = 30; % FIX ME

                stValue.task = stTask;

                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                
                % 2022.01 update to close the SMS slow shutter (glass plate)
                stValue = struct();
                stValue.smsSlowShutter = false;
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                
                
                % wm_RUN
                stValue = struct();
                stValue.workingMode = 5; % drift closed loop for exposure
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                
                % Stop drift monitor tracking
                stValue = struct();
                stValue.tracking = 'stop';
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;

            end
            
            lVerticalSerp = false;
            
            
            
            if lVerticalSerp

                
                % FEM for each dose (m), do each focus (n)

                for m = 1 : length(this.uiFemTool.dDose) % cols

                    % x position on wafer you want the exposure to be
                    stValue = struct();
                    stValue.waferX = -this.uiFemTool.dX(m); 
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1; 

                    for n = 1 : length(this.uiFemTool.dFocus) % rows

                        % For even numbered columns, expose the row in reverse
                        % order so there are never large wafer z changes during
                        % the FEM and never any large wafer y changes during
                        % FEM

                        dY = -this.uiFemTool.dY;
                        dFocus = this.uiFemTool.dFocus;

                        if mod(m, 2) == 0
                            dY = flip(dY);
                            dFocus = flip(dFocus);
                        end


                        %{
                        % x position on wafer you want the exposure to be
                        stValue = struct();
                        stValue.waferX = -this.uiFemTool.dX(m); 
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        %}

                        % y position on wafer you want exposure to be
                        % 2019.04.12 Break into multiple moves of max .1 mm
                        % if not n = 1

                        % 2019-05-30 no breaking up
                        %{
                        if n > 1

                            dDeltaRemaining = dY(n) - dY(n - 1);
                            dAccumulated = 0;
                            dStepMax = 0.1;

                            while abs(dDeltaRemaining) > 1e-6 % 1 nm since units are mm

                                if abs(dDeltaRemaining) >= dStepMax
                                    dStep = sign(dDeltaRemaining) * dStepMax;
                                else
                                    dStep = dDeltaRemaining;
                                end

                                dAccumulated = dAccumulated + dStep;
                                dDeltaRemaining = dDeltaRemaining - dStep;

                                stValue = struct();
                                stValue.waferY = dY(n - 1) + dAccumulated; 
                                ceValues{u8Count} = stValue;
                                u8Count = u8Count + 1;

                                fprintf('bl12014.ui.PrescriptionTool in while loop for y moves.\n');
                                fprintf('bl12014.ui.PrescriptionTool dDeltaRemaining = %1.3f.\n', dDeltaRemaining);
                                fprintf('bl12014.ui.PrescriptionTool dAccumulated = %1.3f.\n', dAccumulated);
                            end
                        else
                            stValue = struct();
                            stValue.waferY = dY(n); 
                            ceValues{u8Count} = stValue;
                            u8Count = u8Count + 1;
                        end
                        %}

                        stValue = struct();
                        stValue.waferY = dY(n); 
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;

                        % Center the reticle fine stage in x and y

                        stValue = struct();
                        stValue.xReticleFine = 5;
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;

                        stValue = struct();
                        stValue.yReticleFine = 5;
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;


                        
                        % Pause for mechanical settling
                        %{
                        stValue = struct();
                        stValue.pause = this.uiFemTool.uiePause.get();
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        %}

                        % DMI-based settle of motion of reticle fine xy from big move to index shot to
                        % dissipate
                        if this.uieTimeToSettle.get() > 0.1
                            stValue = struct();
                            stSettle = struct();
                            stSettle.value = this.uieVibration.get();
                            stSettle.time = this.uieTimeToSettle.get();
                            stValue.settle = stSettle;
                            ceValues{u8Count} = stValue;
                            u8Count = u8Count + 1;
                        end

                        
                        % Val you want HS to read during exposure
                        %{
                        stValue = struct();
                        stValue.waferZ = dFocus(n);
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        
                        % Start drift monitor tracking
                        stValue = struct();
                        stValue.tracking = 'start';
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        
                        
                        
                        %}
                        
                        stValue = struct();
                        stValue.waferZThenDriftControl = dFocus(n);
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        
                        % Set it again so we can check to make sure it
                        % took!
                        % run exposure NEED TO USE SINGLE QUOTES IN RECIPE for struct2json
                        stValue = struct();
                        stValue.workingMode = 4; % Drift closed loop for exposure
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        
                        % 2022.01 update to open the SMS slow shutter (glass plate)
                        stValue = struct();
                        stValue.smsSlowShutter = true;
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        

                        % Exposure task 
                        stValue = struct();
                        stValue.type = 'exposure';

                        stTask = struct();
                        stTask.dose = this.uiFemTool.dDose(m);
                        stTask.femCols = length(this.uiFemTool.dDose);
                        stTask.femCol = m;
                        stTask.femRows = length(this.uiFemTool.dFocus);

                        if mod(m, 2) == 0
                            % even cols go backwards through rows
                            % n = row index
                            % m = col index
                            stTask.femRow = length(this.uiFemTool.dFocus) + 1 - n;
                        else
                            stTask.femRow = n;
                        end

                        % Enough time for resonant motion of frame excited from stage move
                        % to settle
                        % stTask.pausePreExpose = 5;

                        stValue.task = stTask;

                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        
                        % 2022.01 update to open the SMS slow shutter (glass plate)
                        stValue = struct();
                        stValue.smsSlowShutter = false;
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;


                        % wm_RUN
                        stValue = struct();
                        stValue.workingMode = 5;
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;

                        % Stop drift monitor tracking
                        stValue = struct();
                        stValue.tracking = 'stop';
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;

                    end
                end
                
            else
                
                % Horizontal Serp
                
                 % FEM for each focus (m), do each dose (n)
                 
                lSerpentine = false;

                for m = 1 : length(this.uiFemTool.dFocus) % rows

                    % y position on wafer you want the exposure to be
                    stValue = struct();
                    stValue.waferY = -this.uiFemTool.dY(m); 
                    ceValues{u8Count} = stValue;
                    u8Count = u8Count + 1; 

                    for n = 1 : length(this.uiFemTool.dDose) % cols

                        % For even numbered columns, expose the row in reverse
                        % order so there are never large wafer z changes during
                        % the FEM and never any large wafer y changes during
                        % FEM

                        dX = -this.uiFemTool.dX;
                        dDose = this.uiFemTool.dDose;

                        if lSerpentine && mod(m, 2) == 0 % even row, flip order of cols
                            dX = flip(dX);
                            dDose = flip(dDose);
                        end


                        stValue = struct();
                        stValue.waferX = dX(n); 
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;

                        % Center the reticle fine stage in x and y

                        stValue = struct();
                        stValue.xReticleFine = 5;
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;

                        stValue = struct();
                        stValue.yReticleFine = 5;
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;


                        % Pause for mechanical settling
                        %{
                        stValue = struct();
                        stValue.pause = this.uiFemTool.uiePause.get();
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        %}

                        % DMI-based settle of motion of reticle fine xy from big move to index shot to
                        % dissipate
                        if this.uieTimeToSettle.get() > 0.1
                            stValue = struct();
                            stSettle = struct();
                            stSettle.value = this.uieVibration.get();
                            stSettle.time = this.uieTimeToSettle.get();
                            stValue.settle = stSettle;
                            ceValues{u8Count} = stValue;
                            u8Count = u8Count + 1;
                        end

                       
                        % Val you want HS to read during exposure
                        %{
                        stValue = struct();
                        stValue.waferZ = this.uiFemTool.dFocus(m);
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        
                         % Start drift monitor tracking
                        stValue = struct();
                        stValue.tracking = 'start';
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        %}
                        
                        % 2021.10 update to start tracking immediately
                        % after WFZ
                        stValue = struct();
                        stValue.waferZThenDriftControl = this.uiFemTool.dFocus(m);
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        
                         % run exposure NEED TO USE SINGLE QUOTES IN RECIPE for struct2json
                        stValue = struct();
                        stValue.workingMode = 4; % Drift closed loop for exposure
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        
                        % 2022.01 update to open the SMS slow shutter (glass plate)
                        stValue = struct();
                        stValue.smsSlowShutter = true;
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                       

                        % Exposure task 
                        stValue = struct();
                        stValue.type = 'exposure';

                        stTask = struct();
                        stTask.dose = dDose(n); % cant use this since the flip each row. this.uiFemTool.dDose(n);
                        stTask.femCols = length(this.uiFemTool.dDose);
                        stTask.femRows = length(this.uiFemTool.dFocus);
                        
                        stTask.femRow = m;

                        if lSerpentine && mod(m, 2) == 0
                            % even rows go backwards through cols  cols go backwards through rows
                            % n = row index
                            % m = col index
                            stTask.femCol = length(this.uiFemTool.dDose) + 1 - n;
                        else
                            stTask.femCol = n;
                        end

                        % Enough time for resonant motion of frame excited from stage move
                        % to settle
                        % stTask.pausePreExpose = 5;

                        stValue.task = stTask;

                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;
                        
                        % 2022.01 update to open the SMS slow shutter (glass plate)
                        stValue = struct();
                        stValue.smsSlowShutter = false;
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;


                        % wm_RUN
                        stValue = struct();
                        stValue.workingMode = 5;
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;

                        % Stop drift monitor tracking
                        stValue = struct();
                        stValue.tracking = 'stop';
                        ceValues{u8Count} = stValue;
                        u8Count = u8Count + 1;

                    end
                end
               
                
            end
                                
            stUnit = struct();
            stUnit.waferX = 'mm';
            stUnit.waferY = 'mm';
            stUnit.waferZ = 'nm';
            stUnit.reticleX = 'mm';
            stUnit.reticleY = 'mm';
            stUnit.xReticleFine = 'um';
            stUnit.yReticleFine = 'um';
            stUnit.pupilFill = 'n/a';
            stUnit.workingMode = 'n/a';
            
            stRecipe = struct();
            stRecipe.process = this.uiProcessTool.savePublic();
            stRecipe.fem = this.uiFemTool().savePublic();
            stRecipe.unit = stUnit;
            stRecipe.values = ceValues;
            
            
        end
    end
    
    methods (Access = private)
        
        function onUiEditName(this, src, evt)
            
            
        end
        
         function onUiEditTimeToSettle(this, src, evt)
            
            
         end
         
         function onUiCbFadeY(this, src, evt)
             
             if this.uicbFadeY.get() && ~this.uicbUseFastMode.get()
                this.uieFadeY.show();
             else
                this.uieFadeY.hide();
             end
             
         end
         
         function onUiEditFadeY(this, src, evt)
         end
        
          function onUiEditVibration(this, src, evt)
            
            
        end
        
        function init(this)
             
            this.msg('init()');
            
            this.uieName = mic.ui.common.Edit(...
                'cType', 'c', ...
                'cLabel', 'Name', ...
                'fhDirectCallback', @this.onUiEditName ...
            );
        
            this.uieVibration = mic.ui.common.Edit(...
                'cType', 'd', ...
                'cLabel', 'Vib nm', ...
                'fhDirectCallback', @this.onUiEditVibration ...
            );
            this.uieVibration.set(1);
            
            this.uicbFadeY = mic.ui.common.Checkbox(...
                'cLabel', 'Fade Y', ...
                'fhDirectCallback', @this.onUiCbFadeY ...
            );
        
            this.uicbUseFastMode = mic.ui.common.Checkbox(...
                'cLabel', 'Fast Mode' ...
            );

            this.uicbSkipIndex = mic.ui.common.Checkbox(...
                'cLabel', 'Skip Index Shot' ...
            );
                        
            this.uieFadeY = mic.ui.common.Edit(...
                'cType', 'd', ...
                'cLabel', 'Fade Y nm', ...
                'fhDirectCallback', @this.onUiEditFadeY ...
            );
            this.uieFadeY.set(1.1);
            
        
            this.uieTimeToSettle = mic.ui.common.Edit(...
                'cType', 'd', ...
                'cLabel', 'Settle sec', ...
                'fhDirectCallback', @this.onUiEditVibration ...
            );
            this.uieTimeToSettle.set(120);
        
            this.uiProcessTool = bl12014.ui.ProcessTool();
            this.uiReticleTool = bl12014.ui.ReticleTool();
            this.uiPupilFillTool = bl12014.ui.PupilFillTool();
            this.uiFemTool = bl12014.ui.FemTool();
            
            this.uiButtonSave = mic.ui.common.Button(...
                'cText', 'Save As', ...
                'fhOnClick', @this.onClickSave ...
            );
        
            this.uiButtonOverwrite = mic.ui.common.Button(...
                'cText', 'Overwrite Selected', ...
                'fhOnClick', @this.onClickOverwrite ...
            );

            
            %{
            this.ec                 = ExptControl();
            addlistener(this.ec, 'ePreChange', @this.onPreChange);
            %}
            
            cDir = fullfile(this.cDirSrc, 'save', 'prescriptions');
            cDir = mic.Utils.path2canonical(cDir);

            this.uiListPrescriptions = mic.ui.common.ListDir(...
                'cTitle', 'Saved', ...
                'cDir', cDir, ...
                'cLabel', '', ...
                'cFilter', '*.json', ...
                'fhOnChange', @this.onPrescriptionsChange, ...
                'lOrderByReverse', false, ...
                'lShowDelete', true, ...
                'lShowMove', false, ...
                'lShowLabel', false, ...
                'lShowRefresh', true ...
            );
        
            % Load first prescription from the list
            this.onPrescriptionsChange(this.uiListPrescriptions, []);

            % this.uiListPrescriptions.setRefreshFcn(@this.refreshSaved);
            
            
            % addlistener(this.uiListPrescriptions, 'eDelete', @this.onPrescriptionsDelete);
           
        end  
        
        %{
        function ceReturn = refreshSaved(this)
            ceReturn = mic.Utils.dir2cell(...
                this.uiListPrescriptions.getDir(), ...
                'date', ...
                'descend', ...
                '*.json' ...
            );
        end
        %}
        
        
        
        
        
        function c = getSuggestedName(this)
           
            % Generate a suggestion for the filename
            % [yyyy-mm-dd]-[num]-[Resist]-[Reticle]-[Field]-[Illum
            % abbrev.]-[FEM rows x FEM cols]
            
           
            cResist = this.uiProcessTool.uieResistName.get();
            if (length(cResist) > 10)
                cResist = cResist(1:10);
            end
            %{
            
            cIllum = this.uiPupilFillTool.get();
            if (length(cIllum) > 10)
                cIllum = cIllum(1:10);
            end
            %}
            
            cIllum = 'fix me'
            
           
            c = sprintf('%s__RES_%s__FEM_D%1dxF%1d__%s', ...
                datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local'), ...
                cResist, ...
                ...this.uiReticleTool.uipReticle.get(), ...
                ...this.uiReticleTool.uipField.get(), ...
                ...cIllum, ...
                length(this.uiFemTool.dDose), ...
                length(this.uiFemTool.dFocus), ...
                this.uiProcessTool.uieUser.get() ...
            );
            
        end
        
        function onClickOverwrite(this, src, evt)
            
            ceSelected = this.uiListPrescriptions.get();
            
            if isempty(ceSelected)
                % Show alert
                
                cMsg = sprintf('Please select a prescription to overwrite');
                cTitle = 'No prescription selected to overwrite';
                msgbox(cMsg, cTitle, 'warn')    
                
                return
            end
            
            [cPath, cFile, cExt] = fileparts(ceSelected{1});
            cNameJson = [cFile, '.json'];
            cNameMat = [cFile, '.mat'];
            
            cPathJson = fullfile(this.uiListPrescriptions.getDir(), cNameJson);
            cPathMat = fullfile(this.uiListPrescriptions.getDir(), cNameMat);
            
            this.saveRecipeToDisk(cPathJson)
            this.saveRecipeMatToDisk(cPathMat)
            
            % Refresh the list of prescriptions
            this.uiListPrescriptions.refresh();
            
            % Dispatch
            stData = struct();
            stData.cName = cNameJson;
            notify(this, 'eNew', mic.EventWithData(stData));
            
            if isempty(ceSelected)
                % Show alert
                
                cMsg = sprintf('Overwrite completed.');
                cTitle = 'Success';
                cIcon = 'none';
                msgbox(cMsg, cTitle, cIcon)    
                
                return
            end
            
            
            
        end
        
        function [cName, lSuccess] = getNameFromUser(this)
            
            % Suggested filename
            cName = this.getSuggestedName();
            
            % Allow the user to change the suggested filename
            
            cPrompt = { 'Prescription Name' };
            cTitle = 'Input';
            u8Lines = [1 150];
            cDefaultAns = { cName };
            ceAnswer = inputdlg(...
                cPrompt, ...
                cTitle, ...
                u8Lines, ...
                cDefaultAns ...
            );
        
            if isempty(ceAnswer)
                lSuccess = false;
            else 
                lSuccess = true;
                cName = ceAnswer{1};
            end
            
            
            
        end
        
        
        % Generate a suggested save name for the prescription.  Prompt the 
        % user with a dialog to allow them to modify the save name.  If
        % the user continues to save, build and save a JSON prescription
        
        function onClickSave(this, src, evt)
              
            
            
            % Use cDirSave as suggested path
            if ~exist(this.uiListPrescriptions.getDir(), 'dir')
                mkdir(this.uiListPrescriptions.getDir())
            end

            cFastStr = '';
            if this.uicbUseFastMode.get()
                cFastStr = '_FC';
            end
            if this.uicbSkipIndex.get()
                cFastStr = [cFastStr '_noIndex']
            end
            
            cName = [...
                this.uieName.get(), ...
                sprintf('__FEM_D%1dxF%1d', length(this.uiFemTool.dDose), length(this.uiFemTool.dFocus)), ...
                cFastStr, ...
                sprintf('__%s', datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local')) ...
            ];
                               
            %{
            [cName, lSuccess] = this.getNameFromUser();
            if ~lSuccess
                return
            end
            %}
            
            cNameJson = [cName, '.json'];
            cNameMat = [cName, '.mat'];  
            
            cPathJson = fullfile(this.uiListPrescriptions.getDir(), cNameJson);
            cPathMat = fullfile(this.uiListPrescriptions.getDir(), cNameMat);
            
            this.saveRecipeToDisk(cPathJson)
            this.saveRecipeMatToDisk(cPathMat)
            
            % Refresh the list of prescriptions
            this.uiListPrescriptions.refresh();
            this.uiListPrescriptions.setSelectedIndexes(uint8(1)); % select the newly added pre.
            
            %{
            % If the name is not already on the list, append it
            if isempty(strmatch(cPath, this.uiListPrescriptions.getOptions(), 'exact'))
                this.uiListPrescriptions.prepend(cUserFile);
            end
            %}
            
            % Dispatch
            stData = struct();
            stData.cName = cNameJson;
            notify(this, 'eNew', mic.EventWithData(stData)); 
            
        end
        
        function saveRecipeMatToDisk(this, cPath)
            st = this.save();
            save(cPath, 'st');
        end
        
        % Load the saved .mat state of the recipe into the UI
        function loadRecipeMatFromDisk(this, cPath)
            if exist(cPath, 'file') == 2
                load(cPath); % populates variable st in local workspace
                this.load(st);
            else

                % warning message box

                h = msgbox( ...
                    'This file cannot be found.  Click OK below to continue.', ...
                    'File does not exist', ...
                    'warn', ...
                    'modal' ...
                    );

                % wait for them to close the message
                uiwait(h);

            end
            
        end
        
        function saveRecipeToDisk(this, cPath)
                        
            % Config for savejson function
            stOptions = struct();
            stOptions.FileName = cPath;
            stOptions.Compact = 0; 
            
            stRecipe = this.getRecipe();
            
            % !! IMPORTANT !!
            % savejson() cannot accept structures that contain double
            % quotes.  Use single quotes for strings in the recipe
            savejson('', stRecipe, stOptions); 
               
        end
        
        
               
        
        function onPrescriptionsChange(this, src, evt)
            
            this.msg('onPrescriptionsChange()');
            
            
            ceSelected = this.uiListPrescriptions.get();
            if ~isempty(ceSelected)
                                
                % Load the .mat file (assume that cName is the filename in the
                % prescriptions directory

                cPath = this.replaceExtension(fullfile(this.uiListPrescriptions.getDir(), ceSelected{1}), '.mat');
                this.loadRecipeMatFromDisk(cPath);
            end
            
        end
        
        % Replace the extension of a file or path with a new one
        % @param {char 1xm} file or path including extension
        % @param {char 1xm} new extension including the '.', e.g., '.json',
        % '.mat'
        function c = replaceExtension(this, cPath, cExt)
            [cPathTemp, cFileTemp, cExtTemp] = fileparts(cPath);
            c = fullfile(cPathTemp, [cFileTemp, cExt]);
        end
        
        
        
        
        
        
        
        
        
                

    end 
    
    
end