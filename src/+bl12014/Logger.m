classdef Logger < mic.Base
        
    properties (Constant)
         
        
    end
    
	properties (SetAccess = private)
        
        cName = 'logger-'
        
        % { char 1xm } - full path to log file
        cPath
        
        % { handle 1x1} - pointer to open log file during writing
        % fid
        
    end
    

    
    properties (Access = private)
        
        % {bl12014.Hardware 1x1}
        hardware
        
        % { mic.clock 1x1}
        clock
        
    end
    
        
    
    methods
        
        % Constructor
        function this = Logger(varargin)
            
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            
            [cDir, cName, cExt] = fileparts(mfilename('fullpath'));
            cDir = mic.Utils.path2canonical(fullfile(...
                cDir, ...
                '..', ...
                'save', ...
                'logger' ...
            ));
        
%             cDir = 'C:\Users\metmatlab\Documents\Logs\DataTranslation';
%             cName = 'log.csv';
%             cPath = fullfile(cDir, cName);

            mic.Utils.checkDir(cDir);
            this.cPath = fullfile(cDir, 'log.csv');
            this.init();
            
        end
    
        % Destructor
        function delete(this)
            
            if this.clock.has(this.id())
                this.clock.remove(this.id())
            end
        end
        
        
    end
    
    methods (Access = private)
        
        
        function init(this)
            
            
            this.createNewLogFile(this.cPath);
            
            % Show all MeasurePoint channel hardware types (These cannot be set)
            [tc, rtd, volt] = this.hardware.getDataTranslation().channelType();
            fprintf('DataTranslation MeasurPoint Hardware configuration:\n');
            fprintf('TC   sensor channels = %s\n',num2str(tc,'%1.0f '))
            fprintf('RTD  sensor channels = %s\n',num2str(rtd,'%1.0f '))
            fprintf('Volt sensor channels = %s\n',num2str(volt,'%1.0f '))

            this.clock.add(@this.onClock, this.id(), 5);
            
        end
        
        
        function onClock(this)
            
            this.appendValuesToLogFile(this.cPath);
            
        end
        
        function  createNewLogFile(this, cPath)
            
            %UNTITLED Summary of this function goes here
            %   Detailed explanation goes here
            % @param {< datatranslation.MeasurPoint 1x1}
            % @param {char 1xm} cPath - full path to the log file

            if exist(cPath, 'file') == 2
                return
            end

            try
                fid = fopen(cPath, 'w');
                % Write the header
                [tc, rtd, volt] = this.hardware.getDataTranslation().channelType();
                fprintf(fid, '# Hardware configuration:\n');
                fprintf(fid, '# TC sensor channels = %s\n', num2str(tc,'%1.0f '));
                fprintf(fid, '# RTD sensor channels = %s\n', num2str(rtd,'%1.0f '));
                fprintf(fid, '# Volt sensor channels = %s\n', num2str(volt,'%1.0f '));

                % write column headers
                fprintf(fid, '# serialdate,');
                % write channel names

                channels = 0 : 47;
                for n = 1 : length(channels)
                    fprintf(fid, 'ch %1.0f,', channels(n));
                end
                fprintf(fid, '\n');

                % write sensor types
                fprintf(fid, '# sensor type ,');
                channels = 0 : 7;
                for n = channels
                    fprintf(fid, 'J,');
                end

                channels = 8 : 15;
                for n = channels
                    fprintf(fid, 'PT1000,');
                end

                channels = 16 : 19;
                for n = channels
                    fprintf(fid, 'PT100,');
                end

                channels = 20 : 23;
                for n = channels
                    fprintf(fid, 'PT1000,');
                end

                channels = 24 : 31;
                for n = channels
                    fprintf(fid, 'PT100,');
                end
                fprintf(fid, '\n');
                
                channels = 32 : 47;
                for n = channels
                    fprintf(fid, 'NA,');
                end
                fprintf(fid, '\n');

                
                % close
                fclose(fid);
            catch
                if ~isempty(fid)
                    fclose(fid);
                end
            end
        end
        
        function  appendValuesToLogFile(this, cPath )
            
            %UNTITLED Summary of this function goes here
            %   Detailed explanation goes here
            % @param {timer 1x1} (needed since callack of timer)
            % @param {evemt 1x1} (needed since callback of timer)
            % @param {< datatranslation.MeasurPoint 1x1}
            % @param {char 1xm} cPath - full path to the log file

            if exist(cPath, 'file') ~= 2
                disp('File does not exist!');
                return

            end


            % open file in append mode
            fid = fopen(cPath, 'a');

            % append the serial date num.  
            % read this article 
            % https://www.mathworks.com/help/exlink/convert-dates-between-microsoft-excel-and-matlab.html

            fprintf('logging: ');

            fprintf(fid, '%1.8f,', now - 693960);
            fprintf('%1.8f,', now - 693960);


            readings = [];
            try

                channels = 0 : 7;
                readings = [readings this.hardware.getDataTranslation().measure_temperature_tc(channels, 'J')];

                channels = 8 : 15;
                readings = [readings this.hardware.getDataTranslation().measure_temperature_rtd(channels, 'PT1000')];

                channels = 16 : 19;
                readings = [readings this.hardware.getDataTranslation().measure_temperature_rtd(channels, 'PT100')];

                channels = 20 : 23;
                readings = [readings this.hardware.getDataTranslation().measure_temperature_rtd(channels, 'PT1000')];

                channels = 24 : 31;
                readings = [readings this.hardware.getDataTranslation().measure_temperature_rtd(channels, 'PT100')];

                channels = 32 : 47;
                readings = [readings this.hardware.getDataTranslation().measure_voltage(channels)];

                % Cannot use this original code because it assumes the default
                % sensor type, which cannot be stored on hardware, afaik

                % channel_list = 0 : 47; % channels are zero-indexed, 48 channels
                % [readings, channel_map] = this.hardware.getDataTranslation().measure_multi(channel_list);

                for n = 1 : length(readings)
                    fprintf(fid, '%1.8f,', readings(n));
                    fprintf('%1.8f,', readings(n));
                end
                fprintf(fid, '\n');
                fprintf('\n');


            catch mE
                disp('appendValuesToLogFile had an error');
            end

            % close
            fclose(fid);
        end
            

    end % private
    
    
end