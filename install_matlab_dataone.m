
installFilePath = mfilename('fullpath');
[mlt_dataone_root, name, ext] = fileparts(installFilePath);

if ispc
    userdir= getenv('USERPROFILE');
else
    userdir= getenv('HOME');
end

matlab_path = fullfile(userdir, '.matlab');

% Add to Matlab path
warning off MATLAB:dispatcher:nameConflict;

% Add the toolbox to the permanent matlab path using the matlabrc.m file
% See http://www.mathworks.com/help/matlab/ref/matlabrc.html

% Open the startup.m file for writing
startup_path = fullfile(matlab_path, 'startup.m');
mrc_fid = fopen(startup_path, 'w');

% Add a section to the file that adds all matlab-dataone files in lib/matlab and
% src/matlab to the path

lib_matlab_path = fullfile(mlt_dataone_root, 'lib', 'matlab');
fprintf(mrc_fid, '\naddpath(genpath(%s));\n', lib_matlab_path);    

src_matlab_dataone_path = fullfile(mlt_dataone_root, 'src', 'matlab');
fprintf(mrc_fid, 'addpath(genpath(%s));\n', src_matlab_dataone_path);      

% Add the YW libraries to the dynamic java path
yw_library_name = 'yesworkflow-0.2-SNAPSHOT.jar';
yw_library_path = fullfile(mlt_dataone_root, 'lib', 'java', yw_library_name);
fprintf(mrc_fid, 'javaaddpath(%s);\n', yw_library_path);

% close the file
fclose(mrc_fid);


warning off MATLAB:dispatcher:nameConflict;

% Add to the permanent java path
% Get the version of Matlab
matlabVersion = ver('MATLAB');


% Open the ~/.matlab/[R2015a]/javaclasspath.txt
javaclasspath_file_path = fullfile(matlab_path, matlabVersion.Release(2:end-1), 'javaclasspath.txt');
jcls_fid = fopen(javaclasspath_file_path, 'w');

% Add the <before> keyword
fprintf(jcls_fid, '%s\n', '<before>');

% For each library file, add a line to the file
jars = dir(fullfile('lib', 'java'));
for i=1:length(jars)
    if ~ismember(jars(i).name, {'.', '..', '.DS_Store'})
        path = [pwd '/lib/java/' jars(i).name];
        fprintf(jcls_fid, '%s\n', path);
    end
end
clear p i jars home_dir;

% Close the file
fclose(jcls_fid);

% Display a message to restart Matlab so the library changes will take
% effect
fprintf('\n\n Please restart Matlab so the library changes will take effect ...\n');
