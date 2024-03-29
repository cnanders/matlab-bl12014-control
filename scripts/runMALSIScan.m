% This script drives the wafer stage in X repeatedly to help lube the lead
% screw

% check if app is defined:
if ~exist('app','var')
    error('This script requires an instance of the app class to work.')
end


smarActMCS2Comm = app.hardware.getDCTWaferStage();

% define a lambda for setting and getting stage position:
setAxisPos  = @(u8Axis, dVal) smarActMCS2Comm.setPosition(1, u8Axis, dVal);
getAxisPos  = @(u8Axis) smarActMCS2Comm.getPosition(1, u8Axis);
lIsAxisReady = @(u8Axis) ~smarActMCS2Comm.getIsMoving(1, u8Axis);

getPos      = @() [smarActMCS2Comm.getPosition(1, 0), smarActMCS2Comm.getPosition(1, 1)];
setPos      = @(dPos1, dPos2) smarActMCS2Comm.setPosition(1, 0, dPos1); smarActMCS2Comm.setPosition(1, 1, dPos2);
lIsReady    = @() ~smarActMCS2Comm.getIsMoving(1, 0) && ~smarActMCS2Comm.getIsMoving(1, 1);


moveRelX = @(dX) setAxisPos(getAxisPos(0) + dX);
moveRelY = @(dY) setAxisPos(getAxisPos(1) + dY);



%% Determine the period of the stage
T = 0.8;  % 800 um;



%% Perform a scan:
N = 5;
rotation = 0;

% get the current position:
dPos = getPos();

% Create mesh starting here and going +T in X and Y:
xIdx = (0:N) * T/N; 
yIdx = (0:N) * T/N;

[X, Y] = meshgrid(xIdx, yIdx);

% Now rotate the mesh by rotation:
Xr = X * cos(rotation) - Y * sin(rotation);
Yr = X * sin(rotation) + Y * cos(rotation);


for k = 1:N+1
    for m = 1:N+1
        % move to the next position:
        setPos(dPos(1) + Xr(k,m), dPos(2) + Yr(k,m));
        
        % Display which index we are at:
        disp([k, m]);

        % Now wait for user input before continuing:
        figure('Name','Press any key to continue','NumberTitle','off');
        waitforbuttonpress;
        close(gcf);
        
    end
end
