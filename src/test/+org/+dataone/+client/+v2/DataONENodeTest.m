% DATAONENODETEST A class used to test the org.dataone.client.v2.DataONENode class functionality
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

classdef DataONENodeTest < matlab.unittest.TestCase
    
    properties
        
        % The test configuration object
        cfg;
        
    end

    methods (TestMethodSetup)
        
        function setUp(testCase)
            % SETUP sets up the environment for each test
            
            import org.dataone.client.configure.Configuration;
            
            % Set the test configuration directory
            if ispc
                home_dir = getenv('USERPROFILE');
                
            elseif isunix
                home_dir = getenv('HOME');
                
            else
                error('Current platform not supported.');
                
            end
            
            % test_config_directory = fullfile(home_dir, '.d1test');
            
            % for unit testing, set the D1 directory to a test location
            % testCase.cfg = Configuration( ...
            %    'configuration_directory', test_config_directory);
            
            config = Configuration( ...
                'source_member_node_id', 'urn:node:mnDevUCSB2', ...
                'target_member_node_id', 'urn:node:mnDevUCSB2', ...
                'format_id', 'application/octet-stream', ...
                'submitter', 'submitter', ...
                'rights_holder', 'rightsHolder', ...
                'coordinating_node_base_url', 'https://cn-dev-2.test.dataone.org/cn', ...
                'certificate_path', '/tmp/x509up_u501', ...
                'authentication_token', '');
            
            testCase.mgr = RunManager.getInstance(config);
        end
        
    end

    methods (TestMethodTeardown)
        
        function tearDown(testCase)
            % TEARDOWN resets the environment after the test is run
            
            % Reset the Matlab DataONE Toolbox environment
            resetEnvironment(testCase);

        end
        
    end
    
    methods (Test)
        
    end
    
    methods (Access = 'private')
        
        function resetEnvironment(testCase)
        % RESETENVIRONMENT resets the Matlab DataONE Toolbox environment
            
            try
                if ( isprop(testCase.cfg, 'configuration_directory') )
                    rmdir(testCase.cfg.configuration_directory, 's');
                    
                end
                
            catch IOError
                disp(IOError);
                
            end

        end
    end
end