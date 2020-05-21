classdef ExposureMatrixA < mic.Base
    
    % rcs
    
	properties
               
       c_POSITION_TYPE_START = 'Start:';
       c_POSITION_TYPE_CENTER = 'Center:';
       
    end
    
    properties (SetAccess = private)
        
        dWidth              = 550;
        dHeight             = 230;
       
        dWidthPosition      = 250;
        dHeightPosition     = 200;
        dWidthDose          = 275;
        dHeightDose         = 100;
        dWidthFocus         = 275;
        dHeightFocus        = 100;
        
        % {double 1xn} list of dose of each exposure
        dDose 
        
        % {double 1xn} list of wafer x position of each exposure
        dX                 
        
        % {double 1xn} list of wafer y position of each exposure
        dY  
        
        dXGrid
        dYGrid
        dDoseGrid
        
        % {logical 1x1} set to true after all UI elements are initialized
        lInitialized = false    
    end
    
    properties (Access = private)
           
        dWidthPad = 10;
        dHeightPad = 5;
                
        hPanel
        hPanelPos
        hPanelDose
        
        uiePositionNumX
        uiePositionNumY
        
        uipPositionType 
        uiePositionX
        uiePositionStepX
        uiePositionY
        uiePositionStepY
        
        uitPositionNumLabel
        uitPositionStepLabel
        uitPositionRangeX
        uitPositionRangeY
        
        uieDoseNum
        uieDoseCenter
        uieDoseStep
        uipDoseStepType
        uitDoseRange
        
        uibPrintMatrix
        uibPrintSequence
        
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
        
        
        function this = ExposureMatrixA()
            this.init();
        end
        
        function st = savePublic(this)
            st = struct();
            st.dX = this.dX;
            st.dY = this.dY;
            st.dDose = this.dDose;
        end

        function ce = getPropsSaved(this)
            ce = {...
                'uiePositionNumX', ...
                'uiePositionNumY', ...
                'uipPositionType', ...
                'uiePositionX', ...
                'uiePositionY', ...
                'uiePositionStepX', ...
                'uiePositionStepY', ...
                'uieDoseCenter', ...
                'uieDoseStep', ...
                'uipDoseStepType' ...
            };
        end
        
        
        function d = getStepX(this)
            d = this.uiePositionStepX.get();
        end
        
        function d = getStepY(this)
            d = this.uiePositionStepY.get();
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
                        
            this.lLoading = true;
             
            cecProps = this.getPropsSaved();
            for n = 1 : length(cecProps)
               cProp = cecProps{n};
               if isfield(st, cProp)
                   if this.hasProp( cProp )
                        this.(cProp).load(st.(cProp))
                   end
               end
            end
            
            this.lLoading = false;
            this.update();
            
        end
        
        
        function build(this, hParent, dLeft, dTop)
                        
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', '', ... 'Exposure Matrix',...
                'Clipping', 'on',...
                'BorderWidth', this.dWidthBorderPanel, ...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );        
            
			drawnow;
            
            this.buildPanelDose();
            this.buildPanelPosition();
            
                       
            % Print button
 
            dWidth = 120;
            
            dLeft = 10;
            dTop = 150;
            
            this.uibPrintMatrix.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                24 ...
            );
        
            dTop = dTop + 30;
            this.uibPrintSequence.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                24 ...
            );
            
        
            dLeft = dLeft + dWidth + 10;
            dWidth = 40;
            
            this.updateDose();
            this.updateSize();
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
                        
        end
                    

    end
    
    methods (Access = private)
        
        function buildPanelDose(this)
            
            dTop = 10;
            
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
            dWidthPopup = 90;
            
            % Dose Panel
            
            dLeft = this.dWidthPad;
            dTop = 20;
            
            this.uieDoseNum.build( ...
                this.hPanelDose, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
            this.uieDoseNum.disable();

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
            dLeft = dLeft + dWidthEdit;
            
            this.uipDoseStepType.build( ...
                this.hPanelDose, ...
                dLeft, ...
                dTop + 18, ...
                dWidthPopup, ...
                mic.Utils.dEDITHEIGHT ...
            );
        
            dLeft = this.dWidthPad;
            dTop = dTop + mic.Utils.dEDITHEIGHT + 12 + this.dHeightPad; % 12 for labels
            
            this.uitDoseRange.build( ...
                this.hPanelDose, ...
                dLeft, ...
                dTop, ...
                this.dWidthDose - 2 * this.dWidthPad, ...
                mic.Utils.dTEXTHEIGHT ...
            );
        
        
        end
        
        
        function buildPanelPosition(this)
            
            dTop = 10;
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
            
            % Num
            this.uitPositionNumLabel.build(...
                this.hPanelPos, ...
                dLeft + 50, ...
                dTop + 20, ...
                70, ...
                mic.Utils.dEDITHEIGHT ...
            )
            dLeft = dLeft + dWidthPopup + this.dWidthPad;
            this.uiePositionNumX.build( ...
                this.hPanelPos, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
        
            dLeft = dLeft + dWidthEdit + this.dWidthPad;
            this.uiePositionNumY.build( ...
                this.hPanelPos, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
        
            dTop = dTop + mic.Utils.dEDITHEIGHT + 12 + this.dHeightPad; %15 for labels
      
        
            % Start/Center
            dLeft =  this.dWidthPad;
            
            this.uipPositionType.build(...
                this.hPanelPos, ...
                dLeft, ...
                dTop + 5, ...
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
        
        
            dTop = dTop + mic.Utils.dEDITHEIGHT + this.dHeightPad;
            
            % Step
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
            
            this.uiButtonLoadDefault.build(this.hPanelPos, 110, 140, 110, 24);
            
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
                'ceOptions', {'mj/cm2', '%-exp', '%-lin'}, ...
                'fhDirectCallback', @this.onDoseStepType, ...
                'cLabel', 'Step Type', ...
                'lShowLabel', false ...
            );
            this.uitDoseRange = mic.ui.common.Text(...
                'cVal', 'Range: []' ...
            );
            
            this.uieDoseNum.set(uint8(9));
            this.uieDoseCenter.set(15);
            this.uieDoseStep.set(5);
            
            
            
        end
        
        function onDoseNum(this, src, evt)
            % Programatically set. don't act on it.
        end
        
        function onDoseCenter(this, src, evt)
            this.update();
        end
        
        function onDoseStep(this, src, evt)
            this.update();
        end
        
        function onDoseStepType(this, src, evt)
            this.update();
        end
        
        
        
        function initPositionPanel(this)
            

            this.uipPositionType = mic.ui.common.Popup(...
                'ceOptions', {this.c_POSITION_TYPE_START, this.c_POSITION_TYPE_CENTER}, ...
                'fhDirectCallback', @this.onPositionType, ...
                'cLabel', '', ...
                'lShowLabel', false ...
            );
        
            this.uiePositionNumX = mic.ui.common.Edit(...
                'cLabel', 'X', ...
                'fhDirectCallback', @this.onPositionNumX, ...
                'cType', 'u8' ...
            );
            

            this.uiePositionNumY = mic.ui.common.Edit(...
                'cLabel', 'Y', ...
                'fhDirectCallback', @this.onPositionNumY, ...
                'cType', 'u8' ...
            );
        
            
            this.uiePositionX = mic.ui.common.Edit(...
                'cLabel', 'X', ...
                'lShowLabel', false, ...
                'fhDirectCallback', @this.onPositionX, ...
                'cType', 'd' ...
            );
            this.uiePositionY = mic.ui.common.Edit(...
                'cLabel', 'Y', ...
                'lShowLabel', false, ...
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
        
        
            this.uitPositionNumLabel = mic.ui.common.Text(...
                'cVal', 'Num:' ...
            );
        
            this.uitPositionStepLabel = mic.ui.common.Text(...
                'cVal', 'Step:' ...
            );
        
            this.uiePositionNumX.set(uint8(5));
            this.uiePositionNumX.setMin(uint8(1));
            this.uiePositionNumX.setMax(uint8(100));
            
            this.uiePositionNumY.set(uint8(5));
            this.uiePositionNumY.setMin(uint8(1));
            this.uiePositionNumY.setMax(uint8(100));
            
            this.uiePositionX.set(0);
            this.uiePositionY.set(0);
            this.uiePositionStepX.set(1);
            this.uiePositionStepY.set(1);
            
        end
        
        
        function onPositionNumX(this, src, evt)
            this.update();
        end
        
        function onPositionNumY(this, src, evt)
            
            this.update();
        end
        
        function onPositionX(this, src, evt)
            this.update();
        end
        
        function onPositionY(this, src, evt)
            this.update();
        end
        
        function onPositionStepX(this, src, evt)
            this.update();
        end
        
        function onPositionStepY(this, src, evt)
            this.update();
        end
        
        function onPositionType(this, src, evt)
            this.update();
        end
        
        
        function init(this)
                        
            this.msg('init()');
            
            this.initDosePanel();
            this.initPositionPanel();
            
            this.uibPrintMatrix = mic.ui.common.Button(...
                'fhDirectCallback', @this.onPrintMatrix, ...
                'cText', 'Echo Matrix' ...
            );
        
            this.uibPrintSequence = mic.ui.common.Button(...
                'fhDirectCallback', @this.onPrintSequence, ...
                'cText', 'Echo Sequence' ...
            );
        
            this.lInitialized = true;
            
            this.uiButtonLoadDefault = mic.ui.common.Button(...
                'fhOnClick', @this.onClickUiButtonLoadDefault, ...
                'cText', 'Load Defaults' ...
            ); 
        
            this.update();
            
                        
        end
        
        function onClickUiButtonLoadDefault(this, ~, ~)
            
            this.uiePositionNumX.set(uint8(5));
            this.uiePositionNumY.set(uint8(5));
            this.uiePositionX.set(6.5);
            this.uiePositionY.set(-4.5);
            this.uiePositionStepX.set(3);
            this.uiePositionStepY.set(3);
            
        end
        
        function onPrintSequence(this, ~, ~)
            
            disp('x (mm)');
            disp(this.dX * 1e3);
            disp('y (mm)');
            disp(this.dY * 1e3);
            disp('dose (mJ/cm2)');
            disp(this.dDose);
            
        end
        
        function onPrintMatrix(this, ~, ~)
            
            disp('x (mm)');
            disp(this.dXGrid * 1e3);
            disp('y (mm)');
            disp(this.dYGrid * 1e3);
            disp('dose (mJ/cm2)');
            disp(this.dDoseGrid);
            
            return

            
            [rows, cols] = size(this.dXGrid);
            for row = 1 : rows
                for col = 1 : cols
                    fprintf('%1.2f mm, %1.2f mm, %1.2f mJ/cm2\t', ...
                        this.dXGrid(row, col), ...
                        this.dYGrid(row, col), ...
                        this.dDoseGrid(row, col) ...
                    );
                end
                fprintf('\n');
            end
            
        end
        
        function onCloseRequestFcn(this, src, evt)
           
        end
        
 
        function updateSize(this)
             
            if ~this.lInitialized
                return
            end
            
            if this.lLoading
                return
            end
            
            this.uieDoseNum.set(this.uiePositionNumX.get() * this.uiePositionNumY.get());
            
            dNumX = double(this.uiePositionNumX.get());
            dNumY = double(this.uiePositionNumY.get());
            
            switch this.uipPositionType.getSelectedValue()
                case this.c_POSITION_TYPE_START
                    
                    dXStart = this.uiePositionX.get();
                    dYStart = this.uiePositionY.get();
                    dXEnd =  this.uiePositionX.get() +  (dNumX - 1)*this.uiePositionStepX.get();
                    dYEnd = this.uiePositionY.get() + (dNumY - 1)*this.uiePositionStepY.get();
                    
                    
                case this.c_POSITION_TYPE_CENTER
                    % Center
                   
                    % X positions (dose)
                    if mod(dNumX, 2) == 0
                        % Even
                        dXStart = this.uiePositionX.get() - this.uiePositionStepX.get() * dNumX / 2;
                        dXEnd = this.uiePositionX.get() + this.uiePositionStepX.get() * (dNumX / 2 - 1);
                    else
                        % Odd
                        dXStart = this.uiePositionX.get() - this.uiePositionStepX.get() * (dNumX - 1)/2;
                        dXEnd = this.uiePositionX.get() + this.uiePositionStepX.get() * (dNumX - 1)/2;
                    end
                    
                    % Y positions (focus)
                    if mod(dNumY, 2) == 0
                        % Even
                        dYStart = this.uiePositionY.get() - this.uiePositionStepY.get() *  dNumY / 2;
                        dYEnd = this.uiePositionY.get() + this.uiePositionStepY.get() * (dNumY / 2 - 1);
                    else
                        % Odd
                        dYStart = this.uiePositionY.get() - this.uiePositionStepY.get() * (dNumY - 1)/2;
                        dYEnd = this.uiePositionY.get() + this.uiePositionStepY.get() * (dNumY - 1)/2;
                    end
                    
            end % Switch
            
            dX = linspace(dXStart, dXEnd, dNumX);
            dY = linspace(dYStart, dYEnd, dNumY);
            
            if ~isempty(dX)
                cVal = sprintf( ...
                    'x: [%1.1f, %1.1f] mm', ...
                    dX(1), ...
                    dX(end) ...
                );
                this.uitPositionRangeX.set(cVal)
            else 
                this.uitPositionRangeY.set('x: [,] mm');
            end
            
            if ~isempty(dY)
                cVal = sprintf( ...
                    'y: [%1.1f, %1.1f] mm', ...
                    dY(1), ...
                    dY(end) ...
                ); 
                this.uitPositionRangeY.set(cVal)
            else 
                this.uitPositionRangeY.set('y: [,] mm');
            end
            
            [this.dXGrid, this.dYGrid] = meshgrid(dX*1e-3, dY*1e-3);
            
            dSize = [1, dNumX * dNumY];
            this.dX = reshape(this.dXGrid', dSize);
            this.dY = reshape(this.dYGrid', dSize);
            
%             dSize = [1, dNumX * dNumY];
%             this.dX = reshape(this.dXGrid, dSize);
%             this.dY = reshape(this.dYGrid, dSize);
            
        end
        
        function update(this)
            
            this.updateSize();
            this.updateDose();
            
            stData = struct();
            stData.dX = this.dX;
            stData.dY = this.dY;
            stData.dDose = this.dDose;
            
            if ~this.lLoading
                this.msg('updateSize() calling notify()');
                notify(this, 'eSizeChange', mic.EventWithData(stData));
            else
                this.msg('updateSize() skipping notify() because loading');
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
                    % absolute step 
                    this.dDose = this.uieDoseCenter.get() + dRelFactor * this.uieDoseStep.get();
                    
                case uint8(2)
                    % %-Exponential
                    this.dDose = this.uieDoseCenter.get()*(1 + this.uieDoseStep.get() / 100).^dRelFactor;
                    
                case uint8(3)
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
            
            rows = this.uiePositionNumY.get();
            cols = this.uiePositionNumX.get();
            
            % need to play a little trick to get the dose to increase
            % across columns rather than rows.
            this.dDoseGrid = reshape(this.dDose, [cols, rows])';
            
        end
        
        
        

    end % private
    
    
end