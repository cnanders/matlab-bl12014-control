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
        
        dWidth = 900
        dHeight = 255
        
        cName = 'power-pmac-hydra-mot-min'
        
        lShowStores = false
        lShowZero = false
        lShowRel = false
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        hFigure
        
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
            
            
            device = GetSetNumberFromDeltaTauPowerPmac(...
                comm, ...
                GetSetNumberFromDeltaTauPowerPmac.cWCX_MOT_MIN ...
            );
            this.ui1.setDevice(device);
            this.ui1.turnOn();
            this.ui1.syncDestination();
            
            
            device = GetSetNumberFromDeltaTauPowerPmac(...
                comm, ...
                GetSetNumberFromDeltaTauPowerPmac.cWCY_MOT_MIN ...
            );
            this.ui2.setDevice(device);
            this.ui2.turnOn();
            this.ui2.syncDestination();
            
            device = GetSetNumberFromDeltaTauPowerPmac(...
                comm, ...
                GetSetNumberFromDeltaTauPowerPmac.cRCX_MOT_MIN ...
            );
            this.ui3.setDevice(device);
            this.ui3.turnOn();
            this.ui3.syncDestination();
            
            
            device = GetSetNumberFromDeltaTauPowerPmac(...
                comm, ...
                GetSetNumberFromDeltaTauPowerPmac.cRCY_MOT_MIN ...
            );
            this.ui4.setDevice(device);
            this.ui4.turnOn();
            this.ui4.syncDestination();
            
            device = GetSetNumberFromDeltaTauPowerPmac(...
                comm, ...
                GetSetNumberFromDeltaTauPowerPmac.cLSICX_MOT_MIN ...
            );
            this.ui5.setDevice(device);
            this.ui5.turnOn();
            this.ui5.syncDestination();
            
            % Can't do this - results with calling the disconnect
            % function again while it is in the middle of running
            % this.uiCommDeltaTauPowerPmac.set(true);
          
        end
        
        
        function disconnectDeltaTauPowerPmac(this)
            
            
            this.ui1.turnOff();
            this.ui1.setDevice([]);
            
            this.ui2.turnOff();
            this.ui2.setDevice([]);
            
            this.ui3.turnOff();
            this.ui3.setDevice([]);
            
            this.ui4.turnOff();
            this.ui4.setDevice([]);
            
            this.ui5.turnOff();
            this.ui5.setDevice([]);
            
            % Can't do this - results with calling the disconnect
            % function again while it is in the middle of running
            % this.uiCommDeltaTauPowerPmac.set(false);

            
        end
        
        function buildFigure(this)
            
                        dScreenSize = get(0, 'ScreenSize');

            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'Power Pmac Hydra Mot Min', ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onCloseRequest ...
            );
            
            
			drawnow;  
            
        end
        

        function build(this) % , hParent, dLeft, dTop
                        
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            

            
            this.buildFigure()          

            dTop = 20;
            dLeft = 10;
            dSep = 30;
            
            this.uiCommDeltaTauPowerPmac.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 5 + dSep;
            
            this.ui1.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.ui2.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui3.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui4.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.ui5.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            dTop = dTop + 5;
            this.uiTextInstructions.build(this.hFigure, dLeft, dTop, this.dWidth - 2 * dLeft, 50);
            
            
            dLeft = 500
            dBot = 15
            this.uiPositionRecaller.build(this.hFigure, dLeft, dBot, 380, 170);
            
            
            
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
                
         
        function onCloseRequest(this, src, evt)
            this.msg('HeightSensorLEDs.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
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
                'hGetCallback', @this.getValues, ...
                'lShowLabelOfList', false, ... 
                'cTitleOfPanel', 'Saved Configurations', ...
                'hSetCallback', @this.setValues ...
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
        function dValues = getValues(this)
            dValues = [...
                this.ui1.getValRaw(), ...
                this.ui2.getValRaw(), ...
                this.ui3.getValRaw(), ...
                this.ui4.getValRaw(), ...
                this.ui5.getValRaw(), ...
            ];
        end
        
        % Set recalled values into your app
        function setValues(this, dValues)
            
            this.ui1.setDestRaw(dValues(1));
            this.ui2.setDestRaw(dValues(2));
            this.ui3.setDestRaw(dValues(3));
            this.ui4.setDestRaw(dValues(4));
            this.ui5.setDestRaw(dValues(5));
            
            this.ui1.moveToDest();
            this.ui2.moveToDest();
            this.ui3.moveToDest();
            this.ui4.moveToDest();
            this.ui5.moveToDest();
            
        end
        
        
        
    end
    
    
end

