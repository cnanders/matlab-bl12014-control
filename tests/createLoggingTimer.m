function t = createLoggingTimer( mp, cPath )
% @param { datatranslation.MeasurPoint 1x1} 
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

t = timer;
t.StartFcn = @startLoggingTimer;
t.TimerFcn = @(a, b)appendValuesToLogFile(mp, cPath);
t.StopFcn = @cleanupLoggingTimer;
t.Period = 60 * 5; % 5 min
t.ExecutionMode = 'fixedSpacing'; % means period seconds of rest between timer function finish and next call of timerFunction

end

