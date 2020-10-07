t = timer(...
    'TimerFcn', @onTimer, ...
    'StartFcn', @onStart, ...
    'StopFcn', @onStop, ...
    'ErrorFcn', @onError, ...
    'StartDelay', 0.5, ...
    ...'Period', period, ...
    'ExecutionMode', 'singleshot', ...
    'Name', 'Test-Clock' ...
);

start(t);


function onStop(t, evt)
    fprintf('timer stopped\n')
    fprintf('timer.TasksExecuted %1.0f\n', t.TasksExecuted);
    fprintf('timer restarting\n');
    start(t)
end

function onStart(t, evt)
    fprintf('timer started\n');
end

function onError(t, evt)
    fprintf('timer error\n')
end

function onTimer(t, evt)
    fprintf('timer executing\n');
end
