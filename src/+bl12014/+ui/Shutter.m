classdef Shutter < mic.Base
    
    properties
        
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
        
        % {bl12014.Hardware 1x1}
        hardware
        
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
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
        
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
                'fhGet', @() this.hardware.getRigolDG1000Z().getIsOn(1), ...
                'fhSet', @(lVal) mic.Utils.ternEval(lVal, ...
                    @() this.hardware.getRigolDG1000Z().turnOn5VTTL(1), ...
                    @() this.hardware.getRigolDG1000Z().turnOff5VTTL(1) ...
                ), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Override' ...
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
                'fhGet', @() this.hardware.getRigolDG1000Z().getIsOn(1), ...
                'fhSet', @(dVal) this.hardware.getRigolDG1000Z().trigger5VTTLPulse(1, dVal), ...
                'fhIsReady', @() ~this.hardware.getRigolDG1000Z().getIsOn(1), ...
                'fhStop', @() this.hardware.getRigolDG1000Z().turnOff5VTTL(1), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'lShowJog', false ...
            );
        
            % this.uiShutter.setDeviceVirtual(this.deviceVirtual);
        end
                
        function init(this)
            this.msg('init()');
            this.initUiShutter();
            this.initUiOverride();
        end
        
        function onFigureCloseRequest(this, src, evt)
            this.msg('closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        
        
        
    end
    
    
end

