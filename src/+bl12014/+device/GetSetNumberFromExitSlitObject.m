classdef GetSetNumberFromExitSlitObject < mic.interface.device.GetSetNumber
    
    % Wraps functions from vendor/pnaulleau/bl12-exit-slit as
    % a mic.interface.device.GetSetNumber
    
    properties (Access = private)
        
        % { see vendor/pnaulleau/bl12-exit-slit}
        comm
        
        % upper inboard = 4
        % lower inboard = 5
        % upper outboard = 6
        % lower outboard = 7
        
        cPROP_GAP = 'gap'
        cPROP_MOTOR_UPPER_IN = 'motor-1'
        cPROP_MOTOR_LOWER_IN = 'motor-2'
        cPROP_MOTOR_UPPER_OUT = 'motor-3'
        cPROP_MOTOR_LOWER_OUT = 'motor-4'
        
    end
    
    methods
        
        function this = GetSetNumberFromExitSlitObject(comm, cProp)
            this.comm = comm;
            this.cProp = cProp
        end
        
        function d = get(this)
            
            switch this.cProp
                case this.cPROP_GAP
                    [slit,e,estr] = this.comm.getSlitGap();
                    d = slit.gap;
                case this.cPROP_MOTOR_UPPER_IN
                    [pos, e, estr] = this.comm.getPos(4);
                    d = pos;
                case this.cPROP_MOTOR_LOWER_IN
                    [pos, e, estr] = this.comm.getPos(5);
                    d = pos;
                case this.cPROP_MOTOR_UPPER_OUT
                    [pos, e, estr] = this.comm.getPos(6);
                    d = pos;
                case this.cPROP_MOTOR_LOWER_OUT
                    [pos, e, estr] = this.comm.getPos(7);
                    d = pos;
            end
        end
        
        function set(this, dVal)
            % fprintf('bl12014.device.GetSetNumberFromExitSlitObject.set(%1.3f)\n', dVal);
            
            switch this.cProp
                case this.cPROP_GAP
            
                    [e,estr] = this.comm.setSlitGap(dVal);
                case this.cPROP_MOTOR_UPPER_IN
                    [ret, e, estr]= this.comm.moveto(4, dVal);
                case this.cPROP_MOTOR_LOWER_IN
                    [ret, e, estr]= this.comm.moveto(5, dVal);
                case this.cPROP_MOTOR_UPPER_OUT
                    [ret, e, estr]= this.comm.moveto(6, dVal);
                case this.cPROP_MOTOR_LOWER_OUT
                    [ret, e, estr]= this.comm.moveto(7, dVal);
                    
            end
        end
        
        function l = isReady(this)
            this.comm.CLstatus;
            %{
            [pos4,e,estr]=this.comm.getPosRaw(4);
            [pos5,e,estr]=this.comm.getPosRaw(5);
            [pos6,e,estr]=this.comm.getPosRaw(6);
            [pos7,e,estr]=this.comm.getPosRaw(7);
            fprintf('raw pos (4, 5, 6, 7) = (%1.0f, %1.0f, %1.0f, %1.0f)\n', ...
                pos4, ...
                pos5, ...
                pos6, ...
                pos7 ...
            );
            %}
            l = this.comm.CLstatus == 0;
        end
        
        function stop(this)
           % [e,estr]= this.comm.stopAll();
            
           [e,estr]= this.comm.abortAll();
        end
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
        
    
end

