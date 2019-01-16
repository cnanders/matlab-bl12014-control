classdef Scanner < mic.Base
    
    properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommNPointLC400
        
        % {npoint.ui.LC400 1x1}
        uiNPointLC400
        
        % {https://github.com/cnanders/matlab-pupil-fill-generator}
        uiPupilFillGenerator
        
        % { mic.ui.device.GetSetText 1x1} use this to set
        % PupilFillGenerator to a specific waveform by name, which triggers
        % it update its internal store of the dX, dY waveforms
        uiGetSetWaveform
        
    end
    
    properties (Access = protected)
        
        % {mic.Clock 1x1} must be provided
        clock
        dWidth = 1250
        dHeight = 790
        hFigure
        
        dWidthName = 70
        dWidthPadName = 29
        dScale = 1 % scale factor to hardware
        
        % {char 1xm} directories to initialize the PupilFillGenerator to
        cDirWaveforms
        cDirWaveformsStarred
        % {logical 1x1} show the "choose dir" button on both lists of saved
        % pupilfills
        lShowChooseDir = false
        
    end
    
    properties (SetAccess = protected)
        
        cName = 'Test Scanner'
    end
    
    methods
        
        function this = Scanner(varargin)
            
            [cDir, cName, cExt] = fileparts(mfilename('fullpath'));
                   
            this.cDirWaveforms = mic.Utils.path2canonical(fullfile(...
                cDir, ...
                '..', ...
                '..', ...
                'save', ...
                'scanner' ...
            ));
        
            this.cDirWaveformsStarred = fullfile(...
                this.cDirWaveforms, ...
                'starred' ...
            );
            
        
        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
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
        
        function connectNPointLC400(this, comm)
            this.uiNPointLC400.setDevice(comm);
            this.uiNPointLC400.turnOn();
        end
        
        function disconnectNPointLC400(this)
            this.uiNPointLC400.turnOff();
            this.uiNPointLC400.setDevice([]);
            
        end
        
        
        
        function build(this, hParent, dLeft, dTop)
            
            dSep = 10;
           
            this.uiCommNPointLC400.build(hParent, dLeft, dTop);
            dTop = dTop + 24 + dSep;
            
            this.uiPupilFillGenerator.build(hParent, dLeft, dTop);
            dTop = dTop + this.uiPupilFillGenerator.dHeight + 10;
            % dLeft = dLeft + this.uiPupilFillGenerator.dWidth + dSep;
                         
            this.uiNPointLC400.build(hParent, dLeft, dTop);
            % dTop = dTop + 300;
            
            % this.uiGetSetWaveform.build(hParent, dLeft + 650, dTop);
            
        end
        
        function delete(this)
            
            this.msg('delete', this.u8_MSG_TYPE_CLASS_INIT_DELETE);
                        
            % Delete the figure
            delete(this.uiNPointLC400)
            delete(this.uiPupilFillGenerator);
            
            
        end  
        
        
        function st = save(this)
            st = struct();
            st.uiPupilFillGenerator = this.uiPupilFillGenerator.save();
            
        end
        
        function load(this, st)
            if isfield(st, 'uiPupilFillGenerator') 
                this.uiPupilFillGenerator.load(st.uiPupilFillGenerator);
            end
        end
        
    end
    
    methods (Access = protected)
        
        
        
         
        function initUiPupilFillGenerator(this)
            this.uiPupilFillGenerator = PupilFillGenerator(...
                'lShowChooseDir', this.lShowChooseDir, ...
                'cDirWaveforms', this.cDirWaveforms, ...
                'cDirWaveformsStarred', this.cDirWaveformsStarred ...
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
                'uiClock', this.clock, ...
                'fhGet20BitWaveforms', @this.get20BitWaveforms, ...
                'fhGetPathOfRecipe', @() this.uiPupilFillGenerator.getPathOfRecipe(), ...
                'cName', sprintf('%s-LC-400-UI', this.cName) ...
            );
            
        end
        
        
        function initUiCommNPointLC400(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommNPointLC400 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-nPoint-LC400', this.cName), ...
                'cLabel', 'nPoint LC400' ...
            );
        
        end
        
        function init(this)
            this.msg('init');
            this.initUiCommNPointLC400();
            this.initUiPupilFillGenerator();
            this.initUiNPointLC400();
            
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-text', ...
                'pupil-fill.json' ...
            );
        
            config = mic.config.GetSetText(...
                'cPath',  cPathConfig ...
            );
            
                
        %{
            this.uiGetSetWaveform = mic.ui.device.GetSetText( ...
                'cName', [this.cName, 'ui-waveform'], ...
                'cLabel', 'Test', ...
                'lShowUnit', false, ...
                'clock', this.clock, ...
                'config', config, ...
                'lUseFunctionCallbacks', true, ...
                'fhGet', @() this.uiPupilFillGenerator.isDone(), ...
                'fhSet', @(cVal) Utils.this.uiPupilFillGenerator.setStarredByName(cVal), ...
                'fhIsVirtual', @() false ...
            );
            %}
        
        end
        
        
        
    end
    
    
end

