classdef MfDriftMonitorVibration < mic.Base
    
    properties
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommMfDriftMonitor
                        
    end
    
    properties (SetAccess = private)
        
        dWidth = 1500
        dHeight = 960
        
        dWidthAxes = 1200
        dHeightAxes = 240
        
        dHeightPadTop = 70
        dHeightPadTopAxes = 60;
        dWidthPadLeftAxes = 70
        
        dWidthName = 70
        dWidthUnit = 80
        dWidthVal = 75
        dWidthPadUnit = 25 % 280
        
        cName = 'mf-drift-monitor-vibration'
        
        f_min = 10;
        f_max = 500;
        
        dDelay = 0.2;
        
                   
        hLinesPsd = []
        hLinesCas = []
        hLinesTime = []
        

        
    end
    
    properties (Access = private)
        
        clock
        
        hFigure
        hAxesTime % amplitide vs. time
        hAxesPsd % power spectral density
        hAxesCas % cumulative amplitude spectrum
        
       
        
        % {< cxro.met5.device.mfdriftmonitorI}
        device 

        
        uiCheckboxZ1
        uiCheckboxZ2
        uiCheckboxZ3
        uiCheckboxZ1Z2Z3Avg
        uiCheckboxZ4
        uiCheckboxZ5
        uiCheckboxZ6

        uiCheckboxXReticle
        uiCheckboxYReticle
        uiCheckboxXWafer
        uiCheckboxYWafer
        
        uiEditFreqMin
        uiEditFreqMax
        
        uiEditNumOfSamples
        
        dChannelsHsPrevious = []
        dChannelsDmiPrevious = []
        
        lLabelsOfPlotInitialized = false
        
    end
    
    methods
        
        function this = MfDriftMonitorVibration(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.device = bl12014.hardwareAssets.virtual.MFDriftMonitor();
            this.init();
        
        end
        
        
        function buildAxesTime(this)
            
            dLeft = this.dWidthPadLeftAxes;
            dTop = this.dHeightPadTop;
            
            this.hAxesTime = axes(...
                'Parent', this.hFigure, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hFigure),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
            % hold(this.hAxes, 'on');
            drawnow;

        end
        
        function buildAxesPsd(this)
            
            dLeft = this.dWidthPadLeftAxes;
            dTop = this.dHeightPadTop + ...
                this.dHeightAxes + this.dHeightPadTopAxes;
            
            this.hAxesPsd = axes(...
                'Parent', this.hFigure, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hFigure),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
            % hold(this.hAxes, 'on');
            drawnow;

        end
        
        function buildAxesCas(this)
            
            dLeft = this.dWidthPadLeftAxes;
            
            dTop = this.dHeightPadTop + ...
                this.dHeightAxes + this.dHeightPadTopAxes + ...
                this.dHeightAxes + this.dHeightPadTopAxes;
            
            this.hAxesCas = axes(...
                'Parent', this.hFigure, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], this.hFigure),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
            % hold(this.hAxes, 'on');
            drawnow;

        end
        
        
        % @param { < cxro.met5.device.mfdriftmonitorI 1x1}
        function connectMfDriftMonitor(this, comm)
            
            this.uiCommMfDriftMonitor.set(true);
            this.device = comm;
            
        end
        
        
        function disconnectMfDriftMonitor(this)
            this.uiCommMfDriftMonitor.set(false);
            this.device = bl12014.hardwareAssets.virtual.MFDriftMonitor();
        end
        
        function buildFigure(this)
            
            dScreenSize = get(0, 'ScreenSize');

            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'Mf Drift Monitor Vibration Analysis', ...
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
            
            
			drawnow;  
            
        end
        

        function build(this) % , hParent, dLeft, dTop
                        
            if ishghandle(this.hFigure)
                % Bring to front
                figure(this.hFigure);
                return
            end
                        
            this.buildFigure()          

            dTop = 20;
            dLeft = 10;
            dSep = 30;
            
            this.uiCommMfDriftMonitor.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 5 + dSep;
            
            this.buildAxesTime();
            this.buildAxesPsd();
            this.buildAxesCas();
            
            dTop = 100;
            dLeft = 100 + this.dWidthAxes;
            dSep = 20;
            
            
            
            this.uiCheckboxZ1.build(this.hFigure, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxZ2.build(this.hFigure, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxZ3.build(this.hFigure, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxZ1Z2Z3Avg.build(this.hFigure, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxZ4.build(this.hFigure, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxZ5.build(this.hFigure, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxZ6.build(this.hFigure, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;

            this.uiCheckboxXReticle.build(this.hFigure, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxYReticle.build(this.hFigure, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxXWafer.build(this.hFigure, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxYWafer.build(this.hFigure, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;

            dTop = dTop + 20;
            dSep = 40;
            
            this.uiEditNumOfSamples.build(this.hFigure, dLeft, dTop, 150, 24);
            dTop = dTop + dSep;
            
            this.uiEditFreqMin.build(this.hFigure, dLeft, dTop, 150, 24);
            dTop = dTop + dSep;
            
            this.uiEditFreqMax.build(this.hFigure, dLeft, dTop, 150, 24);
            dTop = dTop + dSep;
            
            if ~isempty(this.clock)
                this.clock.add(@this.onClock, this.id(), this.dDelay);
            end
            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            % Clean up clock tasks
            if ~isempty(this.clock) && ...
                isvalid(this.clock) && ...
                this.clock.has(this.id())
                this.msg('delete() removing clock task', this.u8_MSG_TYPE_INFO); 
                this.clock.remove(this.id());
            end
            
            
        end 
        
        
        function update(this)
            
            samples = this.device.getSampleData(this.uiEditNumOfSamples.get());
            z = this.getHeightSensorZFromSampleData(samples);
            xy = this.getDmiPositionFromSampleData(samples);
            
            this.updateAxes(z, xy)
            
        end
        
        function l = areAxesAvailable(this)
            
            l = true;
            if  isempty(this.hAxesPsd) || ...
                ~ishandle(this.hAxesPsd)
               
                l = false;
                return;
            end
            
            if  isempty(this.hAxesCas) || ...
                ~ishandle(this.hAxesCas)
               
                l = false;
                return;
            end
            
            if  isempty(this.hAxesTime) || ...
                ~ishandle(this.hAxesTime)
               
                l = false;
                return;
            end
            
            
        end
        
        function updateAxes(this, z, xy)
            
            
            if ~this.areAxesAvailable()
                return
            end
            
            %delete(this.hLinesPsd);
            %delete(this.hLinesCas);
            
            cla(this.hAxesTime);
            cla(this.hAxesPsd);
            cla(this.hAxesCas);
            
            t = [0 : length(z) - 1] * 1e-3;

            cecLabels = {}; % Fill with plotted things
            cecLabelsZ = {...
                'z 5:30 (1)',  ...
                'z 9:30 (2)',  ...
                'z 1:30 (3)',  ...
                'ang 0:30 (4)', ...
                'ang 4:30 (5)', ...
                'ang 8:30 (6)', ...
                'z avg (123)' ...
            };
            
            % z (nm) 
            dChannelsHs = this.getHeightSensorChannels();
            
            for n = dChannelsHs
    
                channel = n;
                pos = z(channel, :);
                
                % Time
                plot(this.hAxesTime, t, pos - mean(pos))
                hold(this.hAxesTime, 'on') % need to do after first loglog
                
                % PSD
                [freq_psd, energy_psd] = Psd.calc(t, pos - mean(pos));
                [freq_psd, energy_psd] = Psd.fold(freq_psd, energy_psd);
                loglog(this.hAxesPsd, freq_psd, energy_psd);
                hold(this.hAxesPsd, 'on') % need to do after first loglog


                % In-band CAS
                [f_band, energy_band] = Psd.band(freq_psd, energy_psd, 1/this.uiEditFreqMin.get(), 1/this.uiEditFreqMax.get());
                [f, powerc] = Psd.powerCumulative(f_band, energy_band);
                semilogx(this.hAxesCas, f, sqrt(powerc));
                hold(this.hAxesCas, 'on')
                
                cecLabels{end + 1} = cecLabelsZ{channel};



            end

            cecLabelsXY = {...
                'X reticle', ...
                'Y reticle', ...
                'X wafer', ...
                'Y wafer' ...
            };
            
            dChannelsDmi = this.getDmiChannels();
            
            for n = dChannelsDmi
    
                channel = n;
                pos = xy(channel, :);

                % Time
                plot(this.hAxesTime, t, pos - mean(pos));
                hold(this.hAxesTime, 'on')
                
                % PSD
                [freq_psd, energy_psd] = Psd.calc(t, pos - mean(pos));
                [freq_psd, energy_psd] = Psd.fold(freq_psd, energy_psd);
                loglog(this.hAxesPsd, freq_psd, energy_psd);
                hold(this.hAxesPsd, 'on') % need to do after first loglog
                
                % In-band CAS
                [f_band, energy_band] = Psd.band(freq_psd, energy_psd, 1/this.uiEditFreqMin.get(), 1/this.uiEditFreqMax.get());
                [f, powerc] = Psd.powerCumulative(f_band, energy_band);
                semilogx(this.hAxesCas, f, sqrt(powerc));
                hold(this.hAxesCas, 'on')
                
                cecLabels{end + 1} = cecLabelsXY{channel};

            end

            % Y
            lForceNewLegend = true;
            if (~isequal(dChannelsHs, this.dChannelsHsPrevious) || ...
                ~isequal(dChannelsDmi, this.dChannelsDmiPrevious) || ...
                lForceNewLegend)
                legend(this.hAxesTime, cecLabels);
                legend(this.hAxesPsd, cecLabels);
                legend(this.hAxesCas, cecLabels);
            end
               
            if ~this.lLabelsOfPlotInitialized
                this.updateAxesLabels() 
            end
            
            this.lLabelsOfPlotInitialized = true;
            this.dChannelsHsPrevious = dChannelsHs;
            this.dChannelsDmiPrevious = dChannelsDmi;
            
        end
        
        function updateAxesLabels(this)
            
            if ~this.areAxesAvailable()
                return
            end
            
            title(this.hAxesTime, 'Amplitude vs. Time');
            xlabel(this.hAxesTime, 'Time (s)');
            ylabel(this.hAxesTime, 'Amp. (nm)');
            
            title(this.hAxesPsd, 'PSD')
            xlabel(this.hAxesPsd, 'Freq (Hz)');
            ylabel(this.hAxesPsd, 'PSD (nm^2/Hz)');

            cTitle = sprintf(...
                'Cumulative Amplitude Spectrum [%1.0fHz, %1.0fHz]', ...
                this.uiEditFreqMin.get(), ...
                this.uiEditFreqMax.get() ...
            );
            title(this.hAxesCas, cTitle);
            xlabel(this.hAxesCas, 'Freq (Hz)');
            ylabel(this.hAxesCas, 'Cumulative Amplitude RMS (nm)');
                
        end
        
        
        % Returns a {double 6xm} time series of height zensor z in nm of
        % all six channels
        % @param {ArrayList<SampleData> 1x1} samples - sample data
        % @return {double 6xm} - height sensor z (nm) of six channels at 1 kHz
        % @return(1, :) {double 1xm} - z 5:30 (ch 1)
        % @return(2, :) {double 1xm} - z 9:30 (ch 2)
        % @return(3, :) {double 1xm} - z 1:30 (ch 3)
        % @return(4, :) {double 1xm} - ang 0:30 (ch 4)
        % @return(5, :) {double 1xm} - ang 4:30 (ch 5)
        % @return(6, :) {double 1xm} - ang 8:30 (ch 6)
        function z = getHeightSensorZFromSampleData(this, samples)
            
            
            m_per_diff_over_sum = 120e-6/2;  

            hsraw = zeros(24, samples.size());
            
            % Samples.get() is zero-indexed since implementing java
            % interface
            for n = 0 : samples.size() - 1
                hsraw(:, n + 1) = samples.get(n).getHsData();
            end
            
            
            top = zeros(6, samples.size());
            bot = zeros(6, samples.size());
                
            % Build a map of array index to physical configuration
            
            % time 0 us - 500 us use side "a" capacitor
            stMap.ch6top1 = 1;
            stMap.ch6bot1 = 2;
            stMap.ch5top1 = 3;
            stMap.ch5bot1 = 4;
            stMap.ch4top1 = 5;
            stMap.ch4bot1 = 6;
            stMap.ch3top1 = 7;
            stMap.ch3bot1 = 8;
            stMap.ch2top1 = 9;
            stMap.ch2bot1 = 10;
            stMap.ch1top1 = 11;
            stMap.ch1bot1 = 12;

            % time 500 us - 1000 us use side "b" capacitor
            stMap.ch6top2 = 13;
            stMap.ch6bot2 = 14;
            stMap.ch5top2 = 15;
            stMap.ch5bot2 = 16;
            stMap.ch4top2 = 17;
            stMap.ch4bot2 = 18;
            stMap.ch3top2 = 19;
            stMap.ch3bot2 = 20;
            stMap.ch2top2 = 21;
            stMap.ch2bot2 = 22;
            stMap.ch1top2 = 23;
            stMap.ch1bot2 = 24;
            
            % Average ADC values from each cap to get 1 ms of data
            
            top(1, :) = (hsraw(stMap.ch1top1, :) + hsraw(stMap.ch1top2, :)) / 2;
            top(2, :) = (hsraw(stMap.ch2top1, :) + hsraw(stMap.ch2top2, :)) / 2;
            top(3, :) = (hsraw(stMap.ch3top1, :) + hsraw(stMap.ch3top2, :)) / 2;
            top(4, :) = (hsraw(stMap.ch4top1, :) + hsraw(stMap.ch4top2, :)) / 2;
            top(5, :) = (hsraw(stMap.ch5top1, :) + hsraw(stMap.ch5top2, :)) / 2;
            top(6, :) = (hsraw(stMap.ch6top1, :) + hsraw(stMap.ch6top2, :)) / 2; 

            bot(1, :) = (hsraw(stMap.ch1bot1, :) + hsraw(stMap.ch1bot2, :)) / 2;
            bot(2, :) = (hsraw(stMap.ch2bot1, :) + hsraw(stMap.ch2bot2, :)) / 2;
            bot(3, :) = (hsraw(stMap.ch3bot1, :) + hsraw(stMap.ch3bot2, :)) / 2;
            bot(4, :) = (hsraw(stMap.ch4bot1, :) + hsraw(stMap.ch4bot2, :)) / 2;
            bot(5, :) = (hsraw(stMap.ch5bot1, :) + hsraw(stMap.ch5bot2, :)) / 2;
            bot(6, :) = (hsraw(stMap.ch6bot1, :) + hsraw(stMap.ch6bot2, :)) / 2;   
            
            diff = top - bot;
            sum = top + bot;
            dos = double(diff)./double(sum);
            z = dos * m_per_diff_over_sum * 1e9;
            
            % Ch "7" is average of three central
            z(7, :) = (z(1, :) + z(2, :) + z(3, :))/3;
        end
        
        % Returns {double 4xm} x and y position of reticle and wafer in nm
        % @param {ArrayList<SampleData> 1x1} samples - sample data
        % @return {double 4xm} - position data of reticle and wafer nm
        % @return(1, :) {double 1xm} - xReticle
        % @return(2, :) {double 1xm} - yReticle
        % @return(3, :) {double 1xm} - xWafer
        % @return(4, :) {double 1xm} - yWafer

        function pos = getDmiPositionFromSampleData(this, samples)
            
            % Reshape to a 4xn matrix of doubles.  
            
            % Mirrors are mounted 45 degrees relative to x and y
            % row1 = uReticle
            % row2 = vReticle
            % row3 = uWafer
            % row4 = vWafer
            
            % samples is zero-indexed because uses Java interface
            dmi = zeros(4, samples.size());
            for n = 0 : samples.size() - 1
                dmi(:, n + 1) = double(samples.get(n).getDmiData());
            end
                  
            
            % dmi axes come in units of 1.5 angstroms
            % convert to nm
                                  
            dDMI_SCALE = 632.9907/4096; 
                                 
            dErrU_ret = dmi(1, :);
            dErrV_ret = dmi(2, :);
            dErrU_waf = dmi(3, :);
            dErrV_waf = dmi(4, :);
            
            pos = zeros(4, samples.size());

            pos(1, :) = dDMI_SCALE * 1/sqrt(2) * (dErrU_ret + dErrV_ret);
            pos(2, :) = -dDMI_SCALE * 1/sqrt(2) * (dErrU_ret - dErrV_ret);
            pos(3, :) = -dDMI_SCALE * 1/sqrt(2) * (dErrU_waf + dErrV_waf);
            pos(4, :) = dDMI_SCALE * 1/sqrt(2) * (dErrU_waf - dErrV_waf);

            
        end
        
        
        function st = save(this)
            st = struct();
            
            st.uiCheckboxZ1 = this.uiCheckboxZ1.save();
            st.uiCheckboxZ2 = this.uiCheckboxZ2.save();
            st.uiCheckboxZ3 = this.uiCheckboxZ3.save();
            st.uiCheckboxZ1Z2Z3Avg = this.uiCheckboxZ1Z2Z3Avg.save();
            st.uiCheckboxZ4 = this.uiCheckboxZ4.save();
            st.uiCheckboxZ5 = this.uiCheckboxZ5.save();
            st.uiCheckboxZ6 = this.uiCheckboxZ6.save();

            st.uiCheckboxXReticle = this.uiCheckboxXReticle.save();
            st.uiCheckboxYReticle = this.uiCheckboxYReticle.save();
            st.uiCheckboxXWafer = this.uiCheckboxXWafer.save();
            st.uiCheckboxYWafer = this.uiCheckboxYWafer.save();

            st.uiEditFreqMin = this.uiEditFreqMin.save();
            st.uiEditFreqMax = this.uiEditFreqMax.save();
            st.uiEditNumOfSamples = this.uiEditNumOfSamples.save();
            
        end
        
        function load(this, st)
            
            
            if isfield(st, 'uiCheckboxZ1')
                this.uiCheckboxZ1.load(st.uiCheckboxZ1)
            end
            
            if isfield(st, 'uiCheckboxZ2')
                this.uiCheckboxZ2.load(st.uiCheckboxZ2)
            end
            
            if isfield(st, 'uiCheckboxZ3')
                this.uiCheckboxZ3.load(st.uiCheckboxZ3)
            end
            
            if isfield(st, 'uiCheckboxZ4')
                this.uiCheckboxZ4.load(st.uiCheckboxZ4)
            end
            
            if isfield(st, 'uiCheckboxZ5')
                this.uiCheckboxZ5.load(st.uiCheckboxZ5)
            end
            
            if isfield(st, 'uiCheckboxZ6')
                this.uiCheckboxZ6.load(st.uiCheckboxZ6)
            end
            
            if isfield(st, 'uiCheckboxZ1Z2Z3Avg')
                this.uiCheckboxZ1Z2Z3Avg.load(st.uiCheckboxZ1Z2Z3Avg)
            end
            
            if isfield(st, 'uiEditFreqMin')
                this.uiEditFreqMin.load(st.uiEditFreqMin)
            end
            
            if isfield(st, 'uiEditFreqMax')
                this.uiEditFreqMax.load(st.uiEditFreqMax)
            end
            
            if isfield(st, 'uiEditNumOfSamples')
                this.uiEditNumOfSamples.load(st.uiEditNumOfSamples)
            end
        end

        
        
    end
    
    methods (Access = private)
                
         
        function onCloseRequest(this, src, evt)
            this.msg('HeightSensorLEDs.closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
                
        function initUiCommMfDriftMonitor(this)
            
            
            % Configure the mic.ui.common.Toggle instance
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiCommMfDriftMonitor = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', 130, ...
                'lShowLabels', false, ...
                'lShowDevice', false, ...
                'lShowInitButton', false, ...
                'cName', sprintf('%s-mf-drift-monitor-comm', this.cName), ...
                'cLabel', 'Mf Drift Monitor' ...
            );
        
        end
        
        function onClock(this, src, evt)
            
            this.update();
            
        end
        
        function init(this)
            this.msg('init()');
            this.initUiCommMfDriftMonitor();
            
            
                    
            this.uiCheckboxZ1 = mic.ui.common.Checkbox('cLabel', 'z 5:30 (1)', 'lChecked', false);
            this.uiCheckboxZ2 = mic.ui.common.Checkbox('cLabel', 'z 9:30 (2)', 'lChecked', false);
            this.uiCheckboxZ3 = mic.ui.common.Checkbox('cLabel', 'z 1:30 (3)', 'lChecked', false);
            this.uiCheckboxZ1Z2Z3Avg = mic.ui.common.Checkbox('cLabel', 'z avg (123)', 'lChecked', true);
            this.uiCheckboxZ4 = mic.ui.common.Checkbox('cLabel', 'ang 0:30 (4)');
            this.uiCheckboxZ5 = mic.ui.common.Checkbox('cLabel', 'ang 4:30 (5)');
            this.uiCheckboxZ6 = mic.ui.common.Checkbox('cLabel', 'ang 8:30 (6)');
            
            this.uiCheckboxXReticle = mic.ui.common.Checkbox('cLabel', 'x reticle', 'lChecked', true);
            this.uiCheckboxYReticle = mic.ui.common.Checkbox('cLabel', 'y reticle', 'lChecked', true);
            this.uiCheckboxXWafer = mic.ui.common.Checkbox('cLabel', 'x wafer', 'lChecked', true);
            this.uiCheckboxYWafer = mic.ui.common.Checkbox('cLabel', 'y wafer', 'lChecked', true);
            
            this.initUiEditFreqMin();
            this.initUiEditFreqMax();
            this.initUiEditNumOfSamples();
            
        end
        
        function initUiEditFreqMin(this)
            
             this.uiEditFreqMin = mic.ui.common.Edit(...
                'cType', 'd', ...
                'fhDirectCallback', @this.onUiEditFreqMin, ...
                'cLabel', 'Freq. Min (Hz) (min = 0.1)' ...
            );
        
            this.uiEditFreqMin.set(10);
            this.uiEditFreqMin.setMin(0.1)
            this.uiEditFreqMin.setMax(500);
            
        end
        
        function initUiEditFreqMax(this)
            this.uiEditFreqMax = mic.ui.common.Edit(...
                'cType', 'd', ...
                'fhDirectCallback', @this.onUiEditFreqMax, ...
                'cLabel', 'Freq. Max (Hz) (max = 500)' ...
            );
            
            
            this.uiEditFreqMax.set(500);
            this.uiEditFreqMax.setMin(0.1)
            this.uiEditFreqMax.setMax(500);
            
        end
        
        function initUiEditNumOfSamples(this)
            
           
            this.uiEditNumOfSamples = mic.ui.common.Edit(...
                'cType', 'd', ...
                'fhDirectCallback', @this.onUiEditNumOfSamples, ...
                'cLabel', 'Samples (max = 10000)' ...
            );
            
            
            this.uiEditNumOfSamples.set(500);
            this.uiEditNumOfSamples.setMin(0)
            this.uiEditNumOfSamples.setMax(10000);
            
        end
        
        function onUiEditNumOfSamples(this, src, evt)
            
            
        end
        
        function onUiEditFreqMin(this, src, evt)
            
            if isempty(this.uiEditFreqMax)
                return
            end
            
            % Make sure max is not less than min
            if this.uiEditFreqMax.get() < this.uiEditFreqMin.get()
                this.uiEditFreqMax.set(this.uiEditFreqMin.get())
            end
            
            this.updateAxesLabels();
            
        end
        
        function onUiEditFreqMax(this, src, evt)
            
            if isempty(this.uiEditFreqMin)
                return
            end
            
            
            % Make sure min is not > max
            if this.uiEditFreqMin.get() > this.uiEditFreqMax.get()
                this.uiEditFreqMin.set(this.uiEditFreqMax.get())
            end
            
            this.updateAxesLabels();
            
        end
        
        
        % Returns a list of z channels to plot based on checkboxes
        function d = getHeightSensorChannels(this)
            d = [];
            
            % Put these in visual order so plot legend is same order as
            % visual order
            
            if this.uiCheckboxZ1.get()
                d(end + 1) = 1;
            end
            
            if this.uiCheckboxZ2.get()
                d(end + 1) = 2;
            end
            
            if this.uiCheckboxZ3.get()
                d(end + 1) = 3;
            end
            
            if this.uiCheckboxZ1Z2Z3Avg.get()
                d(end + 1) = 7;
            end
            
            if this.uiCheckboxZ4.get()
                d(end + 1) = 4;
            end
            
            if this.uiCheckboxZ5.get()
                d(end + 1) = 5;
            end
            
            if this.uiCheckboxZ6.get()
                d(end + 1) = 6;
            end
            
        end
        
        function d = getDmiChannels(this)
            
            d = [];
            if this.uiCheckboxXReticle.get()
                d(end + 1) = 1;
            end
            
            if this.uiCheckboxYReticle.get()
                d(end + 1) = 2;
            end
            
            if this.uiCheckboxXWafer.get()
                d(end + 1) = 3;
            end
            
            if this.uiCheckboxYWafer.get()
                d(end + 1) = 4;
            end
            
        end
        
        
    end
    
    
end

