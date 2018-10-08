classdef Mod3CapSensors < mic.Base
    
    properties

        % {mic.ui.device.GetNumber 1x1}}
        uiCap1
        
        % {mic.ui.device.GetNumber 1x1}}
        uiCap2
        
        % {mic.ui.device.GetNumber 1x1}}
        uiCap3
        
        % {mic.ui.device.GetNumber 1x1}}
        uiCap4
        
        uiTextTiltX
        uiTextTiltY
                
    end
    
    properties (SetAccess = private)
        
        dWidth = 550
        dHeight = 160
        
        cName = 'Mod3 Cap Sensors'
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 40
        dWidthUnit = 80
        dWidthVal = 75
        dWidthPadUnit = 5
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = Mod3CapSensors(varargin)
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
            
            import bl12014.device.GetNumberFromDeltaTauPowerPmac
            
            deviceCap1 = GetNumberFromDeltaTauPowerPmac( comm, GetNumberFromDeltaTauPowerPmac.cTYPE_RETICLE_CAP_1);
            deviceCap2 = GetNumberFromDeltaTauPowerPmac( comm, GetNumberFromDeltaTauPowerPmac.cTYPE_RETICLE_CAP_2);
            deviceCap3 = GetNumberFromDeltaTauPowerPmac( comm, GetNumberFromDeltaTauPowerPmac.cTYPE_RETICLE_CAP_3);
            deviceCap4 = GetNumberFromDeltaTauPowerPmac( comm, GetNumberFromDeltaTauPowerPmac.cTYPE_RETICLE_CAP_4);
            
            this.uiCap1.setDevice(deviceCap1);
            this.uiCap2.setDevice(deviceCap2);
            this.uiCap3.setDevice(deviceCap3);
            this.uiCap4.setDevice(deviceCap4);
            
            this.uiCap1.turnOn();
            this.uiCap2.turnOn();
            this.uiCap3.turnOn();
            this.uiCap4.turnOn();
        end
        
        function disconnectDeltaTauPowerPmac(this)
            
            this.uiCap1.turnOff();
            this.uiCap2.turnOff();
            this.uiCap3.turnOff();
            this.uiCap4.turnOff();
            
            this.uiCap1.setDevice([]);
            this.uiCap2.setDevice([]);
            this.uiCap3.setDevice([]);
            this.uiCap4.setDevice([]);
        end
        
        
        function turnOn(this)
            
            this.uiCap1.turnOn();
            this.uiCap2.turnOn();
            this.uiCap3.turnOn();
            this.uiCap4.turnOn();
            
            
            
            
        end
        
        function turnOff(this)
            this.uiCap1.turnOff();
            this.uiCap2.turnOff();
            this.uiCap3.turnOff();
            this.uiCap4.turnOff();
            
            
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Mod3 Cap Sensors (PPMAC) 10V = 1 um (near gap); -10V = 3 um',...
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
            
            this.uiCap1.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiCap2.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCap3.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCap4.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            dTop = 20;
            dLeft = 300;
            this.uiTextTiltX.build(this.hPanel, dLeft, dTop, 100, 24);
            dLeft = dLeft + 100;
            this.uiTextTiltY.build(this.hPanel, dLeft, dTop, 100, 24);
            
            if ~isempty(this.clock) && ...
                ~this.clock.has(this.id())
                this.clock.add(@this.onClock, this.id(), 1);
            end
                        
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            if ~isempty(this.clock) && ...
                isvalid(this.clock) && ...
                this.clock.has(this.id())
                this.msg('delete() removing clock task', this.u8_MSG_TYPE_INFO); 
                this.clock.remove(this.id());
            end
            
            
        end 
        
        
        function [dTiltX, dTiltY] = getTiltXAndTiltY(this)
            
            dOffsetX = 34.075 * 1e-3; % m
            dOffsetY = 27.833 * 1e-3; % m
            
            % four points in the plane, one from each sensor
            % 4         3
            % 1         2
            %
            dPoint4 = [-dOffsetX 0 this.uiCap4.getValCal('um')*1e-6];
            dPoint3 = [dOffsetX 0 this.uiCap3.getValCal('um')*1e-6];
            dPoint2 = [dOffsetX -dOffsetY this.uiCap2.getValCal('um')*1e-6];
            dPoint1 = [-dOffsetX -dOffsetY this.uiCap1.getValCal('um')*1e-6];
            
            % Compute vectors in the plane
            dV43 = dPoint4 - dPoint3;
            dV42 = dPoint4 - dPoint2;
            dV41 = dPoint4 - dPoint1;
            
            % Compute cross to get vector normal to the plane, then
            % make it unit magnitude
            dN4342 = cross(dV43, dV42); % vector normal to plane
            dN4342 = dN4342./(sqrt(sum(dN4342.^2))); % unit magnitude vector normal to plane
            
            
            dN4341 = cross(dV43, dV41); % vector normal to plane
            dN4341 = dN4341./(sqrt(sum(dN4341.^2))); % unit magnitude vector normal to plane
            
            [dTiltX, dTiltY] = this.getTiltXAndTiltYFromNormalVector(dN4342);
            [dTiltX2, dTiltY2] = this.getTiltXAndTiltYFromNormalVector(dN4341);
            
