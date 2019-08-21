classdef M142 < mic.Base
    
    properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommMicronixMmc103
        
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiStageX
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiStageTiltX
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiStageTiltYMf
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiStageTiltYMfr
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiStageTiltZMfr
        
       
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 690
        
        dWidthName = 140
        dWidthPadName = 29
        hPanel
        
        configStageY
        configMeasPointVolts
        
    end
    
    properties (SetAccess = private)
        
        cName = 'm142'
        dHeight = 215
        
        % {bl12014.Hardware 1x1}
        hardware

    end
    
    methods
        
        function this = M142(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
        
        end
        
        function syncDestinations(this)
            this.uiStageTiltX.syncDestination();
            this.uiStageTiltYMf.syncDestination();
            this.uiStageTiltYMfr.syncDestination();
        end
        
        function connectMicronixMmc103(this, comm)
            % {< mic.interface.device.GetSetNumber}
            deviceX = bl12014.device.GetSetNumberFromMicronixMMC103(comm, 1);
            
            % {< mic.interface.device.GetSetNumber}
            deviceTiltZMfr = bl12014.device.GetSetNumberFromMicronixMMC103(comm, 2);
            
            this.uiStageX.setDevice(deviceX);
            this.uiStageX.turnOn()
            this.uiStageX.syncDestination();
            
            this.uiStageTiltZMfr.setDevice(deviceTiltZMfr);
            this.uiStageTiltZMfr.turnOn()
            this.uiStageTiltZMfr.syncDestination();
            
            
        end
        
        function disconnectMicronixMmc103(this)
            this.uiStageX.turnOff()
            this.uiStageTiltZMfr.turnOff()
            
            this.uiStageX.setDevice([]);
            this.uiStageTiltZMfr.setDevice([]);
            
        end
        
        %{
        function connectNewFocusModel8742(this, comm)
            
            device = bl12014.device.GetSetNumberFromNewFocusModel8742(comm, 2); % 2
            this.uiStageTiltX.setDevice(device);
            this.uiStageTiltX.turnOn()
            this.uiStageTiltX.syncDestination();
            
            device = bl12014.device.GetSetNumberFromNewFocusModel8742(comm, 1); % 1
            this.uiStageTiltYMf.setDevice(device);
            this.uiStageTiltYMf.turnOn()
            this.uiStageTiltYMf.syncDestination();
            
            device = bl12014.device.GetSetNumberFromNewFocusModel8742(comm, 3);
            this.uiStageTiltYMfr.setDevice(device);
            this.uiStageTiltYMfr.turnOn()
            this.uiStageTiltYMfr.syncDestination();
        end
        
        
        function disconnectNewFocusModel8742(this)
            
            this.uiStageTiltX.turnOff()
            this.uiStageTiltYMf.turnOff()
            this.uiStageTiltYMfr.turnOff()
            
            this.uiStageTiltX.setDevice([]);
            this.uiStageTiltYMf.setDevice([]);
            this.uiStageTiltYMfr.setDevice([]);
        end
        %}
        
        function buildFigure(this)
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'M142 Control', ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onFigureCloseRequest ...
            );
                        
            drawnow;
            
        end
        
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'M142',...
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
            
           
            this.uiCommMicronixMmc103.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
           
            this.uiStageX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiStageTiltX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStageTiltYMf.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStageTiltYMfr.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiStageTiltZMfr.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            

            
        end
        
        function delete(this)
            
            
            % {mic.ui.device.GetSetLogical 1x1}
            this.uiCommMicronixMmc103 = [];

            % {mic.ui.device.GetSetNumber 1x1}
            this.uiStageX = [];

            % {mic.ui.device.GetSetNumber 1x1}
            this.uiStageTiltX = [];

            % {mic.ui.device.GetSetNumber 1x1}
            this.uiStageTiltYMf = [];

            % {mic.ui.device.GetSetNumber 1x1}
            this.uiStageTiltYMfr = [];

            % {mic.ui.device.GetSetNumber 1x1}
            this.uiStageTiltZMfr = [];
            
           
        end    
        
        
        function st = save(this)
            st = struct();
            st.uiStageX = this.uiStageX.save();
            st.uiStageTiltX = this.uiStageTiltX.save();
            st.uiStageTiltYMf = this.uiStageTiltYMf.save();
            st.uiStageTiltYMfr = this.uiStageTiltYMfr.save();
            st.uiStageTiltZMfr = this.uiStageTiltZMfr.save();
        
        end
        
        function load(this, st)
            if isfield(st, 'uiStageY')
                this.uiStageY.load(st.uiStageY)
            end
            
            if isfield(st, 'uiStageTiltX')
                this.uiStageTiltX.load(st.uiStageTiltX)
            end
            
            if isfield(st, 'uiStageTiltYMf')
                this.uiStageTiltYMf.load(st.uiStageTiltYMf)
            end
            
            if isfield(st, 'uiStageTiltYMfr')
                this.uiStageTiltYMfr.load(st.uiStageTiltYMfr)
            end
            
            if isfield(st, 'uiStageTiltZMfr')
                this.uiStageTiltZMfr.load(st.uiStageTiltZMfr)
            end
            
        end
    end
    
    methods (Access = private)
        
         function onFigureCloseRequest(this, src, evt)
            this.msg('M141Control.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
         end
        
         
        function initUiStageX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m142-stage-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-x', this.cName), ...
                'config', uiConfig, ...
                'lShowInitButton', true, ...
                'cLabel', 'X' ...
            );
        end
        
        function initUiStageTiltX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m142-stage-tilt-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            u8Axis = 2;
            this.uiStageTiltX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthPadName', this.dWidthPadName, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-tilt-x', this.cName), ...
                'config', uiConfig, ...
                'fhGet', @() this.hardware.getNewFocus8742M142().getPosition(u8Axis), ...
                'fhSet', @(dVal) this.hardware.getNewFocus8742M142().moveToTargetPosition(u8Axis, dVal), ...
                'fhIsReady', @() this.hardware.getNewFocus8742M142().getMotionDoneStatus(u8Axis), ...
                'fhStop', @() this.hardware.getNewFocus8742M142().stop(u8Axis), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Tilt X (neg=down)' ...
            );
        end
        
        function initUiStageTiltYMf(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m142-stage-tilt-y-mf.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            u8Axis = 1;
            this.uiStageTiltYMf = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthPadName', this.dWidthPadName, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-tilt-y-mf', this.cName), ...
                'config', uiConfig, ...
                'fhGet', @() this.hardware.getNewFocus8742M142().getPosition(u8Axis), ...
                'fhSet', @(dVal) this.hardware.getNewFocus8742M142().moveToTargetPosition(u8Axis, dVal), ...
                'fhIsReady', @() this.hardware.getNewFocus8742M142().getMotionDoneStatus(u8Axis), ...
                'fhStop', @() this.hardware.getNewFocus8742M142().stop(u8Axis), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Tilt Y (MF) (neg=outboard)' ...
            );
        end
        
        function initUiStageTiltYMfr(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m142-stage-tilt-y-mfr.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            u8Axis = 3;
            this.uiStageTiltYMfr = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthPadName', this.dWidthPadName, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-tilt-y-mfr', this.cName), ...
                'config', uiConfig, ...
                'fhGet', @() this.hardware.getNewFocus8742M142().getPosition(u8Axis), ...
                'fhSet', @(dVal) this.hardware.getNewFocus8742M142().moveToTargetPosition(u8Axis, dVal), ...
                'fhIsReady', @() this.hardware.getNewFocus8742M142().getMotionDoneStatus(u8Axis), ...
                'fhStop', @() this.hardware.getNewFocus8742M142().stop(u8Axis), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Tilt Y (MFR) (neg=out)' ...
            );
        end
        
        function initUiStageTiltZMfr(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-m142-stage-tilt-z-mfr.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiStageTiltZMfr = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthPadName', this.dWidthPadName, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-tilt-z-mfr', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Tilt Z (MFR)' ...
            );
        end
        
        
        function initUiCommMicronixMmc103(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommMicronixMmc103 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 180, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-comm-micronix-mmc-103', this.cName), ...
                'cLabel', 'NPort 5150A -> Micronix MMC 103' ...
            );
        
        end
        

        function init(this)
            this.msg('init');
            
            this.initUiCommMicronixMmc103()
            this.initUiStageX();
            this.initUiStageTiltX();
            this.initUiStageTiltYMf();
            this.initUiStageTiltYMfr();
            this.initUiStageTiltZMfr();
        end
        
        
        
    end
    
    
end

