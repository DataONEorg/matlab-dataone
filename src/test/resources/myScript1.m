% Example from http://apdrc.soest.hawaii.edu/tutorials/matlab_ncread.php

% Load the coastline
load coast
xlon = long;
ylat = lat;
% Find the indexes for 165W-153W, 18N-24N, and Oct 3, 2004.
lon = ncread('http://apdrc.soest.hawaii.edu/dods/public_data/NLOM/nlom_ssh', 'lon');
lat = ncread('http://apdrc.soest.hawaii.edu/dods/public_data/NLOM/nlom_ssh', 'lat');
time = ncread('http://apdrc.soest.hawaii.edu/dods/public_data/NLOM/nlom_ssh', 'time');
I = find(lon >= 195 & lon <= 207);
J = find(lat >= 18 & lat <= 24);
% Note: datenum and datevec use the time since Jan 0, 0000. 
% We need to add 365 days to fix the dataset
% because this dataset uses since Jan 1, 0001.
% datevec(time(1)+365) = [2002 6 1 0 0 0] {start time: Jun 1, 2002}
% datevec(mytime+365) = [2004 10 3 0 0 0] {my time: Oct 3, 2004}
mytime = datenum([2004 10 3 0 0 0])-365;
K = find(time == mytime);
% Load the NLOM sea surface height from the above information
ssh=ncread('http://apdrc.soest.hawaii.edu/dods/public_data/NLOM/nlom_ssh', 'ssh', [I(1) J(1) K], [I(end)-I(1)+1 J(end)-J(1)+1 1]);
figure
worldmap([lat(J(1)) lat(J(end))],[lon(I(1)) lon(I(end))])
setm(gca,'MapProjection','mercator')
gridm off
% Contour sea surface height
contourfm(lat(J),lon(I),ssh')
colorbar
% Plot land outlines
hold on
plotm(ylat,xlon,'k')
title('NLOM 1/16 degree Sea Surface Height [cm] October 3, 2004')
tightmap
