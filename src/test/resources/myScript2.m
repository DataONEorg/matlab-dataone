nccreate('myfile3.nc','pi');
ncwrite('myfile3.nc','pi',3.1);
ncwriteatt('myfile3.nc','/','creation_time',datestr(now));
% overwrite existing data
ncwrite('myfile3.nc','pi',3.1416);
ncdisp('myfile3.nc');

nccreate('myncfile.nc','vmark',...
         'Dimensions', {'time', inf, 'cols', 6},...
         'ChunkSize',  [3 3],...
         'DeflateLevel', 2);
ncwrite('myncfile.nc','vmark', eye(3),[1 1]);
varData = ncread('myncfile.nc','vmark');
disp(varData);
ncwrite('myncfile.nc','vmark',fliplr(eye(3)),[1 4]);
varData = ncread('myncfile.nc','vmark');
disp(varData);
 