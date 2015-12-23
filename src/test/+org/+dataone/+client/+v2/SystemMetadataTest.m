% SYSTEMMETADATATEST A class used to test the org.dataone.client.v2.SystemMetadata class functionality
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

classdef SystemMetadataTest < matlab.unittest.TestCase
    
    properties
    end

    methods (Test)
        
        function testInstantiate(testCase)
            % TESTINSTANTIATE tests instantiation of the object
            
            import org.dataone.client.v2.SystemMetadata;
            sysmeta = SystemMetadata();
            
            testCase.assertInstanceOf(sysmeta, 'org.dataone.client.v2.SystemMetadata');
            testCase.assertTrue(isstruct(sysmeta.accessPolicy));
            testCase.assertTrue(isstruct(sysmeta.replicationPolicy));
            testCase.assertTrue(isstruct(sysmeta.checksum));
        end
    end
    
end