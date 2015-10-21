% RUNMANAGERTEST A class used to test the org.dataone.client.run.RunManager class functionality
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2009-2015 DataONE
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

classdef RunManagerTest < matlab.unittest.TestCase
    
    properties 
        filename
        testDir
        mgr
        yw_process_view_property_file_name
        yw_data_view_property_file_name 
        yw_comb_view_property_file_name
    end

    methods (TestMethodSetup)
        
        function setUp(testCase)
                        
            % SETUP Set up the test environment            
            import org.dataone.client.run.RunManager;
            import org.dataone.client.configure.Configuration;
                        
            % testCase.filename = 'src/test/resources/C3_C4_map_present_NA_Markup_v2_3.m';
            testCase.filename = 'src/test/resources/myScript1.m';
            
            if ispc
                home_dir = getenv('USERPROFILE');
            elseif isunix
                home_dir = getenv('HOME');
            else
                error('Current platform not supported.');
            end
            test_config_directory = fullfile(home_dir, '.d1test');
            
            % for unit testing, set the D1 directory to a test location
            config = Configuration( ...
                'configuration_directory', test_config_directory);
            
            testCase.mgr = RunManager.getInstance(config);           
            testCase.yw_process_view_property_file_name = 'lib/yesworkflow/yw_process_view.properties'; 
            testCase.yw_data_view_property_file_name = 'lib/yesworkflow/yw_data_view.properties'; 
            testCase.yw_comb_view_property_file_name = 'lib/yesworkflow/yw_comb_view.properties'; 
        end
    end
    
    methods (TestMethodTeardown)
        
        function tearDown(testCase)
            
            % Reset the Matlab DataONE Toolbox environment
            resetEnvironment(testCase);
        end
    end
    
    methods (Test)
        
        function testGetInstanceNoConfiguration(testCase)
            % TESTGETINSTANCENOCONFIGURATION tests calling the getInstance()
            % function without passing a Configuration object

            fprintf('\nIn testGetInstanceNoConfiguration() ...\n');
            if ( isprop(testCase.mgr.configuration, 'format_id') )                
                old_format_id = get(testCase.mgr.configuration, 'format_id');            
            else
               old_format_id = ''; 
            end
            set(testCase.mgr.configuration, 'format_id', 'application/octet-stream');
            assertInstanceOf(testCase, testCase.mgr, 'org.dataone.client.run.RunManager');
            % Test a single default property to ensure the configuration was set
            assertEqual(testCase, testCase.mgr.configuration.format_id, 'application/octet-stream');
            
            % reset to the original
            set(testCase.mgr.configuration, 'format_id', old_format_id);
        end 
        
        function testGetInstanceWithConfiguration(testCase)
            % TESTGETINSTANCENOCONFIGURATION tests calling the getInstance()
            % function while passing a Configuration object

            import org.dataone.client.run.RunManager;
            import org.dataone.client.configure.Configuration;
            
            fprintf('\nIn testGetInstanceWithConfiguration() ...\n');
 
            old_format_id = get(testCase.mgr.configuration, 'format_id');
            set(testCase.mgr.configuration, 'format_id', 'text/csv');
            
            % Test the instance type
            assertInstanceOf(testCase, testCase.mgr, 'org.dataone.client.run.RunManager');
            % Test a single preset property
            assertEqual(testCase, testCase.mgr.configuration.format_id, 'text/csv');
            
            % reset to the original
            set(testCase.mgr.configuration, 'format_id', old_format_id);
        end        
        
        function testYesWorkflow(testCase)
            fprintf('\nIn testYesWorkflow() ...\n');
            
            testCase.filename = 'src/test/resources/C3_C4_map_present_NA_Markup_v2_7.m';
              
            %scriptPath = fullfile(pwd(), filesep, testCase.filename); 
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
           
            % matlab_toolbox_directory = testCase.mgr.configuration.matlab_dataone_toolbox_directory;
            % yw_process_view_properties_path = fullfile(matlab_toolbox_directory, filesep, testCase.yw_process_view_property_file_name);
            % testCase.mgr.configuration.yesworkflow_config.process_view_property_file_name = yw_process_view_properties_path;
            
            % yw_data_view_properties_path = fullfile(matlab_toolbox_directory, filesep, testCase.yw_data_view_property_file_name);
            % testCase.mgr.configuration.yesworkflow_config.data_view_property_file_name = yw_data_view_properties_path;
            
            % yw_comb_view_properties_path = fullfile(matlab_toolbox_directory, filesep, testCase.yw_comb_view_property_file_name);
            % testCase.mgr.configuration.yesworkflow_config.combined_view_property_file_name = yw_comb_view_properties_path;
           
            testCase.mgr.execution.software_application = scriptPath;
            testCase.mgr.execution.execution_directory = '/tmp';
            addpath(testCase.mgr.execution.execution_directory );
            testCase.mgr.callYesWorkflow(scriptPath, testCase.mgr.execution.execution_directory);
            
            % Test comb_view generated by yesWorkflow exists
            combFileName = testCase.mgr.getYWCombViewFileName();
            a = dir(testCase.mgr.execution.execution_directory);
            b = struct2cell(a);
            existed = any(ismember(b(1,:), combFileName));
          
            assert(isequal(existed,1));           
        end           
        
        function testRecord(testCase)
            fprintf('\nIn testRecord() ...\n');
     
             testCase.filename = 'src/test/resources/C3_C4_map_present_NA_Markup_v2_7.m';
            % testCase.filename = 'src/test/resources/myScript1.m';
            % testCase.filename = 'src/test/resources/myScript2.m';
            % testCase.filename = 'src/Users/syc/Documents/matlab-dataone/src/test/resources/myScript2.m';
 
            scriptPath = which(testCase.filename); % get the absolute path of the script
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            [scriptParentPath, name, ext] = fileparts(scriptPath);
            tag = 'c3_c4_1'; % TODO: multiple tags passed in
          
            % matlab_toolbox_directory = testCase.mgr.configuration.matlab_dataone_toolbox_directory;
            % yw_process_view_properties_path = fullfile(matlab_toolbox_directory, filesep, testCase.yw_process_view_property_file_name);
            % testCase.mgr.configuration.yesworkflow_config.process_view_property_file_name = yw_process_view_properties_path;
            
            % yw_data_view_properties_path = fullfile(matlab_toolbox_directory, filesep, testCase.yw_data_view_property_file_name);
            % testCase.mgr.configuration.yesworkflow_config.data_view_property_file_name = yw_data_view_properties_path;
            
            % yw_comb_view_properties_path = fullfile(matlab_toolbox_directory, filesep, testCase.yw_comb_view_property_file_name);
            % testCase.mgr.configuration.yesworkflow_config.combined_view_property_file_name = yw_comb_view_properties_path;
            
            currentDir = pwd();
            cd(scriptParentPath);
            testCase.mgr.record(scriptPath, tag);  
            cd(currentDir);
            
            % Test if one resource map exists 
            a = dir(testCase.mgr.execution.execution_directory);
            b = struct2cell(a);
            
            [path, name, ext] = fileparts(testCase.filename);
            testResMapFileName = ['resourceMap_' name '.rdf'];
            existed = any(ismember(b(1,:), testResMapFileName));
            assert(isequal(existed,1));
            
            % Test if there are three views outputs exist 
            matches = regexp(b(1,:), '.pdf');
            total = sum(~cellfun('isempty', matches));
            assertEqual(testCase, total, 3);
            
            % Test if there are three yw.properties 
            matches = regexp(b(1,:), '.properties');
            total = sum(~cellfun('isempty', matches));
            assertEqual(testCase, total, 3);
            
            % Test if there are two prolog dump files
            matches = regexp(b(1,:), 'extractfacts');
            total1 = sum(~cellfun('isempty', matches));
            matches = regexp(b(1,:), 'modelfacts');
            total2 = sum(~cellfun('isempty', matches));
            total = total1 + total2;
            assertEqual(testCase, total, 2);
        end
                
        function testOverloadedNCopen(testCase)
            fprintf('\nIn testOverloadedNcread() ...\n');            
            testCase.filename = 'src/test/resources/myScript3.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
    
            run(scriptPath);
        end        
              
        function testOverloadedNCread(testCase)
            fprintf('\nIn testOverloadedNcread() ...\n');            
            testCase.filename = 'src/test/resources/myScript1.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end        
        
        function testOverloadedNCwrite(testCase)
            fprintf('\nIn testOverloadedNcwrite() ...\n');            
            testCase.filename = 'src/test/resources/myScript2.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end        
        
        function testOverloadedCSVread(testCase)
            fprintf('\nIn testOverloadedCSVread() ...\n');            
            testCase.filename = 'src/test/resources/myScript4.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
           
            run(scriptPath);
        end        
                       
        function testOverloadedLoad(testCase)
            % Todo: load coast (not working)
            fprintf('\nIn testOverloadedLoad() ...\n');            
            testCase.filename = 'src/test/resources/myScript5.m';
            % testCase.filename = 'test/resources/myScript1.m'; % load coast
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
           
            run(scriptPath);
        end        
        
        function testOverloadedDlmread(testCase)
          
            fprintf('\nIn testOverloadedDlmread ...\n');            
            testCase.filename = 'src/test/resources/myScript6.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
         
            run(scriptPath);
        end        
                
        function testListRunsNoParams(testCase)
            fprintf('\n*** testListRuns with no parameters: ***\n');
            
            generateTestRuns(testCase);
                        
            runs = testCase.mgr.listRuns();
            
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 3); % Three rows should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsAllParams(testCase)
            fprintf('\n*** testListRuns with all parameters: ***\n');
            
            generateTestRuns(testCase);
            
            quiet = false;
            startDate = '20151006T101049';
            endDate = '20151006T101149';
            tagList = {'test_tag_2'};
                       
            runs = testCase.mgr.listRuns('startDate', startDate, 'endDate', endDate, 'tag', tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsStartDateOnly(testCase)
            fprintf('\n*** testListRuns with startDate only: ***\n');

            generateTestRuns(testCase);

            startDate = '20151006T101049';
           
            runs = testCase.mgr.listRuns('startDate', startDate);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 2); % Two rows should match
            % TODO: Compare the execution ids
  
        end
        
        function testListRunsEndDateOnly(testCase)
            
            fprintf('\n*** testListRuns with endDate only: ***\n');

            generateTestRuns(testCase);

            endDate = '20150930T101149';
           
            runs = testCase.mgr.listRuns('endDate', endDate);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsStartDateEndDateOnly(testCase)
            
            fprintf('\n*** testListRuns with startDate and endDate only: ***\n');

            generateTestRuns(testCase);

            startDate = '20151006T101049';
            endDate = '20151006T101149';
          
            runs = testCase.mgr.listRuns('startDate', startDate, 'endDate', endDate);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids

        end
        
        function testListRunsStartDateEndDateTagsOnly(testCase)
            fprintf('\n*** testListRuns with startDate, endDate and tags only: ***\n');

            generateTestRuns(testCase);

            startDate = '20151006T101049';
            endDate = '20151006T101149';
            tagList = {'test_tag_2'};

            runs = testCase.mgr.listRuns('startDate', startDate, 'endDate', endDate, 'tag', tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsStartDateTagsOnly(testCase)
            fprintf('\n*** testListRuns with startDate and tags only: ***\n');

            generateTestRuns(testCase);

            startDate = '20150929T102515';
            tagList = {'test_tag_2'};

            runs = testCase.mgr.listRuns('startDate', startDate, 'tag', tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
        end

        function testListRunsEndDateTagsOnly(testCase)

            fprintf('\n*** testListRuns with endDate and tags required: ***\n');

            generateTestRuns(testCase);

            endDate = '20150930T101149';
            tagList = {'test_tag_1'};
            
            % runs = testCase.mgr.listRuns('', '', endDate, tagList);
            runs = testCase.mgr.listRuns('endDate', endDate, 'tag', tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsTagsOnly(testCase)
            fprintf('\n*** testListRuns with tags required only: ***\n');

            generateTestRuns(testCase);
            
            tagList = {'test_tag_3'};

            runs = testCase.mgr.listRuns('tag', tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end        
          
        function testListRunsSequenceNumberOnly(testCase)
            fprintf('\n*** testListRuns with sequence number required only: ***\n');

            generateTestRuns(testCase);
            
            sequenceNumber = 1;

            runs = testCase.mgr.listRuns('sequenceNumber', sequenceNumber);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids            
        end 
        
        function testDeleteRunsByTags(testCase)
            fprintf('\n*** testDeleteRunsByTags: ***\n');
            
            generateTestRuns(testCase);
                        
            tagList = {'test_tag_1'};
            noop = true;
            
            % Delete the runs
            testCase.mgr.deleteRuns('tag', tagList, 'noop', noop);
     
            if ~noop
                runs = testCase.mgr.listRuns(); % List the runs
                [rows, cols] = size(runs);
                assertEqual(testCase, rows, 2); % Only 2 rows should be left
            else
                runs = testCase.mgr.listRuns();
                [rows, cols] = size(runs);
                assertEqual(testCase, rows, 3); % 3 rows should be there because no delete is applied
            end
        end          
        
        function testDeleteRunsByTagsRunIdsOnly(testCase)
            fprintf('\n*** testDeleteRunsByTagsRunIdsOnly: ***\n');
            
            generateTestRuns(testCase);
                        
            tagList = {'test_tag_1'};
            runIds = {'1'};
           
            deleted_runs = testCase.mgr.deleteRuns('runIdList', runIds, 'tag', tagList);
            [rows, columns] = size(deleted_runs);
            assertEqual(testCase, rows, 0); % Zero row should match           
        end   
        
        function testDeleteRunsBySequenceNumber(testCase)
            fprintf('\n*** DeleteRunsBySequenceNumber: ***\n');
            
            generateTestRuns(testCase);
                        
            sequenceNumber = 2;
            noop = false;
            
            % Delete the runs
            testCase.mgr.deleteRuns('sequenceNumber', sequenceNumber, 'noop', noop);
     
            if ~noop
                runs = testCase.mgr.listRuns(); % List the runs
                [rows, cols] = size(runs);
                assertEqual(testCase, rows, 2); % Only 2 rows should be left
            else
                runs = testCase.mgr.listRuns();
                [rows, cols] = size(runs);
                assertEqual(testCase, rows, 3); % 3 rows should be there because no delete is applied
            end
        end 
        
        function testViewByPackageIdOnly(testCase)
            fprintf('\n\nTest for ViewByPackageIdOnly function:\n');
           
            generateTestRuns(testCase);

            pkgId = testCase.mgr.execution.data_package_id ;
            
            sessions = {'details', 'used', 'generated'};
            resultObjs = testCase.mgr.view('packageId', pkgId, 'sessions', sessions); % view the selected run
            numOfObjects = size(resultObjs, 2);
            assertGreaterThanOrEqual(testCase, numOfObjects, 1);   
            
            detailsView = resultObjs{1,1};
            assertEqual(testCase, detailsView.Tag, 'test_tag_3');
            assertEqual(testCase, detailsView.RunSequenceNumber, '3');
        end        
        
        function testViewBySequenceNumberOnly(testCase)
            fprintf('\n\nTest for ViewBySequenceNumberOnly function:\n');
           
            generateTestRuns(testCase);

            sequenceNumber = 2;
            
            sessions = {'details', 'used', 'generated'};
            resultObjs = testCase.mgr.view('sequenceNumber', sequenceNumber, 'sessions', sessions); % view the selected run
            numOfObjects = size(resultObjs, 2);
            assertGreaterThanOrEqual(testCase, numOfObjects, 1);   
            
            detailsView = resultObjs{1,1};
            assertEqual(testCase, detailsView.Tag, 'test_tag_2');
            assertEqual(testCase, detailsView.RunSequenceNumber, '2');
        end 
        
        function testPublish(testCase)
            fprintf('\n\nTest for the publish() function:\n\n');
            
            fprintf(['For testPublish() to succeed, you must log into ' ...
                     'https://cilogon.org/?skin=DataONEDev and \n ' ...
                     'download your X509 certificate to /tmp/x509up_u501.']);
                 
            testCase.filename = 'src/test/resources/C3_C4_map_present_NA_Markup_v2_7.m';
            %testCase.filename = 'src/test/resources/myScript02.m';
            set(testCase.mgr.configuration, 'certificate_path', '/tmp/x509up_u501');
            set(testCase.mgr.configuration, 'authentication_token', 'xxxxxxxxxxxxxW7FsqiW_7Hcg');
            
            scriptPath = which(testCase.filename); % get the absolute path of the script
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            [scriptParentPath, name, ext] = fileparts(scriptPath);
            tag = 'myscript2'; 
 
            currentDir = pwd();
            cd(scriptParentPath);
            testCase.mgr.record(scriptPath, tag);  
            cd(currentDir);

            set(testCase.mgr.configuration, ...
                'target_member_node_id', 'urn:node:mnDevUCSB2');
       
            %set(testCase.mgr.configuration, ...
            %    'target_member_node_id', 'urn:node:mnDevUNM2');
            
            set(testCase.mgr.configuration, ...
                'coordinating_node_base_url', 'https://cn-dev-2.test.dataone.org/cn');
            
            runs = testCase.mgr.listRuns();
            pkgId = runs{1,1};
            testCase.mgr.publish(pkgId);
            runs = testCase.mgr.listRuns();
        end 
    end
    
    methods (Access = 'private')
        
        function generateTestRuns(testCase)
        % GENERATETESTRUNS generates test runs and adds them to the database    
            
            % Create run entry 1
            import org.dataone.client.run.Execution;
            run1 = Execution();
            set(run1, 'tag', 'test_tag_1');
            set(run1, 'execution_uri', ...
                [testCase.mgr.configuration.coordinating_node_base_url ...
                '/v2/resolve' run1.execution_id]);
            set(run1, 'start_time', '20150930T101049');
            set(run1, 'end_time', '20150930T101149');
            set(run1, 'software_application', 'test_data_input1.m');
            set(run1, 'sequence_number', '1');
            testCase.mgr.execution = run1;
            createFakeExecution(testCase);
            
            % Create run entry 2
            run2 = Execution();
            set(run2, 'tag', 'test_tag_2');
            set(run2, 'execution_uri', ...
                [testCase.mgr.configuration.coordinating_node_base_url ...
                '/v2/resolve' run2.execution_id]);
            set(run2, 'start_time', '20151006T101049');
            set(run2, 'end_time', '20151006T101149');
            testCase.mgr.execution = run2;
            set(run2, 'software_application', 'test_data_input2.m');
            set(run2, 'sequence_number', '2');
            createFakeExecution(testCase);

            % Create run entry 3
            run3 = Execution();
            set(run3, 'tag', 'test_tag_3');
            set(run3, 'execution_uri', ...
                [testCase.mgr.configuration.coordinating_node_base_url ...
                '/v2/resolve' run3.execution_id]);
            set(run3, 'start_time', '20301030T101049');
            set(run3, 'end_time', '20301030T101249');
            set(run3, 'software_application', 'test_data_input3.m');
            set(run3, 'sequence_number', '3');
            testCase.mgr.execution = run3;
            createFakeExecution(testCase);

        end
        
        function createFakeExecution(testCase)
        % CREATEFAKEEXECUTION creates a create execution in the configuration directory
            
            % Write the execution entry to the file
            runID = char(testCase.mgr.execution.execution_id);
            filePath = char(testCase.mgr.execution.software_application);
            startTime = char(testCase.mgr.execution.start_time);
            endTime = char(testCase.mgr.execution.end_time);
            publishedTime = char(testCase.mgr.execution.publish_time);
            packageId = char(testCase.mgr.execution.data_package_id);
            tag = testCase.mgr.execution.tag;  
            user = char(testCase.mgr.execution.account_name);
            subject = 'CN=Test User, dc=dataone, dc=org'; 
            hostId = char(testCase.mgr.execution.host_id);
            operatingSystem = char(testCase.mgr.execution.operating_system);
            runtime = char(testCase.mgr.execution.runtime);
            moduleDependencies = char(testCase.mgr.execution.module_dependencies);
            console = '';
            errorMessage = char(testCase.mgr.execution.error_message);
            seqNo = char(testCase.mgr.execution.sequence_number);
            
            formatSpec = testCase.mgr.configuration.execution_db_write_format;
            
            if ( exist(testCase.mgr.configuration.execution_db_name, 'file') ~= 2 )
                [fileId, message] = ...
                    fopen(testCase.mgr.configuration.execution_db_name, 'w');
                fprintf(fileId, formatSpec, 'runId', 'filePath', ...
                    'startTime', 'endTime', 'publishedTime', ...
                    'packageId', 'tag', 'user', 'subject', 'hostId', ...
                    'operatingSystem', 'runtime', 'moduleDependencies', ...
                    'console', 'errorMessage', 'sequence_number');
                fprintf(fileId, formatSpec, runID, filePath, startTime, ...
                    endTime, publishedTime, packageId, tag, user, subject, ...
                    hostId, operatingSystem, runtime, moduleDependencies, ...
                    console, errorMessage, seqNo);   
                
            else    
                [fileId, message] = ...
                    fopen(testCase.mgr.configuration.execution_db_name, 'a');
                fprintf(fileId, formatSpec, runID, filePath, startTime, ...
                    endTime, publishedTime, packageId, tag, user, subject, ...
                    hostId, operatingSystem, runtime, moduleDependencies, ...
                    console, errorMessage, seqNo);
                
            end
            
            fclose(fileId);
                 
            % Then create the run directory for the given run
            runDirectory = fullfile(...
                testCase.mgr.configuration.provenance_storage_directory, ...
                'runs', ...
                testCase.mgr.execution.execution_id);
            
            if ( isprop(testCase.mgr.execution, 'execution_id') )
                if ( exist(runDirectory, 'dir') ~= 7 )
                    mkdir(runDirectory);
                end                
            end
        end
        
        function resetEnvironment(testCase)
        % RESETENVIRONMENT resets the Matlab DataONE Toolbox environment
            
            try
                if ( isprop(testCase.mgr.configuration, 'configuration_directory') )
                    rmpath(fullfile(testCase.mgr.execution.execution_directory));
                    rmdir(testCase.mgr.configuration.configuration_directory, 's');
                end
                
            catch IOError
                disp(IOError);
                
            end

        end
    end
end
