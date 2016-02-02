% This script is used to track down the issue of the command 'load'
% returning variables
disp('Display the file path of the load command');
which load;

disp('Contents of workspace before loading file:');
whos;


disp('Load all variables from the mat-file matlab.mat; otherwise returns an error');
load;
disp('Contents of matlab.mat before loading it:');
whos('-file', 'matlab.mat');
disp('Contents of workspace after loading file:');
whos

disp('Contents of gong.mat:');
whos('-file','gong.mat');

% Load a mat-file using syntax load('filename', 'X', 'Y', 'Z')
load('gong.mat', 'Fs');
disp('Load a mat-file using syntax load("filename", "X", "Y", "Z")');
clear Fs;

% Load variables that match any of the regular expression in exprlist from a mat-file 
load('gong.mat', '-regexp', '^F|^y|^a');
disp('Load a mat-file using syntax load("filename", "-regexp", exprlist)');
whos;
clear Fs y;

% Load variables that match any of the regular expression in exprlist from
% a mat-file in command form
whos
load gong.mat -regexp '^F';
disp('Load a mat-file using syntax load filename  -regexp  exprlist');
whos;
clear Fs;

% Load a mat-file using syntax load('-mat', 'filename')
load('-mat', 'gong.mat');
disp('Load a mat-file using syntax load("-mat", "filename")');
clear Fs y;

% Load a mat-file using syntax load('filename')
load('gong.mat');
disp('Load a mat-file using syntax load("filename"):');
clear Fs y;

% Load the coastline using syntax load('filename')
load('coast.mat');
disp('Load a mat-file using syntax load("filename")');
xlon = long;
ylat = lat;
clear xlon ylat;

% Load the coastline using syntax load filename
load coast.mat;
disp('Load a mat-file using syntax load filename');
xlon = long;
ylat = lat;
clear xlon ylat;

% Load the coastline using syntax load filename without extension
load coast;
disp('Load a mat-file using syntax load filename without extension');
xlon = long;
ylat = lat;
clear xlon ylat;

% 
% % Load the coastline using syntax S = load('filename')
% S = load('coast.mat');
% disp('Load a mat-file using syntax S=load("filename")');
% xlon = S.long;
% ylat = S.lat;
% clear xlon  ylat S;
% 
% 
% % Load the coastline using syntax S = load('filename')
% S = load('coast.mat', '-mat', 'lat', 'long');
% disp('Load a mat-file using syntax S=load("filename", "-mat", VARIABLES)');
% xlon = S.long;
% ylat = S.lat;
% clear xlon  ylat   S;


% Test load an ASCII-file
a = magic(4);
b=ones(2,4)*-5.7;
c=[8 6 4 2];
test_file_name = fullfile('tests', 'mydata.dat');
save( test_file_name, 'a', 'b', 'c', '-ascii');


% Load from an ascii file using syntax x = load('ascii-filename)');
disp('Load a ascii-file using syntax x = load("ascii-filename")');
xx=load(test_file_name);
xx
clear xx;

% Load from an ascii file using syntax load('ascii-filename)');
disp('Load a ascii-file using syntax load("ascii-filename")');
load(test_file_name );
mydata
clear mydata;

