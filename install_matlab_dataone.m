
installFilePath = mfilename('fullpath');

% Add to Matlab path
warning off MATLAB:dispatcher:nameConflict;

% Add the toolbox to the permanent matlab path using the matlabrc.m file
% See http://www.mathworks.com/help/matlab/ref/matlabrc.html

% Open the matlabrc.m file for appending

% Add a section to the file that adds all matlab-dataone files in lib/matlab and
% src/matlab to the path

%addpath(genpath(pwd));

% Add the YW libraries to the dynamic java path

% close the file


warning off MATLAB:dispatcher:nameConflict;






% Add to the permanent java path
% Get the version of Matlab
matlabVersion = ver('MATLAB');

% Open the ~/.matlab/[R2015a]/javaclasspath.txt

% Add the <before> keyword

% For each library file, add a line to the file
jars = dir(fullfile('lib', 'java'));
for i=1:length(jars)
    javaaddpath([pwd '/lib/java/' jars(i).name]);
end
clear p i jars home_dir;

% Close the file

% Display a message to restart Matlab so the library changes will take
% effect

