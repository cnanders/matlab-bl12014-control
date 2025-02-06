classdef M1 < mic.Base
    
    properties
        
   
        
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 960
        dHeight = 170

        dWidthName = 100

        
        cName = 'M1'
        
        lShowRange = true
        lShowStores = false
        
      

        
        % {mic.ui.device.GetSetNumber 1x1}
        galilTCP

        uigsMotor1
        uigsMotor2
        uigsCoupledMove

        uibZeroEncoders
        
 
        
    end
    
    properties (Access = private)
        
        clock
        hardware
        

    end
    
    methods
        
        function this = ReticleFiducializedMove(varargin)
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
        
        
        function turnOn(this)
            
            
            
        end
        
        function turnOff(this)
          
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'M1 control',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;            

            dTop = 50;
            dLeft = 10;
            dSep = 24;
            
            this.uigsMotor1.build(this.hPanel, dTop, dLeft);
            dTop = dTop + dSep;
            
            this.uigsMotor2.build(this.hPanel, dTop, dLeft);
            dTop = dTop + dSep;

            this.uigsCoupledMove.build(this.hPanel, dTop, dLeft);

            dTop = dTop + dSep;
            this.uibZeroEncoders.build(this.hPanel, dTop, dLeft, 100, 30);
           
           
           
            

            
        end
        
        function delete(this)
            
            this.msg('delete');
            
         
            
            
        end  
        
        
        function st = save(this)
            st = struct();
        %     st.uiX = this.uiRow.save();
        %     st.uiY = this.uiCol.save();

        %     st.uieOffsetX = this.uieOffsetX.save();
        %     st.uieOffsetY = this.uieOffsetY.save();
        % end
        
        function load(this, st)
            % if isfield(st, 'uiRow')
            %     this.uiRow.load(st.uiRow)
            % end
            
            % if isfield(st, 'uiCol')
            %     this.uiCol.load(st.uiCol)
            % end

            % if isfield(st, 'uieOffsetX')
            %     this.uieOffsetX.load(st.uieOffsetX)
            % else
            %     this.uieOffsetX.set(0)
            % end

            % if isfield(st, 'uieOffsetY')
            %     this.uieOffsetY.load(st.uieOffsetY)
            % else 
            %     this.uieOffsetY.set(0)
            % end
            
         
        end
        
        
        
        
        function init(this)   

            % Initialize galil
            this.galilTCP = this.hardware.getGalilM1();

            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-M1.json' ...
            );

            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );

            this.uigsMotor1 =   mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                'dWidthName', this.dWidthName, ... 
                'lShowInitButton', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowUnit', false, ...
                'lUseFunctionCallbacks', true, ...
                'lShowLabels', false, ...
                'fhIsVirtual', @() false, ...
                'config', uiConfig, ...
                'fhGet', @() this.galilTCP.getAxisAbsolute(1), ...
                'fhSet', @(dVal) this.galilTCP.moveAxisAbsolute(1, dVal), ...
                'cName', [this.cName, 'motor-1'], ...
                'cLabel', 'M1 Motor 1' ...
            );

            this.uigsMotor2 =   mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                'dWidthName', this.dWidthName, ... 
                'lShowInitButton', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowUnit', false, ...
                'lUseFunctionCallbacks', true, ...
                'lShowLabels', false, ...
                'fhIsVirtual', @() false, ...
                'config', uiConfig, ...
                'fhGet', @() this.galilTCP.getAxisAbsolute(2), ...
                'fhSet', @(dVal) this.galilTCP.moveAxisAbsolute(12, dVal), ...
                'cName', [this.cName, 'motor-2'], ...
                'cLabel', 'M1 Motor 2' ...
            );

            this.uigsCoupledMove =   mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                'dWidthName', this.dWidthName, ... 
                'lShowInitButton', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowUnit', false, ...
                'lUseFunctionCallbacks', true, ...
                'lShowLabels', false, ...
                'fhIsVirtual', @() false, ...
                'config', uiConfig, ...
                'fhGet', @() this.getCoupledPos(), ...
                'fhSet', @(dVal) this.makeCoupledMove(dVal), ...
                'cName', [this.cName, 'motor-coupled'], ...
                'cLabel', 'M1 Tilt' ...
            );

            this.uibZeroEncoders = mic.ui.common.Button('cText', 'Zero encoders' , 'fhDirectCallback', @(src,evt) this.zeroEncoders());
            this.uibStop = mic.ui.common.Button('cText', 'Stop' , 'fhDirectCallback', @(src,evt) this.galilTCP.stop());

            
           

            
            
        end

        function makeCoupledMove(this, dVal)
            dPos = this.galilTCP.getAbs(1:2);

            dTarget = dPos + [1;-1]*dVal;

            this.galilTCP.moveAbs(1, dTarget(1));
            this.galilTCP.moveAbs(2, dTarget(2));
        end

        function dPos = getCoupledPos(this)
            dPos = this.galilTCP.getAbs(1:2);
            dPos = (dPos(1) - dPos(2))/2;
        end

        function zeroEncoders(this)

            a = questdlg('Are you sure you want to zero the encoders? This cannot be undone', 'Zero Encoders', 'Yes', 'No', 'No');
            if strcmp(a, 'Yes')
                this.galilTCP.zeroEncoders();
            end
        end
        
        
        
        
    end
    
    
end

