m = [3 6 9 12 15; 5 10 15 20 25; ...
     7 14 21 28 35; 11 22 33 44 55];

csvwrite('src/test/csvlist.dat',m);
csvwrite('src/test/csvlist.dat',m,0,2);

