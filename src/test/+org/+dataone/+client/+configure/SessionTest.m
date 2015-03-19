% SESSION A class used to set configuration options for the DataONE Toolbox
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

classdef SessionTest < matlab.unittest.TestCase
    %TESTCONFIGURESESSION Summary of this class goes here
    %   Detailed explanation goes here
    
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
            import org.dataone.client.configure.Session;
   
            s = Session();
            
            s.set('provenance_storage_directory', '/Users/syc/.d1/provenance');
            testCase.verifyEqual(s.get('provenance_storage_directory'), '/Users/syc/.d1/provenance');
            
            s.set('format_id', 'FGDC-STD-001-1998');
            testCase.verifyEqual(s.get('format_id'), 'FGDC-STD-001-1998');
            
         %   s.set('format_id', 'aaa');
         %   testCase.verifyError(@() Session.set('format_id', 'aaa'),'SessionError:format_id');
            
            s.set('certificate_path', '/tmp');
            testCase.verifyEqual(s.get('certificate_path'), '/tmp');
            
            s.set('number_of_replicas ', 3);
            testCase.verifyEqual(s.get(' number_of_replicas'), 3);
            
            s.set('number_of_replicas', 3.0);
            testCase.verifyEqual(s.get(' number_of_replicas'), 3.0);
            
         %   s.set('number_of_replicas', 3.5);
         %   testCase.verifyError(@() Session.set('number_of_replicas', 3.5),'SessionError:IntegerRequired')
            
            
          
        end
    end
    
end

