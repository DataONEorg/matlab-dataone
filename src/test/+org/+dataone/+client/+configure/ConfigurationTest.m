% CONFIGURATIONTEST A class used to test configuration options for the DataONE Toolbox
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

classdef ConfigurationTest < matlab.unittest.TestCase
    %CONFIGURATIONTEST tests configuration options for the DataONE Toolbox
    
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
        function testSetGet(testCase)
            import org.dataone.client.configure.Configuration;
   
            c = Configuration();
            set(c, 'debug', 'true');
            
            if ispc
                home_dir = getenv('USERPROFILE');
                
            elseif isunix
                home_dir = getenv('HOME');
                
            else
                error('Current platform not supported.');
                
            end
            
            c.set('provenance_storage_directory', ...
                strcat(home_dir, filesep,'.d1', filesep, 'provenance'));
            if ( ispc )
                testCase.verifyEqual(c.get('provenance_storage_directory'), ...
                    [home_dir filesep '.d1' filesep 'provenance']);
                
            elseif ( isunix )
                testCase.verifyEqual(c.get('provenance_storage_directory'), ...
                    [home_dir filesep '.d1' filesep 'provenance']);
  
            end
            
            c.set('format_id', 'FGDC-STD-001-1998');
            testCase.verifyEqual(c.get('format_id'), 'FGDC-STD-001-1998');

            c.set('certificate_path', '/tmp');
            testCase.verifyEqual(c.get('certificate_path'), '/tmp');
            
            c.set('number_of_replicas ', 3);
            testCase.verifyEqual(c.get(' number_of_replicas'), 3);
            
            c.set('number_of_replicas', 3.0);
            testCase.verifyEqual(c.get(' number_of_replicas'), 3.0);
             
        end
    end
    
end

