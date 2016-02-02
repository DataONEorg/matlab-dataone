function save( source, varargin)
%function save( varargin )
% SAVE Save workspace variables to file. 
%   SAVE(FILENAME) stores all variables from the current workspace in a
%   MATLAB formatted binary file (MAT-file) called FILENAME.
%
%   SAVE(FILENAME,VARIABLES) stores only the specified variables.
%
%   SAVE(FILENAME,'-struct',STRUCTNAME,FIELDNAMES) stores the fields of the
%   specified scalar structure as individual variables in the file. If you 
%   include the optional FIELDNAMES, the SAVE function stores only the
%   specified fields of the structure.  You cannot specify VARIABLES and 
%   the '-struct' keyword in the same call to SAVE.
%
%   SAVE(FILENAME, ..., '-append') adds new variables to an existing file.
%   You can specify '-append' with additional inputs such as VARIABLES,
%   '-struct', FORMAT, or VERSION.
%
%   SAVE(FILENAME, ..., FORMAT) saves in the specified format: '-mat' or
%   '-ascii'.
%   You can specify FORMAT with additional inputs such as VARIABLES,
%   '-struct', '-append', or VERSION.
%
%   SAVE(FILENAME, ..., VERSION) saves to MAT-files in the specified
%   version: '-v4', '-v6', '-v7', or '-v7.3'.
%   You can specify VERSION with additional inputs such as VARIABLES,
%   '-struct', '-append', or FORMAT.
%
%   SAVE FILENAME ... is the command form of the syntax, for convenient 
%   saving from the command line.  With command syntax, you do not need to
%   enclose strings in single quotation marks.  Separate inputs with spaces
%   instead of commas.  Do not use command syntax if inputs such as 
%   FILENAME are variables.
%
%   Inputs:
%
%   FILENAME: If you do not specify FILENAME, the SAVE function saves to a
%   file named matlab.mat.  If FILENAME does not include an extension and 
%   the value of format is '-mat' (the default), MATLAB appends .mat. If 
%   filename does not include a full path, MATLAB saves in the current
%   folder. You must have permission to write to the file.
%
%   VARIABLES:  Save only selected variables from the workspace.
%   Use one of the following forms:
%
%       V1, V2, ...              Save the listed variables. Use the '*'
%                                wildcard to match patterns.  For example,
%                                save('A*') saves all variables that start
%                                with A.
%       '-regexp', EXPRESSIONS   Save only the variables that match the
%                                specified regular expressions. SAVE treats
%                                all inputs as regular expressions except
%                                the optional FILENAME and STRUCTNAME.  The
%                                FILENAME input must appear first.  For
%                                more information on regular expressions,
%                                type "doc regexp" at the command prompt.
%
%   '-struct', STRUCTNAME, FIELDNAMES:  Save the fields of a scalar
%   structure as individual variables in the file.  FIELDNAMES is optional; 
%   specify to save only selected fields.  FIELDNAMES use the same forms as
%   VARIABLES.
%
%   '-append': Add data to an existing file.  For MAT-files, '-append' adds
%   new variables to the file or replaces the saved values of existing
%   variables with values in the workspace.  For ASCII files, '-append'
%   adds data to the end of the file.
%
%   FORMAT: Specify the format of the file, regardless of any specified
%   extension.  Use one of the following combinations:
%
%       '-mat'                        Binary MAT-file format (default).
%       '-ascii'                      8-digit ASCII format.
%       '-ascii', '-tabs'             Tab-delimited 8-digit ASCII format.
%       '-ascii', '-double'           16-digit ASCII format.
%       '-ascii', '-double', '-tabs'  Tab-delimited 16-digit ASCII format.
%
%       For ASCII file formats, the SAVE function has the following
%       limitations:
%       * Each variable must be a two-dimensional double or char array.
%       * MATLAB translates characters to their corresponding internal
%         ASCII codes.  For example, 'abc' appears in an ASCII file as:
%             9.7000000e+001  9.8000000e+001  9.9000000e+001
%       * The output includes only the real component of complex numbers.
%       * If you plan to use the LOAD function to read the file, all
%         variables must have the same number of columns.
%
%   VERSION: Create a MAT-file that you can load into an earlier version of
%   MATLAB or that supports specific features.  The following table shows 
%   the available MAT-file version options and the corresponding supported
%   features.
%
%            | Can Load in  |
%   Option   | Versions     | Supported Features
%   ---------+--------------+----------------------------------------------
%   '-v7.3'  | 7.3 or later | Version 7.0 features plus support for
%            |              | data items greater than or equal to 2GB on
%            |              | 64-bit systems
%   ---------+--------------+----------------------------------------------
%   '-v7'    | 7.0 or later | Version 6 features plus data compression and
%            |              | Unicode character encoding
%   ---------+--------------+----------------------------------------------
%   '-v6'    | 5 or later   | Version 4 features plus N-dimensional arrays,
%            |              | cell and structure arrays, and variable names
%            |              | greater than 19 characters
%   ---------+--------------+----------------------------------------------
%   '-v4'    | all          | Two-dimensional double, character, and
%            |              | sparse arrays
%
%   If any data items require features that the specified version does not
%   support, MATLAB does not save those items and issues a warning. You 
%   cannot specify a version later than your version of MATLAB software.
%
%   To view or set the default version for MAT-files, select
%   File > Preferences > General > MAT-Files.
%
%   Examples:
%
%   % Save all variables from the workspace to test.mat:
%   save test.mat
%
%   % Save two variables, where FILENAME is a variable:
%   savefile = 'pqfile.mat';
%   p = rand(1, 10);
%   q = ones(10);
%   save(savefile, 'p', 'q');
%
%   % Save the fields of a structure as individual variables:
%   s1.a = 12.7;
%   s1.b = {'abc', [4 5; 6 7]};
%   s1.c = 'Hello!';
%   save('newstruct.mat', '-struct', 's1');
%
%   % Save variables whose names contain digits:
%   save myfile.mat -regexp \d
%
%   See also LOAD, MATFILE, WHOS, REGEXP, HGSAVE, SAVEAS, WORKSPACE, CLEAR.
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2016 DataONE
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
    
    if ( runManager.configuration.debug )
        disp('Called the save wrapper function.');
    end
    
    % Remove wrapper save from the Matlab path
    overloadedFunctPath = which('save');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded save function.');  
    end
   
    % ...
    option_array= {};
    input_struct = '';
    if length(varargin) == 0
        % Save all variables from the current workspace in a file
       
        % Grab all variables from caller workspace. Refenence:
        % http://stackoverflow.com/questions/1823668/is-there-a-way-to-push-a-matlab-workspace-onto-a-stack
        workspace_all_variables  = evalin('caller', 'whos');   
        names = {workspace_all_variables.name};
        in_struct = struct;
        for i = 1:numel(workspace_all_variables)
            evalin('caller', names{i} )
            in_struct.(names{i}) = evalin('caller', names{i} );
        end
        
        save(source, '-struct', 'in_struct');
        
    elseif length(varargin) > 0
        
        for i = 1:length(varargin) 
            if regexp(varargin{i}, '^-')
                % an option can be fmt
                % fmt: '-mat' (default) | '-ascii' | '-ascii','-tabs' | '-ascii','-double' | '-ascii','-double','-tabs'
                % version: '-v7.3' | '-v7' | '-v6' | '-v4'
                % -struct, structName
                % -struct, structName, field1, ..., fileldN
                % -struct, structName, '-regexp', expr1, ..., exprN
                
                if strcmp(varargin{i}, '-struct')                   
                    X = evalin('caller', varargin{i+1});
                    eval([varargin{i+1} '= X;']);
                end
                
                for j = i:length(varargin)
                    option_array{end+1} = varargin{j};
                end
                               
                break;
            else   
                if any(strfind(varargin{i}, '*'))
                    % Use the '*' wildcard to match patterns
                    workspace_all_variables  = evalin('caller', 'whos'); 
                    variable_names = {workspace_all_variables.name};
                    in_struct = struct;
                    for x = 1:numel(variable_names)
                        if any(regexp( variable_names{x},varargin{i} ))
                            input_struct.(variable_names{x}) = evalin('caller', variable_names{x});
                        end
                    end
                else
                    input_struct.(varargin{i}) = evalin('caller', varargin{i}); 
                end
                                                
            end
        end
        
        if ~isempty(input_struct)            
            save( source, '-struct', 'input_struct', option_array{:} ); 
        else
            save( source, option_array{:} ); 
        end
    end
    % ...

    %s = struct(varargin{:});
    %save( source, '-struct', 's' );
   
    % Add the wrapper save back to the Matlab path
    warning off MATLAB:dispatcher:nameConflict;
    addpath(overloaded_func_path, '-begin');
    warning on MATLAB:dispatcher:nameConflict;
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded save function back.');
    end
    
    % Identifiy the file being used and add a prov:wasGeneratedBy statement 
    % in the RunManager DataPackage instance
    if ( runManager.configuration.capture_file_writes )
        formatId = 'application/octet-stream';
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
        
        if ( ~ ismember(pid, runManager.execution.execution_output_ids) )
            runManager.execution.execution_output_ids{ ...
                end + 1} = pid;
        end
    end
end
