
% plot hs_accuracy


load('hs-accuracy.mat'); % populates data struct


z_wfz = data.z_wafer_fine_nm;
z_hs = data.z_height_sensor_nm;

% remove index shot

z_wfz = z_wfz(2 : end);
z_hs = z_hs(2 : end);

% remove dc

z_wfz = z_wfz - mean(z_wfz);
z_hs = z_hs - mean(z_hs);

z_diff = z_wfz - z_hs;
std_z_diff = std(z_diff);
% plot

figure
hold on
plot(z_wfz, '.-b');
plot(z_hs, 'o-r');
legend({'wafer fine z', 'height sensor'});
ylabel('nm')
xlabel('exposure')
title('wafer fine z and height sensor signals (DC removed)');


figure
plot(z_diff, '.-k');
cTitle = sprintf(...
    'wafer fine z - height sensor.  std = %1.1f nm', ...
    std_z_diff ...
);
title(cTitle);
ylabel('nm');
xlabel('exposure');
