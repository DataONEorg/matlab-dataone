ncid = netcdf.open('example.nc','NC_NOWRITE');
%ncid = netcdf.open('example.nc');
A_number = netcdf.getVar(ncid,0,'single');
whos A_number
netcdf.close(ncid);