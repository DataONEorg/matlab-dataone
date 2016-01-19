M = [1,2,3,4, 5,6;
     7,8,9,10,11,12];

csvwrite('tests/data.csv', M);

data = textread('tests/data.csv', '', 'delimiter', ',', ... 
                'emptyvalue', NaN);

fclose('all');
delete('tests/data.csv');
            