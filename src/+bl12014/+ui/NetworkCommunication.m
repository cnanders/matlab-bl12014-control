classdef NetworkCommunication < mic.Base
    
    properties

        % {mic.ui.device.GetSetLogical 1x1}
        uiConnect
        
        % {mic.ui.device.GetLogical 1xn}
        uis = {}
        cName = 'Network Status (Updates every 2 sec)'
        
    end
    
    properties (Access = private)
        
        dWidth = 600
        dHeight = 750
        
        
        hParent
        
        % {struct 1xn}
        stDevices = [... % Legacy BL12.0.1.3 services / hardware
            struct(...
                'name', 'ALS Corba Name Service', ...
                'hostname', 'cns.als.lbl.gov', ...
                'port', 8888, ... % TCP
                'use', 'BL12Pico, BL12Control, BL12Dev' ...
            ), ...
            struct(...
                'name', 'BL12Control', ...
                'hostname', 'bl12control.als.lbl.gov', ...
                'port', 8450, ... % TCP/UDP
                'use', 'BL 12.0.1 Grating Tilt, Undulator / BL1201CorbaProxy.jar' ...
            ),...
            struct(...
                'name', 'BL12Dev', ...
                'hostname', 'bl12dev.als.lbl.gov', ...
                'port', 8451, ... % TCP/UDP
                'use', 'BL 12.0.1 Shutter / DCTCorbaProxy.jar' ...
            ),...
            struct(...
                'name', 'BL12Pico', ...
                'hostname', 'bl12pico.als.lbl.gov', ...
                'port', 8889, ... % UDP
                'use', 'BL 12.0.1 Exit Slits / BL12PicoCorbaProxy.jar ' ...
            ), ... % .10 Subnet
            struct(...
                'name', 'Wago IO 750', ...
                'hostname', '192.168.10.26', ...
                'port', 80, ... % web server
                'use', 'D141 Pneumatic ' ...
            ), ... % .10 Subnet
            struct(...
                'name', 'SmarAct MCS 3CC ETH TAB', ...
                'hostname', '192.168.10.20', ...
                'port', 5000, ... % FIX ME
                'use', 'M141 X stage' ...
            ), ...
            struct(...
                'name', 'NPort 5150A -> Micronix MMC103', ...
                'hostname', '192.168.10.21', ...
                'port', 4001, ...
                'use', 'M142 common x, M142R tiltZ' ...
            ), ...
            struct(...
                'name', 'NPoint LC400', ...
                'hostname', '192.168.10.22', ...
                'port', 23, ...
                'use', 'M142 field scanner' ...
            ), ...
            struct(...
                'name', 'NewFocus 8742', ...
                'hostname', '192.168.10.23', ...
                'port', 23, ...
                'use', 'M142 pico motors' ...
            ), ...
            struct(...
                'name', 'Galil DMC-30017', ...
                'hostname', '192.168.10.24', ...
                'port', 23, ... 
                'use', 'D142 stage' ...
            ), ...
            struct(...
                'name', 'Galil DMC-30017', ...
                'hostname', '192.168.10.25', ...
                'port', 23, ...
                'use', 'M143 stage' ...
            ), ... % .20 Subnet
            struct(...
                'name', 'NPoint LC400', ...
                'hostname', '192.168.20.20', ... % Should be 20.20 see ICS checklist notes
                'port', 23, ...
                'use', 'MA pupil scanner' ...
            ), ...
            struct(...
                'name', 'Galil DMC 4143', ...
                'hostname', '192.168.20.21', ...
                'port', 23, ...
                'use', 'Vibration Isolation System' ...
            ), ...
            struct(...
                'name', 'VME Computer', ...
                'hostname', '192.168.20.22', ...
                'port', 23, ... % FIX ME
                'use', 'Height Sensor and DMI ModBus Service' ...
            ), ...
            struct(...
                'name', 'DeltaTau Power PMAC', ...
                'hostname', '192.168.20.23', ...
                'port', 23, ...
                'use', 'Reticle and wafer stages' ...
            ), ...
            struct(...
                'name', 'SmarAct MCX XXX', ...
                'hostname', '192.168.20.24', ...
                'port', 5000, ... % FIX ME
                'use', 'LSI Goniometer' ...
            ), ...
            struct(...
                'name', 'SmarAct SmarPod', ...
                'hostname', '192.168.20.25', ...
                'port', 5000, ... % FIX ME
                'use', 'LSI Hexapod' ...
            ), ...
            struct(...
                'name', 'SmarAct MCX 1CSS ETH TAB', ...
                'hostname', '192.168.20.26', ...
                'port', 5000, ... % FIX ME
                'use', 'Focus Monitor' ...
            ), ...
            struct(...
                'name', 'Data Translation MeasurPoint', ...
                'hostname', '192.168.20.27', ...
                'port', 5025, ...
                'use', 'RTDs, Current, Cap Sensors' ...
            ), ...
            struct(...
                'name', 'NPort 5210A -> Keithley 6482 (Reticle)', ...
                'hostname', '192.168.20.28', ...
                'port', 4001, ...
                'use', 'Reticle diode' ...
            ), ...
            struct(...
                'name', 'NPort 5210A -> Keithley 6482 (Wafer)', ...
                'hostname', '192.168.20.28', ...
                'port', 4002, ...
                'use', 'Wafer diode' ...
            ), ...
            struct(...
                'name', 'Rigol DG1000Z', ...
                'hostname', '192.168.20.35', ...
                'port', 5555, ...
                'use', '5VTTL to Shutter Drivers' ...
            ), ...
        ]
            
        clock
        dWidthName = 550
        lShowDevice = false
        lShowInitButton = false
        
        lIsConnected = false
        
        
    end
    
    methods
        
        function this = NetworkCommunication(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
            
        end
        
        
        function turnOn(this)
            
            for n = 1 : length(this.stDevices)
                this.uis{n}.turnOn()
            end
                
        end
        
        function turnOff(this)
            
            for n = 1 : length(this.stDevices)
                this.uis{n}.turnOff()
            end
            
        end
        
        
        
        function build(this, hParent, dLeft, dTop)
            
            this.hParent = hParent;
            dSep = 30;
            
            
            this.uiConnect.build(this.hParent, dLeft, dTop);
            dTop = dTop + dSep + 15;
            
            
            for n = 1 : length(this.stDevices)
                this.uis{n}.build(this.hParent, dLeft, dTop);
                
                if n == 1
                    dTop = dTop + 15 + dSep;
                else
                    dTop = dTop + dSep;
                end
                    
            end
                       
        end
        
        function delete(this)
            
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_INIT_DELETE);  
                        
            this.uiConnect.delete();
            for n = 1 : length(this.uis)
                this.uis{n}.delete()
            end
            
            

        end    
        
        
    end
    
    methods (Access = private)

        % Creates bl12014.device.GetLogicalPing device for each device UI
        % and pass it to the device UI through the setDevice() method
        function connect(this)
            
            for n = 1 : length(this.stDevices)
                device = bl12014.device.GetLogicalPing(...
                    'cHostname', this.stDevices(n).hostname, ...
                    'u16Port', this.stDevices(n).port, ...
                    'dTimeout', 500 ...
                );
                this.uis{n}.setDevice(device);
                this.uis{n}.turnOn();
            end
        end
        
        
        function disconnect(this)
            
            for n = 1 : length(this.stDevices)
                this.uis{n}.turnOff();
                this.uis{n}.setDevice([]);
            end
        end
        
        function initUiConnect(this)
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiConnect = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'network-comm-', ...
                'fhGet', @this.getIsConnected, ...
                'fhSet', @this.setIsConnected, ...
                'fhIsVirtual', @()false, ... % 
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Network' ...
            );
            
        end
                
        function init(this)
            
            this.msg('init()');
            
            this.initUiConnect();
            
            for n = 1 : length(this.stDevices)
                
                if n == 1
                    lShowLabels = true;
                else
                    lShowLabels = false;
                end
                
                cPathConfig = fullfile(...
                    bl12014.Utils.pathUiConfig(), ...
                    'get-logical', ...
                    'config-ping.json' ...
                );
                config = mic.config.GetSetLogical(...
                    'cPath', cPathConfig ...
                );
                
                this.uis{n} = mic.ui.device.GetLogical(...
                   'clock', this.clock, ...
                   'config', config, ...
                   'dWidthName', this.dWidthName, ... 
                   'lShowDevice', this.lShowDevice, ...
                   'lShowLabels', lShowLabels, ...
                   'lShowInitButton', this.lShowInitButton, ...
                   'cName', sprintf(...
                        '%s-%s', ...
                        this.stDevices(n).name, ...
                        this.stDevices(n).hostname ...
                    ), ...
                   'cLabel', sprintf(...
                        '%s:%1.0f -- %s (%s)', ...
                        this.stDevices(n).hostname, ...
                        this.stDevices(n).port, ...
                        this.stDevices(n).name, ...
                        this.stDevices(n).use ...
                    ) ...
                );
            end
            
            
        end
        
        function l = getIsConnected(this)
            l = this.lIsConnected;
        end
        
        function setIsConnected(this, lVal)
            
            this.lIsConnected = lVal;
            
            if this.lIsConnected
                this.connect();
            else
                this.disconnect();
            end
        end
        
        
        
    end
    
    
end

