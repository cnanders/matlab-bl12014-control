function startLoggingTimer(t,~)
% @param {timer 1x1} t
fprintf('starting logging timer with a period of %1.1f s\n', t.Period);
fprintf('timer has execution mode of %s\n', t.ExecutionMode);
end

