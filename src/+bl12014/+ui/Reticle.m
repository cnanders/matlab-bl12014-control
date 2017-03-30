classdef Reticle < mic.Base
        
    properties (Constant)
      
        dWidth      = 620
        dHeight     = 780
        
    end
    
	properties
        
        uiCoarseStage
        uiFineStage
        uiAxes
        mod3cap
    end
    
    properties (SetAccess = private)
    
        cName = 'Reticle'
    end
    
    properties (Access = private)
                      
        clock
        hFigure
        dDelay = 0.5
        
    end
    
        
    events
                
    end
    

    
    methods
        
        
        function this = Reticle(varargin)
            
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
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'Reticle Control', ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onCloseRequest ...
                );
            
            % There is a bug in the default 'painters' renderer when
            % drawing stacked patches.  This is required to make ordering
            % work as expected
            
            set(this.hFigure, 'renderer', 'OpenGL');
            
            drawnow;

            dTop = 10;
            dPad = 10;
            
            % this.mod3cap.build(this.hFigure, dPad, dTop);
            
            this.uiCoarseStage.build(this.hFigure, dPad, dTop);
            dTop = dTop + this.uiCoarseStage.dHeight + dPad;
            
            this.uiFineStage.build(this.hFigure, dPad, dTop);
            dTop = dTop + this.uiFineStage.dHeight + dPad;
            
            this.uiAxes.build(this.hFigure, dPad, dTop);
            dTop = dTop + this.uiAxes.dHeight + dPad;
                        
            
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
            
            % Clean up clock tasks
            
            if (isvalid(this.clock))
                this.clock.remove(this.id());
            end
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end
        
       
        
        
            

    end
    
    methods (Access = private)
        
        
        
        function onClock(this)
            
            % Make sure the hggroup of the carriage is at the correct
            % location.  
            
            dX = this.uiCoarseStage.uiX.getValCalDisplay();
            dY = this.uiCoarseStage.uiY.getValCalDisplay();
            this.uiAxes.setStagePosition(dX, dY);
                        
        end
        
        
        function init(this)
            
           
            this.uiCoarseStage = bl12014.ui.ReticleCoarseStage(...
                'clock', this.clock ...
            );
                       
            this.uiFineStage = bl12014.ui.ReticleFineStage(...
                'clock', this.clock ...
            );
        
            this.uiAxes = bl12014.ui.ReticleAxes(...
                'dWidth', 600, ...
                'dHeight', 450 ...
            );
        
            addlistener(this.uiAxes, 'eClickField', @this.onUiAxesClickField);
            this.clock.add(@this.onClock, this.id(), this.dDelay);

        end
        
        
        function onCloseRequest(this, src, evt)
            this.msg('ReticleControl.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
            % this.saveState();
        end
        
       
        
        function onUiAxesClickField(this, src, evt)
                       
            this.uiCoarseStage.uiX.setDestCalDisplay(-evt.stData.dX);
            this.uiCoarseStage.uiY.setDestCalDisplay(-evt.stData.dY);
            this.uiCoarseStage.uiX.moveToDest();
            this.uiCoarseStage.uiY.moveToDest();            
            
        end
        

    end % private
    
    
end