function  appendValuesToLogFile(mp, cPath )
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
    
    channel_list = 0 : 47; % channels are zero-indexed, 48 channels
    [readings, channel_map] = mp.measure_multi(channel_list);
     
    for n = 1 : length(readings)
        fprintf(fid, '%1.8f,', readings(n));
        fprintf('%1.8f,', readings(n));
    end
    fprintf(fid, '\n');
    fprintf('\n');
    
    % close
    fclose(fid);
end

