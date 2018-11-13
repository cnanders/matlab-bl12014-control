classdef GetSetLogicalFromWagoIO750 < mic.interface.device.GetSetLogical    
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
        
        % {modbus 1x1}
        modbus
        
        % {cell 1xm}
        cDevice
        
    end
    
    methods
        
        % @param {modbus 1x1}
        % @param {uint8 1x1}
        function this = GetSetLogicalFromWagoIO750(m, cDevice)
            this.modbus = m;
            this.cDevice = cDevice;
        end
        
        function l = get(this)
            switch this.cDevice
                case 'd141'
                    l = read(this.modbus, 'coils', 3); % when in, coil 3 is true when out coil 1 is true
            end
        end
        
        function set(this, lVal)
            % Need to cast logical to double which is what 
            % the write method needs
            switch this.cDevice
                case 'd141'
                    write(this.modbus, 'coils', 1, double(lVal))
            end
        end
        
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
        
    
end

