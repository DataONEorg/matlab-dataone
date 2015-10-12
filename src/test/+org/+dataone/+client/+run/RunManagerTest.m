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
            
            %testCase.filename = 'test/resources/C3_C4_map_present_NA_Markup_v2_3.m';
            testCase.filename = 'test/resources/myScript1.m';
            testCase.mgr = RunManager.getInstance();
            testCase.yw_process_view_property_file_name = 'test/resources/yw_process_view_7.properties'; 
            testCase.yw_data_view_property_file_name = 'test/resources/yw_data_view_7.properties'; 
            testCase.yw_comb_view_property_file_name = 'test/resources/yw_comb_view_7.properties'; 
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
            
            testCase.filename = 'test/resources/C3_C4_map_present_NA_Markup_v2_7.m';
              
            %scriptPath = fullfile(pwd(), filesep, testCase.filename); 
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            yw_process_view_properties_path = fullfile(pwd(), filesep, testCase.yw_process_view_property_file_name);
            testCase.mgr.PROCESS_VIEW_PROPERTY_FILE_NAME = yw_process_view_properties_path;
            
            yw_data_view_properties_path = fullfile(pwd(), filesep, testCase.yw_data_view_property_file_name);
            testCase.mgr.DATA_VIEW_PROPERTY_FILE_NAME = yw_data_view_properties_path;
            
            yw_comb_view_properties_path = fullfile(pwd(), filesep, testCase.yw_comb_view_property_file_name);
            testCase.mgr.COMBINED_VIEW_PROPERTY_FILE_NAME = yw_comb_view_properties_path;
           
            testCase.mgr.runDir = '/tmp';
            testCase.mgr.callYesWorkflow(scriptPath, testCase.mgr.runDir);
            
            % Test comb_view generated by yesWorkflow exists
            combFileName = testCase.mgr.getYWCombViewFileName();
            a = dir(testCase.mgr.runDir);
            b = struct2cell(a);
            existed = any(ismember(b(1,:), combFileName));
          
            assert(isequal(existed,1));           
        end           
        
        function testRecord(testCase)
            fprintf('\nIn testRecord() ...\n');
     
             testCase.filename = 'test/resources/C3_C4_map_present_NA_Markup_v2_7.m';
            % testCase.filename = 'test/resources/myScript1.m';
            % testCase.filename = 'test/resources/myScript2.m';
            % testCase.filename = '/Users/syc/Documents/matlab-dataone/src/test/resources/myScript2.m';
 
            script_path = which(testCase.filename); % get the absolute path of the script
            
            tag = 'c3_c4_1'; % TODO: multiple tags passed in
          
            yw_process_view_properties_path = which(testCase.yw_process_view_property_file_name);
            testCase.mgr.PROCESS_VIEW_PROPERTY_FILE_NAME = yw_process_view_properties_path;
            
            yw_data_view_properties_path = which(testCase.yw_data_view_property_file_name);
            testCase.mgr.DATA_VIEW_PROPERTY_FILE_NAME = yw_data_view_properties_path;
            
            yw_comb_view_properties_path = which(testCase.yw_comb_view_property_file_name);
            testCase.mgr.COMBINED_VIEW_PROPERTY_FILE_NAME = yw_comb_view_properties_path;
           
            testCase.mgr.record(script_path, tag);  
            
            % Test if one resource map exists 
            a = dir(testCase.mgr.runDir);
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
            testCase.filename = 'test/resources/myScript3.m';
            
            execInputIds = java.util.Hashtable();
            execOutputIds = java.util.Hashtable();
            
            testCase.mgr.setExecInputIds(execInputIds);
            testCase.mgr.setExecOutputIds(execOutputIds);
    
            run(testCase.filename);
        end        
              
        function testOverloadedNCread(testCase)
            fprintf('\nIn testOverloadedNcread() ...\n');            
            testCase.filename = 'test/resources/myScript1.m';
            
            execInputIds = java.util.Hashtable();
            execOutputIds = java.util.Hashtable();
            
            testCase.mgr.setExecInputIds(execInputIds);
            testCase.mgr.setExecOutputIds(execOutputIds);
         
            run(testCase.filename);
        end        
        
        function testOverloadedNCwrite(testCase)
            fprintf('\nIn testOverloadedNcwrite() ...\n');            
            testCase.filename = 'test/resources/myScript2.m';
            
            execInputIds = java.util.Hashtable();
            execOutputIds = java.util.Hashtable();
            
            testCase.mgr.setExecInputIds(execInputIds);
            testCase.mgr.setExecOutputIds(execOutputIds);
  
            run(testCase.filename);
        end        
        
        function testOverloadedCSVread(testCase)
            fprintf('\nIn testOverloadedCSVread() ...\n');            
            testCase.filename = 'test/resources/myScript4.m';
            
            execInputIds = java.util.Hashtable();
            execOutputIds = java.util.Hashtable();
            
            testCase.mgr.setExecInputIds(execInputIds);
            testCase.mgr.setExecOutputIds(execOutputIds);
  
            run(testCase.filename);
        end        
                       
        function testOverloadedLoad(testCase)
            % Todo: load coast (not working)
            fprintf('\nIn testOverloadedLoad() ...\n');            
            testCase.filename = 'test/resources/myScript5.m';
            % testCase.filename = 'test/resources/myScript1.m'; % load coast
            
            execInputIds = java.util.Hashtable();
            execOutputIds = java.util.Hashtable();
            
            testCase.mgr.setExecInputIds(execInputIds);
            testCase.mgr.setExecOutputIds(execOutputIds);
  
            run(testCase.filename);
        end        
        
        function testOverloadedDlmread(testCase)
            % Todo: load coast (not working)
            fprintf('\nIn testOverloadedDlmread ...\n');            
            testCase.filename = 'test/resources/myScript6.m';
            
            execInputIds = java.util.Hashtable();
            execOutputIds = java.util.Hashtable();
            
            testCase.mgr.setExecInputIds(execInputIds);
            testCase.mgr.setExecOutputIds(execOutputIds);
  
            run(testCase.filename);
        end        
                
        function testSaveExecution(testCase)
            fprintf('\nIn testSaveExecution() ...\n');
            
            execDBName = testCase.mgr.executionDatabaseName;  
            
            % Todo:
        end        
        
        function testListRunsNoParams(testCase)
            fprintf('\n*** testListRuns with no parameters: ***\n');
            
            generateTestRuns(testCase);
            
            runs = testCase.mgr.listRuns('', '', '', '');
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 3); % Three rows should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsAllParams(testCase)
            fprintf('\n*** testListRuns with all parameters: ***\n');
            
            generateTestRuns(testCase);
            
            quiet = false;
            startDate = '20151005T102515';
            endDate = '20151005T102515';
            tagList = {'test_tag_2'};
            
            runs = testCase.mgr.listRuns(quiet, startDate, endDate, tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsStartDateOnly(testCase)
            fprintf('\n*** testListRuns with startDate only: ***\n');

            generateTestRuns(testCase);

            startDate = '20151005T102515';
            runs = testCase.mgr.listRuns('', startDate, '', '');
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 2); % Two rows should match
            % TODO: Compare the execution ids
  
        end
        
        function testListRunsEndDateOnly(testCase)
            
            fprintf('\n*** testListRuns with endDate only: ***\n');

            generateTestRuns(testCase);

            endDate = '20151005T102515';
            runs = testCase.mgr.listRuns('', '', endDate, '');
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsStartDateEndDateOnly(testCase)
            
            fprintf('\n*** testListRuns with startDate and endDate only: ***\n');

            generateTestRuns(testCase);

            startDate = '20151005T102515';
            endDate = '20151007T102515';
            runs = testCase.mgr.listRuns('', startDate, endDate, '');
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids

        end
        
        function testListRunsStartDateEndDateTagsOnly(testCase)
            fprintf('\n*** testListRuns with startDate, endDate and tags only: ***\n');

            generateTestRuns(testCase);

            startDate = '20150930T082515';
            endDate = '20151007T102515';
            tagList = {'test_tag_2'};
            
            runs = testCase.mgr.listRuns('', startDate, endDate, tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsStartDateTagsOnly(testCase)
            fprintf('\n*** testListRuns with startDate and tags only: ***\n');

            generateTestRuns(testCase);

            startDate = '20150929T102515';
            tagList = {'test_tag_2'};
            
            runs = testCase.mgr.listRuns('', startDate, '', tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
        end

        function testListRunsEndDateTagsOnly(testCase)

            fprintf('\n*** testListRuns with endDate and tags required: ***\n');

            generateTestRuns(testCase);

            endDate = '20151005T102515';
            tagList = {'test_tag_2'};

            runs = testCase.mgr.listRuns('', '', endDate, tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsTagsOnly(testCase)
            fprintf('\n*** testListRuns with tags required only: ***\n');

            generateTestRuns(testCase);
            
            tagList = {'test_tag_3'};

            runs = testCase.mgr.listRuns('', '', '', tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end        
        
        function testView(testCase)
            fprintf('\n\nTest for view(packageId) function:\n');
            
            sessions = {'details', 'generated'};
            pkgId = 'urn:uuid:34e94476-bdcf-45d7-83b4-ea977248dd35';
            testCase.mgr.view(pkgId, sessions); % view the selected run
            
            sessions = {};
            testCase.mgr.view(pkgId, sessions); % view the selected run
            
            sessions = {'details', 'used', 'generated'};
            testCase.mgr.view(pkgId, sessions); % view the selected run
        end        
        
        function testPublishPackageFromDisk(testCase)
            fprintf('\n\nTest for publishPackageFromDisk() function:\n');
            
            pkgId = 'urn:uuid:518d685f-4204-4533-a714-1a6a9f075918';
            set(testCase.mgr.configuration, 'target_member_node_id', 'urn:node:mnDemo5');
            testCase.mgr.publishPackageFromDisk(pkgId);
        end        
        
        function testDeleteRuns(testCase)
            fprintf('\n\nTest for deletionRuns(runIdList, startDate, endDate, tags, noop, quiet) function:\n');
            
            quiet = false;
            noop = true;
            
            % With query parameters for startDate or endDate
            % startDate = '20150804T102515';
            % endDate = datestr(now, 30);
            
            % Without query parameters for startDate and endDate
            startDate = '';
            endDate = '';
            
            tagList = {'test_view_1'};
            runIdList = '';
            testCase.mgr.deleteRuns(runIdList, startDate, endDate, tagList, noop, quiet);
        end        
        
        function testPublish(testCase)
            % TESTPUBLISH tests calling the RunManager.publish() function

            import org.dataone.client.run.RunManager;
            import org.dataone.client.configure.Configuration;
            
            disp('In testPublish() ...');
            set(testCase.mgr.configuration, 'target_member_node_id', 'urn:node:mnDemo5');
           
            testCase.mgr.runDir = 'test/resources/runs';
            k = strfind(testCase.mgr.execution.execution_id, 'urn:uuid:'); % get the index of 'urn:uuid:'            
            runId = testCase.mgr.execution.execution_id(k+9:end);
            pkgId = testCase.mgr.publish(runId);
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
                '/v1/resolve' run1.execution_id]);
            set(run1, 'start_time', '20150930T101049');
            set(run1, 'end_time', '20150930T101149');
            testCase.mgr.execution = run1;
            createFakeExecution(testCase);
            
            % Create run entry 2
            run2 = Execution();
            set(run2, 'tag', 'test_tag_2');
            set(run2, 'execution_uri', ...
                [testCase.mgr.configuration.coordinating_node_base_url ...
                '/v1/resolve' run2.execution_id]);
            set(run2, 'start_time', '20151006T101049');
            set(run2, 'end_time', '20151006T101149');
            testCase.mgr.execution = run2;
            createFakeExecution(testCase);

            % Create run entry 3
            run3 = Execution();
            set(run3, 'tag', 'test_tag_3');
            set(run3, 'execution_uri', ...
                [testCase.mgr.configuration.coordinating_node_base_url ...
                '/v1/resolve' run3.execution_id]);
            set(run3, 'start_time', '20301030T101049');
            set(run3, 'end_time', '20301030T101249');
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
            
            formatSpec = testCase.mgr.configuration.execution_db_write_format;
            
            if ( exist(testCase.mgr.configuration.execution_db_name, 'file') ~= 2 )
                [fileId, message] = ...
                    fopen(testCase.mgr.configuration.execution_db_name, 'w');
                fprintf(fileId, formatSpec, 'runId', 'filePath', ...
                    'startTime', 'endTime', 'publishedTime', ...
                    'packageId', 'tag', 'user', 'subject', 'hostId', ...
                    'operatingSystem', 'runtime', 'moduleDependencies', ...
                    'console', 'errorMessage');
                fprintf(fileId, formatSpec, runID, filePath, startTime, ...
                    endTime, publishedTime, packageId, tag, user, subject, ...
                    hostId, operatingSystem, runtime, moduleDependencies, ...
                    console, errorMessage);   
                
            else    
                [fileId, message] = ...
                    fopen(testCase.mgr.configuration.execution_db_name, 'a');
                fprintf(fileId, formatSpec, runID, filePath, startTime, ...
                    endTime, publishedTime, packageId, tag, user, subject, ...
                    hostId, operatingSystem, runtime, moduleDependencies, ...
                    console, errorMessage);
                
            end
            
            fclose(fileId);
                
        end
        
        function resetEnvironment(testCase)
        % RESETENVIRONMENT resets the Matlab DataONE Toolbox environment
            
            try
                if ( isprop(testCase.mgr.configuration, 'configuration_directory') )
                    rmdir(testCase.mgr.configuration.configuration_directory, 's');
                end
                
            catch IOError
                disp(IOError);
                
            end

        end
    end
end
