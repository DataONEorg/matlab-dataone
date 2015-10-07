function csvwrite(source, varargin)
% CSVWRITE Write a comma-separated value file.
%   CSVWRITE(FILENAME,M) writes matrix M into FILENAME as 
%   comma-separated values.
%
%   CSVWRITE(FILENAME,M,R,C) writes matrix M starting at offset 
%   row R, and column C in the file.  R and C are zero-based, so that
%   R=0 and C=0 specifies first number in the file.
%
%   Notes:
%   
%   * CSVWRITE terminates each line with a line feed character and no
%     carriage return.
%
%   * CSVWRITE writes a maximum of five significant digits.  For greater
%     precision, call DLMWRITE with a precision argument.
%
%   * CSVWRITE does not accept cell arrays for the input matrix M. To
%     export cell arrays to a text file, use low-level functions such as
%     FPRINTF.
%
%   See also CSVREAD, DLMREAD, DLMWRITE.

% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2015 DataONE
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

    disp('Called the csvwrite wrapper function.');

    % Remove wrapper ncwrite from the Matlab path
    overloadedFunctPath = which('csvwrite');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    disp('remove the path of the overloaded csvwrite function.');  
    
    % Call csvwrite
    csvwrite( source, varargin{:} );
   
    % Add the wrapper csvwrite back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    disp('add the path of the overloaded csvwrite function back.');
    
    % Identifiy the file being used and add a prov:wasGeneratedBy statement 
    % in the RunManager DataPackage instance

    import org.dataone.client.run.RunManager;
    import java.net.URI;
    
    runManager = RunManager.getInstance();   
   
    exec_output_id_list = runManager.getExecOutputIds();

    fullSourcePath = which(source);
    if isempty(fullSourcePath)
        [status, struc] = fileattrib(source);
        fullSourcePath = struc.Name;
    end
    
    exec_output_id_list.put(fullSourcePath, 'text/csv');

end