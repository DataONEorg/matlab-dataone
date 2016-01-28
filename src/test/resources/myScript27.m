% This script is used to track down the issue of the command 'load'
% returning variables
disp('Contents of workspace before loading file:');
whos;

disp('Contents of gong.mat:');
whos('-file','gong.mat');

% Load a matrix using syntax load('filename', 'X', 'Y', 'Z')
load('gong.mat', 'Fs');
disp('Load a matrix using syntax load("filename", "X", "Y", "Z")');
clear Fs;

% Load a matrix using syntax load('-mat', 'filename')
load('-mat', 'gong.mat');
disp('Load a matrix using syntax load("-mat", "filename")');
clear Fs, y;

% Load a matrix using syntax load('filename')
load('gong.mat');
disp('Load a matrix using syntax load("filename"):');
clear Fs, y;

% Load the coastline using syntax load('filename')
load('coast.mat');
disp('Load a matrix using syntax load("filename")');
xlon = long;
ylat = lat;
clear xlon, ylat;

% Load the coastline using syntax load filename
load coast.mat;
disp('Load a matrix using syntax load filename');
xlon = long;
ylat = lat;
clear xlon, ylat;

% Load the coastline using syntax load filename without extension
load coast;
disp('Load a matrix using syntax load filename without extension');
xlon = long;
ylat = lat;
clear xlon, ylat;


% Load the coastline using syntax S = load('filename')
S = load('coast.mat');
disp('Load a matrix using syntax S=load("filename")');
xlon = S.long;
ylat = S.lat;
clear xlon, ylat


% Load the coastline using syntax S = load('filename')
S = load('coast.mat', '-mat', 'lat', 'long');
disp('Load a matrix using syntax S=load("filename", "-mat", VARIABLES)');
xlon = S.long;
ylat = S.lat;
clear xlon, ylat


% Test load an ASCII-file
a = magic(4);
b=ones(2,4)*-5.7;
c=[8 6 4 2];
save -ascii mydata.dat 'a' 'b' 'c';

% Load from an ascii file using syntax x = load('ascii-filename)');
disp('Load a matrix using syntax x = load("ascii-filename")');
xx=load('mydata.dat');
xx
clear xx;

% Load from an ascii file using syntax load('ascii-filename)');
disp('Load a matrix using syntax load("ascii-filename")');
load('mydata.dat');
mydata
clear mydata

