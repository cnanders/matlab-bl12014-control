classdef FemTool < mic.Base
    
    % rcs
    
	properties
               
       c_POSITION_TYPE_START = 'Start:';
       c_POSITION_TYPE_CENTER = 'Center:';



       uieDoseNum
        uieDoseCenter
        uieDoseStep
        uipDoseStepType
        uitDoseRange
        
        uieFocusNum
        uieFocusCenter
        uieFocusStep
        uitFocusRange
       
    end
    
    properties (SetAccess = private)
        
        dWidth              = 550;
        dHeight             = 250;
       
        dWidthPosition      = 250;
        dHeightPosition     = 170;
        dWidthDose          = 275;
        dHeightDose         = 100;
        dWidthFocus         = 275;
        dHeightFocus        = 100;
        
        
        % {double 1xm} list of focuses
        dFocus              
        
        % {double 1xn} list of doses
        dDose 
        
        % {double 1xn} list of wafer x position of each dose
        dX                 
        
        % {double 1xn} list of wafer y position of each focus
        dY  
        
        % {logical 1x1} set to true after all UI elements are initialized
        lInitialized = false
        
        uiePause

    
    end
    
    properties (Access = private)
           
        dWidthPad = 10;
        dHeightPad = 10;
                
        hPanel
        hPanelPos
        hPanelDose
        hPanelFocus
        hPanelPause
        
        uipPositionType 
        uiePositionX
        uiePositionStepX
        uiePositionY
        uiePositionStepY
        uitPositionStepLabel
        uitPositionRangeX
        uitPositionRangeY
        
        
        
        
        
        uitQA
        
        
        
        uibMatrix
        
        % {logical 1x1} when calling load(), this is true so a bunch of
        % events are not dispatched while loading
        lLoading = false
        
        
        dWidthBorderPanel = 0
                
        
        uiButtonLoadDefault
        
    end
    
        
    events
        
        eSizeChange
        
    end
    

    
    methods
        
        
        function this = FemTool()
            
            this.init();
            
        end
        
        function ce = getPropsSaved(this)
            
            ce = {...
                'uiePause', ...
                'uiePositionX', ...
                'uiePositionY', ...
                'uiePositionStepX', ...
                'uiePositionStepY', ...
                'uipPositionType', ...
                'uieDoseNum', ...
                'uieDoseCenter', ...
                'uieDoseStep', ...
                'uipDoseStepType', ...
                'uieFocusNum', ...
                'uieFocusCenter', ...
                'uieFocusStep' ...
            };
        
        end
        
        function st = savePublic(this)
            
       
            st = struct();
            
            st.cPositionType = this.uipPositionType.get();
            st.dPositionStartX = this.dX(1);
            st.dPositionStepX = this.uiePositionStepX.get();
            st.dPositionStartY = this.dY(1);
            st.dPositionStepY = this.uiePositionStepY.get();
            
            st.u8DoseNum = this.uieDoseNum.get();
            st.dDoseCenter = this.uieDoseCenter.get();
            st.dDoseStep = this.uieDoseStep.get();
            st.u8DoseStepType = this.uipDoseStepType.getSelectedIndex();

            st.u8FocusNum = this.uieFocusNum.get();
            st.dFocusCenter = this.uieFocusCenter.get();
            st.dFocusStep = this.uieFocusStep.get();
            st.dPause = this.uiePause.get();
            
            
        end

        
        % @return {struct} UI state to save
       function st = save(this)
            
            ceProps = this.getPropsSaved();
        
            st = struct();
            for n = 1 : length(ceProps)
                cProp = ceProps{n};
                st.(cProp) = this.(cProp).save();
            end
            
        end
        
        % @param {struct} UI state to load.  See save() for info on struct
        function load(this, st)
            
            this.lLoading = true;
            
            ceProps = this.getPropsSaved();
        
            for n = 1 : length(ceProps)
                cProp = ceProps{n};
                if isfield(st, cProp)
                    try
                        this.(cProp).load(st.(cProp));
                    end
                end
            end
            
            
            this.lLoading = false;
            
            % call updateSize() to dispatch the event
            this.updateSize();
            this.updateFocus();
            this.updateDose();
            
            
        end
        
        
        function build(this, hParent, dLeft, dTop)
                        
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Focus Exposure Matrix',...
                'Clipping', 'on',...
                'BorderWidth', this.dWidthBorderPanel, ...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );        
            
			drawnow;
            
            this.buildPanelDose();
            this.buildPanelFocus();
            this.buildPanelPosition();
            
            dLeft = this.dWidthPad + this.dWidthDose + this.dWidthPad;
            dTop = this.dHeightPad + this.dHeightPosition + 2*this.dHeightPad - 10;
            dWidth = 50;
            this.uiePause.build(...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                50, ...
                24 ...
            )
        
            
            % Print button
            dLeft = dLeft + dWidth + 10;
            dTop = dTop + 10;
            dWidth = 120;
            
            this.uibMatrix.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                30 ...
            );
        
            dLeft = dLeft + dWidth + 10;
            dWidth = 40
            
            this.uitQA.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                24 ...
            );
        
            
            this.updateDose();
            this.updateFocus();
            this.updateSize();
            
            
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
                        
        end
                    

    end
    
    methods (Access = private)
        
        function buildPanelDose(this)
            
            dTop = 20;
            
            this.hPanelDose = uipanel(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Title', 'Dose (mJ/cm2)',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                    this.dWidthPad ...
                    dTop ...
                    this.dWidthDose ...
                    this.dHeightDose], this.hPanel) ...
            );
        
        
            % Size panel is two-col
            
            dWidthEdit = 50;
            dWidthPopup = 80;
            
            % Dose Panel
            
            dLeft = this.dWidthPad;
            
            this.uieDoseNum.build( ...
                this.hPanelDose, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
            dLeft = dLeft + dWidthEdit + this.dWidthPad;
            
            this.uieDoseCenter.build( ...
                this.hPanelDose, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
            dLeft = dLeft + dWidthEdit + this.dWidthPad;
        
            this.uieDoseStep.build( ...
                this.hPanelDose, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
            dLeft = dLeft + dWidthEdit + this.dWidthPad;
            
            this.uipDoseStepType.build( ...
                this.hPanelDose, ...
                dLeft, ...
                dTop, ...
                dWidthPopup, ...
                mic.Utils.dEDITHEIGHT ...
            );
        
            dLeft = this.dWidthPad;
            dTop = dTop + mic.Utils.dEDITHEIGHT + 2 * this.dHeightPad;
            
            this.uitDoseRange.build( ...
                this.hPanelDose, ...
                dLeft, ...
                dTop, ...
                this.dWidthDose - 2 * this.dWidthPad, ...
                mic.Utils.dTEXTHEIGHT ...
            );
        
        
        end
        
        
        function buildPanelFocus(this)
            
            dTop = 20;
            
            this.hPanelFocus = uipanel(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Title', 'Focus (nm)',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                    this.dWidthPad ...
                    dTop + this.dHeightDose + 10 ...
                    this.dWidthFocus ...
                    this.dHeightFocus], this.hPanel) ...
            );
        
            
            dWidthEdit = 50;
            
            dLeft = this.dWidthPad;
            
            this.uieFocusNum.build( ...
                this.hPanelFocus, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
            dLeft = dLeft + this.dWidthPad + dWidthEdit;
            
            this.uieFocusCenter.build( ...
                this.hPanelFocus, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
            dLeft = dLeft + this.dWidthPad + dWidthEdit;
            
            
            this.uieFocusStep.build( ...
                this.hPanelFocus, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
            dLeft = dLeft + this.dWidthPad + dWidthEdit;
                        
        
            dTop = dTop + mic.Utils.dEDITHEIGHT + 2 * this.dHeightPad;
            dLeft = this.dWidthPad;
            
            this.uitFocusRange.build( ...
                this.hPanelFocus, ...
                dLeft, ...
                dTop, ...
                this.dWidthFocus - 2 * this.dWidthPad, ...
                mic.Utils.dTEXTHEIGHT ...
            );
            
        end
        
        
        
        
        function buildPanelPosition(this)
            
            
            dTop = 20;
            dWidthEdit = 50;
            dWidthPopup = 90;
            
            
            this.hPanelPos = uipanel(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Title', 'Position (mm)',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                    this.dWidthPad + this.dWidthDose + this.dWidthPad ...
                    dTop ...
                    this.dWidthPosition ...
                    this.dHeightPosition], this.hPanel) ...
            );
                    
            drawnow;
            
            % Size panel is two-col
            
            dTop = 20;
            
            
            % Position panel
            
            dLeft = this.dWidthPad;
            this.uipPositionType.build(...
                this.hPanelPos, ...
                dLeft, ...
                dTop + 18, ...
                dWidthPopup, ...
                mic.Utils.dEDITHEIGHT ...
            )
            
        
            dLeft = dLeft + dWidthPopup + this.dWidthPad;
            this.uiePositionX.build( ...
                this.hPanelPos, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
        
            dLeft = dLeft + dWidthEdit + this.dWidthPad;
            this.uiePositionY.build( ...
                this.hPanelPos, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
        
        
            dTop = dTop + mic.Utils.dEDITHEIGHT + 2 * this.dHeightPad;
            dTop = dTop - this.dHeightPad + 5;
            dLeft = this.dWidthPad;
            
            this.uitPositionStepLabel.build(...
                this.hPanelPos, ...
                dLeft + 50, ...
                dTop + 5, ...
                70, ...
                mic.Utils.dEDITHEIGHT ...
            )
            
            dLeft = dLeft + dWidthPopup + this.dWidthPad;
            this.uiePositionStepX.build( ...
                this.hPanelPos, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
        
            dLeft = dLeft + dWidthEdit + this.dWidthPad;
            this.uiePositionStepY.build( ...
                this.hPanelPos, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
        
            dTop = dTop + mic.Utils.dEDITHEIGHT + 2 * this.dHeightPad;
            
            this.uitPositionRangeX.build( ...
                this.hPanelPos, ...
                this.dWidthPad, ...
                dTop, ...
                dWidthEdit + dWidthEdit + this.dWidthPad, ...
                mic.Utils.dTEXTHEIGHT ...
            );
        
            dTop = dTop + 20;
            
            this.uitPositionRangeY.build( ...
                this.hPanelPos, ...
                this.dWidthPad, ...
                dTop, ...
                dWidthEdit + dWidthEdit + this.dWidthPad, ...
                mic.Utils.dTEXTHEIGHT ...
            );
            
            this.uiButtonLoadDefault.build(this.hPanelPos, 110, 100, 110, 24);
        end
        
        
        function initDosePanel(this)
            this.uieDoseNum = mic.ui.common.Edit(...
                'cLabel', 'Num', ...
                'fhDirectCallback', @this.onDoseNum, ...
                'cType', 'u8' ...
            );
            this.uieDoseCenter = mic.ui.common.Edit(...
                'cLabel', 'Center', ...
                'fhDirectCallback', @this.onDoseCenter, ...
                'cType', 'd' ...
            );
            this.uieDoseStep = mic.ui.common.Edit(...
                'cLabel', 'Step', ...
                'fhDirectCallback', @this.onDoseStep, ...
                'cType', 'd' ...
            );
            this.uipDoseStepType = mic.ui.common.Popup(...
                'ceOptions', {'%-exp', '%-lin'}, ...
                'fhDirectCallback', @this.onDoseStepType, ...
                'cLabel', 'Step Type', ...
                'lShowLabel', true ...
            );
            this.uitDoseRange = mic.ui.common.Text(...
                'cVal', 'Range: []' ...
            );
            
            this.uieDoseNum.set(uint8(9));
            this.uieDoseCenter.set(15);
            this.uieDoseStep.set(5);
            
            %{
            addlistener(this.uieDoseNum, 'eChange', @this.onSize);
            addlistener(this.uieDoseCenter, 'eChange', @this.onDose);
            addlistener(this.uieDoseStep, 'eChange', @this.onDose);
            addlistener(this.uipDoseStepType, 'eChange', @this.onDose); 
            %}
            
            
        end
        
        function onDoseNum(this, src, evt)
            this.updateSize();
            this.updateDose();
        end
        
        function onDoseCenter(this, src, evt)
            this.updateDose();
        end
        
        function onDoseStep(this, src, evt)
            this.updateDose();
        end
        
        function onDoseStepType(this, src, evt)
            this.updateDose();
        end
        
        
        function initFocusPanel(this)
            
            this.uieFocusNum = mic.ui.common.Edit(...
                'cLabel', 'Num', ...
                'fhDirectCallback', @this.onFocusNum, ...
                'cType', 'u8' ...
            );
            this.uieFocusCenter = mic.ui.common.Edit(...
                'cLabel', 'Center', ...
                'fhDirectCallback', @this.onFocusCenter, ...
                'cType', 'd' ...
            );
            this.uieFocusStep = mic.ui.common.Edit(...
                'cLabel', 'Step', ...
                'fhDirectCallback', @this.onFocusStep, ...
                'cType', 'd' ...
            );
            
            this.uitFocusRange = mic.ui.common.Text('cVal', 'Range: []');
            
            
            this.uieFocusNum.set(uint8(9));
            this.uieFocusCenter.set(0);
            this.uieFocusStep.set(10);
            
            %{
            addlistener(this.uieFocusNum, 'eChange', @this.onSize);
            addlistener(this.uieFocusCenter, 'eChange', @this.onFocus);
            addlistener(this.uieFocusStep, 'eChange', @this.onFocus);
            %}            

        end
        
        function onFocusNum(this, src, evt)
            this.updateSize();
            this.updateDose();
            this.updateFocus();
        end
        
        function onFocusCenter(this, src, evt)
            this.updateFocus();
        end
        
        function onFocusStep(this, src, evt)
            this.updateFocus();
        end
        
                
        function initPositionPanel(this)
            

            this.uipPositionType = mic.ui.common.Popup(...
                'ceOptions', {this.c_POSITION_TYPE_START, this.c_POSITION_TYPE_CENTER}, ...
                'fhDirectCallback', @this.onPositionType, ...
                'cLabel', '', ...
                'lShowLabel', false ...
            );
        
            this.uiePositionX = mic.ui.common.Edit(...
                'cLabel', 'X', ...
                'fhDirectCallback', @this.onPositionX, ...
                'cType', 'd' ...
            );
            this.uiePositionY = mic.ui.common.Edit(...
                'cLabel', 'Y', ...
                'fhDirectCallback', @this.onPositionY, ...
                'cType', 'd' ...
            );
            this.uiePositionStepX = mic.ui.common.Edit( ...
                'cLabel', 'X', ...
                'lShowLabel', false, ...
                'fhDirectCallback', @this.onPositionStepX, ...
                'cType', 'd' ...
            );
            this.uiePositionStepY = mic.ui.common.Edit(...
                'cLabel', 'Y', ...
                'lShowLabel', false, ...
                'fhDirectCallback', @this.onPositionStepY, ...
                'cType', 'd' ...
            );
            this.uitPositionRangeX = mic.ui.common.Text(...
                'cVal', 'x: [,]' ...
            );
            this.uitPositionRangeY = mic.ui.common.Text(...
                'cVal', 'y: [,]' ...
            );
            this.uitPositionStepLabel = mic.ui.common.Text(...
                'cVal', 'Step:' ...
            );
        
            
            this.uiePositionX.set(0);
            this.uiePositionY.set(0);
            this.uiePositionStepX.set(2);
            this.uiePositionStepY.set(2);
            
            %{
            addlistener(this.uiePositionX, 'eChange', @this.onSize);
            addlistener(this.uiePositionY, 'eChange', @this.onSize);
            addlistener(this.uiePositionStepX, 'eChange', @this.onSize);
            addlistener(this.uiePositionStepY, 'eChange', @this.onSize);
            %}
            
            
            
        end
        
        
        function onPositionX(this, src, evt)
            
            
            this.updateSize();
            
            
        end
        
        function onPositionY(this, src, evt)
            
            this.updateSize();
            
            
        end
        
        function onPositionStepX(this, src, evt)
            
            this.updateSize();
            
        end
        
        function onPositionStepY(this, src, evt)
            
            this.updateSize();
            
        end
        
        function onPositionType(this, src, evt)
            
            this.updateSize();
            
        end
        
        
        function init(this)
                        
            this.msg('init()');
            
            this.initDosePanel();
            this.initFocusPanel();
            this.initPositionPanel();
            
            
            this.uiePause = mic.ui.common.Edit(...
                'cType', 'd', ...
                'cLabel', 'Pause (s)' ...
            );
            this.uiePause.set(0);
        
            this.uibMatrix = mic.ui.common.Button(...
                'fhDirectCallback', @this.onPrintMatrix, ...
                'cText', 'Echo FEM Values' ...
            );
        
            this.uitQA = mic.ui.common.Toggle(...
                'cTextTrue', 'X', ...
                'cTextFalse', 'OK' ...
            );
            
            % addlistener(this.uibMatrix, 'eChange', @this.onPrintMatrix);
            addlistener(this.uitQA, 'eChange', @this.onQA);

            this.lInitialized = true;
            
            this.uiButtonLoadDefault = mic.ui.common.Button(...
                'fhOnClick', @this.onClickUiButtonLoadDefault, ...
                'cText', 'Load Def. 2022.03' ...
            ); 
                        
        end
        
        function onClickUiButtonLoadDefault(this, ~, ~)
            
            this.uipPositionType.setSelectedValue(this.c_POSITION_TYPE_CENTER);
            
            % x, y updated 2021.09.27 after fixing zero offset from print
            % data
            this.uiePositionX.set(-14.85); %-14.85 2022.03 % 7.87 2021.12; 6.5
            this.uiePositionY.set(3.5); % -4.5
            this.uiePositionStepX.set(-0.25);
            this.uiePositionStepY.set(0.17);
            
        end
        
        function onPrintMatrix(this, ~, ~)
              
            fprintf('\n%1d (dose) x %1d (focus)\n', length(this.dDose), length(this.dFocus));
            fprintf('Dose (mJ/cm2), Focus (nm)\n');
            for k = 1:length(this.dY)
                for l = 1:length(this.dX)
                   fprintf('%1.2f, %1.0f \t', this.dDose(l), this.dFocus(k));
                end
                
                fprintf('\n');
            end
            
            fprintf('\nX (mm), Y (mm)\n');
            for k = 1:length(this.dY)
                for l = 1:length(this.dX)
                   fprintf('%1.2f, %1.2f \t', this.dX(l), this.dY(k));
                end
                
                fprintf('\n');
            end
            
            fprintf('\nWafer coordinates: X (mm), Y (mm)\n');
            for k = 1:length(this.dY)
                for l = 1:length(this.dX)
                   fprintf('%1.2f, %1.2f \t', -this.dX(l) +2.37, -this.dY(k) +9.12);
                end
                
                fprintf('\n');
            end

            fprintf('\nWafer coordinates of FEM center\n');
            dXCenter = (this.dX(1) + this.dX(end))/2;
            dYCenter = (this.dY(1) + this.dY(end))/2;
            fprintf('%1.2f, %1.2f\n', -dXCenter +2.37, -dYCenter +9.12);

        end
        
        function onCloseRequestFcn(this, src, evt)
           
        end
        
        function onSize(this, ~, ~)
            
            % this.msg('onSize');
            
            this.updateSize();
            this.updateDose();
            this.updateFocus();
        end
        
        function onQA(this, ~, ~)
            
            if this.uitQA.get()
                set(this.hPanel, ...
                    'BackgroundColor', [1 .6 1] ...
                );
            else
                set(this.hPanel, ...
                    'BackgroundColor', [.94 .94 .94] ...
                );
            end
            
        end
        
        function onDose(this, ~, ~)
            this.updateDose();
        end
        
        function onFocus(this, ~, ~)
            this.updateFocus();
        end
        
        function updateSize(this)
             
            
            if ~this.lInitialized
                return
            end
            
            if this.lLoading
                return
            end
            
            dNumDose = double(this.uieDoseNum.get());
            dNumFocus = double(this.uieFocusNum.get());
            
            switch this.uipPositionType.getSelectedValue()
                case this.c_POSITION_TYPE_START
                    
                    dXStart = this.uiePositionX.get();
                    dYStart = this.uiePositionY.get();
                    dXEnd =  this.uiePositionX.get() +  (dNumDose - 1)*this.uiePositionStepX.get();
                    dYEnd = this.uiePositionY.get() + (dNumFocus - 1)*this.uiePositionStepY.get();
                    
                    % this.dX = this.uiePositionX.get() : this.uiePositionStepX.get() : this.uiePositionX.get() + (dNumDose - 1)*this.uiePositionStepX.get();
                    % this.dY = this.uiePositionY.get() : this.uiePositionStepY.get() : this.uiePositionY.get() + (dNumFocus - 1)*this.uiePositionStepY.get();
                case this.c_POSITION_TYPE_CENTER
                    % Center
                   
                    % X positions (dose)
                    if mod(this.uieDoseNum.get(), 2) == 0
                        % Even
                        dXStart = this.uiePositionX.get() - this.uiePositionStepX.get() * dNumDose / 2;
                        dXEnd = this.uiePositionX.get() + this.uiePositionStepX.get() * (dNumDose / 2 - 1);
                    else
                        % Odd
                        dXStart = this.uiePositionX.get() - this.uiePositionStepX.get() * (dNumDose - 1)/2;
                        dXEnd = this.uiePositionX.get() + this.uiePositionStepX.get() * (dNumDose - 1)/2;
                        
                        
                    end
                    
                    % Y positions (focus)
                    if mod(this.uieFocusNum.get(), 2) == 0
                        % Even
                        dYStart = this.uiePositionY.get() - this.uiePositionStepY.get() *  dNumFocus / 2;
                        dYEnd = this.uiePositionY.get() + this.uiePositionStepY.get() * (dNumFocus / 2 - 1);
                    else
                        % Odd
                        dYStart = this.uiePositionY.get() - this.uiePositionStepY.get() * (dNumFocus - 1)/2;
                        dYEnd = this.uiePositionY.get() + this.uiePositionStepY.get() * (dNumFocus - 1)/2;
                    end
                    
                   
                    
            end % Switch
            
            this.dX = linspace(dXStart, dXEnd, dNumDose);
            this.dY = linspace(dYStart, dYEnd, dNumFocus);

            %this.dX = dXStart : this.uiePositionStepX.get() : dXEnd;
            %this.dY = dYStart : this.uiePositionStepY.get() : dYEnd;
            
            if ~isempty(this.dX)
                cVal = sprintf( ...
                    'x: [%1.1f, %1.1f] mm', ...
                    this.dX(1), ...
                    this.dX(end) ...
                );
                
                this.uitPositionRangeX.set(cVal)
            else 
                this.uitPositionRangeY.set('x: [,] mm');
            end
            
            if ~isempty(this.dY)
        
                cVal = sprintf( ...
                    'y: [%1.1f, %1.1f] mm', ...
                    this.dY(1), ...
                    this.dY(end) ...
                ); 
                this.uitPositionRangeY.set(cVal)
            else 
                this.uitPositionRangeY.set('y: [,] mm');
            end
            
            [dXGrid, dYGrid] = meshgrid(this.dX*1e-3, this.dY*1e-3);
            
            stData = struct();
            stData.dX = dXGrid;
            stData.dY = dYGrid;
            
            if ~this.lLoading
                this.msg('updateSize() calling notify()');
                notify(this, 'eSizeChange', mic.EventWithData(stData));
            else
                this.msg('updateSize() skipping notify() because loading');
            end
            
        end
        
        
        function updateFocus(this)
            
            if ~this.lInitialized
                return
            end
            
            if this.lLoading
                return
            end
            
            % relative factor:
            % Even: for 6 do -2 -1 0 1 2 3
            % Odd:  for 7 do -3 -2 -1 0 1 2 3
            
            % this.msg('updateFocus');
            
            dRelFactor = double(1:this.uieFocusNum.get()) - double(ceil(this.uieFocusNum.get()/2));
            this.dFocus = this.uieFocusCenter.get() + this.uieFocusStep.get()*dRelFactor;
            
            if ~isempty(this.dFocus)
                cVal = sprintf( ...
                    '[%1.0f, %1.0f] nm', ...
                    this.dFocus(1), ...
                    this.dFocus(end) ...
                );
                this.uitFocusRange.set(cVal)
            else 
               this.uitFocusRange.set('Range:'); 
            end
        
        end
        
        
        function updateDose(this)
            
            if ~this.lInitialized
                return
            end
            
            if this.lLoading
                return
            end
            
            % Even: for 6 do -2 -1 0 1 2 3
            % Odd:  for 7 do -3 -2 -1 0 1 2 3
            
            % this.msg('updateDose');
            
            dRelFactor = double(1:this.uieDoseNum.get()) - double(ceil(this.uieDoseNum.get()/2));
            
            switch this.uipDoseStepType.getSelectedIndex()
                case uint8(1)
                    % %-Exponential
                    this.dDose = this.uieDoseCenter.get()*(1 + this.uieDoseStep.get() / 100).^dRelFactor;
                    
                case uint8(2)
                    %-Linear
                    dDoseStep = this.uieDoseCenter.get() * this.uieDoseStep.get() / 100;
                    this.dDose = this.uieDoseCenter.get() + dDoseStep * dRelFactor;
                    
            end
            
            if ~isempty(this.dDose)
                cVal = sprintf( ...
                    '[%1.2f, %1.2f] mJ/cm2', ...
                    this.dDose(1), ...
                    this.dDose(end) ...
                );
                this.uitDoseRange.set(cVal)
            else
               this.uitDoseRange.set('Range:'); 
            end
            
   
            
            
        end
        
        
        

    end % private
    
    
end