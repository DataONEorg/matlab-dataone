M = magic(3)*pi;
dlmwrite('myFile.txt',M,'delimiter','\t','precision',3);
M = magic(5);
N = magic(3);
dlmwrite('myFile.txt',M,'delimiter',' ');
dlmwrite('myFile.txt',N,'-append',...
            'delimiter',' ','roffset',1)

