classdef SMS < mic.Base
    
    properties
              
        cName = 'SMS'
        
        
    end
    
    properties (Access = private)
        
        % {bl12014.Hardware 1x1}
        hardware
        
        clock
        
        dWidthName = 120
        lShowDevice = false
        lShowLabels = false
        lShowInitButton = false        
        
        dWidth = 440
        dHeight = 480  
        
        
        uiBeamlineOpen
        uiBeamlineBusy
        uiOnlineMode
        uiRemoteMode
        uiSourceOn
        uiSourceError
        uiVacuumOK
        uiRoughingPumpsOK
        
        uiWobbleWorkingMode
%         uiSystemWarning
%         uiSystemError
        
        uiDiagnostics
        uiAperture
        
    end
    
    
    methods
        
        function this = SMS(varargin)
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
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
            
        end
        
        

        
        
        
        

        
        function build(this, hParent, dLeft, dTop)
            
            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'SMS',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
           
                        
            % set(hParent, 'renderer', 'OpenGL'); % Enables proper stacking
            dPad = 10;
            dLeft = 10;
            dTop = 15;
            dSep = 30;
            
            this.uiBeamlineOpen.build(hPanel, dLeft, dTop);
            dTop = dTop + dSep;

            this.uiWobbleWorkingMode.build(hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiBeamlineBusy.build(hPanel, dLeft, dTop);
            dTop = dTop + dSep;
                        
                       
            this.uiOnlineMode.build(hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiRemoteMode.build(hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiSourceOn.build(hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiSourceError.build(hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiVacuumOK.build(hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiRoughingPumpsOK.build(hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
%             this.uiSystemWarning.build(hPanel, dLeft, dTop);
%             dTop = dTop + dSep;
%             
%             this.uiSystemError.build(hPanel, dLeft, dTop);
%             dTop = dTop + dSep;
            
            this.uiDiagnostics.build(hPanel, dLeft, dTop);
            dTop = dTop + this.uiDiagnostics.dHeight + dSep;
            
            this.uiAperture.build(hPanel, dLeft, dTop);
            dTop = dTop + this.uiAperture.dHeight + dSep;
            
            
        end
        
        function delete(this)
            
            this.uiBeamlineOpen.delete()
            this.uiWobbleWorkingMode.delete()
            this.uiBeamlineBusy.delete()
            this.uiOnlineMode.delete()
            this.uiRemoteMode.delete()
            this.uiSourceOn.delete()
            this.uiSourceError.delete()
            this.uiVacuumOK.delete()
            this.uiRoughingPumpsOK.delete()
%             this.uiSystemWarning.delete()
%             this.uiSystemError.delete()

            this.uiDiagnostics.delete()
                       
            
        end    
        
        
    end
    
    methods (Access = private)
        
                
        function init(this)
            
            this.msg('init()');
                        
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-logical', ...
                'config-sms.json' ...
            );
        
            config = mic.config.GetSetLogical(...
                'cPath',  cPathConfig ...
            );
            
            this.uiBeamlineOpen = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hardware.getSMS().getBeamlineOpen(), ...
                'fhSet', @(lVal) this.hardware.getSMS().setBeamlineOpen(lVal), ...
                'lUseFunctionCallbacks', true, ...
                'ceVararginCommandToggle', {'cTextTrue', 'Close', 'cTextFalse', 'Open'}, ...
                'cName', [this.cName, 'BeamlineOpen'], ...
                'cLabel', 'BeamlineOpen' ...
            );

            this.uiWobbleWorkingMode = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hardware.getSMS().getWobbleWorkingMode(), ...
                'fhSet', @(lVal) this.hardware.getSMS().setWobbleWorkingMode(lVal), ...
                'lUseFunctionCallbacks', true, ...
                'ceVararginCommandToggle', {'cTextTrue', 'Close', 'cTextFalse', 'Open'}, ...
                'cName', [this.cName, 'WobbleWorkingMode'], ...
                'cLabel', 'Wobble Working Mode' ...
            );
        
           
            this.uiBeamlineBusy = mic.ui.device.GetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hardware.getSMS().getBeamlineBusy(), ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'BeamlineBusy'], ...
                'cLabel', 'BeamlineBusy' ...
            );
        
            this.uiOnlineMode = mic.ui.device.GetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hardware.getSMS().getOnlineMode(), ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'OnlineMode'], ...
                'cLabel', 'OnlineMode' ...
            );
        
            this.uiRemoteMode = mic.ui.device.GetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hardware.getSMS().getRemoteMode(), ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'RemoteMode'], ...
                'cLabel', 'RemoteMode' ...
            );
        
            this.uiSourceOn = mic.ui.device.GetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hardware.getSMS().getSourceOn(), ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'SourceOn'], ...
                'cLabel', 'SourceOn' ...
            );
        
            this.uiSourceError = mic.ui.device.GetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hardware.getSMS().getSourceError(), ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'SourceError'], ...
                'cLabel', 'SourceError' ...
            );
        
            this.uiVacuumOK = mic.ui.device.GetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hardware.getSMS().getVacuumOK(), ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'VacuumOK'], ...
                'cLabel', 'VacuumOK' ...
            );
        
            this.uiRoughingPumpsOK = mic.ui.device.GetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hardware.getSMS().getRoughingPumpsOK(), ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'RoughingPumpsOK'], ...
                'cLabel', 'RoughingPumpsOK' ...
            );
        
        %{
            this.uiSystemWarning = mic.ui.device.GetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hardware.getSMS().getSystemWarning(), ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'SystemWarning'], ...
                'cLabel', 'SystemWarning' ...
            );
        
            this.uiSystemError = mic.ui.device.GetLogical(...
                'clock', this.clock, ...
                'config', config, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hardware.getSMS().getSystemError(), ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'SystemError'], ...
                'cLabel', 'SystemError' ...
            );
        %}
            this.uiDiagnostics = bl12014.ui.SMSIFDiagnostics(...
                'hardware', this.hardware, ...
                'clock', this.clock ...
            );
        
            this.uiAperture = bl12014.ui.SMSIFAperture(...
                'hardware', this.hardware, ...
                'clock', this.clock ...
            );
        
            

            
        end
        
     
                
        
        
    end
    
    
end

