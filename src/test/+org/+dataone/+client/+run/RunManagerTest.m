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
    end

    methods (TestMethodSetup)
        
        function setUp(testCase)
                        
            % SETUP Set up the test environment            
            import org.dataone.client.run.RunManager;
            import org.dataone.client.configure.Configuration;
                        
            % testCase.filename = 'src/test/resources/C3_C4_map_present_NA_Markup_v2_3.m';
            testCase.filename = 'src/test/resources/myScript1.m';
            
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
            testCase.yw_process_view_property_file_name = 'lib/yesworkflow/yw_process_view.properties'; 
            testCase.yw_data_view_property_file_name = 'lib/yesworkflow/yw_data_view.properties'; 
            testCase.yw_comb_view_property_file_name = 'lib/yesworkflow/yw_comb_view.properties'; 
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
            
            testCase.filename = 'src/test/resources/C3_C4_map_present_NA_Markup_v2_7.m';
              
            %scriptPath = fullfile(pwd(), filesep, testCase.filename); 
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
         
            testCase.mgr.execution.software_application = scriptPath;
            testCase.mgr.execution.execution_directory = '/tmp';
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
     
             testCase.filename = 'src/test/resources/C3_C4_map_present_NA_Markup_v2_7.m';
            % testCase.filename = 'src/test/resources/myScript1.m';
            % testCase.filename = 'src/test/resources/myScript2.m';
            % testCase.filename = 'src/Users/syc/Documents/matlab-dataone/src/test/resources/myScript2.m';
 
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
            matches = regexp(b(1,:), '.pdf');
            total = sum(~cellfun('isempty', matches));
            assertEqual(testCase, total, 3);
            
            % Test if there are three yw.properties 
            % matches = regexp(b(1,:), '.properties');
            % total = sum(~cellfun('isempty', matches));
            % assertEqual(testCase, total, 3);
            
            % Test if there are two prolog dump files
            matches = regexp(b(1,:), 'extractfacts');
            total1 = sum(~cellfun('isempty', matches));
            matches = regexp(b(1,:), 'modelfacts');
            total2 = sum(~cellfun('isempty', matches));
            total = total1 + total2;
            assertEqual(testCase, total, 2);
        end
        
        
        function testMNodeGet(testCase)
            % Certificate x509up_u501 is requried to run this unit test. Dec-10-2015
            fprintf('\nIn test Member Node Get() ...\n');
     
            import org.dataone.client.v2.MemberNode;
            import org.dataone.service.types.v1.Identifier;
            
            % Create a faked run
            import org.dataone.client.run.Execution;
            run1 = Execution();
            set(run1, 'tag', 'test_MN_Get');
            testCase.mgr.execution = run1;
             
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

            mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            matlab_mn_node = MemberNode(mn_base_url);
           
            % Download a single D1 object
            object_list = matlab_mn_node.mnode.listObjects([], [], [], [], [], [], [], []);
            objList = object_list.getObjectInfoList();
            for i=1:length(objList)
                obj_pid = objList.get(i).getIdentifier().getValue();
                if ~isempty(obj_pid)
                    break;
                end
            end
            
            % Call MNode.get()
            pid = Identifier();
            pid.setValue(obj_pid);
            item = matlab_mn_node.get([], pid); 
            
            % Verify if an object is returned 
            assert(~isempty(item));  
        end
        
        
        function testMNodeCreate(testCase)
            % Certificate x509up_u501 is requried to run this unit test. Dec-10-2015
            fprintf('\nIn test Member Node Create() ...\n');
            
            import org.dataone.client.v2.MemberNode;
            import org.dataone.service.types.v1.Identifier;
            import java.io.File;
            import org.dataone.service.types.v2.SystemMetadata;
            import java.math.BigInteger;
            import org.dataone.service.types.v1.ObjectFormatIdentifier;
            import org.dataone.service.types.v1.util.ChecksumUtil;
            import java.io.FileInputStream;
            import org.dataone.service.types.v1.AccessPolicy;
            import org.dataone.service.types.v1.util.AccessUtil;
            import java.lang.String;
            import org.dataone.service.types.v1.Permission; 
            import org.dataone.service.types.v1.ReplicationPolicy;
            import java.lang.Integer;
            import javax.activation.FileDataSource;
            import org.dataone.service.types.v1.Subject;
            
            testCase.filename = 'src/test/resources/testData.csv';
            full_file_path = which(testCase.filename);
            if isempty(full_file_path)
                [status, struc] = fileattrib(testCase.filename);
                full_file_path = struc.Name;
            end
            
            mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            matlab_mn_node = MemberNode(mn_base_url);
            
            % Create a faked run
            import org.dataone.client.run.Execution;
            run2 = Execution();
            set(run2, 'tag', 'test_MN_Create');
            testCase.mgr.execution = run2;
            
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
            
            % Call MNode.create()
            obj_pid = Identifier();
            obj_pid.setValue(java.util.UUID.randomUUID().toString());
            
            objectFile = File(full_file_path);
            data = FileDataSource(objectFile);
            
            try
                sysmeta = SystemMetadata();
                
                % Set the identifier
                sysmeta.setIdentifier(obj_pid);
                
                % Add the object format id
                fmtid = ObjectFormatIdentifier();
                fmtid.setValue('text/csv');
                sysmeta.setFormatId(fmtid);
                
                % Add the file size
                fileInfo = dir(full_file_path);
                fileSize = fileInfo.bytes;
                sizeBigInt = BigInteger.valueOf(fileSize);
                sysmeta.setSize(sizeBigInt);
              
                % Add the checksum              
                fileInputStream = FileInputStream(objectFile);
                checksum = ChecksumUtil.checksum(fileInputStream, 'SHA1');
                sysmeta.setChecksum(checksum);
                
                % Set the file name
                sysmeta.setFileName(full_file_path); % Question: pass the full_file_path here because in the java call create() there is no way to get the full_file_path in systemeta. No matlab d1object is used.
                
                % Set the access policy
                strArray = javaArray('java.lang.String', 1);
                permsArrary = javaArray('org.dataone.service.types.v1.Permission', 1);
                strArray(1,1) = String('public');
                permsArray(1,1) = Permission.READ;
                ap = AccessUtil.createSingleRuleAccessPolicy(strArray, permsArray);
                sysmeta.setAccessPolicy(ap);

                submitter = Subject();
                submitter.setValue('abc'); 
                sysmeta.setSubmitter(submitter);
                sysmeta.setRightsHolder(submitter);
                
                % Call MNode.create()
                returned_pid = matlab_mn_node.create([], obj_pid, data.getInputStream(), sysmeta);
                
                % Verify if create call is successful
                assertEqual(testCase, char(returned_pid.getValue()), char(obj_pid.getValue()));
                
            catch Error
                rethrow(Error);
            end
        end
        
              
        function testOverloadedCdfread(testCase)
            fprintf('\nIn testOverloadedCdfread() ...\n');            
            testCase.filename = 'src/test/resources/myScript7.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end 
        
        
        function testOverloadedCdfwrite(testCase)
            fprintf('\nIn testOverloadedCdfwrite() ...\n');            
            testCase.filename = 'src/test/resources/myScript8.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end 
        
        
        function testOverloadedHdfread(testCase)
            fprintf('\nIn testOverloadedHdfread() ...\n');            
            testCase.filename = 'src/test/resources/myScript11.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end 
        
        
        function testOverloadedHdfinfo(testCase)
            fprintf('\nIn testOverloadedHdfinfo() ...\n');            
            testCase.filename = 'src/test/resources/myScript12.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end 
        
        
        function testOverloadedH5read(testCase)
            fprintf('\nIn testOverloadedH5read ...\n');            
            testCase.filename = 'src/test/resources/myScript9.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end 
        
        
        function testOverloadedH5write(testCase)
            fprintf('\nIn testOverloadedH5write ...\n');            
            testCase.filename = 'src/test/resources/myScript10.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end 
        
        
        function testOverloadedTextread(testCase)
            fprintf('\nIn testOverloadedTextread ...\n');            
            testCase.filename = 'src/test/resources/myScript13.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end 
        
        
        function testOverloadedReadtable(testCase)
            fprintf('\nIn testOverloadedReadtable ...\n');            
            testCase.filename = 'src/test/resources/myScript14.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end 
        
        
        function testOverloadedWritetable(testCase)
            fprintf('\nIn testOverloadedWritetable ...\n');            
            testCase.filename = 'src/test/resources/myScript14.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end 
        
        function testOverloadedImread(testCase)
            fprintf('\nIn testOverloadedImread ...\n');            
            testCase.filename = 'src/test/resources/myScript15.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end 
        
        
        function testOverloadedImwrite(testCase)
            fprintf('\nIn testOverloadedImwrite ...\n');            
            testCase.filename = 'src/test/resources/myScript16.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end 
        
        
        function testOverloadedXmlread(testCase)
            fprintf('\nIn testOverloadedXmlread ...\n');
            testCase.filename = 'src/test/resources/myScript17.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
        end
        
        
        function testOverloadedXmlwrite(testCase)
            fprintf('\nIn testOverloadedXmlwrite ...\n');
            testCase.filename = 'src/test/resources/myScript18.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
        end
        
          
        function testOverloadedMultibandread(testCase)
            fprintf('\nIn testOverloadedMultibandread ...\n');
            testCase.filename = 'src/test/resources/myScript20.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
        end
        
                
        function testOverloadedMultibandwrite(testCase)
            fprintf('\nIn testOverloadedMultibandwrite ...\n');
            testCase.filename = 'src/test/resources/myScript19.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
        end
        
        
        function testOverloadedFitsread(testCase)
            fprintf('\nIn testOverloadedFitsread ...\n');
            testCase.filename = 'src/test/resources/myScript22.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
        end
        
                
        function testOverloadedFitswrite(testCase)
            fprintf('\nIn testOverloadedFitswrite ...\n');
            testCase.filename = 'src/test/resources/myScript21.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            run(scriptPath);
        end
        
        
        function testOverloadedNCopen(testCase)
            fprintf('\nIn testOverloadedNcread() ...\n');            
            testCase.filename = 'src/test/resources/myScript3.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
    
            run(scriptPath);
        end        
              
        function testOverloadedNCread(testCase)
            fprintf('\nIn testOverloadedNcread() ...\n');            
            testCase.filename = 'src/test/resources/myScript1.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end        
        
        function testOverloadedNCwrite(testCase)
            fprintf('\nIn testOverloadedNcwrite() ...\n');            
            testCase.filename = 'src/test/resources/myScript2.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
          
            run(scriptPath);
        end        
        
        function testOverloadedCSVread(testCase)
            fprintf('\nIn testOverloadedCSVread() ...\n');            
            testCase.filename = 'src/test/resources/myScript4.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
           
            run(scriptPath);
        end        
                       
        function testOverloadedLoad(testCase)
            % Todo: load coast (not working)
            fprintf('\nIn testOverloadedLoad() ...\n');            
            % testCase.filename = 'src/test/resources/myScript5.m';
             testCase.filename = 'test/resources/myScript1.m'; % load coast
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
           
            run(scriptPath);
        end        
        
        function testOverloadedDlmread(testCase)
          
            fprintf('\nIn testOverloadedDlmread ...\n');            
            testCase.filename = 'src/test/resources/myScript6.m';
            
            scriptPath = which(testCase.filename);
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
         
            run(scriptPath);
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

            %testCase.filename = 'src/test/resources/C3_C4_map_present_NA_Markup_v2_7.m';
             testCase.filename = 'src/test/resources/myScript2.m';

            set(testCase.mgr.configuration, 'certificate_path', '/tmp/x509up_u501');
            set(testCase.mgr.configuration, 'authentication_token', 'eyJhbGciOiJSUzI1NiJ9.eyJjb25zdW1lcktleSI6InRoZWNvbnN1bWVya2V5IiwiaXNzdWVkQXQiOiIyMDE1LTEwLTIxVDE0OjUzOjU1LjkzMyswMDowMCIsInVzZXJJZCI6IkNOPVlhbmcgQ2FvIEExOTQwMSxPPVVuaXZlcnNpdHkgb2YgSWxsaW5vaXMgYXQgVXJiYW5hLUNoYW1wYWlnbixDPVVTLERDPWNpbG9nb24sREM9b3JnIiwiZnVsbE5hbWUiOiJZYW5nQ2FvIiwidHRsIjo2NDgwMDAwMH0.BfUC9GrK-WJyrYLr_C1vi-9Ufp9n_9ZQLRT2Yeqhv0eD0nCLB_Zgc8bfCStZdar7Hol2bl9nm-igEcM7E7rm3i-JQFS_6qrqJu5vpJID-ADH7w2pusY_R7xve-qyQ5-pmznQUZOY5mwxkmFyzF4uXTawD6MpDa7T3ulc2y6By0Q9oE1BcoG8Z4GAmmXGCYvTK7JK4lv--uRKJ95VL68_wwmoH1y6Hi3f6qcv0ObBt94BhI-ItEh0vW8LrbKKNLpvQ7ivsbiniRNtzwKXwi72BJ83xqcxN1fi2kCs1-GOqcQhHIdTwtvO3d0xSf8G6UzLsHb7denTWPitMF3RA_G5etMd6v6Qgewfl0pS-fZuaP28OpzxMvHCwDGkFehtoszEdXQLiD_dylPuvEdB4RE2uvfXtR3kWEwGl1HHdaV7Eq4zVxu2N8iq27r213W_R23NdJcU9mOFbT0Dg2AVW17hhdw8Ulp_FvB4-K_JghDlbZSPZKig8TFeZiGd0feqwVrupd48fHacG4qDrTtu_Itn0My2i8dwImc0EQtscrBPUkR-UGE4xJab79OalB7imEQRiO4C9nlrvbrabGixmn1d0FPZ5fKo9Pe00aH7GqiibS3P7roe1u7GQVSMIBH6QqkE8MOTUndyx76CXZ4xR1VnuGZwA9K-2-ZW7FsqiW_7Hcg');
            
            scriptPath = which(testCase.filename); % get the absolute path of the script
            if isempty(scriptPath)
                [status, struc] = fileattrib(testCase.filename);
                scriptPath = struc.Name;
            end
            
            [scriptParentPath, name, ext] = fileparts(scriptPath);
            tag = 'myscript2'; 
 
            currentDir = pwd();
            cd(scriptParentPath);
            testCase.mgr.record(scriptPath, tag);  
            cd(currentDir);

            set(testCase.mgr.configuration, ...
                'target_member_node_id', 'urn:node:mnDevUCSB2');
       
            % set(testCase.mgr.configuration, ...
            %    'target_member_node_id', 'urn:node:mnDevUNM2');
            
            set(testCase.mgr.configuration, ...
                'coordinating_node_base_url', 'https://cn-dev-2.test.dataone.org/cn');
            
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
        end
        
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
