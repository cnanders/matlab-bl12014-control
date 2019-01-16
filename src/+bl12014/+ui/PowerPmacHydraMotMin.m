classdef PowerPmacHydraMotMin < mic.Base
    
    properties

        % {mic.ui.device.GetSetNumber 1x1}}
        ui1
        ui2
        ui3
        ui4
        ui5
        
        uiPositionRecaller
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDeltaTauPowerPmac
        uiWorkingMode
        uiSequenceSetAll
        
    end
    
    properties (SetAccess = private)
        
        dWidth = 820
        dHeight = 300
        
        cName = 'power-pmac-hydra-mot-min'
        
        lShowStores = false
        lShowZero = false
        lShowRel = false
        
        commDeltaTau

    end
    
    properties (Access = private)
        
        clock
        uiClock
        
        hPanel
        
        dWidthName = 70
        dWidthUnit = 80
        dWidthVal = 75
        dWidthPadUnit = 0 % 280

        
    end
    
    methods
        
        function this = PowerPmacHydraMotMin(varargin)
            
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
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
            
            
        
        end
        
       
        
        
        
        function connectDeltaTauPowerPmac(this, comm)
            
            import bl12014.device.GetSetNumberFromDeltaTauPowerPmac

            
            this.uiWorkingMode.connectDeltaTauPowerPmac(comm);
            
            device = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cMOT_MIN_RCX);
            this.ui1.setDevice(device);
            this.ui1.turnOn();
            
            device = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cMOT_MIN_RCY);
            this.ui2.setDevice(device);
            this.ui2.turnOn();
            
            device = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cMOT_MIN_WCX);
            this.ui3.setDevice(device);
            this.ui3.turnOn();
            
            device = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cMOT_MIN_WCY);
            this.ui4.setDevice(device);
            this.ui4.turnOn();
            
            device = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cMOT_MIN_LSIX);
            this.ui5.setDevice(device);
            this.ui5.turnOn();
            

          
        end
        
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.ui1.turnOff();
            this.ui2.turnOff();
            this.ui3.turnOff();
            this.ui4.turnOff();
            this.ui5.turnOff();
            
            this.ui1.setDevice([]);
            this.ui2.setDevice([]);
            this.ui3.setDevice([]);
            this.ui4.setDevice([]);
            this.ui5.setDevice([]);
            
            this.uiWorkingMode.disconnectDeltaTauPowerPmac();
        end
        
        function build(this, hParent, dLeft, dTop)
                                    
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'PPMAC Hyrda Mot Min',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
            dTop = 20;
            dLeft = 10;
            dSep = 24;
            
                       
            this.uiCommDeltaTauPowerPmac.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 5 + dSep;
            
            this.ui1.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.ui2.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui3.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui4.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui5.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            dTop = dTop + 20;
            this.uiSequenceSetAll.build(this.hPanel, dLeft, dTop, 280);
            
            dLeft = 320;
            dTop = 20;
            this.uiPositionRecaller.build(this.hPanel, dLeft, dTop, 330, 230);
            
           
            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end    
        
        
    end
    
    methods (Access = private)
           
        
        function d = getMotMinRcx(this)
            d = this.ui1.get();
        end
        
        function d = getMotMinRcy(this)
            d = this.ui2.get();
        end
                 
        function d = getMotMinWcx(this)
            d = this.ui3.get();
        end
        
        function d = getMotMinWcy(this)
            d = this.ui4.get();
        end
                
        function d = getMotMinLsix(this)
            d = this.ui5.get();
        end
        
        % Returns {double 1x5} list of mot min values of wcx, wcy, rcx,
        % rcy, lsix in that order
        
        function d = getMotMin(this)
            d = [
               this.ui1.get() ...
               this.ui2.get() ...
               this.ui3.get() ...
               this.ui4.get() ...
               this.ui5.get() ...
            ];
        end
        
        function onCloseRequest(this, src, evt)
            this.msg('HeightSensorLEDs.closeRequestFcn()');
            delete(this.hPanel);
            this.hPanel = [];
        end
        
        function x = getConfig(this)
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-power-pmac-hydra-mot-min.json' ...
            );
        
            x = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
        end
        
        
        
        function ce = getCommonProps(this)
            ce = {...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowLabels', false, ...
                'lShowStepNeg', false, ...
                'lShowStep', false, ...
                'lShowStepPos', false, ...
                'lShowPlay', false, ...
                'lShowRel', this.lShowRel ...
            };
            
        end
        
        
        function initUi1(this)
              
            ceProps = this.getCommonProps();
            this.ui1 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-wcx', this.cName), ...
                'config', this.getConfig(), ...
                ceProps{:}, ...
                'lShowLabels', true, ...
                'cLabel', 'WCX' ...
            );
        end
        
        function initUi2(this)
            
            ceProps = this.getCommonProps();
            
            this.ui2 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-wcy', this.cName), ...
                'config', this.getConfig(), ...
                ceProps{:}, ...
                'cLabel', 'WCY' ...
            );
        end
        
        function initUi3(this)
            
            
            ceProps = this.getCommonProps();
            this.ui3 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-rcx', this.cName), ...
                'config', this.getConfig(), ...
                ceProps{:}, ...
                'cLabel', 'RCX' ...
            );
        end
        
        function initUi4(this)
            
            ceProps = this.getCommonProps();
            this.ui4 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-rcy', this.cName), ...
                'config', this.getConfig(), ...
                ceProps{:}, ...
                'cLabel', 'RCY' ...
            );
        end
        
        function initUi5(this)
            
            
            ceProps = this.getCommonProps();
            this.ui5 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-lsicx', this.cName), ...
                'config', this.getConfig(), ...
                ceProps{:}, ...
                'cLabel', 'LSIX' ...
            );
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
                'cName', sprintf('%s-pppmac-comm', this.cName), ...
                'cLabel', 'PowerPmac' ...
            );
        
        end
        
        function initUiPositionRecaller(this)
            
            cDirThis = fileparts(mfilename('fullpath'));
            cPath = fullfile(cDirThis, '..', '..', 'save', 'position-recaller');
            this.uiPositionRecaller = mic.ui.common.PositionRecaller(...
                'cConfigPath', cPath, ... 
                'cName', sprintf('%s-position-recaller', this.cName), ...
                'hGetCallback', @this.onUiPositionRecallerGet, ...
                'lShowLabelOfList', false, ... 
                'cTitleOfPanel', 'Saved Configurations', ...
                'hSetCallback', @this.onUiPositionRecallerSet ...
            );
        end
        
       
        
        function task = getTaskSetAll(this)
            
            ceTasks = {...
                mic.Task.fromUiGetSetText(this.uiWorkingMode.uiWorkingMode, '0', 'Working Mode'), ...
                mic.Task.fromUiGetSetNumberMoveToDest(this.ui1, 0.1, 'MotMin RCX'), ...
                mic.Task.fromUiGetSetNumberMoveToDest(this.ui2, 0.1, 'MotMin RCX'), ...
                mic.Task.fromUiGetSetNumberMoveToDest(this.ui3, 0.1, 'MotMin RCX'), ...
                mic.Task.fromUiGetSetNumberMoveToDest(this.ui4, 0.1, 'MotMin RCX'), ...
                mic.Task.fromUiGetSetNumberMoveToDest(this.ui5, 0.1, 'MotMin RCX'), ...
                mic.Task.fromUiGetSetText(this.uiWorkingMode.uiWorkingMode, '1', 'Working Mode') ...
            };
            
            task = mic.TaskSequence(...
                'cName', [this.cName, 'sequence-set-all'], ...
                'clock', this.clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.1, ...
                'cDescription', 'Set All Mot Min' ...
            );
            
        end
        
        
        function init(this)
            this.msg('init()');
            
            this.uiWorkingMode = bl12014.ui.PowerPmacWorkingMode(...
                'cName', [this.cName, 'pmac-working-mode'], ...
                'clock', this.uiClock ...
            );
        
            this.initUi1();
            this.initUi2();
            this.initUi3();
            this.initUi4();
            this.initUi5();
            this.initUiCommDeltaTauPowerPmac();
            this.initUiPositionRecaller();
            
            this.uiSequenceSetAll = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-sequence-set-all'], ...
                'task', this.getTaskSetAll(), ...
                'lShowIsDone', false, ...
                'clock', this.clock ...
            );
            
        end
        
         % Return list of values from your app
        function dValues = onUiPositionRecallerGet(this)
            
            dValues = [...
                this.ui1.getValRaw(), ...
                this.ui2.getValRaw(), ...
                this.ui3.getValRaw(), ...
                this.ui4.getValRaw(), ...
                this.ui5.getValRaw(), ...
            ];
        end
        
        % Set recalled values into your app
        function onUiPositionRecallerSet(this, dValues)
                           
            
            % Update the UI destinations
            this.ui1.setDestRaw(dValues(1));
            this.ui2.setDestRaw(dValues(2));
            this.ui3.setDestRaw(dValues(3));
            this.ui4.setDestRaw(dValues(4));
            this.ui5.setDestRaw(dValues(5));
            
            this.uiSequenceSetAll.execute();
            
        end
        
        
        
    end
    
    
end

