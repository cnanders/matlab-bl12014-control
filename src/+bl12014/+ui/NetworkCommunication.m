classdef NetworkCommunication < mic.Base
    
    properties

        % {mic.ui.device.GetLogical 1xn}
        uis = {}
        
    end
    
    properties (Access = private)
        
        dWidth = 500
        dHeight = 600
        
        cName = 'Network Status (Updates every 2 sec)'
        hFigure
        
        % {struct 1xn}
        stDevices = [... % Legacy BL12.0.1.3 services / hardware
            struct(...
                'name', 'ALS Corba Name Service', ...
                'hostname', 'cns.als.lbl.gov', ...
                'port', 8888, ...
                'use', '' ...
            ), ...
            struct(...
                'name', 'BL12Pico', ...
                'hostname', 'bl12pico.als.lbl.gov', ...
                'port', 8888, ... % FIX ME
                'use', 'BL12 exit slits' ...
            ), ... % .10 Subnet
            struct(...
                'name', 'SmarAct MCS 3CC ETH TAB', ...
                'hostname', '192.168.10.20', ...
                'port', 5000, ... % FIX ME
                'use', 'M141 stage' ...
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
                'hostname', '192.168.20.20', ...
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
            ) ...
        ]
            
        clock
        dWidthName = 450
        lShowDevice = false
        lShowInitButton = false
        
        
    end
    
    methods
        
        function this = NetworkCommunication(varargin)
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
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
        
        
        
        function build(this)
            
                       
            this.buildFigure()
            
            dTop = 10;
            dLeft = 10;
            dSep = 30;
            
            
            for n = 1 : length(this.stDevices)
                this.uis{n}.build(this.hFigure, dLeft, dTop);
                
                if n == 1
                    dTop = dTop + 15 + dSep;
                else
                    dTop = dTop + dSep;
                end
                    
            end
                       
        end
        
        function delete(this)
            
            this.msg('delete');
            
            this.turnOff();
                        
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end    
        
        
    end
    
    methods (Access = private)
        
        function buildFigure(this)
            
            this.connect();
            this.turnOn();
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', this.cName, ...
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
        
        function onFigureCloseRequest(this, src, evt)
            
            this.turnOff();
            this.msg('M143Control.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
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
            end
        end
                
        function init(this)
            
            this.msg('init()');
            
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
        
        
        
    end
    
    
end
