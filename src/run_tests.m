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
%clc
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, 
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

addpath(genpath(pwd));

import matlab.unittest.TestSuite;

% Create a suite of all client tests 
suite = TestSuite.fromPackage('org.dataone.client.run', 'IncludingSubpackages', true);
run(suite);

rmpath(genpath(pwd));
