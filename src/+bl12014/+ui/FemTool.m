classdef FemTool < mic.Base
    
    % rcs
    
	properties
               
        
    end
    
    properties (SetAccess = private)
        
        dWidth              = 450;
        dHeight             = 250;
       
        
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
    
    end
    
    properties (Access = private)
           
        dWidthPad = 10;
        dHeightPad = 10;
                
        hPanel
        hPanelPos
        hPanelDose
        hPanelFocus
        hPanelPause
        
        uiePositionStartX
        uiePositionStepX
        uiePositionStartY
        uiePositionStepY
        uitPositionRangeX
        uitPositionRangeY
        
        uieDoseNum
        uieDoseCenter
        uieDoseStep
        uipDoseStepType
        uitDoseRange
        
        uieFocusNum
        uieFocusCenter
        uieFocusStep
        uitFocusRange
        
        uitQA
        
        dWidthPosition      = 140;
        dHeightPosition     = 170;
        dWidthDose          = 275;
        dHeightDose         = 100;
        dWidthFocus         = 275;
        dHeightFocus        = 100;
        
        uibMatrix
        
        % {logical 1x1} when calling load(), this is true so a bunch of
        % events are not dispatched while loading
        lLoading = false
        
        
        dWidthBorderPanel = 0
                
    end
    
        
    events
        
        eSizeChange
        
    end
    

    
    methods
        
        
        function this = FemTool()
            
            this.init();
            
        end
        
        % @return {struct} UI state to save
        function st = save(this)
            st = struct();
            
            st.dPositionStartX = this.uiePositionStartX.get();
            st.dPositionStepX = this.uiePositionStepX.get();
            st.dPositionStartY = this.uiePositionStartY.get();
            st.dPositionStepY = this.uiePositionStepY.get();
            
            st.u8DoseNum = this.uieDoseNum.get();
            st.dDoseCenter = this.uieDoseCenter.get();
            st.dDoseStep = this.uieDoseStep.get();
            st.u8DoseStepType = this.uipDoseStepType.getSelectedIndex();

            st.u8FocusNum = this.uieFocusNum.get();
            st.dFocusCenter = this.uieFocusCenter.get();
            st.dFocusStep = this.uieFocusStep.get();
            
        end
        
        % @param {struct} UI state to load.  See save() for info on struct
        function load(this, st)
            
            this.lLoading = true;
            this.uiePositionStartX.set(st.dPositionStartX);
            this.uiePositionStepX.set(st.dPositionStepX);
            this.uiePositionStartY.set(st.dPositionStartY);
            this.uiePositionStepY.set(st.dPositionStepY);
            
            this.uieDoseNum.set(st.u8DoseNum);
            this.uieDoseCenter.set(st.dDoseCenter);
            this.uieDoseStep.set(st.dDoseStep);
            this.uipDoseStepType.setSelectedIndex(st.u8DoseStepType);

            this.uieFocusNum.set(st.u8FocusNum);
            this.uieFocusCenter.set(st.dFocusCenter);
            this.uieFocusStep.set(st.dFocusStep);
            
            this.lLoading = false;
            
            % call updateSize() to dispatch the event
            this.updateSize();
            
            
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
            
               
            % Print button
            
            this.uibMatrix.build( ...
                this.hPanel, ...
                this.dWidthPad + this.dWidthDose + this.dWidthPad, ...
                this.dHeightPad + this.dHeightPosition + 2*this.dHeightPad, ...
                this.dWidthPosition - 40, ...
                30 ...
            );
        
            this.uitQA.build( ...
                this.hPanel, ...
                this.dWidthPad + this.dWidthDose + this.dWidthPad + this.dWidthPosition - 40, ...
                this.dHeightPad + this.dHeightPosition + 2*this.dHeightPad, ...
                40, ...
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
            dWidthPopup = 80;
            
            
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
            
            dWidthEdit = 50;
            dWidthPopup = 80;
            dTop = 20;
            
            
            % Position panel
            
            this.uiePositionStartX.build( ...
                this.hPanelPos, ...
                this.dWidthPad, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
        
            this.uiePositionStartY.build( ...
                this.hPanelPos, ...
                2*this.dWidthPad + dWidthEdit, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
        
        
            dTop = dTop + mic.Utils.dEDITHEIGHT + 2 * this.dHeightPad;
            
            this.uiePositionStepX.build( ...
                this.hPanelPos, ...
                this.dWidthPad, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
        
            this.uiePositionStepY.build( ...
                this.hPanelPos, ...
                2*this.dWidthPad + dWidthEdit, ...
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
            
            this.uiePositionStartX = mic.ui.common.Edit(...
                'cLabel', 'Start X', ...
                'fhDirectCallback', @this.onPositionStartX, ...
                'cType', 'd' ...
            );
            this.uiePositionStartY = mic.ui.common.Edit(...
                'cLabel', 'Start Y', ...
                'fhDirectCallback', @this.onPositionStartY, ...
                'cType', 'd' ...
            );
            this.uiePositionStepX = mic.ui.common.Edit( ...
                'cLabel', 'Step X', ...
                'fhDirectCallback', @this.onPositionStepX, ...
                'cType', 'd' ...
            );
            this.uiePositionStepY = mic.ui.common.Edit(...
                'cLabel', 'Step Y', ...
                'fhDirectCallback', @this.onPositionStepY, ...
                'cType', 'd' ...
            );
            this.uitPositionRangeX = mic.ui.common.Text(...
                'cVal', 'x: [,]' ...
            );
            this.uitPositionRangeY = mic.ui.common.Text(...
                'cVal', 'y: [,]' ...
            );
        
            
            this.uiePositionStartX.set(-5);
            this.uiePositionStartY.set(0);
            this.uiePositionStepX.set(2);
            this.uiePositionStepY.set(-2);
            
            %{
            addlistener(this.uiePositionStartX, 'eChange', @this.onSize);
            addlistener(this.uiePositionStartY, 'eChange', @this.onSize);
            addlistener(this.uiePositionStepX, 'eChange', @this.onSize);
            addlistener(this.uiePositionStepY, 'eChange', @this.onSize);
            %}
            
            
            
        end
        
        
        function onPositionStartX(this, src, evt)
            
            
            this.updateSize();
            
            
        end
        
        function onPositionStartY(this, src, evt)
            
            this.updateSize();
            
            
        end
        
        function onPositionStepX(this, src, evt)
            
            this.updateSize();
            
        end
        
        function onPositionStepY(this, src, evt)
            
            this.updateSize();
            
        end
        
        
        function init(this)
                        
            this.msg('init()');
            
            this.initDosePanel();
            this.initFocusPanel();
            this.initPositionPanel();
            
            this.uibMatrix = mic.ui.common.Button(...
                'fhDirectCallback', @this.onPrintMatrix, ...
                'cText', 'Print Matrix' ...
            );
        
            this.uitQA = mic.ui.common.Toggle(...
                'cTextTrue', 'X', ...
                'cTextFalse', 'OK' ...
            );
            
            % addlistener(this.uibMatrix, 'eChange', @this.onPrintMatrix);
            addlistener(this.uitQA, 'eChange', @this.onQA);

            this.lInitialized = true;
                        
        end
        
        function onPrintMatrix(this, ~, ~)
                       
            fprintf('\nFEM: [%1d, %1d]\n', length(this.dDose), length(this.dFocus));
            for k = 1:length(this.dY)
                for l = 1:length(this.dX)
                   fprintf('%1.2f, %1.0f \t', this.dDose(l), this.dFocus(k));
                end
                
                fprintf('\n');
            end
            
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
            
            this.dX = this.uiePositionStartX.get() : this.uiePositionStepX.get() : this.uiePositionStartX.get() + (double(this.uieDoseNum.get()) - 1)*this.uiePositionStepX.get();
            this.dY = this.uiePositionStartY.get() : this.uiePositionStepY.get() : this.uiePositionStartY.get() + (double(this.uieFocusNum.get()) - 1)*this.uiePositionStepY.get();
             
            if ~isempty(this.dX)
                cVal = sprintf( ...
                    'x: [%1.1f, %1.1f]', ...
                    this.dX(1), ...
                    this.dX(end) ...
                );
                
                this.uitPositionRangeX.set(cVal)
            else 
                this.uitPositionRangeY.set('x: [,]');
            end
            
            if ~isempty(this.dY)
        
                cVal = sprintf( ...
                    'y: [%1.1f, %1.1f]', ...
                    this.dY(1), ...
                    this.dY(end) ...
                ); 
                this.uitPositionRangeY.set(cVal)
            else 
                this.uitPositionRangeY.set('y: [,]');
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
            
            % relative factor:
            % Even: for 6 do -2 -1 0 1 2 3
            % Odd:  for 7 do -3 -2 -1 0 1 2 3
            
            % this.msg('updateFocus');
            
            dRelFactor = double(1:this.uieFocusNum.get()) - double(ceil(this.uieFocusNum.get()/2));
            this.dFocus = this.uieFocusCenter.get() + this.uieFocusStep.get()*dRelFactor;
            
            if ~isempty(this.dFocus)
                cVal = sprintf( ...
                    'Range: %1.0f nm to %1.0f nm', ...
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
                    'Range: %1.2f to %1.2f mJ/cm2', ...
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