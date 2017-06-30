classdef Wafer < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 1435 %1295
        dHeight     = 825
        
    end
    
	properties
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiDeltaTauPowerPmac
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCxroHeightSensor
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiKeithley6482
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiDataTranslationMeasurPoint
        
        uiCoarseStage
        uiFineStage
        uiAxes
        uiPobCapSensors
        uiHeightSensor
       
    end
    
    properties (SetAccess = private)
        
        hFigure
        
    end
    
    properties (Access = private)
                      
        clock
        dDelay = 0.15
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = Wafer(varargin)
            
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
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name', 'Wafer Control',...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onCloseRequestFcn ...
                );
            
            % There is a bug in the default 'painters' renderer when
            % drawing stacked patches.  This is required to make ordering
            % work as expected
            
            % set(this.hFigure, 'renderer', 'OpenGL');
            
            drawnow;

            dTop = 10;
            dPad = 10;
            dLeft = 10;
            dSep = 30;

            
            this.uiCxroHeightSensor.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiDeltaTauPowerPmac.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiKeithley6482.build(this.hFigure, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiDataTranslationMeasurPoint.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            % this.hs.build(this.hFigure, dPad, dTop);
            this.uiCoarseStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiCoarseStage.dHeight + dPad;
            
            this.uiFineStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiFineStage.dHeight + dPad;
            
            this.uiPobCapSensors.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiPobCapSensors.dHeight + dPad;
            
            this.uiHeightSensor.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiHeightSensor.dHeight + dPad;
            
            dLeft = 620;
            dTop = 10;
            this.uiAxes.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiAxes.dHeight + dPad;
           
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
            
            if (isvalid(this.clock))
                this.clock.remove(this.id());
            end
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
        end
               
        
        function onClock(this)
            
            % Make sure the hggroup of the carriage is at the correct
            % location.  
            
            dX = this.uiCoarseStage.uiX.getValCal('m');
            dY = this.uiCoarseStage.uiY.getValCal('m');
            this.uiAxes.setStagePosition(dX, dY);
                        
        end
        
    end
    
    methods (Access = private)
        
        function init(this)
            
            this.msg('init()');
            this.uiCoarseStage = bl12014.ui.WaferCoarseStage(...
                'clock', this.clock ...
            );
            this.uiFineStage = bl12014.ui.WaferFineStage(...
                'clock', this.clock ...
            );
            this.uiPobCapSensors = bl12014.ui.PobCapSensors(...
                'clock', this.clock ...
            );
            this.uiHeightSensor = bl12014.ui.HeightSensor( ...
                'clock', this.clock ...
            );
        
            this.initUiCxroHeightSensor();
            this.initUiDeltaTauPowerPmac();
            this.initUiDataTranslationMeasurPoint();
            this.initUiKeithley6482();
        
            dHeight = this.dHeight - 20;
            this.uiAxes = bl12014.ui.WaferAxes( ...
                'dWidth', dHeight, ...
                'dHeight', dHeight ...
            );
            
                        
            % this.hs     = HeightSensor(this.clock);
            this.clock.add(@this.onClock, this.id(), this.dDelay);

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
                'cName', 'data-translation-measur-point-wafer', ...
                'cLabel', 'DataTrans MeasurPoint' ...
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
                'cName', 'delta-tau-power-pmac-wafer', ...
                'cLabel', 'DeltaTau Power PMAC' ...
            );
        
        end
        
        function initUiCxroHeightSensor(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiCxroHeightSensor = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'cxro-height-sensor', ...
                'cLabel', 'CXRO Height Sensor' ...
            );
        
        end
        
        function initUiKeithley6482(this)
            
             % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };
        
            this.uiKeithley6482 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'keithley-6482-wafer', ...
                'cLabel', 'Keithley 6482 (Wafer)' ...
            );
        
        end
        
        
        function onCloseRequestFcn(this, src, evt)
            
            delete(this.hFigure);
            this.hFigure = [];
            % this.saveState();
            
        end
        
       
        
        
        
        
        
        
    end % private
    
    
end