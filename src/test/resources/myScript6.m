M = dlmread('count.dat');
X = magic(3);
dlmwrite('tests/myfile.txt',[X*5 X/5],' ');
dlmwrite('tests/myfile.txt',X,'-append', ...
   'roffset',1,'delimiter',' ');

M = dlmread('tests/myfile.txt');
