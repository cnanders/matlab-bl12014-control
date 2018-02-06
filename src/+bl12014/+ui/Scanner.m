classdef Scanner < mic.Base
    
    properties
        
        
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommNPointLC400
        
        % {npoint.ui.LC400 1x1}
        uiNPointLC400
        
        % {https://github.com/cnanders/matlab-pupil-fill-generator}
        uiPupilFillGenerator
        
    end
    
    properties (Access = protected)
        
        % {mic.Clock 1x1} must be provided
        clock
        dWidth = 1250
        dHeight = 790
        hFigure
        
        dWidthName = 70
        dWidthPadName = 29
        
    end
    
    properties (SetAccess = protected)
        
        cName = 'Test Scanner'
    end
    
    methods
        
        function this = Scanner(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        function connectNPointLC400(this, comm)
            this.uiNPointLC400.setDevice(comm);
            this.uiNPointLC400.turnOn();
        end
        
        function disconnectNPointLC400(this)
            this.uiNPointLC400.turnOff();
            this.uiNPointLC400.setDevice([]);
            
        end
        
        
        
        function build(this)
            
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', this.cName, ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onFigureCloseRequest ...
            );
                        
            drawnow;

            dTop = 10;
            dLeft = 10;
            dSep = 10;
            
           
            this.uiCommNPointLC400.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 24 + dSep;
            
            this.uiPupilFillGenerator.build(this.hFigure, dLeft, dTop);
            dTop = dTop + this.uiPupilFillGenerator.dHeight + 10;
            % dLeft = dLeft + this.uiPupilFillGenerator.dWidth + dSep;
                         
            this.uiNPointLC400.build(this.hFigure, dLeft, dTop);
            % dTop = dTop + 300;
            
        end
        
        function delete(this)
            
            this.msg('delete', this.u8_MSG_TYPE_CLASS_INIT_DELETE);
                        
            % Delete the figure
            delete(this.uiNPointLC400)
            delete(this.uiPupilFillGenerator);
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
        end  
        
        
        function st = save(this)
            st = struct();
            st.uiPupilFillGenerator = this.uiPupilFillGenerator.save();
            
        end
        
        function load(this, st)
            if isfield(st, 'uiPupilFillGenerator') 
                this.uiPupilFillGenerator.load(st.uiPupilFillGenerator);
            end
        end
        
    end
    
    methods (Access = protected)
        
        function onFigureCloseRequest(this, src, evt)
            this.msg(sprintf('%s.closeRequestFcn()', this.cName));
            delete(this.hFigure);
            this.hFigure = [];
        end
        
         
        function initUiPupilFillGenerator(this)
            this.uiPupilFillGenerator = PupilFillGenerator();
        end
        
        function [i32X, i32Y] = get20BitWaveforms(this)
            
            % returns structure with fields containing 
            % normalized amplitude in [-1 1] as double
            st = this.uiPupilFillGenerator.get(); 
            
            dAmpX = st.x;
            dAmpY = st.y;
            
            % {int32 1xm} in [-2^19 2^19] (20-bit)
            i32X = int32( 2^19 * dAmpX);
            i32Y = int32( 2^19 * dAmpY);
            
        end
        
        function initUiNPointLC400(this)
            
            this.uiNPointLC400 =  npoint.ui.LC400(...
                'clock', this.clock, ...
                'fhGet20BitWaveforms', @this.get20BitWaveforms, ...
                'cName', sprintf('%s-LC-400-UI', this.cName) ...
            );
            
        end
        
        
        function initUiCommNPointLC400(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommNPointLC400 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-nPoint-LC400', this.cName), ...
                'cLabel', 'nPoint LC400' ...
            );
        
        end
        
        function init(this)
            this.msg('init');
            this.initUiCommNPointLC400();
            this.initUiPupilFillGenerator();
            this.initUiNPointLC400();
        end
        
        
        
    end
    
    
end

