% COORDINATINGNODETEST A class used to test the org.dataone.client.v2.CoordinatingNode class functionality
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

classdef CoordinatingNodeTest < matlab.unittest.TestCase
    
    
    properties
        % The RunManager instance used in the tests
        mgr;
        
        filename
    end
    
    methods (TestMethodSetup)
        
        function setUp(testCase)
            import org.dataone.client.run.RunManager;
            import org.dataone.client.configure.Configuration;
            
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
     
        function testGetCapabilities(testCase)
            
            fprintf('\nIn test Coordinating Node getCapabilities() ...\n');
            
            import org.dataone.client.v2.CoordinatingNode;
            
            % Get a CNode matlab instance to the coordinating node
            matlab_cn_node = CoordinatingNode('https://cn-dev-2.test.dataone.org/cn');
            
            node_description = matlab_cn_node.getCapabilities();
           
            assert(~isempty(node_description));
        end
        
        
        function testPing(testCase)
            
            fprintf('\nIn test Coordinating Node ping() ...\n');
            
            import org.dataone.client.v2.CoordinatingNode;
            
            % Get a CNode matlab instance to the member node
            matlab_cn_node = CoordinatingNode('https://cn-dev-2.test.dataone.org/cn');
            
            date = matlab_cn_node.ping();
 
            assert(~isempty(date));
        end
        
        function testListObjects(testCase)
            
            fprintf('\nIn test Coordinating Node listObjects() ...\n');
            
            import org.dataone.client.v2.CoordinatingNode;
            import org.dataone.service.types.v1.Identifier;
            
            % Get a CNode matlab instance
            matlab_cn_node = CoordinatingNode('https://cn-dev-2.test.dataone.org/cn');
            
            % Use matlab wrapper function 
            [ol1, start1, count1, total1] = matlab_cn_node.listObjects([], [], [], [], [], [], [], []);
            assertEqual(testCase, start1, 0);

            [ol2, start2, count2, total2] = matlab_cn_node.listObjects([], [], [], [], [], [], '100', '50');
            assertEqual(testCase, start2, 100);
            assertEqual(testCase, count2, 50);
            
            assertEqual(testCase, total1, total2);
            
            [ol3, start3, count3, total3] = matlab_cn_node.listObjects([], [], [], [], [], [], '0', 50000);
            assertEqual(testCase, count3, length(ol3));
                  
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

