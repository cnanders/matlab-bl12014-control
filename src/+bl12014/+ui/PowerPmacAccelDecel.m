classdef PowerPmacAccelDecel < mic.Base
    
    properties

        % {mic.ui.device.GetSetNumber 1x1}}
        ui1Accel
        ui2Accel
        ui3Accel
        ui4Accel
        ui5Accel
        
        ui1Decel
        ui2Decel
        ui3Decel
        ui4Decel
        ui5Decel
        
        uiPositionRecaller
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiWorkingMode
        uiSequenceSetAll
        
    end
    
    properties (SetAccess = private)
        
        dWidth = 665
        dHeight = 230
        
        cName = 'power-pmac-accel-decel'
        
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
        dWidthVal = 100
        dWidthPadUnit = 0 % 280
        
        % {bl12014.Hardware 1x1}
        hardware

        
    end
    
    methods
        
        function this = PowerPmacAccelDecel(varargin)
            
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
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
            
            
        
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
            
                       
            
            this.ui1Accel.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.ui2Accel.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.ui1Decel.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui2Decel.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            dTop = dTop + 30;
            this.uiSequenceSetAll.build(this.hPanel, dLeft, dTop, 280);
            
            dLeft = 320;
            dTop = 20;
            dHeight = 180
            this.uiPositionRecaller.build(this.hPanel, dLeft, dTop, 330, dHeight);
            
           
            
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
           

        
        function onCloseRequest(this, src, evt)
            this.msg('HeightSensorLEDs.closeRequestFcn()');
            delete(this.hPanel);
            this.hPanel = [];
        end
        
        function x = getConfig(this)
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-power-pmac-accel-decel.json' ...
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
        
        
        function initUi1Accel(this)
              
            ceProps = this.getCommonProps();
            this.ui1Accel = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-accel-wafer-coarse', this.cName), ...
                'config', this.getConfig(), ...
                ceProps{:}, ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getAccelOfWaferCoarse(), ...
                'fhSet', @(dVal) this.hardware.getDeltaTauPowerPmac().setAccelOfWaferCoarse(dVal), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'lShowLabels', true, ...
                'cLabel', 'Accel Wafer Coarse' ...
            );
        end
        
        function initUi2Accel(this)
            
            ceProps = this.getCommonProps();
            
            this.ui2Accel = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-accel-reticle-coarse', this.cName), ...
                'config', this.getConfig(), ...
                ceProps{:}, ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getAccelOfReticleCoarse(), ...
                'fhSet', @(dVal) this.hardware.getDeltaTauPowerPmac().setAccelOfReticleCoarse(dVal), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Accel Reticle Coarse' ...
            );
        end
        
        function initUi1Decel(this)
              
            ceProps = this.getCommonProps();
            this.ui1Decel = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-decel-wafer-coarse', this.cName), ...
                'config', this.getConfig(), ...
                ceProps{:}, ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getDecelOfWaferCoarse(), ...
                'fhSet', @(dVal) this.hardware.getDeltaTauPowerPmac().setDecelOfWaferCoarse(dVal), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Decel Wafer Coarse' ...
            );
        end
        
        function initUi2Decel(this)
            
            ceProps = this.getCommonProps();
            
            this.ui2Decel = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-decel-reticle-coarse', this.cName), ...
                'config', this.getConfig(), ...
                ceProps{:}, ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getDecelOfReticleCoarse(), ...
                'fhSet', @(dVal) this.hardware.getDeltaTauPowerPmac().setDecelOfReticleCoarse(dVal), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Decel Reticle Coarse' ...
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
                ...mic.Task.fromUiGetSetNumber(this.uiWorkingMode.uiWorkingMode, 0, 0.1, 'mode', 'Working Mode'), ...
                mic.Task.fromUiGetSetNumberMoveToDest(this.ui1Accel, 0.1, 'Accel Wafer Coarse'), ...
                mic.Task.fromUiGetSetNumberMoveToDest(this.ui2Accel, 0.1, 'Accel Reticle Coarse'), ...
                mic.Task.fromUiGetSetNumberMoveToDest(this.ui1Decel, 0.1, 'Decel Wafer Coarse'), ...
                mic.Task.fromUiGetSetNumberMoveToDest(this.ui2Decel, 0.1, 'Decel Reticle Coarse'), ...
                ...mic.Task.fromUiGetSetNumber(this.uiWorkingMode.uiWorkingMode, 1, 0.1, 'mode', 'Working Mode') ...
            };
            
            task = mic.TaskSequence(...
                'cName', [this.cName, 'sequence-set-all'], ...
                'clock', this.clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.1, ...
                'fhGetMessage', @() 'Set All' ...
            );
            
        end
        
        
        function init(this)
            this.msg('init()');
            
            this.uiWorkingMode = bl12014.ui.PowerPmacWorkingMode(...
                'cName', [this.cName, 'pmac-working-mode'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
        
            this.initUi1Accel();
            this.initUi2Accel();
            this.initUi1Decel();
            this.initUi2Decel();
           
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
                this.ui1Accel.getValRaw(), ...
                this.ui2Accel.getValRaw(), ...
                this.ui1Decel.getValRaw(), ...
                this.ui2Decel.getValRaw(), ...
            ];
        end
        
        % Set recalled values into your app
        function onUiPositionRecallerSet(this, dValues)
                           
            
            % Update the UI destinations
            this.ui1Accel.setDestRaw(dValues(1));
            this.ui2Accel.setDestRaw(dValues(2));
            this.ui1Decel.setDestRaw(dValues(3));
            this.ui2Decel.setDestRaw(dValues(4));
            
            this.uiSequenceSetAll.execute();
            
        end
        
        
        
    end
    
    
end

