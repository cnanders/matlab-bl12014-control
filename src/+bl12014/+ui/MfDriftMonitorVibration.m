classdef MfDriftMonitorVibration < mic.Base
    
    properties (Constant)
        
        cTabCooked = 'Cooked'
        cTabRaw = 'Raw'
        cTabRawHsOfFolder = 'Raw HS of Folder'
        
        
                        
    end
    
    properties (SetAccess = private)
        
        dWidth = 1710
        dHeight = 980
        
        dHeightList = 250
        
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
        
        uiButtonZeroDMI
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
        
        hParent
        
        % Cooked
        hAxesTime % amplitide vs. time
        hAxesPsd % power spectral density
        hAxesCas % cumulative amplitude spectrum
        
        
        hAxesTimeRaw % amplitide vs. time
        hAxesPsdRaw % power spectral density
        hAxesCasRaw % cumulative amplitude spectrum
        
       
        hAxesRawHsOfFolder
        
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
        
        % avg of cap1 and cap2
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
        
        
        uiCheckboxCh1TFolder
        uiCheckboxCh1BFolder
        uiCheckboxCh2TFolder
        uiCheckboxCh2BFolder
        uiCheckboxCh3TFolder
        uiCheckboxCh3BFolder
        uiCheckboxCh4TFolder
        uiCheckboxCh4BFolder
        uiCheckboxCh5TFolder
        uiCheckboxCh5BFolder
        uiCheckboxCh6TFolder
        uiCheckboxCh6BFolder
  
        uiCheckboxRemoveDCFolder
        uiCheckboxDeltasFolder
        
        
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
        dRawHsOfFolder = zeros(12, 1);
        
        % { bl12014.Hardware 1x1}
        hardware
        
        uiCheckboxAutoSave
        
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
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            if ~isa(this.clock, 'mic.Clock') && ...
                ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock or mic.ui.Clock');
            end
            
            
            this.init();
        
        end
        
              
        function buildFigure(this)
            
            dScreenSize = get(0, 'ScreenSize');

            this.hParent = figure( ...
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
                'Parent', this.hParent,...
                'Units', 'pixels',...
                'Title', 'Save / Load',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidthPanel ...
                dHeight], this.hParent) ...
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
                'Parent', this.hParent,...
                'Units', 'pixels',...
                'Title', 'Time Settings',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidthPanel ...
                dHeight], this.hParent) ...
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
                'Parent', this.hParent,...
                'Units', 'pixels',...
                'Title', 'CAS Settings',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidthPanel ...
                dHeight], this.hParent) ...
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
            
            hPanel = this.uiTabGroupAxes.getTabByName(this.cTabCooked);
            
            dLeft = this.dWidthPadLeftAxes;
            dTop = this.dHeightPadTopAxes;
            
            this.hAxesTime = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], hPanel),...
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
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], hPanel),...
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
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], hPanel),...
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
            
            hPanel = this.uiTabGroupAxes.getTabByName(this.cTabRaw);
            
            dLeft = this.dWidthPadLeftAxes;
            dTop = this.dHeightPadTopAxes;
            
            this.hAxesTimeRaw = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], hPanel),...
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
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], hPanel),...
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
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, this.dHeightAxes], hPanel),...
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
        
        
        function buildTabRawHsOfFolder(this)
            
            hPanel = this.uiTabGroupAxes.getTabByName(this.cTabRawHsOfFolder);
            
            dLeft = this.dWidthPadLeftAxes;
            dTop = this.dHeightPadTopAxes;
            
            this.hAxesRawHsOfFolder = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([dLeft, dTop, this.dWidthAxes, 500], hPanel),...
                'HandleVisibility', 'on', ...
                'XMinorTick','on', ...
                'YMinorTick','on', ...
                'XMinorGrid','on', ...
                'YMinorGrid','on', ...
                'XGrid','on', ...
                'YGrid','on' ... 
            );
            
            dTop = dTop + this.dHeightAxes + this.dHeightPadTopAxes;
            
            drawnow;
            
            dLeft = this.dWidthAxes + this.dWidthPadLeftAxes + this.dWidthPadLeftCheckboxes;
            dTop = this.dHeightPadTopTabGroup;
            dSep = 20;
            
            
            dWidth = 160;
            dHeightPadChannel = 5;
            dHeightPadGroup = 20; %cap1 vs. cap 2 vs dmi
            dHeight = 15;
            dSep = 15;
            cecProps = {
                'uiCheckboxCh1TFolder', ...
                'uiCheckboxCh1BFolder', ...
                'uiCheckboxCh2TFolder', ...
                'uiCheckboxCh2BFolder', ...
                'uiCheckboxCh3TFolder', ...
                'uiCheckboxCh3BFolder', ...
                'uiCheckboxCh4TFolder', ...
                'uiCheckboxCh4BFolder', ...
                'uiCheckboxCh5TFolder', ...
                'uiCheckboxCh5BFolder', ...
                'uiCheckboxCh6TFolder', ...
                'uiCheckboxCh6BFolder' ...
            };
        
            % Building the checkboxes for raw 
            
            for n = 1 : length(cecProps)
               cProp = cecProps{n};
               this.(cProp).build(hPanel, dLeft, dTop, dWidth, dHeight);
               dTop = dTop + dSep;
            end
            
            dTop = dTop + 30;
            this.uiCheckboxRemoveDCFolder.build(hPanel, dLeft, dTop, dWidth, dHeight);
            dTop = dTop + dSep;
            this.uiCheckboxDeltasFolder.build(hPanel, dLeft, dTop, dWidth, dHeight);

        end
        
        function build(this, hParent, dLeft, dTop) % , hParent, dLeft, dTop
                        
                   
            this.hParent = hParent;
            dTop = 20;
            dLeft = 10;
            dSep = 30;
            
            this.uiButtonZeroDMI.build(this.hParent, dLeft, dTop, 100, 24);
            
            dTop = dTop + 30;
            
            this.uiTogglePlayPause.build(this.hParent, dLeft, dTop, 100, 24);
            % dTop = dTop + dSep;
            
            dLeft = dLeft + 110;
            this.uiEditNumOfSamples.build(this.hParent, dLeft, dTop - 10, 150, 24);
            dTop = dTop + dSep;
            
            
            
            dLeft = 10;
            this.uiCheckboxAutoSave.build(this.hParent, dLeft, dTop, 200, 24);
            
            
            
            this.buildPanelSaveLoad();
            this.buildPanelCasSettings();
            this.buildPanelTimeSettings();
            
            
            % Tab Group
            dLeft = 300;
            dTop = 20;
            this.uiTabGroupAxes.build(this.hParent, dLeft, 10, this.dWidth - 320, this.dHeight - 40);
            this.buildTabCooked();
            this.buildTabRaw();
            this.buildTabRawHsOfFolder();
            
            dTop = 20;
            dLeft = 100 + this.dWidthAxes;
            dSep = 30;
            
           
            
            if ~isempty(this.clock)
                this.clock.add(...
                    @this.onClockWhilePlaying, ...
                    this.id(), ...
                    this.dDelay);
            
                this.clock.add(...
                    @this.refreshListDir, ...
                    [this.id(), 'refresh-list-dir'], ...
                    2 ...
                );
            end
            
        end
        
        function delete(this)
            
            this.msg('delete');
            
            % Clean up clock tasks
            if ~isempty(this.clock) && ...
                isvalid(this.clock) 
                
                this.msg('delete() removing clock task', this.u8_MSG_TYPE_INFO); 
                this.clock.remove(this.id());
                this.clock.remove([this.id(), 'refresh-list-dir']);
            end 
            
            
            
        end 
        
        
        
        function update(this)
            
            if ~ishghandle(this.hParent)
                return
            end
            
            this.samples = this.hardware.getMfDriftMonitor().getSampleData(this.uiEditNumOfSamples.get());
            
            this.dZ = bl12014.MfDriftMonitorUtilities.getHeightSensorZFromSampleData(this.samples);
            this.dXY = bl12014.MfDriftMonitorUtilities.getDmiPositionFromSampleData(this.samples);
                    
            this.dRawOfHeightSensor = bl12014.MfDriftMonitorUtilities.getRawOfHeightSensorFromSampleData(this.samples);
            this.dRawOfDmi = bl12014.MfDriftMonitorUtilities.getRawOfDmiFromSampleData(this.samples);
            
            % If on the raw folder tab  
            
            switch this.uiTabGroupAxes.getSelectedTabName()
                case this.cTabRawHsOfFolder
                    this.dRawHsOfFolder = this.getRawHsOfFolder();
            end
                    
            this.updateAxes();
            this.updateTexts();            
            
        end
        
        function saveLastNSamplesToFile(this, numSamples, cPath)
            this.saveSamplesToFile(this.hardware.getMfDriftMonitor().getSampleData(numSamples), cPath);
        end
        
        function updateTexts(this)
            
            switch this.uiTabGroupAxes.getSelectedTabName()
                case this.cTabCooked
                case this.cTabRaw
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
                case this.cTabCooked
                    this.updateAxesCooked(this.dZ, this.dXY);
                case this.cTabRaw
                    this.updateAxesRaw(this.dRawOfHeightSensor, this.dRawOfDmi);
                case this.cTabRawHsOfFolder
                    this.updateAxesRawHsOfFolder();
            end
        end
        
        
        function updateFromFileSelectedInList(this)
            
            this.uiTogglePlayPause.set(false); % pause so it shows "play"
            
            ceFiles = this.uiListDir.get(); % returns the selected file
            if isempty(ceFiles)
                return
            end
            
            cPathOfDir = mic.Utils.path2canonical(this.uiListDir.getDir());
            cPath = fullfile(cPathOfDir, ceFiles{1});
            
            ceData = bl12014.MfDriftMonitorUtilities.getDataFromLogFile(cPath);
            ceData = bl12014.MfDriftMonitorUtilities.removePartialsFromFileData(ceData);

            this.dZ = bl12014.MfDriftMonitorUtilities.getHeightSensorZFromFileData(ceData);
            this.dXY = bl12014.MfDriftMonitorUtilities.getDmiPositionFromFileData(ceData);
                    
            this.dRawOfHeightSensor = bl12014.MfDriftMonitorUtilities.getRawOfHeightSensorFromFileData(ceData);
            this.dRawOfDmi = bl12014.MfDriftMonitorUtilities.getRawOfDmiFromFileData(ceData);
                    
            this.updateAxes();
            this.updateTexts();
                                         
        end
        
        
        % Returns {double 12 x <files>} matrix where each column is the
        % mean raw value of HS channel data (cap1 + cap2 average) in a log file
        % Alternatively, thinking about each row of the matrix, you get the
        % change of, for example, CH1T through every log file.
        
        function dReturn = getRawHsOfFolder(this)
            
            cPathOfDir = mic.Utils.path2canonical(this.uiListDir.getDir());
            
            cSortBy = 'date';
            cSortMode = 'ascend';
            cFilter = '*.txt';
            cecFiles = mic.Utils.dir2cell(...
                cPathOfDir, ...
                cSortBy, ...
                cSortMode, ...
                cFilter ...
            );
        
            dReturn = zeros(12, length(cecFiles));
            
            for j = 1 : length(cecFiles)
                
                cPath = fullfile(cPathOfDir, cecFiles{j});
                
                ceData = bl12014.MfDriftMonitorUtilities.getDataFromLogFile(cPath);
                ceData = bl12014.MfDriftMonitorUtilities.removePartialsFromFileData(ceData);
                dRawHS = bl12014.MfDriftMonitorUtilities.getRawOfHeightSensorFromFileData(ceData);
                
                % return only the cap1 + cap2 averaged results which are in
                % rows 25 - 36 of the matrix returned by getRawOfHeightSensorFromFileData
                for n = 25 : 36
                    dReturn(n - 24, j) = mean(dRawHS(n, :));
                end
            end
             
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
        
        function l = areAxesRawHsOfFolderAvailable(this)
            l = true;
            if  isempty(this.hAxesRawHsOfFolder) || ...
                ~ishandle(this.hAxesRawHsOfFolder)
               
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
        
        
        function updateAxesRawHsOfFolder(this)
            
            if ~this.areAxesRawHsOfFolderAvailable()
                return
            end
            
            cla(this.hAxesRawHsOfFolder);
            
            cecLabels = {}; % Fill with plotted things
            cecLabelsZ = {...
                'ch6T CAP1,2 mean', ...
                'ch6B CAP1,2 mean', ...
                'ch5T CAP1,2 mean', ...
                'ch5B CAP1,2 mean', ...
                'ch4T CAP1,2 mean', ...
                'ch4B CAP1,2 mean', ...
                'ch3T CAP1,2 mean', ...
                'ch3B CAP1,2 mean', ...
                'ch2T CAP1,2 mean', ...
                'ch2B CAP1,2 mean', ...
                'ch1T CAP1,2 mean', ...
                'ch1B CAP1,2 mean' ...
            };
                        
            lSelected = [...
                this.uiCheckboxCh6TFolder.get(), ...
                this.uiCheckboxCh6BFolder.get(), ...
                this.uiCheckboxCh5TFolder.get(), ...
                this.uiCheckboxCh5BFolder.get(), ...
                this.uiCheckboxCh4TFolder.get(), ...
                this.uiCheckboxCh4BFolder.get(), ...
                this.uiCheckboxCh3TFolder.get(), ...
                this.uiCheckboxCh3BFolder.get(), ...
                this.uiCheckboxCh2TFolder.get(), ...
                this.uiCheckboxCh2BFolder.get(), ...
                this.uiCheckboxCh1TFolder.get(), ...
                this.uiCheckboxCh1BFolder.get() ...
            ];
            
            dIndexes = 1:12;
            dChannelsHs = dIndexes(lSelected);
            
            for n = dChannelsHs
    
                channel = n;
                values = this.dRawHsOfFolder(channel, :);
                
                % dc removal
                if this.uiCheckboxRemoveDCFolder.get()
                    values = values - mean(values);
                end
                
                 % plot shot to shot deltas 
                if this.uiCheckboxDeltasFolder.get()
                   deltas = zeros(1, length(values) - 1); % initialize
                   for m = 2 : length(values)
                       deltas(m - 1) = values(m) - values(m - 1);
                   end
                   values = deltas;
                end
                
                plot(this.hAxesRawHsOfFolder, values', '.-')
                hold(this.hAxesRawHsOfFolder, 'on') % need to do after first loglog
                
                cecLabels{end + 1} = cecLabelsZ{channel};

            end

            legend(this.hAxesRawHsOfFolder, cecLabels);
            
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
                
        % Returns a {double 6xm} time series of height zensor z in nm of
        % all six channels
        % @param {ArrayList<SampleData> 1x1} samples - sample data
        % @return {double 24xm} - height sensor z (nm) of six channels at 1 kHz
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
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
           
            
        end
                
        
        function refreshListDir(this, src, evt)
            
            ceOptionsBefore = this.uiListDir.getOptions();
            this.uiListDir.refresh();
            ceOptionsAfter = this.uiListDir.getOptions();
            
            if length(ceOptionsAfter) > length(ceOptionsBefore)
            
                switch this.uiTabGroupAxes.getSelectedTabName()
                    case this.cTabRawHsOfFolder
                        this.dRawHsOfFolder = this.getRawHsOfFolder();
                        this.updateAxes();
                end
            end
        end
       
        function onClockWhilePlaying(this, src, evt)
            
            this.update();
            
            if this.uiCheckboxAutoSave.get() 
                
                cNameOfFile = datestr(datevec(now), 'yyyymmdd-HHMMSS.txt', 'local');
                cPathOfDir = mic.Utils.path2canonical(this.uiListDir.getDir());

                if ~isdir(cPathOfDir)
                    mkdir(cPathOfDir)
                end

                cPath = fullfile(cPathOfDir, cNameOfFile);

                this.saveSamplesToFile(this.samples, cPath); 
                this.uiListDir.refresh();
                
            end
            
        end
        
        function onUiTabGroupAxes(this, src, evt);
            
            switch this.uiTabGroupAxes.getSelectedTabName()
                case this.cTabRawHsOfFolder
                     this.uiTogglePlayPause.set(false); % pause so it shows "play"
                    this.dRawHsOfFolder = this.getRawHsOfFolder();
            end
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
        
        function initCheckboxesFolder(this)
            this.uiCheckboxCh1TFolder = mic.ui.common.Checkbox('cLabel', '1T 5:30 z', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh1BFolder = mic.ui.common.Checkbox('cLabel', '1B 5:30 z', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            
            this.uiCheckboxCh2TFolder = mic.ui.common.Checkbox('cLabel', '2T 9:30 z', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh2BFolder = mic.ui.common.Checkbox('cLabel', '2B 9:30 z', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh3TFolder = mic.ui.common.Checkbox('cLabel', '3T 1:30 z', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh3BFolder = mic.ui.common.Checkbox('cLabel', '3B 1:30 z', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh4TFolder = mic.ui.common.Checkbox('cLabel', '4T 0:30 ang', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh4BFolder = mic.ui.common.Checkbox('cLabel', '4B 0:30 ang', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh5TFolder = mic.ui.common.Checkbox('cLabel', '5T 4:30 ang', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh5BFolder = mic.ui.common.Checkbox('cLabel', '5B 4:30 ang', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);

            this.uiCheckboxCh6TFolder = mic.ui.common.Checkbox('cLabel', '6T 8:30 ang', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox);
            this.uiCheckboxCh6BFolder = mic.ui.common.Checkbox('cLabel', '6B 8:30 ang', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox); 
            
            
            this.uiCheckboxRemoveDCFolder = mic.ui.common.Checkbox('cLabel', 'Remove DC', 'lChecked', true, 'fhDirectCallback', @this.onUiCheckbox); 
            this.uiCheckboxDeltasFolder = mic.ui.common.Checkbox('cLabel', 'Deltas', 'lChecked', false, 'fhDirectCallback', @this.onUiCheckbox); 
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
            
            % Axes tab group:
            this.uiTabGroupAxes = mic.ui.common.Tabgroup(...
                'fhDirectCallback', { ...
                    @this.onUiTabGroupAxes, ...
                    @this.onUiTabGroupAxes, ...
                    @this.onUiTabGroupAxes ...
                 } , ... % provide a callback for each tab!!
                'ceTabNames',  {...
                    this.cTabCooked, ...
                    this.cTabRaw, ...
                    this.cTabRawHsOfFolder ...
                } ...
            );
        
            this.initCheckboxesRaw();
            this.initCheckboxesFolder();
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
        
            this.uiCheckboxAutoSave = mic.ui.common.Checkbox(...
                'cLabel', 'Auto Save', ...
                'lChecked', false, ...
                'fhDirectCallback', @this.onUiCheckboxAutoSave ...
            );
            this.uiButtonSave = mic.ui.common.Button(...
                'cText', 'Save', ...
                'fhDirectCallback', @this.onUiButtonSave ...
            );
        
            this.uiButtonLoad = mic.ui.common.Button(...
                'cText', 'Load', ...
                'fhDirectCallback', @this.onUiButtonLoad ...
            );
        
           this.uiButtonZeroDMI = mic.ui.common.Button(...
               'cText', 'Zero DMI',...
               'fhDirectCallback', @(src, evt) this.hardware.getMfDriftMonitorMiddleware().setDMIZero() ...
           );

            cDirThis = fileparts(mfilename('fullpath'));

            cPath = mic.Utils.path2canonical(fullfile(cDirThis, '..', '..', 'save', 'hs-dmi'));
            this.uiListDir = mic.ui.common.ListDir(...
                'cDir', cPath, ...
                'cFilter', '*.txt', ...
                'lShowLabel', false, ...
                'lShowChooseDir', true, ...
                'fhOnChange', @this.onUiListChange, ...
                'fhOnChangeDir', @this.onUiListChangeDir, ...
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
        
        function onUiCheckboxAutoSave(this, ~, ~)
            
            % Dont do anything
            
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
        
        % Returns a list of z channels to plot based on checkboxes
        function d = getChannelsHeightSensorRawFolder(this)
            
            lSelected = [...
                ... % 0 us - 1000 us
                this.uiCheckboxCh6TFolder.get(), ...
                this.uiCheckboxCh6BFolder.get(), ...
                this.uiCheckboxCh5TFolder.get(), ...
                this.uiCheckboxCh5BFolder.get(), ...
                this.uiCheckboxCh4TFolder.get(), ...
                this.uiCheckboxCh4BFolder.get(), ...
                this.uiCheckboxCh3TFolder.get(), ...
                this.uiCheckboxCh3BFolder.get(), ...
                this.uiCheckboxCh2TFolder.get(), ...
                this.uiCheckboxCh2BFolder.get(), ...
                this.uiCheckboxCh1TFolder.get(), ...
                this.uiCheckboxCh1BFolder.get() ...
            ];
            
            dIndexes = 1:12;
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
         
        function onUiListChangeDir(this, src, evt)
            
            switch this.uiTabGroupAxes.getSelectedTabName()
                case this.cTabRawHsOfFolder
                    this.dRawHsOfFolder = this.getRawHsOfFolder();
                    this.updateAxes();
            end
            
        end
        
        function onUiListChange(this, src, evt)
            
            
            
            
            this.updateFromFileSelectedInList();
            
        end
        
        function onUiButtonLoad(this, src, evt)
            this.updateFromFileSelectedInList()
        end
        
        
        % @param {} samples - see this.samples
        % @param {char 1 x m} cPath - full path to file to save 
        function saveSamplesToFile(this, samples, cPath)
            
            % Open a file for writing
            u8FildId = fopen(cPath, 'w'); % upper case to suppress flushing
            
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
            
            dSize = samples.size();
            
            cFormat = [...
                '%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,', ...
                '%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,', ...
                '%i,%i,%i,%i' ...
            ];
            
            for n = 0 : dSize - 1
                hsraw = samples.get(n).getHsData();
                dmi = samples.get(n).getDmiData();
                
                %hsraw = hsraw';
                %dmi = dmi';
                %[hsraw dmi]
                data = [hsraw' dmi'];
                
                fprintf(...
                    u8FildId, ...
                    cFormat, ...
                    data ...
                ); 
                if n < dSize - 1
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
                    this.clock.add(@this.onClockWhilePlaying, this.id(), this.dDelay);
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

