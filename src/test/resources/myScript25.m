M = magic(3)*pi;
dlmwrite('tests/myFile.txt',M,'delimiter','\t','precision',3);
M = magic(5);
N = magic(3);
dlmwrite('tests/myFile.txt',M,'delimiter',' ');
dlmwrite('tests/myFile.txt',N,'-append',...
            'delimiter',' ','roffset',1)
fclose('all');
delete('tests/myFile.txt');