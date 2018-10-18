classdef GetSetLogicalFromWagoIO750 < mic.interface.device.GetSetLogical    
    
    properties (Constant)
        
        
    end
    
    
    properties (Access = private)
        
        % {modbus 1x1}
        modbus
        
        % {uint8 1x1}
        u8Channel
        
    end
    
    methods
        
        % @param {modbus 1x1}
        % @param {uint8 1x1}
        function this = GetSetLogicalFromWagoIO750(m, u8Channel)
            this.modbus = m;
            this.u8Channel = u8Channel;
        end
        
        function l = get(this)
            l = read(this.modbus, 'coils', this.u8Channel, 1);
        end
        
        function set(this, lVal)
            % Need to cast logical to double which is what 
            % the write method needs
            write(this.modbus, 'coils', this.u8Channel, double(lVal))
        end
        
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
    end
        
    
end

