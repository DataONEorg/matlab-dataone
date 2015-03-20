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
        
        function testGetInstanceNoSession(testCase)
            % TESTGETINSTANCENOSESSION tests calling the getInstance()
            % function without passing a Session object

            import org.dataone.client.run.RunManager;
            
            mgr = RunManager.getInstance();
            assertInstanceOf(testCase, mgr, 'org.dataone.client.run.RunManager');
            % Test a single default property to ensure the session was set
            assertEqual(testCase, mgr.session.format_id, 'application/octet-stream');
            
        end
        
        function testGetInstanceWithSession(testCase)
            % TESTGETINSTANCENOSESSION tests calling the getInstance()
            % function while passing a Session object

            import org.dataone.client.run.RunManager;
            import org.dataone.client.configure.Session;
            
            session = Session();
            set(session, 'format_id', 'text/plain');
            
            mgr = RunManager.getInstance(session);
            assertInstanceOf(testCase, mgr, 'org.dataone.client.run.RunManager');
            % Test a single preset property
            assertEqual(testCase, mgr.session.format_id, 'text/plain');

        end
    end
end