varAttribStruct.validmin = {'Longitude' [10]};
cdfwrite('example', {'Longitude' 0:360}, 'VariableAttributes', varAttribStruct);
fclose('all');
delete('example.cdf');