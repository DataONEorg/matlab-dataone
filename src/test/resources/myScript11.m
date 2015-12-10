data1 = hdfread('example.hdf', 'Example SDS');
data1
data = hdfread('example.hdf', 'MonthlyRain', 'Fields', 'TbOceanRain');
data
data = hdfread('example.hdf', 'MonthlyRain', 'Fields', 'TbOceanRain', 'Box', {[0 360], [0 90]});
data
