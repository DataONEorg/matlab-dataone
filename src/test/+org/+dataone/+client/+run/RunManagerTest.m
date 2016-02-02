% RUNMANAGERTEST A class used to test the org.dataone.client.run.RunManager class functionality
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

classdef RunManagerTest < matlab.unittest.TestCase
    
    properties 
        filename
        testDir
        mgr
        yw_process_view_property_file_name
        yw_data_view_property_file_name 
        yw_comb_view_property_file_name
        test_output_dir
        ywdb
    end

    methods (TestMethodSetup)
        
        function setUp(testCase)
                        
            % SETUP Set up the test environment            
            import org.dataone.client.run.RunManager;
            import org.dataone.client.configure.Configuration;
                                    
            if ispc
                home_dir = getenv('USERPROFILE');
            elseif isunix
                home_dir = getenv('HOME');
            else
                error('Current platform not supported.');
            end
            
            % test_config_directory = fullfile(home_dir, '.d1test');
            
            % for unit testing, set the D1 directory to a test location
            % 'configuration_directory', test_config_directory, ...

            config = Configuration( ...
                'configuration_directory', fullfile(home_dir, '.d1'), ...
                'source_member_node_id', 'urn:node:mnDevUCSB2', ...
                'target_member_node_id', 'urn:node:mnDevUCSB2', ...
                'format_id', 'application/octet-stream', ...
                'submitter', 'submitter', ...
                'rights_holder', 'rightsHolder', ...
                'coordinating_node_base_url', 'https://cn-dev-2.test.dataone.org/cn', ...
                'certificate_path', fullfile(tempdir, 'x509up_u501'), ... 
                'authentication_token', '');

               
            set(config, 'science_metadata_config', testCase.getScienceMetadataConfig('mstmip_c3c4'));

            testCase.mgr = RunManager.getInstance(config);
         
            testCase.mgr.execution.execution_input_ids  = {};
            testCase.mgr.execution.execution_output_ids = {};
            
            testCase.test_output_dir = fullfile('src', 'test', 'resources', 'tests');
            if (~ exist(testCase.test_output_dir, 'dir') )
                mkdir(testCase.test_output_dir);
            end
         
        end
    end
    
    methods (TestMethodTeardown)
        
        function tearDown(testCase)
            
            % Reset the Matlab DataONE Toolbox environment
             resetEnvironment(testCase);
        end
    end
    
    methods (Test)
        
        function testGetInstanceNoConfiguration(testCase)
            % TESTGETINSTANCENOCONFIGURATION tests calling the getInstance()
            % function without passing a Configuration object
            
            fprintf('\nIn testGetInstanceNoConfiguration() ...\n');
            if ( isprop(testCase.mgr.configuration, 'format_id') )
                old_format_id = get(testCase.mgr.configuration, 'format_id');
            else
                old_format_id = '';
            end
            set(testCase.mgr.configuration, 'format_id', 'application/octet-stream');
            assertInstanceOf(testCase, testCase.mgr, 'org.dataone.client.run.RunManager');
            % Test a single default property to ensure the configuration was set
            assertEqual(testCase, testCase.mgr.configuration.format_id, 'application/octet-stream');
            
            % reset to the original
            set(testCase.mgr.configuration, 'format_id', old_format_id);
        end
        
        function testGetInstanceWithConfiguration(testCase)
            % TESTGETINSTANCENOCONFIGURATION tests calling the getInstance()
            % function while passing a Configuration object
            
            import org.dataone.client.run.RunManager;
            import org.dataone.client.configure.Configuration;
            
            fprintf('\nIn testGetInstanceWithConfiguration() ...\n');
            
            old_format_id = get(testCase.mgr.configuration, 'format_id');
            set(testCase.mgr.configuration, 'format_id', 'text/csv');
            
            % Test the instance type
            assertInstanceOf(testCase, testCase.mgr, 'org.dataone.client.run.RunManager');
            % Test a single preset property
            assertEqual(testCase, testCase.mgr.configuration.format_id, 'text/csv');
            
            % reset to the original
            set(testCase.mgr.configuration, 'format_id', old_format_id);
        end
                
        function testYesWorkflow(testCase)
            fprintf('\nIn testYesWorkflow() ...\n');
            
            testCase.filename = ...
                fullfile(testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src', 'test', 'resources', 'C3_C4_map_present_NA_Markup_v2_7.m');

            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            testCase.mgr.execution.software_application = scriptPath;
            % testCase.mgr.execution.execution_directory = '/tmp';
            testCase.mgr.execution.execution_directory = tempdir; % 1-18-2016
            addpath(testCase.mgr.execution.execution_directory );
            testCase.mgr.callYesWorkflow(scriptPath, testCase.mgr.execution.execution_directory);
            
            % Test comb_view generated by yesWorkflow exists
            combFileName = testCase.mgr.getYWCombViewFileName();
            a = dir(testCase.mgr.execution.execution_directory);
            b = struct2cell(a);
            existed = any(ismember(b(1,:), combFileName));
            
            assert(isequal(existed,1));
        end
                
        function testRecord(testCase)
            fprintf('\nIn testRecord() ...\n');
            
            testCase.filename = ...
                fullfile( ...
                testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src', 'test', 'resources', 'C3_C4_map_present_NA_Markup_v2_7.m');
            
            scriptPath = which(testCase.filename); % get the absolute path of the script
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            [scriptParentPath, name, ext] = fileparts(scriptPath);
            tag = 'c3_c4_1'; % TODO: multiple tags passed in
            
            currentDir = pwd();
            cd(scriptParentPath);
            testCase.mgr.record(scriptPath, tag);
            cd(currentDir);
            
            % Test if one resource map exists
            a = dir(testCase.mgr.execution.execution_directory);
            b = struct2cell(a);
            
            matches = regexp(b(1,:), '.rdf');
            total = sum(~cellfun('isempty', matches));
            assertEqual(testCase, total, 1);
            
            % Test if there are three views outputs exist
            if  testCase.mgr.configuration.capture_yesworkflow_comments
                matches = regexp(b(1,:), '.pdf');
                total = sum(~cellfun('isempty', matches));
                assertEqual(testCase, total, 3);
            end
            
        end
        
        function testPutMetadataWithSalutationConfigAndDomElement(testCase)
            % The Saluation element is present in the dom object
            
            fprintf('\nIn test Put Metadata With Salutation Config Element Exists ...\n');
            
            testCase.filename = ...
                fullfile( ...
                testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src', 'test', 'resources', 'testMetadataWithSaluation.xml');
            newScienceMetaFileName = ...
                fullfile( ...
                testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src', 'test', 'resources', 'testReplaceMetadata.xml');
            
            % Create a faked run
            import org.dataone.client.run.Execution;
            run = Execution();
            testCase.mgr.execution = run;
            
            % Then create the run directory for the given run
            runDirectory = fullfile(...
                testCase.mgr.configuration.provenance_storage_directory, ...
                'runs', ...
                testCase.mgr.execution.execution_id);
            
            if ( isprop(testCase.mgr.execution, 'execution_id') )
                if ( exist(runDirectory, 'dir') ~= 7 )
                    mkdir(runDirectory);
                end
            end
            
            % Create a faked science metadata in a faked run directory
            if ( exist(runDirectory, 'dir') == 7)
                science_metadata_file = ['metadata_' testCase.mgr.execution.execution_id '.xml'];
                
                [status, message] = copyfile( ...
                    testCase.filename, ...
                    fullfile(runDirectory, science_metadata_file), 'f');
                
                if ( status ~= 1 )
                    error('RunManager:putMetadata:IOError', ...
                        message);
                end
                
            end
            
            % Check if the Saluation element is present in the dom object
            import org.ecoinformatics.eml.EML;
            eml1 = EML.loadDocument( ...
                fullfile(runDirectory, ...
                science_metadata_file));
            salutationNode1 = eml1.document.getElementsByTagName('salutation').item(0);
            salutationTextNode1 = salutationNode1.getFirstChild();
            saluationText1 = char(salutationTextNode1.getNodeValue());
            
            testCase.mgr.putMetadata('packageId', testCase.mgr.execution.execution_id, 'file', newScienceMetaFileName);
            
            eml2 = EML.loadDocument( ...
                fullfile(runDirectory, ...
                science_metadata_file));
            salutationNode2 = eml2.document.getElementsByTagName('salutation').item(0);
            salutationTextNode2 = salutationNode2.getFirstChild();
            saluationText2 = char(salutationTextNode2.getNodeValue());
            
            assertNotEqual(testCase, saluationText1, saluationText2);
        end
                
        function testPutMetadataWithSalutationNoDomElement(testCase)
            % The Saluation element is not present in the dom object
            
            fprintf('\nIn test Put Metadata No Salutation Config Element Exists ...\n');
            
            testCase.filename = ...
                fullfile( ...
                testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src', 'test', 'resources', 'testMetadataNoSaluation.xml');
            newScienceMetaFileName = ...
                fullfile( ...
                testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src', 'test', 'resources', 'testReplaceMetadata.xml');
            
            % Create a faked run
            import org.dataone.client.run.Execution;
            run = Execution();
            testCase.mgr.execution = run;
            
            % Then create the run directory for the given run
            runDirectory = fullfile(...
                testCase.mgr.configuration.provenance_storage_directory, ...
                'runs', ...
                testCase.mgr.execution.execution_id);
            
            if ( isprop(testCase.mgr.execution, 'execution_id') )
                if ( exist(runDirectory, 'dir') ~= 7 )
                    mkdir(runDirectory);
                end
            end
            
            % Create a faked science metadata in a faked run directory
            if ( exist(runDirectory, 'dir') == 7)
                science_metadata_file = ['metadata_' testCase.mgr.execution.execution_id '.xml'];
                
                [status, message] = copyfile( ...
                    testCase.filename, ...
                    fullfile(runDirectory, science_metadata_file), 'f');
                
                if ( status ~= 1 )
                    error('RunManager:putMetadata:IOError', ...
                        message);
                end
                
            end
            
            % Check if the Saluation element is present in the dom object
            import org.ecoinformatics.eml.EML;
            eml1 = EML.loadDocument( ...
                fullfile(runDirectory, ...
                science_metadata_file));
            salutationNode1 = eml1.document.getElementsByTagName('salutation').item(0);
            assert(isempty(salutationNode1));
            
            testCase.mgr.putMetadata('packageId', testCase.mgr.execution.execution_id, 'file', newScienceMetaFileName);
            
            eml2 = EML.loadDocument( ...
                fullfile(runDirectory, ...
                science_metadata_file));
            salutationNode2 = eml2.document.getElementsByTagName('salutation').item(0);
            salutationTextNode2 = salutationNode2.getFirstChild();
            saluationText2 = char(salutationTextNode2.getNodeValue());
            
            assert(~isempty(saluationText2));
        end
                
        function testPutMetadataWithoutSalutationConfigWithDomElement(testCase)
            fprintf('\nIn test Put Metadata Without Salutation Config Element Exists but Saluation dom element exists ...\n');
            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'testMetadataWithSaluation.xml');
            newScienceMetaFileName = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'testReplaceMetadataNoSaluation.xml');
            
            % Create a faked run
            import org.dataone.client.run.Execution;
            run = Execution();
            testCase.mgr.execution = run;
            
            % Then create the run directory for the given run
            runDirectory = fullfile(...
                testCase.mgr.configuration.provenance_storage_directory, ...
                'runs', ...
                testCase.mgr.execution.execution_id);
            
            if ( isprop(testCase.mgr.execution, 'execution_id') )
                if ( exist(runDirectory, 'dir') ~= 7 )
                    mkdir(runDirectory);
                end
            end
            
            % Create a faked science metadata in a faked run directory
            if ( exist(runDirectory, 'dir') == 7)
                science_metadata_file = ['metadata_' testCase.mgr.execution.execution_id '.xml'];
                
                [status, message] = copyfile( ...
                    testCase.filename, ...
                    fullfile(runDirectory, science_metadata_file), 'f');
                
                if ( status ~= 1 )
                    error('RunManager:putMetadata:IOError', ...
                        message);
                end
                
            end
            
            % Check if the Saluation element is present in the dom object
            import org.ecoinformatics.eml.EML;
            eml1 = EML.loadDocument( ...
                fullfile(runDirectory, ...
                science_metadata_file));
            salutationNode1 = eml1.document.getElementsByTagName('salutation').item(0);
            salutationTextNode1 = salutationNode1.getFirstChild();
            saluationText1 = char(salutationTextNode1.getNodeValue());
            assert(~isempty(saluationText1));
            
            testCase.mgr.putMetadata('packageId', testCase.mgr.execution.execution_id, 'file', newScienceMetaFileName);
            
            eml2 = EML.loadDocument( ...
                fullfile(runDirectory, ...
                science_metadata_file));
            salutationNode2 = eml2.document.getElementsByTagName('salutation').item(0);
            assert(isempty(salutationNode2));
            
        end
                
        function testPutMetadataWithoutSalutationConfigNoDomElement(testCase)
            fprintf('\nIn test Put Metadata Without Salutation Config Element Exists and Saluation dom element not present ...\n');
            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'testMetadataNoSaluation.xml');
            newScienceMetaFileName = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'testReplaceMetadataNoSaluation.xml');
            
            % Create a faked run
            import org.dataone.client.run.Execution;
            run = Execution();
            testCase.mgr.execution = run;
            
            % Then create the run directory for the given run
            runDirectory = fullfile(...
                testCase.mgr.configuration.provenance_storage_directory, ...
                'runs', ...
                testCase.mgr.execution.execution_id);
            
            if ( isprop(testCase.mgr.execution, 'execution_id') )
                if ( exist(runDirectory, 'dir') ~= 7 )
                    mkdir(runDirectory);
                end
            end
            
            % Create a faked science metadata in a faked run directory
            if ( exist(runDirectory, 'dir') == 7)
                science_metadata_file = ['metadata_' testCase.mgr.execution.execution_id '.xml'];
                
                [status, message] = copyfile( ...
                    testCase.filename, ...
                    fullfile(runDirectory, science_metadata_file), 'f');
                
                if ( status ~= 1 )
                    error('RunManager:putMetadata:IOError', ...
                        message);
                end
                
            end
            
            % Check if the Saluation element is present in the dom object
            import org.ecoinformatics.eml.EML;
            eml1 = EML.loadDocument( ...
                fullfile(runDirectory, ...
                science_metadata_file));
            salutationNode1 = eml1.document.getElementsByTagName('salutation').item(0);
            assert(isempty(salutationNode1));
            
            testCase.mgr.putMetadata('packageId', testCase.mgr.execution.execution_id, 'file', newScienceMetaFileName);
            
            eml2 = EML.loadDocument( ...
                fullfile(runDirectory, ...
                science_metadata_file));
            salutationNode2 = eml2.document.getElementsByTagName('salutation').item(0);
            assert(isempty(salutationNode2));
            
        end
                
        function testGetMetadata(testCase)
            fprintf('\nIn test Get Metadata ...\n');
            
            testCase.filename = ... 
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'testMetadataWithSaluation.xml');
         
            % Create a faked run
            import org.dataone.client.run.Execution;
            run = Execution();
            testCase.mgr.execution = run;
            
            % Then create the run directory for the given run
            runDirectory = fullfile(...
                testCase.mgr.configuration.provenance_storage_directory, ...
                'runs', ...
                testCase.mgr.execution.execution_id);
            
            if ( isprop(testCase.mgr.execution, 'execution_id') )
                if ( exist(runDirectory, 'dir') ~= 7 )
                    mkdir(runDirectory);
                end
            end
            
            % Create a faked science metadata in a faked run directory
            if ( exist(runDirectory, 'dir') == 7)
                science_metadata_file = ['metadata_' testCase.mgr.execution.execution_id '.xml'];
                
                [status, message] = copyfile( ...
                    testCase.filename, ...
                    fullfile(runDirectory, science_metadata_file), 'f');
                
                if ( status ~= 1 )
                    error('RunManager:putMetadata:IOError', ...
                        message);
                end
                
            end
            
            eml_string = testCase.mgr.getMetadata('packageId', testCase.mgr.execution.execution_id);     
            assert(~isempty(eml_string));
        end
        
        function testOverloadedXlsread(testCase)
            if ispc
                fprintf('\nIn testOverloadedXlsread() ...\n');
                testCase.filename = ...
                    fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src', 'test', 'resources', 'myScript23.m');
                
                scriptPath = which(testCase.filename);
                if isempty(scriptPath)
                    [status, struc] = fileattrib(testCase.filename);
                    scriptPath = struc.Name;
                end
                
                run(scriptPath);
                
                assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
                assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),1);
            end
        end
        
        function testOverloadedXlswrite(testCase)
            if ispc
                fprintf('\nIn testOverloadedXlswrite() ...\n');
                testCase.filename = ...
                    fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src', 'test', 'resources', 'myScript26.m');
                
                scriptPath = which(testCase.filename);
                if isempty(scriptPath)
                    [status, struc] = fileattrib(testCase.filename);
                    scriptPath = struc.Name;
                end
                
                run(scriptPath);
                
                assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 0);
                assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids), 2);
            end
        end
        
        
        function testOverloadedCdfread(testCase)
            fprintf('\nIn testOverloadedCdfread() ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src', 'test', 'resources', 'myScript7.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),0);
  
        end 
                
        function testOverloadedCdfwrite(testCase)
            fprintf('\nIn testOverloadedCdfwrite() ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript8.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 0);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids), 1);

        end 
                
        function testOverloadedHdfread(testCase)
            fprintf('\nIn testOverloadedHdfread() ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript11.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),0);

        end 
                
        function testOverloadedHdfinfo(testCase)
            fprintf('\nIn testOverloadedHdfinfo() ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript12.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),0);

        end 
                
        function testOverloadedH5read(testCase)
            fprintf('\nIn testOverloadedH5read ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript9.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),0);

        end 
                
        function testOverloadedH5write(testCase)
            fprintf('\nIn testOverloadedH5write ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript10.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 0);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),1);

        end 
                
        function testOverloadedTextread(testCase)
            fprintf('\nIn testOverloadedTextread ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript13.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids), 1);

        end 
                
        function testOverloadedReadtable(testCase)
            fprintf('\nIn testOverloadedReadtable ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript14.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),1);

        end 
                
        function testOverloadedWritetable(testCase)
            fprintf('\nIn testOverloadedWritetable ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript14.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),1);

        end 
        
        function testOverloadedImread(testCase)
            fprintf('\nIn testOverloadedImread ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript15.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),0);

        end 
                
        function testOverloadedImwrite(testCase)
            fprintf('\nIn testOverloadedImwrite ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript16.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),3);

        end 
                
        function testOverloadedXmlread(testCase)
            fprintf('\nIn testOverloadedXmlread ...\n');
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript17.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),0);

        end
                
        function testOverloadedXmlwrite(testCase)
            fprintf('\nIn testOverloadedXmlwrite ...\n');
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript18.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 0);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),1);

        end
                  
        function testOverloadedMultibandread(testCase)
            fprintf('\nIn testOverloadedMultibandread ...\n');
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript20.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 2);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),0);

        end
                        
        function testOverloadedMultibandwrite(testCase)
            fprintf('\nIn testOverloadedMultibandwrite ...\n');
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript19.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 0);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids), 1);

        end
                
        function testOverloadedFitsread(testCase)
            fprintf('\nIn testOverloadedFitsread ...\n');
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript22.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),0);

        end
                        
        function testOverloadedFitswrite(testCase)
            fprintf('\nIn testOverloadedFitswrite ...\n');
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript21.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),1);

        end
                
        function testOverloadedNCopen(testCase)
            fprintf('\nIn testOverloadedNCopen() ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript3.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
    
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),0);

        end        
              
        function testOverloadedNCread(testCase)
            fprintf('\nIn testOverloadedNcread() ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript1.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids),0);

        end        
        
        function testOverloadedNCwrite(testCase)
            fprintf('\nIn testOverloadedNcwrite() ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript2.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
         
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids), 1);

        end        
        
        function testOverloadedCSVread(testCase)
            fprintf('\nIn testOverloadedCSVread() ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test', 'resources', 'myScript4.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
           
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 1);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids), 0);

        end        
          
        
        function testOverloadedCsvWrite(testCase)
            fprintf('\nIn testOverloadedCsvWrite() ...\n');
            testCase.filename = ...
                fullfile( ...
                testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                'src', 'test', 'resources', 'myScript24.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
               
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 0);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids), 1);

        end
        
        function testOverloadedLoad(testCase)

           fprintf('\nIn testOverloadedLoad() ...\n'); 
                       
            testCase.filename = ...
                fullfile( ...
                testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                'src', 'test', 'resources', 'myScript27.m');                
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
           
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 3);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids), 1);

        end        
        
        function testOverloadedSave(testCase)
            
            fprintf('\nIn testOverloadedSave() ...\n');
            
            testCase.filename = ...
                fullfile( ...
                testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                'src', 'test', 'resources', 'myScript28.m');
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 0);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids), 3);
            
        end
        
        function testOverloadedDlmread(testCase)
          
            fprintf('\nIn testOverloadedDlmread ...\n');            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                        'src', 'test','resources', 'myScript6.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
         
            run(scriptPath);
               
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 2);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids), 1);

        end        
          
        
        function testOverloadedDlmWrite(testCase)
            
            fprintf('\nIn testOverloadedDlmWrite ...\n');
            testCase.filename = ...
                fullfile( ...
                testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                'src', 'test', 'resources', 'myScript25.m');
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
            
            assertEqual(testCase, length(testCase.mgr.execution.execution_input_ids), 0);
            assertEqual(testCase, length(testCase.mgr.execution.execution_output_ids), 1);

        end
        
                
        function testListRunsNoParams(testCase)
            fprintf('\n*** testListRuns with no parameters: ***\n');
            
            generateTestRuns(testCase);
                        
            runs = testCase.mgr.listRuns();
            
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 3); % Three rows should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsAllParams(testCase)
            fprintf('\n*** testListRuns with all parameters: ***\n');
            
            generateTestRuns(testCase);
            
            quiet = false;
            startDate = '20151006T101049';
            endDate = '20151006T101149';
            tagList = {'test_tag_2'};
                       
            runs = testCase.mgr.listRuns('startDate', startDate, 'endDate', endDate, 'tag', tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsStartDateOnly(testCase)
            fprintf('\n*** testListRuns with startDate only: ***\n');

            generateTestRuns(testCase);

            startDate = '20151006T101049';
           
            runs = testCase.mgr.listRuns('startDate', startDate);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 2); % Two rows should match
            % TODO: Compare the execution ids
  
        end
        
        function testListRunsEndDateOnly(testCase)
            
            fprintf('\n*** testListRuns with endDate only: ***\n');

            generateTestRuns(testCase);

            endDate = '20150930T101149';
           
            runs = testCase.mgr.listRuns('endDate', endDate);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsStartDateEndDateOnly(testCase)
            
            fprintf('\n*** testListRuns with startDate and endDate only: ***\n');

            generateTestRuns(testCase);

            startDate = '20151006T101049';
            endDate = '20151006T101149';
          
            runs = testCase.mgr.listRuns('startDate', startDate, 'endDate', endDate);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids

        end
        
        function testListRunsStartDateEndDateTagsOnly(testCase)
            fprintf('\n*** testListRuns with startDate, endDate and tags only: ***\n');

            generateTestRuns(testCase);

            startDate = '20151006T101049';
            endDate = '20151006T101149';
            tagList = {'test_tag_2'};

            runs = testCase.mgr.listRuns('startDate', startDate, 'endDate', endDate, 'tag', tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsStartDateTagsOnly(testCase)
            fprintf('\n*** testListRuns with startDate and tags only: ***\n');

            generateTestRuns(testCase);

            startDate = '20150929T102515';
            tagList = {'test_tag_2'};

            runs = testCase.mgr.listRuns('startDate', startDate, 'tag', tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
        end

        function testListRunsEndDateTagsOnly(testCase)

            fprintf('\n*** testListRuns with endDate and tags required: ***\n');

            generateTestRuns(testCase);

            endDate = '20150930T101149';
            tagList = {'test_tag_1'};
            
            % runs = testCase.mgr.listRuns('', '', endDate, tagList);
            runs = testCase.mgr.listRuns('endDate', endDate, 'tag', tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end
        
        function testListRunsTagsOnly(testCase)
            fprintf('\n*** testListRuns with tags required only: ***\n');

            generateTestRuns(testCase);
            
            tagList = {'test_tag_3'};

            runs = testCase.mgr.listRuns('tag', tagList);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids
            
        end        
          
        function testListRunsSequenceNumberOnly(testCase)
            fprintf('\n*** testListRuns with sequence number required only: ***\n');

            generateTestRuns(testCase);
            
            runNumber = 1;

            runs = testCase.mgr.listRuns('runNumber', runNumber);
            [rows, columns] = size(runs);
            assertEqual(testCase, rows, 1); % Only one row should match
            % TODO: Compare the execution ids            
        end 
        
        function testDeleteRunsByTags(testCase)
            fprintf('\n*** testDeleteRunsByTags: ***\n');
            
            generateTestRuns(testCase);
                        
            tagList = {'test_tag_1'};
            noop = true;
            
            % Delete the runs
            testCase.mgr.deleteRuns('tag', tagList, 'noop', noop);
     
            if ~noop
                runs = testCase.mgr.listRuns(); % List the runs
                [rows, cols] = size(runs);
                assertEqual(testCase, rows, 2); % Only 2 rows should be left
            else
                runs = testCase.mgr.listRuns();
                [rows, cols] = size(runs);
                assertEqual(testCase, rows, 3); % 3 rows should be there because no delete is applied
            end
        end          
        
        function testDeleteRunsByTagsRunIdsOnly(testCase)
            fprintf('\n*** testDeleteRunsByTagsRunIdsOnly: ***\n');
            
            generateTestRuns(testCase);
                        
            tagList = {'test_tag_1'};
            runIds = {'1'};
           
            deleted_runs = testCase.mgr.deleteRuns('runIdList', runIds, 'tag', tagList);
            [rows, columns] = size(deleted_runs);
            assertEqual(testCase, rows, 0); % Zero row should match           
        end   
        
        function testDeleteRunsBySequenceNumber(testCase)
            fprintf('\n*** DeleteRunsBySequenceNumber: ***\n');
            
            generateTestRuns(testCase);
                        
            runNumber = 2;
            noop = false;
            
            % Delete the runs
            testCase.mgr.deleteRuns('runNumber', runNumber, 'noop', noop);
     
            if ~noop
                runs = testCase.mgr.listRuns(); % List the runs
                [rows, cols] = size(runs);
                assertEqual(testCase, rows, 2); % Only 2 rows should be left
            else
                runs = testCase.mgr.listRuns();
                [rows, cols] = size(runs);
                assertEqual(testCase, rows, 3); % 3 rows should be there because no delete is applied
            end
        end 
        
        function testViewByPackageIdOnly(testCase)
            fprintf('\n\nTest for ViewByPackageIdOnly function:\n');
           
            generateTestRuns(testCase);

            pkgId = testCase.mgr.execution.execution_id ;
            
            sections = {'details', 'used', 'generated'};
            resultObjs = testCase.mgr.view('packageId', pkgId, 'sections', sections); % view the selected run
            numOfObjects = size(resultObjs, 2);
            assertGreaterThanOrEqual(testCase, numOfObjects, 1);   
            
            detailsView = resultObjs{1,1};
            assertEqual(testCase, detailsView.Tag, 'test_tag_3');
            assertEqual(testCase, detailsView.RunSequenceNumber, '3');
        end        
        
        function testViewBySequenceNumberOnly(testCase)
            fprintf('\n\nTest for ViewBySequenceNumberOnly function:\n');
           
            generateTestRuns(testCase);

            runNumber = 2;
            
            sections = {'details', 'used', 'generated'};
            resultObjs = testCase.mgr.view('runNumber', runNumber, 'sections', sections); % view the selected run
            numOfObjects = size(resultObjs, 2);
            assertGreaterThanOrEqual(testCase, numOfObjects, 1);   
            
            detailsView = resultObjs{1,1};
            assertEqual(testCase, detailsView.Tag, 'test_tag_2');
            assertEqual(testCase, detailsView.RunSequenceNumber, '2');
        end 
        
        function testPublish(testCase)
            fprintf('\n\nTest for the publish() function:\n\n');
            
            fprintf(['For testPublish() to succeed, you must log into ' ...
                     'https://cilogon.org/?skin=DataONEDev and \n ' ...
                     'download your X509 certificate to /tmp/x509up_u501.\n']);

%             testCase.filename = ...
%                 fullfile( ...
%                     testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
%                         'src', 'test', 'resources', 'C3_C4_map_present_NA_with_comments.m');

            testCase.filename = ...
                fullfile( ...
                testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                'src', 'test', 'resources', 'myScript2.m');
            
            scriptPath = which(testCase.filename); % get the absolute path of the script
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            [scriptParentPath, name, ext] = fileparts(scriptPath);
            tag = 'testPublish'; 
 
            currentDir = pwd();
            cd(scriptParentPath);
            testCase.mgr.record(scriptPath, tag);  
            cd(currentDir);
            
            runs = testCase.mgr.listRuns();
            pkgId = runs{1,1};
            testCase.mgr.publish(pkgId);
            runs = testCase.mgr.listRuns();
        end
        
    end
    
    methods (Access = 'private')
        
        function generateTestRuns(testCase)
        % GENERATETESTRUNS generates test runs and adds them to the database    
            
            % Create run entry 1
            import org.dataone.client.run.Execution;
            run1 = Execution();
            set(run1, 'tag', 'test_tag_1');
            set(run1, 'execution_uri', ...
                [testCase.mgr.configuration.coordinating_node_base_url ...
                '/v2/resolve' run1.execution_id]);
            set(run1, 'start_time', '20150930T101049');
            set(run1, 'end_time', '20150930T101149');
            set(run1, 'software_application', 'test_data_input1.m');
            set(run1, 'sequence_number', '1');
            testCase.mgr.execution = run1;
            createFakeExecution(testCase);
            
            % Create run entry 2
            run2 = Execution();
            set(run2, 'tag', 'test_tag_2');
            set(run2, 'execution_uri', ...
                [testCase.mgr.configuration.coordinating_node_base_url ...
                '/v2/resolve' run2.execution_id]);
            set(run2, 'start_time', '20151006T101049');
            set(run2, 'end_time', '20151006T101149');
            testCase.mgr.execution = run2;
            set(run2, 'software_application', 'test_data_input2.m');
            set(run2, 'sequence_number', '2');
            createFakeExecution(testCase);

            % Create run entry 3
            run3 = Execution();
            set(run3, 'tag', 'test_tag_3');
            set(run3, 'execution_uri', ...
                [testCase.mgr.configuration.coordinating_node_base_url ...
                '/v2/resolve' run3.execution_id]);
            set(run3, 'start_time', '20301030T101049');
            set(run3, 'end_time', '20301030T101249');
            set(run3, 'software_application', 'test_data_input3.m');
            set(run3, 'sequence_number', '3');
            testCase.mgr.execution = run3;
            createFakeExecution(testCase);

        end
        
        function createFakeExecution(testCase)
        % CREATEFAKEEXECUTION creates a create execution in the configuration directory
            
            % Write the execution entry to the file
            runID = char(testCase.mgr.execution.execution_id);
            filePath = char(testCase.mgr.execution.software_application);
            startTime = char(testCase.mgr.execution.start_time);
            endTime = char(testCase.mgr.execution.end_time);
            publishedTime = char(testCase.mgr.execution.publish_time);
            packageId = char(testCase.mgr.execution.execution_id);
            tag = testCase.mgr.execution.tag;  
            user = char(testCase.mgr.execution.account_name);
            subject = 'CN=Test User, dc=dataone, dc=org'; 
            hostId = char(testCase.mgr.execution.host_id);
            operatingSystem = char(testCase.mgr.execution.operating_system);
            runtime = char(testCase.mgr.execution.runtime);
            moduleDependencies = char(testCase.mgr.execution.module_dependencies);
            console = '';
            errorMessage = char(testCase.mgr.execution.error_message);
            seqNo = char(testCase.mgr.execution.sequence_number);
            
            formatSpec = testCase.mgr.configuration.execution_db_write_format;
            
            if ( exist(testCase.mgr.configuration.execution_db_name, 'file') ~= 2 )
                [fileId, message] = ...
                    fopen(testCase.mgr.configuration.execution_db_name, 'w');
                fprintf(fileId, formatSpec, 'runId', 'filePath', ...
                    'startTime', 'endTime', 'publishedTime', ...
                    'packageId', 'tag', 'user', 'subject', 'hostId', ...
                    'operatingSystem', 'runtime', 'moduleDependencies', ...
                    'console', 'errorMessage', 'sequence_number');
                fprintf(fileId, formatSpec, runID, filePath, startTime, ...
                    endTime, publishedTime, packageId, tag, user, subject, ...
                    hostId, operatingSystem, runtime, moduleDependencies, ...
                    console, errorMessage, seqNo);   
                
            else    
                [fileId, message] = ...
                    fopen(testCase.mgr.configuration.execution_db_name, 'a');
                fprintf(fileId, formatSpec, runID, filePath, startTime, ...
                    endTime, publishedTime, packageId, tag, user, subject, ...
                    hostId, operatingSystem, runtime, moduleDependencies, ...
                    console, errorMessage, seqNo);
                
            end
            
            fclose(fileId);
                 
            % Then create the run directory for the given run
            runDirectory = fullfile(...
                testCase.mgr.configuration.provenance_storage_directory, ...
                'runs', ...
                testCase.mgr.execution.execution_id);
            
            if ( isprop(testCase.mgr.execution, 'execution_id') )
                if ( exist(runDirectory, 'dir') ~= 7 )
                    mkdir(runDirectory);
                end                
            end
            
            % Serialize the execution object to local file system in the
            % execution_directory
            execution_serialized_object = [testCase.mgr.execution.execution_id '.mat'];
            exec_destination = [runDirectory filesep execution_serialized_object];
            executionObj = testCase.mgr.execution;
            
            % Remove the path to the overloaded save()
            overloadedFunctPath = which('save');
            [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
            rmpath(overloaded_func_path);
            
            save(char(exec_destination), 'executionObj');
            
            % Add the path to the overloaded save() back to the Matlab path
            warning off MATLAB:dispatcher:nameConflict;
            addpath(overloaded_func_path, '-begin');
            warning on MATLAB:dispatcher:nameConflict;
        end
        
        function resetEnvironment(testCase)
        % RESETENVIRONMENT resets the Matlab DataONE Toolbox environment
            
            try
                if ( isprop(testCase.mgr.configuration, 'configuration_directory') )
                    rmpath(fullfile(testCase.mgr.execution.execution_directory));
                    
                    if ispc
                        dos_cmd = sprintf( 'rmdir /S /Q "%s"', testCase.mgr.configuration.configuration_directory );
                        [ st, msg ] = system( dos_cmd );
                        
                        dos_cmd = sprintf( 'rmdir /S /Q "%s"', testCase.test_output_dir );
                        [ st, msg ] = system( dos_cmd );
                    else
                        rmdir(testCase.mgr.configuration.configuration_directory, 's');
                        rmdir(testCase.test_output_dir, 's');
                    end
                end
                
            catch IOError
                disp(IOError);
                
            end

        end
        
        function science_metadata_config = getScienceMetadataConfig(testCase, config_name)
            % GETSCIENCEMETADATA returns a science metadata configuration
            % struct based on the given known name.  Defaults to
            % a struct with empty fields. Currently supports 'mstmip_c3c4'
            % as the config_name.
            
            switch config_name
                case 'mstmip_c3c4'
                    science_metadata_config.title_prefix = 'MsTMIP: C3 C4 soil map processing: ';
                    science_metadata_config.title_suffix = '';
                    science_metadata_config.primary_creator_salutation = 'Dr.';
                    science_metadata_config.primary_creator_givenname = 'Yaxing';
                    science_metadata_config.primary_creator_surname = 'Wei';
                    science_metadata_config.primary_creator_address1 = 'Environmental Sciences Division';
                    science_metadata_config.primary_creator_address2 = 'Oak Ridge National Laboratory';
                    science_metadata_config.primary_creator_city = 'Oak Ridge';
                    science_metadata_config.primary_creator_state = 'TN';
                    science_metadata_config.primary_creator_zipcode = '37831-6290';
                    science_metadata_config.primary_creator_country = 'USA';
                    science_metadata_config.primary_creator_email = 'weiy@ornl.gov';
                    science_metadata_config.language = 'English';
                    science_metadata_config.abstract = 'Global land surfaces are classified by their relative fraction of Carbon 3 or Carbon 4 grasses, ...';
                    science_metadata_config.keyword1 = 'Carbon 3';
                    science_metadata_config.keyword2 = 'Carbon 4';
                    science_metadata_config.keyword3 = 'soil';
                    science_metadata_config.keyword4 = 'mapping';
                    science_metadata_config.keyword5 = 'global';
                    science_metadata_config.intellectual_rights = 'When using these data, please cite the originators as ...';
                    
                otherwise
                    science_metadata_config.title_prefix = '';
                    science_metadata_config.title_suffix = '';
                    science_metadata_config.primary_creator_salutation = '';
                    science_metadata_config.primary_creator_givenname = '';
                    science_metadata_config.primary_creator_surname = '';
                    science_metadata_config.primary_creator_address1 = '';
                    science_metadata_config.primary_creator_address2 = '';
                    science_metadata_config.primary_creator_city = '';
                    science_metadata_config.primary_creator_state = '';
                    science_metadata_config.primary_creator_zipcode = '';
                    science_metadata_config.primary_creator_country = '';
                    science_metadata_config.primary_creator_email = '';
                    science_metadata_config.language = '';
                    science_metadata_config.abstract = '';
                    science_metadata_config.keyword1 = '';
                    science_metadata_config.keyword2 = '';
                    science_metadata_config.keyword3 = '';
                    science_metadata_config.keyword4 = '';
                    science_metadata_config.keyword5 = '';
                    science_metadata_config.intellectual_rights = '';
            end
        end
    end
end
