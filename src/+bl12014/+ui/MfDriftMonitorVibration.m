classdef MfDriftMonitorVibration < mic.Base
    
    properties
        
        % {mic.ui.device.GetSetLogical 1x1}
        uiCommMfDriftMonitor
                        
    end
    
    properties (SetAccess = private)
        
        dWidth = 1710
        dHeight = 980
        
        dHeightList = 150
        
        dWidthAxes = 1100
        dHeightAxes = 225
        
        dWidthPanel = 270
        
        dHeightPadTop = 70
        dHeightPadTopAxes = 70;
        dWidthPadLeftAxes = 70
        
        dHeightPadTopTabGroup = 50;
        
        dWidthName = 70
        dWidthUnit = 80
        dWidthVal = 75
        dWidthPadUnit = 25 % 280
        
        dWidthPadLeftCheckboxes = 20
        
        cName = 'mf-drift-monitor-vibration'
        
        f_min = 10;
        f_max = 500;
        
        dDelay = 1;
        
                   
        hLinesPsd = []
        hLinesCas = []
        hLinesTime = []
        
        uiTogglePlayPause
        uiButtonSave
        uiButtonLoad
        uiListDir
        
        hPanelCasSettings
        hPanelTimeSettings
        hPanelSave
        
        uiTabGroupAxes
        
        

        
    end
    
    properties (Access = private)
        
        clock
        
        hFigure
        
        % Cooked
        hAxesTime % amplitide vs. time
        hAxesPsd % power spectral density
        hAxesCas % cumulative amplitude spectrum
        
        
        hAxesTimeRaw % amplitide vs. time
        hAxesPsdRaw % power spectral density
        hAxesCasRaw % cumulative amplitude spectrum
        
       
        
        % {< cxro.met5.device.mfdriftmonitorI}
        device 

        % *1 = time 0 us - 500 us of acquisition widnow
        % *2 = time 500 us - 1000 us of acquisition window
        
        uiCheckboxCh1T1
        uiCheckboxCh1B1
        uiCheckboxCh2T1
        uiCheckboxCh2B1
        uiCheckboxCh3T1
        uiCheckboxCh3B1
        uiCheckboxCh4T1
        uiCheckboxCh4B1
        uiCheckboxCh5T1
        uiCheckboxCh5B1
        uiCheckboxCh6T1
        uiCheckboxCh6B1
        
        uiCheckboxCh1T2
        uiCheckboxCh1B2
        uiCheckboxCh2T2
        uiCheckboxCh2B2
        uiCheckboxCh3T2
        uiCheckboxCh3B2
        uiCheckboxCh4T2
        uiCheckboxCh4B2
        uiCheckboxCh5T2
        uiCheckboxCh5B2
        uiCheckboxCh6T2
        uiCheckboxCh6B2
        
        uiCheckboxCh1T
        uiCheckboxCh1B
        uiCheckboxCh2T
        uiCheckboxCh2B
        uiCheckboxCh3T
        uiCheckboxCh3B
        uiCheckboxCh4T
        uiCheckboxCh4B
        uiCheckboxCh5T
        uiCheckboxCh5B
        uiCheckboxCh6T
        uiCheckboxCh6B
  
        
        
        
        
        uiTextCh1T1
        uiTextCh1B1
        uiTextCh2T1
        uiTextCh2B1
        uiTextCh3T1
        uiTextCh3B1
        uiTextCh4T1
        uiTextCh4B1
        uiTextCh5T1
        uiTextCh5B1
        uiTextCh6T1
        uiTextCh6B1
        
        uiTextCh1T2
        uiTextCh1B2
        uiTextCh2T2
        uiTextCh2B2
        uiTextCh3T2
        uiTextCh3B2
        uiTextCh4T2
        uiTextCh4B2
        uiTextCh5T2
        uiTextCh5B2
        uiTextCh6T2
        uiTextCh6B2
        
        uiTextCh1T
        uiTextCh1B
        uiTextCh2T
        uiTextCh2B
        uiTextCh3T
        uiTextCh3B
        uiTextCh4T
        uiTextCh4B
        uiTextCh5T
        uiTextCh5B
        uiTextCh6T
        uiTextCh6B
        
        uiTextSquareCh1T1
        uiTextSquareCh1B1
        uiTextSquareCh2T1
        uiTextSquareCh2B1
        uiTextSquareCh3T1
        uiTextSquareCh3B1
        uiTextSquareCh4T1
        uiTextSquareCh4B1
        uiTextSquareCh5T1
        uiTextSquareCh5B1
        uiTextSquareCh6T1
        uiTextSquareCh6B1
        
        uiTextSquareCh1T2
        uiTextSquareCh1B2
        uiTextSquareCh2T2
        uiTextSquareCh2B2
        uiTextSquareCh3T2
        uiTextSquareCh3B2
        uiTextSquareCh4T2
        uiTextSquareCh4B2
        uiTextSquareCh5T2
        uiTextSquareCh5B2
        uiTextSquareCh6T2
        uiTextSquareCh6B2
        
        uiTextSquareCh1T
        uiTextSquareCh1B
        uiTextSquareCh2T
        uiTextSquareCh2B
        uiTextSquareCh3T
        uiTextSquareCh3B
        uiTextSquareCh4T
        uiTextSquareCh4B
        uiTextSquareCh5T
        uiTextSquareCh5B
        uiTextSquareCh6T
        uiTextSquareCh6B
        
        uiTextLabelMeanCounts
        uiTextLabelCap1
        uiTextLabelCap2
        uiTextLabelCap1Cap2Avg

        uiCheckboxUReticle
        uiCheckboxVReticle
        uiCheckboxUWafer
        uiCheckboxVWafer
        
        
        
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
        uiCheckboxDriftX
        uiCheckboxDriftY
        
        uiEditFreqMin
        uiEditFreqMax
        
        uiCheckboxAutoScaleYCas
        uiEditYMaxCas
        uiEditYMinCas
        
        uiEditTimeMin
        uiEditTimeMax
        
        uiEditNumOfSamples
        
        dChannelsHsPrevious = []
        dChannelsDmiPrevious = []
        
        dChannelsRawHsPrevious = []
        dChannelsRawDmiPrevious = []
        
        lLabelsOfCookedInitialized = false
        lLabelsOfRawInitialized = false
        
        % { < java.util.ArrayList<cxro.met5.device.mfdriftmonitor.SampleData>}
        % Store them so save can have access to frozen data set.
        samples
        
        
        % Why do we need to store the values?  Because when paused (which
        % happens after load), need to be able to select the checkboxes to
        % change what is plotted.  Only way to update plot is if have full
        % set of possible data that can be plotted
        
        % {double 7xm}
        dZ = zeros(7, 1)
        % {double 4xm}
        dXY = zeros(4, 1)
        
        dRawOfHeightSensor = zeros(24, 1);
        dRawOfDmi = zeros(4, 1);
        
        
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
        
        
        
        
        
        
        
        function buildAxesTimeRaw(this)
            
            dLeft = this.dWidthPadLeftAxes;
            dTop = this.dHeightPadTop;
            
            this.hAxesTimeRaw = axes(...
                'Parent', this.uiTabGroupAxes.getTabByName('Raw'), ...
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
        
        function buildAxesPsdRaw(this)
            
            dLeft = this.dWidthPadLeftAxes;
            dTop = this.dHeightPadTop + ...
                this.dHeightAxes + this.dHeightPadTopAxes;
            
            this.hAxesPsdRaw = axes(...
                'Parent', this.uiTabGroupAxes.getTabByName('Raw'), ...
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
        
        function buildAxesCasRaw(this)
            
            dLeft = this.dWidthPadLeftAxes;
            
            dTop = this.dHeightPadTop + ...
                this.dHeightAxes + this.dHeightPadTopAxes + ...
                this.dHeightAxes + this.dHeightPadTopAxes;
            
            this.hAxesCasRaw = axes(...
                'Parent', this.uiTabGroupAxes.getTabByName('Raw'), ...
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
            
            % this.uiCommMfDriftMonitor.set(true);
            this.device = comm;
            
        end
        
        
        function disconnectMfDriftMonitor(this)
            % this.uiCommMfDriftMonitor.set(false);
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
        
        function buildPanelSaveLoad(this)
            
            dLeft = 10;
            dTop = 170;
            dHeight = 300;
            
            this.hPanelSave = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Save / Load',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidthPanel ...
                dHeight], this.hFigure) ...
            );
        
            dLeft = 10;
            dTop = 20;
            dSep = 30;
            
            % Save 
            this.uiButtonSave.build(this.hPanelSave, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;            
            
            % List Dir
            this.uiListDir.build(this.hPanelSave, dLeft, dTop, 240, this.dHeightList);
            dTop = dTop + this.dHeightList + 10 + dSep;
            
            % Load 
            %{
            this.uiButtonLoad.build(this.hPanelSave, dLeft, dTop, 80, 24);
            dTop = dTop + 50 + dSep;
            %}
            
        end
        
        function buildPanelTimeSettings(this)
            
            dLeft = 10;
            dTop = 500;
            dHeight = 150;
            
            this.hPanelTimeSettings = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'Time Settings',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidthPanel ...
                dHeight], this.hFigure) ...
            );
            
            dLeft = 10;
            dTop = 20;
            dSep = 40;
            
            this.uiEditTimeMin.build(this.hPanelTimeSettings, dLeft, dTop, 150, 24);
            dTop = dTop + dSep;
            
            this.uiEditTimeMax.build(this.hPanelTimeSettings, dLeft, dTop, 150, 24);
            dTop = dTop + dSep;
            
        end
        
        function buildPanelCasSettings(this)
            
            dLeft = 10;
            dTop = 670;
            dHeight = 250;
            
            this.hPanelCasSettings = uipanel(...
                'Parent', this.hFigure,...
                'Units', 'pixels',...
                'Title', 'CAS Settings',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidthPanel ...
                dHeight], this.hFigure) ...
            );
            
            dLeft = 10;
            dTop = 20;
            dSep = 40;
            
            this.uiEditFreqMin.build(this.hPanelCasSettings, dLeft, dTop, 150, 24);
            dTop = dTop + dSep;
            
            this.uiEditFreqMax.build(this.hPanelCasSettings, dLeft, dTop, 150, 24);
            dTop = dTop + dSep;
            
            dTop = dTop + 20;
            this.uiCheckboxAutoScaleYCas.build(this.hPanelCasSettings, dLeft, dTop, 150, 24);
            dTop = dTop + dSep - 10;
            
            
            this.uiEditYMaxCas.build(this.hPanelCasSettings, dLeft, dTop, 150, 24);
            dTop = dTop + dSep;
            
            
            this.uiEditYMinCas.build(this.hPanelCasSettings, dLeft, dTop, 150, 24);
            dTop = dTop + dSep;
            
            
            if this.uiCheckboxAutoScaleYCas.get()
                this.uiEditYMinCas.hide()
                this.uiEditYMaxCas.hide()
            end
            
                                    
        end
        
        function buildTabCooked(this)
            
            hPanel = this.uiTabGroupAxes.getTabByName('Cooked');
            
            dLeft = this.dWidthPadLeftAxes;
            dTop = this.dHeightPadTop + this.dHeightPadTopTabGroup;
            
            this.hAxesTime = axes(...
                'Parent', hPanel, ...
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
            
            dTop = dTop + this.dHeightAxes + this.dHeightPadTopAxes;
            
            this.hAxesPsd = axes(...
                'Parent', hPanel, ...
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
            
            dTop = dTop + this.dHeightAxes + this.dHeightPadTopAxes;

            
            this.hAxesCas = axes(...
                'Parent', hPanel, ...
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
            
            dLeft = this.dWidthAxes + this.dWidthPadLeftAxes + this.dWidthPadLeftCheckboxes;
            dTop = this.dHeightPadTopTabGroup;
            dSep = 20;
            
            this.uiCheckboxZ1.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxZ2.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxZ3.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxZ1Z2Z3Avg.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxZ4.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxZ5.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxZ6.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;

            this.uiCheckboxXReticle.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxYReticle.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxXWafer.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            this.uiCheckboxYWafer.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            
            this.uiCheckboxDriftX.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;
            
            this.uiCheckboxDriftY.build(hPanel, dLeft, dTop, 100, 24);
            dTop = dTop + dSep;

            dTop = dTop + 20;
            dSep = 40;
            
            
        end
        
        function buildTabRaw(this)
            
            hPanel = this.uiTabGroupAxes.getTabByName('Raw');
            
            dLeft = this.dWidthPadLeftAxes;
            dTop = this.dHeightPadTop + this.dHeightPadTopTabGroup;
            
            this.hAxesTimeRaw = axes(...
                'Parent', hPanel, ...
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
            
            dTop = dTop + this.dHeightAxes + this.dHeightPadTopAxes;
            
            this.hAxesPsdRaw = axes(...
                'Parent', hPanel, ...
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
            
            dTop = dTop + this.dHeightAxes + this.dHeightPadTopAxes;

            
            this.hAxesCasRaw = axes(...
                'Parent', hPanel, ...
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
            
            dLeft = this.dWidthAxes + this.dWidthPadLeftAxes + this.dWidthPadLeftCheckboxes;
            dTop = this.dHeightPadTopTabGroup;
            dSep = 20;
            
            this.uiTextLabelCap1.build(hPanel, dLeft, dTop - 20, 100, 20);
            this.uiTextLabelMeanCounts.build(hPanel, dLeft + 100, dTop - 20, 100, 20);
            
            dWidth = 160;
            dHeightPadChannel = 5;
            dHeightPadGroup = 20; %cap1 vs. cap 2 vs dmi
            
            cecProps = this.getCheckboxRawHeightSensorProps();
            dHeight = 15
            dSep = 15;
        
            % Building the checkboxes for raw 
            
            for n = 1 : length(cecProps)
               cProp = cecProps{n};
               this.(cProp).build(hPanel, dLeft, dTop, dWidth, dHeight);
               dTop = dTop + dSep;
               
               if mod(n, 2) == 0
                   dTop = dTop + dHeightPadChannel;
               end
               if n == 12
                   dTop = dTop + dHeightPadGroup;
                   this.uiTextLabelCap2.build(hPanel, dLeft, dTop - dHeight, 100, dHeight);
               end
               if n == 24
                   dTop = dTop + dHeightPadGroup;
                   this.uiTextLabelCap1Cap2Avg.build(hPanel, dLeft, dTop - dHeight, 200, dHeight);
               end
               
               
               
            end
            
            
            dTop = dTop + 30;

            
            this.uiCheckboxUReticle.build(hPanel, dLeft, dTop, dWidth, dHeight);
            dTop = dTop + dSep;
            this.uiCheckboxVReticle.build(hPanel, dLeft, dTop, dWidth, dHeight);
            dTop = dTop + dSep;
            this.uiCheckboxUWafer.build(hPanel, dLeft, dTop, dWidth, dHeight);
            dTop = dTop + dSep;
            this.uiCheckboxVWafer.build(hPanel, dLeft, dTop, dWidth, dHeight);
            dTop = dTop + dSep;
            
            
            
            dLeft = this.dWidthAxes + this.dWidthPadLeftAxes + this.dWidthPadLeftCheckboxes + 100;
            dTop = this.dHeightPadTopTabGroup;
            dSep = 15;
            dHeight = 15;
            dWidth = 50;
            
            % Texts for avg counts
            
            cecProps = this.getTextProps();
        
            % Additional offset
            dTop = dTop + 0;
            for n = 1 : length(cecProps)
               cProp = cecProps{n};
               this.(cProp).build(hPanel, dLeft, dTop, dWidth, dHeight);
               dTop = dTop + dSep;
               
               if mod(n, 2) == 0
                   dTop = dTop + dHeightPadChannel;
               end
               
               if n == 12
                   dTop = dTop + dHeightPadGroup;
               end
               
               if n == 24
                   dTop = dTop + dHeightPadGroup;
               end
            end
            
            % mic.ui.Text used to get a square of a color
            
            dLeft = this.dWidthAxes + this.dWidthPadLeftAxes + this.dWidthPadLeftCheckboxes + 100 + 55;
            dTop = this.dHeightPadTopTabGroup;
            dSep = 15;
            dWidth = dHeight;
            
            cecProps = this.getTextSquareProps();
        
            % Text "Squares" used for color status
            % Additional offset
            dTop = dTop + 0;
            for n = 1 : length(cecProps)
               cProp = cecProps{n};
               this.(cProp).build(hPanel, dLeft, dTop, dWidth, dHeight);
               dTop = dTop + dSep;
               if mod(n, 2) == 0
                   dTop = dTop + dHeightPadChannel;
               end
               if n == 12
                   dTop = dTop + dHeightPadGroup;
               end
               
               if n == 24
                   dTop = dTop + dHeightPadGroup;
               end
            end
            
            
            
            
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
            
            
            dTop = dTop + 30;
            this.uiTogglePlayPause.build(this.hFigure, dLeft, dTop, 100, 24);
            % dTop = dTop + dSep;
            
            dLeft = dLeft + 110;
            this.uiEditNumOfSamples.build(this.hFigure, dLeft, dTop - 10, 150, 24);
            dTop = dTop + dSep;
            
            this.buildPanelSaveLoad();
            this.buildPanelCasSettings();
            this.buildPanelTimeSettings();
            
            
            % Tab Group
            dLeft = 300;
            dTop = 20;
            this.uiTabGroupAxes.build(this.hFigure, dLeft, 10, this.dWidth - 320, this.dHeight - 40);
            this.buildTabCooked();
            this.buildTabRaw();
            
            dTop = 20;
            dLeft = 100 + this.dWidthAxes;
            dSep = 30;
            
           
            
            if ~isempty(this.clock)
                this.clock.add(@this.onClock, this.id(), this.dDelay);
            end
            
        end
        
        function delete(this)
            
            this.msg('delete');
            
            % Clean up clock tasks
            if ~isempty(this.clock) && ...
                isvalid(this.clock) && ...
                this.clock.has(this.id())
                this.msg('delete() removing clock task', this.u8_MSG_TYPE_INFO); 
                this.clock.remove(this.id());
            end
            
                        
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end 
        
        
        
        function update(this)
            
            if ~ishghandle(this.hFigure)
                return
            end
            
            this.samples = this.device.getSampleData(this.uiEditNumOfSamples.get());
            
            this.dZ = this.getHeightSensorZFromSampleData(this.samples);
            this.dXY = this.getDmiPositionFromSampleData(this.samples);
                    
            this.dRawOfHeightSensor = this.getRawOfHeightSensorFromSampleData(this.samples);
            this.dRawOfDmi = this.getRawOfDmiFromSampleData(this.samples);
                    
                    
            this.updateAxes();
            this.updateTexts()
            
        end
        
        function saveLastNSamplesToFile(this, numSamples, cPath)
            this.saveSamplesToFile(this.device.getSampleData(numSamples), cPath);
        end
        
        function updateTexts(this)
            
            switch this.uiTabGroupAxes.getSelectedTabName()
                case "Cooked"
                    
                case "Raw"
                    this.updateTextsRaw(this.dRawOfHeightSensor, this.dRawOfDmi);
            end
        end
        
        % Updates the avg counts of raw data and the 
        % color indicators
        function updateTextsRaw(this, rawHs, rawDmi)
            
            cecListOfTexts = this.getTextProps();
            cecListOfTextSquares = this.getTextSquareProps();
            
            dColors = 256;
            cmap = jet(dColors);
            for n = 1 : length(cecListOfTexts)
                dVal = mean(rawHs(n, :));
                dIndexOfColor = round((dColors - 1) * dVal/2^20) + 1; % 0 to 255 + 1
                % Map dVal to a range of ints in
                cVal = sprintf('%6.0f', dVal);
                this.(cecListOfTexts{n}).set(cVal)
                this.(cecListOfTextSquares{n}).setBackgroundColor(cmap(dIndexOfColor, :));
            end
            
            
        end
        
        
        function updateAxes(this)
            
            
            switch this.uiTabGroupAxes.getSelectedTabName()
                case "Cooked"
                    this.updateAxesCooked(this.dZ, this.dXY);
                case "Raw"
                    this.updateAxesRaw(this.dRawOfHeightSensor, this.dRawOfDmi);
            end
        end
        
        
        function updateFromFileSelectedInList(this)
            
            this.uiTogglePlayPause.set(false); % pause so it shows "play"
            
            ceFiles = this.uiListDir.get();
            if isempty(ceFiles)
                return
            end
            
            cPathOfDir = mic.Utils.path2canonical(this.uiListDir.getDir());
            cPath = fullfile(cPathOfDir, ceFiles{1});
            hFile = fopen(cPath);

            % %d = signed integer, 32-bit
            cFormat = [...
                '%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,', ...
                '%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,', ...
                '%d,%d,%d,%d' ...
            ];

            ceData = textscan(...
                hFile, cFormat, -1, ...
                'headerlines', 1 ...
            );
        
            fclose(hFile);
            
            % To deal with data from the test routines on met5vme that
            % usually contain partial data, truncate all sample
            % arrays to the length of dmi4 sample appay

            numSamples = length(ceData{28});
            for n = 1 : length(ceData)
                while length(ceData{n}) > numSamples
                    ceData{n}(end) = [];
                end
            end

            this.dZ = this.getHeightSensorZFromFileData(ceData);
            this.dXY = this.getDmiPositionFromFileData(ceData);
                    
            this.dRawOfHeightSensor = this.getRawOfHeightSensorFromFileData(ceData);
            this.dRawOfDmi = this.getRawOfDmiFromFileData(ceData);
                    
            this.updateAxes();
            this.updateTexts();
                                         
        end
        
        function l = areAxesRawAvailable(this)
            l = true;
            if  isempty(this.hAxesPsdRaw) || ...
                ~ishandle(this.hAxesPsdRaw)
               
                l = false;
                return;
            end
            
            if  isempty(this.hAxesCasRaw) || ...
                ~ishandle(this.hAxesCasRaw)
               
                l = false;
                return;
            end
            
            if  isempty(this.hAxesTimeRaw) || ...
                ~ishandle(this.hAxesTimeRaw)
               
                l = false;
                return;
            end
            
        end
        
        
        function l = areAxesCookedAvailable(this)
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
        
        
        function l = areAxesAvailable(this)
            l = this.areAxesCookedAvailable() && this.areAxesRawAvailable();
        end
        
        function updateAxesCooked(this, z, xy)
            
            
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
            dChannelsHs = this.getChannelsHeightSensor();
            
            for n = dChannelsHs
    
                channel = n;
                pos = z(channel, :);
                
                % Time
                plot(this.hAxesTime, t, pos - mean(pos), '.-')
                hold(this.hAxesTime, 'on') % need to do after first loglog
                grid(this.hAxesTime, 'on');
                
                % PSD
                [freq_psd, energy_psd] = Psd.calc(t, pos - mean(pos));
                [freq_psd, energy_psd] = Psd.fold(freq_psd, energy_psd);
                loglog(this.hAxesPsd, freq_psd, energy_psd);
                hold(this.hAxesPsd, 'on') % need to do after first loglog
                grid(this.hAxesPsd, 'on');


                % In-band CAS
                [f_band, energy_band] = Psd.band(freq_psd, energy_psd, 1/this.uiEditFreqMin.get(), 1/this.uiEditFreqMax.get());
                [f, powerc] = Psd.powerCumulative(f_band, energy_band);
                semilogx(this.hAxesCas, f, sqrt(powerc));
                hold(this.hAxesCas, 'on')
                grid(this.hAxesCas, 'on')
                
                cecLabels{end + 1} = cecLabelsZ{channel};



            end

            cecLabelsXY = {...
                'X reticle', ...
                'Y reticle', ...
                'X wafer', ...
                'Y wafer', ...
                'Drift X', ...
                'Drift Y' ...
            };
            
            dChannelsDmi = this.getChannelsDmi();
            
            for n = dChannelsDmi
    
                channel = n;
                pos = xy(channel, :);

                % Time
                plot(this.hAxesTime, t, pos - mean(pos), '.-');
                hold(this.hAxesTime, 'on')
                grid(this.hAxesTime, 'on')
                
                % PSD
                [freq_psd, energy_psd] = Psd.calc(t, pos - mean(pos));
                [freq_psd, energy_psd] = Psd.fold(freq_psd, energy_psd);
                loglog(this.hAxesPsd, freq_psd, energy_psd);
                hold(this.hAxesPsd, 'on') % need to do after first loglog
                grid(this.hAxesPsd, 'on');
                
                % In-band CAS
                [f_band, energy_band] = Psd.band(freq_psd, energy_psd, 1/this.uiEditFreqMin.get(), 1/this.uiEditFreqMax.get());
                [f, powerc] = Psd.powerCumulative(f_band, energy_band);
                semilogx(this.hAxesCas, f, sqrt(powerc));
                hold(this.hAxesCas, 'on')
                grid(this.hAxesCas, 'on')
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
               
            if ~this.lLabelsOfCookedInitialized
                this.updateAxesLabelsCooked()
                this.lLabelsOfCookedInitialized = true;

            end
            
            this.dChannelsHsPrevious = dChannelsHs;
            this.dChannelsDmiPrevious = dChannelsDmi;
            
        end
        
        
        function updateAxesRaw(this, rawHs, rawDmi)
            
            
            if ~this.areAxesAvailable()
                return
            end
            
            %delete(this.hLinesPsd);
            %delete(this.hLinesCas);
            
            cla(this.hAxesTimeRaw);
            cla(this.hAxesPsdRaw);
            cla(this.hAxesCasRaw);
            
            t = [0 : length(rawHs) - 1] * 1e-3;

            cecLabels = {}; % Fill with plotted things
            cecLabelsZ = {...
                'ch6top cap 1 (0 - 500 us)', ...
                'ch6bot cap 1 (0 - 500 us)', ...
                'ch5top cap 1 (0 - 500 us)', ...
                'ch5bot cap 1 (0 - 500 us)', ...
                'ch4top cap 1 (0 - 500 us)', ...
                'ch4bot cap 1 (0 - 500 us)', ...
                'ch3top cap 1 (0 - 500 us)', ...
                'ch3bot cap 1 (0 - 500 us)', ...
                'ch2top cap 1 (0 - 500 us)', ...
                'ch2bot cap 1 (0 - 500 us)', ...
                'ch1top cap 1 (0 - 500 us)', ...
                'ch1bot cap 1 (0 - 500 us)', ...
                'ch6top cap 2 (500 - 1000 us)', ...
                'ch6bot cap 2 (500 - 1000 us)', ...
                'ch5top cap 2 (500 - 1000 us)', ...
                'ch5bot cap 2 (500 - 1000 us)', ...
                'ch4top cap 2 (500 - 1000 us)', ...
                'ch4bot cap 2 (500 - 1000 us)', ...
                'ch3top cap 2 (500 - 1000 us)', ...
                'ch3bot cap 2 (500 - 1000 us)', ...
                'ch2top cap 2 (500 - 1000 us)', ...
                'ch2bot cap 2 (500 - 1000 us)', ...
                'ch1top cap 2 (500 - 1000 us)', ...
                'ch1bot cap 2 (500 - 1000 us)', ...
                'ch6top avg (0 - 1000 us)', ...
                'ch6bot avg (0 - 1000 us)', ...
                'ch5top avg (0 - 1000 us)', ...
                'ch5bot avg (0 - 1000 us)', ...
                'ch4top avg (0 - 1000 us)', ...
                'ch4bot avg (0 - 1000 us)', ...
                'ch3top avg (0 - 1000 us)', ...
                'ch3bot avg (0 - 1000 us)', ...
                'ch2top avg (0 - 1000 us)', ...
                'ch2bot avg (0 - 1000 us)', ...
                'ch1top avg (0 - 1000 us)', ...
                'ch1bot avg (0 - 1000 us)' ...
            };
            
            % z (nm) 
            dChannelsHs = this.getChannelsHeightSensorRaw();
            
            for n = dChannelsHs
    
                channel = n;
                pos = rawHs(channel, :);
                
                % Time
                plot(this.hAxesTimeRaw, t, pos - mean(pos), '.-')
                hold(this.hAxesTimeRaw, 'on') % need to do after first loglog
                grid(this.hAxesTimeRaw, 'on');
                
                % PSD
                [freq_psd, energy_psd] = Psd.calc(t, pos - mean(pos));
                [freq_psd, energy_psd] = Psd.fold(freq_psd, energy_psd);
                
                loglog(this.hAxesPsdRaw, freq_psd, energy_psd);
                hold(this.hAxesPsdRaw, 'on') % need to do after first loglog
                grid(this.hAxesPsdRaw, 'on');


                % In-band CAS
                [f_band, energy_band] = Psd.band(freq_psd, energy_psd, 1/this.uiEditFreqMin.get(), 1/this.uiEditFreqMax.get());
                [f, powerc] = Psd.powerCumulative(f_band, energy_band);
                semilogx(this.hAxesCasRaw, f, sqrt(powerc));
                hold(this.hAxesCasRaw, 'on')
                grid(this.hAxesCasRaw, 'on')
                
                cecLabels{end + 1} = cecLabelsZ{channel};

            end

            cecLabelsXY = {...
                'U reticle', ...
                'V reticle', ...
                'U wafer', ...
                'V wafer' ...
            };
            
            dChannelsDmi = this.getChannelsDmiRaw();
            
            for n = dChannelsDmi
    
                channel = n;
                pos = rawDmi(channel, :);

                % Time
                plot(this.hAxesTimeRaw, t, pos - mean(pos), '.-');
                hold(this.hAxesTimeRaw, 'on')
                grid(this.hAxesTimeRaw, 'on')
                
                % PSD
                [freq_psd, energy_psd] = Psd.calc(t, pos - mean(pos));
                [freq_psd, energy_psd] = Psd.fold(freq_psd, energy_psd);
                loglog(this.hAxesPsdRaw, freq_psd, energy_psd);
                hold(this.hAxesPsdRaw, 'on') % need to do after first loglog
                grid(this.hAxesPsdRaw, 'on');
                
                % In-band CAS
                [f_band, energy_band] = Psd.band(freq_psd, energy_psd, 1/this.uiEditFreqMin.get(), 1/this.uiEditFreqMax.get());
                [f, powerc] = Psd.powerCumulative(f_band, energy_band);
                semilogx(this.hAxesCasRaw, f, sqrt(powerc));
                hold(this.hAxesCasRaw, 'on')
                grid(this.hAxesCasRaw, 'on')
                cecLabels{end + 1} = cecLabelsXY{channel};

            end

            % Y
            lForceNewLegend = true;
            if (~isequal(dChannelsHs, this.dChannelsRawHsPrevious) || ...
                ~isequal(dChannelsDmi, this.dChannelsRawDmiPrevious) || ...
                lForceNewLegend)
                legend(this.hAxesTimeRaw, cecLabels);
                legend(this.hAxesPsdRaw, cecLabels);
                legend(this.hAxesCasRaw, cecLabels);
            end
               
            if ~this.lLabelsOfRawInitialized
                this.updateAxesLabelsRaw()
                this.lLabelsOfRawInitialized = true;

            end
            
            this.dChannelsRawHsPrevious = dChannelsHs;
            this.dChannelsRawDmiPrevious = dChannelsDmi;
            
        end
        
        function updateAxesLabelsRaw(this)
            
            if ~this.areAxesAvailable()
                return
            end
            
            title(this.hAxesTimeRaw, 'Amplitude - Mean vs. Time');
            xlabel(this.hAxesTimeRaw, 'Time (s)');
            ylabel(this.hAxesTimeRaw, 'Counts');
            xlim(this.hAxesTimeRaw, [this.uiEditTimeMin.get()/1e3, this.uiEditTimeMax.get()/1e3])
            
            title(this.hAxesPsdRaw, 'PSD')
            xlabel(this.hAxesPsdRaw, 'Freq (Hz)');
            ylabel(this.hAxesPsdRaw, 'PSD (counts^2/Hz)');
            xlim(this.hAxesPsdRaw, [this.uiEditFreqMin.get(), this.uiEditFreqMax.get()])
            
            

            cTitle = sprintf(...
                'Cumulative Amplitude Spectrum [%1.0fHz, %1.0fHz]', ...
                this.uiEditFreqMin.get(), ...
                this.uiEditFreqMax.get() ...
            );
            title(this.hAxesCasRaw, cTitle);
            xlabel(this.hAxesCasRaw, 'Freq (Hz)');
            ylabel(this.hAxesCasRaw, 'Cumulative Amplitude RMS (counts)');
            xlim(this.hAxesCasRaw, [this.uiEditFreqMin.get(), this.uiEditFreqMax.get()])
            
            if ~this.uiCheckboxAutoScaleYCas.get()
                ylim(this.hAxesCasRaw, [this.uiEditYMinCas.get() , this.uiEditYMaxCas.get()])
            else
                ylim(this.hAxesCasRaw, 'auto')
            end
            
        end
        
        function updateAxesLabelsCooked(this)
            
            if ~this.areAxesAvailable()
                return
            end
            
            title(this.hAxesTime, 'Amplitude vs. Time');
            xlabel(this.hAxesTime, 'Time (s)');
            ylabel(this.hAxesTime, 'Amp. (nm)');
            xlim(this.hAxesTime, [this.uiEditTimeMin.get()/1e3, this.uiEditTimeMax.get()/1e3])
            
            title(this.hAxesPsd, 'PSD')
            xlabel(this.hAxesPsd, 'Freq (Hz)');
            ylabel(this.hAxesPsd, 'PSD (nm^2/Hz)');
            xlim(this.hAxesPsd, [this.uiEditFreqMin.get(), this.uiEditFreqMax.get()])

            cTitle = sprintf(...
                'Cumulative Amplitude Spectrum [%1.0fHz, %1.0fHz]', ...
                this.uiEditFreqMin.get(), ...
                this.uiEditFreqMax.get() ...
            );
            title(this.hAxesCas, cTitle);
            xlabel(this.hAxesCas, 'Freq (Hz)');
            ylabel(this.hAxesCas, 'Cumulative Amplitude RMS (nm)');
            xlim(this.hAxesCas, [this.uiEditFreqMin.get(), this.uiEditFreqMax.get()])
            
            if ~this.uiCheckboxAutoScaleYCas.get()
                ylim(this.hAxesCas, [this.uiEditYMinCas.get() , this.uiEditYMaxCas.get()])
            else
                ylim(this.hAxesCas, 'auto')
            end
            
        end
        
        function updateAxesLabels(this)
            this.updateAxesLabelsRaw();
            this.updateAxesLabelsCooked();
            
        end
        
        function d = getRawOfHeightSensorFromFileData(this, ceData)
            
            d = zeros(24, length(ceData{28})); 
            for n = 1 : 24
                d(n, :) = ceData{n};
            end
            
            % Rows 25 - 36 contain average of "cap a" and "cap b" over 
            % a 1000 us acquisition window
            for n = 1 : 12
                d(24 + n, :) = (d(n, :) + d(n + 12, :)) / 2;
            end
            
            
        end
        
        
        % See getHeightSensorZFromSampleData
        function z = getHeightSensorZFromFileData(this, ceData)
            
            m_per_diff_over_sum = 120e-6/2; 
            
            stMap = struct();
            
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

            % side === indicates to the capacitor used.  Do not confuse this with
            % "side" of the diode.  "a", and "b" refer to "top" and "bottom" halves of
            % the dual-diode, respectively
            % A single measurement returns the "capacitor/side" of the ADC, and the
            % counts from the top and bottom of each diode of each channel

            % average the values from each cap within the 1 ms acquisition period

            % top
            top(1, :) = (ceData{stMap.ch1top1} + ceData{stMap.ch1top2}) / 2;
            top(2, :) = (ceData{stMap.ch2top1} + ceData{stMap.ch2top2}) / 2;
            top(3, :) = (ceData{stMap.ch3top1} + ceData{stMap.ch3top2}) / 2;
            top(4, :) = (ceData{stMap.ch4top1} + ceData{stMap.ch4top2}) / 2;
            top(5, :) = (ceData{stMap.ch5top1} + ceData{stMap.ch5top2}) / 2;
            top(6, :) = (ceData{stMap.ch6top1} + ceData{stMap.ch6top2}) / 2; 

            % bottom
            bot(1, :) = (ceData{stMap.ch1bot1} + ceData{stMap.ch1bot2}) / 2;
            bot(2, :) = (ceData{stMap.ch2bot1} + ceData{stMap.ch2bot2}) / 2;
            bot(3, :) = (ceData{stMap.ch3bot1} + ceData{stMap.ch3bot2}) / 2;
            bot(4, :) = (ceData{stMap.ch4bot1} + ceData{stMap.ch4bot2}) / 2;
            bot(5, :) = (ceData{stMap.ch5bot1} + ceData{stMap.ch5bot2}) / 2;
            bot(6, :) = (ceData{stMap.ch6bot1} + ceData{stMap.ch6bot2}) / 2;    

            diff = top - bot;
            sum = top + bot;
            dos = double(diff)./double(sum);
            z = dos * m_per_diff_over_sum * 1e9;
            
            % Ch "7" is average of three central
            z(7, :) = (z(1, :) + z(2, :) + z(3, :))/3;
        end
        
        
        
        % Returns a {double 6xm} time series of height zensor z in nm of
        % all six channels
        % @param {ArrayList<SampleData> 1x1} samples - sample data
        % @return {double 24xm} - height sensor z (nm) of six channels at 1 kHz
        
        function d = getRawOfHeightSensorFromSampleData(this, samples)
            
            d = zeros(36, samples.size());
            
            % Samples.get() is zero-indexed since implementing java
            % interface
            for n = 0 : samples.size() - 1
                d(1 : 24, n + 1) = samples.get(n).getHsData();
            end
            
            % Rows 25 - 36 contain average of "cap a" and "cap b" over 
            % a 1000 us acquisition window
            for n = 1 : 12
                d(24 + n, :) = (d(n, :) + d(n + 12, :)) / 2;
            end
                                                    
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
        
        function d = getRawOfDmiFromFileData(this, ceData)
            
            stMap = struct();
            stMap.dmi1 = 25;
            stMap.dmi2 = 26;
            stMap.dmi3 = 27;
            stMap.dmi4 = 28;
                                 
            d(1, :) = double(ceData{stMap.dmi1});
            d(2, :) = double(ceData{stMap.dmi2});
            d(3, :) = double(ceData{stMap.dmi3});
            d(4, :) = double(ceData{stMap.dmi4});

            
            
        end
        
        % See getDmiPositionFromSampleData
        function pos = getDmiPositionFromFileData(this, ceData)
            
            
            stMap = struct();
            stMap.dmi1 = 25;
            stMap.dmi2 = 26;
            stMap.dmi3 = 27;
            stMap.dmi4 = 28;
            
            dDMI_SCALE = 632.9907/4096; % dmi axes come in units of 1.5 angstroms
                                  % Convert to nm
                                 
            dErrU_ret = double(ceData{stMap.dmi1});
            dErrV_ret = double(ceData{stMap.dmi2});
            dErrU_waf = double(ceData{stMap.dmi3});
            dErrV_waf = double(ceData{stMap.dmi4});

            dXDat_ret = dDMI_SCALE * 1/sqrt(2) * (dErrU_ret + dErrV_ret);
            dYDat_ret = -dDMI_SCALE * 1/sqrt(2) * (dErrU_ret - dErrV_ret);
            dXDat_waf = -dDMI_SCALE * 1/sqrt(2) * (dErrU_waf + dErrV_waf);
            dYDat_waf = dDMI_SCALE * 1/sqrt(2) * (dErrU_waf - dErrV_waf);

            pos(1, :) = dXDat_ret;
            pos(2, :) = dYDat_ret;
            pos(3, :) = dXDat_waf; 
            pos(4, :) = dYDat_waf;
            
            % Drift
            pos(5, :) = 5 * pos(3, :) + pos(1, :); % drift x
            pos(6, :) = -5 * pos(4, :) + pos(2, :); % drift y
            
            
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

            pos(1, :) = dDMI_SCALE * 1/sqrt(2) * (dErrU_ret + dErrV_ret); % x ret
            pos(2, :) = -dDMI_SCALE * 1/sqrt(2) * (dErrU_ret - dErrV_ret); % y ret
            pos(3, :) = -dDMI_SCALE * 1/sqrt(2) * (dErrU_waf + dErrV_waf); % x wafer
            pos(4, :) = dDMI_SCALE * 1/sqrt(2) * (dErrU_waf - dErrV_waf); % y wafer
            
            % Compute drift
            pos(5, :) = 5 * pos(3, :) + pos(1, :); % drift x
            pos(6, :) = -5 * pos(4, :) + pos(2, :); % drift y
            
            
            %{ 
            From Java code
            double errX =  5 * xWafer + xReticle;
            double errY = -5 * yWafer + yReticle;
            %}
            
            
    
            

            
        end
        
        
        % Returns {double 4xm} x and y position of reticle and wafer in nm
        % @param {ArrayList<SampleData> 1x1} samples - sample data
        % @return {double 4xm} - position data of reticle and wafer nm
        % @return(1, :) {double 1xm} - uReticle
        % @return(2, :) {double 1xm} - vReticle
        % @return(3, :) {double 1xm} - uWafer
        % @return(4, :) {double 1xm} - vWafer

        function d = getRawOfDmiFromSampleData(this, samples)
            
            % Reshape to a 4xn matrix of doubles.  
            
            % Mirrors are mounted 45 degrees relative to x and y
            % row1 = uReticle
            % row2 = vReticle
            % row3 = uWafer
            % row4 = vWafer
            
            % samples is zero-indexed because uses Java interface
            d = zeros(4, samples.size());
            for n = 0 : samples.size() - 1
                d(:, n + 1) = double(samples.get(n).getDmiData());
            end
                  
           
        end
        
        function st = save(this)
            
            cecProps = this.getSaveLoadProps();
            
            st = struct();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
                st.(cProp) = this.(cProp).save();
            end
            
            
        end
        
        function cec = getSaveLoadProps(this)
            cec = {...
                ... % Cooked
                'uiCheckboxZ1', ...
                'uiCheckboxZ2', ...
                'uiCheckboxZ3', ...
                'uiCheckboxZ4', ...
                'uiCheckboxZ5', ...
                'uiCheckboxZ6', ...
                'uiCheckboxZ1Z2Z3Avg', ...
                'uiCheckboxXReticle', ...
                'uiCheckboxYReticle', ...
                'uiCheckboxXWafer', ...
                'uiCheckboxYWafer', ...
                ... % Raw
                'uiCheckboxCh6T1', ...
                'uiCheckboxCh6B1', ...
                'uiCheckboxCh5T1', ...
                'uiCheckboxCh5B1', ...
                'uiCheckboxCh4T1', ...
                'uiCheckboxCh4B1', ...
                'uiCheckboxCh3T1', ...
                'uiCheckboxCh3B1', ...
                'uiCheckboxCh2T1', ...
                'uiCheckboxCh2B1', ...
                'uiCheckboxCh1T1', ...
                'uiCheckboxCh1B1', ...
                'uiCheckboxCh6T2', ...
                'uiCheckboxCh6B2', ...
                'uiCheckboxCh5T2', ...
                'uiCheckboxCh5B2', ...
                'uiCheckboxCh4T2', ...
                'uiCheckboxCh4B2', ...
                'uiCheckboxCh3T2', ...
                'uiCheckboxCh3B2', ...
                'uiCheckboxCh2T2', ...
                'uiCheckboxCh2B2', ...
                'uiCheckboxCh1T2', ...
                'uiCheckboxCh1B2', ...
                'uiCheckboxCh6T', ...
                'uiCheckboxCh6B', ...
                'uiCheckboxCh5T', ...
                'uiCheckboxCh5B', ...
                'uiCheckboxCh4T', ...
                'uiCheckboxCh4B', ...
                'uiCheckboxCh3T', ...
                'uiCheckboxCh3B', ...
                'uiCheckboxCh2T', ...
                'uiCheckboxCh2B', ...
                'uiCheckboxCh1T', ...
                'uiCheckboxCh1B', ...
                'uiCheckboxUReticle', ...
                'uiCheckboxVReticle', ...
                'uiCheckboxUWafer', ...
                'uiCheckboxVWafer', ...
                ... % Other
                'uiEditTimeMin', ...
                'uiEditTimeMax', ...
                'uiEditFreqMin', ...
                'uiEditFreqMax', ...
                'uiEditYMinCas', ...
                'uiEditYMaxCas', ...
                'uiCheckboxAutoScaleYCas', ...
                'uiEditNumOfSamples', ...
                'uiListDir' ...
            };
            
        end
        
        
        
        function load(this, st)
            
            cecProps = this.getSaveLoadProps();
            for n = 1 : length(cecProps)
                cProp = cecProps{n};
               if isfield(st, cProp)
               	this.(cProp).load(st.(cProp))
               end
            end
            
        end

        
        
    end
    
    methods (Access = private)
                
         
        function onCloseRequest(this, src, evt)
           
            
             % Clean up clock tasks
            if ~isempty(this.clock) && ...
                isvalid(this.clock) && ...
                this.clock.has(this.id())
                this.msg('delete() removing clock task', this.u8_MSG_TYPE_INFO); 
                this.clock.remove(this.id());
            end
            
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
        
        function onUiTabGroupAxes(this, src, evt);
            this.updateAxes();
        end
        
        function initCheckboxesRaw(this)
            
            this.uiCheckboxCh6T1 = mic.ui.common.Checkbox('cLabel', '6T 8:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh6B1 = mic.ui.common.Checkbox('cLabel', '6B 8:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh5T1 = mic.ui.common.Checkbox('cLabel', '5T 4:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh5B1 = mic.ui.common.Checkbox('cLabel', '5B 4:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            
            this.uiCheckboxCh4T1 = mic.ui.common.Checkbox('cLabel', '4T 0:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh4B1 = mic.ui.common.Checkbox('cLabel', '4B 0:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh3T1 = mic.ui.common.Checkbox('cLabel', '3T 1:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh3B1 = mic.ui.common.Checkbox('cLabel', '3B 1:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh2T1 = mic.ui.common.Checkbox('cLabel', '2T 9:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh2B1 = mic.ui.common.Checkbox('cLabel', '2B 9:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh1T1 = mic.ui.common.Checkbox('cLabel', '1T 5:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh1B1 = mic.ui.common.Checkbox('cLabel', '1B 5:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            
            
            this.uiCheckboxCh1T2 = mic.ui.common.Checkbox('cLabel', '1T 5:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh1B2 = mic.ui.common.Checkbox('cLabel', '1B 5:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh2T2 = mic.ui.common.Checkbox('cLabel', '2T 9:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh2B2 = mic.ui.common.Checkbox('cLabel', '2B 9:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh3T2 = mic.ui.common.Checkbox('cLabel', '3T 1:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh3B2 = mic.ui.common.Checkbox('cLabel', '3B 1:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh4T2 = mic.ui.common.Checkbox('cLabel', '4T 0:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh4B2 = mic.ui.common.Checkbox('cLabel', '4B 0:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh5T2 = mic.ui.common.Checkbox('cLabel', '5T 4:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh5B2 = mic.ui.common.Checkbox('cLabel', '5B 4:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh6T2 = mic.ui.common.Checkbox('cLabel', '6T 8:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh6B2 = mic.ui.common.Checkbox('cLabel', '6B 8:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            
            this.uiCheckboxCh1T = mic.ui.common.Checkbox('cLabel', '1T 5:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh1B = mic.ui.common.Checkbox('cLabel', '1B 5:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh2T = mic.ui.common.Checkbox('cLabel', '2T 9:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh2B = mic.ui.common.Checkbox('cLabel', '2B 9:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh3T = mic.ui.common.Checkbox('cLabel', '3T 1:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh3B = mic.ui.common.Checkbox('cLabel', '3B 1:30 z', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh4T = mic.ui.common.Checkbox('cLabel', '4T 0:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh4B = mic.ui.common.Checkbox('cLabel', '4B 0:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh5T = mic.ui.common.Checkbox('cLabel', '5T 4:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh5B = mic.ui.common.Checkbox('cLabel', '5B 4:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh6T = mic.ui.common.Checkbox('cLabel', '6T 8:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh6B = mic.ui.common.Checkbox('cLabel', '6B 8:30 ang', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);

            
            
            this.uiCheckboxUReticle = mic.ui.common.Checkbox('cLabel', 'U reticle', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxVReticle = mic.ui.common.Checkbox('cLabel', 'V reticle', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxUWafer = mic.ui.common.Checkbox('cLabel', 'U wafer', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxVWafer = mic.ui.common.Checkbox('cLabel', 'V wafer', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            
            
            
        end
        
        function cec = getTextProps(this)
            cec = {...
                ... % 0 - 500 us
                'uiTextCh6T1', ...
                'uiTextCh6B1', ...
                'uiTextCh5T1', ...
                'uiTextCh5B1', ...
                'uiTextCh4T1', ...
                'uiTextCh4B1', ...
                'uiTextCh3T1', ...
                'uiTextCh3B1', ...
                'uiTextCh2T1', ...
                'uiTextCh2B1', ...
                'uiTextCh1T1', ...
                'uiTextCh1B1', ...
                ... % 500 us - 1000 us
                'uiTextCh6T2', ...
                'uiTextCh6B2', ...
                'uiTextCh5T2', ...
                'uiTextCh5B2', ...
                'uiTextCh4T2', ...
                'uiTextCh4B2', ...
                'uiTextCh3T2', ...
                'uiTextCh3B2', ...
                'uiTextCh2T2', ...
                'uiTextCh2B2', ...
                'uiTextCh1T2', ...
                'uiTextCh1B2', ...
                ... % 0 us - 1000 us
                'uiTextCh6T', ...
                'uiTextCh6B', ...
                'uiTextCh5T', ...
                'uiTextCh5B', ...
                'uiTextCh4T', ...
                'uiTextCh4B', ...
                'uiTextCh3T', ...
                'uiTextCh3B', ...
                'uiTextCh2T', ...
                'uiTextCh2B', ...
                'uiTextCh1T', ...
                'uiTextCh1B' ...
            };
        end
        
        function cec = getTextSquareProps(this)
            cec = {...
                ... % 0 - 500 us
                'uiTextSquareCh6T1', ...
                'uiTextSquareCh6B1', ...
                'uiTextSquareCh5T1', ...
                'uiTextSquareCh5B1', ...
                'uiTextSquareCh4T1', ...
                'uiTextSquareCh4B1', ...
                'uiTextSquareCh3T1', ...
                'uiTextSquareCh3B1', ...
                'uiTextSquareCh2T1', ...
                'uiTextSquareCh2B1', ...
                'uiTextSquareCh1T1', ...
                'uiTextSquareCh1B1', ...
                ... % 500 us - 1000 us
                'uiTextSquareCh6T2', ...
                'uiTextSquareCh6B2', ...
                'uiTextSquareCh5T2', ...
                'uiTextSquareCh5B2', ...
                'uiTextSquareCh4T2', ...
                'uiTextSquareCh4B2', ...
                'uiTextSquareCh3T2', ...
                'uiTextSquareCh3B2', ...
                'uiTextSquareCh2T2', ...
                'uiTextSquareCh2B2', ...
                'uiTextSquareCh1T2', ...
                'uiTextSquareCh1B2', ...
                ... % 0 us - 1000 us
                'uiTextSquareCh6T', ...
                'uiTextSquareCh6B', ...
                'uiTextSquareCh5T', ...
                'uiTextSquareCh5B', ...
                'uiTextSquareCh4T', ...
                'uiTextSquareCh4B', ...
                'uiTextSquareCh3T', ...
                'uiTextSquareCh3B', ...
                'uiTextSquareCh2T', ...
                'uiTextSquareCh2B', ...
                'uiTextSquareCh1T', ...
                'uiTextSquareCh1B' ...
            };
        end
        
        function cec = getCheckboxRawHeightSensorProps(this)
            cec = {...
                ... % 0 - 500 us
                'uiCheckboxCh6T1', ...
                'uiCheckboxCh6B1', ...
                'uiCheckboxCh5T1', ...
                'uiCheckboxCh5B1', ...
                'uiCheckboxCh4T1', ...
                'uiCheckboxCh4B1', ...
                'uiCheckboxCh3T1', ...
                'uiCheckboxCh3B1', ...
                'uiCheckboxCh2T1', ...
                'uiCheckboxCh2B1', ...
                'uiCheckboxCh1T1', ...
                'uiCheckboxCh1B1', ...
                ... % 500 us - 1000 us
                'uiCheckboxCh6T2', ...
                'uiCheckboxCh6B2', ...
                'uiCheckboxCh5T2', ...
                'uiCheckboxCh5B2', ...
                'uiCheckboxCh4T2', ...
                'uiCheckboxCh4B2', ...
                'uiCheckboxCh3T2', ...
                'uiCheckboxCh3B2', ...
                'uiCheckboxCh2T2', ...
                'uiCheckboxCh2B2', ...
                'uiCheckboxCh1T2', ...
                'uiCheckboxCh1B2', ...
                ... % 0 us - 1000 us average
                'uiCheckboxCh6T', ...
                'uiCheckboxCh6B', ...
                'uiCheckboxCh5T', ...
                'uiCheckboxCh5B', ...
                'uiCheckboxCh4T', ...
                'uiCheckboxCh4B', ...
                'uiCheckboxCh3T', ...
                'uiCheckboxCh3B', ...
                'uiCheckboxCh2T', ...
                'uiCheckboxCh2B', ...
                'uiCheckboxCh1T', ...
                'uiCheckboxCh1B', ...
            };
        end
        
        function initTextsRaw(this)
            
            cecProps = this.getTextProps();
        
            for n = 1 : length(cecProps)
               cProp = cecProps{n};
               this.(cProp) = mic.ui.common.Text('cVal', '...', 'cAlign', 'right');
            end    
            
            
        end
        
        function initTextSquaresRaw(this)
            
            cecProps = this.getTextSquareProps();
        
            for n = 1 : length(cecProps)
               cProp = cecProps{n};
               this.(cProp) = mic.ui.common.Text('cVal', '', 'cAlign', 'right');
            end    
            

            
        end
        
        
        function init(this)
            this.msg('init()');
            this.initUiCommMfDriftMonitor();
            
            % Axes tab group:
            this.uiTabGroupAxes = mic.ui.common.Tabgroup(...
                'fhDirectCallback', { @this.onUiTabGroupAxes, @this.onUiTabGroupAxes } , ...
                'ceTabNames',  {'Cooked', 'Raw'} ...
            );
        
            this.initCheckboxesRaw()
            this.initTextsRaw()
            this.initTextSquaresRaw();
            
            this.uiTextLabelMeanCounts = mic.ui.common.Text('cVal', 'Avg. Counts');
            this.uiTextLabelCap1 = mic.ui.common.Text('cVal', '"Cap1" 0-500us');
            this.uiTextLabelCap2 = mic.ui.common.Text('cVal', '"Cap2" 500-1000us');
            this.uiTextLabelCap1Cap2Avg = mic.ui.common.Text('cVal', '"Cap1" + "Cap2" Avg 0-1000us');

                    
            this.uiCheckboxZ1 = mic.ui.common.Checkbox('cLabel', 'z 5:30 (1)', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxZ2 = mic.ui.common.Checkbox('cLabel', 'z 9:30 (2)', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxZ3 = mic.ui.common.Checkbox('cLabel', 'z 1:30 (3)', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxZ1Z2Z3Avg = mic.ui.common.Checkbox('cLabel', 'z avg (123)', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxZ4 = mic.ui.common.Checkbox('cLabel', 'ang 0:30 (4)', 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxZ5 = mic.ui.common.Checkbox('cLabel', 'ang 4:30 (5)', 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxZ6 = mic.ui.common.Checkbox('cLabel', 'ang 8:30 (6)', 'fhDirectCallback', @this.onUiCheckbox);
            
            this.uiCheckboxXReticle = mic.ui.common.Checkbox('cLabel', 'x reticle', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxYReticle = mic.ui.common.Checkbox('cLabel', 'y reticle', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxXWafer = mic.ui.common.Checkbox('cLabel', 'x wafer', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxYWafer = mic.ui.common.Checkbox('cLabel', 'y wafer', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            
            
            this.uiCheckboxDriftX = mic.ui.common.Checkbox('cLabel', 'drift x', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxDriftY = mic.ui.common.Checkbox('cLabel', 'drift y', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            
            this.uiTogglePlayPause = mic.ui.common.Toggle(...
                'cTextTrue', 'Pause', ...
                'cTextFalse', 'Acquire', ...
                'lVal', true, ...
                'fhDirectCallback', @this.onUiTogglePlayPause ...
            );
        
            this.uiButtonSave = mic.ui.common.Button(...
                'cText', 'Save', ...
                'fhDirectCallback', @this.onUiButtonSave ...
            );
        
            this.uiButtonLoad = mic.ui.common.Button(...
                'cText', 'Load', ...
                'fhDirectCallback', @this.onUiButtonLoad ...
            );
        
            cDirThis = fileparts(mfilename('fullpath'));

            cPath = mic.Utils.path2canonical(fullfile(cDirThis, '..', '..', 'save', 'hs-dmi'));
            this.uiListDir = mic.ui.common.ListDir(...
                'cDir', cPath, ...
                'cFilter', '*.txt', ...
                'lShowLabel', false, ...
                'lShowChooseDir', true, ...
                'fhOnChange', @this.onUiListChange, ...
                'cLabel', 'Save / Load Directory' ...
            );
        
            this.initUiEditFreqMin();
            this.initUiEditFreqMax();
            
             
            
            this.initUiEditYMinCas();
            this.initUiEditYMaxCas();
            
            this.initUiEditTimeMin();
            this.initUiEditTimeMax();
            this.initUiEditNumOfSamples();
            
            this.uiCheckboxAutoScaleYCas = mic.ui.common.Checkbox(...
                'cLabel', 'Auto Scale Y', ...
                'lChecked', true, ...
                'fhDirectCallback', @this.onUiCheckboxAutoScaleYCas ...
            );
               
            
        end
        
        function onUiCheckboxAutoScaleYCas(this, src, evt)
            
            if isempty(this.uiEditYMinCas)
                return
            end
            
            if isempty(this.uiEditYMaxCas)
                return
            end
            
            if this.uiCheckboxAutoScaleYCas.get()
                this.uiEditYMinCas.hide()
                this.uiEditYMaxCas.hide()
            else
                this.uiEditYMinCas.show()
                this.uiEditYMaxCas.show()
            end
            
            if ~this.uiTogglePlayPause.get() % paused
                % Need to update since CAS band has changed
                this.updateAxes()
            end
            this.updateAxesLabels();
            
            
        end
        
        function initUiEditTimeMin(this)
            
             this.uiEditTimeMin = mic.ui.common.Edit(...
                'cType', 'd', ...
                'fhDirectCallback', @this.onUiEditTimeMin, ...
                'cLabel', 'Time. Min (ms) (min = 0)' ...
            );
        
            this.uiEditTimeMin.setMin(0);
            this.uiEditTimeMin.setMax(9999);
            this.uiEditTimeMin.set(0);
            
        end
        
        function initUiEditTimeMax(this)
            
             this.uiEditTimeMax = mic.ui.common.Edit(...
                'cType', 'd', ...
                'fhDirectCallback', @this.onUiEditTimeMax, ...
                'cLabel', 'Time. Max (ms) (max = 10000)' ...
            );
        
            % Default value is zero, need to set to value larger than zero
            % before calling setMin(1)
            this.uiEditTimeMax.set(1000);
            this.uiEditTimeMax.setMin(1)
            this.uiEditTimeMax.setMax(10000);
            
        end
        
        
        function initUiEditYMinCas(this)
            
             this.uiEditYMinCas = mic.ui.common.Edit(...
                'cType', 'd', ...
                'fhDirectCallback', @this.onUiEditYMinCas, ...
                'cLabel', 'Y Min (nm) (min = 0)' ...
            );
            this.uiEditYMinCas.setMin(0)
            this.uiEditYMinCas.set(0);
            
        end
        
        function initUiEditYMaxCas(this)
            
             this.uiEditYMaxCas = mic.ui.common.Edit(...
                'cType', 'd', ...
                'fhDirectCallback', @this.onUiEditYMaxCas, ...
                'cLabel', 'Y Max (nm)' ...
            );
            this.uiEditYMaxCas.setMin(0)
            this.uiEditYMaxCas.set(50);
            
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
            this.uiEditTimeMin.set(0);
            this.uiEditTimeMax.set(this.uiEditNumOfSamples.get())
            
        end
        
        function onUiEditTimeMin(this, src, evt)
            
            if isempty(this.uiEditTimeMax)
                return
            end
            
            % Make sure max is not less than min
            if this.uiEditTimeMax.get() <= this.uiEditTimeMin.get()
                this.uiEditTimeMax.set(this.uiEditTimeMin.get() + 1)
            end
            
            if ~this.uiTogglePlayPause.get() % paused
                % Need to update since CAS band has changed
                this.updateAxes()
            end
            
            this.updateAxesLabels();
            
        end
        
        
        function onUiEditTimeMax(this, src, evt)
            
            if isempty(this.uiEditTimeMin)
                return
            end
            
            
            % Make sure min is not > max
            if this.uiEditTimeMin.get() >= this.uiEditTimeMax.get()
                this.uiEditTimeMin.set(this.uiEditTimeMax.get() - 1)
            end
            
            if ~this.uiTogglePlayPause.get() % paused
                % Need to update since CAS band has changed
                this.updateAxes()
            end
            this.updateAxesLabels();
            
        end
        
        function onUiEditYMinCas(this, src, evt)
            
            if isempty(this.uiEditYMaxCas)
               return 
            end
            
            % Make sure max is not less than min
            if this.uiEditYMaxCas.get() < this.uiEditYMinCas.get()
                this.uiEditYMaxCas.set(this.uiEditYMinCas.get() + 1)
            end
            
            if ~this.uiTogglePlayPause.get() % paused
                % Need to update since CAS band has changed
                this.updateAxes()
            end
            
            this.updateAxesLabels();
            
            
        end
        
        function onUiEditYMaxCas(this, src, evt)
            
            if isempty(this.uiEditYMinCas)
                return
            end
            
            
            % Make sure min is not > max
            if this.uiEditYMinCas.get() > this.uiEditYMaxCas.get()
                this.uiEditYMinCas.set(this.uiEditYMaxCas.get() - 1)
            end
            
            if ~this.uiTogglePlayPause.get() % paused
                % Need to update since CAS band has changed
                this.updateAxes()
            end
            this.updateAxesLabels();
            
        end
        
        
        
        function onUiEditFreqMin(this, src, evt)
            
            if isempty(this.uiEditFreqMax)
                return
            end
            
            % Make sure max is not less than min
            if this.uiEditFreqMax.get() < this.uiEditFreqMin.get()
                this.uiEditFreqMax.set(this.uiEditFreqMin.get())
            end
            
            if ~this.uiTogglePlayPause.get() % paused
                % Need to update since CAS band has changed
                this.updateAxes()
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
            
            if ~this.uiTogglePlayPause.get() % paused
                % Need to update since CAS band has changed
                this.updateAxes()
            end
            this.updateAxesLabels();
            
        end
        
        
        % Returns a list of z channels to plot based on checkboxes
        function d = getChannelsHeightSensor(this)
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
        
        
        % Returns a list of z channels to plot based on checkboxes
        function d = getChannelsHeightSensorRaw(this)
            d = [];
            
            % Put these in visual order so plot legend is same order as
            % visual order
            
            %{
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
            %}
            
            lSelected = [...
                ... % 0 us - 500 us
                this.uiCheckboxCh6T1.get(), ...
                this.uiCheckboxCh6B1.get(), ...
                this.uiCheckboxCh5T1.get(), ...
                this.uiCheckboxCh5B1.get(), ...
                this.uiCheckboxCh4T1.get(), ...
                this.uiCheckboxCh4B1.get(), ...
                this.uiCheckboxCh3T1.get(), ...
                this.uiCheckboxCh3B1.get(), ...
                this.uiCheckboxCh2T1.get(), ...
                this.uiCheckboxCh2B1.get(), ...
                this.uiCheckboxCh1T1.get(), ...
                this.uiCheckboxCh1B1.get(), ...
                ... % 500 us - 1000 us
                this.uiCheckboxCh6T2.get(), ...
                this.uiCheckboxCh6B2.get(), ...
                this.uiCheckboxCh5T2.get(), ...
                this.uiCheckboxCh5B2.get(), ...
                this.uiCheckboxCh4T2.get(), ...
                this.uiCheckboxCh4B2.get(), ...
                this.uiCheckboxCh3T2.get(), ...
                this.uiCheckboxCh3B2.get(), ...
                this.uiCheckboxCh2T2.get(), ...
                this.uiCheckboxCh2B2.get(), ...
                this.uiCheckboxCh1T2.get(), ...
                this.uiCheckboxCh1B2.get(), ...
                ... % 0 us - 1000 us
                this.uiCheckboxCh6T.get(), ...
                this.uiCheckboxCh6B.get(), ...
                this.uiCheckboxCh5T.get(), ...
                this.uiCheckboxCh5B.get(), ...
                this.uiCheckboxCh4T.get(), ...
                this.uiCheckboxCh4B.get(), ...
                this.uiCheckboxCh3T.get(), ...
                this.uiCheckboxCh3B.get(), ...
                this.uiCheckboxCh2T.get(), ...
                this.uiCheckboxCh2B.get(), ...
                this.uiCheckboxCh1T.get(), ...
                this.uiCheckboxCh1B.get() ...
            ];
            
            dIndexes = 1 : 36;
            d = dIndexes(lSelected);
                        
        end
        
        
        
        function d = getChannelsDmiRaw(this)
            
            d = [];
            if this.uiCheckboxUReticle.get()
                d(end + 1) = 1;
            end
            
            if this.uiCheckboxVReticle.get()
                d(end + 1) = 2;
            end
            
            if this.uiCheckboxUWafer.get()
                d(end + 1) = 3;
            end
            
            if this.uiCheckboxVWafer.get()
                d(end + 1) = 4;
            end
            
        end
        
        function d = getChannelsDmi(this)
            
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
            
            if this.uiCheckboxDriftX.get()
                d(end + 1) = 5;
            end
            
            if this.uiCheckboxDriftY.get()
                d(end + 1) = 6;
            end
            
        end
        
        function onUiListChange(this, src, evt)
            this.updateFromFileSelectedInList()
        end
        
        function onUiButtonLoad(this, src, evt)
            this.updateFromFileSelectedInList()
        end
        
        
        % @param {} samples - see this.samples
        % @param {char 1 x m} cPath - full path to file to save 
        function saveSamplesToFile(this, samples, cPath)
            
            % Open a file for writing
            u8FildId = fopen(cPath, 'w');
            
            % Write header
            fprintf(...
                u8FildId, ...
                [...
                    '6T1,6B1,5T1,5B1,4T1,4B1,3T1,3B1,2T1,2B1,1T1,1B1,', ...
                    '6T2,6B2,5T2,5B2,4T2,4B2,3T2,3B2,2T2,2B2,1T2,1B2,', ...
                    'DMI1,DMI2,DMI3,DMI4', ...
                    '\n' ...
                ] ...
            );
            
            % Samples.get() is zero-indexed since implementing java
            % ArrayList interface
            for n = 0 : samples.size() - 1
                hsraw = samples.get(n).getHsData();
                dmi = samples.get(n).getDmiData();
                
                hsraw = hsraw';
                dmi = dmi';
                
                fprintf(...
                    u8FildId, ...
                    [...
                        '%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,', ...
                        '%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,', ...
                        '%i,%i,%i,%i' ...
                    ], ...
                    [hsraw dmi] ...
                ); 
                if n < samples.size() - 1
                    fprintf(u8FildId, '\n');
                end
            end
            
            fclose(u8FildId);
            
        end
        
        function onUiButtonSave(this, src, evt)
            
            lPlayingOnSave = this.uiTogglePlayPause.get();
            
            if lPlayingOnSave
                this.uiTogglePlayPause.set(false); % pause
            end
            % Allow the user to change the suggested filename
            
            cNameSuggested = datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local');
            cPrompt = { 'Save As (do not add .txt):' };
            cTitle = 'Save As:';
            u8Lines = [1 50];
            cDefaultAns = { cNameSuggested };
            ceAnswer = inputdlg(...
                cPrompt, ...
                cTitle, ...
                u8Lines, ...
                cDefaultAns ...
            );
        
            if isempty(ceAnswer)
                return
            end
 
            cPathOfDir = mic.Utils.path2canonical(this.uiListDir.getDir());

            if ~isdir(cPathOfDir)
                mkdir(cPathOfDir)
            end
            
            cNameOfFile = [ceAnswer{1}, '.txt']; 
            cPath = fullfile(cPathOfDir, cNameOfFile);
                                    
            this.saveSamplesToFile(this.samples, cPath); 
            this.uiListDir.refresh();
            
            if lPlayingOnSave
                this.uiTogglePlayPause.set(true); % resume acquisition
            end
            
        end
        
        function onUiTogglePlayPause(this, src, evt)
                        
            if this.uiTogglePlayPause.get() % says pause (playing) so make sure the clock task is added
                
                if ~isempty(this.clock) && ...
                   ~this.clock.has(this.id())
                    this.clock.add(@this.onClock, this.id(), this.dDelay);
                    return;
                end
            
            end
            
            
            if ~this.uiTogglePlayPause.get() % says play so paused
                
                % Clean up clock tasks
                if ~isempty(this.clock) && ...
                    isvalid(this.clock) && ...
                    this.clock.has(this.id())
                    this.msg('delete() removing clock task', this.u8_MSG_TYPE_INFO); 
                    this.clock.remove(this.id());
                    return;
                end
                
                
            end
            
            
        end
        
        function onUiCheckbox(this, src, evt)
            
            if ~this.uiTogglePlayPause.get() % paused
                this.updateAxes()
            end
        end
        
        
        
    end
    
    
end

