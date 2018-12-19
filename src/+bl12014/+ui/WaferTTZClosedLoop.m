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
        
        uiCLTiltX
        uiCLTiltY
        uiCLZ
            
        dTiltXTol = 3; %urad
        dTiltYTol = 3; %urad
        dZTol  = 4; %nm
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 630
        dHeight = 150        
        cName = 'wafer-coarse-stage-ttz-closed-loop'
        lShowRange = false
        lShowStores = true
        
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
        
        function device = createCLZdevice(this, commPPMAC, commDriftMonitor)
            mm2nm           = 1e6;
            
            
            % Leverage existing PPMAC device implementation for isReady,
            % possibly could use the UIs for this too, 
            deviceCoarseZ = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, ...
                 bl12014.device.GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_Z);
            deviceFineZ = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, ...
                 bl12014.device.GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_FINE_Z);
            
            
            fhIsReadyMotor  = @() deviceCoarseZ.isReady() & deviceFineZ.isReady();
            dTolerance      = this.dZTol;
           
            fhGetSensor     = @()commDriftMonitor.getSimpleZ();
            fhGetMotor      = @()deviceFineZ.get() * mm2nm;
            fhSetMotor      = @(dMotorDest) this.closedLoopZSet(dMotorDest);
            
            
            device = mic.device.GetSetNumberFromClosedLoopControl(...
                this.clock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance, ...
                'cName', 'device-closed-loop-z',...
                'dDelay', 0.2);
        end
        
        
        function closedLoopZSet(this, dMotorDest)
            
            % Need to check if fine z requested move is in range.  If not,
            % compute a coarse Z correction to put fine stage back in
            % center of range.
            dCoarseZCorrection = 0;
            
            nm2mm = 1e-6;
            dCENTER_RANGE = (this.dFINE_Z_HIGH_LIMIT + this.dFINE_Z_LOW_LIMIT)/2;
            
            % If we need a coarse correction, set coarse stage, otherwise
            % set fine stage
            if  dMotorDest >= this.dFINE_Z_HIGH_LIMIT || dMotorDest <= this.dFINE_Z_LOW_LIMIT
                
                % The amount we need to buffer for fine stage is:
                dBuffer = dCENTER_RANGE - this.uiFineZ.getValCalDisplay();
                

                % Since we added this to fine stage, must subtract from
                % coarse stage:
                dCoarseZCorrection = -dBuffer * nm2mm;
               
                % Next we need to make actua desired move, which is
                % difference between current fine value and the motor
                % destination:
                dCoarseZCorrection = dCoarseZCorrection + (dMotorDest - this.uiFineZ.getValCalDisplay()) * nm2mm;
                
                dCurrentCoarseZ = this.uiCoarseZ.getValCalDisplay();
                
                % Set Coarse and fine stages:
                this.setDestAndGo(this.uiCoarseZ, dCurrentCoarseZ + dCoarseZCorrection);
                this.setDestAndGo(this.uiFineZ, dCENTER_RANGE);
                
            else
                % Make a normal fine stage move:
                this.setDestAndGo(this.uiFineZ, dMotorDest);
            end
            
        end
        
        
        function dVal = getFreshHSValue(~, commDriftMonitor, u8idx)
            
            commDriftMonitor.forceUpdate();
            dVal = commDriftMonitor.getHSValue(u8idx); 
            
        end
        
        function device = createCLRxdevice(this,  commPPMAC, commDriftMonitor)
            mrad2urad = 1e3;
            
            deviceTiltXPPMAC = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, ...
                 bl12014.device.GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TIP);
            
            fhGetMotor      = @()deviceTiltXPPMAC.get();
            fhSetMotor      = @(dVal) this.setDestAndGo(this.uiTiltX, dVal);
            fhIsReadyMotor  = @()deviceTiltXPPMAC.isReady();
            dTolerance      = this.dTiltXTol;
            fhGetSensor     = @()this.getFreshHSValue(commDriftMonitor, 1) * mrad2urad;   
            
            
            device = mic.device.GetSetNumberFromClosedLoopControl(...
                this.clock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance,...
                'cName', 'device-closed-loop-rx', ...
                'dDelay', 0.5);
        end
        
        function device = createCLRydevice(this,  commPPMAC, commDriftMonitor)
            mrad2urad = 1e3;
            
            deviceTiltYPPMAC = bl12014.device.GetSetNumberFromDeltaTauPowerPmac(commPPMAC, ...
                 bl12014.device.GetSetNumberFromDeltaTauPowerPmac.cAXIS_WAFER_COARSE_TILT);
            
            fhGetMotor      = @()deviceTiltYPPMAC.get();
            fhSetMotor      = @(dVal) this.setDestAndGo(this.uiTiltY, dVal);
            fhIsReadyMotor  = @()deviceTiltYPPMAC.isReady();
            dTolerance      = this.dTiltYTol;
            fhGetSensor     = @()this.getFreshHSValue(commDriftMonitor, 2) * mrad2urad; 
            
            
            device = mic.device.GetSetNumberFromClosedLoopControl(...
                this.clock, fhGetSensor, fhGetMotor, fhSetMotor, fhIsReadyMotor, dTolerance,...
                'cName', 'device-closed-loop-ry',...
                'dDelay', 0.5);
        end
        
        % Set lambda that edits UI destination before moving so that it
        % looks like it's controlling the UI.
        function setDestAndGo(~, ui, dVal)
            ui.setDestCalDisplay(dVal);
            ui.moveToDest();
        end
        
        
        function connect(this, commPPMAC, commDriftMonitor)

            % Represent devices implementations from Closed loop control
            deviceCLZ  = this.createCLZdevice(commPPMAC, commDriftMonitor);
            deviceCLRx = this.createCLRxdevice(commPPMAC, commDriftMonitor);
            deviceCLRy = this.createCLRydevice(commPPMAC, commDriftMonitor);
            
            % Set Devices
            this.uiCLZ.setDevice(deviceCLZ);
            this.uiCLTiltX.setDevice(deviceCLRx);
            this.uiCLTiltY.setDevice(deviceCLRy);
            
            % Turn on
            this.uiCLZ.turnOn();
            this.uiCLTiltX.turnOn();
            this.uiCLTiltY.turnOn();
            
            
