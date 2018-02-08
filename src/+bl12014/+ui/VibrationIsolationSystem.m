classdef VibrationIsolationSystem < mic.Base
    
    properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommGalil
        uiCommDataTranslation
       
        % {mic.ui.device.GetSetNumber 1x1}
        uiStage1
        uiStage2
        uiStage3
        uiStage4
        
        % {mic.ui.device.GetNumber 1x1}
        uiEncoder1
        uiEncoder2
        uiEncoder3
        uiEncoder4
        
        % {mic.ui.device.GetNumber 1x1}}
        uiTemp1
        uiTemp2
        uiTemp3
        uiTemp4
        
        % {mic.ui.common.Button 1x1}
        uiButtonGoDest
        uiButtonGoStep
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 660
        dHeight = 270
        hFigure
        
        dWidthNameMotor = 150
        dWidthNameEncoder = 0
        dWidthVal = 100
        dWidthValueEncocer = 50
        dWidthValueTemp = 50
        dWidthPadName = 0
        dWidthPadUnitEncoder = 5
        dWidthUnitTemp = 100
                
        dWidthButton = 55
    end
    
    properties (SetAccess = private)
        
        cName = 'vibration-isolation-system'
    end
    
    methods
        
        function this = VibrationIsolationSystem(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        function st = save(this)
            st = struct();
            st.uiStage1 = this.uiStage1.save();
            st.uiStage2 = this.uiStage2.save();
            st.uiStage3 = this.uiStage3.save();
            st.uiStage4 = this.uiStage4.save();
            
            st.uiTemp1 = this.uiTemp1.save();
            st.uiTemp2 = this.uiTemp2.save();
            st.uiTemp3 = this.uiTemp3.save();
            st.uiTemp4 = this.uiTemp4.save();
            
            
            st.uiEncoder1 = this.uiEncoder1.save();
            st.uiEncoder2 = this.uiEncoder2.save();
            st.uiEncoder3 = this.uiEncoder3.save();
            st.uiEncoder4 = this.uiEncoder4.save();
            
        end
        
        
        function load(this, st)
            
            if isfield(st, 'uiStage1')
                this.uiStage1.load(st.uiStage1);
            end
            
            if isfield(st, 'uiStage2')
                this.uiStage2.load(st.uiStage2);
            end
            
            if isfield(st, 'uiStage3')
                this.uiStage3.load(st.uiStage3);
            end
            
            if isfield(st, 'uiStage4')
                this.uiStage4.load(st.uiStage4);
            end
            
            
            if isfield(st, 'uiTemp1')
                this.uiTemp1.load(st.uiTemp1);
            end
            
            if isfield(st, 'uiTemp2')
                this.uiTemp2.load(st.uiTemp2);
            end
            
            if isfield(st, 'uiTemp3')
                this.uiTemp3.load(st.uiTemp3);
            end
            
            if isfield(st, 'uiTemp4')
                this.uiTemp4.load(st.uiTemp4);
            end
            
            
            
            if isfield(st, 'uiEncoder1')
                this.uiEncoder1.load(st.uiEncoder1);
            end
            
            if isfield(st, 'uiEncoder2')
                this.uiEncoder2.load(st.uiEncoder2);
            end
            
            if isfield(st, 'uiEncoder3')
                this.uiEncoder3.load(st.uiEncoder3);
            end
            
            if isfield(st, 'uiEncoder4')
                this.uiEncoder4.load(st.uiEncoder4);
            end
            
        end
        
        
        function connectDataTranslationMeasurPoint(this, comm)
            
            device1 = GetNumberFromDataTranslationMeasurPoint(...
                comm, ...
                GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, ...
                11 ...
            );
            device2 = GetNumberFromDataTranslationMeasurPoint(...
                comm, ...
                GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, ...
                12 ...
            );
            device3 = GetNumberFromDataTranslationMeasurPoint(...
                comm, ...
                GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, ...
                13 ...
            );
            device4 = GetNumberFromDataTranslationMeasurPoint(...
                comm, ...
                GetNumberFromDataTranslationMeasurPoint.cTYPE_TEMP_RTD, ...
                14 ...
            );
            this.uiTemp1.setDevice(device1);
            this.uiTemp2.setDevice(device2);
            this.uiTemp3.setDevice(device3);
            this.uiTemp4.setDevice(device4);
            
            this.uiTemp1.turnOn();
            this.uiTemp2.turnOn();
            this.uiTemp3.turnOn();
            this.uiTemp4.turnOn();
        end
        
        function disconnectDataTranslationMeasurPoint(this)
                        
            this.uiTemp1.turnOff();
            this.uiTemp2.turnOff();
            this.uiTemp3.turnOff();
            this.uiTemp4.turnOff();
            
            this.uiTemp1.setDevice([]);
            this.uiTemp2.setDevice([]);
            this.uiTemp3.setDevice([]);
            this.uiTemp4.setDevice([]);
            
        end
        
        
        function connectGalil(this, comm)
            
            device1 = bl12014.device.GetSetNumberFromStage(comm, 0);
            device2 = bl12014.device.GetSetNumberFromStage(comm, 1);
            device3 = bl12014.device.GetSetNumberFromStage(comm, 2);
            device4 = bl12014.device.GetSetNumberFromStage(comm, 3);
            
            this.uiStage1.setDevice(device1);
            this.uiStage2.setDevice(device2);
            this.uiStage3.setDevice(device3);
            this.uiStage4.setDevice(device4);
            
            this.uiStage1.turnOn();
            this.uiStage2.turnOn();
            this.uiStage3.turnOn();
            this.uiStage4.turnOn();
            
            % FIXME
            % Need to wire in the encoders
            
            %{
            device1 = bl12014.device.GetSetNumberFromStage(comm, 0);
            device2 = bl12014.device.GetSetNumberFromStage(comm, 1);
            device3 = bl12014.device.GetSetNumberFromStage(comm, 2);
            device4 = bl12014.device.GetSetNumberFromStage(comm, 3);
            
            this.uiEncoder1.setDevice(device1);
            this.uiEncoder2.setDevice(device2);
            this.uiEncoder3.setDevice(device3);
            this.uiEncoder4.setDevice(device4);
            
            this.uiEncoder1.turnOn();
            this.uiEncoder2.turnOn();
            this.uiEncoder3.turnOn();
            this.uiEncoder4.turnOn();
            %}
            
            
        end
        
        function disconnectGalil(this)
            this.uiStage1.turnOff();
            this.uiStage2.turnOff();
            this.uiStage3.turnOff();
            this.uiStage4.turnOff();
            
            this.uiStage1.setDevice([]);
            this.uiStage2.setDevice([]);
            this.uiStage3.setDevice([]);
            this.uiStage4.setDevice([]);
            
            % FIX ME - wire in encoders
        end
        
        
        function build(this)
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'Vibration Isolation System Control', ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onFigureCloseRequest ...
            );
                        
            drawnow;

            dTop = 10;
            dLeft = 10;
            dSep = 30;
            
                       
            this.uiCommGalil.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslation.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
                       
            this.uiStage1.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep + 15;
            
            this.uiStage2.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStage3.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStage4.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            dLeft = 265;
            this.uiButtonGoDest.build(this.hFigure, dLeft, dTop, this.dWidthButton, 24)
            dLeft = dLeft + 70;
            this.uiButtonGoStep.build(this.hFigure, dLeft, dTop, this.dWidthButton, 24);
            
            
            % Hack to draw these in line with stage GetSetNumbers as if
            % they were another column of those devices
            
            dTop = 10;
            dLeft = 40;
            dSep = 30;
            dTop = dTop + 15 + dSep + dSep;
            
            
            this.uiEncoder1.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep + 15;
            
            this.uiEncoder2.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiEncoder3.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiEncoder4.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            % Hack to draw these in line with stage GetSetNumbers as if
            % they were another column of those devices
            
            dTop = 10;
            dLeft = 500;
            dSep = 30;
            dTop = dTop + 15 + dSep + dSep;
            
            this.uiTemp1.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiTemp2.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiTemp3.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiTemp4.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            

            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end    
        
        
        
    end
    
    methods (Access = private)
        
         function onFigureCloseRequest(this, src, evt)
            this.msg('M141Control.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
         end
         
         
         function initUiEncoder1(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-vibration-isolation-system-encoder-1.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiEncoder1 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthPadUnit', this.dWidthPadUnitEncoder, ...
                'dWidthVal', this.dWidthValueEncocer, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowLabels', true, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'lShowName', false, ...
                'cLabelValue', 'Encoder', ...
                'cLabelUnit', 'Encoder Unit', ...
                'cName', sprintf('%s-encoder-1', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Encoder 1' ...
            );
         end
         
         function initUiEncoder2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-vibration-isolation-system-encoder-2.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiEncoder2 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthPadUnit', this.dWidthPadUnitEncoder, ...
                'dWidthVal', this.dWidthValueEncocer, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowName', false, ...
                'cName', sprintf('%s-encoder-2', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Encoder 2' ...
            );
         end
         
         function initUiEncoder3(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-vibration-isolation-system-encoder-3.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiEncoder3 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthPadUnit', this.dWidthPadUnitEncoder, ...
                'dWidthVal', this.dWidthValueEncocer, ...
                'lShowLabels', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowDevice', false, ...
                'lShowName', false, ...
                'cName', sprintf('%s-encoder-3', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Encoder 3' ...
            );
         end
         
         function initUiEncoder4(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-vibration-isolation-system-encoder-4.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiEncoder4 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthPadUnit', this.dWidthPadUnitEncoder, ...
                'dWidthVal', this.dWidthValueEncocer, ...
                'lShowLabels', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowDevice', false, ...
                'lShowName', false, ...
                'cName', sprintf('%s-encoder-4', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Encoder 4' ...
            );
         end
        
         
         
               
        
        function initUiStage1(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-vibration-isolation-system-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStage1 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cLabelName', 'Motor', ...
                'dWidthName', this.dWidthNameMotor, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthVal', this.dWidthVal, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'lShowLabels', true, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowPlay', false, ...
                'lShowStepPos', false, ...
                'lShowStepNeg', false, ...
                'dWidthPadStep', 20, ...
                'cLabelValue', 'Dist From Home', ...
                'lDisableMoveToDestOnDestEnter', true, ...
                'cName', sprintf('%s-stage-1', this.cName), ...
                'config', uiConfig, ...
                'cLabel', '1' ...
            );
        end
        
        function initUiStage2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-vibration-isolation-system-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStage2 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cLabelName', 'Motor', ...
                'dWidthName', this.dWidthNameMotor, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthVal', this.dWidthVal, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'lShowLabels', false, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowPlay', false, ...
                'lShowStepPos', false, ...
                'lShowStepNeg', false, ...
                'dWidthPadStep', 20, ...
                'lDisableMoveToDestOnDestEnter', true, ...
                'cName', sprintf('%s-stage-2', this.cName), ...
                'config', uiConfig, ...
                'cLabel', '2' ...
            );
        end
        
        function initUiStage3(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-vibration-isolation-system-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStage3 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cLabelName', 'Motor', ...
                'dWidthName', this.dWidthNameMotor, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthVal', this.dWidthVal, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'lShowLabels', false, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowPlay', false, ...
                'lShowStepPos', false, ...
                'lShowStepNeg', false, ...
                'dWidthPadStep', 20, ...
                'lDisableMoveToDestOnDestEnter', true, ...
                'cName', sprintf('%s-stage-3', this.cName), ...
                'config', uiConfig, ...
                'cLabel', '3' ...
            );
        end
        
        function initUiStage4(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-vibration-isolation-system-stage.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStage4 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cLabelName', 'Motor', ...
                'dWidthName', this.dWidthNameMotor, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthVal', this.dWidthVal, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'lShowLabels', false, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowPlay', false, ...
                'lShowStepPos', false, ...
                'lShowStepNeg', false, ...
                'dWidthPadStep', 20, ...
                'lDisableMoveToDestOnDestEnter', true, ...
                'cName', sprintf('%s-stage-4', this.cName), ...
                'config', uiConfig, ...
                'cLabel', '4' ...
            );
        end
        
        function initUiCommGalil(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommGalil = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'cLabelName', 'Motor', ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-galil-dmc-4143', this.cName), ...
                'cLabel', 'Galil DMC 4143' ...
            );
        
        end
        
        function initUiCommDataTranslation(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommDataTranslation = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'cLabelName', '', ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-data-translation-measur-point', this.cName), ...
                'cLabel', 'Data Translsation MeasurPoint' ...
            );
        
        end
        
        
        function initUiButtonGoStep(this)
            this.uiButtonGoStep = mic.ui.common.Button( ...
                'cText', 'Step', ...
                'fhDirectCallback', @this.onButtonClickGoStep ...
            );
        end
        
        function initUiButtonGoDest(this)
            this.uiButtonGoDest = mic.ui.common.Button( ...
                'cText', 'Go', ...
                'fhDirectCallback', @this.onButtonClickGoDest ...
            );
        end
        
        function onButtonClickGoStep(this, src, evt)
            
            this.uiStage1.stepPos();
            this.uiStage2.stepPos();
            this.uiStage3.stepPos();
            this.uiStage4.stepPos();
            
        end
        
        function onButtonClickGoDest(this, src, evt)
            
            this.uiStage1.moveToDest();
            this.uiStage2.moveToDest();
            this.uiStage3.moveToDest();
            this.uiStage4.moveToDest();
        end
        

        function init(this)
            this.msg('init');
            
            this.initUiButtonGoStep()
            this.initUiButtonGoDest();
            
            this.initUiCommGalil();
            this.initUiCommDataTranslation();
            
            this.initUiStage1();
            this.initUiStage2();
            this.initUiStage3();
            this.initUiStage4();
            
            this.initUiEncoder1();
            this.initUiEncoder2();
            this.initUiEncoder3();
            this.initUiEncoder4();
            
            this.initUiTemp1();
            this.initUiTemp2();
            this.initUiTemp3();
            this.initUiTemp4();
        end
        
        function initUiTemp1(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-vis-temp-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiTemp1 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthUnit', this.dWidthUnitTemp, ...
                'dWidthVal', this.dWidthValueTemp, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowLabels', true, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'lShowName', false, ...
                'cName', 'vis-temp-sensor-1', ...
                'config', uiConfig, ...
                'cLabelValue', 'Temp', ...
                'cLabelUnit', 'Temp Unit', ...
                'cLabel', '1' ...
            );
        end
        
        function initUiTemp2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-vis-temp-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiTemp2 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthUnit', this.dWidthUnitTemp, ...
                'dWidthVal', this.dWidthValueTemp, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowLabels', true, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'lShowName', false, ...
                'cName', 'vis-temp-sensor-2', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'cLabel', '2' ...
            );
        end
        
        function initUiTemp3(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-vis-temp-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiTemp3 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthUnit', this.dWidthUnitTemp, ...
                'dWidthVal', this.dWidthValueTemp, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowLabels', true, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'lShowName', false, ...
                'cName', 'vis-temp-sensor-3', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'cLabel', '3' ...
            );
        end
        
        function initUiTemp4(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-vis-temp-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiTemp4 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthUnit', this.dWidthUnitTemp, ...
                'dWidthVal', this.dWidthValueTemp, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowLabels', true, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'lShowName', false, ...
                'cName', 'vis-temp-sensor-4', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'cLabel', '1' ...
            );
        end
        
        
        
    end
    
    
end

