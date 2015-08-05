% RUNMANAGERTEST A class used to test the org.dataone.client.run.RunManager class functionality
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

classdef RunManagerTest < matlab.unittest.TestCase
    
    properties 
        filename
        testDir
        mgr
    end

    methods (TestMethodSetup)
        
        function setUp(testCase)
            % SETUP Set up the test environment  
            
            import org.dataone.client.run.RunManager;
            
            % testCase.filename = 'test/resources/DroughtTimeScale_Markup_v2.m';
            testCase.filename = 'test/resources/C3_C4_map_present_NA_Markup_v2.m';
            testCase.testDir = 'test/resources';
            testCase.mgr = RunManager.getInstance();
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

            %% Test for YesWorkflow              
            script_path = fullfile(pwd(), filesep, testCase.filename); 
                 
            testCase.mgr.configuration.provenance_storage_directory = testCase.testDir;
            
            testCase.mgr.configuration.script_base_name = ''; % A user can give a prefix name to output files; otherwise, the script name will be used as prefix name.
            
            testCase.mgr.record(script_path, '');
        
            %if testCase.mgr.configuration.include_workflow_graphic
            %    curDir = pwd();
            %    cd(testCase.mgr.runDir); % go to the provenance run directory 
                % Display 3 different views of YesWorkflow output files
                % system('/usr/bin/open process_view.pdf');              
            %    cd(curDir);
            %end  
                
        end
        
        function testListRuns(testCase)
            fprintf('\n\nTest for ListRuns(runManager, quiet, startDate, endDate, tags) function:\n');
            
            quiet = false;
            startDate = '20150731T102515';
            endDate = datestr(now, 30);
            tagList = {'1', '3'};
            
            fprintf('*** startDate and endDate both required: ***\n');
            runs = testCase.mgr.listRuns(quiet, startDate, endDate, '');
                     
            %fprintf('*** startDate only required: ***\n');
            %runs = testCase.mgr.listRuns(quiet, startDate, '', '');
  
            %fprintf('*** endDate only required: ***\n');
            %runs = testCase.mgr.listRuns(quiet, '', endDate, '');
            
            fprintf('*** No query parameters are required: ***\n');
            runs = testCase.mgr.listRuns(quiet, '', '', '');
            
            fprintf('*** startDate, endDate and tags all required: ***\n');
            runs = testCase.mgr.listRuns(quiet, startDate, endDate, tagList);
                     
            fprintf('*** startDate and tags are required: ***\n');
            runs = testCase.mgr.listRuns(quiet, startDate, '', tagList);
  
            fprintf('*** endDate and tags are required: ***\n');
            runs = testCase.mgr.listRuns(quiet, '', endDate, tagList);
            
            fprintf('*** tags is required only: ***\n');
            runs = testCase.mgr.listRuns(quiet, '', '', tagList);
        end
        
        
        function testView(testCase)
            fprintf('\n\nTest for view(packageId) function:\n');
            testCase.mgr.view(testCase.mgr.execution.data_package_id);
           
        end
        
        
        function testDeleteRuns(testCase)
            fprintf('\n\nTest for deletionRuns(runIdList, startDate, endDate, tags, noop, quiet) function:\n');
            
            quiet = false;
            noop = false;
            
            % With query parameters for startDate or endDate
            startDate = '20150804T102515';
            endDate = datestr(now, 30);
            
            % Without query parameters for startDate and endDate
            %startDate = '';
            %endDate = '';
            
            %tag = '';
            %runIdList = {'8c28b610-4932-47c1-a040-d8e3dfce5ddf', '84abb73f-2f13-49b7-8c45-9c1e0434b31f'};
            tagList = {'2', '1'};
            runIdList = '';
            testCase.mgr.deleteRuns(runIdList, startDate, endDate, tagList, noop, quiet);
        end
        
        % function testPublish(testCase)
           % TESTPUBLISH tests calling the RunManager.publish() function

        %    import org.dataone.client.run.RunManager;
        %    import org.dataone.client.configure.Configuration;
            
        %    disp('In testPublish() ...');
        %    set(testCase.mgr.configuration, 'target_member_node_id', 'urn:node:mnDemo5');
           
        %    testCase.mgr.runDir = 'test/resources/runs';
        %    k = strfind(testCase.mgr.execution.execution_id, 'urn:uuid:'); % get the index of 'urn:uuid:'            
        %    runId = testCase.mgr.execution.execution_id(k+9:end);
        %    pkgId = testCase.mgr.publish(runId);
        % end
    end
end
