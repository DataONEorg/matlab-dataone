M = [1,2,3,4, 5,6;
     7,8,9,10,11,12];

csvwrite('data.csv', M);

data = textread('data.csv', '', 'delimiter', ',', ... 
                'emptyvalue', NaN);

fclose('all');
delete('data.csv');
            