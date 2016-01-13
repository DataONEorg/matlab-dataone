%% @begin myScript2
%  @out myfile4.nc 
%  @out myncfile4.nc

%% @begin generate_pi_file
%  @out myfile4.nc

nccreate('myfile02.nc','pi');
ncwrite('myfile02.nc','pi',3.1);
ncwriteatt('myfile02.nc','/','creation_time',datestr(now));
% overwrite existing data
ncwrite('myfile02.nc','pi',3.1416);
ncdisp('myfile02.nc');
%% @end generate_pi_file
delete('myfile02.nc');
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