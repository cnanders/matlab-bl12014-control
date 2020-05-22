classdef DCTStages < mic.Base
    
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        
        dWidth = 1000
        dHeight = 700
               
    end
    
	properties
        
       
    end
    
    properties (SetAccess = private)
        
        uiStageAperture
        uiStageWafer
        uiAxes
        uiShutter
        
    end
    
    properties (Access = private)
        
        
        hPanel
        cName = 'dct-stages-'
        
        
        uiClock
        
        % {bl12014.Hardware 1x1}
        hardware
        
        % { bl12014.DCTExposures 1x1}
        exposures
        
       
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = DCTStages(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.uiClock, 'mic.Clock') && ...
               ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            if ~isa(this.exposures, 'bl12014.DCTExposures')
                error('exposures must be bl12014.DCTExposures');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
            
        end
        
        
        function init(this)
            
            this.uiShutter = bl12014.ui.Shutter(...
                'cName', [this.cName, 'shutter'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        
        
            this.uiStageWafer = bl12014.ui.DCTWaferStage(...
                'cName', [this.cName, 'stage-wafer'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        
            this.uiStageAperture = bl12014.ui.DCTApertureStage(...
                'cName', [this.cName, 'stage-aperture'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
            
            this.uiAxes = bl12014.ui.DCTWaferAxes(...
                'cName', [this.cName, 'axes'], ...
                'clock', this.uiClock, ...
                'fhGetIsShutterOpen', @() this.uiShutter.uiOverride.get(), ...
                'fhGetXOfWafer', @() this.uiStageWafer.uiX.getValCal('mm') * 1e-3, ...
                'fhGetYOfWafer', @() this.uiStageWafer.uiY.getValCal('mm') * 1e-3, ...
                'fhGetXOfAperture', @() this.uiStageAperture.uiX.getValCal('mm') * 1e-3, ...
                'fhGetYOfAperture', @() this.uiStageAperture.uiY.getValCal('mm') * 1e-3, ...
                'exposures', this.exposures ...
            );
            
            
        end
        
        
        function build(this, hParent, dLeft, dTop)

            dPad = 10;
            dSep = 30;
            
            dTopStart = dTop;
            
            this.uiStageAperture.build(hParent, dLeft, dTop);
            dTop = dTop + this.uiStageAperture.dHeight + dPad;
            
            this.uiStageWafer.build(hParent, dLeft, dTop);
            dTop = dTop + this.uiStageWafer.dHeight + dPad;
            
            % Don't build shutter.
            
            dLeft = dLeft + this.uiStageWafer.dWidth + dPad;
            dTop = dTopStart;
            this.uiAxes.build(hParent, dLeft, dTop);
            
        end
        
        
    end
    
end