%             fprintf('tiltX = %1.1f, %1.1f\n', ...
%                 dTiltX * pi / 180 * 1e6, ...
%                 dTiltX2 * pi / 180 * 1e6 ...
%             );
%         
%             fprintf('tiltY = %1.1f, %1.1f\n', ...
%                 dTiltY * pi / 180 * 1e6, ...
%                 dTiltY2 * pi / 180 * 1e6 ...
%             );
            
        end
        
        
    end
    
    methods (Access = private)
                
         
        function initUiCap1(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-mod3-cap-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCap1 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'mod3-cap-sensor-1', ...
                'config', uiConfig, ...
                'cLabel', '1' ...
            );
        end
        
        function initUiCap2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-mod3-cap-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCap2 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'mod3-cap-sensor-2', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'cLabel', '2' ...
            );
        end
        
        function initUiCap3(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-mod3-cap-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCap3 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'mod3-cap-sensor-3', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'cLabel', '3' ...
            );
        end
        
        function initUiCap4(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-mod3-cap-sensor.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCap4 = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', this.dWidthUnit, ...
                'dWidthVal', this.dWidthVal, ...
                'dWidthPadUnit', this.dWidthPadUnit, ...
                'cName', 'mod3-cap-sensor-4', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'cLabel', '4' ...
            );
        end
        
       
        function initUiTextTiltX(this)
            
            this.uiTextTiltX = mic.ui.common.Text(...
                'cLabel', 'TiltX (urad)', ...
                'lShowLabel', true ...
            );
            
        end
        
        function initUiTextTiltY(this)
            
            this.uiTextTiltY = mic.ui.common.Text(...
                'cLabel', 'TiltY (urad)', ...
                'lShowLabel', true ...
            );
            
        end
        
        
        
        % @param {double 1x3} dN - normal vector
        function [dTiltX, dTiltY] = getTiltXAndTiltYFromNormalVector(this, dN)
            
            % Normal vector.  Assumes rotation about the x axis by dThetaX, then in
            % this new coordinate system, rotate about the y axis by dTiltY
            % This is must have stole this from wikipedia?

            % dN = [sin(dTiltY) -cos(dTiltY)*sin(dThetaX) cos(dTiltY)*cos(dThetaX)]
            
            dTiltY = asin(dN(1)) * 180 / pi;
            dTiltX = asin(- dN(2) / cos(dTiltY * pi / 180)) * 180 / pi;

        end
        
        function onClock(this)
            
            if ~ishghandle(this.hPanel)
                this.msg('onClock() returning since not build', this.u8_MSG_TYPE_INFO);
                
                % Remove task
                if isvalid(this.clock) && ...
                   this.clock.has(this.id())
                    this.clock.remove(this.id());
                end
            end
            
            [dTiltX, dTiltY] = this.getTiltXAndTiltY();
            this.uiTextTiltX.set(sprintf('%1.1f', dTiltX * pi / 180 * 1e6))
            this.uiTextTiltY.set(sprintf('%1.1f', dTiltY * pi / 180 * 1e6))
            
        end
        
        
        function init(this)
            this.msg('init()');
            this.initUiTextTiltX();
            this.initUiTextTiltY();
            this.initUiCap1();
            this.initUiCap2();
            this.initUiCap3();
            this.initUiCap4();
            
            
        end
        
        
        
    end
    
    
end

