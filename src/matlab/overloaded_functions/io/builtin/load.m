
function varargout = load( varargin )

% LOAD Load data from MAT-file into workspace.
%   S = LOAD(FILENAME) loads the variables from a MAT-file into a structure
%   array, or data from an ASCII file into a double-precision array.
%
%   S = LOAD(FILENAME, VARIABLES) loads only the specified variables from a
%   MAT-file.  VARIABLES use one of the following forms:
%
%       VAR1, VAR2, ...          Load the listed variables.  Use the '*'
%                                wildcard to match patterns.  For
%                                example, load('A*') loads all variables
%                                that start with A.
%       '-regexp', EXPRESSIONS   Load only the variables that match the
%                                specified regular expressions.  For more
%                                information on regular expressions, type
%                                "doc regexp" at the command prompt.
%
%   S = LOAD(FILENAME, '-mat', VARIABLES) forces LOAD to treat the file as
%   a MAT-file, regardless of the extension.  Specifying VARIABLES is
%   optional.
%
%   S = LOAD(FILENAME, '-ascii') forces LOAD to treat the file as an ASCII
%   file, regardless of the extension.
%
%   LOAD(...) loads without combining MAT-file variables into a structure
%   array.
%
%   LOAD ... is the command form of the syntax, for convenient loading from
%   the command line. With command syntax, you do not need to enclose input
%   strings in single quotation marks. Separate inputs with spaces instead 
%   of commas. Do not use command syntax if FILENAME is a variable.
%   
%   Notes:
%
%   If you do not specify FILENAME, the LOAD function searches for a file
%   named matlab.mat.
%
%   ASCII files must contain a rectangular table of numbers, with an equal
%   number of elements in each row.  The file delimiter (character between
%   each element in a row) can be a blank, comma, semicolon, or tab.  The
%   file can contain MATLAB comments.
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
        disp('Called the load wrapper function.');
    end
    
    % Remove wrapper load from the Matlab path
    overloadedFunctPath = which('load');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug )
        disp('remove the path of the overloaded load function.');  
    end
    
    source = '';
    if nargin == 0
        % Load all variables from the mat-file matlab.mat if it exists. Returns an error if it doesn't exist.
        
        str = which('-file', 'matlab.mat');
        if isempty(str) % 'matlab.mat' file does not exist
            try
                load % call built-in load function and an error message will be displayed 
            catch ME
                % Add the wrapper load back to the Matlab path
                warning off MATLAB:dispatcher:nameConflict;
                addpath(overloaded_func_path, '-begin');
                warning on MATLAB:dispatcher:nameConflict;
                
                if ( runManager.configuration.debug)
                    disp('add the path of the overloaded load function back.');
                end
                
                rethrow(ME);
            end

        end
        
        % Call builtin load with any input arguments
        load_returned_struct = load; % Assign the returned results to a struct
        
        % Export loaded data from the function load to the caller workspace
        if ~ isempty(load_returned_struct)
            fnames = fieldnames( load_returned_struct );
            for i = 1:size(fnames)
                val =  getfield(load_returned_struct,fnames{i});
                assignin('caller', fnames{i}, val);
            end
            source = 'matlab.mat';
        end
       
    else
        
        % Get the filename as source        
        if ismember(varargin{1}, {'-mat', '-ascii'}) % for syntax load('-mat', 'filename') or load('-ascii', 'filename')
            source = varargin{2};
        else
            source = varargin{1};
        end
        
        % Get the filename extension and check if variable source has no extension. If so, add an
        % extension '.mat'
        [path, file_name, ext] = fileparts(source);
        if isempty(ext)
            source = [source '.mat'];
        end
        
        % Call builtin load function
        if ismember(ext, {'.mat', ''})
            % Load MAT-file
            if nargout > 0
                % For syntax S = load(...) and naragout is 1 (output variable S)
                [varargout{1:nargout}]  = load( varargin{:} );
            else
                load_returned_struct = load(varargin{:}); % Assign the returned results to a struct
                
                % Export loaded data from the function load to the caller workspace
                fnames = fieldnames( load_returned_struct );
                for i = 1:size(fnames)
                    val =  getfield(load_returned_struct,fnames{i});
                    assignin('caller', fnames{i}, val);
                end
            end
        else
            % Load ASCII-file
            if nargout > 0
                % For syntax S = load(...) and naragout is 1 (variable S)
                [varargout{1:nargout}]  = load( varargin{:} );
            else
                % Create variable name after the loaded file
               
                % Create default output variable name when a user do not
                % speccify any output variable,
                % precedes any leading underscores
                % or digits in filename with X and replaces any other
                % nonalphabetic characters with underscores. Eg., load
                % 10-May-data.dat, creates a variable called X10_May_data
                % Jan-27-2016
                temp_str1 = regexprep(file_name, '[^a-zA-Z0-9]', '_'); % replace any non alphabetic/digit character with '_'
               
                expression = '^([\d*]|_)';
                replace = 'X$1';
                output_variable_name = regexprep(temp_str1, expression, replace); % replace any leading underscores or digits in filename with an X
               
                % Assign the returned results to a 2-dim double array
                output_variable_value = load(varargin{:});
                
                % Export loaded data from the function load to the caller workspace
                assignin('caller', output_variable_name, output_variable_value);
            end
        end
    end
    
    % Add the wrapper load back to the Matlab path
    warning off MATLAB:dispatcher:nameConflict;
    addpath(overloaded_func_path, '-begin');
    warning on MATLAB:dispatcher:nameConflict;
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded load function back.');
    end
    
    % Identify the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance    
    % if ( runManager.configuration.capture_file_reads )
    if ( runManager.configuration.capture_file_reads )
        formatId = 'application/octet-stream';
        
        import org.dataone.client.v2.DataObject;
        import org.dataone.client.sqlite.FileMetadata;
        
        fullSourcePath = which(source);
        if isempty(fullSourcePath)
            [status, struc] = fileattrib(source);
            if status ~= 0
                fullSourcePath = struc.Name;
            end
        end
        
        [archiveRelDir, archivedRelFilePath, db_status] = FileMetadata.archiveFile(fullSourcePath);
        if db_status == 1
            % The file has not been archived
            full_archive_file_path = sprintf('%s/%s', runManager.configuration.provenance_storage_directory, archivedRelFilePath);
            full_archive_dir_path = sprintf('%s/%s', runManager.configuration.provenance_storage_directory, archiveRelDir);
            if ~exist(full_archive_dir_path, 'dir')
                mkdir(full_archive_dir_path);
            end
            % Copy this file to the archive directory
            copyfile(fullSourcePath, full_archive_file_path, 'f');
        end
        
        % Save the file metadata to the database
        pid = char(java.util.UUID.randomUUID());
        dataObject = DataObject(pid, formatId, fullSourcePath);
        file_meta_obj = FileMetadata(dataObject, runManager.execution.execution_id, 'read');
        file_meta_obj.archivedFilePath = archivedRelFilePath;
        write_query = file_meta_obj.writeFileMeta();
        sql_status = runManager.provenanceDB.execute(write_query, file_meta_obj.tableName);
        if sql_status == -1
            message = 'DBError: insert a new record to the filemeta table.';
            error(message);
        end
        
        %         existing_id = runManager.execution.getIdByFullFilePath( ...
        %             fullSourcePath);
        %         if ( isempty(existing_id) )
        %             % Add this object to the execution objects map
        %             pid = char(java.util.UUID.randomUUID()); % generate an id
        %             dataObject = DataObject(pid, formatId, fullSourcePath);
        %             runManager.execution.execution_objects(dataObject.identifier) = ...
        %                 dataObject;
        %         else
        %             pid = existing_id;
        %             dataObject = DataObject(pid, formatId, fullSourcePath);
        %             runManager.execution.execution_objects(dataObject.identifier) = ...
        %                 dataObject;
        %         end
        %
        %         if ~isempty(fullSourcePath)
        %             if ( ~ ismember(pid, runManager.execution.execution_input_ids) )
        %                 runManager.execution.execution_input_ids{ ...
        %                     end + 1} = pid;
        %             end
        %         end
    end
end
