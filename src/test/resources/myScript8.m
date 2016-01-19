varAttribStruct.validmin = {'Longitude' [10]};
cdfwrite('tests/example', {'Longitude' 0:360}, 'VariableAttributes', varAttribStruct);
