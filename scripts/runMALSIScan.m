% This script drives the wafer stage in X repeatedly to help lube the lead
% screw

% check if app is defined:
if ~exist('app','var')
    error('This script requires an instance of the app class to work.')
end


comm = app.hardware.getDCTApertureStage();

% define a lambda for setting and getting stage position:
setAxisPos  = @(u8Axis, dVal) comm.goToPositionAbsolute(u8Axis, dVal);
getAxisPos  = @(u8Axis) comm.getPosition(u8Axis);

getPos      = @() [comm.getPosition(0), comm.getPosition(1), comm.getPosition(2)];
setPos      = @(dPos1, dPos2) {comm.goToPositionAbsolute(0, dPos1),  comm.goToPositionAbsolute(1, dPos2)};


moveRelX = @(dX) setAxisPos(getAxisPos(0) + dX);
moveRelY = @(dY) setAxisPos(getAxisPos(1) + dY);



%% Determine the period of the stage
T = 0.8 * sqrt(2) * 1e9;  % 1.13 um;



%% Perform a scan:
N = 7;
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
        setAxisPos(1, dPos(2) + Xr(k,m));
        setAxisPos(2,  dPos(3) + Yr(k,m))
        
        % Display which index we are at:
        disp([k, m]);
        
        % Now wait for user input before continuing:
        figure('Name',sprintf('[%d, %d]', k, m),'NumberTitle','off');
        % Specify the string you want to display
        str = sprintf('[%d, %d]', k, m);
        
        % Get current axes, or create one if it doesn't exist
        ax = gca;
        
        % Make sure the axes cover the whole figure
        ax.Position = [0 0 1 1];
        
        % Remove the axes ticks
        ax.XTick = [];
        ax.YTick = [];
        
        % Set the limits of the axes to [0 1] for both X and Y
        xlim([0 1]);
        ylim([0 1]);
        
        % Calculate the position to place the text (center of the figure)
        x = 0.5;
        y = 0.5;
        
        % Display the string in the middle of the figure with large text
        text(x, y, str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 96);
        
        % Turn off the axes so they don't interfere with the text appearance
        axis off;
        waitforbuttonpress;
        close(gcf);
        
    end
end
