LastName = {'Smith';'Johnson';'Williams';'Jones';'Brown'};
Age = [38;43;38;40;49];
Height = [71;69;64;67;64];
Weight = [176;163;131;133;119];
BloodPressure = [124 93; 109 77; 125 83; 117 75; 122 80];

T = table(Age,Height,Weight,BloodPressure,...
    'RowNames',LastName)
writetable(T,'myPatientData.dat','WriteRowNames',true)
type 'myPatientData.dat';

T = readtable('myPatientData.dat');

disp(T);

fclose('all');
delete('myPatientData.dat');