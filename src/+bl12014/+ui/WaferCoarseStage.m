classdef WaferCoarseStage < mic.Base
    
    properties
            
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiX
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiY
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiZ
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiTiltX
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiTiltY
        
        % {mic.ui.common.PositionRecaller 1x1}
        uiPositionRecaller
        
        
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 960
        dHeight = 160        
        cName = 'wafer-coarse-stage'
        lShowRange = true
        lShowStores = false
        
        % This is a cheat / hack since the PPMAC treats multiple
        % axes as a single coordinate system and the underlying MIC
        % framework does not support that
        commDeltaTauPowerPmac
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 30
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = WaferCoarseStage(varargin)
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
            import bl12014.device.GetSetTextFromDeltaTauPowerPmac
            
            % Devices
            deviceX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_X);
            deviceY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_Y);
            deviceZ = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_Z);
            deviceTiltX = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TIP);
            deviceTiltY = GetSetNumberFromDeltaTauPowerPmac(comm, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TILT);
            
            % Set Devices
            this.uiX.setDevice(deviceX);
            this.uiY.setDevice(deviceY);
            this.uiZ.setDevice(deviceZ);
            this.uiTiltX.setDevice(deviceTiltX);
            this.uiTiltY.setDevice(deviceTiltY);
            
            % Turn on
            this.uiX.turnOn();
            this.uiY.turnOn();
            this.uiZ.turnOn();
            this.uiTiltX.turnOn();
            this.uiTiltY.turnOn();
            
            this.uiX.syncDestination();
            this.uiY.syncDestination();
            this.uiZ.syncDestination();
            this.uiTiltX.syncDestination();
            this.uiTiltY.syncDestination();
            
            % CHEATING HACK
            % store a reference to comm so it can be used when loading
            % from stores
            
            this.commDeltaTauPowerPmac = comm;

            
        end
        
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.uiX.turnOff();
            this.uiY.turnOff();
            this.uiZ.turnOff();
            this.uiTiltX.turnOff();
            this.uiTiltY.turnOff();
                        
            this.uiX.setDevice([]);
            this.uiY.setDevice([]);
            this.uiZ.setDevice([]);
            this.uiTiltX.setDevice([]);
            this.uiTiltY.setDevice([]);

            
        end

        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wafer Coarse Stage (PPMAC)',...
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
            
            this.uiX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiZ.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiTiltX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiTiltY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            dLeft = 590;
            dTop = 15;
            dWidth = 360;
            this.uiPositionRecaller.build(this.hPanel, dLeft, dTop, dWidth, 145);
            
            
            
            

            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end 
        
        function st = save(this)
            st = struct();
            st.uiX = this.uiX.save();
            st.uiY = this.uiY.save();
            st.uiZ = this.uiZ.save();
            st.uiTiltX = this.uiTiltX.save();
            st.uiTiltY = this.uiTiltY.save();
        end
        
        function load(this, st)
            if isfield(st, 'uiX')
                this.uiX.load(st.uiX)
            end
            
            if isfield(st, 'uiY')
                this.uiY.load(st.uiY)
            end
            
            if isfield(st, 'uiZ')
                this.uiZ.load(st.uiZ)
            end
            
            if isfield(st, 'uiTiltX')
                this.uiTiltX.load(st.uiTiltX)
            end
            
            if isfield(st, 'uiTiltY')
                this.uiTiltY.load(st.uiTiltY)
            end
        end
        
        
    end
    
    methods (Access = private)
        
         function onFigureCloseRequest(this, src, evt)
            this.msg('M141Control.closeRequestFcn()');
            delete(this.hPanel);
         end
        
         
        function initUiX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-x', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'cLabel', 'X' ...
            );
        end
        
        function initUiY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-y.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-y', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'cLabel', 'Y' ...
            );
        end
        
        function initUiZ(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-z.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiZ = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-z', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'cLabel', 'Z' ...
            );
        end
        
        
        function initUiTiltX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-tilt-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiTiltX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-tilt-x', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'cLabel', 'Tilt X' ...
            );
        end
        
        function initUiTiltY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-tilt-y.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiTiltY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-tilt-y', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'cLabel', 'Tilt Y' ...
            );
        end
        
        % Return list of values from your app
        function dValues = onUiPositionRecallerGet(this)
            dValues = [...
                this.uiX.getValRaw(), ...
                this.uiY.getValRaw(), ...
                this.uiZ.getValRaw(), ...
                this.uiTiltX.getValRaw(), ...
                this.uiTiltY.getValRaw(), ...
            ];
        end
        
        % Set recalled values into your app
        function onUiPositionRecallerSet(this, dValues)
            
            % This is a cheat / hack of the MIC
            
            % Update the UI destinations
            this.uiX.setDestRaw(dValues(1));
            this.uiY.setDestRaw(dValues(2));
            this.uiZ.setDestRaw(dValues(3));
            this.uiTiltX.setDestRaw(dValues(4));
            this.uiTiltY.setDestRaw(dValues(5));
            
            % Update the destinations of CS1 on the PPMAC
            
            cCmd = {...
               sprintf('DestCS1X=%1.6f;', dValues(1)), ...
               sprintf('DestCS1Y=%1.6f;', dValues(2)), ...
               sprintf('DestCS1Z=%1.6f;', dValues(3)), ...
               sprintf('DestCS1A=%1.6f;', dValues(4)), ...
               sprintf('DestCS1B=%1.6f;', dValues(5)), ...
               'CommandCode=14' ...
            };
        
               this.commDeltaTauPowerPmac.command(strjoin(cCmd, ';'));
               
               
               
%             this.commDeltaTauPowerPmac.command(sprintf('DestCS1X=%1.6f;', dValues(1)));
%             this.commDeltaTauPowerPmac.command(sprintf('DestCS1Y=%1.6f;', dValues(2)));
%             this.commDeltaTauPowerPmac.command(sprintf('DestCS1Z=%1.6f;', dValues(3)));
%             this.commDeltaTauPowerPmac.command(sprintf('DestCS1A=%1.6f;', dValues(4)));
%             this.commDeltaTauPowerPmac.command(sprintf('DestCS1B=%1.6f;', dValues(5)));
%             
%             % Command PPMAC to have CS1 go to all destinations
%             this.commDeltaTauPowerPmac.command('CommandCode=14');
            
        end
        
        function initUiPositionRecaller(this)
            
            cDirThis = fileparts(mfilename('fullpath'));
            cPath = fullfile(cDirThis, '..', '..', 'save', 'position-recaller');
            this.uiPositionRecaller = mic.ui.common.PositionRecaller(...
                'cConfigPath', cPath, ... 
                'cName', [this.cName, '-position-recaller'], ...
                'cTitleOfPanel', 'Position Stores', ...
                'lShowLabelOfList', false, ...
                'hGetCallback', @this.onUiPositionRecallerGet, ...
                'hSetCallback', @this.onUiPositionRecallerSet ...
            );
        end
        
        
        function init(this)
            this.msg('init()');
            this.initUiX();
            this.initUiY();
            this.initUiZ();
            this.initUiTiltX();
            this.initUiTiltY();
            this.initUiPositionRecaller();
        end
        
        
        
    end
    
    
end

