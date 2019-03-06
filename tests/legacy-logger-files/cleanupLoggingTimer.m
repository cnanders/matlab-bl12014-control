function cleanupLoggingTimer(t,~)
% @param {timer 1x1} t
disp('Deleting logging timer.')
delete(t)
end

