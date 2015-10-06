% Script. Read gridded lake bathymetry data from a csv file and compute lake
% area and volume as a function of lake level.

% define parameters
file = '~/Documents/matlab-dataone-exampels/quabbin.csv';
dx = 20; % m
dy = 20; % m
num_level = 10;
make_plot = 1; % 1 = on, 0 = off

% read in data
depth = csvread(file);

% get lake levels
level_min = -max(max(depth));
level_step = level_min/(num_level-1);
level = 0:level_step:level_min;

% create output variables
area = zeros(1, num_level);
vol = zeros(1, num_level);

% populate output variables
for i = 1:num_level

    % reduce level
    low = depth+level(i);
    wet = low>0;

    % compute area
    area(i) = sum(sum(wet))*dx*dy; % m^2

    % compute volume
    vol(i) = sum(low(wet))*dx*dy; % m^3
end

% plot, if enabled
if make_plot
    figure()

    subplot(1,2,1)
    plot(level,area/1e6);
    xlabel('Lake Level (m)');
    ylabel('Area (km^2)')

    subplot(1,2,2)
    plot(level,vol/1e9);
    xlabel('Lake Level (m)');
    ylabel('Volume (km^3)')
end