%             this.uiCLZ.syncDestination();
%             this.uiCLTiltX.syncDestination();
%             this.uiCLTiltY.syncDestination();
            
        end
        
        
        function disconnect(this)
            
            this.uiCLZ.turnOff();
            this.uiCLTiltX.turnOff();
            this.uiCLTiltY.turnOff();
                        
            this.uiCLZ.setDevice([]);
            this.uiCLTiltX.setDevice([]);
            this.uiCLTiltY.setDevice([]);

            
        end

        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Wafer Z/T/T Closed Loop Control: Z -> HS simple Z (4 nm tol), [Rx,Ry] -> HS Calibrated tilt (3 urad tol)',...
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
            

            
            this.uiCLZ.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCLTiltX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCLTiltY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
           
            
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
            st.uiCLZ = this.uiCLZ.save();
            st.uiCLTiltX = this.uiCLTiltX.save();
            st.uiCLTiltX = this.uiCLTiltX.save();
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
                'config-wafer-fine-stage-z-cl.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCLZ = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-z', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'cLabel', 'HS Simple Z' ...
            );
        
        
        end
        
        
        function initUiTiltX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-rx-hs-cl.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCLTiltX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-tilt-x-cl', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'cLabel', 'HS Cal Rx' ...
            );
        end
        
        function initUiTiltY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-wafer-coarse-stage-ry-hs-cl.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCLTiltY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', sprintf('%s-tilt-y-cl', this.cName), ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'cLabel', 'HS Cal Rx' ...
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

