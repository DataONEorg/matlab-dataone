% EXECUTION A class representing the metadata associated with a script execution.
%       An Execution represents a script run, and contains some
%       critical metadata needed to understand the execution
%       environment, uniquely identify the run, categorize it,
%       and know it's start and end times.
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2009-2016 DataONE

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

classdef Execution < hgsetget

    properties
        % The sequence number assigned to the run for easy reference
        sequence_number;
        
        % A label that allows the scientist to characterize the run
        tag = '';
        
        % The unique identifier of the execution
        execution_id = '';

        % The unique coordinating Node URI of the execution
        execution_uri = '';

        % The directory storing the execution artifacts
        execution_directory = '';
        
        % the time this execution was published to a permanent repository
        publish_time = '';
        
        % The start time of the execution
        start_time = '';
        
        % The end time of the execution
        end_time = '';
        
        % The user's system account name
        account_name = '';
        
        % The name of the host the script was run on
        host_id;
        
        % The Runtime version information for the Matlab installation
        runtime;
        
        % The operating system the execution was run on
        operating_system;
        
        % The software application associated with this run (script name)
        software_application = '';
        
        % The Matlab module (toolbox) dependencies associated with this run
        module_dependencies;
        
        % Any error message associated with a run
        error_message;
        
        subject; % todo:
        
        console; % todo:
        
        % The input id list for an execution
        execution_input_ids;
        
        % The output id list for an execution
        execution_output_ids;
        
        % a map of {id, DataObject} pairs that are part of the execution
        execution_objects = containers.Map('keyType', 'char', 'valueType', 'any');
    end
    
    methods

        function execution = Execution(varargin)
            % EXECUTION Constructs an instance of the Execution class
            %   exec = Execution() creates a default execution object
            %   exec = Execution('some tag string') creates the execution
            %          object and sets the tag property to the given string
            
            if ( nargin > 0 )
                if ( ischar(varargin{1}) )
                    execution.tag = varargin{1};
                end
            end
                
            execution.init();
        end
                
        function runtime_info = getMatlabVersion(execution)
            % GETMATLABVERSION Returns a string showing the installed Matlab version
            
            v = ver('MATLAB');
            
            runtime_info = [v.Name ' ' v.Version ' ' v.Release ' ' v.Date];
            
        end
        
        
        function operating_system_info = getOSInfo(execution)
            % GETOSINFO Returns a string describing the operating system environment
            platform = system_dependent('getos');
            
            % Handle PC or Mac OSs
            if ( ispc )
                platform = [platform, '', system_dependent('getwinsys')];
                
            elseif ( isunix )
                [status, result] = unix('sw_vers');
                if ( status == 0 )
                    platform = strrep(result, 'ProductName:', '');
                    platform = strrep(platform, sprintf('\t'), '');
                    platform = strrep(platform, sprintf('\n'), ' ');
                    platform = strrep(platform, 'ProductVersion:', ' Version: ');
                    platform = strrep(platform, 'BuildVersion:', 'Build: ');
                end
            end
            
            operating_system_info = strtrim(platform);
        end
        
        function hostname = getHostName(execution)
            % GETHOSTNAME returns the name of the host machine that the
            % execution ran on
            
            hostname = 'localhost'; % A fallback default name
            [status, result] = system('hostname');
            
            if ( length(result) ~= 0 )
                hostname = strtrim(result);
            end
            
        end
        
        function init(execution)
            % INIT Initializes properties for a new instance of the
            % Execution class
            
            % Set a default id
            execution.execution_id = char(java.util.UUID.randomUUID());
            
            % Set the start timestamp. Use Java-based date formatting to 
            % encode the timezone offset correctly
            format = java.text.SimpleDateFormat('yyyy-MM-dd HH:MM:ss.SSSZ');
            execution.start_time = char(format.format(java.util.Date()));
            
            % Set the account with the system username
            if ( ispc() )
                execution.account_name = getenv('USERNAME'); % Windows
            else
                execution.account_name = getenv('USER'); % Mac/Linux
            end
            
            % Set the runtime version
            execution.runtime = execution.getMatlabVersion();
            
            % Set the OS info
            execution.operating_system = execution.getOSInfo();
            
            % Set the host name
            execution.host_id = execution.getHostName();
            
            % Set the software app name (original script file name)
            % Question: should it be programName?
            % [stacktrace, workspace_idx] = dbstack('-completenames');
            % execution.software_application = stacktrace(length(stacktrace)).file;
              
            % Set the potential toolbox dependencies
            % TODO: Decide if matlab.codetools.requiredFilesAndProducts()
            % is more appropriate for this
            execution.module_dependencies = path; 
          
        end

        function identifier = getIdByFullFilePath(execution, full_file_path)
        % GETIDBYFULLFILEPATH returns the identifier of an object given its path
        %       identifier = getIdByFullFilePath(full_file_path) will
        %       return an identifier string if the given full_file_path 
        %       argument value matches the full_file_path property of a 
        %       DataObject instance already stored in the 
        %       Execuition.execution_objects map. Otherwise, it will return
        %       an empty string.
            identifier = '';
        
            object_map_keys = keys(execution.execution_objects);
            object_map_values = values(execution.execution_objects);
        
            for i = 1 : length(execution.execution_objects)
                existing_identifier = object_map_keys{i};
                existing_d1_object = object_map_values{i};
                existing_path = existing_d1_object.full_file_path;
            
                % Does it already exist? Return the id
                if ( strcmp(full_file_path, existing_path) )
                    identifier = existing_identifier;
                    break;
                
                end
            end        
        end
    end
    
end
