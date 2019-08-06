classdef POCurrent < mic.Base
    
    properties
                
        
        % {mic.ui.device.GetNumber 1x1}
        uiCurrent
        
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 800
        dHeight = 680
        
        dWidthPadLeftAxes = 60
        
        hPanel
        hAxes
        % {handle} storage for the Line object returned by plot
        hPlot1
        hPlot2
        
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
                
        %{
        function connectKeithley6482(this, comm)
            
            device = bl12014.device.GetNumberFromKeithley6482(comm, 1);
            this.uiCurrent.setDevice(device);
            this.uiCurrent.turnOn()
            this.clearValues();
            
        end
        
        
        function disconnectKeithley6482(this, comm)
            this.uiCurrent.turnOff();
            this.uiCurrent.setDevice([]);
            
        end
        %}
        
                
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
            
            
                        
            this.uiCurrent.build(this.hPanel, dLeft, dTop);
            
            
            
        
            dLeft = this.dWidthPadLeftAxes;
            dTop = 80;
            dWidth = this.dWidth - this.dWidthPadLeftAxes - 40;
            dHeight = this.dHeight - dTop - 50;
            
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
        
            dLeft = this.dWidth - 40 - 100;
            dTop = 50;
            this.uiButtonClear.build(...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                100, ...
                24 ...
            );
            
            % Initialize index of buffer
            [dIndexStart, this.dIndexOfBuffer] = this.hardware.getDataTranslation().getIndiciesOfScanBuffer();
            
            if ~isempty(this.clock)
                this.clock.add(@this.onClock, this.id(), this.dPeriod);
            end
            
        end
               
        function delete(this)
            
            this.msg('delete');
            
        end   
        
        function st = save(this)
            st = struct();
            st.uiCurrent = this.uiCurrent.save();
            
        end
        
        function load(this, st)
            if isfield(st, 'uiCurrent')
                this.uiCurrent.load(st.uiCurrent);
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
                
                this.dtTimes(end + 1 : end + dRows) = datetime(results(:,49), 'ConvertFrom', 'posixtime');
                dLength = length(this.dValues);
                this.dValues(1, dLength + 1 : dLength + dRows) = results(:, 36); % FIX ME column
                this.dValues(2, dLength + 1 : dLength + dRows) = results(:, 37); % FIX ME column
                this.updateAxes(this.dtTimes, this.dValues);
               
            catch mE
                mE
            end
            
        end
        
                 
         function updateAxes(this, dX, dY)
            
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
                ylabel(this.hAxes', 'Photocurrent');

            else
                yyaxis(this.hAxes, 'left')
                set(this.hPlot1, ...
                    'XData', dX, ...
                    'YData', dY(1, :) ...
                );
                
            end
            
            % Plot channel 2 on right
            if isempty(this.hPlot2)
                
                yyaxis(this.hAxes, 'right')
                this.hPlot2 = plot(...
                    this.hAxes, ...
                    dX, dY(2, :), '.-r'...
                );
            
                xlabel(this.hAxes, 'Time');
                ylabel(this.hAxes', 'Shutter');

            else
                yyaxis(this.hAxes, 'right')
                set(this.hPlot2, ...
                    'XData', dX, ...
                    'YData', dY(2, :) ...
                );
                
            end
            
            
                         
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
            this.initUiCurrent();
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

