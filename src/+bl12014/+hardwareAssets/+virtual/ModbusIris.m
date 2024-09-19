classdef ModbusIris < handle
    
    % Modbus communication with EUV Tech SMS
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
        
        % {modbus 1x1}
        comm
      
        % {char 1xm} IP/URL
        cHost = '192.168.20.50'
        cPort = 5020
        
    
        
        
    end
    
    methods
        
        
        function this = ModbusIris(varargin)
            

            
        end

        function dVal = getCounts(this)
            dVal = floor(1000 * rand(1, 1));
        end
        
        % @param {uint8 1x1} - zero-indexed axis
        function setCounts(this, dVal)
            
        end

        function zeroCounts(this)
           
        end
        
        
    end
    
   
    
    
    
    
        
    
end

