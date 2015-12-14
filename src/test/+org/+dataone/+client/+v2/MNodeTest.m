% MNODETEST A class used to test the org.dataone.client.v2.MemberNode class functionality
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

classdef MNodeTest < matlab.unittest.TestCase
    
    
    properties
        % The RunManager instance used in the tests
        mgr;
        
        
    end
    
    methods (TestMethodSetup)
        
        function setUp(testCase)
            
            % Set the test configuration directory
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

        end
        
    end
    
    methods (TestMethodTeardown)
        
        function tearDown(testCase)
            
            % Reset the Matlab DataONE Toolbox environment
            resetEnvironment(testCase);

        end
        
    end
    
    methods (Test)
        
        function testMNodeGet(testCase)
        % TESTMNODEGET Tests the DataONE get() API call to a Member Node
        
        end
        
        function testMNodeCreate(testCase)
        % TESTMNODECREATE Tests the DataONE create() API call to a Member Node
        
        end

        function testMNodeUpdate(testCase)
        % TESTMNODEGET Tests the DataONE update() API call to a Member Node
        
        end

    end
    
    methods (Access = 'private')
        
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