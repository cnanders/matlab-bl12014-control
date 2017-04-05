classdef PauseTool < mic.Base
        
	properties
                
        
    end
    
    properties (SetAccess = private)
        
            
    end
    
    properties (Access = private)
           
        hPanel
        
        uiePreExposure
        uiePreHeightSensor
        uieHeightSensorMove
        
        dWidth = 275;
        dHeight = 80;
        dWidthPad = 10;
        dHeightPad = 10;
                        
    end
    
        
    events
                
    end
    

    
    methods
        
        
        function this = PauseTool()
            
            this.init();
            
        end
        
        function d = getPreExposure(this)
            d = this.uiePreExposure.get();
        end
        
        function d = getPreHeightSensor(this)
            d = this.uiePreHeightSensor.get();
        end
        
        function d = getHeightSensorMove(this)
            d = this.uieHeightSensorMove.get();
        end
        
        function build(this, hParent, dLeft, dTop)
                        
            dWidthEdit = 50;
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Pause (s)',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
        
            dTop = 20;
            dLeft = this.dWidthPad;
                
            this.uiePreExposure.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
            dLeft = dLeft + this.dWidthPad + dWidthEdit;
            
            this.uiePreHeightSensor.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
            dLeft = dLeft + this.dWidthPad + dWidthEdit;

            this.uieHeightSensorMove.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );

        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
                        
        end
                    

    end
    
    methods (Access = private)
        

        function init(this)
                        
            this.msg('init()');
            
            this.uiePreExposure = mic.ui.common.Edit(...
                'cLabel', 'Pre-exp', ...
                'cType', 'd' ...
            );
            this.uiePreHeightSensor = mic.ui.common.Edit(...
                'cLabel', 'Pre-HS', ...
                'cType', 'd' ...
            );
            this.uieHeightSensorMove = mic.ui.common.Edit(...
                'cLabel', 'HS Move', ...
                'cType', 'd' ...
            );
            
            
                        
            % Defaults
            
            this.uiePreExposure.set(2.5);
            this.uiePreHeightSensor.set(1);
            this.uieHeightSensorMove.set(3.5);
            
                        
        end
        
       

    end % private
    
    
end