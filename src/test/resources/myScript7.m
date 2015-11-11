data = cdfread('example.cdf');
data = cdfread('example.cdf',  'Variables', {'Time'});
data = cdfread('example.cdf', 'CombineRecords', true, 'ConvertEpochToDatenum', true);
data{1}
data{2}
data{3}