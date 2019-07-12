classdef GetSetNumberFromExitSlitObject < mic.interface.device.GetSetNumber
    
    % Wraps functions from vendor/pnaulleau/bl12-exit-slit as
    % a mic.interface.device.GetSetNumber
    
    properties (Constant)
        
        % upper outboard = 6         upper inboard = 4
        % lower outboard = 7         lower inboard = 5
        
        cPROP_STEP = 'step'
        cPROP_GAP = 'gap'
        cPROP_MOTOR_UPPER_IN = 'motor-1'
        cPROP_MOTOR_LOWER_IN = 'motor-2'
        cPROP_MOTOR_UPPER_OUT = 'motor-3'
        cPROP_MOTOR_LOWER_OUT = 'motor-4'
    end
    
    
    properties (Access = private)
        
        % {function_handle 1x1} returns instance vendor/pnaulleau/bl12-exit-slit
        fhGetComm
        
        % {char 1xm} see cPROP_*
        cProp
        
        

        
    end
    
    methods
        
        function this = GetSetNumberFromExitSlitObject(fhGetComm, cProp)
            this.fhGetComm = fhGetComm;
            this.cProp = cProp;

        end
        
        function d = get(this)
            
            comm = this.fhGetComm();
            switch this.cProp
                case this.cPROP_STEP
                    d = comm.getSlitMaxStep();
                case this.cPROP_GAP
                    [slit,e,estr] = comm.getSlitGap();
                    d = slit.gap;
                case this.cPROP_MOTOR_UPPER_IN
                    [pos, e, estr] = comm.getPos(4);
                    d = pos;
                case this.cPROP_MOTOR_LOWER_IN
                    [pos, e, estr] = comm.getPos(5);
                    d = pos;
                case this.cPROP_MOTOR_UPPER_OUT
                    [pos, e, estr] = comm.getPos(6);
                    d = pos;
                case this.cPROP_MOTOR_LOWER_OUT
                    [pos, e, estr] = comm.getPos(7);
                    d = pos;
            end
        end
        
        function set(this, dVal)
            % fprintf('bl12014.device.GetSetNumberFromExitSlitObject.set(%1.3f)\n', dVal);
            
            comm = this.fhGetComm();
            switch this.cProp
                case this.cPROP_STEP
                    [e, estr] = comm.setSlitMaxStep(dVal);
                case this.cPROP_GAP
                    [e,estr] = comm.setSlitGap(dVal);
                case this.cPROP_MOTOR_UPPER_IN
                    [ret, e, estr]= comm.moveto(4, dVal);
                case this.cPROP_MOTOR_LOWER_IN
                    [ret, e, estr]= comm.moveto(5, dVal);
                case this.cPROP_MOTOR_UPPER_OUT
                    [ret, e, estr]= comm.moveto(6, dVal);
                case this.cPROP_MOTOR_LOWER_OUT
                    [ret, e, estr]= comm.moveto(7, dVal);
                    
            end
        end
        
        function l = isReady(this)
            
            comm = this.fhGetComm();
            
            [s,e,estr] = comm.getState();
            
            switch this.cProp
                case this.cPROP_STEP
                   l = true;
                case this.cPROP_GAP
                   l = comm.CLstatus == 0;
                case this.cPROP_MOTOR_UPPER_IN
                   l = ~(s == 4 || s == 104);
                case this.cPROP_MOTOR_LOWER_IN
                   l = ~(s == 5 || s == 105);
                case this.cPROP_MOTOR_UPPER_OUT
                   l = ~(s == 6 || s == 106);
                case this.cPROP_MOTOR_LOWER_OUT
                    l = ~(s == 7 || s == 107);
            end
            %{
            [pos4,e,estr]=comm.getPosRaw(4);
            [pos5,e,estr]=comm.getPosRaw(5);
            [pos6,e,estr]=comm.getPosRaw(6);
            [pos7,e,estr]=comm.getPosRaw(7);
            fprintf('raw pos (4, 5, 6, 7) = (%1.0f, %1.0f, %1.0f, %1.0f)\n', ...
                pos4, ...
                pos5, ...
                pos6, ...
                pos7 ...
            );
            %}
        end
        
        function stop(this)
           % [e,estr]= this.fhGetComm().stopAll();
            
           comm = this.fhGetComm()
           [e,estr]= comm.abortAll();
        end
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
        
    
end

