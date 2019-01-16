classdef Shutter < mic.Base
    
    properties
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommRigol
        
        
        % {bl12014.device.ShutterVirtual}
        deviceVirtual
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiShutter
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiOverride
        
        
    end
    
    properties (SetAccess = private)
        
        dHeight = 100 
        
        cName = 'shutter'

                
    end
    
    properties (Access = private)
        
        clock
        dWidth = 540
        configStageY
        configMeasPointVolts
        
        % {< mic.interface.device.GetSetNumber}
        device
        
    end
    
    methods
        
        function this = Shutter(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        %{
        function connectDctCorbaProxy(this, comm)
            device = bl12014.device.GetSetNumberFromDctCorbaProxy(...
                comm, ...
                bl12014.device.GetSetNumberFromDctCorbaProxy.cDEVICE_SHUTTER ...
            );
        
            this.uiShutter.setDevice(device)
            this.uiShutter.turnOn()
        end
        
        function disconnectDctCorbaProxy(this)
            this.uiShutter.turnOff()
            this.uiShutter.setDevice([])
        end
        %}
        
        function connectRigolDG1000ZVirtual(this)
            
            comm = rigol.DG1000ZVirtual();
            
            device = bl12014.device.GetSetNumberFromRigolDG1000Z(comm, 1);
            this.uiShutter.setDeviceVirtual(device);
            
            device = bl12014.device.GetSetLogicalFromRigolDG1000Z(comm, 1);
            this.uiOverride.setDeviceVirtual(device);
                
        end
                
        function connectRigolDG1000Z(this, comm)
            
            device = bl12014.device.GetSetNumberFromRigolDG1000Z(comm, 1);
            this.uiShutter.setDevice(device);
            this.uiShutter.turnOn();
            
            
            device = bl12014.device.GetSetLogicalFromRigolDG1000Z(comm, 1);
            this.uiOverride.setDevice(device);
            this.uiOverride.turnOn();
            
        end
        
        function disconnectRigolDG1000Z(this)
            
            this.uiShutter.turnOff();
            this.uiShutter.setDevice([]);
            
            this.uiOverride.turnOff();
            this.uiOverride.setDevice([]);
        end
            
        
        function build(this, hParent, dLeft, dTop)
            

            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Shutter',...
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
                       
            
            this.uiCommRigol.build(hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiShutter.build(hPanel, dLeft, dTop);
            % dTop = dTop + 15 + dSep;
            
            this.uiOverride.build(hPanel, 135, dTop);
            % dTop = dTop + 15 + dSep;
                        
        end
        
        
        
        
        function delete(this)
            
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_INIT_DELETE);

            delete(this.uiShutter) % uses deviceVirtrual so need to delete this first
            delete(this.deviceVirtual)
            delete(this.uiOverride);
            
        end    
        
        
    end
    
    
    methods (Access = private)
        
        
        function initUiOverride(this)
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Close', ...
                'cTextFalse', 'Open' ...
            };

            this.uiOverride = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'cName', [this.cName, 'shutter-manual'], ...
                'lShowName', false, ...
                'lShowInitButton', false, ...
                'cLabelCommand', 'Manual', ...
                'lShowDevice', false, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'cLabel', 'Override' ...
            );
            
        end
        
        
        function initUiCommRigol(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommRigol = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', [this.cName, 'comm-rigol'], ...
                'cLabel', 'Rigol DG1000Z' ...
            );
        
        end
        
        
         function initUiShutter(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-shutter-rigol.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiShutter = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', [this.cName, 'shutter-timed'], ...
                'config', uiConfig, ...
                'cLabel', 'Shutter', ...
                'cLabelDest', 'Timed', ...
                'cLabelPlay', '', ...
                'dWidthUnit', 120, ...
                'dWidthName', 260, ...
                'lShowRel', false, ...
                'lShowJog', false, ...
                'lShowZero', false, ...
                'lShowStores', false, ...
                'lShowStepNeg', false, ...
                'lShowStep', false, ...
                'lShowStepPos', false, ...
                'lShowVal', false, ...
                'lShowJog', false ...
            );
        
            % this.uiShutter.setDeviceVirtual(this.deviceVirtual);
        end
        
        function initDeviceShutterVirtual(this)
            this.deviceVirtual = bl12014.device.ShutterVirtual();
        end
        
        
        function init(this)
            this.msg('init()');
            
            % this.initDeviceShutterVirtual();
            this.initUiCommRigol();
            this.initUiShutter();
            this.initUiOverride();
            
            this.connectRigolDG1000ZVirtual();
        end
        
        function onFigureCloseRequest(this, src, evt)
            this.msg('closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        
        
        
    end
    
    
end

