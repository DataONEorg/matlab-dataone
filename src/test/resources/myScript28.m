% Save data to ascii-file
a = magic(4);
b = ones(2,4)*-5.7;
c = [8 6 4 2];

disp('Calling the overloaded save() from the path: ');
which save

% Save data to ascii-file using command form
save  mydata.dat  a  b  c ;
delete mydata.dat;

filename1 = 'tests/mydata2.dat';
save( filename1,  'a',  'b', 'c', '-ascii' );

save  mydata.dat  a  b c -ascii;
delete mydata.dat;

%save  -ascii  mydata.dat  a  b c ;
%delete mydata.dat;

% Save structure fields as individual variables in mat-file
S.v_a = 10;
S.v_b = 20;
filename2 = 'tests/mydata.mat';

save(filename2, '-struct', 'S', 'v_a', 'v_b');
whos('-file', filename2);

% Save only fields whose names match the regular expressions, specified as
% strings
save(filename2, '-struct', 'S', '-regexp', 'v_*');
whos('-file', filename2);

save(filename2, '-struct', 'S', '-regexp', 'v_a');
whos('-file', filename2);

save(filename2, '-struct', 'S', '-regexp', '^v_a');
whos('-file', filename2);


save(filename2, '-struct', 'S', '-regexp', '^v');
whos('-file', filename2);

save(filename2, '-struct', 'S', '-regexp', 'v*');
whos('-file', filename2);

% Save variables to version 7.3 mat-file
A = rand(5);
B = magic(10);
save(filename2, 'A', 'B', '-v7.3');
filename2 = 'tests/mydata.mat';
whos('-file', filename2);

% Append variable to mat-file
p = rand(1,10);
q = ones(10);
save(filename2, 'p', 'q', '-append');
whos('-file', filename2);

% Save all workspace variables to mat-file
save(filename2);
whos('-file', filename2);

% Save the listed variables and use the '*' to match patterns
A1 = 30;
A2 = 40;
A3 = 50;

save(filename2, 'A*');
whos('-file', filename2);




