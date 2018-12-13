classdef ExitSlit < mic.Base
    
    properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommExitSlit
       
        % {mic.ui.device.GetSetNumber 1x1}
        uiStage1
        uiStage2
        uiStage3
        uiStage4
        uiGap
                
        uiPositionRecaller
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 670

        dHeight = 160
        hPanel
        
        
        dWidthPanelMotors = 710
        dHeightPanelMotors = 100
        
        dWidthName = 100

        dWidthVal = 40
        dWidthDest = 40
        dWidthPadName = 5
        dWidthPadStep = 0
        dWidthStep = 30
        dWidthPadUnitEncoder = 5
        dWidthUnitTemp = 100
                
        dWidthButton = 55
        
    end
    
    properties (SetAccess = private)
        
        cName = 'exit-slit'
    end
    
    methods
        
        function this = ExitSlit(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        function cec = getSaveLoadProps(this)
            
           cec = {...
               'uiStage1', ...
               'uiStage2', ...
               'uiStage3', ...
               'uiStage4' ...
           };
            
        end
        function st = save(this)
            
            cecProps = this.getSaveLoadProps();
            
            st = struct();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                st.(cProp) = this.(cProp).save();
            end
            
            
            
        end
        
        
        function load(this, st)
            
            cecProps = this.getSaveLoadProps();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
               if isfield(st, cProp)
               	this.(cProp).load(st.(cProp))
               end
            end
            
        end
        
        
     
        
        function connectExitSlit(this, comm)
            
            device1 = bl12014.device.GetSetNumberFromExitSlitObject(...
                comm, ...
                bl12014.device.GetSetNumberFromExitSlitObject.cPROP_MOTOR_UPPER_OUT);
            
            device2 = bl12014.device.GetSetNumberFromExitSlitObject(...
                comm, ...
                bl12014.device.GetSetNumberFromExitSlitObject.cPROP_MOTOR_LOWER_OUT);

            device3 = bl12014.device.GetSetNumberFromExitSlitObject(...
                comm, ...
                bl12014.device.GetSetNumberFromExitSlitObject.cPROP_MOTOR_UPPER_IN);
            
            device4 = bl12014.device.GetSetNumberFromExitSlitObject(...
                comm, ...
                bl12014.device.GetSetNumberFromExitSlitObject.cPROP_MOTOR_LOWER_IN);
            
            deviceGap = bl12014.device.GetSetNumberFromExitSlitObject(...
                comm, ...
                bl12014.device.GetSetNumberFromExitSlitObject.cPROP_GAP);
            
            this.uiStage1.setDevice(device1);
            this.uiStage2.setDevice(device2);
            this.uiStage3.setDevice(device3);
            this.uiStage4.setDevice(device4);
            this.uiGap.setDevice(deviceGap);
            
            this.uiStage1.turnOn();
            this.uiStage2.turnOn();
            this.uiStage3.turnOn();
            this.uiStage4.turnOn();
            this.uiGap.turnOn();
            
            this.uiStage1.syncDestination();
            this.uiStage2.syncDestination();
            this.uiStage3.syncDestination();
            this.uiStage4.syncDestination();
            this.uiGap.syncDestination();
                   
            
        end
        
        function disconnectExitSlit(this)
            this.uiStage1.turnOff();
            this.uiStage2.turnOff();
            this.uiStage3.turnOff();
            this.uiStage4.turnOff();
            this.uiGap.turnOff();
            
            this.uiStage1.setDevice([]);
            this.uiStage2.setDevice([]);
            this.uiStage3.setDevice([]);
            this.uiStage4.setDevice([]);
            this.uiGap.setDevice([]);
            
          
        end
        
     

        
        function build(this, hParent, dLeft, dTop)
                        
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Exit Slit',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
            dLeft = 0;
            dTop = 15;
            dSep = 30;
                       
            this.uiCommExitSlit.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;

            this.uiGap.build(this.hPanel, dLeft, dTop);
          
            dTop = 100;
            dLeftCol1 = 0;
            dLeftCol2 = 350;
            dSep = 30;
            
            this.uiStage1.build(this.hPanel, dLeftCol1, dTop);
            dTop = dTop + dSep;
            
            this.uiStage2.build(this.hPanel, dLeftCol1, dTop);
            dTop = 100;
            
            this.uiStage3.build(this.hPanel, dLeftCol2, dTop);
            dTop = dTop + dSep;
            
            this.uiStage4.build(this.hPanel, dLeftCol2, dTop);
        end
        
        function delete(this)
  
            
        end    
        
        
        
    end
    
    methods (Access = private)
        
         
         
        
         
        function ce = getUiStageCommonProps(this)
             ce = {...
                'dWidthName', this.dWidthName, ...
                'dWidthPadName', this.dWidthPadName, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthDest', this.dWidthDest, ...
                'lShowDevice', true, ...
                'lShowInitButton', false, ...
                'lShowLabels', false, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowPlay', true, ...
                'lShowStepPos', true, ...
                'lShowUnit', false, ...
                'lShowStepNeg', true, ...
                'dWidthPadStep', this.dWidthPadStep, ...
                'lDisableMoveToDestOnDestEnter', false, ...
                'dWidthStep', this.dWidthStep ... 
           };
             
        end
               
        
        function initUiStage1(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-exit-slit-blade.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            ceProps = this.getUiStageCommonProps();
            this.uiStage1 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                ceProps{:}, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-upper-outboard', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Upper Out (6) (um)' ...
            );
        end
        
        function initUiStage2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-exit-slit-blade.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            ceProps = this.getUiStageCommonProps();
            this.uiStage2 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                ceProps{:}, ...
                'cName', sprintf('%s-lower-outboard', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Lower Out (7) (um)' ...
            );
        end
        
        function initUiStage3(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-exit-slit-blade.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            ceProps = this.getUiStageCommonProps();
            this.uiStage3 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                ceProps{:}, ...
                'cName', sprintf('%s-upper-inboard', this.cName), ...
                'config', uiConfig, ...
                'lShowLabels', false, ...
                'cLabel', 'Upper In (4) (um)' ...
            );
        end
        
        function initUiStage4(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-exit-slit-blade.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            ceProps = this.getUiStageCommonProps();
            this.uiStage4 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                ceProps{:}, ...
                'cName', sprintf('%s-lower-inboard', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Lower In (5) (um)' ...
            );
        end
        
        
        function initUiGap(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-gap-of-exit-slit.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            ceProps = this.getUiStageCommonProps();
            this.uiGap = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                ceProps{:}, ...
                'lShowLabels', true, ...
                'lShowStores', true, ...
                'dWidthStores', 150, ...
                'cName', sprintf('%s-gap', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Gap (um)' ...
            );
        end
        
        function initUiCommExitSlit(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommExitSlit = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-comm-exit-slit', this.cName), ...
                'cLabel', 'BL12Pico (PN) ' ...
            );
        
        end
        
        
        
        
        
        
        
        function initUiPositionRecaller(this)
            
            cDirThis = fileparts(mfilename('fullpath'));
            cPath = fullfile(cDirThis, '..', '..', 'save', 'position-recaller');
            this.uiPositionRecaller = mic.ui.common.PositionRecaller(...
                'cConfigPath', cPath, ... 
                'cName', [this.cName, '-position-recaller'], ...
                'hGetCallback', @this.getStageValues, ...
                'hSetCallback', @this.setStageValues ...
            );
        end
        
        
        
        
        

        function init(this)
            this.msg('init');
            
            
            this.initUiCommExitSlit();
            
            this.initUiStage1();
            this.initUiStage2();
            this.initUiStage3();
            this.initUiStage4();
            this.initUiGap();
            
            % this.initUiPositionRecaller();
        end
        
        
        % Return list of values from your app
        function dValues = getStageValues(this)
            dValues = [...
                this.uiStage1.getValRaw(), ...
                this.uiStage2.getValRaw(), ...
                this.uiStage3.getValRaw(), ...
                this.uiStage4.getValRaw() ...
            ];
        end
        
        % Set recalled values into your app
        function setStageValues(this, dValues)
            this.uiStage1.setDestRaw(dValues(1));
            this.uiStage2.setDestRaw(dValues(2));
            this.uiStage3.setDestRaw(dValues(3));
            this.uiStage4.setDestRaw(dValues(4));
        end
        
        
        
    end
    
    
end

