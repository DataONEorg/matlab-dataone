function m = csvread(source, varargin)
% CSVREAD Read a comma separated value file.
%   M = CSVREAD('FILENAME') reads a comma separated value formatted file
%   FILENAME.  The result is returned in M.  The file can only contain
%   numeric values.
%
%   M = CSVREAD('FILENAME',R,C) reads data from the comma separated value
%   formatted file starting at row R and column C.  R and C are zero-
%   based so that R=0 and C=0 specifies the first value in the file.
%
%   M = CSVREAD('FILENAME',R,C,RNG) reads only the range specified
%   by RNG = [R1 C1 R2 C2] where (R1,C1) is the upper-left corner of
%   the data to be read and (R2,C2) is the lower-right corner.  RNG
%   can also be specified using spreadsheet notation as in RNG = 'A1..B7'.
%
%   CSVREAD fills empty delimited fields with zero.  Data files where
%   the lines end with a comma will produce a result with an extra last 
%   column filled with zeros.
%
%   See also CSVWRITE, DLMREAD, DLMWRITE, LOAD, TEXTSCAN.

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

    import org.dataone.client.run.RunManager;
    
    runManager = RunManager.getInstance();   
 
    if ( runManager.configuration.debug)
        disp('Called the csvread wrapper function.');
    end
    
    % Remove wrapper csvread from the Matlab path
    overloadedFunctPath = which('csvread');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded csvread function.');  
    end
     
    % Call csvread 
    m = csvread( source, varargin{:} );
    
    % Add the wrapper csvread back to the Matlab path
    warning off MATLAB:dispatcher:nameConflict;
    addpath(overloaded_func_path, '-begin');
    warning on MATLAB:dispatcher:nameConflict;
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded csvread function back.');
    end
    
    % Identifiy the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_reads )
        formatId = 'text/csv';
        import org.dataone.client.v2.DataObject;

        fullSourcePath = which(source);
        if isempty(fullSourcePath)
            [status, struc] = fileattrib(source);
            fullSourcePath = struc.Name;
        end
    
        existing_id = runManager.execution.getIdByFullFilePath( ...
            fullSourcePath);
        if ( isempty(existing_id) )
            % Add this object to the execution objects map
            pid = char(java.util.UUID.randomUUID()); % generate an id
            dataObject = DataObject(pid, formatId, fullSourcePath);
            runManager.execution.execution_objects(dataObject.identifier) = ...
                dataObject;
        else
            % Update the existing map entry with a new DataObject
            pid = existing_id;
            dataObject = DataObject(pid, formatId, fullSourcePath);
            runManager.execution.execution_objects(dataObject.identifier) = ...
                dataObject;
        end
        
        if ( ~ ismember(pid, runManager.execution.execution_input_ids) )
            runManager.execution.execution_input_ids{end+1} = pid;
        end
    end
end