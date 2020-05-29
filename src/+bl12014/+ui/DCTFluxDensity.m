classdef DCTFluxDensity < mic.Base
        
    properties (Constant)
       
        dWidth      = 700 %1295
        dHeight     = 600
        dWidthPanelBorder = 0
    end
    
	properties
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        uiStageWafer
        uiStageAperture
           
        uiDiode
        uiShutter
        uiUndulator
        uiExitSlit
        uiBeamline
                
        % Must pass in
        uiScannerM142
        uiScannerPlotDCT
        
        uiStateMonoGratingAtEUV
        uiStateWaferAtDiode
        uiStateApertureMatchesDiode
        uiStateShutterOpen
        uiStateM142ScanningDefault
        
        % {logical 1x1} true when save is aborted. rest to true when save
        % clicked
        lAbortSave
        
        uiButtonSave
        uiButtonCancelSave
        uiButtonConfirmSave
        uiButtonRedoSave
        
        hFigureSave
        hAxesSave
        hPlotSave
        uiTextSaveGapOfUndulator
        uiTextSaveGapOfExitSlit
        uiTextSaveValue
        uiTextSaveMean
        uiTextSaveStd
        uiTextSavePV
        uiProgressBarSave
        
        uiTextTimeCalibrated
        uiTextFluxDensityCalibrated
        uiTextGapOfUndulatorCalibrated
        uiTextGapOfExitSlitCalibrated
        uiTextApertureCalibrated
        
        
        hAxesFieldFill
        hPlotFieldFill
        
        dColorPlotFiducials = [0.3 0.3 0.3]
        
                
    end
    
    properties (SetAccess = private)
        
        cName = 'dct-flux-density-'
        
        % {struct 1x1} stores config date loaded from +bl12014/config/tune-flux-density-coordinates.json
        stConfig
        cDirSave
    end
    
    properties (Access = private)
                      
        clock
        uiClock
        dDelay = 0.5
        
        hProgress
        
        % {mic.Scan 1x1}
        scan
        
        % {bl12014.Hardware 1x1}
        hardware
        
        % {bl12014.DCTExposures}
        exposures
        
        dFluxDensityAcc = [] % accumulated during calibration
        dFluxDensityCalibrated = 0
        dGapOfUndulatorCalibrated = 40.24
        dGapOfExitSlitCalibrated = 300
        cApertureCalibrated = '25 mm'
        dtTimeCalibrated = 'Never';
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = DCTFluxDensity(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSave = fullfile( ...
                cDirThis, ...
                '..', ...
                '..', ...
                'save', ...
                'dct-flux-density' ...
            );
            
            % The reason we pass this in is because the grating has 
            % a relative offset and the architecture is set up so this is
            % on a UI by UI basis.
            
            %{
            if ~isa(this.uiGratingTiltX, 'mic.ui.device.GetSetNumber')
                error('uiGratingTiltX must be mic.ui.device.GetSetNumber');
            end
            %}
            
            
            if ~isa(this.uiScannerM142, 'bl12014.ui.Scanner')
                error('uiScannerM142 must be bl12014.ui.Scanner');
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock mic.ui.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            if ~isa(this.exposures, 'bl12014.DCTExposures')
                error('exposures must be bl12014.DCTExposures');
            end
            
            if ~isa(this.uiBeamline, 'bl12014.ui.Beamline')
                error('uiBeamline must be bl12014.ui.Beamline');
            end
            
            this.init();
            
        end
        
        % Returns mJ/cm2/s flux density value currently loaded / saved
        % @return {double 1x1} flux density in mJ/cm2/s
        function d = getFluxDensityCalibrated(this)
            d = this.dFluxDensityCalibrated;
        end
        
        % Returns gap of the undulator in mm that was set when the last
        % flux density calibration was performend and saved.  The gap of
        % the undulaotr will need to be this durin exposures
        % @return {double 1x1} gap of undulator in mm
        function d = getGapOfUndulatorCalibrated(this)
            d = this.dGapOfUndulatorCalibrated;
        end
        
        % Returns gap of the exit slit in um that was set when the last
        % flux density calibration was performend and saved.  The gap of
        % the exit slit will need to be this during exposures
        % @return {double 1x1} gap of exit slit in um
        function d = getGapOfExitSlitCalibrated(this)
            d = this.dGapOfExitSlitCalibrated;
        end
        
        % Returns aperture that was set when the last
        % flux density calibration was performend and saved.  
        % @return {char 1xm}
        function c = getApertureCalibrated(this)
            c = this.cApertureCalibrated;
        end
        
        % Returns {char 1xm} time yyyy-mm-dd--hh-mm-ss when the last 
        % flux density calibration was performed
        function c = getTimeCalibrated(this)
            c = this.dtTimeCalibrated;
        end
        
        function build(this, hParent, dLeft, dTop)
                    
            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', '',...
                'BorderWidth', this.dWidthPanelBorder, ...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
                        
            dLeft = 10;
            dTop = 15;
            dSep = 30;
            dPad = 10;
                        
            dWidthTask = 400;
            
            %{
            this.uiSequencePrep.build(hPanel, 10, dTop, 600);
            dTop = dTop + dSep;
            %}
            
            
            this.uiStateMonoGratingAtEUV.build(hPanel, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
            
            
            this.uiStateWaferAtDiode.build(hPanel, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
            
            this.uiStateApertureMatchesDiode.build(hPanel, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
            
            %{
            this.uiStateM142ScanningDefault.build(hPanel, 10, dTop, dWidthTask);
            dTop = dTop + dSep;
            %}
            
            this.uiStateShutterOpen.build(hPanel, 10, dTop, dWidthTask);
            dTop = dTop + dSep;   
            
           
            this.uiScannerPlotDCT.build(hPanel, 440, 10);
            
            dTop = dTop + 20;
                                    
            this.uiUndulator.build(hPanel, dLeft, dTop);
            dTop = dTop + 24 + dPad;
            
            this.uiExitSlit.build(hPanel, dLeft, dTop);
            dTop = dTop + this.uiExitSlit.dHeight + dPad;
            
            this.uiShutter.build(hPanel, dLeft, dTop);
            dTop = dTop + this.uiShutter.dHeight + dPad;
            
            this.uiDiode.build(hPanel, dLeft, dTop);
            
            this.buildCalibratePanel(hPanel, 350, dTop + 30);
            
            dTop = dTop + this.uiDiode.dHeight + dPad;
            
            this.buildSaveModal();
            
        end
        
        function buildCalibratePanel(this, hParent, dLeft, dTop)
            
            dSep = 25;
            dWidthText = 200;
            dHeightText = 14;
            dSep = 5;
            
            this.uiTextTimeCalibrated.build(hParent, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextFluxDensityCalibrated.build(hParent, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextGapOfUndulatorCalibrated.build(hParent, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextGapOfExitSlitCalibrated.build(hParent, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextApertureCalibrated.build(hParent, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            dTop = dTop + 20;
            
            this.uiButtonSave.build(hParent, dLeft, dTop, 300, 48);
            
        end
        
        
                        
        
        %% Destructor
        
        
        
        function delete(this)
            this.uiStageWafer = []; 
            this.uiStageAperture = []; 
            this.uiDiode = []; 
            this.uiExitSlit = []; 
            this.uiUndulator = []; 
            this.uiShutter = []; 
            this.uiStateMonoGratingAtEUV = []; 
            this.uiStateWaferAtDiode = []; 
            this.uiStateApertureMatchesDiode = []; 
            this.uiStateShutterOpen = []; 
            this.uiScannerPlotDCT = []; 
                        
        end
        
        function cec = getPropsSaved(this)
            cec = {...
                'uiDiode' ...
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
               
    end
    
    methods (Access = private)
        
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
        
        function onChangeDiodeAperture(this)
            
            this.exposures.setSizeOfApertureForScan(...
                this.uiDiode.uiPopupAperture.get().dWidth * 1e-3, ...
                this.uiDiode.uiPopupAperture.get().dHeight * 1e-3 ...
            );
        
            this.exposures.setSizeOfApertureForPre(...
                this.uiDiode.uiPopupAperture.get().dWidth * 1e-3, ...
                this.uiDiode.uiPopupAperture.get().dHeight * 1e-3 ...
            );
        
        end
        
        function init(this)
            
            this.msg('init()');
            
            this.uiStageWafer = bl12014.ui.DCTWaferStage(...
                'hardware', this.hardware, ...
                'cName', [this.cName, 'stage-wafer'], ...
                'clock', this.uiClock ...
            );
        
            this.uiStageAperture = bl12014.ui.DCTApertureStage(...
                'hardware', this.hardware, ...
                'cName', [this.cName, 'stage-aperture'], ...
                'clock', this.uiClock ...
            );
        
            this.uiDiode = bl12014.ui.DCTDiode(...
                'cName', [this.cName, 'diode-1'], ...
                'cTitle', 'Diode 1', ...
                'fhOnChangeAperture', @() this.onChangeDiodeAperture, ...
                'fhSetSensitivity', @(dLevel) this.hardware.getSR570DCT1().setSensitivity(dLevel), ...
                'fhGetVolts', @() this.hardware.getDataTranslation().getScanDataOfChannel(33), ...
                'clock', this.clock ...
            );
        
       
            this.uiExitSlit = bl12014.ui.ExitSlit(...
                'cName', [this.cName, 'exit-slit'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock);
            
            this.uiUndulator = bl12014.ui.Undulator(...
                'cName', [this.cName, 'undulator'], ...
                'hardware', this.hardware, ...
                'uiClock', this.uiClock ...
            );
            
            this.uiShutter = bl12014.ui.Shutter(...
                'cName', [this.cName, 'shutter'], ...
                'hardware', this.hardware, ...
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
                        
            this.uiStateWaferAtDiode = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-wafer-at-diode'], ...
                'task', bl12014.Tasks.createStateDCTWaferStageAtDiode(...
                    [this.cName, 'state-wafer-at-diode'], ...
                    this.uiStageWafer, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
        
            this.uiStateApertureMatchesDiode = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-dct-aperture-stage-matches-diode'], ...
                'task', bl12014.Tasks.createStateDCTApertureStageMatchesDiode(...
                    [this.cName, 'state-dct-aperture-stage-matches-diode'], ...
                    this.uiStageAperture, ...
                    this.uiDiode, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
            
        
            this.uiStateShutterOpen = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-shutter-is-open'], ...
                'task', bl12014.Tasks.createStateShutterIsOpen(...
                    [this.cName, 'state-shutter-is-open'], ...
                    this.uiShutter, ...
                    this.clock ...
                ), ...
                'lShowButton', true, ...
                'clock', this.uiClock ...
            );
        
            %{
            this.uiStateM142ScanningDefault = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-state-m142-is-scanning-default'], ...
                'task', bl12014.Tasks.createStateM142ScanningDefault(...
                    [this.cName, 'state-m142-is-scanning-default'], ...
                    this.uiScannerM142.uiNPointLC400, ...
                    this.clock ...
                ), ...
                'lShowButton', false, ...
                'clock', this.uiClock ...
            );
            %}
        
            this.uiButtonSave = mic.ui.common.Button(...
                'fhOnClick', @this.onClickSave, ...
                'cText', 'Record mJ/cm2/s and Save Calibration' ...
            );
        
            this.uiButtonCancelSave = mic.ui.common.Button(...
                'fhOnClick', @this.onClickCancelSave, ...
                'cText', 'Cancel' ...
            );
        
            this.uiButtonConfirmSave = mic.ui.common.Button(...
                'fhOnClick', @this.onClickConfirmSave, ...
                'cText', 'Save This Calibration' ...
            );
        
            this.uiButtonRedoSave = mic.ui.common.Button(...
                'fhOnClick', @this.onClickSave, ...
                'cText', 'Redo' ...
            );
            
            this.uiTextSaveGapOfUndulator = mic.ui.common.Text(...
                'cVal', 'Gap of Undulator', ...
                'dFontSize', 14, ...
                'cFontWeight', 'bold' ...
            );
            this.uiTextSaveGapOfExitSlit = mic.ui.common.Text(...
                'cVal', 'Gap of Exit Slit', ...
                'dFontSize', 14, ...
                'cFontWeight', 'bold' ...
            );
            this.uiTextSaveValue = mic.ui.common.Text(...
                'cVal', 'Value');
            this.uiTextSaveMean = mic.ui.common.Text(...
                'cVal', 'Mean', ...
                'dFontSize', 14, ...
                'cFontWeight', 'bold' ...
            );
            this.uiTextSaveStd = mic.ui.common.Text(...
                'cVal', 'Std');
            this.uiTextSavePV = mic.ui.common.Text(...
                'cVal', 'PV');
            this.uiProgressBarSave = mic.ui.common.ProgressBar();
        
            
            this.uiTextTimeCalibrated = mic.ui.common.Text(...
                'cVal', 'Last Calibration:');
            this.uiTextFluxDensityCalibrated = mic.ui.common.Text(...
                'cVal', 'Flux Density: ');
            this.uiTextGapOfUndulatorCalibrated = mic.ui.common.Text(...
                'cVal', 'Gap of Undulator:');
            this.uiTextGapOfExitSlitCalibrated = mic.ui.common.Text(...
                'cVal', 'Gap of Exit Slit:');
            
            this.uiTextApertureCalibrated = mic.ui.common.Text(...
                'cVal', 'Aperture:');
            
            
            this.uiScannerPlotDCT = bl12014.ui.ScannerPlotDCT(...
               'cName', [this.cName, 'scanner-plot-dct'], ...
                'uiClock', this.uiClock, ...
                'fhGetWidthOfAperture', @() this.uiDiode.uiPopupAperture.get().dWidth * 1e-3, ...
                'fhGetHeightOfAperture', @() this.uiDiode.uiPopupAperture.get().dWidth * 1e-3, ...
                'fhGetWavetables', @() this.uiScannerM142.uiNPointLC400.getWavetables(), ...
                'fhGetActive', @() this.uiScannerM142.uiNPointLC400.uiGetSetLogicalActive.get() ...
            );
        
            
            this.loadLastFluxCalibration();
        end
        

        function cancelSave(this)
            this.hideSaveModal();
            this.lAbortSave = true;
        end
        
        function hideSaveModal(this)
            
            
            if ~ishandle(this.hFigureSave)
                return
            end
            %{
            delete(this.hPlotSave);
            delete(this.hFigureSave)
            %}
            
            set(this.hFigureSave, 'Visible', 'off');
        end
        
        function buildSaveModal(this)
            
            
            % Build it the first time
            
            dWidthFigure = 500;
            dHeightFigure = 430;
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigureSave = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name', 'Averaging Flux Density for 10 Seconds',...
                'Position', [ ...
                (dScreenSize(3) - dWidthFigure)/2 ...
                (dScreenSize(4) - dHeightFigure)/2 ...
                dWidthFigure ...
                dHeightFigure ...
                ],... % left bottom width height
                'CloseRequestFcn', @this.onClickCancelSave, ... 
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                ... % 'CloseRequestFcn', @this.onCloseRequest, ...
                ... Default to not visible, show when user clicks "Save"
                'Visible', 'off'... % def
            );
                    
            dTop = 30;
            dLeft = 70;
            dWidthAxes = 400;
            dHeightAxes = 200;
            
            this.hAxesSave = axes(...
                'Parent', this.hFigureSave,...
                'Units', 'pixels',...
                'Position',mic.Utils.lt2lb([...
                    dLeft, ...
                    dTop, ...
                    dWidthAxes,...
                    dHeightAxes], this.hFigureSave),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                'DataAspectRatio',[1 1 1],...
                'HandleVisibility','on'...
           );
            dTop = dTop + dHeightAxes + 50;
            
            dTopTexts = dTop;
            dLeft = 30;
            dWidthText = 300;
            dHeightText = 20;
            dSep = 5;
            
            
            this.uiTextSaveMean.build(this.hFigureSave, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextSaveGapOfUndulator.build(...
                this.hFigureSave, ...
                dLeft, ...
                dTop, ...
                dWidthText, ...
                dHeightText ...
            );
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextSaveGapOfExitSlit.build(...
                this.hFigureSave, ...
                dLeft, ...
                dTop, ...
                dWidthText, ...
                dHeightText ...
            );
            dTop = dTop + dHeightText + dSep;
            
            %{
            this.uiTextSaveValue.build(this.hFigureSave, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            %}
            
           
            dHeightText = 14;
            this.uiTextSaveStd.build(this.hFigureSave, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            this.uiTextSavePV.build(this.hFigureSave, dLeft, dTop, dWidthText, dHeightText);
            dTop = dTop + dHeightText + dSep;
            
            
            this.uiTextSaveGapOfUndulator.hide();
            this.uiTextSaveGapOfExitSlit.hide();
            this.uiTextSaveValue.hide();
            this.uiTextSaveMean.hide();
            this.uiTextSaveStd.hide();
            this.uiTextSavePV.hide();
            
            
            dTop = dTopTexts;
            dLeft = 240;
            dWidthButton = 100;
            dSep = 10;
            
            dLeft = 350;
            this.uiButtonCancelSave.build(...
                this.hFigureSave, ...
                dLeft, ...
                dTop, ...
                100, ...
                24 ...
            );
            dTop = dTop + 24;
            
            this.uiButtonRedoSave.build(...
                this.hFigureSave, ...
                dLeft, ...
                dTop, ...
                dWidthButton, ...
                24 ...
            );
            dTop = dTop + 24;
            
            this.uiButtonConfirmSave.build(...
                this.hFigureSave, ...
                dLeft - 25, ...
                dTop, ...
                150, ...
                48 ...
            );
        
            this.uiButtonRedoSave.hide();
            this.uiButtonConfirmSave.hide();
            dTop = dTop + 24;
        
            dTop = dTop + 70;
            dLeft = 0;
            this.uiProgressBarSave.build(...
                this.hFigureSave, ...
                dLeft, ...
                dTop, ...
                dWidthFigure, ...
                10 ...
            );
            
            
        end
        
        function showSaveModal(this)
            
            if ishandle(this.hFigureSave)
                
                set(this.hFigureSave, 'Visible', 'on');
                this.uiTextSaveGapOfUndulator.hide();
                this.uiTextSaveGapOfExitSlit.hide();
                this.uiTextSaveValue.hide();
                this.uiTextSaveMean.hide();
                this.uiTextSaveStd.hide();
                this.uiTextSavePV.hide();
                this.uiButtonConfirmSave.hide();
                this.uiButtonRedoSave.hide();
                
            end

        end
        
        function onClickCancelSave(this, ~, ~)
            
            this.lAbortSave = true;
            this.hideSaveModal();
        end
        
        
        function onClickSave(this, ~, ~)
            
            % Build up an average flux density over 10 seconds
            % with a progress bar
            
            this.lAbortSave = false;
            this.showSaveModal();
            this.uiProgressBarSave.show();
            
            
            this.dFluxDensityAcc = [];
            dNum = 20;
            for n = 1 : dNum
                
                if this.lAbortSave
                    return
                end
                
                this.dFluxDensityAcc(end + 1) = this.uiDiode.getFluxDensity();
                                
                if isempty(this.hPlotSave)
                    this.hPlotSave = plot(1 : n, this.dFluxDensityAcc,'.-');
                    ylabel(this.hAxesSave, 'mJ/cm2/s');
                else
                    this.hPlotSave.XData = 1 : n;
                    this.hPlotSave.YData = this.dFluxDensityAcc;
                end
                
                this.uiProgressBarSave.set(n / dNum);
                pause(0.3);
            end
            
            
            dMean = abs(mean(this.dFluxDensityAcc));
            dStd = std(this.dFluxDensityAcc);
            dPV = abs(max(this.dFluxDensityAcc) - min(this.dFluxDensityAcc));
            
            
            cMsgMean = sprintf(...
                'Avgeraging Complete: %1.1f mJ/cm2/s', ...
                dMean ...
            );
            cMsgUndulator = sprintf(...
                '@Undulator = %1.2f mm', ...
                this.uiUndulator.uiGap.getValCal('mm') ...
            );
            cMsgExitSlit = sprintf(...
                '@ExitSlit = %1.2f um', ...
                this.uiExitSlit.uiGap.getValCal('um') ...
            );
        
            
            cMsgStd = sprintf(...
                'Std = %1.1f%% (%1.3f mJ/cm2/s)', ...
                dStd / dMean  * 100, ...
                dStd...
            );
            cMsgPV = sprintf(...
                'PV = %1.1f%% (%1.3f mJ/cm2/s)', ...
                dPV / dMean * 100 , ...
                dPV...
            );
            
            
            this.uiTextSaveMean.set(cMsgMean);
            this.uiTextSaveGapOfUndulator.set(cMsgUndulator);
            this.uiTextSaveGapOfExitSlit.set(cMsgExitSlit);
            
            % this.uiTextSaveValue.set(cMsgValue);
            this.uiTextSaveStd.set(cMsgStd);
            this.uiTextSavePV.set(cMsgPV);
            
            
            this.uiTextSaveMean.show();
            this.uiTextSaveGapOfUndulator.show();
            this.uiTextSaveGapOfExitSlit.show();
            % this.uiTextSaveValue.show();
            this.uiTextSaveStd.show();
            this.uiTextSavePV.show();
            
            this.uiButtonRedoSave.show();
            this.uiButtonConfirmSave.show();
            this.uiProgressBarSave.hide();
                            
        end
        
        function onClickConfirmSave(this, ~, ~)
            
            st = struct();
            st.dFluxDensity = abs(mean(this.dFluxDensityAcc));
            st.dGapOfUndulator = this.uiUndulator.uiGap.getValCal('mm');
            st.dGapOfExitSlit = this.uiExitSlit.uiGap.getValCal('um');
            st.cAperture = this.uiDiode.uiPopupAperture.get().cLabel;
            st.dtTime = datetime('now');
            
            cTime = datestr(datevec(now), 'yyyy-mm-dd--HH-MM-SS', 'local');
            mic.Utils.checkDir(this.cDirSave);
            c = fullfile(...
                this.cDirSave, ...
                ['flux-density-calibration-', cTime , '.mat']...
            );
        
            % Save this to disk
            save(c, 'st');
            
            this.loadLastFluxCalibration();
            
            this.lAbortSave = true;
            this.hideSaveModal();
            
        end
        
        
        function loadLastFluxCalibration(this)
            
            cOrder = 'descend';
            cOrderByPredicate = 'date';
            % {char 1xm} - filter for dir2cell, e.g., '*.json'
            cFilter = '*.mat';
            
            ceReturn = mic.Utils.dir2cell(...
                this.cDirSave, ...
                cOrderByPredicate, ...
                cOrder, ...
                cFilter ...
            );
            
            if isempty(ceReturn)
                return
            end
            
            load(fullfile(this.cDirSave, ceReturn{1})); % populates variable st in local workspace
            
            this.dFluxDensityCalibrated = st.dFluxDensity;
            this.dGapOfUndulatorCalibrated = st.dGapOfUndulator;
            this.dGapOfExitSlitCalibrated = st.dGapOfExitSlit;
            this.cApertureCalibrated = st.cAperture;
            this.dtTimeCalibrated = st.dtTime;
                        
            this.uiTextTimeCalibrated.set(sprintf('Last Calibration: %s', this.dtTimeCalibrated));
            this.uiTextFluxDensityCalibrated.set(sprintf('Flux Density: %1.1f mJ/cm2/s', this.dFluxDensityCalibrated));
            this.uiTextGapOfUndulatorCalibrated.set(sprintf('Gap of Undulator: %1.2f mm', this.dGapOfUndulatorCalibrated));            
            this.uiTextGapOfExitSlitCalibrated.set(sprintf('Gap of Exit Slit: %1.1f um', this.dGapOfExitSlitCalibrated));
            this.uiTextApertureCalibrated.set(sprintf('Aperture: %s', this.cApertureCalibrated));

        end

    end % private
    
    
end