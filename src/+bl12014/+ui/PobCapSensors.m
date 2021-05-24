classdef PobCapSensors < mic.Base
    
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
        
       dWidth = 320
        dHeight = 140
        
        cName = 'POB Cap Sensors'
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 20
        dWidthUnit = 80
        dWidthVal = 50
        dWidthPadUnit = 5 % 280
        
        configStageY
        configMeasPointVolts
        
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    methods
        
        function this = PobCapSensors(varargin)
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
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'POB Cap Sensors (PPMAC) 10V = 1 mm (near gap); -10V = 3 mm ',...
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
            dSep = 24;
            
            this.uiCap1.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            
            this.uiCap2.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCap3.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCap4.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            
            
            dTop = 20;
            dLeft = 250;
            this.uiTextTiltX.build(this.hPanel, dLeft, dTop, 100, 24);
            
            dTop = dTop + dSep + 10;
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
            
            
        end   
        
        % Returns tip and tilt as seen by the cap sensors in rad 
        
        function [dTiltX, dTiltY] = getTiltXAndTiltYWithoutSensor4(this)
            
            dTiltX = 0;
            dTiltY = 0;

            dOffsetX = 34.075 * 1e-3; % m
            dOffsetY = 27.833 * 1e-3; % m

            dR = 168e-3 / 2; 

            dTheta1 = -90 * pi / 180; % 1200
            dTheta2 = -150 * pi / 180; 
            dTheta3 = 90 * pi / 180;
            dTheta4 = 30 * pi / 180;

            dPoint1 = [dR * cos(dTheta1) dR * sin(dTheta1) this.uiCap1.getValCal('um')*1e-6];
            dPoint2 = [dR * cos(dTheta2) dR * sin(dTheta2) this.uiCap2.getValCal('um')*1e-6];
            dPoint3 = [dR * cos(dTheta3) dR * sin(dTheta3) this.uiCap3.getValCal('um')*1e-6];
            dPoint4 = [dR * cos(dTheta4) dR * sin(dTheta4) this.uiCap4.getValCal('um')*1e-6];


            try
                % Compute vectors in the plane
                dV32 = dPoint3 - dPoint2;
                dV31 = dPoint3 - dPoint1;

                % Compute cross to get vector normal to the plane, then
                % make it unit magnitude
                dN = cross(dV32, dV31); % vector normal to plane
                dN = dN./(sqrt(sum(dN.^2))); % unit magnitude vector normal to plane

                [dTiltX, dTiltY] = this.getTiltXAndTiltYFromNormalVector(dN);

    %             fprintf('tiltX = %1.1f, %1.1f\n', ...
    %                 dTiltX * pi / 180 * 1e6, ...
    %                 dTiltX2 * pi / 180 * 1e6 ...
    %             );
    %         
    %             fprintf('tiltY = %1.1f, %1.1f\n', ...
    %                 dTiltY * pi / 180 * 1e6, ...
    %                 dTiltY2 * pi / 180 * 1e6 ...
    %             );
    
                    % Invert values into perspective of wafer stage, not
                    % cap sensors looking down
                    dTiltX = -dTiltX;
                    dTiltY = -dTiltY;

            catch mE

            end
        end
        
        function [dTiltX, dTiltY] = getTiltXAndTiltY(this)
            
            dTiltX = 0;
            dTiltY = 0;

            dOffsetX = 34.075 * 1e-3; % m
            dOffsetY = 27.833 * 1e-3; % m

            dR = 168e-3 / 2; 

            dTheta1 = -90 * pi / 180; % 1200
            dTheta2 = -150 * pi / 180; 
            dTheta3 = 90 * pi / 180;
            dTheta4 = 30 * pi / 180;

            dPoint1 = [dR * cos(dTheta1) dR * sin(dTheta1) this.uiCap1.getValCal('um')*1e-6];
            dPoint2 = [dR * cos(dTheta2) dR * sin(dTheta2) this.uiCap2.getValCal('um')*1e-6];
            dPoint3 = [dR * cos(dTheta3) dR * sin(dTheta3) this.uiCap3.getValCal('um')*1e-6];
            dPoint4 = [dR * cos(dTheta4) dR * sin(dTheta4) this.uiCap4.getValCal('um')*1e-6];


            try
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
                
                % Invert both into the ponit of view of the stage.  These
                % are computed from the point of view of the cap sensors
                % looking down towards the floor where the HS isn in the
                % point of view of the stage
                dTiltX = -dTiltX;
                dTiltY = -dTiltY;

    %             fprintf('tiltX = %1.1f, %1.1f\n', ...
    %                 dTiltX * pi / 180 * 1e6, ...
    %                 dTiltX2 * pi / 180 * 1e6 ...
    %             );
    %         
    %             fprintf('tiltY = %1.1f, %1.1f\n', ...
    %                 dTiltY * pi / 180 * 1e6, ...
    %                 dTiltY2 * pi / 180 * 1e6 ...
    %             );

            catch mE

            end
            
        end
        
        
    end
    
    methods (Access = private)
                
         
        function initUiCap1(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-pob-cap-sensor.json' ...
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
                'cName', 'pob-cap-sensor-1', ...
                'config', uiConfig, ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getAcc28EADCValue(3,0), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', '1' ...
            );
        end
        
        function initUiCap2(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-pob-cap-sensor.json' ...
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
                'cName', 'pob-cap-sensor-2', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getAcc28EADCValue(3,1), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', '2' ...
            );
        end
        
        function initUiCap3(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-pob-cap-sensor.json' ...
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
                'cName', 'pob-cap-sensor-3', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getAcc28EADCValue(3,2), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', '3' ...
            );
        end
        
        function initUiCap4(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-pob-cap-sensor.json' ...
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
                'cName', 'pob-cap-sensor-4', ...
                'lShowLabels', false, ...
                'config', uiConfig, ...
                'fhGet', @() this.hardware.getDeltaTauPowerPmac().getAcc28EADCValue(3,3), ...
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
        
        
        
        % @param {double 1x3} dN - normal vector
        function [dTiltX, dTiltY] = getTiltXAndTiltYFromNormalVector(this, dN)
            
            % Normal vector.  Assumes rotation about the x axis by dThetaX, then in
            % this new coordinate system, rotate about the y axis by dTiltY
            % This is must have stole this from wikipedia?
            % See ~/Documents/Matlab/Code/met5-height-sensor/get_tip_tilt_and_eqn_of_plane_from_three_points

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
            
            [dTiltX, dTiltY] = this.getTiltXAndTiltYWithoutSensor4();
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

