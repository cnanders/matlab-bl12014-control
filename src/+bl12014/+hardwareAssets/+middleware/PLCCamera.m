% This is a bridge between hardware device and MATLAB UI

    
classdef PLCCamera < mic.Base
    
    
    properties (Constant)
        cName = 'PLC-Camera'
        
        cCameraID_test = 'UI225xSE-M R3_4102612161'
    end
    
    properties 
        hLabel
        api
    end
    
    properties (Access = private)
        
        
    end
    
    methods
        
        function this = PLCCamera(varargin)
           
             for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
             end
             
             this.init();
        end
        
        function init(this)
            this.hAdapterHandle = imaqhwinfo('winvideo');
        end
     
        
    end
    
    
    
     
    
end

