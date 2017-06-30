classdef TempSensors < mic.Base
        
    properties (Constant)
      
        dWidth      = 645
        dHeight     = 505
        
    end
    
	properties
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiDeltaTauPowerPmac
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiDataTranslationMeasurPoint
        
        uiPobTempSensors
        uiMod3TempSensors
        
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
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
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
            
            this.uiDeltaTauPowerPmac.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiDataTranslationMeasurPoint.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            
            % this.mod3cap.build(this.hFigure, dPad, dTop);
            
            this.uiPobTempSensors.build(this.hFigure, dLeft, dTop);
            % dTop = dTop + this.uiPobTempSensors.dHeight + dPad;
            dLeft = dLeft + this.uiPobTempSensors.dWidth + dPad;
            
            this.uiMod3TempSensors.build(this.hFigure, dLeft, dTop);
            % dTop = dTop + this.uiMod3TempSensors.dHeight + dPad;
            dLeft = dLeft + this.uiMod3TempSensors.dWidth + dPad;
                     
            
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
        
            this.initUiDataTranslationMeasurPoint();
            this.initUiDeltaTauPowerPmac();
        
        end
        
        function initUiDataTranslationMeasurPoint(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiDataTranslationMeasurPoint = mic.ui.device.GetSetLogical(...
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
        
        function initUiDeltaTauPowerPmac(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiDeltaTauPowerPmac = mic.ui.device.GetSetLogical(...
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