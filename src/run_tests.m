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

import matlab.unittest.TestSuite;

% Use fromPackage
% suite = TestSuite.fromPackage('org.dataone.client', 'IncludingSubpackages', true);

% Use fromClass
% testCls = ?org.dataone.client.configure.ConfigurationTest;
% testCls = ?org.dataone.client.run.ExecutionTest;
% testCls = ?org.dataone.client.run.RunManagerTest;
% suite = TestSuite.fromClass(testCls);

% Use fromMethod
testCls = ?org.dataone.client.run.RunManagerTest;
% suite = TestSuite.fromMethod(testCls, 'testGetInstanceNoConfiguration'); % Succeeds
% suite = TestSuite.fromMethod(testCls, 'testGetInstanceWithConfiguration'); % Succeeds
% suite = TestSuite.fromMethod(testCls, 'testListRunsNoParams'); % Succeeds
% suite = TestSuite.fromMethod(testCls, 'testListRunsAllParams'); % Succeeds
% suite = TestSuite.fromMethod(testCls, 'testListRunsStartDateOnly'); % Succeeds
% suite = TestSuite.fromMethod(testCls, 'testListRunsEndDateOnly'); % Succeeds
% suite = TestSuite.fromMethod(testCls, 'testListRunsStartDateEndDateOnly'); % Succeeds
% suite = TestSuite.fromMethod(testCls, 'testListRunsStartDateEndDateTagsOnly'); % Fails due to logical OR in listRuns()
% suite = TestSuite.fromMethod(testCls, 'testListRunsStartDateTagsOnly'); % Fails due to logical OR in listRuns()
% suite = TestSuite.fromMethod(testCls, 'testListRunsEndDateTagsOnly'); % Fails due to logical OR in listRuns()
% suite = TestSuite.fromMethod(testCls, 'testListRunsTagsOnly'); % Fails due to dateCondition set to true line 1258
% suite = TestSuite.fromMethod(testCls, 'testDeleteRunsByTags');
 suite = TestSuite.fromMethod(testCls, 'testDeleteRunsByTagsRunIdsOnly');
% suite = TestSuite.fromMethod(testCls, 'testOverloadedCSVread'); % Fails: Error using cd Cannot CD to test/resources (Name is nonexistent or not a directory). Error in run (line 41) cd(fileDir);
% suite = TestSuite.fromMethod(testCls, 'testOverloadedDlmread'); % Fails, same as above
% suite = TestSuite.fromMethod(testCls, 'testOverloadedLoad'); % Fails, same as above
% suite = TestSuite.fromMethod(testCls, 'testOverloadedNCopen'); % Fails, same as above
% suite = TestSuite.fromMethod(testCls, 'testOverloadedNCread'); % Fails, same as above
% suite = TestSuite.fromMethod(testCls, 'testOverloadedNCwrite'); % Fails, same as above
% suite = TestSuite.fromMethod(testCls, 'testPublish'); % No public field runDir exists for class org.dataone.client.run.RunManager. Error in org.dataone.client.run.RunManagerTest/testPublish (line 370): testCase.mgr.runDir = 'test/resources/runs';   
% suite = TestSuite.fromMethod(testCls, 'testPublishPackageFromDisk'); % Need to rename this to testPubish(). function no longer exists.
% suite = TestSuite.fromMethod(testCls, 'testRecord'); % Error using org.dataone.client.run.RunManager/startRecord (line 1141). The script: /Users/cjones/Documents/Development/d1org/matlab-dataone/src/test/resources/C3_C4_map_present_NA_Markup_v2_7.m could not be run. The error message was: Attempt to reference field of non-structure array.
% suite = TestSuite.fromMethod(testCls, 'testSaveExecution'); % Error in org.dataone.client.run.RunManagerTest/testSaveExecution (line 277). execDBName = testCase.mgr.executionDatabaseName;  
% suite = TestSuite.fromMethod(testCls, 'testView'); % Error using org.dataone.client.run.RunManager/view (line 1422). No runs can be found as a match.
% suite = TestSuite.fromMethod(testCls, 'testYesWorkflow'); % No public field runDir exists for class org.dataone.client.run.RunManager. Error in org.dataone.client.run.RunManagerTest/testYesWorkflow (line 120): testCase.mgr.runDir = '/tmp';
% suite = TestSuite.fromMethod(testCls, 'testView'); % Error using org.dataone.client.run.RunManager/view (line 1422): No runs can be found as a match.

run(suite);

% rmpath(genpath(pwd));