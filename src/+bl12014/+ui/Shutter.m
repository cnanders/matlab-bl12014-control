classdef Shutter < mic.Base
    
    properties
        
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiShutter
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiOverride
        
    end
    
    properties (SetAccess = private)
        
        dHeight = 60 
        
        cName = 'shutter'
        
        uiTextMDM

                
    end
    
    properties (Access = private)
        
        clock
        uiClock
        
        dWidth = 460
        configStageY
        configMeasPointVolts
        
        % {< mic.interface.device.GetSetNumber}
        device
        
        % {bl12014.Hardware 1x1}
        hardware
        
        
        taskSequenceUpdateMDM
        
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
            
            
              if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
              end
            
            if ~isa(this.clock, 'mic.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
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
            
            this.uiOverride.build(hPanel, 110, dTop);
            % dTop = dTop + 15 + dSep;
            
            this.uiTextMDM.build(hPanel, 380, dTop, 100, 40)
                        
        end
        
        
        
        
        function delete(this)
            
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);

            delete(this.uiShutter) % uses deviceVirtrual so need to delete this first
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
                'clock', this.uiClock, ...
                'cName', [this.cName, 'shutter-manual'], ...
                'lShowName', false, ...
                'dWidthCommand', 60, ...
                'lShowInitButton', false, ...
                'cLabelCommand', 'Manual', ...
                'lShowDevice', false, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                ...'fhGet', @() this.hardware.getRigolDG1000Z().getIsOn(1), ...
                'fhGet', @() this.hardware.getTekAFG31021().getIsOn(), ...
                'fhSet', @(lVal) this.overrideShutter(lVal), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Override' ...
            );
            
        end
        
        
        
        
        function updateMDM(this)
            
             dVal = this.hardware.getDoseMonitor().getCharge(this.hardware.getSR570MDM().getSensitivity());
             
             % convert measured charge into millions of electrons since
             % that is what the UI is
             dVal = dVal / 1e6;
             dVal = round(dVal);
             this.uiTextMDM.set(num2str(dVal));
            
        end
        
        function overrideShutter(this, lVal)
            
            % doing this here so we can get the MDM capability built-in
            
            
            %{
mic.Utils.ternEval(lVal, ...
                    @() this.hardware.getRigolDG1000Z().turnOn5VTTL(1), ...
                    @() this.hardware.getRigolDG1000Z().turnOff5VTTL(1) ...
                )
            %}
            
            mic.Utils.ternEval(lVal, ...
                    @() this.hardware.getTekAFG31021().turnOn5V(), ...
                    @() this.hardware.getTekAFG31021().turnOff5V() ...
                )
            
            
            if (lVal)
                this.taskSequenceUpdateMDM.abort();
             this.taskSequenceUpdateMDM.execute();
            end
            
            
        end
        
        
        
        function setShutter(this, dVal)
            
             % this.hardware.getRigolDG1000Z().trigger5VTTLPulse(1, dVal)
             this.hardware.getTekAFG31021().trigger5VPulse(dVal)
             
             % Start checking to see when done.  Once done, get the dose
             % monitor value.  Can use a Task Sequence consisting of a 
             % wait until shutter is closed, and a get MDM
             
             this.taskSequenceUpdateMDM.abort();
             this.taskSequenceUpdateMDM.execute();
            
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
                'clock', this.uiClock, ...
                'cName', [this.cName, 'shutter-timed'], ...
                'config', uiConfig, ...
                'cLabel', 'Shutter', ...
                'cLabelDest', 'Timed', ...
                'cLabelPlay', '', ...
                'dWidthUnit', 60, ...
                'dWidthName', 190, ... % because override button positioned to left
                'dWidthDest', 70, ...
                'lShowRel', false, ...
                'lShowJog', false, ...
                'lShowZero', false, ...
                'lShowStores', false, ...
                'lShowStepNeg', false, ...
                'lShowStep', false, ...
                'lShowStepPos', false, ...
                'lShowVal', false, ...
                'fhSet', @(dVal) this.setShutter(dVal), ...
                ...'fhGet', @() this.hardware.getRigolDG1000Z().getIsOn(1), ...
                ...'fhIsReady', @() ~this.hardware.getRigolDG1000Z().getIsOn(1), ...
                ...'fhStop', @() this.hardware.getRigolDG1000Z().turnOff5VTTL(1), ...
                'fhGet', @() this.hardware.getTekAFG31021().getIsOn(), ...
                'fhIsReady', @() ~this.hardware.getTekAFG31021().getIsOn(), ...
                'fhStop', @() this.hardware.getTekAFG31021().turnOff5V(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'lShowJog', false ...
            );
        
         end
        
         
         function initTaskSequenceUpdateMDM(this)
             
          taskWaitUntilShutterIsClosed = mic.Task(...
                'fhIsDone', @() this.uiShutter.isReady(), ...
                'fhGetMessage', @() 'Wait for shutter closed' ... 
            );
        
             taskUpdateMDM = mic.Task(...
                 'fhExecute', @() this.updateMDM(), ...
                 'fhGetMessage', @() 'Refreshing MDM' ...
             );
             
        
            ceTasks = {...
                taskWaitUntilShutterIsClosed, ...
                taskUpdateMDM
           };
        
           this.taskSequenceUpdateMDM = mic.TaskSequence(...
                'cName', 'shuttert-get-latest-mdm', ...
                'clock', this.clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'fhGetMessage', @() 'Calibrate' ...
            );    
         end
         
                
        function init(this)
            this.msg('init()');
            this.initUiShutter();
            this.initUiOverride();
            
            this.uiTextMDM = mic.ui.common.Text(...
                'cLabel', 'Last MDM (ME)', ...
                'lShowLabel', true, ...
                'cVal', '...' ...
            );
        
            this.initTaskSequenceUpdateMDM();
        
            
        end
        
        function onFigureCloseRequest(this, src, evt)
            this.msg('closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        
        
        
    end
    
    
end

