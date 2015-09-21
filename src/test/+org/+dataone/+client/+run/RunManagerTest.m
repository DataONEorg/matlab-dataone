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
            testCase.yw_process_view_property_file_name = 'test/resources/yw_process_view_4.properties'; 
            testCase.yw_data_view_property_file_name = 'test/resources/yw_data_view_4.properties'; 
            testCase.yw_comb_view_property_file_name = 'test/resources/yw_comb_view_4.properties'; 
        end
    end
    
    methods (TestMethodTeardown)
        
        function tearDown(testCase)
            % TEARDOWN Tear down the test environment
            
        end
    end
    
    methods (Test)
        
        function testGetInstanceNoConfiguration(testCase)
            % TESTGETINSTANCENOCONFIGURATION tests calling the getInstance()
            % function without passing a Configuration object

            fprintf('\nIn testGetInstanceNoConfiguration() ...\n');
            old_format_id = get(testCase.mgr.configuration, 'format_id');
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
        
        
        %function testYesWorkflow(testCase)
        %    fprintf('\nIn testYesWorkflow() ...\n');
            
        %    testCase.filename = 'test/resources/C3_C4_map_present_NA_Markup_v2_3.m';
              
        %    scriptPath = fullfile(pwd(), filesep, testCase.filename); 
                          
        %    yw_process_view_properties_path = fullfile(pwd(), filesep, testCase.yw_process_view_property_file_name);
        %    testCase.mgr.PROCESS_VIEW_PROPERTY_FILE_NAME = yw_process_view_properties_path;
           
        %    yw_data_view_properties_path = fullfile(pwd(), filesep, testCase.yw_data_view_property_file_name);
        %    testCase.mgr.DATA_VIEW_PROPERTY_FILE_NAME = yw_data_view_properties_path;
            
        %    yw_comb_view_properties_path = fullfile(pwd(), filesep, testCase.yw_comb_view_property_file_name);
        %    testCase.mgr.COMBINED_VIEW_PROPERTY_FILE_NAME = yw_comb_view_properties_path;
           
        %    testCase.mgr.runDir = '/tmp';
        %    testCase.mgr.callYesWorkflow(scriptPath, testCase.mgr.runDir);
        %end
           
        
        function testRecord(testCase)
            fprintf('\nIn testRecord() ...\n');
     
            testCase.filename = 'test/resources/C3_C4_map_present_NA_Markup_v2_4.m';
                         
            script_path = fullfile(pwd(), filesep, testCase.filename);  % Script path 
            
            tag = 'test_view'; % TODO: multiple tags passed in
          
            yw_process_view_properties_path = fullfile(pwd(), filesep, testCase.yw_process_view_property_file_name);
            testCase.mgr.PROCESS_VIEW_PROPERTY_FILE_NAME = yw_process_view_properties_path;
           
            yw_data_view_properties_path = fullfile(pwd(), filesep, testCase.yw_data_view_property_file_name);
            testCase.mgr.DATA_VIEW_PROPERTY_FILE_NAME = yw_data_view_properties_path;
            
            yw_comb_view_properties_path = fullfile(pwd(), filesep, testCase.yw_comb_view_property_file_name);
            testCase.mgr.COMBINED_VIEW_PROPERTY_FILE_NAME = yw_comb_view_properties_path;
        
            testCase.mgr.record(script_path, tag);
        end
        
        
        %function testOverloadedNcread(testCase)
        %    fprintf('\nIn testOverloadedNcread() ...\n');            
        %    testCase.filename = 'test/resources/myScript1.m';
        %    results = runtests(testCase.filename);  
        %end
        
        
        %function testOverloadedNcwrite(testCase)
        %    fprintf('\nIn testOverloadedNcwrite() ...\n');            
        %    testCase.filename = 'test/resources/myScript2.m';
        %    results = runtests(testCase.filename);  
        %end
        
        %function testListRuns(testCase)
            %fprintf('\n\nTest for ListRuns(runManager, quiet, startDate, endDate, tags) function:\n');
            
            %quiet = false;
            %startDate = '20150731T102515';
            %endDate = datestr(now, 30);
            %tagList = {'1', '3'};
            
            %fprintf('*** startDate and endDate both required: ***\n');
            %runs = testCase.mgr.listRuns(quiet, startDate, endDate, '');
                     
            %fprintf('*** startDate only required: ***\n');
            %runs = testCase.mgr.listRuns(quiet, startDate, '', '');
  
            %fprintf('*** endDate only required: ***\n');
            %runs = testCase.mgr.listRuns(quiet, '', endDate, '');
            
            %fprintf('*** No query parameters are required: ***\n');
            %runs = testCase.mgr.listRuns(quiet, '', '', '');
            
            %fprintf('*** startDate, endDate and tags all required: ***\n');
            %runs = testCase.mgr.listRuns(quiet, startDate, endDate, tagList);
                     
            %fprintf('*** startDate and tags are required: ***\n');
            %runs = testCase.mgr.listRuns(quiet, startDate, '', tagList);
  
            %fprintf('*** endDate and tags are required: ***\n');
            %runs = testCase.mgr.listRuns(quiet, '', endDate, tagList);
            
            %fprintf('*** tags is required only: ***\n');
            %runs = testCase.mgr.listRuns(quiet, '', '', tagList);
        %end
        
        
        function testView(testCase)
            fprintf('\n\nTest for view(packageId) function:\n');
            sessions = {'details', 'generated'};
            pkgId = 'urn:uuid:3e278252-b475-4feb-aa81-d2bfec818abe';
            testCase.mgr.view(pkgId, sessions); % view the selected run
            
            sessions = {};
            testCase.mgr.view(pkgId, sessions); % view the selected run
            
            sessions = {'details', 'used', 'generated'};
            testCase.mgr.view(pkgId, sessions); % view the selected run
        end
        
        
        function testPublishPackageFromDisk(testCase)
            fprintf('\n\nTest for publishPackageFromDisk() function:\n');
            pkgId = 'urn:uuid:3e278252-b475-4feb-aa81-d2bfec818abe';
            set(testCase.mgr.configuration, 'target_member_node_id', 'urn:node:mnDemo5');
            testCase.mgr.publishPackageFromDisk(pkgId);
        end
        
        
        %function testDeleteRuns(testCase)
           %fprintf('\n\nTest for deletionRuns(runIdList, startDate, endDate, tags, noop, quiet) function:\n');
            
           % quiet = false;
           % noop = true;
            
            % With query parameters for startDate or endDate
           % startDate = '20150804T102515';
           % endDate = datestr(now, 30);
            
            % Without query parameters for startDate and endDate
            %startDate = '';
            %endDate = '';
            
            %tag = '';
            %runIdList = {'8c28b610-4932-47c1-a040-d8e3dfce5ddf', '84abb73f-2f13-49b7-8c45-9c1e0434b31f'};
           % tagList = {'2', '1'};
           % runIdList = '';
           % testCase.mgr.deleteRuns(runIdList, startDate, endDate, tagList, noop, quiet);
        %end
        
        
        %function testPublish(testCase)
        %   TESTPUBLISH tests calling the RunManager.publish() function

        %    import org.dataone.client.run.RunManager;
        %    import org.dataone.client.configure.Configuration;
            
        %    disp('In testPublish() ...');
        %    set(testCase.mgr.configuration, 'target_member_node_id', 'urn:node:mnDemo5');
           
        %    testCase.mgr.runDir = 'test/resources/runs';
        %    k = strfind(testCase.mgr.execution.execution_id, 'urn:uuid:'); % get the index of 'urn:uuid:'            
        %    runId = testCase.mgr.execution.execution_id(k+9:end);
        %    pkgId = testCase.mgr.publish(runId);
        %end
         
    end
end
