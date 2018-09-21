classdef PowerPmacWorkingMode < mic.Base
    
    properties
        % {mic.ui.device.GetSetText 1x1}
        uiWorkingMode
        
        % {mic.ui.device.GetLogical 1x1}
        uiWaferPositionLocked
        uiReticlePositionLocked
        uiAtWaferTransferPosition
        uiAtReticleTransferPosition
         
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 450
        dWidthName = 130
        dHeight = 190
        
        cName = 'power-pmac-working-mode'
        
    end
    
    properties (Access = private)
        
        clock
        hPanel
        
    end
    
    methods
        
        function this = PowerPmacWorkingMode(varargin)
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
            import bl12014.device.GetLogicalFromDeltaTauPowerPmac
            
            % Devices
            device = GetSetTextFromDeltaTauPowerPmac(comm, GetSetTextFromDeltaTauPowerPmac.cTYPE_WORKING_MODE);
            this.uiWorkingMode.setDevice(device);
            this.uiWorkingMode.turnOn();
            
            device = GetLogicalFromDeltaTauPowerPmac(comm, GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_AT_WAFER_TRANSFER_POSITION);
            this.uiAtWaferTransferPosition.setDevice(device);
            this.uiAtWaferTransferPosition.turnOn();
            
            device = GetLogicalFromDeltaTauPowerPmac(comm, GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_AT_RETICLE_TRANSFER_POSITION);
            this.uiAtReticleTransferPosition.setDevice(device);
            this.uiAtReticleTransferPosition.turnOn();
            
            device = GetLogicalFromDeltaTauPowerPmac(comm, GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_RETICLE_POSITION_LOCKED);
            this.uiReticlePositionLocked.setDevice(device);
            this.uiReticlePositionLocked.turnOn();
            
            device = GetLogicalFromDeltaTauPowerPmac(comm, GetLogicalFromDeltaTauPowerPmac.cTYPE_IO_INFO_WAFER_POSITION_LOCKED);
            this.uiWaferPositionLocked.setDevice(device);
            this.uiWaferPositionLocked.turnOn();
            
            %this.uiWorkingMode.syncDestination();
                        
            
        end
        
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.uiWorkingMode.turnOff();
            this.uiWorkingMode.setDevice([]);
            
            this.uiAtWaferTransferPosition.turnOff();
            this.uiAtWaferTransferPosition.setDevice([]);
            
            this.uiAtReticleTransferPosition.turnOff();
            this.uiAtReticleTransferPosition.setDevice([]);
            
            this.uiWaferPositionLocked.turnOff();
            this.uiWaferPositionLocked.setDevice([]);
            
            this.uiReticlePositionLocked.turnOff();
            this.uiReticlePositionLocked.setDevice([]);
            
            
        end
                
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Working Mode and EPS IO',...
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
            
            this.uiWorkingMode.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            this.uiAtReticleTransferPosition.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiReticlePositionLocked.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            
            this.uiAtWaferTransferPosition.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiWaferPositionLocked.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
                       
                        
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
        
        function ce = getUiCommonProps(this)
            ce = { ...
                'lShowLabels', false, ...
                'lShowInitButton', false, ...
                'dWidthName', this.dWidthName, ...
                'clock', this.clock ...  
            };
        end
        
        function initUiAtWaferTransferPosition(this)
            
            ceProps = this.getUiCommonProps();
            this.uiAtWaferTransferPosition = mic.ui.device.GetLogical(...
                'cName', [this.cName, 'at-wafer-transfer-position'], ...
                'cLabel', 'At Wafer Transfer Pos', ...
                ceProps{:} ...
            );
        end
        
        function initUiAtReticleTransferPosition(this)
            
            ceProps = this.getUiCommonProps();
            this.uiAtReticleTransferPosition = mic.ui.device.GetLogical(...
                'cName', [this.cName, 'at-reticle-transfer-position'], ...
                'cLabel', 'At Reticle Transfer Pos', ...
                ceProps{:} ...
            );
        end
        
        function initUiReticlePositionLocked(this)
            
            ceProps = this.getUiCommonProps();
            this.uiReticlePositionLocked = mic.ui.device.GetLogical(...
                'cName', [this.cName, 'reticle-position-locked'], ...
                'cLabel', 'Reticle Pos Locked', ...
                ceProps{:} ...
            );
        end
        
        function initUiWaferPositionLocked(this)
            ceProps = this.getUiCommonProps();
            this.uiWaferPositionLocked = mic.ui.device.GetLogical(...
                'cName', [this.cName, 'wafer-position-locked'], ...
                'cLabel', 'Wafer Pos Locked', ...
                ceProps{:} ...
            );
        end
        
         
        function initUiWorkingMode(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-text', ...
                'power-pmac-working-mode-no-transfer.json' ...
            );
        
            uiConfig = mic.config.GetSetText(...
                'cPath',  cPathConfig ...
            );
            
            this.uiWorkingMode = mic.ui.device.GetSetText(...
                'cName', this.cName, ...
                'cLabel', 'Working Mode', ...
                'clock', this.clock, ...
                'config', uiConfig, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowInitButton', false, ...
                'dWidthName', this.dWidthName, ...
                'dWidthVal', 120, ...
                'dWidthStores', 120, ...
                'lShowStores', true ...
            );
        end
        
        
        
        
        
        
        function init(this)
            this.msg('init()');
            this.initUiWorkingMode();
            this.initUiWaferPositionLocked();
            this.initUiReticlePositionLocked();
            this.initUiAtReticleTransferPosition();
            this.initUiAtWaferTransferPosition();
        end
        
        
        
    end
    
    
end

