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
    
    import org.dataone.client.run.RunManager;
    
    runManager = RunManager.getInstance();   
    
    if ( runManager.configuration.debug)
        disp('Called the csvwrite wrapper function.');
    end
    
    % Remove wrapper csvwrite from the Matlab path
    overloadedFunctPath = which('csvwrite');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded csvwrite function.');  
    end
     
    % Call csvwrite
    csvwrite( source, varargin{:} );
   
    % Add the wrapper csvwrite back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded csvwrite function back.');
    end
    
    % Identifiy the file being used and add a prov:wasGeneratedBy statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_writes )
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
     
        runManager.execution.execution_output_ids{end+1} = pid;    
       
    end
end