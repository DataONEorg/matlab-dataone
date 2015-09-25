%% @begin myScript2
%  @out myfile5.nc 
%  @out myncfile5.nc

%% @begin generate_pi_file
%  @out myfile5.nc

nccreate('myfile5.nc','pi');
ncwrite('myfile5.nc','pi',3.1);
ncwriteatt('myfile5.nc','/','creation_time',datestr(now));
% overwrite existing data
ncwrite('myfile5.nc','pi',3.1416);
ncdisp('myfile5.nc');
%% @end generate_pi_file


%% @begin generate_second_file
%  @out myncfile5.nc

nccreate('myncfile5.nc','vmark',...
         'Dimensions', {'time', inf, 'cols', 6},...
         'ChunkSize',  [3 3],...
         'DeflateLevel', 2);
ncwrite('myncfile5.nc','vmark', eye(3),[1 1]);
varData = ncread('myncfile5.nc','vmark');
disp(varData);
ncwrite('myncfile5.nc','vmark',fliplr(eye(3)),[1 4]);
varData = ncread('myncfile5.nc','vmark');
disp(varData);
%% @end generate_second_file

%% @end myScript2