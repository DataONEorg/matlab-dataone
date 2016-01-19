%% @begin myScript2
%  @out myfile4.nc 
%  @out myncfile4.nc

%% @begin generate_pi_file
%  @out myfile4.nc

nccreate('tests/myfile02.nc','pi');
ncwrite('tests/myfile02.nc','pi',3.1);
ncwriteatt('tests/myfile02.nc','/','creation_time',datestr(now));
% overwrite existing data
ncwrite('tests/myfile02.nc','pi',3.1416);
ncdisp('tests/myfile02.nc');
%% @end generate_pi_file

fclose('all');
delete('tests/myfile02.nc');
clear pi;

%% @begin generate_second_file
%  @out myncfile02

% nccreate('myncfile02.nc','vmark',...
%          'Dimensions', {'time', inf, 'cols', 6},...
%          'ChunkSize',  [3 3],...
%          'DeflateLevel', 2);
% ncwrite('myncfile02.nc','vmark', eye(3),[1 1]);
% varData = ncread('myncfile02.nc','vmark');
% disp(varData);
% ncwrite('myncfile02.nc','vmark',fliplr(eye(3)),[1 4]);
% varData = ncread('myncfile02.nc','vmark');
% disp(varData);
% delete('myncfile02.nc');
%% @end generate_second_file


%% @end myScript2