h5create('myfile.h5','/DS3',[20 Inf],'ChunkSize',[5 5]);
h5disp('myfile.h5');

for j = 1:10
    data = j*ones(20,1);
    start = [1 j];
    count = [20 1];
    h5write('myfile.h5','/DS3',data,start,count);
end

h5disp('myfile.h5');
h5disp('example.h5','/g4/lat');

delete('myfile.h5');