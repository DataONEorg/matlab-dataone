% Write a vector to a spreadsheet
filename = 'tests/testdata1.xlsx';
A = [12.7 5.02 -98 63.9 0 -.2 56];
xlswrite(filename,A);

% Write to specific sheet and range in a spreadsheet
filename = 'tests/testdata2.xlsx';
A = {'Time','Temperature'; 12,98; 13,99; 14,97};
sheet = 2;
xlRange = 'E1';
xlswrite(filename,A,sheet,xlRange)

