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
        
        uiTextInstructions
        
        
        
    end
    
    properties (SetAccess = private)
        
        dWidth = 820
        dHeight = 200
        
        cName = 'power-pmac-hydra-mot-min'
        
        lShowStores = false
        lShowZero = false
        lShowRel = false
        
        commDeltaTau

    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 70
        dWidthUnit = 80
        dWidthVal = 75
        dWidthPadUnit = 25 % 280

        
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
            
            this.init();
        
        end
        
       
        
        
        
        function connectDeltaTauPowerPmac(this, comm)
            
            import bl12014.device.GetSetNumberFromDeltaTauPowerPmac
            
            this.commDeltaTau = comm;
          
        end
        
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.commDeltaTau = [];
        end
        
        function build(this, hParent, dLeft, dTop)
                                    
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'PPMAC Mot Min',...
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
            dTop = dTop + 5;
            this.uiTextInstructions.build(this.hPanel, dLeft, dTop, this.dWidth - 2 * dLeft, 50);
            
            
            dLeft = 480;
            dBot = 15;
            this.uiPositionRecaller.build(this.hPanel, dLeft, dBot, 330, 170);
            
           
            
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
           
        function l = isVirtual(this)
            l = isempty(this.commDeltaTau);
        end
        
        function l = isReady(this)
            
            % Make sure that the working mode is "Activate"
            % Set working mode to "Undefined" before doing any set
            % l = this.commDeltaTau.getActiveWorkingMode() == 1;
            
            l = true; % FIX ME
            
        end
        
        
        function setMotMinWcx(this, dVal)
            
            cCmd = {...
                sprintf('NewWorkingMode=0'), ...
                sprintf('Hydra1UMotMinNorm1=%1.3f', dVal), ...
                sprintf('NewWorkingMode=1') ...
            };
            this.commDeltaTau.command(strjoin(cCmd, ';'));
            
        end
        
        function setMotMinWcy(this, dVal)
            
            cCmd = {...
                sprintf('NewWorkingMode=0'), ...
                sprintf('Hydra1UMotMinNorm2=%1.3f', dVal), ...
                sprintf('NewWorkingMode=1') ...
            };
            this.commDeltaTau.command(strjoin(cCmd, ';'));
            
        end
        
        function setMotMinRcx(this, dVal)
            cCmd = {...
                sprintf('NewWorkingMode=0'), ...
                sprintf('Hydra2UMotMinNorm1=%1.3f', dVal), ...
                sprintf('NewWorkingMode=1') ...
            };
            this.commDeltaTau.command(strjoin(cCmd, ';'));
        end
        
        function setMotMinRcy(this, dVal)
            cCmd = {...
                sprintf('NewWorkingMode=0'), ...
                sprintf('Hydra2UMotMinNorm2=%1.3f', dVal), ...
                sprintf('NewWorkingMode=1') ...
            };
            this.commDeltaTau.command(strjoin(cCmd, ';'));
        end
        
        function setMotMinLsix(this, dVal)
            cCmd = {...
                sprintf('NewWorkingMode=0'), ...
                sprintf('Hydra3UMotMinNorm1=%1.3f', dVal), ...
                sprintf('NewWorkingMode=1') ...
            };
            this.commDeltaTau.command(strjoin(cCmd, ';'));
        end
        
        % @param {double 1x5} d - desired mot min vlaues of wcx, wcy, rcx, rcy,
        % lsix in that order
        
        function setMotMinAll(this, dVal)
            
            % First set workign mode to undefined
            % Issue set for all of them
            
            cCmd = {...
                sprintf('NewWorkingMode=0'), ...
                sprintf('Hydra1UMotMinNorm1=%1.3f', dVal(1)), ...
                sprintf('Hydra1UMotMinNorm2=%1.3f', dVal(2)), ...
                sprintf('Hydra2UMotMinNorm1=%1.3f', dVal(3)), ...
                sprintf('Hydra2UMotMinNorm2=%1.3f', dVal(4)), ...
                sprintf('Hydra3UMotMinNorm1=%1.3f', dVal(5)), ...
                sprintf('NewWorkingMode=1') ...
            };
            this.commDeltaTau.command(strjoin(cCmd, ';'));
            
        end
                 
        function d = getMotMinWcx(this)
            d = this.getMotMin();
            d = d(1);
        end
        
        function d = getMotMinWcy(this)
            d = this.getMotMin();
            d = d(2);
        end
        
        function d = getMotMinRcx(this)
            d = this.getMotMin();
            d = d(3);
        end
        
        function d = getMotMinRcy(this)
            d = this.getMotMin();
            d = d(4);
        end
        
        function d = getMotMinLsix(this)
            d = this.getMotMin();
            d = d(5);
        end
        
        % Returns {double 1x5} list of mot min values of wcx, wcy, rcx,
        % rcy, lsix in that order
        
        function d = getMotMin(this)
            d = [
               this.commDeltaTau.getWaferCoarseXMotMin(), ...
               this.commDeltaTau.getWaferCoarseYMotMin(), ...
               this.commDeltaTau.getReticleCoarseXMotMin(), ...
               this.commDeltaTau.getReticleCoarseYMotMin(), ...  
               this.commDeltaTau.getLsiCoarseXMotMin() ... 
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
        
        function initUiTextInstructions(this)
            
            cVal = [...
                'Notice: you must toggle the PPMAC working mode to wm_ACTIVATE ', ...
                'for changes to be pushed to the Hydras' ...
            ];
            this.uiTextInstructions = mic.ui.common.Text(...
                'cVal', cVal, ...
                'dFontSize', 10, ...
                'cFontWeight', 'bold' ...
            );
            
        end
        
        function initUi1(this)
                        
            this.ui1 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', sprintf('%s-wcx', this.cName), ...
                'config', this.getConfig(), ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'fhGet', @this.getMotMinWcx, ...
                'fhSet', @this.setMotMinWcx, ...
                'fhIsReady', @this.isReady, ...
                'fhStop', @()[], ...
                'fhInitialize', @()[], ...
                'fhIsInitialized', @()true, ...
                'fhIsVirtual', @this.isVirtual, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'WCX' ...
            );
        end
        
        function initUi2(this)
            
            
            
            this.ui2 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', sprintf('%s-wcy', this.cName), ...
                'lShowLabels', false, ...
                'config', this.getConfig(), ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'fhGet', @this.getMotMinWcy, ...
                'fhSet', @this.setMotMinWcy, ...
                'fhIsReady', @this.isReady, ...
                'fhStop', @()[], ...
                'fhInitialize', @()[], ...
                'fhIsInitialized', @()true, ...
                'fhIsVirtual', @this.isVirtual, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'WCY' ...
            );
        end
        
        function initUi3(this)
            
            
            
            this.ui3 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', sprintf('%s-rcx', this.cName), ...
                'lShowLabels', false, ...
                'config', this.getConfig(), ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'fhGet', @this.getMotMinRcx, ...
                'fhSet', @this.setMotMinRcx, ...
                'fhIsReady', @this.isReady, ...
                'fhStop', @()[], ...
                'fhInitialize', @()[], ...
                'fhIsInitialized', @()true, ...
                'fhIsVirtual', @this.isVirtual, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'RCX' ...
            );
        end
        
        function initUi4(this)
            
            
            this.ui4 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', sprintf('%s-rcy', this.cName), ...
                'lShowLabels', false, ...
                'config', this.getConfig(), ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'fhGet', @this.getMotMinRcy, ...
                'fhSet', @this.setMotMinRcy, ...
                'fhIsReady', @this.isReady, ...
                'fhStop', @()[], ...
                'fhInitialize', @()[], ...
                'fhIsInitialized', @()true, ...
                'fhIsVirtual', @this.isVirtual, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'RCY' ...
            );
        end
        
        function initUi5(this)
            
            
            
            this.ui5 = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', sprintf('%s-lsicx', this.cName), ...
                'lShowLabels', false, ...
                'config', this.getConfig(), ...
                'lShowStores', this.lShowStores, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'fhGet', @this.getMotMinLsix, ...
                'fhSet', @this.setMotMinLsix, ...
                'fhIsReady', @this.isReady, ...
                'fhStop', @()[], ...
                'fhInitialize', @()[], ...
                'fhIsInitialized', @()true, ...
                'fhIsVirtual', @this.isVirtual, ...
                'lUseFunctionCallbacks', true, ...
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
        
       
        
        
        
        function init(this)
            this.msg('init()');
            this.initUi1();
            this.initUi2();
            this.initUi3();
            this.initUi4();
            this.initUi5();
            this.initUiTextInstructions();
            this.initUiCommDeltaTauPowerPmac();
            this.initUiPositionRecaller();
            
          
            
            
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
            
            % This is a cheat / hack of the MIC.  Instead of instructing
            % the UI to go to dest, if we are connected, tell the hardware
            % to move, which will cause the UI to update.

            if ~isempty(this.commDeltaTau)
                this.setMotMinAll(dValues);
                return;
            end
            
            % If not connected, tell simulate click on the UI play button
            
            this.ui1.moveToDest();
            this.ui2.moveToDest();
            this.ui3.moveToDest();
            this.ui4.moveToDest();
            this.ui5.moveToDest();
            
        end
        
        
        
    end
    
    
end

