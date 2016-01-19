data1 = hdfread('example.hdf', 'Example SDS');

data = hdfread('example.hdf', 'MonthlyRain', 'Fields', 'TbOceanRain');

data = hdfread('example.hdf', 'MonthlyRain', 'Fields', 'TbOceanRain', 'Box', {[0 360], [0 90]});

