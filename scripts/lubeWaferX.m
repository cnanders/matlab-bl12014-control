% This script drives the wafer stage in X repeatedly to help lube the lead
% screw

% check if app is defined:
if ~exist('app','var')
    error('This script requires an instance of the app class to work.')
end



X_LIMIT_MIN = -449;
X_LIMIT_MAX = 46;

% requires an instance of app to work:
ppComm = app.hardware.getDeltaTauPowerPmac();

% define a lambda for setting stage velocity:
setVel = @(vel) ppComm.setDemandSpeedWaferCoarse(vel);


% define a lambda for setting stage position:
setPos = @(pos) ppComm.setXWaferCoarse(pos);

% define a lambda for getting stage position:
getPos = @() ppComm.getXWaferCoarse();

%%


t0 = tic;

fprintf('Starting scan at %s.\n',datestr(now,'yyyy-mm-dd-HH-MM-SS'));

% Create a logfile for this scan. We'll use a csv file:
logFile = sprintf('lube-logs/lubeScan-%s.csv', datestr(now,'yyyy-mm-dd-HH-MM-SS'));
fid = fopen(logFile,'w');


numTrials = 400;
pollPeriod = 1;
velocity = 5;

% set velocity:
setVel(velocity);

for k = 1:numTrials

    adjustDirection = 1;
    if mod(k, 20) == 0

        if velocity == 5
            adjustDirection = 1;
        elseif velocity == 15
            adjustDirection = -1;
        end

        velocity = velocity + 5*adjustDirection;
        setVel(velocity);
    end


    % move to the left limit:
    pause(3);
    setPos(X_LIMIT_MIN);
    
    % wait until current pos and demand pos are separated by less than epsilon:
    ct = 0;
    while abs(getPos() - X_LIMIT_MIN) > 0.1
        pause(pollPeriod);

        % Wrtie a line in the csv file with a timestamp and the current position as well
        %  as number of seconds since the start of the scan:
        fprintf(fid,'%s,%f,%f,%f\n',datestr(now,'yyyy-mm-dd-HH-MM-SS'),toc(t0), velocity, getPos());

        % exit if counts is higher than a large number,say 2000:
        ct = ct + 1;
        if ct > 2000
            fprintf('Error: stage not moving.\n');
            break;
        end


        % Echo current pos every 5 cts::
        if mod(ct,5) == 0
            fprintf('Current position: %f\n',getPos());
        end
    end
    fprintf('At left limit.\n');

    % move to the right limit:
    pause(3);
    setPos(X_LIMIT_MAX);

    ct = 0;


    % wait until current pos and demand pos are separated by less than epsilon:
    while abs(getPos() - X_LIMIT_MAX) > 0.1
        pause(pollPeriod);
         % Wrtie a line in the csv file with a timestamp and the current position as well
        %  as number of seconds since the start of the scan:
        fprintf(fid,'%s,%f,%f,%f\n',datestr(now,'yyyy-mm-dd-HH-MM-SS'),toc(t0), velocity, getPos());

         % exit if counts is higher than a large number,say 2000:
         ct = ct + 1;
         if ct > 2000
             fprintf('Error: stage not moving.\n');
             break;
         end

          % Echo current pos every 5 cts::
        if mod(ct,5) == 0
            fprintf('Current position: %f\n',getPos());
        end
    end
    fprintf('At right limit.\n');

    % echo number of trials completed:
    fprintf('Completed %d of %d trials.\n',k,numTrials);

end

fprintf('Scan complete.\n');
fclose(fid);
