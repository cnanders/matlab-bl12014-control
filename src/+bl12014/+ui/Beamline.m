classdef Beamline < mic.Base
    
    properties
        
        
      
        
        % {< mic.interface.device.GetSetNumber}
        deviceExitSlit
        
        % {< mic.interface.device.GetSetNumber}
        deviceUndulatorGap
        
        % {< mic.interface.device.GetSetNumber}
        deviceGratingTiltX
        
        % {< mic.interface.device.GetSetNumber}
        deviceShutter
        
        
        
        
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiExitSlit
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiUndulatorGap
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiShutter
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiGratingTiltX
        
         % {mic.ui.device.GetSetNumber 1x1}}
        uiD142StageY
        
        % {mic.ui.device.GetNumber 1x1}
        uiMeasurPointD142Volts
        
       
        
        
        
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 600
        dHeight = 214
        
        cName = 'Beamline'
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 70
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = Beamline(varargin)
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        
        function turnOn(this)
            
            this.uiExitSlit.turnOn();
            this.uiUndulatorGap.turnOn();
            this.uiShutter.turnOn();
            this.uiGratingTiltX.turnOn();
            this.uiTiltY.turnOn();
            this.uiD142StageY.turnOn();
            this.uiMeasurPointD142Volts.turnOn();
            
        end
        
        function turnOff(this)
            this.uiExitSlit.turnOff();
            this.uiUndulatorGap.turnOff();
            this.uiShutter.turnOff();
            this.uiGratingTiltX.turnOff();
            this.uiTiltY.turnOff();
            this.uiD142StageY.turnOff();
            this.uiMeasurPointD142Volts.turnOff();
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Devices',...
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
            
            this.uiExitSlit.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiUndulatorGap.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiShutter.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiGratingTiltX.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiD142StageY.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiMeasurPointD142Volts.build(this.hPanel, dLeft, dTop);
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
        
        function initUiD142StageY(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-d142-stage-y.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiD142StageY = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', 'd142-stage-y', ...
                'config', uiConfig, ...
                'dWidthName', this.dWidthName, ...
                'lShowLabels', false, ...
                'cLabel', 'D142 Stage Y' ...
            );
        end
        
        
        function initUiMeasurPointD142Volts(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-d142-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiMeasurPointD142Volts = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', 'measur-point-d142-diode', ...
                'config', uiConfig, ...
                'dWidthName', this.dWidthName, ...
                'cLabel', 'MeasurPoint (D142)', ...
                'dWidthPadUnit', 277, ...
                'lShowLabels', false ...
            );
        end 
         
        function initUiExitSlit(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-exit-slits.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiExitSlit = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'cName', 'exit-slit', ...
                'config', uiConfig, ...
                'cLabel', 'Exit Slit' ...
            );
        end
        
        function initUiUndulatorGap(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-undulator-gap.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiUndulatorGap = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', 'undulator-gap', ...
                'config', uiConfig, ...
                'cLabel', 'Undulator Gap' ...
            );
        end
        
        function initUiShutter(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-shutter.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiShutter = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', 'shutter', ...
                'config', uiConfig, ...
                'cLabel', 'Shutter' ...
            );
        end
        
        
        function initUiGratingTiltX(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-grating-tilt-x.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiGratingTiltX = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'cName', 'grating-tilt-x', ...
                'config', uiConfig, ...
                'cLabel', 'Grating Tilt X' ...
            );
        end
        
        
        
        function init(this)
            this.msg('init()');
            this.initUiExitSlit();
            this.initUiUndulatorGap();
            this.initUiShutter();
            this.initUiGratingTiltX();
            this.initUiD142StageY()
            this.initUiMeasurPointD142Volts();
        end
        
        
        
    end
    
    
end

