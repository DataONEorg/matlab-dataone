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
       
        % The instance of the Configuration class used to provide settings 
        % details for this RunManager
        configuration;
                
        % The execution metadata associated with this run
        execution;
        
        % The YesWorkflow Extractor object
        extractor;
        
        % The YesWorkflow Modeler object
        modeler;
        
        % The YesWorkflow Grapher object
        grapher;
        
        % The generated workflow object built by YesWorkflow 
        workflow;
               
        % The provenance directory for an execution
        runDir;
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

        function manager = RunManager(configuration)
            % RUNMANAGER Constructor: creates an instance of the RunManager class
            %   The RunManager class manages outputs of a script based on the
            %   settings in the given configuration passed in.            
            import org.dataone.client.configure.Configuration;
            manager.configuration = configuration;
            configuration.saveConfig();
            manager.init();
            mlock; % Lock the RunManager instance to prevent clears          
        end
        
    end

    methods (Static)
        function runManager = getInstance(configuration)
            % GETINSTANCE returns an instance of the RunManager by either
            % creating a new instance or returning an existing one.
                        
            import org.dataone.client.configure.Configuration;
            
            %% Set all jars under lib/java/ to the java dynamic class path (Need further consideration !)
            % RunManager.setJavaClassPath();
                       
            % Set the java class path
            RunManager.setMatlabPath();

            % Create a default configuration object if one isn't passed in
            if ( nargin < 1 )
                configuration = Configuration();
               
            end
            
            persistent singletonRunManager; % private, stays in memory across clears
            
            if isempty( singletonRunManager )
                import org.dataone.client.run.RunManager;
                runManager = RunManager(configuration);
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
        function configYesWorkflow(runManager, path)
            % CONFIGYESWORKFLOW set YesWorkflow extractor language model to be
            % Matlab type
            import org.yesworkflow.LanguageModel;
            import org.yesworkflow.extract.DefaultExtractor;
            import org.yesworkflow.model.DefaultModeler;
            import org.yesworkflow.graph.DotGrapher;
            import java.io.PrintStream;
            
            runManager.extractor = DefaultExtractor;
            runManager.modeler = DefaultModeler;
            runManager.grapher = DotGrapher(java.lang.System.out, java.lang.System.err);
            
            % Get an inner class that's an Enum class because we need the Enum Language values 
            matCode = javaMethod('valueOf', 'org.yesworkflow.LanguageModel$Language', 'MATLAB');
            lm = LanguageModel(matCode); 
            runManager.extractor = runManager.extractor.languageModel(lm);  
                      
            % Set generate_workflow_graphic to be true
            runManager.configuration.generate_workflow_graphic = true;
        end
        
                
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
            runManager.execution.software_application = filePath; % Set script path
            
            % Set up YesWorkflow and pass the path of a script to
            % YesWorkflow
            runManager.configYesWorkflow(runManager.execution.software_application);
            
            % Begin recording
            runManager.startRecord(runManager.execution.tag);

            % End the recording session
            runManager.dataPackage = runManager.endRecord();          
        end
        
        function startRecord(runManager, tag)
            % STARTRECORD Starts recording provenance relationships (see
            % record()).

            if ( runManager.recording )
                warning(['A RunManager session is already active. Please call ' ...
                         'endRecord() if you wish to close this session']);
                  
            end                

            % Create the run metadata directory for this run
            k = strfind(runManager.execution.execution_id, 'urn:uuid:'); % get the index of 'urn:uuid:'
            runId = runManager.execution.execution_id(k+9:end);
          % fprintf('k+9=%d\n', k+9);
            runManager.runDir = strcat(runManager.configuration.provenance_storage_directory, filesep,'runs', filesep, runId);
            [status, message, message_id] = mkdir(runManager.runDir);
          % fprintf('filePath:%s\n', runManager.runDir);           
            if ( status ~= 1 )
                error(message_id, [ 'The directory %s' ...
                    ' could not be created. The error message' ...
                    ' was: ' runManager.runDir, message]);
            end
                           
            % Call YesWorkflow to capture prospective provenance for current scirpt
            curDir = pwd();
            runManager.captureProspectiveProvenanceWithYW();
           
            % Generate YesWorkflow image outputs
            if runManager.configuration.generate_workflow_graphic
                cd(runManager.runDir);
                % Convert .gv files to .png files
                if isunix
                    system('/usr/local/bin/dot -Tpng combined_view.gv -o combined_view.png'); % for linux & mac platform, not for windows OS family
                   
                 %  execIdList = ArrayListMatlabWrapper;
                 %  execIdList.add(executionId);
                 %  runManager.dataPackage.insertRelationship(imgId1, execIdList, NamedConstant.provNS, NamedConstant.provWasGeneratedBy);
                 
                    system('/usr/local/bin/dot -Tpng data_view.gv -o data_view.png');
                    % One derived YW data view image
                    imgId2 = Identifier;
                    imgId2.setValue([NamedConstant.cnBaseURL 'data_view.png']); % a figure image
                        
                    system('/usr/local/bin/dot -Tpng process_view.gv -o process_view.png');
                    % One derived YW process view image
                    imgId3 = Identifier;
                    imgId3.setValue([NamedConstant.cnBaseURL 'process_view.png']); % a figure image
                end    
                cd(curDir);
            end
            
            %% Package a datapackage for the current run    
            % Initialize a dataPackage to manage the run
            import org.dataone.client.v1.itk.DataPackage;
            import org.dataone.service.types.v1.Identifier;
            import org.dataone.ore.ResourceMapFactory;
            import org.dataone.ore.ProvResourceMapBuilder;
            import org.dataone.ore.HashmapMatlabWrapper;
            import org.dspace.foresite.ResourceMap;
            
            packageIdentifier = Identifier();
            packageIdentifier.setValue(runManager.execution.data_package_id);            
            runManager.dataPackage = DataPackage(packageIdentifier);
            
            % Create a resource map
            resourceMapId = Identifier;
            resourceMapId.setValue(['resourceMap_' char(java.util.UUID.randomUUID())]);
            rmf = ProvResourceMapBuilder.getInstance();
                 
            % Create metadata 
            metadataId = Identifier;
            metadataId.setValue('Meta_11111111111');
            
            % Include YW impages
            if runManager.configuration.include_workflow_graphic 
                % One derived YW combined view image 
                imgId1 = Identifier;
                imgId1.setValue('combined_view.png'); % a figure image
                % Metadata
                metadataImgId1 = Identifier;
                metadataImgId1.setValue('combined_view.xml');
                dataIds1 = ArrayListMatlabWrapper;
                dataIds1.add(imgId1); 
            end
            
            executionId = Identifier;
            executionId.setValue(['execution_' runId]);
            
            % Map the objects in the data package
            dataIds = ArrayListMatlabWrapper;
            dataIds.add(executionId);
            dataIds.add(metadataImgId1);
            dataIds.add(imgId1);
            
            idMap = HashmapMatlabWrapper;
            idMap.put(metadataId, dataIds);
                      
            resourceMap = rmf.createResourceMap(resourceMapId, idMap);
                                 
            % Record relationship identifying this id as a provone:Execution
            import org.dataone.client.run.NamedConstant;
            import org.dataone.client.v1.itk.ArrayListMatlabWrapper;
            
            executionId = Identifier;
            executionId.setValue(['execution_' runId]);
            
            % wasGeneratedBy
            rmf.addWasGeneratedBy(resourceMap, imgId1, executionId);
                 
            % Record relationship between the Exectution and the User
              
                
            % Record relationship between the figure impage and the source data
                   
            
            % Create an XML document with the serialized RDF
            rdfXml = ResourceMapFactory.getInstance().serializeResourceMap(resourceMap);
         
            % Print it
            fw = fopen('testCreatedResourceMapWithProv.xml', 'w');          
            fprintf(fw, '%s', char(rdfXml));
            fclose(fw);
            fprintf('The resource map is : %s', char(rdfXml)); % output to the screen
            
            % Run the script and collect provenance information
          % runManager.prov_capture_enabled = true;
          % [pathstr, script_name, ext] = ...
          %     fileparts(runManager.execution.software_application);
          % addpath(pathstr);

          % try
          %     eval(script_name);
                
          % catch runtimeError
          %     error(['The script: ' ...
          %            runManager.execution.software_application ...
          %            ' could not be run. The error message was: ' ...
          %             runtimeError.message]);
                   
          % end
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
            if ( ~ isempty(runManager.configuration) )
                prov_dir = runManager.configuration.get('provenance_storage_directory');
                
                % Only proceed if the runs directory is available
                if ( ~ exist(prov_dir, 'dir') )
                    runs_dir = fullfile(prov_dir, 'runs', filesep);
                    [status, message, message_id] = mkdir(runs_dir);
                    
                    if ( status ~= 1 )
                        error(message_id, [ 'The directory ' runs_dir ...
                              ' could not be created. The error message' ...
                              ' was: ' message]);
                    
                    elseif ( strcmp(message, 'already exists') )
                        if ( runManager.configuration.debug )
                            disp(['The directory ' runs_dir ...
                                ' already exists and will not be created.']);
                        end
                    end                    
                end
            end
        end
 
        function captureProspectiveProvenanceWithYW(runManager)
            % CAPTUREPROSPECTIVEPROVENANCEWITHYW captures the prospective
            % provenance using YesWorkflow.
            
            % Scan the script for inline YesWorkflow comments
            import java.io.BufferedReader;
            import org.yesworkflow.annotations.Annotation;
            import org.yesworkflow.model.Program;
            import org.yesworkflow.model.Workflow;
            import java.io.File;
            import java.io.FileReader;
            import java.util.List;
            import java.util.HashMap;
                       
            % Read script content from disk
            script = File(runManager.execution.software_application);
            freader = FileReader(script);
            reader = BufferedReader(freader);
            
            % Call YW-Extract module
            runManager.extractor = runManager.extractor.source(reader);
            annotations = runManager.extractor.extract().getAnnotations();
        
            % Call YW-Model module
            runManager.modeler = runManager.modeler.annotations(annotations);
            runManager.modeler = runManager.modeler.model;
            program = runManager.modeler.getModel;
            runManager.workflow = runManager.modeler.getWorkflow;
          
            % Call YW-Graph module
            if runManager.configuration.generate_workflow_graphic
                import org.yesworkflow.graph.GraphView;
                import org.yesworkflow.graph.CommentVisibility;
            
                runManager.grapher = runManager.grapher.workflow(runManager.workflow);
                gconfig = HashMap;
                       
                % Set the working directory to be the run metadata directory for this run
                curDir = pwd();
                wd = cd(runManager.runDir); % do I need to go back to the src/ folder again?
                
                % Generate YW.Process_View
                gconfig.put('view', GraphView.PROCESS_CENTRIC_VIEW);
                gconfig.put('comments', CommentVisibility.HIDE);
                runManager.grapher.config(gconfig);
                runManager.grapher = runManager.grapher.graph();           
                % Output the content of dot file to a file (test_mstmip_process_view.gv)
                fileID = fopen('process_view.gv','w');
                fprintf(fileID, '%s', char(runManager.grapher.toString()));
                fclose(fileID);
            
                % Generate YW.Data_View
                gconfig.put('view', GraphView.DATA_CENTRIC_VIEW);
                runManager.grapher.config(gconfig);
                runManager.grapher = runManager.grapher.graph();
                % Output the content of dot file to a file (test_mstmip_data_view.gv)
                fileID = fopen('data_view.gv','w');
                fprintf(fileID, '%s', char(runManager.grapher.toString()));
                fclose(fileID);
            
                % Generate YW.Combined_View
                gconfig.put('view', GraphView.COMBINED_VIEW);
                runManager.grapher.config(gconfig);
                runManager.grapher = runManager.grapher.graph();
                % Output the content of dot file to a file (test_mstmip_combined_view.gv)
                fileID = fopen('combined_view.gv','w');
                fprintf(fileID, '%s', char(runManager.grapher.toString()));
                fclose(fileID);
                
                cd(curDir); % go back to current working directory 
            
            end    
        end
    end
end
