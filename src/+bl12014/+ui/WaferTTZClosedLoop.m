classdef WaferTTZClosedLoop < mic.Base
    
    properties (Constant)
        dFINE_Z_HIGH_LIMIT = 10000;
        dFINE_Z_LOW_LIMIT = 0;
    end
    
     
    properties
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiTiltX
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiTiltY
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiCoarseZ
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiFineZ  
            
        dTiltXTol = 50; %urad
        dTiltYTol = 50; %urad
        dZTol  = 4; %nm
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 1030
        dHeight = 205        
        cName = 'wafer-coarse-stage-ttz-closed-loop'
        lShowRange = true
        lShowStores = false
        
        commDeltaTauPowerPmac
        
        commMfDriftMonitorMiddleware
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 70
    
        
    end
    
    methods
        
        function this = WaferTTZClosedLoop(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        % Need to construct req function handles for GSNFromCLC device
        % implementations: fhGetSensor, fhGetMotor, fhSetMotor,
        % fhIsReadyMotor, dTolearnce
        
        function device = createCLZdevice(this,  commPPMAC, commDriftMonitor)
            
            % Leverage existing PPMAC device implementation:
            deviceCoarseZ = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_Z);
            deviceFineZ = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_FINE_Z);
            
            
            fhIsReadyMotor  = @() deviceCoarseZ.isReady() & deviceFineZ.isReady();
            dTolerance      = this.dZTol;
            
            fhGetSensor     = commDriftMonitor.getSimpleZ;
            
            fhGetMotor      = deviceFineZ.get;
            fhSetMotor      = @(dMotorDest) this.closedLoopZSet(dMotorDest);
            
            
            device = bl12014.device.GetSetNumberFromClosedLoopControl(...
                this.clock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance, ...
                'cName', 'device-closed-loop-z');
        end
        
        
        function closedLoopZSet(this, dMotorDest)
            
            % Need to check if fine z requested move is in range.  If not,
            % compute a coarse Z correction to put fine stage back in
            % center of range.
            dCoarseZCorrection = 0;
            
            nm2mm = 1e-6;
            dCENTER_RANGE = (this.dFINE_Z_HIGH_LIMIT + this.dFINE_Z_LOW_LIMIT)/2;
            
            if dMotorDest >= this.dFINE_Z_HIGH_LIMIT
                dCoarseZCorrection = -dMotorDest - this.dFINE_Z_HIGH_LIMIT) * nm2mm - dCENTER_RANGE;
            elseif dMotorDest <= this.dFINE_Z_HIGH_LIMIT
                dCoarseZCorrection = -(dMotorDest - this.dFINE_Z_LOW_LIMIT) * nm2mm + dCENTER_RANGE;
            end
            
            % If we need a coarse correction, set coarse stage, otherwise
            % set fine stage
            if dCoarseZCorrection ~= 0
                dCurrentCoarseZ = this.uiCoarseZ.getValCalDisplay();
                this.setDestAndGo(this.uiCoarseZ, dCurrentCoarseZ + dCoarseZCorrection);
                
            else
                % Make a normal fine stage move:
                this.setDestAndGo(this.uiFineZ, dMotorDest);
            end
            
        end
        
        
        
        function device = createCLRxdevice(this,  commPPMAC, commDriftMonitor)
            deviceTiltXPPMAC = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TIP);
            
            fhGetMotor      = deviceTiltXPPMAC.get;
            fhSetMotor      = @(dVal) this.setDestAndGo(this.uiTiltX, dVal);
            fhIsReadyMotor  = deviceTiltXPPMAC.isReady;
            dTolerance      = this.dTiltXTol;
            fhGetSensor     = @()commDriftMonitor.getHSValue(1);   
            
            
            device = bl12014.device.GetSetNumberFromClosedLoopControl(...
                this.clock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance,...
                'cName', 'device-closed-loop-rx');
        end
        
        function device = createCLRydevice(this,  commPPMAC, commDriftMonitor)
            deviceTiltYPPMAC = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TILT);
            
            fhGetMotor      = deviceTiltYPPMAC.get;
            fhSetMotor      =  @(dVal) this.setDestAndGo(this.uiTiltY, dVal);
            fhIsReadyMotor  = deviceTiltYPPMAC.isReady;
            dTolerance      = this.dTiltYTol;
            fhGetSensor     = @()commDriftMonitor.getHSValue(2);   
            
            
            device = bl12014.device.GetSetNumberFromClosedLoopControl(...
                this.clock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance,...
                'cName', 'device-closed-loop-ry');
        end
        
        % Set lambda that edits UI destination before moving so that it
        % looks like it's controlling the UI.
        function setDestAndGo(~, ui, dVal)
            ui.setDestCalDisplay(dVal);
            ui.moveToDest();
        end
        
        
        function connect(this, commPPMAC, commDriftMonitor)

            % Represent devices implementations from Closed loop control
            deviceCLZ  = this.createCLZdevice(this, commPPMAC, commDriftMonitor);
            deviceCLRx = this.createCLRxdevice(this, commPPMAC, commDriftMonitor);
            deviceCLRy = this.createCLRydevice(this, commPPMAC, commDriftMonitor);
            
            % Set Devices
            this.uiZ.setDevice(deviceCLZ);
            this.uiTiltX.setDevice(deviceCLRx);
            this.uiTiltY.setDevice(deviceCLRy);
            
            % Turn on
            this.uiZ.turnOn();
            this.uiTiltX.turnOn();
            this.uiTiltY.turnOn();
            
        end
        
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.uiZ.turnOff();
            this.uiTiltX.turnOff();
            this.uiTiltY.turnOff();
                        
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
        
			drawnow;            

            dTop = 20;
            dLeft = 10;
            dSep = 30;
            

            
            this.uiZ.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiTiltX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiTiltY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            dLeft = 630;
            dTop = 20;
            this.uiPositionRecaller.build(this.hPanel, dLeft, dTop, 380, 170);
            
            
            

            
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
            st.uiZ = this.uiZ.save();
            st.uiTiltX = this.uiTiltX.save();
            st.uiTiltY = this.uiTiltY.save();
        end
        
        function load(this, st)
        end
        
        
    end
    
    methods (Access = private)
        
         function onFigureCloseRequest(this, src, evt)
            this.msg('WaferTTZClosedLoop.closeRequestFcn()');
            delete(this.hPanel);
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
        
        
        
        function init(this)
            this.msg('init()');
            
            this.initUiZ();
            this.initUiTiltX();
            this.initUiTiltY();
        end
        
        
        
    end
    
    
end

