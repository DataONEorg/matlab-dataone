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


%% @begin generate_second_file
%  @out myncfile4.nc

nccreate('myncfile02.nc','vmark',...
         'Dimensions', {'time', inf, 'cols', 6},...
         'ChunkSize',  [3 3],...
         'DeflateLevel', 2);
ncwrite('myncfile02.nc','vmark', eye(3),[1 1]);
varData = ncread('myncfile4.nc','vmark');
disp(varData);
ncwrite('myncfile02.nc','vmark',fliplr(eye(3)),[1 4]);
varData = ncread('myncfile02.nc','vmark');
disp(varData);
%% @end generate_second_file

% delete('myfile02.nc');
% delete('myncfile02.nc');
%% @end myScript2