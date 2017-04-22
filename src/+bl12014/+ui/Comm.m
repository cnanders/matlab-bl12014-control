classdef Comm < mic.ui.common.ButtonList
        
    properties (Constant)
       
         dColorTrue = [1 0 1];
         dColorFalse = [1 0 0];
    end
    
    
	properties
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
         


    end
    
        
    events
        
        
    end
    

    
    methods
        
        function this = Comm(varargin)
            % Pass varargin through to subclass constructor
            this@mic.ui.common.ButtonList(varargin{:});
                        
        end
        
        function build(this, hParent, dLeft, dTop)
            
            % Call supercalss method
            build@mic.ui.common.ButtonList(this, hParent, dLeft, dTop);
            
            for n = 1 : length(this.uiButtons)
                this.uiButtons(n).setColorBackground(this.dColorFalse);
            end    
            
        end
        
    end
    
    methods (Access = protected)
        
        % Overload
        function onUiButtonClick(this, src, evt, n)
            cMsg = sprintf('onUiButtonClick(%1.0f)', n);
            this.msg(cMsg);
            l = this.stButtonDefinitions(n).fhOnClick();
            if l
                this.setButtonColorBackground(n, this.dColorTrue);
            else
                this.setButtonColorBackground(n, this.dColorFalse);
            end
            
        end
        
        
    end
    
    methods (Access = private)
        
            
        
        
    end % private
    
    
end