classdef M1 < mic.Base
    
    properties
        
   
        
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 680
        dHeight = 240

        dWidthName = 75
        dWidthUnit = 90

        
        cName = 'M1'
        
        lShowRange = true
        lShowStores = false
        
      
        lIsWobbling = false

        
        % {mic.ui.device.GetSetNumber 1x1}
        galilTCP

        uigsMotor1
        uigsMotor2
        uigsMotor3
        uigsCoupledMove

        uigslIsWobbling

        uibZeroEncoders
        uibStop
        
        hPanel

        uieMotor1Pos1
        uieMotor1Pos2
        uieMotor2Pos1
        uieMotor2Pos2
        uieMotor1Dwell
        uieMotor2Dwell
        uieWobbleDelay

        uieWobbleAr
        uieDwellAr


        uibSetWobblePos1
        uibSetWobblePos2

        uieMotor1WobbleDelay
        uieMotor2WobbleDelay

        uibStartWobble
        uibStopWobble

        uiWobbleWorkingMode

        % uieWobbleLC
        
        
        % Store position locally so we don't need to do as many requests:
        dPos = [0,0, 0]


        % Uniformity vectors:
        dCoefRat = 1;
 
        
    end
    
    properties (Access = private)
        
        clock
        uiClock
        hardware
        

    end
    
    methods
        
        function this = M1(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end

            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            
            
            this.init();
        
        end
        
        
        function turnOn(this)
            
            
            
        end
        
        function turnOff(this)
          
            
        end

        function cb(this, src, evt)
            this.msg('cb()');
            switch src
                case this.uibSetWobblePos1
                    this.uieMotor1Pos1.set(this.uigsMotor1.getValRaw());
                    this.uieMotor2Pos1.set(this.uigsMotor2.getValRaw());
                case this.uibSetWobblePos2
                    this.uieMotor1Pos2.set(this.uigsMotor1.getValRaw());
                    this.uieMotor2Pos2.set(this.uigsMotor2.getValRaw());
                case this.uibStartWobble

                    this.startWobble();

                case this.uibStopWobble
                    this.stopWobble();
            end
        end

        function setWobbleParamsFromCombo(this, dCoords, dCoeff)

        
            dStartDwell = 100;

            dwellStr = [];
            for i = 1:length(dCoeff)
                dwellStr = [dwellStr, sprintf('%0.1f', dStartDwell * dCoeff(i))];
                if i < length(dCoeff)
                    dwellStr = [dwellStr, ', '];
                end
            end
            dwellStr = ['[', dwellStr, ']'];
            this.uieDwellAr.set(dwellStr);

            % Generate coords string:
            coordStr = [];
            for i = 1:length(dCoords)
                coordStr = [coordStr, sprintf('%d, %d', floor(dCoords(i, 1)), floor(dCoords(i, 2)))];
                if i < length(dCoords)
                    coordStr = [coordStr, '; '];
                end
            end
            coordStr = ['[', coordStr, ']'];

            this.uieWobbleAr.set(coordStr);
            
        end
        

        function setWobbleDelayFromPeriod(this, dPeriod, dCoeff)

            dCoeff = dCoeff / sum(dCoeff);
            dwellStr = [];
            for i = 1:length(dCoeff)
                dwellStr = [dwellStr, sprintf('%0.1f', dPeriod * dCoeff(i))];
                if i < length(dCoeff)
                    dwellStr = [dwellStr, ', '];
                end
            end
            dwellStr = ['[', dwellStr, ']'];
            this.uieDwellAr.set(dwellStr);


        end

        function toggleWobble(this, lVal)
            if lVal
                this.startWobble();
            else
                this.stopWobble();
            end
        end

        function startWobble(this)
            this.lIsWobbling = true;

            dDwells = eval(this.uieDwellAr.get());
            dCoords = eval(this.uieWobbleAr.get());

            % Set up the wobble program:
            dNumPos = length(dDwells);
            this.hardware.getGalilM1().writeParameter('NUM_POS',dNumPos);
            for k = 1:length(dDwells)
                this.hardware.getGalilM1().writeParameter(sprintf('POS_B%d', k - 1), dCoords(k, 1));
                this.hardware.getGalilM1().writeParameter(sprintf('POS_C%d', k - 1), dCoords(k, 2));
                this.hardware.getGalilM1().writeParameter(sprintf('DWELL%d', k - 1), dDwells(k));
            end
            
           

            this.hardware.getGalilM1().writeParameter('speed', 90000);

            this.hardware.getGalilM1().runProgram('wobbleAr');

        end

        function stopWobble(this)
            this.lIsWobbling = false;

            this.hardware.getGalilM1().stopAxisMove();

             % Reset axes to 0:
             this.hardware.getGalilM1().moveAxisAbsolute(1, 0);
             this.hardware.getGalilM1().moveAxisAbsolute(2, 0);
        end
        
        function build(this, hParent, dLeft, dTop)


            
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'M1 control',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );

            hpIsWobbling = uipanel(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Title', 'Executing wobble',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                    350 ...
                        15 ...
                        270 ...
                        60], this.hPanel) ...
            );
        
            dLeft = 0;
            dTop = 15;
            
            this.uigslIsWobbling.build(hpIsWobbling, dLeft, dTop);

        
			drawnow;            

            dTop = 15;
            dLeft = 10;
            dSep = 40;

            dColB1 = 430;
            dColB2 = 540;
            dColB3 = 600;


            this.uiWobbleWorkingMode.build(this.hPanel, dLeft, dTop);

            % this.uibStartWobble.build(this.hPanel, dLeft + dColB1, dTop + 20,  100, 30);
            % this.uibStopWobble.build(this.hPanel, dLeft + dColB2, dTop+ 20,  100, 30);


            dTop = dTop + 80
            
            this.uigsMotor1.build(this.hPanel, dLeft, dTop - 8);
            this.uieWobbleAr.build(this.hPanel, dLeft + dColB1, dTop - 17,  200, 25);
            % this.uieMotor1Pos1.build(this.hPanel, dLeft + dColB1, dTop - 17,  90, 25);
            % this.uieMotor1Pos2.build(this.hPanel, dLeft + dColB2, dTop - 17,  90, 25);

            dTop = dTop + dSep;
            
            this.uigsMotor2.build(this.hPanel, dLeft, dTop - 8);
            this.uieDwellAr.build(this.hPanel, dLeft + dColB1, dTop - 17,  200, 25);
            % this.uieMotor2Pos1.build(this.hPanel,  dLeft + dColB1, dTop - 17,  90, 25);
            % this.uieMotor2Pos2.build(this.hPanel, dLeft + dColB2, dTop - 17,  90, 25);
            
            
            dTop = dTop + dSep;
            this.uigsMotor3.build(this.hPanel, dLeft, dTop - 8);

            % this.uieMotor1Dwell.build(this.hPanel, dLeft + dColB1, dTop - 17,  90, 25);
            % this.uieMotor2Dwell.build(this.hPanel, dLeft + dColB2, dTop - 17,  90, 25);

            % this.uibSetWobblePos1.build(this.hPanel, dLeft + dColB1, dTop,  90, 30);
            % this.uibSetWobblePos2.build(this.hPanel, dLeft + dColB2, dTop,  90, 30);
            
            % dTop = dTop + dSep;
            % this.uieWobbleDelay.build(this.hPanel, dLeft + dColB1, dTop - 17,  90, 25);




            % this.uieWobbleLC.build(this.hPanel, dLeft, dTop,  100, 30);
            % this.uibZeroEncoders.build(this.hPanel, dLeft, dTop,  100, 30);
            % dTop = dTop + dSep;
            % this.uigsCoupledMove.build(this.hPanel, dLeft, dTop);
            
           
           
           
            

            
        end

        function disableControls(this)

            % Needs to make sure UI is disabled when CLC is running:
            this.uigsMotor1.disable();
            this.uigsMotor2.disable();
            this.uigsMotor3.disable();
            this.uibSetWobblePos1.disable();
            this.uibSetWobblePos2.disable();
            this.uigslIsWobbling.disable();
        end

        function enableControls(this)
            this.uigsMotor1.enable();
            this.uigsMotor2.enable();
            this.uigsMotor3.enable();
            this.uibSetWobblePos1.enable();
            this.uibSetWobblePos2.enable();
            this.uigslIsWobbling.enable();
        end

        function checkWorkingMode(this)
            if ~this.uiWobbleWorkingMode.get() 
