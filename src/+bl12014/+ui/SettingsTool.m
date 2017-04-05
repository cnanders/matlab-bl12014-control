classdef SettingsTool < mic.Base
        
	properties
                
        
    end
    
    properties (SetAccess = private)
        
            
    end
    
    properties (Access = private)
           
        hPanel
        hPanelPause
        
        uiePausePreExposure
        uiePausePreHeightSensor
        uiePauseHeightSensorMove
        
        dWidth = 275;
        dHeight = 120;
        dWidthPad = 10;
        dHeightPad = 10;
        
        dHeightPause = 80;
                        
    end
    
        
    events
                
    end
    

    
    methods
        
        
        function this = SettingsTool()
            
            this.init();
            
        end
        
        function d = getPausePreExposure(this)
            d = this.uiePausePreExposure.get();
        end
        
        function d = getPausePreHeightSensor(this)
            d = this.uiePausePreHeightSensor.get();
        end
        
        function d = getPauseHeightSensorMove(this)
            d = this.uiePauseHeightSensorMove.get();
        end
        
        function build(this, hParent, dLeft, dTop)
                        
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Settings',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
        
            this.buildPausePanel();

        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
                        
        end
                    

    end
    
    methods (Access = private)
        

        function buildPausePanel(this)
           
            dWidthEdit = 50;
            
            this.hPanelPause = uipanel(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Title', 'Pause (s)',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb(...
                    [...
                        this.dWidthPad ...
                        20 ...
                        this.dWidth - 2 * this.dWidthPad ...
                        this.dHeightPause ...
                    ], ...
                    this.hPanel ...
                 ) ...
            );
        
            dTop = 20;
            dLeft = this.dWidthPad;
                
            this.uiePausePreExposure.build( ...
                this.hPanelPause, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
            dLeft = dLeft + this.dWidthPad + dWidthEdit;
            
            this.uiePausePreHeightSensor.build( ...
                this.hPanelPause, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
            dLeft = dLeft + this.dWidthPad + dWidthEdit;

            this.uiePauseHeightSensorMove.build( ...
                this.hPanelPause, ...
                dLeft, ...
                dTop, ...
                dWidthEdit, ...
                mic.Utils.dEDITHEIGHT ...
            );
            
            
        end
        function init(this)
                        
            this.msg('init()');
            
            this.uiePausePreExposure = mic.ui.common.Edit(...
                'cLabel', 'Pre-exp', ...
                'cType', 'd' ...
            );
            this.uiePausePreHeightSensor = mic.ui.common.Edit(...
                'cLabel', 'Pre-HS', ...
                'cType', 'd' ...
            );
            this.uiePauseHeightSensorMove = mic.ui.common.Edit(...
                'cLabel', 'HS Move', ...
                'cType', 'd' ...
            );
            
            
                        
            % Defaults
            
            this.uiePausePreExposure.set(2.5);
            this.uiePausePreHeightSensor.set(1);
            this.uiePauseHeightSensorMove.set(3.5);
            
                        
        end
        
       

    end % private
    
    
end