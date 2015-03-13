% EXECUTIONTEST A class used to test the org.dataone.client.run.Execution class functionality
% Note that to run this test, the current directory should be the parent
% directory of the 'test' directory when running tests via this script. In
% the matlab-dataone repo, this is the 'src' directory.
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2015 DataONE
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

classdef ExecutionTest < matlab.unittest.TestCase
    
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
        
        function testSetTag(testCase)
            % TESTSETTAG Tests setting the tag property
            import org.dataone.client.run.Execution;
            import org.dataone.client.run.ExecutionTest;
            execution = Execution();
            set(execution, 'tag', 'calibration-coefficient=0.1234');
            returnValue = get(execution, 'tag');
            testCase.assertEqual('calibration-coefficient=0.1234', returnValue);
        end
        
        function testIsValidUUID(testCase)
            % TESTISVALIDUUID Test if particular properties are set wit a valid UUID URN
            
            import org.dataone.client.run.Execution;
            import org.dataone.client.run.ExecutionTest;
            execution = Execution();
            
            matchPattern = 'urn:uuid:[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}';
            execution_id = get(execution, 'execution_id');
            assertMatches(testCase, execution_id, matchPattern);
            
            data_package_id = get(execution, 'data_package_id');
            assertMatches(testCase, data_package_id, matchPattern);

        end
    end
    
end