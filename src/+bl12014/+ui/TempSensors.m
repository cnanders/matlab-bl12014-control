classdef TempSensors < mic.Base
        
    properties (Constant)
      
        dWidth      = 970
        dHeight     = 505
        
    end
    
	properties
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDeltaTauPowerPmac
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommDataTranslationMeasurPoint
        
        uiPobTempSensors
        uiMod3TempSensors
        uiVisTempSensors
        
    end
    
    properties (SetAccess = private)
    
        cName = 'Temp Sensors'
    end
    
    properties (Access = private)
         
        % { mic.clock 1x1} passed in
        clock
        hFigure
        
    end
    
        
    events
                
    end
    

    
    methods
        
        
        function this = TempSensors(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            this.init();
            
        end
        
                
        function build(this)
                        
            % Figure
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'Temp Sensor Monitor', ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onCloseRequest ...
            );
            
            
            drawnow;

            dTop = 10;
            dLeft = 10;
            dPad = 10;
            
            dSep = 30;
            
            this.uiCommDeltaTauPowerPmac.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCommDataTranslationMeasurPoint.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            % this.mod3cap.build(this.hFigure, dPad, dTop);
            
            this.uiPobTempSensors.build(this.hFigure, dLeft, dTop);
            % dTop = dTop + this.uiPobTempSensors.dHeight + dPad;
            dLeft = dLeft + this.uiPobTempSensors.dWidth + dPad;
            
            this.uiMod3TempSensors.build(this.hFigure, dLeft, dTop);
            % dTop = dTop + this.uiMod3TempSensors.dHeight + dPad;
            dLeft = dLeft + this.uiMod3TempSensors.dWidth + dPad;
            
            this.uiVisTempSensors.build(this.hFigure, dLeft, dTop);
                     
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end
        
       
        
        
            

    end
    
    methods (Access = private)
 
        
        function init(this)
            
            this.msg('init()');
            
            this.uiPobTempSensors = bl12014.ui.PobTempSensors(...
                'clock', this.clock ...
            );
                       
            this.uiMod3TempSensors = bl12014.ui.Mod3TempSensors(...
                'clock', this.clock ...
            );
        
            this.uiVisTempSensors = bl12014.ui.VibrationIsolationSystemTempSensors(...
                'clock', this.clock ...
            );
        
            this.initUiCommDataTranslationMeasurPoint();
            this.initUiCommDeltaTauPowerPmac();
        
        end
        
        function initUiCommDataTranslationMeasurPoint(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommDataTranslationMeasurPoint = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'data-translation-measur-point-temp-sensors', ...
                'cLabel', 'Data Trans MeasurPoint' ...
            );
        
        end
        
        function initUiCommDeltaTauPowerPmac(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCommDeltaTauPowerPmac = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'delta-tau-power-pmac-temp-sensors', ...
                'cLabel', 'DeltaTau Power PMAC' ...
            );
        
        end
        
        
        function onCloseRequest(this, src, evt)
            this.msg('TempSensorsControl.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
            % this.saveState();
        end
        

    end % private
    
    
end