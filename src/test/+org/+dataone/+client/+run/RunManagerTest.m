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
        
        function testGetInstanceNoConfiguration(testCase)
            % TESTGETINSTANCENOCONFIGURATION tests calling the getInstance()
            % function without passing a Configuration object

            import org.dataone.client.run.RunManager;
            
            mgr = RunManager.getInstance();
            old_format_id = get(mgr.configuration, 'format_id');
            set(mgr.configuration, 'format_id', 'application/octet-stream');
            assertInstanceOf(testCase, mgr, 'org.dataone.client.run.RunManager');
            % Test a single default property to ensure the configuration was set
            assertEqual(testCase, mgr.configuration.format_id, 'application/octet-stream');
            
            % reset to the original
            set(mgr.configuration, 'format_id', old_format_id);

        end
        
        function testGetInstanceWithConfiguration(testCase)
            % TESTGETINSTANCENOCONFIGURATION tests calling the getInstance()
            % function while passing a Configuration object

            import org.dataone.client.run.RunManager;
            import org.dataone.client.configure.Configuration;
            
            configuration = Configuration();
            
            mgr = RunManager.getInstance(configuration);
            old_format_id = get(mgr.configuration, 'format_id');
            set(mgr.configuration, 'format_id', 'text/csv');
            
            % Test the instance type
            assertInstanceOf(testCase, mgr, 'org.dataone.client.run.RunManager');
            % Test a single preset property
            assertEqual(testCase, mgr.configuration.format_id, 'text/csv');
            
            % reset to the original
            set(mgr.configuration, 'format_id', old_format_id);

            %% Test for YesWorkflow
            import org.yesworkflow.LanguageModel;
            import org.yesworkflow.extract.DefaultExtractor;
            import java.io.BufferedReader;
            import java.io.StringReader;
            import org.yesworkflow.annotations.Annotation;
            import org.yesworkflow.model.Program;
            import org.yesworkflow.model.DefaultModeler;
            
            % Get an inner class that's an Enum class because we need the
            % Enum Language values (web ref)
            matCode = javaMethod('valueOf', 'org.yesworkflow.LanguageModel$Language', 'MATLAB')
            lm = LanguageModel(matCode);
            
            testStr = strcat(' % @begin script \n', ' % @in x @as horiz \n', ...
                              ' % @in y @as vert \n', ' % @out d @as dist \n', ...
                              ' % @end script');
            
            reader= BufferedReader(StringReader(testStr));
            
            extractor = DefaultExtractor; 
            extractor = extractor.languageModel(lm);
            extractor = extractor.source(reader);
            annotations = extractor.extract().getAnnotations();
         
            model = DefaultModeler;
            model = model.annotations(annotations);
            modeller = model.model;
            program = modeller.getModel;
            
            inPorts = cell(program.inPorts);
          %  celldisp(inPorts);
            outPorts = cell(program.outPorts);
          %  celldisp(outPorts);
     
            testCase.verifyEqual(2, program.inPorts.length);
            testCase.verifyEqual(1, program.outPorts.length);
            testCase.verifyEqual('horiz', char(inPorts{1}.flowAnnotation.binding()));
            testCase.verifyEqual('vert', char(inPorts{2}.flowAnnotation.binding()));
            testCase.verifyEqual('dist', char(outPorts{1}.flowAnnotation.binding()));
        end
    end
end