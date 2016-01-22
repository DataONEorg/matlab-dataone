
values = {1, 2, 3 ; 4, 5, 'x' ; 7, 8, 9};
headers = {'First','Second','Third'};
xlswrite('tests/myExample.xlsx',[headers; values]);

% Read numeric data, text, raw data from worksheet
[num,txt,raw] = xlsread('tests/myExample.xlsx');

% Read range of cells
filename = 'tests/myExample.xlsx';
sheet = 1;
xlRange = 'B2:C3';
subsetA = xlsread(filename,sheet,xlRange);


% Read column
filename = 'tests/myExample.xlsx';
columnB = xlsread(filename,'B:B');





