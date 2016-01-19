m = [3 6 9 12 15; 5 10 15 20 25; ...
     7 14 21 28 35; 11 22 33 44 55];

csvwrite('tests/csvlist.dat',m);
csvwrite('tests/csvlist.dat',m,0,2);


fclose('all');
delete('tests/csvlist.dat');