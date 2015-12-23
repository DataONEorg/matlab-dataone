% RUN_TESTS A script used to run Matlab tests in the Matlab DataONE
% Toolbox.
% Run the tests. Note that the current directory should be the parent
% directory of the 'test' directory when running tests via this script. In
% the matlab-dataone repo, this is the 'src' directory.
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

% Create a suite of all client tests 

warning off MATLAB:dispatcher:nameConflict;
addpath(genpath(pwd));
warning on MATLAB:dispatcher:nameConflict;

warning('off','backtrace');
 
import matlab.unittest.TestSuite;

% Use fromPackage
% suite = TestSuite.fromPackage('org.dataone.client', 'IncludingSubpackages', true);
% suite = TestSuite.fromPackage('org.dataone.client.configure', 'IncludingSubpackages', true);
% suite = TestSuite.fromPackage('org.dataone.client.run', 'IncludingSubpackages', true);
% suite = TestSuite.fromPackage('org.dataone.client.v2', 'IncludingSubpackages', true);

% Use fromClass
% testCls = ?org.dataone.client.configure.ConfigurationTest;
% testCls = ?org.dataone.client.run.ExecutionTest;
% testCls = ?org.dataone.client.run.RunManagerTest;
% suite = TestSuite.fromClass(testCls);

% Use fromMethod
testCls = ?org.dataone.client.run.RunManagerTest;
% suite = TestSuite.fromMethod(testCls, 'testGetInstanceNoConfiguration');
% suite = TestSuite.fromMethod(testCls, 'testGetInstanceWithConfiguration'); 
% suite = TestSuite.fromMethod(testCls, 'testListRunsNoParams'); 
% suite = TestSuite.fromMethod(testCls, 'testListRunsAllParams'); 
% suite = TestSuite.fromMethod(testCls, 'testListRunsStartDateOnly'); 
% suite = TestSuite.fromMethod(testCls, 'testListRunsEndDateOnly'); 
% suite = TestSuite.fromMethod(testCls, 'testListRunsStartDateEndDateOnly'); 
% suite = TestSuite.fromMethod(testCls, 'testListRunsStartDateEndDateTagsOnly'); 
% suite = TestSuite.fromMethod(testCls, 'testListRunsStartDateTagsOnly'); 
% suite = TestSuite.fromMethod(testCls, 'testListRunsEndDateTagsOnly'); 
% suite = TestSuite.fromMethod(testCls, 'testListRunsTagsOnly'); 
% suite = TestSuite.fromMethod(testCls, 'testDeleteRunsByTags');
% suite = TestSuite.fromMethod(testCls, 'testDeleteRunsByTagsRunIdsOnly');

% suite = TestSuite.fromMethod(testCls, 'testOverloadedCSVread'); 
% suite = TestSuite.fromMethod(testCls, 'testOverloadedDlmread');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedLoad'); % Fails, same as above
% suite = TestSuite.fromMethod(testCls, 'testOverloadedNCopen'); 
% suite = TestSuite.fromMethod(testCls, 'testOverloadedNCread'); % Fails, same as above
% suite = TestSuite.fromMethod(testCls, 'testOverloadedNCwrite'); 
% suite = TestSuite.fromMethod(testCls, 'testOverloadedCdfread'); 
% suite = TestSuite.fromMethod(testCls, 'testOverloadedCdfwrite'); 
% suite = TestSuite.fromMethod(testCls, 'testOverloadedH5read'); 
% suite = TestSuite.fromMethod(testCls, 'testOverloadedH5write'); 
% suite = TestSuite.fromMethod(testCls, 'testOverloadedHdfread'); 
% suite = TestSuite.fromMethod(testCls, 'testOverloadedHdfinfo');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedTextread');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedReadtable');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedWritetable');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedImread');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedImwrite');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedXmlread');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedXmlwrite');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedMultibandwrite');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedMultibandread');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedFitswrite');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedFitsread');
 
% suite = TestSuite.fromMethod(testCls, 'testPublish'); 
% suite = TestSuite.fromMethod(testCls, 'testRecord'); 
% suite = TestSuite.fromMethod(testCls, 'testViewByPackageIdOnly'); 
% suite = TestSuite.fromMethod(testCls, 'testViewBySequenceNumberOnly'); 
% suite = TestSuite.fromMethod(testCls, 'testYesWorkflow');

% suite = TestSuite.fromMethod(testCls, 'testMNodeGet');
% suite = TestSuite.fromMethod(testCls, 'testMNodeCreate');
% suite = TestSuite.fromMethod(testCls, 'testMNodeUpdate'); 
 suite = TestSuite.fromMethod(testCls, 'testMNodeListObjects'); 
% suite = TestSuite.fromMethod(testCls, 'testMNodeGetChecksum'); 


% suite = TestSuite.fromMethod(testCls, 'testPutMetadataWithSalutationConfigAndDomElement'); 
% suite = TestSuite.fromMethod(testCls, 'testPutMetadataWithSalutationNoDomElement'); 
% suite = TestSuite.fromMethod(testCls, 'testPutMetadataWithoutSalutationConfigWithDomElement'); 
% suite = TestSuite.fromMethod(testCls, 'testPutMetadataWithoutSalutationConfigNoDomElement');
% suite = TestSuite.fromMethod(testCls, 'testGetMetadata');

% testCls = ?org.dataone.client.v2.MNodeTest;
% suite = TestSuite.fromMethod(testCls, 'testMNodeGet');
% suite = TestSuite.fromMethod(testCls, 'testMNodeCreate');
% suite = TestSuite.fromMethod(testCls, 'testMNodeUpdate');

run(suite);

% rmpath(genpath(pwd));