classdef DCTPrescriptions < mic.Base
    
    properties (Constant)
       
        dWidth          = 575
        dHeight         = 560
        dColorFigure = [200 200 200]./255
                
    end
    
	properties
        
                 
                
    end
    
    properties (SetAccess = private)
        
        uiListPrescriptions
        uieName
        uiExposureMatrix         
    
    end
    
    properties (Access = private)
          
        hParent
        hPanel
        hPanelSaved
        cDirThis
        cDirSrc
        
        uiButtonSave         % button for saving
        uiButtonOverwrite
                
        dWidthBorderPanel = 0
        
        fhOnChange = @(stData) []
    
    end
    
        
    events
        
        eDelete
        eSizeChange
        eNew
        
    end
    
    methods
        
        function this = DCTPrescriptions(varargin)
            
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
        
        function cec = getPropsSaved(this)
            cec = {...
                'uieName', ...
                'uiExposureMatrix', ... 
             };
        end
        
        
        function st = save(this)
            cecProps = this.getPropsSaved();
            
            st = struct();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                if this.hasProp( cProp)
                    st.(cProp) = this.(cProp).save();
                end
            end

             
        end
        
        function load(this, st)
                        
            cecProps = this.getPropsSaved();
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
            dLeft = 20;
            dTop = 15;
            
            
            dWidth = 270;
            dHeight = 24;
            
            this.uieName.build(...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                dHeight ...
           );
       
            dLeft = 10;
            dTop = dTop + dHeight + 12; % 12 for labels
            dTop = dTop + 10;
            
            this.uiExposureMatrix.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop);

            dTop = dTop + this.uiExposureMatrix.dHeight;
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
        
        function stRecipe = getRecipe(this)
            
            ceValues = {};
            u8Count = 1;
                    
            % Reference shot
            stValue = struct();
            stValue.xWafer = this.uiExposureMatrix.dX(1);
            stValue.yWafer = this.uiExposureMatrix.dY(1) - this.uiExposureMatrix.getStepY() * 1e-3;
            
            stTask = struct();
            stTask.dose = this.uiExposureMatrix.dDose(end);
            stTask.doseMin = this.uiExposureMatrix.dDose(1);
            stTask.doseMax = this.uiExposureMatrix.dDose(end);
            stValue.task = stTask;
            
            ceValues{u8Count} = stValue;
            u8Count = u8Count + 1;
            
            for m = 1 : length(this.uiExposureMatrix.dDose)
                
                stValue = struct();
                stValue.xWafer = this.uiExposureMatrix.dX(m);
                stValue.yWafer = this.uiExposureMatrix.dY(m);
                
                stTask = struct();
                stTask.dose = this.uiExposureMatrix.dDose(m);
                stTask.doseMin = this.uiExposureMatrix.dDose(1);
                stTask.doseMax = this.uiExposureMatrix.dDose(end);
            
                stValue.task = stTask;
                
                ceValues{u8Count} = stValue;
                u8Count = u8Count + 1;
                
            end
                
                                
            stUnit = struct();
            stUnit.xWafer = 'mm';
            stUnit.yWafer = 'mm';
            
            stRecipe = struct();
            stRecipe.matrix = this.uiExposureMatrix().savePublic();
            stRecipe.unit = stUnit;
            stRecipe.values = ceValues;
            
            
        end
                    

    end
    
    methods (Access = private)
        
        function onUiEditName(this, src, evt)
            
            
        end
        
         
        
        function init(this)
             
            this.msg('init()');
            
            this.uieName = mic.ui.common.Edit(...
                'cType', 'c', ...
                'cLabel', 'Name', ...
                'fhDirectCallback', @this.onUiEditName ...
            );
        
            
            this.uiExposureMatrix = bl12014.ui.ExposureMatrixA(...
                'fhOnChange', @(stData) this.fhOnChange(stData) ...
            );
            
            this.uiButtonSave = mic.ui.common.Button(...
                'cText', 'Save As', ...
                'fhOnClick', @this.onClickSave ...
            );
        
            this.uiButtonOverwrite = mic.ui.common.Button(...
                'cText', 'Overwrite Selected', ...
                'fhOnClick', @this.onClickOverwrite ...
            );
            
            cDir = fullfile(this.cDirSrc, 'save', 'dct-prescriptions');
            cDir = mic.Utils.path2canonical(cDir);

            this.uiListPrescriptions = mic.ui.common.ListDir(...
                'cTitle', 'Saved', ...
                'cDir', cDir, ...
                'cLabel', '', ...
                'cFilter', '*.mat', ... '*.json', ...
                'fhOnChange', @this.onPrescriptionsChange, ...
                'lOrderByReverse', false, ...
                'lShowDelete', true, ...
                'lShowMove', false, ...
                'lShowLabel', false, ...
                'lShowRefresh', true ...
            );
        
            this.onPrescriptionsChange(this.uiListPrescriptions, []);
 
           
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
        
        
        % Build and save a JSON prescription
        
        function onClickSave(this, src, evt)
                          
            % Use cDirSave as suggested path
            if ~exist(this.uiListPrescriptions.getDir(), 'dir')
                mkdir(this.uiListPrescriptions.getDir())
            end
            
            cName = [...
                this.uieName.get(), ...
                ... sprintf('__FEM_D%1dxF%1d', length(this.uiExposureMatrix.dDose), length(this.uiExposureMatrix.dFocus)), ...
                sprintf('__%s', datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local')) ...
            ];
                               
            cNameJson = [cName, '.json'];
            cNameMat = [cName, '.mat'];  
            
            cPathJson = fullfile(this.uiListPrescriptions.getDir(), cNameJson);
            cPathMat = fullfile(this.uiListPrescriptions.getDir(), cNameMat);
            
            this.saveRecipeToDisk(cPathJson)
            this.saveRecipeMatToDisk(cPathMat)
            
            % Refresh the list of prescriptions
            this.uiListPrescriptions.refresh();
            this.uiListPrescriptions.setSelectedIndexes(uint8(1)); % select the newly added pre.

            % Dispatch
            stData = struct();
            stData.cName = cNameJson;
            notify(this, 'eNew', mic.EventWithData(stData)); 
            
        end
        
        function saveRecipeMatToDisk(this, cPath)
            st = this.save();
            st.stRecipe = this.getRecipe();
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

                % cPath = this.replaceExtension(fullfile(this.uiListPrescriptions.getDir(), ceSelected{1}), '.mat');
                cPath = fullfile(this.uiListPrescriptions.getDir(), ceSelected{1});
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