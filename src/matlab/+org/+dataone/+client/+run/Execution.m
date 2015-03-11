% EXECUTION A class representing the metadata associated with a script
% execution.
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2009-2014 DataONE
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

classdef Execution < hgsetget
    % EXECUTION A class representing the metadata associated with a script execution.
    %       An Execution represents a script run, and contains some
    %       critical metadata needed to understand the execution
    %       environment, uniquely identify the run, categorize it,
    %       and know it's start and end times.
    
    properties
        % A label that allows the scientist to characterize the run
        tag;
        
        % The unique identifier of the execution
        execution_id;

        % the time this execution was published to a permanent repository
        publish_time;
        
        % The start time of the execution
        start_time;
        
        % The end time of the execution
        end_time;
        
        % The user's system account name
        account_name;
        
        % The name of the host the script was run on
        host_id;
        
        % The Runtime version information for the Matlab installation
        runtime;
        
        % The operating system the execution was run on
        operating_system;
        
        % The identifier for the DataONE data package associated with this run
        data_package_id;
        
        % The software application associated with this run
        software_application;
        
        % The Matlab module dependencies associated with this run
        module_dependencies;
    end

    methods
        
        function execution = Execution()
            % EXECUTION Constructs an instance of the Execution class

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
                
            elseif ( ismac )
                [status, result] = unix('sw_vers');
                if ( status == 0 )
                    platform = strrep(result, 'ProductName:', '');
                    platform = strrep(platform, sprintf('\t'), '');
                    platform = strrep(platform, sprintf('\n'), ' ');
                    platform = strrep(platform, 'ProductVersion:', ' Version: ');
                    platform = strrep(platform, 'BuildVersion:', 'Build: ');
                end
            end
            
            operating_system_info = platform;
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
            
            % set default properties
            execution.execution_id = ['urn:uuid:' char(java.util.UUID.randomUUID())];
            execution.data_package_id = ['urn:uuid:' char(java.util.UUID.randomUUID())];
            execution.account_name = getenv('USER') % TODO: test on Windows
            execution.runtime = execution.getMatlabVersion();
            execution.operating_system = execution.getOSInfo();
            execution.host_id = execution.getHostName();
            
        end
    end
    
end