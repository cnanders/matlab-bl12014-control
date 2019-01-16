classdef GetSetTextFromDeltaTauPowerPmac < mic.interface.device.GetSetText
    
    % Translates deltatau.PowerPmac to mic.interface.device.GetSetText
    
    properties (Constant)
        
        cTYPE_WORKING_MODE = 'working-mode'
        
        
    end
    
    
    properties (Access = private)
        
        % {< deltatau.PowerPmac (MET5) 1x1}
        comm
        
        % {char 1xm} the axis to control (see cAXIS_* constants)
        cType
    end
    
    methods
        
        function this = GetSetTextFromDeltaTauPowerPmac(comm, cType)
            this.comm = comm;
            this.cType = cType;
        end
        
        function c = get(this)
            
            switch this.cType
                case this.cTYPE_WORKING_MODE
                    d = this.comm.getActiveWorkingMode();
                    c = num2str(d);
                    % c = this.getWorkingModeString(d);
            end
                    
        end
        
        function set(this, cVal)
            switch this.cType
                case this.cTYPE_WORKING_MODE
                    % cVal is "0", "1", .... "8"
                    switch cVal
                        case "0"
                            this.comm.setWorkingModeUndefined();
                        case "1"
                            this.comm.setWorkingModeActivate();
                        case "2"
                            this.comm.setWorkingModeShutdown();
                        case "3"
                            this.comm.setWorkingModeRunSetup();
                        case "4"
                            this.comm.setWorkingModeRunExposure();
                        case "5"
                            this.comm.setWorkingModeRun();
                        case "6"
                            this.comm.setWorkingModeLsiRun();
                        case "7"
                            this.comm.setWorkingModeWaferTransfer();
                        case "8"
                            this.comm.setWorkingModeReticleTransfer();
                    end
                otherwise
                                        
            end % switch
        end
        
        function l = isReady(this)
            switch this.cType
                case this.cTYPE_WORKING_MODE
                    if this.comm.getNewWorkingMode() == this.comm.getActiveWorkingMode()
                        l = true;
                    else
                        l = false;
                    end
                otherwise
                   l = true; 
            end % switch cType
        end
        
        function stop(this)
            
            % unknown - email to PI 2017.08.02
        end
        
        function initialize(this)
            % Don't know what to do here
            % this.comm.initializeAxis(this.u8Axis)
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
    
    methods (Static)
        
        
        % Returns the string / text representation of a working mode from
        % its numeric representation of a working mode (0-9)
        % @param {uint8 1x1} u8Val - numeric representation of working mode
        % (0-8)
        function c = getWorkingModeString(u8Val)
            switch u8Val
                case 0
                    c = 'Undefined';
                case 1
                    c = 'Activate';
                case 2
                    c = 'Shutdown';
                case 3
                    c = 'Run Setup';
                case 4
                    c = 'Run Exposure';
                case 5
                    c = 'Run';
                case 6
                    c = 'LSI Run';
                case 7
                    c = 'Wafer Transfer';
                case 8
                    c = 'Reticle Transfer';
                otherwise
                    c = 'Invalid Mode';
            end
        end
        
    end
        
    
end

