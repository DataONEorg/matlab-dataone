% Test save an ASCII-file
a = magic(4);
b=ones(2,4)*-5.7;
c=[8 6 4 2];
which save

save  mydata.dat  a  b  c ;
%save( 'mydata.dat',  'a',  'b', 'c' );
%save  mydata.dat  a  b c -ascii;