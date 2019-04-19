classdef Scan < mic.Base
    
    % A panel with a list of available prescriptions, the ability to queue
    % multiple prescriptions to a new experiment (wafer), start/pause/stop
    % the experiment, checkboxes for booleans pertaining to running the
    % experiment
    
    
    properties (Constant)
       
        dWidth = 950
        dHeight = 570
        
        
        dWidthList = 500
        dHeightList = 100
        dWidthUiScan = 270
        
        dPauseTime = 1
        
        dWidthPanelAvailable = 600
        dHeightPanelAvailable = 200
        
        dWidthPanelAdded = 800
        dHeightPanelAdded = 550
        
        dWidthPanelBorder = 1
        
        dColorFigure = [200 200 200]./255
        
        dToleranceReticleX = 0.01 % mm
        dToleranceReticleY = 0.01 % mm
        dToleranceWaferX = 0.01 % mm
        dToleranceWaferY = 0.01 % mm
        dToleranceWaferZ = 5 % nm
        dToleranceReticleFineX = 0.1 % umm
        dToleranceReticleFineY = 0.1 % um

        dColorGreen = [.85, 1, .85];
        dColorRed = [1, .85, .85];
        
    end
    
	properties

        
    end
    
    properties (SetAccess = private)
        
        hDYMO
        
        uiEditMjPerCm2PerSec
        uiEditRowStart
        uiEditColStart
        
        uiPOCurrent
        uiShutter
        uiPrescriptionTool
        
        cName = 'fem-scan-control'
    
    end
    
    properties (Access = private)
        
        
        dWidthButton = 100
        dWidthPadPanel = 10
        dWidthPadFigure = 10
        dHeightPadFigure = 10
        dHeightButton = 24
        
        uiListPrescriptions            
        uiListActive
        
        uiButtonClearPrescriptions
        uiButtonClearWafer
        
        uibNewWafer
        uibAddToWafer
        uibPrint
        uibPrintSaved
        uicWaferLL
        uicAutoVentAtLL 
        
        
        uiMFDriftMonitor
        uiMfDriftMonitorVibration
        uiVibrationIsolationSystem
        uiWafer
        uiReticle
        uiPupilFill
        uiScannerMA
        uiScannerM142
        % {mic.ui.device.GetSetNumber 1x1}
        uiBeamline % Temporary, allows control of the shutter
        uiTuneFluxDensity
        
        clock
        uiClock
        
        hDock
        
        cDirThis
        cDirSrc
        cDirPrescriptions
        cDirSave
        cDirScan % new directory for every scan
        
        hPanelAvailable
        hPanelAdded
        hParent
        
        cePrescriptions           % Store uiListActive.ceOptions when FEM starts
         
        %{        
        uitScanPause
        uibScanAbort
        uibScanStart
        %}
        
        % {mic.ui.Scan 1x1}
        uiScan
        
        % Going to have a play/pause button and an abort button.  When you
        % click play the first time, a logical lRun = true will be set.  An
        % abort button will be shown.  Chenging the status of the button
        % will then put us into wait.  Only if we click abort lRun = false
        % will be set and the abort button will be hidden
        
        lRunning = false
        
        % {mic.Scan 1x1}
        scan
        
        % {struct 1x1} storage used  and checking if the
        % system has reached a particular state.  The structure has a prop
        % for each configurable prop of the system and each of those has
        % two props: lRequired, lIssued
        stScanSetContract
        stScanAcquireContract
        
        % {cell of struct} storage of state during each acquire
        ceValues
                
        
        uiWaferAxes
        uiReticleAxes
        waferExposureHistory
        
        
         % {bl12014.Hardware 1x1}
        hardware
            
        
        uiSequenceLevelWafer
        uiSequenceLevelReticle
        uiStateM142ScanningDefault
        uiStateUndulatorIsCalibrated
        uiStateExitSlitIsCalibrated
        uiStateMonoGratingAtEUV
        
        uiTextReticleField
        
        hAxesPupilFill
        hAxesFieldFill
        hPlotPupilFill
        hPlotFieldFill
        dColorPlotFiducials = [0.3 0.3 0.3]
        
        uiTextTimeCalibrated
        uiTextFluxDensityCalibrated
    end
    
        
    events
        ePreChange
    end
    

    
    methods
        
        
        function this = Scan(varargin)
            
            
            this.cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSrc = fullfile(this.cDirThis, '..', '..');
            this.cDirPrescriptions = fullfile(...
                this.cDirSrc, ...
                'save', ...
                'prescriptions' ...
            );
            this.cDirSave = fullfile(this.cDirSrc, 'save', 'fem-scans');
            this.cDirPrescriptions = mic.Utils.path2canonical(this.cDirPrescriptions);

                        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            if ~isa(this.uiTuneFluxDensity, 'bl12014.ui.TuneFluxDensity')
                error('uiTuneFluxDensity must be bl12014.ui.TuneFluxDensity');
            end
            
            if ~isa(this.uiReticle, 'bl12014.ui.Reticle')
                error('uiReticle must be bl12014.ui.Reticle');
            end
            
            if ~isa(this.uiWafer, 'bl12014.ui.Wafer')
                error('uiWafer must be bl12014.ui.Wafer');
            end
            
            if ~isa(this.uiScannerMA, 'bl12014.ui.Scanner')
                error('uiScannerMA must be bl12014.ui.Scanner');
            end
            
            if ~isa(this.uiScannerM142, 'bl12014.ui.Scanner')
                error('uiScannerM142 must be bl12014.ui.Scanner');
            end
            
            if ~isa(this.waferExposureHistory, 'bl12014.WaferExposureHistory')
                error('waferExposureHistory must be bl12014.WaferExposureHistory');
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
            
        end
        
        function st = save(this)
             st = struct();
             st.cDirPrescriptions = this.cDirPrescriptions;
             st.lWaferLoadLock = this.uicWaferLL.get();
             st.lAutoVentAtLoadLock = this.uicAutoVentAtLL.get(); 
             % st.uiEditMjPerCm2PerSec = this.uiEditMjPerCm2PerSec.save();
             st.uiEditRowStart = this.uiEditRowStart.save();
             st.uiEditColStart = this.uiEditColStart.save();
        end
        
        function load(this, st)
            this.cDirPrescriptions = st.cDirPrescriptions;
            this.uicWaferLL.set(st.lWaferLoadLock);
            this.uicAutoVentAtLL.set(st.lAutoVentAtLoadLock);
            
            
            
            if isfield(st, 'uiEditColStart')
                try
                    this.uiEditColStart.load(st.uiEditColStart);
                end
            end
            
            if isfield(st, 'uiEditRowStart')
                try
                    this.uiEditRowStart.load(st.uiEditRowStart);
                end
            end
            
        end
       
        
        
        function buildPanelAdded(this)
            
           
            
            dLeft = 1000;
            dTop = 10;
            
            this.hPanelAdded = uipanel(...
                'Parent', this.hParent,...
                'Units', 'pixels',...
                'Title', '',...
                'BorderWidth', this.dWidthPanelBorder, ...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                    dLeft ...
                    dTop ...
                    this.dWidthPanelAdded...
                    this.dHeightPanelAdded], ...
                    this.hParent ...
                ) ...
            );
        
            
            dLeft = this.dWidthPadFigure;
            dTop = this.dWidthPadFigure;
            
            this.uiListActive.build(this.hPanelAdded, ...
                dLeft, ...
                dTop, ...
                this.dWidthList, ...
                40);
            
           dTop = 30;
           dSep = 20;
           dTop = 140;
           
           %dLeft = dPad + this.dWidthList + dPad;
           
           dTop = 70;
           dLeft = this.dWidthPadFigure;
           
