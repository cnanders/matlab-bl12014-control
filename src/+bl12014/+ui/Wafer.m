classdef Wafer < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 1900 %1295
        dHeight     = 1000
        
    end
    
	properties
        
        hDock = {}
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        % uiCommCxroHeightSensor
        % uiCommDataTranslationMeasurPoint
        uiCommMfDriftMonitor
        
                
        uiCoarseStage
        uiLsiCoarseStage
        uiFineStage
        uiHeightSensorZClosedLoop
        uiHeightSensorZClosedLoopCoarse
        uiHeightSensorRxClosedLoop
        uiHeightSensorRyClosedLoop
        
        
        %Closed loop control for rx/ry/z
        uiWaferTTZClosedLoop
        
        uiAxes
        uiDiode
        uiPobCapSensors
        % uiHeightSensor
        uiWorkingMode
        uiMotMin
        uiShutter
        
        commDeltaTauPowerPmac = []
        commMfDriftMonitorMiddleware = []
        
        
       
        
        waferExposureHistory
        
        uiMotMinSimple
        
        uiButtonSyncDestinations
        
        uiSequenceHomeAndLevel
    end
    
    properties (SetAccess = private)
        
        hParent
        cName = 'wafer-control-'
        
    end
    
    properties (Access = private)
                      
        clock
        uiClock
        dDelay = 0.5
        
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = Wafer(varargin)
            
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
            
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
            
            
        end
        
        
        
        function syncDestinations(this)
            this.uiCoarseStage.uiX.syncDestination();
            this.uiCoarseStage.uiY.syncDestination();
            this.uiCoarseStage.uiZ.syncDestination();
            this.uiCoarseStage.uiTiltX.syncDestination();
            this.uiCoarseStage.uiTiltY.syncDestination();
            this.uiFineStage.uiZ.syncDestination();
            this.uiWaferTTZClosedLoop.uiCLTiltX.syncDestination();
            this.uiWaferTTZClosedLoop.uiCLTiltY.syncDestination();
            this.uiWaferTTZClosedLoop.uiCLZ.syncDestination();
            
        end
        
        
        function build(this, hParent, dLeft, dTop)
                    
            this.hParent = hParent;

            dPad = 10;
            dSep = 30;

            
            
            %{
            this.uiCommCxroHeightSensor.build(this.hParent, dLeft, dTop);
            dTop = dTop + dSep;
            %}
                        
            
           
            %{
            this.uiCommDataTranslationMeasurPoint.build(this.hParent, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            %}
            
            % this.hs.build(this.hParent, dPad, dTop);
            
            dTop = 10;
            dLeft = 10;
            this.uiMotMinSimple.build(this.hParent, dLeft, dTop);
            
            dLeft = 350;
            this.uiWorkingMode.build(this.hParent, dLeft, dTop);
            % this.uiMotMin.build(this.hParent, 800, 10);
            
            dTop = 20;
            dLeft = 720;
            this.uiSequenceHomeAndLevel.build(this.hParent, dLeft, dTop, 300);
            
            
            dLeft = 10;
            dTop = 140;
            
            this.uiButtonSyncDestinations.build(this.hParent, dLeft, dTop, 120, 24);
            dTop = 180;
                        
            this.uiCoarseStage.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiCoarseStage.dHeight + dPad;
            
            %{
            this.uiLsiCoarseStage.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiLsiCoarseStage.dHeight + dPad;
            %}
            
            this.uiFineStage.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiFineStage.dHeight + dPad;
            
%             this.uiHeightSensorZClosedLoop.build(this.hParent, dLeft, dTop);
%             dTop = dTop + this.uiHeightSensorZClosedLoop.dHeight + dPad;
            
            %{
            this.uiHeightSensorZClosedLoopCoarse.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiHeightSensorZClosedLoopCoarse.dHeight + dPad;
            %}
           
            
%             this.uiHeightSensorRxClosedLoop.build(this.hParent, dLeft, dTop);
%             dTop = dTop + this.uiHeightSensorZClosedLoop.dHeight + dPad;
%             
%             this.uiHeightSensorRyClosedLoop.build(this.hParent, dLeft, dTop);
%             dTop = dTop + this.uiHeightSensorZClosedLoop.dHeight + dPad;
            
            this.uiWaferTTZClosedLoop.build(this.hParent, dLeft, dTop)
            
            
            dLeft = 650;
            this.uiPobCapSensors.build(this.hParent, dLeft, dTop);
             
            dTopDiode = dTop;
            
            dTop = dTop + this.uiWaferTTZClosedLoop.dHeight + dPad;

            dLeft = 10;
            this.uiDiode.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiDiode.dHeight + dPad;
            
            this.uiShutter.build(this.hParent, dLeft, dTop);
            
            
            %{
            this.uiHeightSensor.build(this.hParent, 375, dTopDiode);
            dTop = dTop + this.uiHeightSensor.dHeight + dPad;
            %}
            
            dLeft = 1000;
            dTop = 180;
            this.uiAxes.build(this.hParent, dLeft, dTop);
            dTop = dTop + this.uiAxes.dHeight + dPad;
            
            
            
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
                this.uiCoarseStage = [];
                this.uiFineStage = [];
                this.uiLsiCoarseStage = [];
                this.uiWorkingMode = [];
                 this.uiWaferTTZClosedLoop = [];       
        end
        
        function st = save(this)
            st = struct();
            st.uiCoarseStage = this.uiCoarseStage.save();
            st.uiFineStage = this.uiFineStage.save();
            st.uiLsiCoarseStage = this.uiLsiCoarseStage.save();
        end
        
        function load(this, st)
            if isfield(st, 'uiCoarseStage')
                this.uiCoarseStage.load(st.uiCoarseStage)
            end
            
            if isfield(st, 'uiLsiCoarseStage')
                this.uiLsiCoarseStage.load(st.uiLsiCoarseStage)
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
                'clock', this.uiClock ...
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
                'uiClock', this.uiClock, ...
                'clock', this.clock ...
            );
        
            this.uiCoarseStage = bl12014.ui.WaferCoarseStage(...
                'cName', [this.cName, 'wafer-coarse-stage'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        
            this.uiLsiCoarseStage = bl12014.ui.LsiCoarseStage(...
                'cName', [this.cName, 'lsi-coarse-stage'], ...
                'hardware', this.hardware', ...
                'clock', this.uiClock ...
            );
        
            this.uiLsiCoarseStage.uiX.setDestCal(450, 'mm');
            this.uiLsiCoarseStage.uiX.moveToDest();
            
            this.uiFineStage = bl12014.ui.WaferFineStage(...
                'cName', [this.cName, 'wafer-fine-stage'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        
%             this.uiHeightSensorZClosedLoop = bl12014.ui.HeightSensorZClosedLoop( ...
%                 'clock', this.uiClock, ...
%                 'lShowZWafer', false, ...
%                 'uiParentStageUICoarse', this.uiCoarseStage.uiZ, ...
%                 'uiParentStageUIFine', this.uiFineStage.uiZ, ...
%                 'cName', 'ui-wafer' ...
%             );
        
%             this.uiHeightSensorRxClosedLoop = bl12014.ui.HeightSensorRxClosedLoop( ...
%                 'clock', this.uiClock, ...
%                 'lShowZWafer', false, ...
%                 'uiParentStageUI', this.uiCoarseStage.uiTiltX, ...
%                 'cName', 'ui-wafer' ...
%             );
%         
%             this.uiHeightSensorRyClosedLoop = bl12014.ui.HeightSensorRyClosedLoop( ...
%                 'clock', this.uiClock, ...
%                 'lShowZWafer', false, ...
%                 'uiParentStageUI', this.uiCoarseStage.uiTiltY, ...
%                 'cName', 'ui-wafer' ...
%             );
        
%{
            this.uiHeightSensorZClosedLoopCoarse = bl12014.ui.HeightSensorZClosedLoopCoarse( ...
                'clock', this.uiClock, ...
                'hardware', this.hardware, ...
                'lShowZWafer', false, ...
                'cName', [this.cName, 'hs-z-closed-loop-coarse'] ...
            );
%}
        
            % New ZTT closed loop framework.  This UI will connect to other
            % UIs and control them using feedback from drift monitor
            % sensors
            this.uiWaferTTZClosedLoop = bl12014.ui.WaferTTZClosedLoop( ...
                'clock',        this.clock, ...
                'hardware', this.hardware, ...
                'uiClock',      this.uiClock, ...
                'cName', [this.cName, 'wafer-z-tiltX-tiltY-closed-loop'], ...
                'dZTol',  0.5, ...
                'uiTiltX',      this.uiCoarseStage.uiTiltX, ...
                'uiTiltY',      this.uiCoarseStage.uiTiltY, ...
                'uiCoarseZ',    this.uiCoarseStage.uiZ, ...
                'uiFineZ',      this.uiFineStage.uiZ ...
            );
        
            this.uiDiode = bl12014.ui.WaferDiode(...
                'cName', [this.cName, 'diode-wafer'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
            this.uiPobCapSensors = bl12014.ui.PobCapSensors(...
                'cName', [this.cName, 'pob-cap-sensors'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        
            %{
            this.uiHeightSensor = bl12014.ui.HeightSensor( ...
                'clock', this.uiClock ...
            );
            %}
        
            % this.initUiCommCxroHeightSensor();
        
            
            this.uiShutter = bl12014.ui.Shutter(...
                'cName', [this.cName, 'shutter'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );


                        
            dHeight = 600;
            this.uiAxes = bl12014.ui.WaferAxes( ...
                'cName', [this.cName, 'wafer-axes'], ... 
                'clock', this.uiClock, ...
                'fhGetIsShutterOpen', @() this.uiShutter.uiOverride.get(), ...
                'fhGetXOfWafer', @() this.uiCoarseStage.uiX.getValCal('mm') / 1000, ...
                'fhGetYOfWafer', @() this.uiCoarseStage.uiY.getValCal('mm') / 1000, ...
                'fhGetXOfLsi', @() this.uiLsiCoarseStage.uiX.getValCal('mm') / 1000, ...
                'waferExposureHistory', this.waferExposureHistory, ...
                'dWidth', dHeight, ...
                'dHeight', dHeight ...
            );
        
        
            this.uiButtonSyncDestinations = mic.ui.common.Button(...
                'fhOnClick', @(src, evt) this.syncDestinations(), ...
                'cText', 'Sync Destinations' ...
            );
        
            this.uiSequenceHomeAndLevel = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-sequence-wm-run-wafer-print-wafer-level'], ...
                'task', bl12014.Tasks.createSequenceWorkingModeRunWaferPrintWaferLevel(...
                    [this.cName, 'sequence-wm-run-wafer-print-wafer-level'], ...
                    this.hardware, ...
                    this.uiWaferTTZClosedLoop, ...
                    this.clock ...
                ), ...
                'lShowIsDone', true, ...
                'clock', this.uiClock ...
            );
            
        
            
                        
            

        end
        
        
        %{
        function initUiCommCxroHeightSensor(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommCxroHeightSensor = mic.ui.device.GetSetLogical(...
                'clock', this.uiClock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'cxro-height-sensor', ...
                'cLabel', 'CXRO Height Sensor' ...
            );
        
        end
        %}
        
       
        
        
        function onCloseRequestFcn(this, src, evt)
            
            delete(this.hParent);
            this.hParent = [];
            % this.saveState();
            
        end
        
        function onDockClose(this, ~, ~)
            this.msg('ReticleControl.closeRequestFcn()');
            this.hParent = [];
        end

        
        
    end % private
    
    
end