%                 this.disableControls(); temporarily force enable cause we
%                 don't trust CLC
                this.enableControls();

            else
                this.enableControls();
            end
        end
        
        function delete(this)
            try
                this.uiClock.remove(this.id());
            catch
                
            end
            
            this.msg('delete');
        end  
        
   
        function st = save(this)
            st = struct();

            st.uigsMotor1 = this.uigsMotor1.save();
            st.uigsMotor2 = this.uigsMotor2.save();
            st.uigsMotor3 = this.uigsMotor3.save();

            st.uieMotor1Pos1 = this.uieMotor1Pos1.get();
            st.uieMotor1Pos2 = this.uieMotor1Pos2.get();
            st.uieMotor2Pos1 = this.uieMotor2Pos1.get();
            st.uieMotor2Pos2 = this.uieMotor2Pos2.get();
            st.uieWobbleDelay = this.uieWobbleDelay.get();

        end
        
        function load(this, st)
            % if isfield(st, 'uiRow')
            %     this.uiRow.load(st.uiRow)
            % end
            
            if isfield(st, 'uigsMotor1')
                this.uigsMotor1.load(st.uigsMotor1)
            end

            if isfield(st, 'uigsMotor2')
                this.uigsMotor2.load(st.uigsMotor2)
            end

            if isfield(st, 'uigsMotor3')
                this.uigsMotor3.load(st.uigsMotor3)
            end

            if isfield(st, 'uieMotor1Pos1')
                this.uieMotor1Pos1.set(st.uieMotor1Pos1)
            end

            if isfield(st, 'uieMotor1Pos2')
                this.uieMotor1Pos2.set(st.uieMotor1Pos2)
            end

            if isfield(st, 'uieMotor2Pos1')
                this.uieMotor2Pos1.set(st.uieMotor2Pos1)
            end

            if isfield(st, 'uieMotor2Pos2')
                this.uieMotor2Pos2.set(st.uieMotor2Pos2)
            end

            if isfield(st, 'uieWobbleDelay')
                this.uieWobbleDelay.set(st.uieWobbleDelay)
            end
            
         
        end
        
        
        function refreshPositions(this)
            this.dPos = this.hardware.getGalilM1().getAxisPosition(1:3);
        end
        
        function d = getPos(this, channel)
