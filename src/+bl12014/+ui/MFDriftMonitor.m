classdef MFDriftMonitor < mic.Base
    
    properties

        uiHeightSensorChannels
        uiDMIChannels
        
        ceHeightSensorChannelNames = {'Height-Sensor-Z'}
        ceDMIChannelNames = {'DMI-X', 'DMI-Y'}
        
        
        
        
    end
    
    properties (SetAccess = private)
        
        dWidth = 600
        dHeight = 300
        
        cName = 'Drift monitor'
        
    end
    
    properties (Access = private)
        
        clock
        
        hPanel
        
        dWidthName = 150
        dWidthUnit = 80
        dWidthVal = 75
        dWidthPadUnit = 277
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = MFDriftMonitor(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        function init(this)
            % Init Height sensor:
            for k = 1:length(this.ceHeightSensorChannelNames)
                cPathConfig = fullfile(...
                    bl12014.Utils.pathUiConfig(), ...
                    'get-number', ...
                    sprintf('config-%s.json', this.ceHeightSensorChannelNames{k}) ...
                    );
                
                uiConfig = mic.config.GetSetNumber(...
                    'cPath',  cPathConfig ...
                    );
                
                this.uiHeightSensorChannels{k} = mic.ui.device.GetNumber(...
                    'clock', this.clock, ...
                    'dWidthName', this.dWidthName, ...
                    'dWidthUnit', this.dWidthUnit, ...
                    'dWidthVal', this.dWidthVal, ...
                    'dWidthPadUnit', this.dWidthPadUnit, ...
                    'cName', this.ceHeightSensorChannelNames{k}, ...
                    'config', uiConfig, ...
                    'cLabel', this.ceHeightSensorChannelNames{k} ...
                    );
            end
            
            % Init DMI sensor:
            for k = 1:length(this.ceDMIChannelNames)
                cPathConfig = fullfile(...
                    bl12014.Utils.pathUiConfig(), ...
                    'get-number', ...
                    sprintf('config-%s.json', this.ceDMIChannelNames{k}) ...
                    );
                
                uiConfig = mic.config.GetSetNumber(...
                    'cPath',  cPathConfig ...
                    );
                
                this.uiDMIChannels{k} = mic.ui.device.GetNumber(...
                    'clock', this.clock, ...
                    'dWidthName', this.dWidthName, ...
                    'dWidthUnit', this.dWidthUnit, ...
                    'dWidthVal', this.dWidthVal, ...
                    'dWidthPadUnit', this.dWidthPadUnit, ...
                    'cName', this.ceDMIChannelNames{k}, ...
                    'config', uiConfig, ...
                    'cLabel', this.ceDMIChannelNames{k} ...
                    );
            end
        end
        
        function setDevices(this)
            
            % bl12014.device.GetNumberFromMFDriftMonitor
        end
        function turnOn(this)
            for k = 1:length(this.uiHeightSensorChannels)
                this.uiHeightSensorChannels{k}.turnOn();
            end
            for k = 1:length(this.uiDMIChannels)
                this.uiDMIChannels{k}.turnOn();
            end
       
            
        end
        
        function turnOff(this)
            for k = 1:length(this.uiHeightSensorChannels)
                this.uiHeightSensorChannels{k}.turnOff();
            end
            for k = 1:length(this.uiDMIChannels)
                this.uiDMIChannels{k}.turnOff();
            end
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cName,...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;            

            dTop = 20;
            dLeft = 10;
            dSep = 40;
            
            for k = 1:length(this.uiHeightSensorChannels)
                this.uiHeightSensorChannels{k}.build(this.hPanel, dLeft, dTop);
                dTop = dTop + dSep;    
            end
            dTop = dTop + 15;
            for k = 1:length(this.uiDMIChannels)
                this.uiDMIChannels{k}.build(this.hPanel, dLeft, dTop);
                dTop = dTop + dSep;    
            end

            
        end
        
        function delete(this)
            
            this.msg('delete');
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end    
        
        
    end
    
    methods (Access = private)

         
       
        
    end
    
    
end

