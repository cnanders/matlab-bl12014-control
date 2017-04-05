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
       
        dWidth          = 1250
        dHeight         = 720
        
    end
    
	properties
        
        uiProcessTool              
        uiReticleTool                
        uiPupilFillTool            
        uiFemTool                  
                
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
          
        hFigure
        hPanel
        hPanelSaved
        cDirThis
        cDirSrc
        cDirSave
        uilPrescriptions
        uibSave         % button for saving
        
        % For undo/redo
        % Use implementation from Redux since it is standard
        % http://redux.js.org/docs/recipes/ImplementingUndoHistory.html
        
        % {cell of struct}
        cestStatesPast
        % {struct}
        stStatePresent
        % {cell of struct}
        cestStatesFuture 
    
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
            this.cDirSave = fullfile(this.cDirSrc, 'save', 'prescriptions');
        
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end 
            
            
            this.init();
            
        end
        
        
        % @return {struct} UI state to save
        function st = save(this)
            st = struct();
            st.uiProcessTool = this.uiProcessTool.save();
            st.uiFemTool = this.uiFemTool.save();
            st.uiPupilFillTool = this.uiPupilFillTool.save();
            st.uiReticleTool = this.uiReticleTool.save();
            
        end
        
        % @param {struct} UI state to load
        function load(this, st)
            this.uiProcessTool.load(st.uiProcessTool);
            this.uiFemTool.load(st.uiFemTool);
            this.uiPupilFillTool.load(st.uiPupilFillTool);
            this.uiReticleTool.load(st.uiReticleTool);
        end
        
        
        function build(this)
              
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            dScreenSize = get(0, 'ScreenSize');
            
            dPad = 10;
            dTop = 10;
            
            % Figure
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name',  'Prescription Builder',...
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
            
                        
            % set(this.hFigure, 'renderer', 'OpenGL'); % Enables proper stacking
             
            
            this.uiProcessTool.build( ...
                this.hFigure, ...
                dPad, ...
                dTop);
            this.uiReticleTool.build(...
                this.hFigure, ...
                dPad + this.uiProcessTool.dWidth + dPad, ...
                dTop);
            this.uiPupilFillTool.build( ...
                this.hFigure, ...
                dPad + this.uiProcessTool.dWidth + dPad, ...
                dTop + this.uiReticleTool.dHeight + dPad);
            this.uiFemTool.build( ...
                this.hFigure, ...
                dPad + this.uiProcessTool.dWidth + dPad + this.uiReticleTool.dWidth + dPad, ...
                dTop);
            this.uibSave.build( ...
                this.hFigure, ...
                dPad + this.uiProcessTool.dWidth + dPad + this.uiReticleTool.dWidth + dPad, ...
                dTop + this.uiFemTool.dHeight + dPad, ...
                this.uiFemTool.dWidth, ...
                55);
            
            this.hPanelSaved = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Saved Prescriptions',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                    dPad ...
                    dTop + this.uiProcessTool.dHeight + 2*dPad ...
                    this.dWidth - 2*dPad ...
                    280], this.hFigure) ...
            );
            drawnow; 
            
            this.uilPrescriptions.build( ...
                this.hPanelSaved, ...
                dPad, ...
                20, ...
                this.dWidth - 4*dPad, ...
                225);
            
            this.uilPrescriptions.refresh();
            
                                  
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
            
            % Delete the figure
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
                        
        end
        
        
        function loadPre(cName)
            
            
 
        end
        
        function ceReturn = refreshSaved(this)
            ceReturn = mic.Utils.dir2cell(this.cDirSave, 'date', 'descend', '*.json');
        end
        
        function stRecipe = getRecipe(this)
            
            ceValues = cell(1, length(this.uiFemTool.dX) * length(this.uiFemTool.dY) + 1);
            
            % Use first state to set reticle and pupil fill 
            
            stValue = struct();
            stValue.reticleX = this.uiReticleTool.dX;
            stValue.reticleY = this.uiReticleTool.dY;
            stValue.pupilFill = this.uiPupilFillTool.get();
            
            % Use other states for wafer pos and exposure task FEM
            
            u8Count = 1;
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
            for m = 1 : length(this.uiFemTool.dDose)
                for n = 1 : length(this.uiFemTool.dFocus)

                    % State
                    stValue = struct();
                    stValue.waferX = -this.uiFemTool.dX(m);
                    stValue.waferY = -this.uiFemTool.dY(n);
                    stValue.waferZ = this.uiFemTool.dFocus(n);
                    
                    % Exposure task
                    stTask = struct();
                    stTask.dose = this.uiFemTool.dDose(m);
                    stTask.femCols = length(this.uiFemTool.dDose);
                    stTask.femCol = m;
                    stTask.femRows = length(this.uiFemTool.dFocus);
                    stTask.femRow = n;
                    stTask.pausePreExpose = 1; % FIX ME
                    
                    stValue.task = stTask;
                    
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
            stUnit.pupilFill = 'n/a';
            
            stRecipe = struct();
            stRecipe.process = this.uiProcessTool.save();
            stRecipe.fem = this.uiFemTool().save();
            stRecipe.unit = stUnit;
            stRecipe.values = ceValues;
            
            
        end
                    

    end
    
    methods (Access = private)
        
        function init(this)
             
            this.msg('init()');
            this.uiProcessTool = bl12014.ui.ProcessTool();
            this.uiReticleTool = bl12014.ui.ReticleTool();
            this.uiPupilFillTool = bl12014.ui.PupilFillTool();
            this.uiFemTool = bl12014.ui.FemTool();
            
            this.uibSave = mic.ui.common.Button('cText', 'Save');
            addlistener(this.uibSave, 'eChange', @this.onSave);
            
            %{
            this.ec                 = ExptControl();
            addlistener(this.ec, 'ePreChange', @this.onPreChange);
            %}
           
            this.uilPrescriptions = mic.ui.common.List(...
                'ceOptions', cell(1,0), ...
                'cLabel', '', ...
                'lShowDelete', true, ...
                'lShowMove', true, ...
                'lShowLabel', false, ...
                'lShowRefresh', true ...
            );
            this.uilPrescriptions.setRefreshFcn(@this.refreshSaved);
            
            addlistener(this.uilPrescriptions, 'eDelete', @this.onPrescriptionsDelete);
            addlistener(this.uilPrescriptions, 'eChange', @this.onPrescriptionsChange);
            
            
           
        end        
        
        
        function onCloseRequestFcn(this, src, evt)
            delete(this.hFigure);
            this.hFigure = [];
            % this.saveState();
        end
        
        
        function c = getSuggestedName(this)
           
            % Generate a suggestion for the filename
            % [yyyy-mm-dd]-[num]-[Resist]-[Reticle]-[Field]-[Illum
            % abbrev.]-[FEM rows x FEM cols]
            
           
            cResist = this.uiProcessTool.uieResistName.get();
            if (length(cResist) > 10)
                cResist = cResist(1:10);
            end
            
            cIllum = this.uiPupilFillTool.get();
            if (length(cIllum) > 10)
                cIllum = cIllum(1:10);
            end
            
           
            c = sprintf('%s__RES_%s__RET_%s_%s__ILLUM_%s__FEM_%1dx%1d', ...
                datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local'), ...
                cResist, ...
                this.uiReticleTool.uipReticle.get(), ...
                this.uiReticleTool.uipField.get(), ...
                cIllum, ...
                length(this.uiFemTool.dDose), ...
                length(this.uiFemTool.dFocus) ...
            );
            
        end
        
        % Generate a suggested save name for the prescription.  Prompt the 
        % user with a dialog to allow them to modify the save name.  If
        % the user continues to save, build and save a JSON prescription
        
        function onSave(this, src, evt)
              
            % Suggested filename
            cName = this.getSuggestedName();
            
            % Use cDirSave as suggested path
            if ~exist(this.cDirSave, 'dir')
                mkdir(this.cDirSave)
            end
                                
            cPath = fullfile(this.cDirSave, cName);
            
            % Allow the user to overwrite the filename and path
            [   cUserFile, ...
                cUserPath, ...
                cFilterIndex] = uiputfile('*.json', 'Save As:', cPath);
            
            % uiputfile returns 0 when the user hits cancel
            
            if cUserFile == 0
                return
            end
            
            cPathJson = fullfile(cUserPath, cUserFile);
            cPathMat = this.replaceExtension(cPathJson, '.mat');
            
            this.saveRecipeToDisk(cPathJson)
            this.saveToDisk(cPathMat)
            
            % If the name is not already on the list, append it
            if isempty(strmatch(cPath, this.uilPrescriptions.getOptions(), 'exact'))
                this.uilPrescriptions.prepend(cUserFile);
            end
            
            
            % Dispatch
            stData = struct();
            stData.cName = cUserFile;
            notify(this, 'eNew', mic.EventWithData(stData)); 
            
            
        end
        
        function saveToDisk(this, cPath)
            st = this.save();
            save(cPath, 'st');
        end
        
        function loadFromDisk(this, cPath)
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
        
        function onPrescriptionsDelete(this, src, evt)
        
            % In this case, evt is an instance of EventWithData (custom
            % class that extends event.EventData) that has a property
            % stData (a structure).  The structure has one property called
            % options which is a cell array of the items on the list that
            % were just deleted.
            % 
            % Need to loop through them and delete them from the directory.
            % The actual filenames are appended with .mat
                        
            for k = 1:length(evt.stData.ceOptions)
                
                cFile = fullfile(this.cDirSave, evt.stData.ceOptions{k});
                            
                if exist(cFile, 'file') ~= 0
                    % File exists, delete it
                    delete(cFile);
                else
                    this.msg(sprintf('Cannot find file: %s; not deleting.', cFile));
                end
                
            end
            
            notify(this, 'eDelete')
            
        end
               
        
        function onPrescriptionsChange(this, src, evt)
            
            this.msg('onPrescriptionsChange()');
            
            
            ceSelected = this.uilPrescriptions.get();
            if ~isempty(ceSelected)
                                
                % Load the .mat file (assume that cName is the filename in the
                % prescriptions directory

                cPath = this.replaceExtension(fullfile(this.cDirSave, ceSelected{1}), '.mat');
                this.loadFromDisk(cPath);
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