%             this.dPos/-8000

            if length(this.dPos) < channel
                d = 0;
                return
            end
            
            d = this.dPos(channel);
        end
        
        function init(this)   

            % Initialize galil
            this.galilTCP = this.hardware.getGalilM1();

            this.uiWobbleWorkingMode = bl12014.ui.SMSMoxaComm(...
                'cName', [this.cName, 'wobble-working-mode'], ...
                'uiClock', this.uiClock, ...
                'hardware', this.hardware, ...
                'clock', this.clock ...
            );


            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-M1.json' ...
            );

            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );

            this.uigsMotor1 =   mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                'dWidthName', this.dWidthName, ... 
                'lShowInitButton', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowUnit', true, ...
                'dWidthUnit', this.dWidthUnit, ...
                'lUseFunctionCallbacks', true, ...
                'lShowLabels', false, ...
                'fhIsVirtual', @() false, ...
                'config', uiConfig, ...
                'fhGet', @()this.getPos(1), ...
                'fhSet', @(dVal) this.hardware.getGalilM1().moveAxisAbsolute(1, dVal), ...
                'cName', [this.cName, 'motor-1'], ...
                'cLabel', 'M1 Motor A' ...
            );

            this.uigsMotor2 =   mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                'dWidthName', this.dWidthName, ... 
                'lShowInitButton', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowUnit', true, ...
                    'dWidthUnit', this.dWidthUnit, ...
                'lUseFunctionCallbacks', true, ...
                'lShowLabels', false, ...
                'fhIsVirtual', @() false, ...
                'config', uiConfig, ...
                'fhGet', @()this.getPos(2), ...
                'fhSet', @(dVal) this.hardware.getGalilM1().moveAxisAbsolute(2, dVal), ...
                'cName', [this.cName, 'motor-2'], ...
                'cLabel', 'M1 Motor B' ...
            );

            
            % cPathConfig = fullfile(...
            %     bl12014.Utils.pathUiConfig(), ...
            %     'get-set-number', ...
            %     'config-M1_d.json' ...
            % );

            % uiConfig = mic.config.GetSetNumber(...
            %     'cPath',  cPathConfig ...
            % );

            this.uigsMotor3 =   mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                'dWidthName', this.dWidthName, ... 
                'lShowInitButton', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowUnit', true, ...
                    'dWidthUnit', this.dWidthUnit, ...
                'lUseFunctionCallbacks', true, ...
                'lShowLabels', false, ...
                'fhIsVirtual', @() false, ...
                'config', uiConfig, ...
                'fhGet', @()this.getPos(3), ...
                'fhSet', @(dVal) this.hardware.getGalilM1().moveAxisAbsolute(3, dVal), ...
                'cName', [this.cName, 'motor-3'], ...
                'cLabel', 'M1 Motor C' ...
            );


            this.uigsCoupledMove =   mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                'dWidthName', this.dWidthName, ... 
                'lShowInitButton', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowUnit', true, ...
                'lUseFunctionCallbacks', true, ...
                'lShowLabels', false, ...
                'fhIsVirtual', @() false, ...
                'config', uiConfig, ...
                'fhGet', @() this.getCoupledPos(), ...
                'fhSet', @(dVal) this.makeCoupledMove(dVal), ...
                'cName', [this.cName, 'motor-coupled'], ...
                'cLabel', 'M1 Tilt' ...
            );

            this.uieMotor1Pos1 = mic.ui.common.Edit('cLabel', 'Wobble Pos 1', 'cType', 'd');
            this.uieMotor1Pos2 = mic.ui.common.Edit('cLabel', 'Wobble Pos 2', 'cType', 'd');
            this.uieMotor2Pos1 = mic.ui.common.Edit('cLabel', 'Wobble Pos 1', 'cType', 'd');
            this.uieMotor2Pos2 = mic.ui.common.Edit('cLabel', 'Wobble Pos 2', 'cType', 'd');
            this.uieMotor1Dwell = mic.ui.common.Edit('cLabel', 'Dwell 1 (ms)', 'cType', 'd');
            this.uieMotor2Dwell = mic.ui.common.Edit('cLabel', 'Dwell 2 (ms)', 'cType', 'd');
            this.uieWobbleDelay = mic.ui.common.Edit('cLabel', 'Move Latency (ms)', 'cType', 'd');

            this.uieWobbleAr = mic.ui.common.Edit('cLabel', 'Wobble coordinates', 'cType', 'c');
            this.uieDwellAr = mic.ui.common.Edit('cLabel', 'Dwells', 'cType', 'c');

            this.uieWobbleAr.set('[]');
            this.uieDwellAr.set('[]');

            % If the first time then set values:
            if (this.uieMotor1Pos1.get() == 0 ...
                && this.uieMotor1Pos2.get() == 0 ...
                && this.uieMotor2Pos1.get() == 0 ...
                && this.uieMotor2Pos2.get() == 0 ...
                && this.uieWobbleDelay.get() == 0)

                this.uieMotor1Pos1.set(-1500);
                this.uieMotor1Pos2.set(1500);
                this.uieMotor2Pos1.set(1500);
                this.uieMotor2Pos2.set(-1500);
                this.uieWobbleDelay.set(500);
                this.uieMotor1Dwell.set(1000);
                this.uieMotor2Dwell.set(1000);
            end

            this.uibSetWobblePos1 = mic.ui.common.Button('cText', 'Set Wobble Pos 1' , 'fhDirectCallback', @this.cb);
            this.uibSetWobblePos2 = mic.ui.common.Button('cText', 'Set Wobble Pos 2' , 'fhDirectCallback', @this.cb);
            
            this.uieMotor1WobbleDelay = mic.ui.common.Edit('cLabel', 'Wobble Delay 1', 'cType', 'd');
            this.uieMotor2WobbleDelay = mic.ui.common.Edit('cLabel', 'Wobble Delay 2', 'cType', 'd');

            this.uibStartWobble = mic.ui.common.Button('cText', 'Execute Wobble' , 'fhDirectCallback', @this.cb);
            this.uibStopWobble = mic.ui.common.Button('cText', 'Stop Wobble' , 'fhDirectCallback',  @this.cb);

            ceVararginCommandToggle = {...
                'cTextTrue', 'Stop', ...
                'cTextFalse', 'Start' ...
            };

            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-logical', ...
                'config-sms-moxa.json' ...
            );
        
            config = mic.config.GetSetLogical(...
                'cPath',  cPathConfig ...
            );

            this.uigslIsWobbling =  mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', false, ...
                'lShowLabels', false, ...
                'lShowInitButton', false, ...
                'fhGet', @() this.lIsWobbling, ...
                'fhSet', @(lVal) this.toggleWobble(lVal), ...
                'lUseFunctionCallbacks', true, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'cName', [this.cName, 'execute-wobble'], ...
                'cLabel', 'M1 Wobbler' ...
            );
            % this.uieWobbleLC = mic.ui.common.Edit('cLabel', 'Wobble LC', 'cType', 'c');

            % this.uieWobbleLC.setVal('[1, 1]');

            this.uibZeroEncoders = mic.ui.common.Button('cText', 'Reset encoders' , 'fhDirectCallback', @(src,evt) this.zeroEncoders());
            this.uibStop = mic.ui.common.Button('cText', 'Stop' , 'fhDirectCallback', @(src,evt) this.hardware.getGalilM1().stop());

            
           
