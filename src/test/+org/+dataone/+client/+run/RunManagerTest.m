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
    end

    methods (TestMethodSetup)
        
        function setUp(testCase)
            % SETUP Set up the test environment

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

            import org.dataone.client.run.RunManager;
            
            mgr = RunManager.getInstance();
            old_format_id = get(mgr.configuration, 'format_id');
            set(mgr.configuration, 'format_id', 'application/octet-stream');
            assertInstanceOf(testCase, mgr, 'org.dataone.client.run.RunManager');
            % Test a single default property to ensure the configuration was set
            assertEqual(testCase, mgr.configuration.format_id, 'application/octet-stream');
            
            % reset to the original
            set(mgr.configuration, 'format_id', old_format_id);

        end
        
        function testGetInstanceWithConfiguration(testCase)
            % TESTGETINSTANCENOCONFIGURATION tests calling the getInstance()
            % function while passing a Configuration object

            import org.dataone.client.run.RunManager;
            import org.dataone.client.configure.Configuration;
            
            configuration = Configuration();
            
            mgr = RunManager.getInstance(configuration);
            old_format_id = get(mgr.configuration, 'format_id');
            set(mgr.configuration, 'format_id', 'text/csv');
            
            % Test the instance type
            assertInstanceOf(testCase, mgr, 'org.dataone.client.run.RunManager');
            % Test a single preset property
            assertEqual(testCase, mgr.configuration.format_id, 'text/csv');
            
            % reset to the original
            set(mgr.configuration, 'format_id', old_format_id);

            %% Test for YesWorkflow  
            mgr.record('/Users/syc/Documents/matlab-dataone/DroughtTimeScale_Markup_v2.m', '');
         %  mgr.startRecord('test_mstmip');
            
            if (mgr.configuration.generate_workflow_graphic)
                % Convert .gv files to .png files
                system('/usr/local/bin/dot -Tpng test_mstmip_combined_view.gv -o test_mstmip_combined_view.png');
                system('/usr/local/bin/dot -Tpng test_mstmip_data_view.gv -o test_mstmip_data_view.png');
                system('/usr/local/bin/dot -Tpng test_mstmip_process_view.gv -o test_mstmip_process_view.png');
            
                % Display 3 different views of YesWorkflow output files
                system('/usr/bin/open test_mstmip_process_view.png');
                system('/usr/bin/open test_mstmip_data_view.png');
                system('/usr/bin/open test_mstmip_combined_view.png');
            end
            
        end

    end
end