classdef CameraLEDs < mic.Base
    
    properties
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiComm3GStoreRemotePowerSwitch1
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiComm3GStoreRemotePowerSwitch2
        
        % {mic.ui.device.GetSetLogical 1x1}}
        uiSwitch1Outlet1
        uiSwitch1Outlet2
        uiSwitch2Outlet1
        uiSwitch2Outlet2
        
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 610
        dHeight = 230
        hFigure
        
        
    end
    
    properties (SetAccess = private)
        
        cName = 'camera-leds'
    end
    
    methods
        
        function this = CameraLEDs(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        
        function connect3GStoreRemotePowerSwitch1(this, comm)
            
            % {< mic.interface.device.GetSetLogical}
            outlet1 = bl12014.device.GetSetLogicalFrom3GStoreRemotePowerSwitch(comm, 1);

            % {< mic.interface.device.GetSetLogical}
            outlet2 = bl12014.device.GetSetLogicalFrom3GStoreRemotePowerSwitch(comm, 2);
            
            this.uiSwitch1Outlet1.setDevice(outlet1);
            this.uiSwitch1Outlet2.setDevice(outlet2);
            
            this.uiSwitch1Outlet1.turnOn();
            this.uiSwitch1Outlet2.turnOn();
            
        end
        
        
        function connect3GStoreRemotePowerSwitch2(this, comm)
            
            % {< mic.interface.device.GetSetLogical}
            outlet1 = bl12014.device.GetSetLogicalFrom3GStoreRemotePowerSwitch(comm, 1);

            % {< mic.interface.device.GetSetLogical}
            outlet2 = bl12014.device.GetSetLogicalFrom3GStoreRemotePowerSwitch(comm, 2);
            
            this.uiSwitch2Outlet1.setDevice(outlet1);
            this.uiSwitch2Outlet2.setDevice(outlet2);
            
            this.uiSwitch2Outlet1.turnOn();
            this.uiSwitch2Outlet2.turnOn();
            
        end
        
        function disconnect3GStoreRemotePowerSwitch1(this)
           
            this.uiSwitch1Outlet1.turnOff();
            this.uiSwitch1Outlet1.setDevice([]);
            
            this.uiSwitch1Outlet2.turnOff();
            this.uiSwitch1Outlet2.setDevice([]);
            
        end
        
        
        function disconnect3GStoreRemotePowerSwitch2(this)
           
            this.uiSwitch2Outlet1.turnOff();
            this.uiSwitch2Outlet1.setDevice([]);
            
            this.uiSwitch2Outlet2.turnOff();
            this.uiSwitch2Outlet2.setDevice([]);
            
        end
        
        
                
        function build(this)
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'M141 Control', ...
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

            dTop = 10;
            dLeft = 10;
            dSep = 30;
            
            this.uiComm3GStoreRemotePowerSwitch1.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiComm3GStoreRemotePowerSwitch2.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            this.uiSwitch1Outlet1.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            this.uiSwitch1Outlet2.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiSwitch2Outlet1.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiSwitch2Outlet2.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            

            
        end
        
        
       
        
        
        function delete(this)
            
            this.msg('delete');
            
            % Clean up clock tasks
            
            %{
            if (isvalid(this.cl))
                this.cl.remove(this.id());
            end
            %}
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end   
        
        function st = save(this)
            %st = struct();
            %st.uiSwitch1Outlet1 = this.uiSwitch1Outlet1.save();
        end
        
        function load(this, st)
            %{
            if isfield(st, 'uiStageY')
                this.uiSwitch1Outlet1.load(st.uiSwitch1Outlet1)
            end
            %}
        end
        
        
    end
    
    methods (Access = private)
        
         function onFigureCloseRequest(this, src, evt)
            delete(this.hFigure);
            this.hFigure = [];
         end
        
         
        function initUiSwitch1Outlet1(this)
               
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-logical', ...
                'config-3gstore-remote-power-switch.json' ...
            );
        
            uiConfig = mic.config.GetSetLogical(...
                'cPath',  cPathConfig ...
            );
            
            this.uiSwitch1Outlet1 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                 'config', uiConfig, ...
                'cName', sprintf('%s-branch-outlet-1', this.cName), ...
                'lShowInitButton', false, ...
                'cLabel', 'Branch Outlet 1' ...
            );
        end
        
        function initUiSwitch1Outlet2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-logical', ...
                'config-3gstore-remote-power-switch.json' ...
            );
        
            uiConfig = mic.config.GetSetLogical(...
                'cPath',  cPathConfig ...
            );
        
            this.uiSwitch1Outlet2 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                 'config', uiConfig, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-branch-outlet-2', this.cName), ...
                'lShowInitButton', false, ...
                'cLabel', 'Branch Outlet 2' ...
            );
        end
        
        function initUiSwitch2Outlet1(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-logical', ...
                'config-3gstore-remote-power-switch.json' ...
            );
        
            uiConfig = mic.config.GetSetLogical(...
                'cPath',  cPathConfig ...
            );
        
            this.uiSwitch2Outlet1 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                 'config', uiConfig, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-end-station-outlet-1', this.cName), ...
                'lShowInitButton', false, ...
                'cLabel', 'End Station Outlet 1' ...
            );
        end
        
        function initUiSwitch2Outlet2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-logical', ...
                'config-3gstore-remote-power-switch.json' ...
            );
        
            uiConfig = mic.config.GetSetLogical(...
                'cPath',  cPathConfig ...
            );
        
            this.uiSwitch2Outlet2 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                 'config', uiConfig, ...
                'lShowLabels', false, ...
                'cName', sprintf('%s-end-station-outlet-2', this.cName), ...
                'lShowInitButton', false, ...
                'cLabel', 'End Station Outlet 2' ...
            );
        end
        
        
        
        function initUiComm3GStoreRemotePowerSwitch2(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiComm3GStoreRemotePowerSwitch2 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', '3gstore-remote-power-switch-2', ...
                'cLabel', '3GStore Remote Power 2' ...
            );
        
        end
        
        function initUiComm3GStoreRemotePowerSwitch1(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiComm3GStoreRemotePowerSwitch1 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', '3gstore-remote-power-switch-1', ...
                'cLabel', '3GStore Remote Power 1' ...
            );
        
        end
        
        function init(this)
            
            this.msg('init');
            this.initUiSwitch1Outlet1();
            this.initUiSwitch1Outlet2();
            this.initUiSwitch2Outlet1();
            this.initUiSwitch2Outlet2();
            this.initUiComm3GStoreRemotePowerSwitch1();
            this.initUiComm3GStoreRemotePowerSwitch2();
        end
        
        
        
    end
    
    
end