%            this.uibNewWafer.build(this.hPanelAdded, ...
%                 dLeft, ...
%                 dTop, ...
%                 this.dWidthButton, ...
%                 this.dHeightButton);
%             dLeft = dLeft + this.dWidthButton + this.dWidthPadFigure;
            
            this.uiButtonClearPrescriptions.build(this.hPanelAdded, ...
                dLeft, ...
                dTop, ...
                this.dWidthButton, ...
                this.dHeightButton);
            dLeft = dLeft + this.dWidthButton + this.dWidthPadFigure;
            
            this.uiButtonClearWafer.build(this.hPanelAdded, ...
                dLeft, ...
                dTop, ...
                this.dWidthButton, ...
                this.dHeightButton);
            dLeft = dLeft + this.dWidthButton + this.dWidthPadFigure;
            
            
            this.uibPrint.build(this.hPanelAdded, ...
                dLeft, ...
                dTop, ...
                100, ...
                this.dHeightButton);
            
           
           dLeft = this.dWidthPadFigure;
           dTop = dTop + 50;
           
           dTopBelowList = dTop;
           
           dSep = 40;
           
           %{
           this.uiEditMjPerCm2PerSec.build(this.hPanelAdded, dLeft, dTop, 100, 24);
           dTop = dTop + dSep;
           %}
                      
           this.uiEditColStart.build(this.hPanelAdded, dLeft, dTop, 100, 24);
           dTop = dTop + dSep;
           
           this.uiEditRowStart.build(this.hPanelAdded, dLeft, dTop, 100, 24);
           dTop = dTop + dSep;
           
           dTop = dTop + 10;
           
           dSep = 20;
           
           this.uicWaferLL.build(this.hPanelAdded, ...
               dLeft, ...
               dTop, ...
               200, ...
               20);
            
           dTop = dTop + dSep;
           this.uicAutoVentAtLL.build(this.hPanelAdded, ...
               dLeft, ...
               dTop, ...
               200, ...
               20);
           dTop = dTop + 30;
           
           % dLeft = 150;
           % dTop = 180
           this.uiScan.build(this.hPanelAdded, dLeft - 10, dTop);
           
           dTop = dTopBelowList;
           dLeft = 400;
           dSep = 30;
           dSize = 100;
           
           this.hAxesFieldFill = axes(...
                'Parent', this.hPanelAdded,...
                'Units', 'pixels',...
                'Color', [0 0 0], ...
                'Position',mic.Utils.lt2lb([...
                dLeft, ...
                dTop, ...
                dSize, ...
                dSize], this.hPanelAdded),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                'DataAspectRatio',[1 1 1],...
                'HandleVisibility','on'...
           );
       
            
            this.hAxesPupilFill = axes(...
                'Parent', this.hPanelAdded,...
                'Units', 'pixels',...
                'Color', [0 0 0], ...
                'Position',mic.Utils.lt2lb([...
                dLeft + dSize + 50,...
                dTop,...
                dSize,...
                dSize], this.hPanelAdded),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                'DataAspectRatio',[1 1 1],...
                'HandleVisibility','on'...
           );
            
           dTop = dTop + 120;
           
           
           dWidthText = 300
           dHeightText = 24;
            
           this.uiTextReticleField.build(this.hPanelAdded, dLeft, dTop, 300, 24);
           dTop = dTop + dSep;
           
           %{
            this.uiTextTimeCalibrated.build(this.hPanelAdded, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dSep;
           %}
            
            this.uiTextFluxDensityCalibrated.build(this.hPanelAdded, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop  + dSep;
            
            
           this.uiStateUndulatorIsCalibrated.build(this.hPanelAdded, dLeft, dTop, 300);
           dTop = dTop + dSep;
           
           this.uiStateMonoGratingAtEUV.build(this.hPanelAdded, dLeft, dTop, 300);
           dTop = dTop + dSep;
           
           this.uiStateExitSlitIsCalibrated.build(this.hPanelAdded, dLeft, dTop, 300);
           dTop = dTop + dSep;
           %{
           this.uiStateM142ScanningDefault.build(this.hPanelAdded, dLeft, dTop, 300);
           dTop = dTop + dSep;
           %}
           this.uiSequenceLevelReticle.build(this.hPanelAdded, dLeft, dTop, 300);
           dTop = dTop + dSep;
           this.uiSequenceLevelWafer.build(this.hPanelAdded, dLeft, dTop, 300);
           dTop = dTop + dSep;

           
            
        end
             
        
        function plotPupilFill(this)
            
            if isempty(this.hAxesPupilFill)
                return
            end
            
            if ~ishandle(this.hAxesPupilFill)
                return
            end
            
            
            st = this.uiScannerMA.uiNPointLC400.getWavetables();
            
            if isempty(this.hPlotPupilFill)
                this.hPlotPupilFill = plot(...
                    this.hAxesPupilFill, ...
                    st.x, st.y, 'm', ...
                    'LineWidth', 2 ...
                );
            
                % Create plotting data for circles at sigma = 0.3 - 1.0

                dSig = [0.3:0.1:1.0];
                dPhase = linspace(0, 2*pi, 100);

                for (k = 1:length(dSig))

                    x = dSig(k)*cos(dPhase);
                    y = dSig(k)*sin(dPhase);
                    line( ...
                        x, y, ...
                        'color', this.dColorPlotFiducials, ...
                        'LineWidth', 1, ...
                        'Parent', this.hAxesPupilFill ...
                    );

                end
            else
                this.hPlotPupilFill.XData = st.x;
                this.hPlotPupilFill.YData = st.y;
            end
            set(this.hAxesPupilFill, 'XTick', [], 'YTick', []);
            
            if this.uiScannerMA.uiNPointLC400.uiGetSetLogicalActive.get()
                set(this.hAxesPupilFill, 'Color', this.dColorGreen);
            else
                set(this.hAxesPupilFill, 'Color', this.dColorRed);
            end
            xlim(this.hAxesPupilFill, [-1 1])
            ylim(this.hAxesPupilFill, [-1 1])
            
        end
        
        function plotFieldFill(this)
            
            if isempty(this.hAxesFieldFill)
                return
            end
            
            if ~ishandle(this.hAxesFieldFill)
                return
            end
            
            
            st = this.uiScannerM142.uiNPointLC400.getWavetables();
            
            if isempty(this.hPlotFieldFill)
                this.hPlotFieldFill = plot(...
                    this.hAxesFieldFill, ...
                    st.x, st.y, 'm', ...
                    'LineWidth', 2 ...
                );
            
                % Draw a border that represents the width of the field
                dWidth = 0.62;
                dHeight = dWidth / 5;
                
                x = [-dWidth/2 dWidth/2 dWidth/2 -dWidth/2 -dWidth/2];
                y = [dHeight/2 dHeight/2 -dHeight/2 -dHeight/2 dHeight/2];
                line( ...
                    x, y, ...
                    'color', this.dColorPlotFiducials, ...
                    'LineWidth', 1, ...
                    'Parent', this.hAxesFieldFill ...
                );
            else
                this.hPlotFieldFill.XData = st.x;
                this.hPlotFieldFill.YData = st.y;
            end
            
            set(this.hAxesFieldFill, 'XTick', [], 'YTick', []);
            
            % Set background color based on if the scanner is on or not
            if this.uiScannerM142.uiNPointLC400.uiGetSetLogicalActive.get()
                set(this.hAxesFieldFill, 'Color', this.dColorGreen);
            else
                set(this.hAxesFieldFill, 'Color', this.dColorRed);
            end
            xlim(this.hAxesFieldFill, [-1 1])
            ylim(this.hAxesFieldFill, [-1 1])
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hParent = hParent;
            
            this.uiPrescriptionTool.build(hParent, dLeft, dTop);
            
            dLeft = 400;
            dWidthButton = 150;
            dSep = 10;
            this.uibAddToWafer.build(...
                hParent, ...
                400, ...
                dTop + this.uiPrescriptionTool.dHeight - 45, ...
                dWidthButton, ...
                this.dHeightButton);
            
            dLeft = dLeft + dWidthButton + dSep;
            this.uibPrintSaved.build( ...
                hParent, ...
                dLeft, ...
                dTop + this.uiPrescriptionTool.dHeight - 45, ...
                dWidthButton, ...
                this.dHeightButton);
            
            
            this.buildPanelAdded()
            
            dTop = 580;
            this.uiReticleAxes.build(this.hParent, 10, dTop);
            this.uiWaferAxes.build(this.hParent, 420, dTop);
            this.uiShutter.build(this.hParent, 10 + this.uiPrescriptionTool.dWidth + 80, 500);
            this.uiPOCurrent.build(this.hParent, 840, dTop);
            
            
          
        end
        
        
        %% Destructor
        
        function delete(this)
            
            this.uiReticleAxes = [];
            this.uiWaferAxes = [];
            this.uiPOCurrent = [];
            
            this.msg('delete');
            % Clean up clock tasks
            
            % Delete the figure
            
            if ishandle(this.hParent)
                delete(this.hParent);
            end
                        
        end
        
        function ceReturn = refreshFcn(this)
            ceReturn = mic.Utils.dir2cell(this.cDirPrescriptions, 'date', 'descend', '*.json');
        end
        
        
                    

    end
    
    methods (Access = private)
        
        function init(this)
                  
            this.msg('init()');
            
            
            
            this.uiButtonClearPrescriptions = mic.ui.common.Button(...
                'cText', 'Clear Prescriptions', ...
                'fhOnClick', @this.onUiButtonClearPrescriptions ...
            );
        
            this.uiButtonClearWafer = mic.ui.common.Button(...
                'cText', 'Clear Wafer', ...
                'fhOnClick', @this.onUiButtonClearWafer ...
            );
        
            this.uibNewWafer = mic.ui.common.Button(...
                'cText', 'New', ...
                'fhOnClick', @this.onUiButtonNewWafer ...
            );
            this.uibAddToWafer = mic.ui.common.Button(...
                'cText', 'Add To Wafer', ...
                'fhOnClick', @this.onAddToWafer ...
            );
            % Prints from "Added" list
            this.uibPrint = mic.ui.common.Button(...
                'cText', 'Print', ...
                'fhOnClick', @this.onClickPrintActive ...
            );
        
            % Prints from "Saved Prescriptions" list
            this.uibPrintSaved = mic.ui.common.Button(...
                'cText', 'Print', ...
                'fhOnClick', @this.onClickPrintSaved ...
            );
        
            this.uiListActive = mic.ui.common.List(...
                'ceOptions', cell(1,0), ...
                'cLabel', 'Added prescriptions', ...
                'fhDirectCallback', @this.onListActiveChange, ...
                'lShowDelete', true, ...
                'lShowMove', true, ...
                'lShowLabel', true, ...
                'lShowRefresh', false ...
            );
            this.uicWaferLL = mic.ui.common.Checkbox(...
                'lChecked', false, ...
                'cLabel', 'Wafer to LL when done' ...
            );
            this.uicAutoVentAtLL = mic.ui.common.Checkbox(...
                'lChecked', false, ...
                'cLabel', 'Auto vent wafer at LL' ...
            );
            
            %{
            this.uibScanStart = mic.ui.common.Button( ...
                'cText', 'Start' ...
            );
        
            this.uitScanPause = mic.ui.common.Toggle( ...
                'cTextFalse', 'Pause', ...
                'cTextTrue', 'Resume' ...
            );
            
            this.uibScanAbort = mic.ui.common.Button(...
                'cText', 'Abort', ...
                'lAsk', true, ...
                'cMsg', 'The scan is now paused.  Are you sure you want to abort?' ... 
            );
            
            addlistener(this.uibScanAbort, 'ePress', @this.onButtonPressScanAbort);
            addlistener(this.uibScanAbort, 'eChange', @this.onButtonScanAbort);
            addlistener(this.uitScanPause, 'eChange', @this.onButtonScanPause);
            addlistener(this.uibScanStart, 'eChange', @this.onButtonScanStart);
            %}
            
            this.uiScan = mic.ui.Scan(...
                'dWidthBorderPanel', 0, ...
                'dWidth', this.dWidthUiScan, ...
                'cTitle', '', ...
                'dWidthButton', this.dWidthButton, ...
                'dHeightPadPanel', 0, ...
                'dWidthPadPanel', 0 ...
            );
            addlistener(this.uiScan, 'eStart', @this.onUiScanStart);
            addlistener(this.uiScan, 'ePause', @this.onUiScanPause);
            addlistener(this.uiScan, 'eResume', @this.onUiScanResume);
            addlistener(this.uiScan, 'eAbort', @this.onUiScanAbort);
            
            
            this.initScanSetContract();
            this.initScanAcquireContract();
            
            %{
            this.uiEditMjPerCm2PerSec = mic.ui.common.Edit(...
                'cLabel', 'mJ/cm2/s', ...
                'cType', 'd' ...
            );
            this.uiEditMjPerCm2PerSec.set(10);
            this.uiEditMjPerCm2PerSec.setMin(0);
            this.uiEditMjPerCm2PerSec.setMax(1e5);
            %}
            
            
            this.uiEditRowStart = mic.ui.common.Edit(...
                'cLabel', 'Row Start', ...
                'cType', 'u8' ...
            );
            this.uiEditRowStart.set(uint8(1));
            this.uiEditRowStart.setMin(uint8(0));
            
            this.uiEditColStart = mic.ui.common.Edit(...
                'cLabel', 'Col Start', ...
                'cType', 'u8' ...
            );
            this.uiEditColStart.set(uint8(1));
            this.uiEditColStart.setMin(uint8(0));
            
            
            this.uiShutter = bl12014.ui.Shutter(...
                'cName', [this.cName, 'shutter'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
            
            
            this.uiWaferAxes = bl12014.ui.WaferAxes(...
                'cName', [this.cName, 'wafer-axes'], ...
                'dWidth', 400, ...
                'dHeight', 400, ...
                'clock', this.uiClock, ...
                'fhGetIsShutterOpen', @() this.uiShutter.uiOverride.get(), ...
                'waferExposureHistory', this.waferExposureHistory, ...
                'fhGetXOfWafer', @() this.uiWafer.uiCoarseStage.uiX.getValCal('mm') / 1000, ...
                'fhGetYOfWafer', @() this.uiWafer.uiCoarseStage.uiY.getValCal('mm') / 1000, ...
                'fhGetXOfLsi', @() this.uiWafer.uiLsiCoarseStage.uiX.getValCal('mm') / 1000 ...
            );
        
            this.uiReticleAxes = bl12014.ui.ReticleAxes(...
                'cName', [this.cName, 'reticle-axes'], ...
                'dWidth', 400, ...
                'dHeight', 400, ...
                'clock', this.uiClock, ...
                'fhGetIsShutterOpen', @() this.uiShutter.uiOverride.get(), ...
                'fhGetX', @() this.uiReticle.uiCoarseStage.uiX.getValCal('mm') / 1000, ...
                'fhGetY', @() this.uiReticle.uiCoarseStage.uiY.getValCal('mm') / 1000 ...
            );
            
        
            this.uiPrescriptionTool = bl12014.ui.PrescriptionTool();
            this.uiPOCurrent = bl12014.ui.POCurrent(...
                'cName', [this.cName, 'po-current'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock, ...
                'dWidth', 780, ...
                'dHeight', 400 ...
            );
        
            
            
            this.uiSequenceLevelWafer = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-level-wafer'], ...
                'task', bl12014.Tasks.createSequenceLevelWafer(...
                    [this.cName, 'task-sequence-level-wafer'], ...
                    this.uiWafer.uiWaferTTZClosedLoop, ...
                    ...% this.uiWafer.uiWaferTTZClosedLoopuiHeightSensorLEDs, ...
                    this.clock ...
                 ), ...
                'clock', this.uiClock ...
            );
        
            
        
            this.uiSequenceLevelReticle = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-task-sequence-level-reticle'], ...
                'task', bl12014.Tasks.createSequenceLevelReticle(...
                    [this.cName, 'task-sequence-level-reticle'], ...
                    this.uiReticle.uiReticleTTZClosedLoop, ...
                    this.clock ...
                 ), ...
                'clock', this.uiClock ...
            );
        
            this.uiStateM142ScanningDefault = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-sequence-set-m142-to-default'], ...
                'task', bl12014.Tasks.createSequenceSetM142ToDefault(...
                    [this.cName, 'sequence-set-m142-to-default'], ...
                    this.uiScannerM142, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateUndulatorIsCalibrated = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-undulator-is-calibrated'], ...
                'task', bl12014.Tasks.createStateUndulatorIsCalibrated(...
                    [this.cName, 'state-undulator-is-calibrated'], ...
                    this.uiTuneFluxDensity, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
        
            this.uiStateMonoGratingAtEUV = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-mono-grating-at-euv'], ...
                'task', bl12014.Tasks.createStateMonoGratingAtEUV(...
                    [this.cName, 'state-mono-grating-at-euv'], ...
                    this.uiBeamline.uiGratingTiltX, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            this.uiStateExitSlitIsCalibrated = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-exit-slit-is-calibrated'], ...
                'task', bl12014.Tasks.createStateExitSlitIsCalibrated(...
                    [this.cName, 'state-exit-slit-is-calibrated'], ...
                    this.uiTuneFluxDensity, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
        
        
            this.uiTextReticleField = mic.ui.common.Text(...
                'cVal', 'Reticle Field: [--, --]' ...
            );
        
            this.uiClock.add(...
                @this.updateTextReticleField, ...
                [this.id(), '-update-text-reticle-field'], ...
                1 ...
            );
        
            this.uiClock.add(...
                @this.updateScannerPlots, ...
                [this.id(), '-update-scanner-plots'], ...
                1 ...
            );
        
            try
                this.hDYMO =  bl12014.hardwareAssets.middleware.DymoLabelWriter450();
            catch
                this.msg('DYMO labelwriter failed to initialize!!', this.u8_MSG_TYPE_SCAN);
            end
            
            this.uiTextTimeCalibrated = mic.ui.common.Text(...
                'cVal', 'Last Calibration:');
            this.uiTextFluxDensityCalibrated = mic.ui.common.Text(...
                'cVal', 'Flux Density: ');
            
            
            this.uiClock.add(...
                @this.updateTextsFluxCalibration, ...
                [this.id(), '-update-text-flux-calibration'], ...
                1 ...
            );
            
            
                       
        end
        
        
        function updateTextsFluxCalibration(this, src, evt)
            
            this.uiTextFluxDensityCalibrated.set(...
                sprintf('Flux Density: %1.1f mJ/cm2/s on %s', ...
                this.uiTuneFluxDensity.getFluxDensityCalibrated(), ...
                this.uiTuneFluxDensity.getTimeCalibrated() ...
            ));
            
        end
        
        function initScanSetContract(this)
            
             ceFields = {...
                'pupilFill', ...
                'reticleX', ...
                'reticleY', ...
                'waferX', ...
                'waferY', ...
                'waferZ', ...
                'xReticleFine', ...
                'yReticleFine', ...
                'workingMode', ...
            };

            for n = 1 : length(ceFields)
                this.stScanSetContract.(ceFields{n}).lRequired = false;
                this.stScanSetContract.(ceFields{n}).lIssued = false;
                this.stScanSetContract.(ceFields{n}).lAchieved = false;
            end
            
        end
        
        function initScanAcquireContract(this)
            
            ceFields = {...
                'shutter'
            };

            for n = 1 : length(ceFields)
                this.stScanAcquireContract.(ceFields{n}).lRequired = false;
                this.stScanAcquireContract.(ceFields{n}).lIssued = false;
            end
            
        end
        
        % For every field of this.stScanSetContract, set its lSetRequired and 
        % lSetIssued properties to false
        function resetScanSetContract(this)
            
            ceFields = fieldnames(this.stScanSetContract);
            for n = 1 : length(ceFields)
                this.stScanSetContract.(ceFields{n}).lRequired = false;
                this.stScanSetContract.(ceFields{n}).lIssued = false;
                this.stScanSetContract.(ceFields{n}).lAchieved = false;
            end
            
        end
        
        function resetScanAcquireContract(this)
            
            ceFields = fieldnames(this.stScanAcquireContract);
            for n = 1 : length(ceFields)
                this.stScanAcquireContract.(ceFields{n}).lRequired = false;
                this.stScanAcquireContract.(ceFields{n}).lIssued = false;
                this.stScanAcquireContract.(ceFields{n}).lAchieved = false;
            end
            
        end
        
        %{
        function onButtonScanStart(this, src, evt)
            
            this.msg('onButtonScanStart');
            
            this.hideScanStart();
            this.showScanPauseAbort();
            this.startNewScan();
                       
        end
        
        function onButtonScanPause(this, ~, ~)
        
            if (this.uitScanPause.get()) % just changed to true, so was playing
                this.scan.pause();
            else
                this.scan.resume();
            end
        end
        
        function onButtonPressScanAbort(this, ~, ~)
            this.scan.pause();
            this.uitScanPause.set(true);
        end
        
        function onButtonScanAbort(this, ~, ~)
            this.scan.stop(); % calls onScanAbort()
        end
        
        %}
        
        
        function onUiScanStart(this, src, evt)
            this.msg('onUiScanStart');
            this.startNewScan();
        end
        
        function onUiScanPause(this, ~, ~)
            this.scan.pause();
            this.updateUiScanStatus()

        end
        
        function onUiScanResume(this, ~, ~)
            this.scan.resume();
            this.updateUiScanStatus()

        end
        
        function onUiScanAbort(this, ~, ~)
            this.scan.stop(); % calls onScanAbort()
        end
        
        
        function printRecipe(this, stRecipe, cFile)
            
            % build strings:
            cFEMSize        = sprintf('[%d(F) X %d(D)]', stRecipe.fem.u8FocusNum, stRecipe.fem.u8DoseNum);
            ceWaferID        = regexp(cFile, '(?<=\\)\w*\d+\-\d+','match');
            cWaferID        = ceWaferID{1};
            cFocusString    = sprintf('%g / %g', stRecipe.fem.dFocusCenter, stRecipe.fem.dFocusStep);
            cDoseString     = sprintf('%g / %g', stRecipe.fem.dDoseCenter, stRecipe.fem.dDoseStep);
            cPEB            = sprintf('%gC / %gs', stRecipe.process.dResistPebTemp, stRecipe.process.dResistPebTime);
            cDev            = sprintf('%s - %gs / %s - %gs', stRecipe.process.cDevName, stRecipe.process.dDevTime, ...
                                                  stRecipe.process.cRinseName, stRecipe.process.dRinseTime);
            cResist         = sprintf('%s: %g nm', stRecipe.process.cResistName, stRecipe.process.dResistThick);
            
            % Set fields:
            % Not setting all fields here, can still set the following:
            % cField, cSublayer, cResistThickness, cPrescription,
            % cIllumination
            this.hDYMO.setField(...
                'cWaferID', cWaferID, ...
                'cSize',    cFEMSize, ...
                'cDose',    cDoseString, ...
                'cFocus',   cFocusString, ...
                'cPEB',     cPEB, ...
                'cDev',     cDev, ...
                'cResist',  cResist...
            )
        
            this.hDYMO.printLabel();
            
        end
        
        
        
        
        function onClickPrintActive(this, ~, ~)
            this.msg('Printing label on DYMO', this.u8_MSG_TYPE_SCAN);
           
            if isempty(this.hDYMO)
                msgbox('Cannot print label because DYMO failed to initialize');
                return
            end
            
            % Grab active prescriptions
            cFile = this.getPathRecipe();  
            [stRecipe, lError] = this.buildRecipeFromFile(cFile); 
            this.printRecipe(stRecipe, cFile);
            
            
        end
        
        function onClickPrintSaved(this, ~, ~)
            this.msg('Printing label on DYMO', this.u8_MSG_TYPE_SCAN);
           
            if isempty(this.hDYMO)
                msgbox('Cannot print label because DYMO failed to initialize');
                return
            end
            
            % Grab active prescriptions
            
            ceSelected = this.uiPrescriptionTool.uiListPrescriptions.get();
            
            if isempty(ceSelected)
                % Show alert
                
                cMsg = sprintf('Please select a prescription to print');
                cTitle = 'No prescription selected';
                msgbox(cMsg, cTitle, 'warn')    
                
                return
            end

            cFile = fullfile(this.uiPrescriptionTool.uiListPrescriptions.getDir(), ceSelected{1});
            [stRecipe, lError] = this.buildRecipeFromFile(cFile); 
            this.printRecipe(stRecipe, cFile);
            
            
        end
        
        function onUiButtonNewWafer(this, src, evt)
            
            % Purge all items from uiListActive
            this.uiListActive.setOptions(cell(1,0));
            
            this.waferExposureHistory.deleteExposures();
            this.waferExposureHistory.deleteFemPreviewScan();
            
        end
        
        function onUiButtonClearWafer(this, src, evt)
            
            
            
            this.waferExposureHistory.deleteExposures();
            this.waferExposureHistory.deleteFemPreviewScan();
            
        end
        
        function onUiButtonClearPrescriptions(this, src, evt)
            
            this.uiListActive.setOptions(cell(1,0));
            this.waferExposureHistory.deleteFemPreviewScan();

        end
        
        function onListActiveChange(this)
            
            this.addFemPreviewOfAllAddedPrescriptionsToWaferExposureHistory();
            
        end
        
        
        
        function onAddToWafer(this, src, evt)
                        
            % For all prescriptions highlihged when the user clicks 
            % "add to wafer", add them to ListActive 
            
            % ceSelected = this.uiListPrescriptions.get();
            
            ceSelected = this.uiPrescriptionTool.uiListPrescriptions.get();
            
            for k = 1:length(ceSelected)
                this.uiListActive.append(ceSelected{k});
            end
           
            this.addFemPreviewOfAllAddedPrescriptionsToWaferExposureHistory();
           
            
        end 
        
        function addFemPreviewOfAllAddedPrescriptionsToWaferExposureHistory(this)
            
            % Loop through all selected prescriptions and push them to the
            % active list
            
            this.waferExposureHistory.deleteFemPreviewScan();

            
            ceOptions = this.uiListActive.getOptions();
            for k = 1:length(ceOptions)
                
                % Read file, build recipe
                cFile = fullfile(this.cDirPrescriptions, ceOptions{k});
                [stRecipe, lError] = this.buildRecipeFromFile(cFile);
                
                [dX, dY] = this.getFemGrid(...
                    stRecipe.fem.dPositionStartX, ...
                    stRecipe.fem.dPositionStepX, ...
                    stRecipe.fem.u8DoseNum, ...
                    stRecipe.fem.dPositionStartY, ... 
                    stRecipe.fem.dPositionStepY, ...
                    stRecipe.fem.u8FocusNum ...
                );
                this.waferExposureHistory.addFemPreviewScan(dX, dY);
                    
            end
            
            
        end
        
        function [stRecipe, lError] = buildRecipeFromFile(this, cPath)
           
            cMsg = sprintf('buildRecipeFromFile: %s', cPath);
            this.msg(cMsg);
            
            lError = false;
            
            if strcmp('', cPath) || ...
                isempty(cPath)
                % Has not been set
                lError = true;
                stRecipe = struct();
                return;
            end
                        
            if exist(cPath, 'file') ~= 2
                % File doesn't exist
                lError = true;
                stRecipe = struct();
                
                cMsg = sprintf(...
                    'The recipe file %s does not exist.', ...
                    cPath ...
                );
                cTitle = sprintf('Error reading recipe');
                msgbox(cMsg, cTitle, 'warn')
                
                return;
            end
            
            % File exists
            
            %{
            cStatus = this.uitxStatus.cVal;
            this.uitxStatus.cVal = 'Reading recipe ...';
            drawnow;
            %}
            
            stRecipe = loadjson(cPath);
            
            % this.uitxStatus.cVal = cStatus;
            
            if ~this.validateRecipe(stRecipe)
                lError = true;
                return;
            end

        end
            
        
        
        
        function onScanSetState(this, stUnit, stValue)
            
            cFn = 'onScanSetState';
            lDebug = true;
            this.resetScanSetContract();
            
            % Update the stScanSetContract properties listed in stValue 
            
            ceFields = fieldnames(stValue);
            for n = 1 : length(ceFields)
                switch ceFields{n}
                    case {'task', 'type'}
                        % Do nothing
                    otherwise
                        this.stScanSetContract.(ceFields{n}).lRequired = true;
                        this.stScanSetContract.(ceFields{n}).lIssued = false;
                end
            end
            
            % Setting the state programatically does
            % exactly what would happen if the user were to do it manually
            % with the UI. I.E., we programatically update the UI and
            % programatically "click" UI buttons.
            
            for n = 1 : length(ceFields)
                
                cField = ceFields{n};
                                
                switch cField
                    
                    case 'workingMode'
                        
                        this.uiWafer.uiWorkingMode.uiWorkingMode.setDestCalDisplay(stValue.workingMode); 
                        this.uiWafer.uiWorkingMode.uiWorkingMode.moveToDest();
                        this.stScanSetContract.workingMode.lIssued = true;
                          
                    case 'xReticleFine'
                        
                        this.uiReticle.uiFineStage.uiX.setDestCalAndGo(stValue.xReticleFine, 'um');
                        this.stScanSetContract.xReticleFine.lIssued = true;
                    
                    case 'yReticleFine'
                        
                        this.uiReticle.uiFineStage.uiY.setDestCalAndGo(stValue.yReticleFine, 'um');
                        this.stScanSetContract.yReticleFine.lIssued = true;
                        
                    case 'waferX'
                        
                        % The FEM is constructed with positions relative to
                        % the center of the wafer in mm.  
                        % We need to tell the stage
                        % where to go to to make sure the EUV is at this 
                        % location on the wafer. Use
                        % uiWafer.uiAxes.dXChiefRay (mm)
                        % uiWafer.uiAxes.dYChiefRay (mm)
                        % to offset the stage correctly
                                    
                        dX = stValue.waferX + this.uiWafer.uiAxes.dXChiefRay * 1e3; % mm
                        this.uiWafer.uiCoarseStage.uiX.setDestCalDisplay(dX, 'mm');
                        this.uiWafer.uiCoarseStage.uiX.moveToDest(); % click
                        this.stScanSetContract.waferX.lIssued = true;
                        
                    case 'waferY'
                        
                        % See comment for waferX
                        
                        dY = stValue.waferY + this.uiWafer.uiAxes.dYChiefRay * 1e3; % mm
                        this.uiWafer.uiCoarseStage.uiY.setDestCalDisplay(dY, 'mm');
                        this.uiWafer.uiCoarseStage.uiY.moveToDest(); % click
                        this.stScanSetContract.waferY.lIssued = true;
                      
                    case 'waferZ'
                        
                       
                        % this.uiWafer.uiFineStage.uiZ.setDestCalDisplay(
%                         this.uiWafer.uiHeightSensorZClosedLoop.uiZHeightSensor.setDestCalDisplay(stValue.waferZ, stUnit.waferZ);
%                         this.uiWafer.uiHeightSensorZClosedLoop.uiZHeightSensor.moveToDest();
%                         
                        
                        % Changed RM 12/2018 to new CL architecture:
                        this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.setDestCalDisplay(stValue.waferZ, stUnit.waferZ);
                        this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.moveToDest();
                        this.stScanSetContract.waferZ.lIssued = true;
                        
                        
                        
                    case 'reticleX'
                        
                        % TEMPORARILY DONT MOVE 2018.04.19
                        % this.uiReticle.uiCoarseStage.uiX.setDestCalDisplay(dValue, cUnit);
                        % this.uiReticle.uiCoarseStage.uiX.moveToDest(); % click
                        this.stScanSetContract.(cField).lIssued = true;
                    
                    case 'reticleY'
                        
                        % this.uiReticle.uiCoarseStage.uiY.setDestCalDisplay(dValue, cUnit);
                        % this.uiReticle.uiCoarseStage.uiY.moveToDest(); % click
                        this.stScanSetContract.(cField).lIssued = true;
                    
                    case 'pupilFill'
                        % FIX ME
                        this.stScanSetContract.(cField).lIssued = true;
                        
                        %{

                        
                        % Load the saved structure associated with the pupil fill
                
                        cFile = fullfile( ...
                            this.cDirPupilFills, ...
                            stPre.uiPupilFillSelect.cSelected ...
                        );

                        if exist(cFile, 'file') ~= 0
                            load(cFile); % populates s in local workspace
                            stPupilFill = s;
                        else
                            this.abort(sprintf('Could not find pupilfill file: %s', cFile));
                            return;
                        end
                        if ~this.uiPupilFill.np.setWavetable(stPupilFill.i32X, stPupilFill.i32Y);

                            cQuestion   = ['The nPoint pupil fill scanner is ' ...
                                'not enabled and not scanning the desired ' ...
                                'pupil pattern.  Do you want to run the FEM anyway?'];

                            cTitle      = 'nPoint is not enabled';
                            cAnswer1    = 'Run FEM without pupilfill.';
                            cAnswer2    = 'Abort';
                            cDefault    = cAnswer2;

                            qanswer = questdlg(cQuestion, cTitle, cAnswer1, cAnswer2, cDefault);
                            switch qanswer
                                case cAnswer1;

                                otherwise
                                    this.abort('You stopped the FEM because the nPoint is not scanning.');
                                    return; 
                            end

                        end
                        %}
                        
                    otherwise
                        % do nothing
                        
                end % switch cField 
                
                if lDebug
                    this.msg(sprintf('%s setting %s', cFn, cField), this.u8_MSG_TYPE_SCAN);
                end
            end % loop through fields
        end
        
        
        
        
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the system is at the state


        function lOut = onScanIsAtState(this, stUnit, stValue)
            
            
            % The complexity of setState(), i.e., lots of 
            % series operations vs. one large parallel operation, dictates
            % how complex this needs to be.  I decided to implement a
            % general approach that will work for the case of complex
            % serial operations.  The idea is that each device (HIO) is
            % wrapped with a lSetRequired and lSetIssued {locical} property.
            %
            % The beginning of setState(), loops through all devices
            % that will be controlled and sets the lSetRequired flag ==
            % true for each one and false for non-controlled devices.  It also sets 
            % lSetIssued === false for all controlled devices.  
            %
            % Once a device move is commanded, the lSetIssued flag is set
            % to true.  These two flags provide a systematic way to check
            % isAtState: loop through all devices being controlled and only
            % return true when every one that needs to be moved has had its
            % move issued and also has isThere / lReady === true.
            
            % Ryan / Antine you might know a better way to do this nested
            % loop / conditional but I wanted readability and debugginb so
            % I made it verbose
            
            this.updateUiScanStatus()
            
            
            cFn = 'onScanIsAtState';
            lDebug = true;           
            lOut = true;
                        
            ceFields= fieldnames(stValue);
            
            for n = 1:length(ceFields)
                
                cField = ceFields{n};
                
                switch cField
                    case {'task', 'type'}
                        continue;
                end               
                
                if this.stScanSetContract.(cField).lRequired
                    if lDebug
                        this.msg(sprintf('%s %s set is required', cFn, cField), this.u8_MSG_TYPE_SCAN);
                    end

                    if this.stScanSetContract.(cField).lIssued
                        
                        if lDebug
                            this.msg(sprintf('%s %s set has been issued', cFn, cField), this.u8_MSG_TYPE_SCAN);
                        end
                        
                        if this.stScanSetContract.(cField).lAchieved
                            
                            if lDebug
                                this.msg(sprintf('% %s set has been achieved', cFn, cField), this.u8_MSG_TYPE_SCAN);
                            end
                            
                            continue % no need to check this property
                        end
                        
                        % Check if the set operation is complete
                        
                        lReady = true;
                        
                        if ~isempty(stValue.(cField))
                            
                            switch cField
                                case 'pupilFill'
                                    % FIX ME
                                    lReady = true;

                                case 'xReticleFine'
                                    lReady =    abs(this.uiReticle.uiFineStage.uiX.getValCal(stUnit.xReticleFine) - stValue.xReticleFine) <= this.dToleranceReticleFineX;
                                case 'yReticleFine'
                                    lReady =    abs(this.uiReticle.uiFineStage.uiY.getValCal(stUnit.yReticleFine) - stValue.yReticleFine) <= this.dToleranceReticleFineY;
                                case 'reticleX'
                                    lReady =    ... ~this.hardware.getDeltaTauPowerPmac().getIsStartedReticleCoarseXYZTipTilt();
                                                abs(this.uiReticle.uiCoarseStage.uiX.getValCal(stUnit.reticleX) - stValue.reticleX) <= this.dToleranceReticleX;
                                case 'reticleY'
                                    lReady =    ... ~this.hardware.getDeltaTauPowerPmac().getIsStartedReticleCoarseXYZTipTilt();
                                                abs(this.uiReticle.uiCoarseStage.uiY.getValCal(stUnit.reticleY) - stValue.reticleY) <= this.dToleranceReticleY;
                                case 'waferX'
                                    lReady =    ... ~this.hardware.getDeltaTauPowerPmac().getIsStartedWaferCoarseXYZTipTilt();
                                                abs(this.uiWafer.uiCoarseStage.uiX.getValCal(stUnit.waferX) - this.uiWafer.uiAxes.dXChiefRay * 1e3 - stValue.waferX) <= this.dToleranceWaferX;
                                case 'waferY'
                                    lReady =    ...~this.hardware.getDeltaTauPowerPmac().getIsStartedWaferCoarseXYZTipTilt();
                                                abs(this.uiWafer.uiCoarseStage.uiY.getValCal(stUnit.waferY) - this.uiWafer.uiAxes.dYChiefRay * 1e3 - stValue.waferY) <= this.dToleranceWaferY;
                                case 'waferZ'
                                   lReady =     ... (   ~this.hardware.getDeltaTauPowerPmac().getIsStartedWaferCoarseXYZTipTilt() && ...
                                                ... ~this.hardware.getDeltaTauPowerPmac().getIsStartedWaferFineZ);
                                                this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.getDevice().isReady();
                                                ...abs(this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.getValCal(stUnit.waferZ) - stValue.waferZ) <= this.dToleranceWaferZ;

                                case 'workingMode'

                                    lReady = this.uiWafer.uiWorkingMode.uiWorkingMode.getValCalDisplay() == stValue.workingMode;                               



                                otherwise

                                    % UNSUPPORTED

                            end
                            
                        end
                        
                        
                        if lReady
                            
                            this.stScanSetContract.(cField).lAchieved = true;
                        	
                            if lDebug
                                %this.msg(sprintf('%s %s set operation complete', cFn, cField), this.u8_MSG_TYPE_SCAN);
                            end
 
                        else
                            % still isn't there.
                            if lDebug
                                %this.msg(sprintf('%s %s is still setting to %1.3f', cFn, cField, stValue.(cField)), this.u8_MSG_TYPE_SCAN);
                            end
                            lOut = false;
                            return;
                        end
                    else
                        % need to move and hasn't been issued.
                        if lDebug
                            %this.msg(sprintf('%s %s set not yet issued', cFn, cField), this.u8_MSG_TYPE_SCAN);
                        end
                        
                        lOut = false;
                        return;
                    end                    
                else
                    
                    if lDebug
                        this.msg(sprintf('%s %s N/A', cFn, cField), this.u8_MSG_TYPE_SCAN);
                    end
                   % don't need to move, this param is OK. Don't false. 
                end
            end
        end
        
        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state (possibly contains 
        % information about the task to execute during acquire)
        function onScanAcquire(this, stUnit, stValue)
            
            this.resetScanAcquireContract();
            
            % If stValue does not have a "task" or "action" prop, return
            
            if ~isfield(stValue, 'task')
                return
            end
            
            
            
            % Should eventually have a "type" property associated with the
            % task that can be switched on.  "type", "data" which is a
            % struct.  
            % 
            % One type would be "exposure"
            
            this.stScanAcquireContract.shutter.lRequired = true;
            this.stScanAcquireContract.shutter.lIssued = false;
            

            % Pause before the exposure to let resonant motion settle
            
            if isfield(stValue.task, 'pausePreExpose')
                
                dTimeStart = tic;
                dTimeElapsed = 0;
                
                while dTimeElapsed < stValue.task.pausePreExpose
                    dTimeElapsed = toc(dTimeStart);
                    pause(1);
                    fprintf('bl12014.ui.Scan.onScanAcquire() pausing %1.1f sec of %1.1f sec\n', ...
                        dTimeElapsed, ...
                        stValue.task.pausePreExpose ...
                    );
                end
            
            end            

            % Calculate the exposure time
            % dSec = stValue.task.dose / this.uiTuneFluxDensity.getFluxDensityCalibrated();
            dSec = stValue.task.dose / this.uiTuneFluxDensity.getFluxDensityCalibrated();
            
            % Set the shutter UI time (ms)
            this.uiShutter.uiShutter.setDestCal(...
                dSec * 1e3, ...
                'ms' ...
            );
            % Trigger the shutter UI
            this.uiShutter.uiShutter.moveToDest();
            
           
            this.stScanAcquireContract.shutter.lIssued = true;
            
            
            if isfield(stValue, 'task')
                % Store the state of the system
                stState = this.getState(stUnit);
                stState.dose_mj_per_cm2 = stValue.task.dose;
                this.ceValues{this.scan.u8Index} = stState;
            end
            
        end

        % @param {struct} stUnit - the unit definition structure 
        % @param {struct} stState - the state
        % @returns {logical} - true if the acquisition task is complete
        function lOut = onScanIsAcquired(this, stUnit, stValue)

            cFn = 'onScanIsAcquired';
            lDebug = true;           
            lOut = true;
            
            if ~isfield(stValue, 'task')
                return
            end
                        
            ceFields= fieldnames(this.stScanAcquireContract);
            
            for n = 1:length(ceFields)
                
                cField = ceFields{n};
                
                if this.stScanAcquireContract.(cField).lRequired
                    if lDebug
                        this.msg(sprintf('%s %s set is required', cFn, cField));
                    end

                    if this.stScanAcquireContract.(cField).lIssued
                        
                        if lDebug
                            this.msg(sprintf('%s %s set has been issued', cFn, cField));
                        end
                        
                        % Check if the set operation is complete
                        
                        lReady = true;
                        
                        switch cField
                            case 'shutter'
                                
                               
                               lReady = this.uiShutter.uiShutter.getDevice().isReady();
                                 
                            otherwise
                                
                                % UNSUPPORTED
                                
                        end
                        
                        
                        if lReady
                        	if lDebug
                                this.msg(sprintf('%s %s set complete', cFn, cField));
                            end
 
                        else
                            % still isn't there.
                            if lDebug
                                this.msg(sprintf('%s %s set still setting', cFn, cField));
                            end
                            lOut = false;
                            return;
                        end
                    else
                        % need to move and hasn't been issued.
                        if lDebug
                            this.msg(sprintf('%s %s set not yet issued', cFn, cField));
                        end
                        
                        lOut = false;
                        return;
                    end                    
                else
                    
                    if lDebug
                        this.msg(sprintf('%s %s set is not required', cFn, cField));
                    end
                   % don't need to move, this param is OK. Don't false. 
                end
            end
            
            if lOut
                
                % Write to log

                this.writeToLog('Finished task.');

                % Add an exposure to the plot
                %{
                dExposure = [ ...
                    stValue.waferX ...
                    stValue.waferY ...
                    stValue.task.femCol ...
                    stValue.task.femCols ...
                    stValue.task.femRow ...
                    stValue.task.femRows ...
                ]
                %}
                
                % Needs units of m
                
                % Could also use stValue.waferX / 1000, stValue.waferY / 1000
                dExposure = [
                    this.uiWafer.uiAxes.dXChiefRay - this.uiWafer.uiCoarseStage.uiX.getValCal('mm') / 1000 ...
                    this.uiWafer.uiAxes.dYChiefRay - this.uiWafer.uiCoarseStage.uiY.getValCal('mm') / 1000 ...
                    stValue.task.femCol ...
                    stValue.task.femCols ...
                    stValue.task.femRow ...
                    stValue.task.femRows ...
                ];
                this.waferExposureHistory.addExposure(dExposure);
            
                
                % Overwrite the results file
                this.saveScanResults(stUnit);
                
                % 2018.11.15  
                this.saveDmiHeightSensorDataFromExposure(stValue)
                
            end
        end

        % Save 1 kHz DMI data collected during the shutter is open
        function saveDmiHeightSensorDataFromExposure(this, stValue)
            
            try
                dSec = stValue.task.dose / this.uiTuneFluxDensity.getFluxDensityCalibrated();
                dSamples = round(dSec * 1000);
                
                cPath = fullfile(...
                    this.cDirScan, ... 
                    this.getNameOfDmiHeightSensorLogFile(stValue) ...
                );
                this.uiMfDriftMonitorVibration.saveLastNSamplesToFile(dSamples, cPath)
            
            catch mE
                fprintf('saveDmiHeightSensorDataFromExposure error');
            end
            

        end
        
        function onScanAbort(this, stUnit)
             this.saveScanResults(stUnit, true);
             this.abort();
             
             
             
        end


        function onScanComplete(this, stUnit)
              this.saveScanResults(stUnit);
             this.uiScan.reset();
             this.updateUiScanStatus();
             
             
             this.uiListActive.setOptions({});
             
             cMsg = sprintf('FEM is complete. The list of added prescriptions has been purged.');
            cTitle = 'Success';
            cIcon = 'none';
            msgbox(cMsg, cTitle, cIcon)  
             
        end
        
        function startNewScan(this)
            
            this.msg('startFEM');
                       
            % Pre-FEM Check
            
            if ~this.preCheck()
                this.msg('failed preCheck() returning from startNewScan()');
                this.uiScan.reset();
                return
            end
            
            % At this point, we have passed all pre-checks and want to
            % actually start moving motors and such.  The experiment/FEM
            % will now begin
            
            % Store all of the selected items in uiListActive into a temporary
            % cell 
            
                       
            % Create new log file
            
            this.createNewLog();
            
            % Tell grating and undulator to go to correct place.
            % *** TO DO ***
                        
            % Loop through prescriptions (k, l, m)
            
            % for k = 1:length(this.cePrescriptions)
            
                % Build the recipe from .json file (we dogfood our own .json recipes always)
                
                cFile = this.getPathRecipe();  
                
                % Create a new folder to save results
                this.cDirScan = this.getDirScan();
                

                [stRecipe, lError] = this.buildRecipeFromFile(cFile); 
                                
                % Figure out number of skipped states.  Assumes FEM does column 
                % by column and that rows per column is number of focus.
                if stRecipe.fem.u8DoseNum < this.uiEditColStart.get()
                    this.abort('The start column is larger than the number of dose colums in the FEM')
                    return 
                end

                if stRecipe.fem.u8FocusNum < this.uiEditRowStart.get()
                    this.abort('The start row is larger than the number of focus rows in the FEM')
                    return 
                end
            
                stRecipe = this.getRecipeModifiedForSkippedColsAndRows(stRecipe);
                
                if lError 
                    this.abort('There was an error building the scan recipe from the .json file.');
                    return;
                end
                
                this.ceValues = cell(size(stRecipe.values));
                
                this.scan = mic.Scan(...
                    'ui-fem-scan', ...
                    this.clock, ...
                    stRecipe, ...
                    @this.onScanSetState, ...
                    @this.onScanIsAtState, ...
                    @this.onScanAcquire, ...
                    @this.onScanIsAcquired, ...
                    @this.onScanComplete, ...
                    @this.onScanAbort, ...
                    0.25 ... % Need larger than the PPMAC cache period of 0.2 s
                );
                
                this.scan.start();
            % end
            
        end
        
        
        
        
       
        
        function abort(this, cMsg)
                           
            if exist('cMsg', 'var') ~= 1
                cMsg = 'The FEM was aborted.';
            end
            
            this.uiListActive.setOptions({});
             
            cMsg = sprintf('The FEM was aborted. The list of added prescriptions has been purged.');
            cTitle = 'Fem Aborted';
            cIcon = 'help';
            h = msgbox(cMsg, cTitle, cIcon, 'modal');  
            
            % wait for them to close the message
            % uiwait(h);
            
            this.msg(sprintf('The FEM was aborted: %s', cMsg));
            
            % Write to logs.
            this.writeToLog(sprintf('The FEM was aborted: %s', cMsg));

            this.uiScan.reset();
            
        end
        
        function createNewLog(this)
            
            % Close existing log file
            
        end
        
        function writeToLog(this, cMsg)
            
            
        end
        
        function lReturn = preCheck(this)
           
            
            this.msg('preCheck');
            % Make sure at least one prescription is selected
            
            if (isempty(this.uiListActive.get()))
                this.abort('No prescriptions were added. Please add a prescription before starting the FEM.');
                lReturn = false;
                return;
            end
            
            % Verify that DMIs are zeroed:
            this.uiMFDriftMonitor.apiDriftMonitor.setDMIZero();
            
            
            % Make sure the shutter is not open (this happens when it is
            % manually overridden)
            
            %{
            if(this.shutter.lOpen)
                this.abort('The shutter is open.  Please make sure that it is not manually overridden');
                lReturn = false;
                return; 
            end
            %}
            
            % Make sure all valves that get light into the tool are open
            % *** TO DO ***
            
            
            % Check that every single hardware instance that I will control 
            % is active
            
            
            cMsg = '';
            
            % Shutter
            
            if ~this.hardware.getIsConnectedRigolDG1000Z()
                cMsg = sprintf('%s\n%s', cMsg, 'Rigol DG100Z (Shutter Signal Generator)');
            end
            
            % PPMAC
            if ~this.hardware.getIsConnectedDeltaTauPowerPmac()
                cMsg = sprintf('%s\n%s', cMsg, 'PPMAC (Reticle + Wafer Stages)');
            end
            
            % MF Drift Monitor Middleware
            if ~this.hardware.getIsConnectedMfDriftMonitorMiddleware()
                cMsg = sprintf('%s\n%s', cMsg, 'MF Drift Monitor Middleware (Height Sensor + DMI)');
            end

            if ~strcmp(cMsg, '')
                
                cQuestion   = sprintf( ...
                    ['The following device UI controls are virtualized (not active):' ...
                    '\n %s \n\n' ...
                    'Do you want to continue running the FEM with virtual devices?'], ...
                    cMsg ...
                );
                
                cTitle      = 'Some UI controls are virtualized';
                cAnswer1    = 'Run FEM with virtual hardware';
                cAnswer2    = 'Abort';
                cDefault    = cAnswer2;

                qanswer = questdlg(cQuestion, cTitle, cAnswer1, cAnswer2, cDefault);
                switch qanswer
                    case cAnswer1;

                    otherwise
                        this.abort('You stopped the FEM because some hardware was virtualized.');
                        lReturn = false;
                        return; %  exit startFEM() method
                end
            end
            
            
            % Throw up the "Run preseciption(s) ______?" dialog box
                        
            cQuestion   = sprintf( ...
                ['You are about to run the following prescriptions: ' ...
                '\n\n\t\t\t--%s\n\n is that OK?'], ...
                strjoin(this.uiListActive.get(), '\n\t\t\t--') ...
            );
            cTitle      = 'Confirm prescriptions';
            cAnswer1    = 'Run FEM';
            cAnswer2    = 'Abort';
            cDefault    = cAnswer1;
            
            qanswer = questdlg(cQuestion, cTitle, cAnswer1, cAnswer2, cDefault);
           
            switch qanswer
                case cAnswer1
                    lReturn = true;
                    return;
                otherwise
                    this.abort('You elected not to run the prescription(s) you had queued.');
                    lReturn = false;
                    return; %  exit startFEM() method
            end
            
            
        end
        
                

        
        
        
        
        function lReturn = shIsClosed(this)
            
            lReturn = ~this.shutter.lOpen;
            
        end
        
        
        
        
        function lOut = validateRecipe(this, stRecipe)
            % FIX ME
            lOut = true;            
        end
        
        function [dX, dY] = getFemGrid(this, dXStart, dXStep, u8NumDose, dYStart, dYStep, u8NumFocus)
            
            dX = dXStart : dXStep : dXStart + (double(u8NumDose) - 1) * dXStep;
            dY = dYStart : dYStep : dYStart + (double(u8NumFocus) - 1) * dYStep;
            
            [dX, dY] = meshgrid(dX * 1e-3, dY * 1e-3);
        end
        
        function updateUiScanStatus(this)
           this.uiScan.setStatus(this.scan.getStatus()); 
        end
        
        
        
        
        function saveScanResults(this, stUnit, lAborted)
            this.msg('saveScanResults()');
            
            if nargin <3
                lAborted = false;
            end
            this.saveScanResultsJson(stUnit, lAborted);
            this.saveScanResultsCsv(stUnit, lAborted);
        end
        
        function saveScanResultsJson(this, stUnit, lAborted)
       
            this.msg('saveScanResultsJson()');
             
            switch lAborted
                case true
                    cName = 'result-aborted.json';
                case false
                    cName = 'result.json';
            end
            
            cPath = fullfile(...
                this.cDirScan, ... 
                cName ...
            );
        
            stResult = struct();
            stResult.recipe = this.getPathRecipe();
            stResult.unit = stUnit;
            stResult.values = this.ceValues;
            
            stOptions = struct();
            stOptions.FileName = cPath;
            stOptions.Compact = 0;
            
            
            savejson('', stResult, stOptions);     

        end
        
        
        function saveScanResultsCsv(this, stUnit, lAborted)
        
            this.msg('saveScanResultsCsv()');
            
            switch lAborted
                case true
                    cName = 'result-aborted.csv';
                case false
                    cName = 'result.csv';
            end
            
            cPath = fullfile(...
                this.cDirScan, ... 
                cName ...
            );
            
            if isempty(this.ceValues)
                return
            end
            
            % Open the file
            fid = fopen(cPath, 'w');

            % Write the header
            % Device
            % fprintf(fid, '# "%s"\n', this.uiPopupRecipeDevice.get().cValue);
            
            % Write the field names
            ceNames = {...
                'als_current_ma', ...
                'exit_slit_um', ...
                'undulator_gap_mm', ...
                'wavelength_nm', ...
                'x_reticle_coarse_mm', ...
                'y_reticle_coarse_mm', ...
                'z_reticle_coarse_mm', ...
                'tilt_x_reticle_coarse_urad', ...
                'tilt_y_reticle_coarse_urad', ...
                'x_reticle_fine_nm', ...
                'y_reticle_fine_nm', ...
                'x_wafer_coarse_mm', ...
                'y_wafer_coarse_mm', ...
                'z_wafer_coarse_mm', ...
                'tilt_x_wafer_coarse_urad', ...
                'tilt_y_wafer_coarse_urad', ...
                'z_wafer_fine_nm', ...
                'z_height_sensor_nm', ...
                'shutter_ms', ...
                'flux_mj_per_cm2_per_s', ...
                'time' ...
            };
            for n = 1:length(ceNames)
                fprintf(fid, '%s,', ceNames{n});
            end
            fprintf(fid, '\n');

            % Write values
            for n = 1 : length(this.ceValues)
                stValue = this.ceValues{n};
                if ~isstruct(stValue)
                    continue
                end
                ceNames = fieldnames(stValue);
                for m = 1 : length(ceNames)
                    switch ceNames{m}
                        case 'time'
                            fprintf(fid, '%s,', stValue.(ceNames{m}));
                        otherwise
                            fprintf(fid, '%1.3e,', stValue.(ceNames{m}));
                    end
                end
                fprintf(fid, '\n');
            end

            % Close the file
            fclose(fid);

        end
        
        % @param {struct} stValue - state value structure 
        function c = getNameOfDmiHeightSensorLogFile(this, stValue)
            
            % num of rows per col * current col = elapsed colums
            % then add current row
            dShot =  stValue.task.femRows * (stValue.task.femCol - 1) + stValue.task.femRow;
                
            %{
            c = sprintf(...
                [...
                    '%03d-', ...
                    'dose%02d-', ...
                    'focus%02d-', ...
                    '1kHz-DMI-HS-data-', ...
                    '%s.txt' ...
                ], ...
                dShot, ...
                stValue.task.femCol, ...
                stValue.task.femRow, ...
                datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local') ...
            );
            %}
        
            c = sprintf(...
                [...
                    '%s-', ...
                    'dose%02d-', ...
                    'focus%02d-', ...
                    '1kHz-DMI-HS-data.txt' ...
                ], ...
                datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local'), ...
                stValue.task.femCol, ...
                stValue.task.femRow ...
            );
        
        end
        
        function c = getDirScan(this)
            
            % Get name of recipe
            [cPath, cName, cExt] = fileparts(this.getPathRecipe());
            
            c = sprintf('%s__PRE_%s', ...
                datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local'), ...
                cName ...
            );
        
            c = fullfile(this.cDirSave, c);
            c = mic.Utils.path2canonical(c);
            mic.Utils.checkDir(c);
            
        end
        
        
        function c = getPathRecipe(this)
            
            cePrescriptions = this.uiListActive.get();
%             c = fullfile(...
%                 this.cDirPrescriptions, ...
%                 cePrescriptions{1} ...
%             );

            c = fullfile(...
                this.uiPrescriptionTool.uiListPrescriptions.getDir(), ...
                cePrescriptions{1} ...
            );

                
        end
        
        
        function st = getState(this, stUnit)
            
        	st = struct();
            
            st.als_current_ma = 500; % FIX ME
            st.exit_slit_um = this.uiBeamline.uiExitSlit.uiGap.getValCal('um');
            st.undulator_gap_mm = this.uiBeamline.uiUndulatorGap.getValCal('mm');
            st.wavelength_nm = this.uiBeamline.uiGratingTiltX.getValCal('wav (nm)');
            
            st.x_reticle_coarse_mm = this.uiReticle.uiCoarseStage.uiX.getValCal('mm');
            st.y_reticle_coarse_mm = this.uiReticle.uiCoarseStage.uiY.getValCal('mm');
            st.z_reticle_coarse_mm = this.uiReticle.uiCoarseStage.uiZ.getValCal('mm');
            st.tilt_x_reticle_coarse_urad = this.uiReticle.uiCoarseStage.uiTiltX.getValCal('urad');
            st.tilt_y_reticle_coarse_urad = this.uiReticle.uiCoarseStage.uiTiltY.getValCal('urad');
            
            [dTiltX, dTiltY, dZ] =  this.uiReticle.uiMod3CapSensors.getTiltXAndTiltYAndZ(); % returns deg
            st.tilt_x_reticle_cap_urad = dTiltX * pi / 180 * 1e6;
            st.tilt_y_reticle_cap_urad = dTiltY * pi / 180 * 1e6;
            st.z_reticle_cap_um = dZ;
            
            st.cap_1_reticle_V = this.uiReticle.uiMod3CapSensors.uiCap1.getValCal('V');
            st.cap_2_reticle_V = this.uiReticle.uiMod3CapSensors.uiCap2.getValCal('V');
            st.cap_3_reticle_V = this.uiReticle.uiMod3CapSensors.uiCap3.getValCal('V');
            st.cap_4_reticle_V = this.uiReticle.uiMod3CapSensors.uiCap4.getValCal('V');
            
            st.cap_1_reticle_um = this.uiReticle.uiMod3CapSensors.uiCap1.getValCal('um');
            st.cap_2_reticle_um = this.uiReticle.uiMod3CapSensors.uiCap2.getValCal('um');
            st.cap_3_reticle_um = this.uiReticle.uiMod3CapSensors.uiCap3.getValCal('um');
            st.cap_4_reticle_um = this.uiReticle.uiMod3CapSensors.uiCap4.getValCal('um');

            st.x_reticle_fine_nm = this.uiReticle.uiFineStage.uiX.getValCal('nm');
            st.y_reticle_fine_nm = this.uiReticle.uiFineStage.uiY.getValCal('nm');
            
            st.x_wafer_coarse_mm = this.uiWafer.uiCoarseStage.uiX.getValCal('mm');
            st.y_wafer_coarse_mm = this.uiWafer.uiCoarseStage.uiY.getValCal('mm');
            st.z_wafer_coarse_mm = this.uiWafer.uiCoarseStage.uiZ.getValCal('mm');
            st.tilt_x_wafer_coarse_urad = this.uiWafer.uiCoarseStage.uiTiltX.getValCal('urad');
            st.tilt_y_wafer_coarse_urad = this.uiWafer.uiCoarseStage.uiTiltY.getValCal('urad');
            
            % TODO add mfdriftmon middleware foce update call
            st.tilt_x_wafer_height_sensor_urad = this.uiWafer.uiWaferTTZClosedLoop.uiCLTiltX.getValCal('urad');
            st.tilt_y_wafer_height_sensor_urad = this.uiWafer.uiWaferTTZClosedLoop.uiCLTiltY.getValCal('urad');
            
            [dTiltX, dTiltY] =  this.uiWafer.uiPobCapSensors.getTiltXAndTiltYWithoutSensor4(); % returns deg
            st.tilt_x_wafer_cap_urad = dTiltX * pi / 180 * 1e6;
            st.tilt_y_wafer_cap_urad = dTiltY * pi / 180 * 1e6;
            
            st.cap_1_wafer_V = this.uiWafer.uiPobCapSensors.uiCap1.getValCal('V');
            st.cap_2_wafer_V = this.uiWafer.uiPobCapSensors.uiCap2.getValCal('V');
            st.cap_3_wafer_V = this.uiWafer.uiPobCapSensors.uiCap3.getValCal('V');
            st.cap_4_wafer_V = this.uiWafer.uiPobCapSensors.uiCap4.getValCal('V');
            
            st.cap_1_wafer_um = this.uiWafer.uiPobCapSensors.uiCap1.getValCal('um');
            st.cap_2_wafer_um = this.uiWafer.uiPobCapSensors.uiCap2.getValCal('um');
            st.cap_3_wafer_um = this.uiWafer.uiPobCapSensors.uiCap3.getValCal('um');
            st.cap_4_wafer_um = this.uiWafer.uiPobCapSensors.uiCap4.getValCal('um');
            
            st.z_wafer_fine_nm = this.uiWafer.uiFineStage.uiZ.getValCal('nm');
            st.z_height_sensor_nm = this.uiWafer.uiWaferTTZClosedLoop.uiCLZ.getValCal('nm');
            % st.z_height_sensor_cal_nm = this.hardware.getMfDriftMonitorMiddleware.
            
            
            % VIS
            st.z_encoder_1_vis_V = this.uiVibrationIsolationSystem.uiEncoder1.getValCal('Volts');
            st.z_encoder_2_vis_V = this.uiVibrationIsolationSystem.uiEncoder2.getValCal('Volts');
            st.z_encoder_3_vis_V = this.uiVibrationIsolationSystem.uiEncoder3.getValCal('Volts');
            st.z_encoder_4_vis_V = this.uiVibrationIsolationSystem.uiEncoder4.getValCal('Volts');
            st.z_encoder_1_vis_um = this.uiVibrationIsolationSystem.uiEncoder1.getValCal('um');
            st.z_encoder_2_vis_um = this.uiVibrationIsolationSystem.uiEncoder2.getValCal('um');
            st.z_encoder_3_vis_um = this.uiVibrationIsolationSystem.uiEncoder3.getValCal('um');
            st.z_encoder_4_vis_um = this.uiVibrationIsolationSystem.uiEncoder4.getValCal('um');
            [dTiltX, dTiltY] = this.uiVibrationIsolationSystem.getTiltXAndTiltY(); % returns deg
            st.tilt_x_vis_urad = dTiltX * pi / 180 * 1e6;
            st.tilt_y_vis_urad = dTiltY * pi / 180 * 1e6;
                        
            
            % st.z_height_sensor_nm = this.uiWafer.uiHeightSensorZClosedLoop.uiZHeightSensor.getDevice().getAveraged(); 
            st.shutter_ms = this.uiShutter.uiShutter.getDestCal('ms');
            st.flux_mj_per_cm2_per_s = this.uiTuneFluxDensity.getFluxDensityCalibrated();
            
            
            % st.temp_c_po_m2_0200 = this.hardware.getDataTranslation().measure_temperature_rtd(31, 'PT100');
            dData = this.hardware.getDataTranslation().getScanData();
            st.temp_c_po_m2_0200 = dData(31 + 1);
            st.time = datestr(datevec(now), 'yyyy-mm-dd HH:MM:SS', 'local');

        end
        
        function stRecipe = getRecipeModifiedForSkippedColsAndRows(this, stRecipe)
           
            
            dNumOfStatesSkipped = ...
                (this.uiEditColStart.get() - 1) * stRecipe.fem.u8FocusNum + ...
                (this.uiEditRowStart.get() - 1);
            
            ceValues = stRecipe.values;
            
            if dNumOfStatesSkipped > 0
                
                % Skip the first setup state
                ceValues = ceValues(2 : end);
                
                % Skip states
                for n = 1 : dNumOfStatesSkipped
                   ceValues = ceValues(2 : end); 
                end
            end
            
            stRecipe.values = ceValues;
            
        end
        
        function updateTextReticleField(this, src, evt)
            
            dRow = this.uiReticle.uiReticleFiducializedMove.uiRow.getValCalDisplay();
            dCol = this.uiReticle.uiReticleFiducializedMove.uiCol.getValCalDisplay();
            
    
            
            if ~isnumeric(dRow) || ...
               ~isscalar(dRow) || ...
               ~isnumeric(dCol) || ...
               ~isscalar(dCol)
                return
            end
            
            dErrorRow = dRow - round(dRow);
            dErrorCol = dCol - round(dCol);
            
            if abs(dErrorRow) < 0.01
                dRow = round(dRow);
            end
            if abs(dErrorCol) < 0.01
                dCol = round(dCol);
            end
            
            cNameOfField = 'Unknown';
            try
                cNameOfField = bl12014.getNameOfReticleField(...
                    'row', dRow, ...
                    'col', dCol ...
                );
                
            catch mE
                
                
            end
            
            cVal = sprintf(...
                'Retile Field: [row %1.1f, col %1.1f] = %s', ...
                dRow, ...
                dCol, ...
                cNameOfField ...
           );
           this.uiTextReticleField.set(cVal);
            
            
        end
        
        function updateScannerPlots(this, ~, ~)
            
            this.plotFieldFill();
            this.plotPupilFill();
            
        end
                          

    end 
    
    
end