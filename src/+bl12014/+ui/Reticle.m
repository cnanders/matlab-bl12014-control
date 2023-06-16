classdef Reticle < mic.Base
        
    properties (Constant)
      
        dWidth      = 1830
        dHeight     = 900
        
    end
    
	properties
        
        hDock
        
        % These are the UI for activating the hardware that gives the 
        % software real data
               
        % {mic.ui.device.GetSetLogical 1x1}
        % uiCommDataTranslationMeasurPoint
        
        uiReticleTTZClosedLoop
        uiReticleFiducializedMove
        
        uiCoarseStage
        uiFineStage
        uiAxes
        uiDiode
        uiMod3CapSensors
        uiWorkingMode
        uiMotMin
        uiShutter
        uiMotMinSimple
        
        uiButtonSyncDestinations
        
    end
    
    properties (SetAccess = private)
    
        cName = 'reticle-control-'
    end
    
    properties (Access = private)
                      
        clock
        uiClock
        hParent
        dDelay = 0.5
        
        % {bl12014.Hardware 1x1}
        hardware
        
        
        
    end
    
        
    events
                
    end
    

    
    methods
        
        
        function this = Reticle(varargin)
            
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
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            
            if ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock mic.ui.Clock');
            end
            
            this.init();
            
        end
          
        
        
        function syncDestinations(this)
            this.uiCoarseStage.uiX.syncDestination();
            this.uiCoarseStage.uiY.syncDestination();
            this.uiCoarseStage.uiZ.syncDestination();
            this.uiCoarseStage.uiTiltX.syncDestination();
            this.uiCoarseStage.uiTiltY.syncDestination();
            this.uiFineStage.uiX.syncDestination();
            this.uiFineStage.uiY.syncDestination();
            this.uiReticleTTZClosedLoop.uiCLTiltX.syncDestination();
            this.uiReticleTTZClosedLoop.uiCLTiltY.syncDestination();
            this.uiReticleTTZClosedLoop.uiCLZ.syncDestination();
            
            this.uiReticleFiducializedMove.uiRow.syncDestination();
            this.uiReticleFiducializedMove.uiCol.syncDestination();
        end
        
        function build(this, hParent, dLeft, dTop)
            this.hParent = hParent;

            dPad = 10;
            dSep = 30;
            
            
            %{
            this.uiCommDataTranslationMeasurPoint.build(this.hParent, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            %}
            
            
            dTop = 10;
            dLeft = 10;
            
            %{
            this.uiMotMinSimple.build(this.hParent, dLeft, dTop);
            dLeft =  dLeft + this.uiMotMinSimple.dWidth + 10;
            %}

            this.uiWorkingMode.build(this.hParent, dLeft, dTop);
            % this.uiMotMin.build(this.hParent, 800, dTop);
            


            
            dTop = 190;
            dLeft = 10;
                        
            this.uiCoarseStage.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiCoarseStage.dHeight + dPad;
            
            this.uiReticleFiducializedMove.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiReticleFiducializedMove.dHeight + dPad;
            
            this.uiReticleTTZClosedLoop.build(this.hParent, dLeft, dTop);
            
            
            this.uiMod3CapSensors.build(this.hParent, 620, dTop);
            dTop = dTop + this.uiReticleTTZClosedLoop.dHeight + dPad;
            
           
            this.uiFineStage.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiFineStage.dHeight + dPad;
           
            
            this.uiDiode.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiDiode.dHeight + dPad;
            
            dLeft = 10;
            
%             dTop = dTop + this.uiMod3CapSensors.dHeight + dPad;
            
            this.uiShutter.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiShutter.dHeight + dPad;
            
            
            dLeft = 1000;
            dTop = 220;
            this.uiAxes.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiAxes.dHeight + dPad;


            dLeft = 160;
            dTop = 190;
            this.uiButtonSyncDestinations.build(this.hParent, dLeft, dTop, 120, 24);
                  
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            this.uiCoarseStage = [];
            this.uiFineStage = [];
            this.uiWorkingMode = [];
            this.uiMotMin = [];
            this.uiMotMinSimple = [];
            this.uiReticleTTZClosedLoop = [];
            this.uiReticleFiducializedMove = [];
        
            this.msg('delete');
            
            % Clean up clock tasks
            
            if (isvalid(this.uiClock))
                this.uiClock.remove(this.id());
            end
            
            % Delete the figure
            
            
            
        end
        
        function st = save(this)
            st = struct();
            st.uiCoarseStage = this.uiCoarseStage.save();

            st.uiFineStage = this.uiFineStage.save();            
        end
        
        function load(this, st)
            if isfield(st, 'uiCoarseStage')
                this.uiCoarseStage.load(st.uiCoarseStage)
            end
            
            if isfield(st, 'uiFineStage')
                this.uiFineStage.load(st.uiFineStage)
            end
        end
        

    end
    
    methods (Access = private)
        
        
        
        
        
        function init(this)
            
            this.msg('init()');
            
            this.uiWorkingMode = bl12014.ui.PowerPmacWorkingMode(...
                'cName', [this.cName, 'pmac-working-mode'], ...
                'hardware', this.hardware, ...
                'uiClock', this.uiClock, ...
                'clock', this.clock ...
            );
        
            this.uiMotMin = bl12014.ui.PowerPmacHydraMotMin(...
                'cName', [this.cName, 'power-pmac-hydra-mot-min'], ...
                'hardware', this.hardware, ...
                'uiClock', this.uiClock, ...
                'clock', this.clock ...
            );
        
            this.uiMotMinSimple = bl12014.ui.PowerPmacHydraMotMinSimple(...
                'cName', [this.cName, 'power-pmac-hydra-mot-min-simple'], ...
                'hardware', this.hardware, ...
                'clock', this.clock, ...
                'uiClock', this.uiClock ...
            );
            this.uiCoarseStage = bl12014.ui.ReticleCoarseStage(...
                'cName', [this.cName, 'reticle-coarse-stage'], ...
                 'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
                       
            this.uiFineStage = bl12014.ui.ReticleFineStage(...
                'cName', [this.cName, 'reticle-fine-stage'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        
            this.uiDiode = bl12014.ui.ReticleDiode(...
                'cName', [this.cName, 'reticle-diode'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
            
                
            this.uiShutter = bl12014.ui.Shutter(...
                'cName', [this.cName, 'shutter'], ...
                'hardware', this.hardware, ...
                'clock', this.clock, ...
                'uiClock', this.uiClock ...
            );

                    
            dHeight = 600;
            this.uiAxes = bl12014.ui.ReticleAxes(...
                'cName', [this.cName, 'reticle-axes'], ...
                'clock', this.uiClock, ...
                'fhGetIsShutterOpen', @this.uiShutter.uiOverride.get, ...
                'fhGetX', @() this.uiCoarseStage.uiX.getValCal('mm') / 1000, ...
                'fhGetY', @() this.uiCoarseStage.uiY.getValCal('mm') / 1000, ...
                'dWidth', dHeight, ...
                'dHeight', dHeight ...
            );
        
            this.uiMod3CapSensors = bl12014.ui.Mod3CapSensors(...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        
            this.uiReticleTTZClosedLoop = bl12014.ui.ReticleTTZClosedLoop(...
                'clock',        this.clock, ...
                'hardware', this.hardware, ...
                'uiClock',      this.uiClock, ...
                'cName', [this.cName, 'reticle-z-tiltX-tiltY-closed-loop'], ...
                'uiTiltX',      this.uiCoarseStage.uiTiltX, ...
                'uiTiltY',      this.uiCoarseStage.uiTiltY, ...
                'uiCoarseZ',    this.uiCoarseStage.uiZ, ...
                'uiCapSensors', this.uiMod3CapSensors...
            );
        
            this.uiReticleFiducializedMove = bl12014.ui.ReticleFiducializedMove(...
                'clock',  this.uiClock, ...
                'uiX', this.uiCoarseStage.uiX, ...
                'uiY', this.uiCoarseStage.uiY, ...
                'hardware', this.hardware ...
            );
        
            
            this.uiButtonSyncDestinations = mic.ui.common.Button(...
                'fhOnClick', @(src, evt) this.syncDestinations(), ...
                'cText', 'Sync Destinations' ...
            );
        
            addlistener(this.uiAxes, 'eClickField', @this.onUiAxesClickField);

        end
        
        
        function onCloseRequest(this, src, evt)
            this.msg('ReticleControl.closeRequestFcn()');
            this.uiMod3CapSensors.onClose();
            delete(this.hParent);
            this.hParent = [];
            % this.saveState();
        end
        
        function onDockClose(this, ~, ~)
            this.msg('ReticleControl.closeRequestFcn()');
            this.uiMod3CapSensors.onClose();
            this.hParent = [];
        end
        
        
       
        
        
        

       
        
        function onUiAxesClickField(this, src, evt)
             
            % evt.stData.dX is in units of mm
            dX = -this.uiAxes.dXChiefRay * 1000 + evt.stData.dX; %mm
            this.uiCoarseStage.uiX.setDestCal(dX, 'mm');
            this.uiCoarseStage.uiX.moveToDest();
            
            dY = -this.uiAxes.dYChiefRay * 1000 + evt.stData.dY; %mm
            this.uiCoarseStage.uiY.setDestCal(dY, 'mm');
            this.uiCoarseStage.uiY.moveToDest();  
          
            
            
        end
        

    end % private
    
    
end