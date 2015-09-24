%% @begin myScript2
%  @out myfile4.nc 
%  @out myncfile4.nc

%% @begin generate_pi_file
%  @out myfile4.nc

nccreate('myfile4.nc','pi');
ncwrite('myfile4.nc','pi',3.1);
ncwriteatt('myfile4.nc','/','creation_time',datestr(now));
% overwrite existing data
ncwrite('myfile4.nc','pi',3.1416);
ncdisp('myfile4.nc');
%% @end generate_pi_file


%% @begin generate_second_file
%  @out myncfile4.nc

nccreate('myncfile4.nc','vmark',...
         'Dimensions', {'time', inf, 'cols', 6},...
         'ChunkSize',  [3 3],...
         'DeflateLevel', 2);
ncwrite('myncfile4.nc','vmark', eye(3),[1 1]);
varData = ncread('myncfile4.nc','vmark');
disp(varData);
ncwrite('myncfile4.nc','vmark',fliplr(eye(3)),[1 4]);
varData = ncread('myncfile4.nc','vmark');
disp(varData);
%% @end generate_second_file

%% @end myScript2