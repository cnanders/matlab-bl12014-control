classdef Reticle < mic.Base
        
    properties (Constant)
      
        dWidth      = 1830
        dHeight     = 790
        
    end
    
	properties
        
        hDock
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDeltaTauPowerPmac
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommKeithley6482
        
        % {mic.ui.device.GetSetLogical 1x1}
        % uiCommDataTranslationMeasurPoint
        
        
        ReticleTTZClosedLoop
        
        uiCoarseStage
        uiFineStage
        uiAxes
        uiDiode
        uiMod3CapSensors
        uiWorkingMode
        uiMotMin
    end
    
    properties (SetAccess = private)
    
        cName = 'Reticle Control'
    end
    
    properties (Access = private)
                      
        clock
        hParent
        dDelay = 0.5
        
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
            this.init();
            
        end
        
        %{
        function connectDataTranslationMeasurPoint(this, comm)
            
            % 2018.09.15 Mod3 Cap Sensors Now come From PPMAC

            return
            
            deviceCap1 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, 5);
            deviceCap2 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, 6);
            deviceCap3 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, 7);
            deviceCap4 = GetNumberFromDataTranslationMeasurPoint(comm, GetNumberFromDataTranslationMeasurPoint.cTYPE_VOLTAGE, 8);
            
            this.uiMod3CapSensors.uiCap1.setDevice(deviceCap1);
            this.uiMod3CapSensors.uiCap2.setDevice(deviceCap2);
            this.uiMod3CapSensors.uiCap3.setDevice(deviceCap3);
            this.uiMod3CapSensors.uiCap4.setDevice(deviceCap4);
            
            this.uiMod3CapSensors.uiCap1.turnOn();
            this.uiMod3CapSensors.uiCap2.turnOn();
            this.uiMod3CapSensors.uiCap3.turnOn();
            this.uiMod3CapSensors.uiCap4.turnOn();
            
            
        end
        
        function disconnectDataTranslationMeasurPoint(this)
            
            % 2018.09.15 Mod3 Cap Sensors Now come From PPMAC
            
            return
            this.uiMod3CapSensors.uiCap1.turnOff();
            this.uiMod3CapSensors.uiCap2.turnOff();
            this.uiMod3CapSensors.uiCap3.turnOff();
            this.uiMod3CapSensors.uiCap4.turnOff();
            
            this.uiMod3CapSensors.uiCap1.setDevice([]);
            this.uiMod3CapSensors.uiCap2.setDevice([]);
            this.uiMod3CapSensors.uiCap3.setDevice([]);
            this.uiMod3CapSensors.uiCap4.setDevice([]);
        end
        
        %}
        
        %{
        function connectKeithley6482(this, comm)
            deviceCh1 = bl12014.device.GetNumberFromKeithley6482(comm, 1);
            this.uiDiode.uiCurrent.setDevice(deviceCh1);
            this.uiDiode.uiCurrent.turnOn();
        end
        
        function disconnectKeithley6482(this)
            this.uiDiode.uiCurrent.turnOff()
            this.uiDiode.uiCurrent.setDevice([]);
        end
        %}
        
        
        function connectDeltaTauPowerPmac(this, comm)
            
            this.uiFineStage.connectDeltaTauPowerPmac(comm);
            this.uiCoarseStage.connectDeltaTauPowerPmac(comm);
            this.uiMod3CapSensors.connectDeltaTauPowerPmac(comm)
            this.uiWorkingMode.connectDeltaTauPowerPmac(comm);
            this.uiMotMin.connectDeltaTauPowerPmac(comm);

            this.ReticleTTZClosedLoop.connect(comm);
        end
        
        function disconnectDeltaTauPowerPmac(this)

            this.uiFineStage.disconnectDeltaTauPowerPmac();
            this.uiCoarseStage.disconnectDeltaTauPowerPmac();
            this.uiMod3CapSensors.disconnectDeltaTauPowerPmac()
            this.uiWorkingMode.disconnectDeltaTauPowerPmac(); 
            this.uiMotMin.disconnectDeltaTauPowerPmac();     
            this.ReticleTTZClosedLoop.disconnect();
        end
        
        
                
        function build(this, hParent, dLeft, dTop)
            this.hParent = hParent;

            dPad = 10;
            dSep = 30;
            
            
            this.uiCommDeltaTauPowerPmac.build(this.hParent, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommKeithley6482.build(this.hParent, dLeft, dTop);
            dTop = dTop + dSep;
            
            %{
            this.uiCommDataTranslationMeasurPoint.build(this.hParent, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            %}
            
            
            dTop = 10;
            dLeft = 290;
            
            this.uiWorkingMode.build(this.hParent, dLeft, dTop);
            this.uiMotMin.build(this.hParent, 800, dTop);
            dLeft = 10;
            dTop = 280;
                        
            this.uiCoarseStage.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiCoarseStage.dHeight + dPad;
            
            this.uiFineStage.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiFineStage.dHeight + dPad;
            
            this.uiDiode.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiDiode.dHeight + dPad;
            
            this.ReticleTTZClosedLoop.build(this.hParent, dLeft, dTop);
            
            dLeft = 655;
            this.uiMod3CapSensors.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiMod3CapSensors.dHeight + dPad;
            
            dLeft = 1100;
            dTop = 280;
            this.uiAxes.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiAxes.dHeight + dPad;
                  
            this.clock.add(@this.onClock, this.id(), this.dDelay);

            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
            
            % Clean up clock tasks
            
            if (isvalid(this.clock))
                this.clock.remove(this.id());
            end
            
            % Delete the figure
            
            if ishandle(this.hParent)
                delete(this.hParent);
            end
            
            
        end
        
        function st = save(this)
            st = struct();
            st.uiCoarseStage = this.uiCoarseStage.save();
            st.uiFineStage = this.uiFineStage.save();
%             st.ReticleTTZClosedLoop = this.ReticleTTZClosedLoop.save();
            
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
        
        
        
        function onClock(this)
            
            if isempty(this.hParent) || ...
               ~ishghandle(this.hParent)
                this.msg('onClock() returning since not build', this.u8_MSG_TYPE_INFO);
                
                % Remove task
                if isvalid(this.clock) && ...
                   this.clock.has(this.id())
                    this.clock.remove(this.id());
                end
                
            end
            
            % Make sure the hggroup of the carriage is at the correct
            % location.  
            
            
            
            dX = this.uiCoarseStage.uiX.getValCal('mm') / 1000;
            dY = this.uiCoarseStage.uiY.getValCal('mm') / 1000;
            this.uiAxes.setStagePosition(-dX, -dY); % Flip y so screen corresponds to plan view
                        
        end
        
        
        function init(this)
            
            this.msg('init()');
            
            this.uiWorkingMode = bl12014.ui.PowerPmacWorkingMode(...
                'cName', 'reticle-pmac-working-mode', ...
                'clock', this.clock ...
            );
        
            this.uiMotMin = bl12014.ui.PowerPmacHydraMotMin(...
                'cName', 'reticle-pmac-hydra-mot-min', ...
                'clock', this.clock ...
            );
            this.uiCoarseStage = bl12014.ui.ReticleCoarseStage(...
                'clock', this.clock ...
            );
                       
            this.uiFineStage = bl12014.ui.ReticleFineStage(...
                'clock', this.clock ...
            );
        
            this.uiDiode = bl12014.ui.ReticleDiode(...
                'clock', this.clock ...
            );
        
            
                
            dHeight = 600;
            this.uiAxes = bl12014.ui.ReticleAxes(...
                'dWidth', dHeight, ...
                'dHeight', dHeight ...
            );
        
            this.uiMod3CapSensors = bl12014.ui.Mod3CapSensors(...
                'clock', this.clock ...
            );
        
            this.ReticleTTZClosedLoop = bl12014.ui.ReticleTTZClosedLoop(...
                'clock',        this.clock, ...
                'uiTiltX',      this.uiCoarseStage.uiTiltX, ...
                'uiTiltY',      this.uiCoarseStage.uiTiltY, ...
                'uiCoarseZ',    this.uiCoarseStage.uiZ, ...
                'uiCapSensors', this.uiMod3CapSensors...
            );
        
            this.initUiCommDataTranslationMeasurPoint();
            this.initUiCommDeltaTauPowerPmac();
            this.initUiCommKeithley6482();
        
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
        
        
        function initUiCommDataTranslationMeasurPoint(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            %{
            this.uiCommDataTranslationMeasurPoint = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'data-translation-measur-point-reticle', ...
                'cLabel', 'DataTrans MeasurPoint' ...
            );
            %}
        
        end
        
        function initUiCommDeltaTauPowerPmac(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommDeltaTauPowerPmac = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'delta-tau-power-pmac-reticle', ...
                'cLabel', 'DeltaTau Power PMAC' ...
            );
        
        end
        
        
        
        function initUiCommKeithley6482(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommKeithley6482 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'keithley-6482-reticle', ...
                'cLabel', 'Keithley 6482' ...
            );
        
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