varAttribStruct.validmin = {'Longitude' [10]};
cdfwrite('example', {'Longitude' 0:360}, 'VariableAttributes', varAttribStruct);
delete('example.cdf');