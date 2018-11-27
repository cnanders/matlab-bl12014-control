    function  createNewLogFile( mp, cPath )
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
        [tc, rtd, volt] = mp.channelType();
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
 
 
 
        %{
        % write sensor types OLD
        fprintf(fid, '# ,');
        fprintf(fid, strjoin(mp.getSensorType(), ','));
        fprintf(fid, '\n');
        %}

        % close
        fclose(fid);
    catch
        if ~isempty(fid)
            fclose(fid);
        end
    end
end

