% RUNMANAGER A class used to track information about program runs.
%   The RunManager class provides functions to manage script runs in terms
%   of the known file inputs and the derived file outputs. It keeps track
%   of the provenance (history) relationships between these inputs and outputs.
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

classdef RunManager < hgsetget
    
    properties
       
        % The instance of the Session class used to provide settings 
        % details for this RunManager
        session;
                
        % The execution metadata associated with this run
        execution;
    end

    properties (Access = private)
               
        % Enable or disable the provenance capture state
        prov_capture_enabled = false;

        % The state of a recording session
        recording = false;
        
        % The DataPackage aggregating and describing all objects in a run
        dataPackage;
        
    end

    methods (Access = private)

        function manager = RunManager(session)
            % RUNMANAGER Constructor: creates an instance of the RunManager class
            %   The RunManager class manages outputs of a script based on the
            %   settings in the given session passed in.
          
            import org.dataone.client.configure.Session;
            manager.session = session;
            session.saveSession();
            manager.init();
            mlock; % Lock the RunManager instance to prevent clears
            
        end
        
    end

    methods (Static)
        function runManager = getInstance(session)
            % GETINSTANCE returns an instance of the RunManager by either
            % creating a new instance or returning an existing one.
            
            import org.dataone.client.configure.Session;
            
            % Set the java class path
            RunManager.setJavaClassPath();

            % Set the java class path
            RunManager.setMatlabPath();

            % Create a default session object if one isn't passed in
            if ( nargin < 1 )
                session = Session();
               
            end
            
            persistent singletonRunManager; % private, stays in memory across clears
            
            if isempty( singletonRunManager )
                import org.dataone.client.run.RunManager;
                runManager = RunManager(session);
                singletonRunManager = runManager;
                
            else
                runManager = singletonRunManager;
                
            end
        end
        
        function setJavaClassPath()
            % SETJAVACLASSPATH adds all Java libraries found in 
            % $matalab-dataone/lib to the java class path
            
            % Determine the lib directory relative to the RunManager
            % location
            filePath = mfilename('fullpath');
            matlab_dataone_dir_array = strsplit(filePath, filesep);
            matlab_dataone_java_lib_dir = ...
                [strjoin( ...
                    matlab_dataone_dir_array(1:length(matlab_dataone_dir_array) - 7), ...
                    filesep) ...
                    filesep 'lib' filesep 'java' filesep];
            java_libs_array = dir(matlab_dataone_java_lib_dir);
            % For each library file, add it to the class path
            
            classpath = javaclasspath('-all');
            
            for i=3:length(java_libs_array)
                classpathItem = [matlab_dataone_java_lib_dir java_libs_array(i).name];
                presentInClassPath = strmatch(classpathItem, classpath);
                if ( isempty(presentInClassPath) )
                    javaaddpath(classpathItem);
                    disp(['Added new java classpath item: ' classpathItem]);
                end
                
            end
        end
        
        function setMatlabPath()
            % SETMATLABPATH adds all Matlab libraries found in 
            % $matalab-dataone/lib/matlab to the Matlab path
            
            % Determine the lib directory relative to the RunManager
            % location
            filePath = mfilename('fullpath');
            matlab_dataone_dir_array = strsplit(filePath, filesep);
            matlab_dataone_lib_dir = ...
                [strjoin( ...
                    matlab_dataone_dir_array(1:length(matlab_dataone_dir_array) - 7), ...
                    filesep) ...
                    filesep 'lib' filesep 'matlab' filesep];
           
           % Add subdirectories of lib/matlab to the Matlab path,
           addpath(genpath(matlab_dataone_lib_dir));
                
         end
    end
    
    methods
        
        function data_package = record(runManager, filePath, tag)
            % RECORD Records provenance relationships between data and scripts
            % When record() is called, data input files, data output files,
            % and programs (scripts and classes) are tracked during an
            % execution of the program, and a graph of their relationships
            % is produced using the W3C PROV ontology standard 
            % (<http://www.w3.org/TR/prov-o/>) and the
            % DataONE ProvONE model(<https://purl.dataone.org/provone-v1-dev>).
            % Note that, when passing scripts to the record() function,
            % scripts that contain commands such as 'clear all' will cause
            % the recording session to fail because the RunManager instance
            % will have been removed. Also, note that relative path names
            % to files may also cause I/O errors, depending on what your
            % current working directory is at the moment.

            % Return if we are already recording
            if ( runManager.recording )
                return;
            end
                   
            % Do we have a script as input?
            if ( nargin < 2 )
                error(['Please provide the path to the script you want to ' ...
                       'record, and (optionally) a tag that labels your run.']);
            end
            
            % Does the script exist?
            if ( ~exist(filePath, 'file'));
                error([' The script: '  filePath ' does not exist.' ...
                       'Please provide the path to the script you want to ' ...
                       'record, and (optionally) a tag that labels your run.']);                    
            end
            
            % do we have a tag?
            if ( nargin < 3 )
                tag = ''; % otherwise use an empty tag
                    
            end
                        
            % Begin collecting execution metadata
            import org.dataone.client.run.Execution;
                
            % Validate the tag, ensuring it can be cast to a string
            try
                tagStr = '';
                if ( ~isempty(tag) )
                    tagStr = cast(tag);
                end
                
            catch classCastException
                error(['The tag used for the record session cannot be ' ...
                       'cast to a string. Please use a tag label that is ' ...
                       ' a string or a data type that can be cast to ' ...
                       'a string. The error message was: ' ...
                       classCastException.message]);
            end

            runManager.execution = Execution(tagStr);
            runManager.execution.software_application = filePath;
            
            % Begin recording
            runManager.startRecord(runManager.execution.tag);

            % End the recording session
            runManager.dataPackage = runManager.endRecord();
            
        end
        
        function startRecord(runManager, tag)
            % STARTRECORD Starts recording provenance relationships (see
            % record()).

            if ( runManager.recording )
                disp(['A RunManager session is already active. Please call ' ...
                      'endRecord() if you wish to close this session']);
                  
            end                

            % Initialize a dataPackage to manage the run
            import org.dataone.client.v1.itk.DataPackage;
            import org.dataone.service.types.v1.Identifier;
            packageIdentifier = Identifier();
            packageIdentifier.setValue(runManager.execution.data_package_id);            
            runManager.dataPackage = DataPackage(packageIdentifier);
            
            % Scan the script for inline YesWorkflow comments
            
            % Add YesWorkflow-derived triples to the DataPackage
            
            % Run the script and collect provenance information
            runManager.prov_capture_enabled = true;
            [pathstr, script_name, ext] = ...
                fileparts(runManager.execution.software_application);
            addpath(pathstr);

            try
                eval(script_name);
                
            catch runtimeError
                error(['The script: ' ...
                       runManager.execution.software_application ...
                       ' could not be run. The error message was: ' ...
                       runtimeError.message]);
                   
            end
        end
        
        function data_package = endRecord(runManager)
            % ENDRECORD Ends the recording of an execution (run).
            
            % Stop recording
            runManager.recording = false;
            runManager.prov_capture_enabled = false;
            
            % Return the Java DataPackage as a Matlab structured array
            data_package = struct(runManager.dataPackage);
            
            % Unlock the RunManager instance
            munlock('RunManager');
            
        end
        
        function runs = listRuns(runManager, quiet, startDate, endDate, tags)
            % LISTRUNS Lists prior executions (runs) and information about them.
        end
        
        function deleted_runs = deleteRuns(runIdList, startDate, endDate, tags)
            % DELETERUNS Deletes prior executions (runs) from the stored
            % list.
            
        end
        
        function package_id = view(runManager, packageId)
            % VIEW Displays detailed information about a data package that
            % is the result of an execution (run).
            
        end
        
        function package_id = publish(runManager, packageId)
            % PUBLISH Uploads a data package produced by an execution (run)
            % to the configured DataONE Member Node server.
            
        end
        
        function init(runManager)
            % INIT initializes the RunManager instance
                        
            % Ensure the provenance storage directory is configured
            if ( ~ isempty(runManager.session) )
                prov_dir = runManager.session.get('provenance_storage_directory');
                
                % Only proceed if the runs directory is available
                if ( ~ exist(prov_dir, 'dir') )
                    runs_dir = fullfile(prov_dir, 'runs', filesep);
                    [status, message, message_id] = mkdir(runs_dir);
                    
                    if ( status ~= 1 )
                        error(message_id, [ 'The directory ' runs_dir ...
                              ' could not be created. The error message' ...
                              ' was: ' message]);
                    
                    elseif ( strcmp(message, 'already exists') )
                        if ( runManager.session.debug )
                            disp(['The directory ' runs_dir ...
                                ' already exists and will not be created.']);
                        end
                    end                    
                end
            end
        end
    end
end