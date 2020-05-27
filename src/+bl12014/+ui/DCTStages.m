classdef DCTStages < mic.Base
    
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        
        dWidth = 500
        dHeight = 500
               
    end
    
	properties
        
       
    end
    
    properties (SetAccess = private)
        
        uiStageAperture
        uiStageWafer
        
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
            
        end
        
        
        function build(this, hParent, dLeft, dTop)

            dPad = 10;
            dSep = 30;
            
            dTopStart = dTop;
            
            this.uiStageAperture.build(hParent, dLeft, dTop);
            dTop = dTop + this.uiStageAperture.dHeight + dPad;
            
            this.uiStageWafer.build(hParent, dLeft, dTop);
            dTop = dTop + this.uiStageWafer.dHeight + dPad;
            
            
        end
        
        
    end
    
end

