classdef POCurrent < mic.Base
    
    properties
                
        
        % {mic.ui.device.GetNumber 1x1}
        uiCurrent
        
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 800
        dHeight = 800
        
        dWidthPadLeftAxes = 60
        dHeightPadBottomAxes = 40
        
        hPanel
        hAxes
        % {handle} storage for the Line object returned by plot
        hPlot1
        hPlot2
        
        hPlot2a
        hPlot2b
        hPlot2c
        
        
        hAxes2
        hPlot21
        hPlot22
        
        hPlot22a
        hPlot22b
        hPlot22c
        
        dNumPlot2 = 600;
        
        % {double 1xm} storage of values from two channels of the 
        % Data translation
        dValues = []
        
        % {datetime 1xm} storage of measurement times
        dtTimes = NaT(0, 0)
        
        uiButtonClear
        
        dPeriod = 500/1000;
        
        % {bl12014.Hardware 1x1}
        hardware
        
        % {double 1xm} really an int that stores that last read index
        % of the circular memory buffer of the data translation
        dIndexOfBuffer
                       
    end
    
    properties (SetAccess = private)
        
        cName = 'po-current-monitor'
    end
    
    methods
        
        function this = POCurrent(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
        
        end
                
        
        
                
        function build(this, hParent, dLeft, dTop)
            
            
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'PO Photo Current',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
        
            dTop = 15;
            dLeft = 10;
            dSep = 10;
            
            this.uiButtonClear.build(...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                100, ...
                24 ...
            );
            
            % this.uiCurrent.build(this.hPanel, dLeft, dTop);

            dLeft = this.dWidthPadLeftAxes;
            dTop = 50;
            dWidth = this.dWidth - this.dWidthPadLeftAxes - 40;
            dHeight = (this.dHeight - 50 - 2 * this.dHeightPadBottomAxes) / 2;
            
            this.hAxes = axes(...
                'Parent', this.hPanel, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([ ...
                    dLeft, ...
                    dTop, ...
                    dWidth, ...
                    dHeight, ...
                    ], ...
                    this.hPanel ...
                ),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
        
            dTop = dTop + dHeight + this.dHeightPadBottomAxes;
            this.hAxes2 = axes(...
                'Parent', this.hPanel, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([ ...
                    dLeft, ...
                    dTop, ...
                    dWidth, ...
                    dHeight, ...
                    ], ...
                    this.hPanel ...
                ),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
            
            
            % Initialize index of buffer
            [dIndexStart, this.dIndexOfBuffer] = this.hardware.getDataTranslation().getIndiciesOfScanBuffer();
            
            if ~isempty(this.clock)
                this.clock.add(@this.onClock, this.id(), this.dPeriod);
            end
            
        end
               
        function delete(this)
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_INIT_DELETE);  
            this.clock.remove(this.id());
            
        end   
        
        function st = save(this)
            st = struct();
            % st.uiCurrent = this.uiCurrent.save();
            
        end
        
        function load(this, st)
            if isfield(st, 'uiCurrent')
                % this.uiCurrent.load(st.uiCurrent);
            end
        end
        
        function d = get(this)
            d = this.dValues;
        end
        
        function clearValues(this)
            this.dValues = [];
            this.dtTimes = NaT(0, 0);
        end
        
        
    end
    
    methods (Access = private)
        
        function onClock(this)
            try
                
                %{
                this.dValues(end + 1) = this.uiCurrent.getValCal('A');
                this.dtTimes(end + 1) = datetime;
                this.updateAxes(this.dtTimes, this.dValues);
                %}
                
                [results, this.dIndexOfBuffer] = this.hardware.getDataTranslation.getScanDataAheadOfIndex(this.dIndexOfBuffer);                
                [dRows, dCols] = size(results);
                
                if dRows == 0
                    return % no new data
                end
                
                
                dLength = length(this.dValues);
                
                % HARDWARE HAS A CHANNEL ZERO - SO DUMB
                % CHANNEL 0 ON THE DEVICE IS INDEX 1 OF THE MATLAB LIST
                this.dtTimes(dLength + 1 : dLength + dRows) = datetime(results(:,49), 'ConvertFrom', 'posixtime');
                this.dValues(1, dLength + 1 : dLength + dRows) = results(:, 36); % CH 35 on hardware matlab index shifted 1
                this.dValues(2, dLength + 1 : dLength + dRows) = results(:, 37); % ch 36 on hardware 37 is the DMI laser ref
                this.dValues(3, dLength + 1 : dLength + dRows) = results(:, 39); % ch 38 on hardware
                this.dValues(4, dLength + 1 : dLength + dRows) = results(:, 40); % ch 39 on hardware
                
                this.updateAxes(this.dtTimes, this.dValues);
               
            catch mE
                mE
            end
            
        end
        
        
        function updateAxes2(this, dX, dY)
            
             if  isempty(this.hAxes2) || ...
                ~ishandle(this.hAxes2)
                return;
             end
             
             if isempty(dX)
                return
            end
            
            if isempty(dY)
                return
            end
            
            if length(dX) ~= length(dY)
                cMsg = sprintf(...
                    'updateAxes2 returing because length(dX) %1.0f, ~= length(dY) %1.0f', ...
                    length(dX), ...
                    length(dY) ...
                );
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
            
            % Axes 2
            % only plot the last N points
            if length(dX) > this.dNumPlot2
                dX = dX(end - this.dNumPlot2 : end);
                dY = dY(:, end - this.dNumPlot2 : end);
            end
            
            % Plot channel 1 on left
            if isempty(this.hPlot21)
                yyaxis(this.hAxes2, 'left')
                this.hPlot21 = plot(...
                    this.hAxes2, ...
                    dX, dY(1, :), '.-b'...
                );
                xlabel(this.hAxes2, 'Time');
                ylabel(this.hAxes2, 'Photocurrent');

            else
                yyaxis(this.hAxes2, 'left')
                set(this.hPlot21, ...
                    'XData', dX, ...
                    'YData', dY(1, :) ...
                );
                
            end
            
            % Plot channel 2 on right
            if isempty(this.hPlot22a) % now using 22a,b,c
                
                yyaxis(this.hAxes2, 'right')
                hold(this.hAxes2, 'on');
                this.hPlot22a = plot(...
                    this.hAxes2, ...
                    dX, dY(2, :), '.-g'...
                );
                this.hPlot22b = plot(...
                    this.hAxes2, ...
                    dX, dY(3, :), 'o-c'...
                );
                this.hPlot22c = plot(...
                    this.hAxes2, ...
                    dX, dY(4, :), 'x-k'...
                );
                xlabel(this.hAxes2, 'Time');
                ylabel(this.hAxes2, 'Shutter');
                
                legend(this.hAxes2, {'PO Current (35)', 'Rigol Out (36)', 'Uniblitz (38)', 'Uniblitz (39)'}); 

            else
                yyaxis(this.hAxes2, 'right')
                hold(this.hAxes2, 'on')
                set(this.hPlot22a, ...
                    'XData', dX, ...
                    'YData', dY(2, :) ...
                );
            
                set(this.hPlot22b, ...
                    'XData', dX, ...
                    'YData', dY(3, :) ...
                );
            
                set(this.hPlot22c, ...
                    'XData', dX, ...
                    'YData', dY(4, :) ...
                );
                
            end
            
        end
                 
         function updateAxes(this, dX, dY)
            
             % dX are times
             % dY is a {double 4 x m}:
             % row 1 is channel 36, 
             % row 2 is channel 37
             % row 3 is channel 38 (uniblitz output)
             % row 4 is channel 39 (uniblitz output)
            if  isempty(this.hAxes) || ...
                ~ishandle(this.hAxes)
                return;
            end
             
           
            
            % Careful here
            % If you don't pass values in and instead use the props, you
            % can run into problems if onClock updates the length of 
            % dValues or dtTimes but not the other at the moment plot() is
            % called.
            
            % Passing values in ensures that they are always the same
            % length
            
            if isempty(dX)
                return
            end
            
            if isempty(dY)
                return
            end
            
            if length(dX) ~= length(dY)
                cMsg = sprintf(...
                    'updateAxes returing because length(dX) %1.0f, ~= length(dY) %1.0f', ...
                    length(dX), ...
                    length(dY) ...
                );
                this.msg(cMsg, this.u8_MSG_TYPE_ERROR);
                return
            end
                
            % Plot channel 1 on left
            if isempty(this.hPlot1)
                yyaxis(this.hAxes, 'left')
                this.hPlot1 = plot(...
                    this.hAxes, ...
                    dX, dY(1, :), '.-b'...
                );
                xlabel(this.hAxes, 'Time');
                ylabel(this.hAxes, 'Photocurrent');

            else
                yyaxis(this.hAxes, 'left')
                set(this.hPlot1, ...
                    'XData', dX, ...
                    'YData', dY(1, :) ...
                );
                
            end
            
            % Plot channel 2, 3, 4 on right
            if isempty(this.hPlot2a)
                
                yyaxis(this.hAxes, 'right')
                hold(this.hAxes, 'on');
                this.hPlot2a = plot(...
                    this.hAxes, ...
                    dX, dY(2, :), '.-g'...
                );
                this.hPlot2b = plot(...
                    this.hAxes, ...
                    dX, dY(3, :), 'o-c'...
                );
                this.hPlot2c = plot(...
                    this.hAxes, ...
                    dX, dY(4, :), 'x-k'...
                );
                % hPlot2 will be a 3 x 1 Line array
            
                xlabel(this.hAxes, 'Time');
                ylabel(this.hAxes, 'Shutter');
                legend(this.hAxes, {'PO Current (35)', 'Rigol Out (36)', 'Uniblitz (38)', 'Uniblitz (39)'});

            else
                yyaxis(this.hAxes, 'right')
                hold(this.hAxes, 'on')
                set(this.hPlot2a, ...
                    'XData', dX, ...
                    'YData', dY(2, :) ...
                );
            
                 set(this.hPlot2b, ...
                    'XData', dX, ...
                    'YData', dY(3, :) ...
                );
            
                set(this.hPlot2c, ...
                    'XData', dX, ...
                    'YData', dY(4, :) ...
                );
                
            end
            
            this.updateAxes2(dX, dY);
            
                         
         end
        
        function initUiCurrent(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-po-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            this.uiCurrent = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'cName', sprintf('%s-current', this.cName), ...
                'config', uiConfig, ...
                'cLabel', 'Current', ...
                'dWidthPadUnit', 25, ...
                'fhGet', @() this.hardware.getKeithley6482Wafer().read(1), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'lShowLabels', false ...
            );
        end
        
        
        
        
        
        function init(this)
            
            this.msg('init');
            % this.initUiCurrent();
            this.initUiButtonClear();
            
            
        end
        
        function initUiButtonClear(this)
            this.uiButtonClear = mic.ui.common.Button(...
                'cText', 'Reset', ...
                'fhDirectCallback', @this.onButtonClear ...
            );
        
        end
        
        function onButtonClear(this, src, evt)
            % Initialize index of buffer
            [dIndexStart, this.dIndexOfBuffer] = this.hardware.getDataTranslation().getIndiciesOfScanBuffer();
            
            this.clearValues()
        end
        
        
        
    end
    
    
end

