classdef Wafer < mic.Base
        
    properties (Constant)
       
        
        dWidth      = 620
        dHeight     = 780
        
    end
    
	properties
        
        uiCoarseStage
        uiFineStage
        uiAxes
        
        hs
       
    end
    
    properties (SetAccess = private)
        
        hFigure
        
    end
    
    properties (Access = private)
                      
        clock
        dDelay = 0.5
        
    end
    
        
    events
        
        eName
        
    end
    

    
    methods
        
        
        function this = Wafer(varargin)
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            this.init();
            
            
        end
        
                
        function build(this)
                        
            % Figure
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name', 'Wafer Control',...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.handleCloseRequestFcn ...
                );
            
            % There is a bug in the default 'painters' renderer when
            % drawing stacked patches.  This is required to make ordering
            % work as expected
            
            % set(this.hFigure, 'renderer', 'OpenGL');
            
            drawnow;

            dTop = 10;
            dPad = 10;
            dLeft = 10;
            % this.hs.build(this.hFigure, dPad, dTop);
            this.uiCoarseStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiCoarseStage.dHeight + dPad;
            
            this.uiFineStage.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiFineStage.dHeight + dPad;
            
            this.uiAxes.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiAxes.dHeight + dPad;
           
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
            
            if (isvalid(this.clock))
                this.clock.remove(this.id());
            end
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
        end
               
        
        function onClock(this)
            
            % Make sure the hggroup of the carriage is at the correct
            % location.  
            
            dX = this.uiCoarseStage.uiX.getValCalDisplay();
            dY = this.uiCoarseStage.uiY.getValCalDisplay();
            this.uiAxes.setStagePosition(dX, dY);
                        
        end
        
    end
    
    methods (Access = private)
        
        function init(this)
            
            this.uiCoarseStage = bl12014.ui.WaferCoarseStage(...
                'clock', this.clock ...
            );
            this.uiFineStage = bl12014.ui.WaferFineStage(...
                'clock', this.clock ...
            );
        
            this.uiAxes = bl12014.ui.WaferAxes( ...
                'dWidth', 600, ...
                'dHeight', 480 ...
            );
            
                        
            % this.hs     = HeightSensor(this.clock);
            this.clock.add(@this.onClock, this.id(), this.dDelay);

        end
        
        
        function handleCloseRequestFcn(this, src, evt)
            
            delete(this.hFigure);
            % this.saveState();
            
        end
        
       
        
        
        
        
        
        
    end % private
    
    
end