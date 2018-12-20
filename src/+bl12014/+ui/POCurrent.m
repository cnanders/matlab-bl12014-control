classdef POCurrent < mic.Base
    
    properties
                
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommKeithley6482
        
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
        
        % {double 1xm} storage of current
        dValues = []
        
        % {datetime 1xm} storage of measurement times
        dtTimes = NaT(0, 0)
        
        uiButtonClear
        
        dPeriod = 500/1000;
                       
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
            
            this.init();
        
        end
                
        
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
            
            this.uiCommKeithley6482.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep + 15;
                        
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
                this.dValues(end + 1) = this.uiCurrent.getValCal('A');
                this.dtTimes(end + 1) = datetime;


                this.updateAxes(this.dtTimes, this.dValues);
            catch
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
            
            if length(dX) ~= length(dY)
                return
            end
                
            plot(...
                this.hAxes, ...
                dX, dY, '.-b'...
            );
            xlabel(this.hAxes, 'Time');
            ylabel(this.hAxes', 'Current');
                         
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
                'lShowInitButton', true, ...
                'lShowLabels', false ...
            );
        end
        
        function initUiCommKeithley6482(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommKeithley6482 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', 'keithley-6482-wafer-po-current', ...
                'cLabel', 'Keithley 6482 (Wafer)' ...
            );
        
        end
        
        
        
        function init(this)
            
            this.msg('init');
            this.initUiCurrent();
            this.initUiCommKeithley6482();
            this.initUiButtonClear();
            
            
        end
        
        function initUiButtonClear(this)
            this.uiButtonClear = mic.ui.common.Button(...
                'cText', 'Reset', ...
                'fhDirectCallback', @this.onButtonClear ...
            );
        
        end
        
        function onButtonClear(this, src, evt)
            this.clearValues()
        end
        
        
        
    end
    
    
end

