classdef DCT < mic.Base
        
    properties (Constant)
        
        
        dWidthTabGroup = 1060
        dHeightTabGroup = 750
               
    end
    
	properties
        
        cName = 'ui.DCT'
        
        exposures
        
        uiAxes
        uiFluxDensity
        uiStages
        uiExposureControl
        
        % Pass in
        uiBeamline
        uiScannerM142
        
        % Eventually make private.
        % Exposing for troubleshooting
        clock
        
        % { mic.ui.Clock 1x1}
        uiClockStages
        uiClockFluxDensity
        uiClockExposureControl

    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        
        cecTabs = {...
            'Stages', ...
            'Flux Density', ...
            'Exposure Control' ...
        };
    
        lIsTabBuilt = false(1, 3);
        hardware
        uiTabGroup
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = DCT(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.uiScannerM142, 'bl12014.ui.Scanner')
                error('uiScannerM142 must be bl12014.ui.Scanner');
            end
            
            
            if ~isa(this.uiBeamline, 'bl12014.ui.Beamline')
                error('uiBeamline must be bl12014.ui.Beamline');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            this.init();
            
        end
        
        
        function build(this, hParent, dLeft, dTop)
            
            
            this.uiAxes.build(hParent, dLeft, dTop + 20);
            this.uiTabGroup.build(hParent, ...
                dLeft + this.uiAxes.dWidth + 10, ...
                dTop, this.dWidthTabGroup, this.dHeightTabGroup);
            
            % Build the first tab.
            cTab = 'Stages';
            this.lIsTabBuilt(strcmp(cTab, this.cecTabs)) = true;
            hTab = this.uiTabGroup.getTabByName(cTab);
            
            dLeft = 30;
            dTop = 30;
            this.uiStages.build(hTab, dLeft, dTop);
            
        end
        
        
        
        %% Destructor
        
        function delete(this)
            this.uiStages = [];
            this.uiFluxDensity = [];
            this.uiExposureControl = [];          
        end 
        
        function cec = getSaveLoadProps(this)
           
            cec = {...
                'uiStages', ...
                'uiFluxDensity', ...
                'uiExposureControl', ...
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
    
    methods (Access = private)
        
        function init(this)
            
            this.exposures = bl12014.DCTExposures();
            
            % Initialize cell of function handle callbacks for each tab of 
            % the tab group
            
            cefhCallback = cell(1, length(this.cecTabs));
            for n = 1 : length(this.cecTabs)
                cefhCallback{n} = @this.onUiTabGroup;
            end
            
            this.uiAxes = bl12014.ui.DCTWaferAxes(...
                'clock', this.clock, ...
                'dWidth', 700, ...
                'dHeight', 700, ...
                'hardware', this.hardware, ...
                'exposures', this.exposures ...
            );
            
            this.uiTabGroup = mic.ui.common.Tabgroup(...
                'fhDirectCallback', cefhCallback, ...
                'ceTabNames',  this.cecTabs ...
            );
                                   
            this.uiClockStages = mic.ui.Clock(this.clock);
            this.uiClockFluxDensity = mic.ui.Clock(this.clock);
            this.uiClockExposureControl = mic.ui.Clock(this.clock);
            
            
            this.uiStages = bl12014.ui.DCTStages(...
                'uiClock', this.uiClockStages, ...
                'hardware', this.hardware, ...
                'exposures', this.exposures ...
            );
        
            
        
            this.uiFluxDensity = bl12014.ui.DCTFluxDensity(...
                'clock', this.clock, ...
                'uiClock', this.uiClockFluxDensity, ...
                'hardware', this.hardware, ...
                ...'uiGratingTiltX', this.uiBeamline.uiGratingTiltX, ...
                'uiScannerM142', this.uiScannerM142 ...
            );
            
            this.uiExposureControl = bl12014.ui.DCTExposureControl(...
                'clock', this.clock, ...
                'uiClock', this.uiClockExposureControl, ...
                'hardware', this.hardware, ...
                'exposures', this.exposures, ...
                'uiFluxDensity', this.uiFluxDensity, ...
                ...%'uiScannerM142', uiScannerM142, ...
                'uiBeamline', this.uiBeamline ...
            );
        
            
        end
        

        
        function stopAllUiClocks(this)
            this.uiClockStages.stop();
            this.uiClockFluxDensity.stop();
            this.uiClockExposureControl.stop();
        end
        
        function startUiClockOfActiveTab(this)
            cTab = this.uiTabGroup.getSelectedTabName();
            
            switch cTab
                case 'Stages'
                    this.uiClockStages.start();
                case 'Flux Density'
                     this.uiClockFluxDensity.start();
                case 'Exposure Control'
                     this.uiClockExposureControl.start();
            end
        end
        
        
        function onUiTabGroup(this)
            
            cTab = this.uiTabGroup.getSelectedTabName();
            lIsBuilt = this.lIsTabBuilt(strcmp(cTab, this.cecTabs));
            
            this.stopAllUiClocks();
            this.startUiClockOfActiveTab();
            
            if lIsBuilt
                % Already built
                return;
            end
            
            % Store that it has been built
            this.lIsTabBuilt(strcmp(cTab, this.cecTabs)) = true;
            hTab = this.uiTabGroup.getTabByName(cTab);
            
            dLeft = 10;
            dTop = 30;

            switch cTab
                case 'Stages'
                    this.uiStages.build(hTab, dLeft, dTop);
                case 'Flux Density'
                     this.uiFluxDensity.build(hTab, dLeft, dTop);
                case 'Exposure Control'
                     this.uiExposureControl.build(hTab, dLeft, dTop);

            end
            
            
        end
        
    end % private
    
    
end