% 
%             this.uiClock.add(...
%                 @this.checkWorkingMode, ...
%                 this.id(), ...
%                 1 ...
%             );
%         
            this.uiClock.add(...
                @this.refreshPositions, ...
                [this.id(), '-refresh'], ...
                0.5 ...
                );
            
            
        end

        function makeCoupledMove(this, dVal)
            dPos(1) = this.hardware.getGalilM1().getAxisPosition(1);
            dPos(2) = this.hardware.getGalilM1().getAxisPosition(2);

            dTarget = dPos + [1;-1]*dVal;

            this.hardware.getGalilM1().moveAbs(1, dTarget(1));
            this.hardware.getGalilM1().moveAbs(2, dTarget(2));
        end

        function dPos = getCoupledPos(this)
            dPos(1) = this.hardware.getGalilM1().getAxisPosition(1);
            dPos(2) = this.hardware.getGalilM1().getAxisPosition(2);

            dPos = (dPos(1) - dPos(2))/2;
        end

        function zeroEncoders(this)

            a = questdlg('Are you sure you want to zero the encoders? This cannot be undone', 'Zero Encoders', 'Yes', 'No', 'No');
            if strcmp(a, 'Yes')
                this.hardware.getGalilM1().zeroEncoders();
            end
        end
        
        
        
        
    end
    
    
end

