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
        uiTextZ
                
    end
    
    properties (SetAccess = private)
        
        dWidth = 390
        dHeight = 140
        
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
        
         % {bl12014.Hardware 1x1}
        hardware
        
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
            
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
        
        end
        
        function onClose(this)
            delete(this.hPanel);
            this.hPanel = []; % necessary to remove clock task
            
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
            dSep = 25;
            
            this.uiCap1.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiCap2.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCap3.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCap4.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            dTop = 20;
            dLeft = 325;
            
             this.uiTextZ.build(this.hPanel, dLeft, dTop, 100, 24);
             dTop = dTop + 40;
            this.uiTextTiltX.build(this.hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + 40;
            this.uiTextTiltY.build(this.hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + 50;
           
            
            if ~isempty(this.clock) && ...
                ~this.clock.has(this.id())
                this.clock.add(@this.onClock, sprintf('%s-calc-tiltx-tilty', this.id()), 1);
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
        
        
        function [dTiltX, dTiltY, dZ] = getTiltXAndTiltYAndZ(this)
            
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
            
            dZ = mean([dPoint1(3), dPoint2(3), dPoint3(3), dPoint4(3)]) * 1e6 -2282; % Offset to read roughly around 0 for level
            
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
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getVoltageReticleCap1(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
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
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getVoltageReticleCap2(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
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
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getVoltageReticleCap3(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
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
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getVoltageReticleCap4(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
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
        
        function initUiTextZ(this)
            
            this.uiTextZ = mic.ui.common.Text(...
                'cLabel', 'Z (um)', ...
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
            
            if isempty(this.hPanel) || ~ishghandle(this.hPanel)
                this.msg('onClock() returning since not build', this.u8_MSG_TYPE_INFO);
                
                % Remove task
                if isvalid(this.clock) && ...
                   this.clock.has(sprintf('%s-calc-tiltx-tilty', this.id()))
                    this.clock.remove(sprintf('%s-calc-tiltx-tilty', this.id()));
                end
            end
            
            [dTiltX, dTiltY, dZ] = this.getTiltXAndTiltYAndZ();
            this.uiTextTiltX.set(sprintf('%1.1f', dTiltX * pi / 180 * 1e6))
            this.uiTextTiltY.set(sprintf('%1.1f', dTiltY * pi / 180 * 1e6))
            this.uiTextZ.set(sprintf('%1.3f', dZ))
            
        end
        
        
        
        
        function init(this)
            this.msg('init()');
            this.initUiTextTiltX();
            this.initUiTextTiltY();
            this.initUiTextZ();
            this.initUiCap1();
            this.initUiCap2();
            this.initUiCap3();
            this.initUiCap4();
            
            
        end
        
        
        
    end
    
    
end

