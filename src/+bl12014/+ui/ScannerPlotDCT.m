classdef ScannerPlotDCT < mic.Base
    
    properties (Constant)
        
        dWidth = 100
        dHeight = 100
        
        dColorGreen = [.85, 1, .85];
        dColorRed = [1, .85, .85];
        
    end
    
	properties

        
    end
    
    properties (SetAccess = private)
        cName = 'scanner-plot-dct'
    end
    
    properties (Access = private)

        uiClock
        
        hAxes
        hPlot
        hLineAperture
        dColorPlotFiducials = [0.7 0.7 0]
        
        fhGetWavetables
        fhGetActive
        fhGetWidthOfAperture
        fhGetHeightOfAperture
        
    end
    
        
    events
        ePreChange
    end

    
    methods
        
        
        function this = ScannerPlotDCT(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.fhGetWavetables, 'function_handle')
                error('fhGetWavetables must be function_handle');
            end
            
            if ~isa(this.fhGetActive, 'function_handle')
                error('fhGetActive must be function_handle');
            end
            
            if ~isa(this.fhGetWidthOfAperture, 'function_handle')
                error('fhGetWidthOfAperture must be function_handle');
            end
            
            if ~isa(this.fhGetHeightOfAperture, 'function_handle')
                error('fhGetHeightOfAperture must be function_handle');
            end
            
            % These are all basically indirect ways to access some property
            % of a piece of hardware or some piece of UI state.  There is
            % no global state that is the source of truth so need to pass
            % in some UIs
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
            
        end
        
        
        function st = save(this)
            st = struct();
        end
        
        function load(this, st)
            
        end
        
        function build(this, hParent, dLeft, dTop)
                       
           this.hAxes = axes(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Color', [0 0 0], ...
                'Position',mic.Utils.lt2lb([...
                dLeft, ...
                dTop, ...
                this.dWidth, ...
                this.dHeight], hParent),...
                'XColor', [0 0 0],...
                'YColor', [0 0 0],...
                'DataAspectRatio',[1 1 1],...
                'HandleVisibility','on'...
           );
            
        end
             
                
        function plot(this)
            
            if isempty(this.hAxes)
                return
            end
            
            if ~ishandle(this.hAxes)
                return
            end
            
            % Returns the wavetable data loaded on the hardware.  Amplitude is
            % relative [-1 : 1] to the max mechanical deflection of the hardware
            % @typedef {struct 1x1} WavetableData
            % @property {double 1xm} x - x amplitude [-1 : 1]
            % @property {double 1xm} y - y amplitude [-1 : 1]
            % @property {double 1xm} t - time (sec)
            % @return {WavetableData 1x1}
        
            st = this.fhGetWavetables();
            
            % Calculate mm per wavetable amplitude
            % +/- 3 mrad mechanical creates +/- 6 mrad optical in
            % reflection.  Propagate lets assume 6 meters to DCT aperture
            % so when amplitude of wavetable is 1, we have 36mm of
            % deflection
            % So a swing of 2 in wavetable amplitude (+/- 1) is a width of 72mm
            % Need to draw the aperture in wavetable units.  So divide the
            % width by 72 and that is the amplitude.
            
            if isempty(this.hPlot)
                this.hPlot = plot(...
                    this.hAxes, ...
                    st.x, st.y, 'm', ...
                    'LineWidth', 2 ...
                );
            else
                this.hPlot.XData = st.x;
                this.hPlot.YData = st.y;
            end
            
            
            % Draw a border that represents the width of the field

            dWidth = this.fhGetWidthOfAperture()* 1e3 / 72; % wavetable amplitude unuits
            dHeight = this.fhGetHeightOfAperture() * 1e3 / 72; % wavetable amplitude units

            x = [-dWidth/2 dWidth/2 dWidth/2 -dWidth/2 -dWidth/2];
            y = [dHeight/2 dHeight/2 -dHeight/2 -dHeight/2 dHeight/2];
            
            if isempty(this.hLineAperture)
                
                this.hLineAperture = line( ...
                    x, y, ...
                    'color', this.dColorPlotFiducials, ...
                    'LineWidth', 2, ...
                    'Parent', this.hAxes ...
                );
                
            else
                
                this.hLineAperture.XData = x;
                this.hLineAperture.YData = y;
            end
            
            set(this.hAxes, 'XTick', [], 'YTick', []);
            
            % Set background color based on if the scanner is on or not
            if this.fhGetActive()
                set(this.hAxes, 'Color', this.dColorGreen);
            else
                set(this.hAxes, 'Color', this.dColorRed);
            end
            xlim(this.hAxes, [-1 1])
            ylim(this.hAxes, [-1 1])
            
        end
        
        
        %% Destructor
        
        function delete(this)
            this.uiClock.remove(this.id());
        end
                            

    end
    
    methods (Access = private)
        
        function init(this)
            this.uiClock.add(...
                @() this.plot(), ...
                this.id(), ...
                1 ...
            );
        
        end

    end 
    
    
end