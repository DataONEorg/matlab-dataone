% This script is used to track down the issue of the command 'load'
% returning variables
disp('Contents of workspace before loading file:')
whos

disp('Contents of gong.mat:')
whos('-file','gong.mat')

load1('gong.mat');
Fs
y
disp('Contents of workspace after loading file:')
whos

% Load the coastline
load1('coast.mat');
xlon = long;
ylat = lat;