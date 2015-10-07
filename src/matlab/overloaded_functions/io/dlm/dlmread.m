function result = dlmread( source, varargin )
% DLMREAD Read ASCII delimited file.
%   RESULT = DLMREAD(FILENAME) reads numeric data from the ASCII
%   delimited file FILENAME.  The delimiter is inferred from the formatting
%   of the file.
%
%   RESULT = DLMREAD(FILENAME,DELIMITER) reads numeric data from the ASCII
%   delimited file FILENAME using the delimiter DELIMITER.  The result is
%   returned in RESULT.  Use '\t' to specify a tab.
%
%   When a delimiter is inferred from the formatting of the file,
%   consecutive whitespaces are treated as a single delimiter.  By
%   contrast, if a delimiter is specified by the DELIMITER input, any
%   repeated delimiter character is treated as a separate delimiter.
%
%   RESULT = DLMREAD(FILENAME,DELIMITER,R,C) reads data from the
%   DELIMITER-delimited file FILENAME.  R and C specify the row R and column
%   C where the upper-left corner of the data lies in the file.  R and C are
%   zero-based so that R=0 and C=0 specifies the first value in the file.
%
%   All data in the input file must be numeric. DLMREAD does not operate 
%   on files containing nonnumeric data, even if the specified rows and
%   columns for the read contain numeric data only.
%
%   RESULT = DLMREAD(FILENAME,DELIMITER,RANGE) reads the range specified
%   by RANGE = [R1 C1 R2 C2] where (R1,C1) is the upper-left corner of
%   the data to be read and (R2,C2) is the lower-right corner.  RANGE
%   can also be specified using spreadsheet notation as in RANGE = 'A1..B7'.
%
%   DLMREAD fills empty delimited fields with zero.  Data files where
%   the lines end with a non-whitespace delimiter will produce a result with
%   an extra last column filled with zeros.
%
%   See also DLMWRITE, CSVREAD, TEXTSCAN, LOAD.

% Obsolete syntax:
%   RESULT= DLMREAD(FILENAME,DELIMITER,R,C,RANGE) reads only the range specified
%   by RANGE = [R1 C1 R2 C2] where (R1,C1) is the upper-left corner of
%   the data to be read and (R2,C2) is the lower-right corner.  RANGE
%   can also be specified using spreadsheet notation as in RANGE = 'A1..B7'.
%   A warning will be generated if R,C or both don't match the upper
%   left corner of the RANGE.
%
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

    disp('Called the dlmread wrapper function.');

    % Remove wrapper dlmread from the Matlab path
    overloadedFunctPath = which('dlmread');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    disp('remove the path of the overloaded dlmread function.');  
    
    % Call dlmread 
    result = dlmread( source, varargin{:} );
  
    % Add the wrapper dlmread back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    
    disp('add the path of the overloaded dlmread function back.');
    
    % Identifiy the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance
  
    import org.dataone.client.run.RunManager;
    import java.net.URI;
    
    runManager = RunManager.getInstance();   
   
    exec_input_id_list = runManager.getExecInputIds();
    fullSourcePath = which(source);
    if isempty(fullSourcePath)
        [status, struc] = fileattrib(source);
        fullSourcePath = struc.Name;
    end
    
    % Todo: determine the object format for dlmread type
    exec_input_id_list.put(fullSourcePath, 'text/plain');
end