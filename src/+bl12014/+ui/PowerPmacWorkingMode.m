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
        
        dWidth = 430
        dWidthName = 130
        dHeight = 170
        
        cName = 'power-pmac-working-mode'

        uiSendMotMinGradNormToHydras
        uiSendMotMinGradHighToHydras
        
    end
    
    properties (Access = private)
        
        clock
        hPanel
        % {bl12014.Hardware 1x1}
        hardware
        uiClock
        
        
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
            
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end

            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
              error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
        
        end
        
        
                
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'PPMAC Working Mode and EPS IO, Hydra Low/Norm/High Push',...
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
            dSep = 25;
            
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


            dLeft = 180;
            dTop = 100;
            dWidth = 230;
            this.uiSendMotMinGradNormToHydras.build(this.hPanel, dLeft, dTop, dWidth);
            dTop = dTop + dSep;
            this.uiSendMotMinGradHighToHydras.build(this.hPanel, dLeft, dTop, dWidth);
            
                       
                        
        end
        
        function delete(this)
            
            this.msg('delete');

            delete(this.uiSendMotMinGradNormToHydras);
            delete(this.uiSendMotMinGradHighToHydras);
                        
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
                'clock', this.uiClock ...  
            };
        end
        
        function initUiAtWaferTransferPosition(this)
            
            ceProps = this.getUiCommonProps();
            this.uiAtWaferTransferPosition = mic.ui.device.GetLogical(...
                'cName', [this.cName, 'at-wafer-transfer-position'], ...
                'cLabel', 'At Wafer Transfer Pos', ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getIoInfoAtWaferTransferPosition(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                ceProps{:} ...
            );
        end
        
        function initUiAtReticleTransferPosition(this)
            
            ceProps = this.getUiCommonProps();
            this.uiAtReticleTransferPosition = mic.ui.device.GetLogical(...
                'cName', [this.cName, 'at-reticle-transfer-position'], ...
                'cLabel', 'At Reticle Transfer Pos', ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getIoInfoAtReticleTransferPosition(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                ceProps{:} ...
            );
        end
        
        function initUiReticlePositionLocked(this)
            
            ceProps = this.getUiCommonProps();
            this.uiReticlePositionLocked = mic.ui.device.GetLogical(...
                'cName', [this.cName, 'reticle-position-locked'], ...
                'cLabel', 'Reticle Pos Locked', ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getIoInfoReticlePositionLocked(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                ceProps{:} ...
            );
        end
        
        function initUiWaferPositionLocked(this)
            ceProps = this.getUiCommonProps();
            this.uiWaferPositionLocked = mic.ui.device.GetLogical(...
                'cName', [this.cName, 'wafer-position-locked'], ...
                'cLabel', 'Wafer Pos Locked', ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getIoInfoWaferPositionLocked(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                ceProps{:} ...
            );
        end
        
         
        function initUiWorkingMode(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-power-pmac-working-mode.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiWorkingMode = mic.ui.device.GetSetNumber(...
                'cName', this.cName, ...
                'cLabel', 'Working Mode', ...
                'clock', this.uiClock, ...
                'config', uiConfig, ...
                'lShowDest', false, ...
                'lShowPlay', false, ...
                'lShowInitButton', false, ...
                'lShowStepNeg', false, ...
                'lShowStep', false, ...
                'lShowStepPos', false, ...
                'lShowUnit', false, ...
                'lShowRel', false, ...
                'lShowZero', false, ...
                'dWidthName', this.dWidthName, ...
                'dWidthVal', 24, ...
                'dWidthStores', 120, ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getActiveWorkingMode(), ...
                'fhSet', @(dVal) this.setWorkingMode(dVal), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'lShowStores', true ...
            );
        end

        
        
        
        function init(this)
            this.msg('init()');

           

            this.uiSendMotMinGradNormToHydras = mic.ui.TaskSequence( ...
                'cName', [this.cName, 'ui-sequence-set-norm'], ...
                'task', bl12014.Tasks.createSequenceSendMotMinGradNormToHydras(...
                  [this.cName, 'sequence-set-norm'], ...
                  this.hardware, ...
                  this.clock ...
                ), ...
                'dDelay', 0.25, ...
                'lShowIsDone', false, ...
                'clock', this.clock ...
            );

            this.uiSendMotMinGradHighToHydras = mic.ui.TaskSequence( ...
                'cName', [this.cName, 'ui-sequence-set-high'], ...
                'task', bl12014.Tasks.createSequenceSendMotMinGradHighToHydras(...
                  [this.cName, 'sequence-set-high'], ...
                  this.hardware, ...
                  this.clock ...
                ), ...
                'dDelay', 0.25, ...
                'lShowIsDone', false, ...
                'clock', this.clock ...
            );

            this.initUiWorkingMode();
            this.initUiWaferPositionLocked();
            this.initUiReticlePositionLocked();
            this.initUiAtReticleTransferPosition();
            this.initUiAtWaferTransferPosition();
        end
        
        function setWorkingMode(this, dVal)


          
            %{
            if (dVal == 7)
              % Send the Hydra MotMin MotGrad "High" settings from PPMAC to the Hydra
              this.uiSendMotMinGradHighToHydras.execute();

              % wait until done executing
              while (this.uiSendMotMinGradHighToHydras.isExecuting())
                  this.msg('Waiting for isExecuting complete');
                  pause(0.1);
              end
  
            else
              % Send the Hydra MotMin MotGrad "Norm" settings from PPMAC to the Hydra
              this.uiSendMotMinGradNormToHydras.execute();

              % wait until done executing
              while (this.uiSendMotMinGradNormToHydras.isExecuting())
                              this.msg('Waiting for isExecuting complete');

                  pause(0.1);
              end
  
            end
            %}
           
  
              
            switch dVal
                case 0
                    this.hardware.getDeltaTauPowerPmac().setWorkingModeUndefined();
                case 1
                    this.hardware.getDeltaTauPowerPmac().setWorkingModeActivate();
                case 2
                    this.hardware.getDeltaTauPowerPmac().setWorkingModeShutdown();
                case 3
                    this.hardware.getDeltaTauPowerPmac().setWorkingModeRunSetup();
                case 4
                    this.hardware.getDeltaTauPowerPmac().setWorkingModeRunExposure();
                case 5
                    this.hardware.getDeltaTauPowerPmac().setWorkingModeRun();
                case 6
                    this.hardware.getDeltaTauPowerPmac().setWorkingModeLsiRun();
                case 7
                    this.hardware.getDeltaTauPowerPmac().setWorkingModeWaferTransfer();
                    return

                    % First confirm this with a msgbox: 
                    cMsg = sprintf(...
                        'Are you sure you want send WAFER to Transfer?\n\n' ...
                    );
                    cTitle = 'Confirm Wafer Transfer';
                    cAnswer = questdlg(cMsg, cTitle, 'Yes', 'Cancel', 'Cancel');
                    switch cAnswer
                        case 'Yes'
                            this.hardware.getDeltaTauPowerPmac().setWorkingModeWaferTransfer();
                        case 'Cancel'
                            return
                    end
                case 8
                     % First confirm this with a msgbox: 
                    cMsg = sprintf(...
                     'Are you sure you want send RETICLE to Transfer?\n\n' ...
                    );
                    cTitle = 'Confirm Reticle Transfer';
                    cAnswer = questdlg(cMsg, cTitle, 'Yes', 'Cancel', 'Cancel');
                    switch cAnswer
                        case 'Yes'
                            this.hardware.getDeltaTauPowerPmac().setWorkingModeReticleTransfer();
                        case 'Cancel'
                            return
                    end
            end
                
        end
            
            
            
        
        
    end
    
    
end

