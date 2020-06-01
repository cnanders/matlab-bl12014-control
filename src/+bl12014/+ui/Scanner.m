classdef Scanner < mic.Base
    
    properties (Constant)
        
        
    end
    properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
                
        % {npoint.ui.LC400 1x1}
        uiNPointLC400
        
        
        % {https://github.com/cnanders/matlab-pupil-fill-generator}
        uiPupilFillGenerator
        
        
    end
    
    properties (Access = protected)
        
        % {mic.Clock 1x1} must be provided
        clock
        % {mic.ui.Clock 1x1}
        uiClock
        
        
        dWidth = 1250
        dHeight = 790
        hFigure
        
        dWidthName = 70
        dWidthPadName = 29
        dScale = 1 % scale factor to hardware
        
        % {char 1xm} directory for saving
        cDirSave
        
        % {logical 1x1} show the "choose dir" button on both lists of saved
        % pupilfills
        lShowChooseDir = false
        
        fhGetNPoint
         
        
    end
    
    properties (SetAccess = protected)
        
        cName = 'Test Scanner'
    end
    
    methods
        
        function this = Scanner(varargin)
            
            [cDir, cName, cExt] = fileparts(mfilename('fullpath'));
            
            this.cDirSave = mic.Utils.path2canonical(fullfile(...
                cDir, ...
                '..', ...
                '..', ...
                'save', ...
                'scanner' ...
            ));
            
            
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
 
                       
            this.init();
        
        end
        
        
            
        
        function c = getDirWaveforms(this)
            c = this.cDirSave;
        end
        
        function c = getDirWaveformsStarred(this)
            c = fullfile(...
                this.cDirSave, ...
                'starred' ...
            );
        end
        
        function c = getDirUI(this)
            c = fullfile(...
                this.cDirSave, ...
                'npoint-ui' ...
            );
        end
        
        % Sets the pupil fill with name {cName} in the directory of the 
        % starred list
        function setStarredIlluminationByName(this, cName)
            
            this.uiPupilFillGenerator.selectStarredByName(cName);
            
            this.uiPupilFillGenerator.isDone()
            % Tell the npoint UI to set illumination to the selected
            % illumination
            this.uiNPointLC400.setIlluminationFromGetter();
            
        end
        
        
        
        
        
        function d = processImageFrame(this, dData)
            d = rot90(dData);
            d = rot90(d);
        end
        
       
        
        function build(this, hParent, dLeft, dTop)
            
            dSep = 10;
           
            this.uiPupilFillGenerator.build(hParent, dLeft, dTop);
            dTop = dTop + this.uiPupilFillGenerator.dHeight + 10;
            % dLeft = dLeft + this.uiPupilFillGenerator.dWidth + dSep;
                         
            this.uiNPointLC400.build(hParent, dLeft, dTop);
            % dTop = dTop + 300;
                        
            
        end
        
        function delete(this)
            
            this.msg('delete', this.u8_MSG_TYPE_CLASS_DELETE);
                        
            % Delete the figure
            this.uiNPointLC400.delete();
            this.uiPupilFillGenerator.delete();
            
        end 
        
        
        function cec = getSaveLoadProps(this)
            cec = {...
                'uiPupilFillGenerator', ...
                'uiNPointLC400', ...
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
        
        
        
    end
    
    methods (Access = protected)
        
        
        
         
        function initUiPupilFillGenerator(this)
            this.uiPupilFillGenerator = PupilFillGenerator(...
                'lShowChooseDir', this.lShowChooseDir, ...
                'cDirWaveforms', this.getDirWaveforms(), ...
                'cDirWaveformsStarred', this.getDirWaveformsStarred() ...
            );
        end
        
        function [i32X, i32Y] = get20BitWaveforms(this)
            
            % returns structure with fields containing 
            % normalized amplitude in [-1 1] as double
            st = this.uiPupilFillGenerator.get(); 
            
            dAmpX = st.x * this.dScale;
            dAmpY = st.y * this.dScale;
            
            % {int32 1xm} in [-2^19 2^19] (20-bit)
            i32X = int32( 2^19 * dAmpX);
            i32Y = int32( 2^19 * dAmpY);
            
        end
        
        function initUiNPointLC400(this)
            
            this.uiNPointLC400 =  npoint.ui.LC400(...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                ...'fhOnChangeOffsetX', @this.onChangeNPointOffset, ...
                ...'fhOnChangeOffsetY', @this.onChangeNPointOffset, ...
                'fhGetNPoint', this.fhGetNPoint, ...
                'fhGet20BitWaveforms', @this.get20BitWaveforms, ...
                'fhGetPathOfRecipe', @() this.uiPupilFillGenerator.getPathOfRecipe(), ...
                'cName', sprintf('%s-LC-400-UI', this.cName) ...
            );
        
            % this.loadStateOfUiNPointFromDisk();
            
        end
        
        %{
        function c = getPathOfSavedState(this)
            mic.Utils.checkDir(this.getDirUI());
            c = fullfile(...
                this.getDirUI(), ...
                ['saved-state-of-ui', '.mat']...
            );
            c = mic.Utils.path2canonical(c);
        end
        
       
        % Only loads the state of the 
        function loadStateOfUiNPointFromDisk(this)
            if exist(this.getPathOfSavedState(), 'file') == 2
                fprintf('ui.Scanner loadStateOfUiNPointFromDisk() file: %s\n', this.getPathOfSavedState());
                load(this.getPathOfSavedState()); % populates variable st in local workspace
                this.uiNPointLC400.load(st);
            end
        end
        
        
        function saveStateOfUiNPointToDisk(this)
            st = this.uiNPointLC400.save();
            fprintf('ui.Scanner saveStateOfUiNPointToDisk() file: %s\n', this.getPathOfSavedState());
            save(this.getPathOfSavedState(), 'st');
        end
        
        
        function onChangeNPointOffset(this, src, evt)
            this.saveStateOfUiNPointToDisk();
        end
        %}
        
        function init(this)
            this.msg('init');
            this.initUiPupilFillGenerator();
            this.initUiNPointLC400();
            
        end
          
        
    end
    
    
end

