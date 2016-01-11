% MEMBERNODETEST A class used to test the org.dataone.client.v2.MemberNode class functionality
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

classdef MemberNodeTest < matlab.unittest.TestCase
    
    
    properties
        % The RunManager instance used in the tests
        mgr;
        
        filename
    end
    
    methods (TestMethodSetup)
        
        function setUp(testCase)
            import org.dataone.client.run.RunManager;
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
            % config = Configuration( ...
            %     'configuration_directory', test_config_directory);
            % testCase.mgr = RunManager.getInstance(config);

            config = Configuration( ...
                'source_member_node_id', 'urn:node:mnDevUCSB2', ...
                'target_member_node_id', 'urn:node:mnDevUCSB2', ...
                'format_id', 'application/octet-stream', ...
                'submitter', 'submitter', ...
                'rights_holder', 'rightsHolder', ...
                'coordinating_node_base_url', 'https://cn-dev-2.test.dataone.org/cn', ...
                'certificate_path', '/tmp/x509up_u501', ...
                'authentication_token', '');
        end
        
    end
    
    methods (TestMethodTeardown)
        
        function tearDown(testCase)
            
            % Reset the Matlab DataONE Toolbox environment
            resetEnvironment(testCase);

        end
        
    end
    
    methods (Test)
        
        function testGetSystemMetadata(testCase)
        % TESTGETSYSTEMMETADATA Tests the DataONE getSystemMetadata() API call to a Member Node
            
            import org.dataone.client.v2.DataONEClient;
            import org.dataone.client.v2.Session;
            
            session = Session();
            
            mn = DataONEClient.getMN('urn:node:mnDevUCSB2');
            pid = 'dv.test.006';
            
            sysmeta = mn.getSystemMetadata(session, pid);
            assertEqual(testCase, sysmeta.identifier, pid);
            
        end
        
        function testGet(testCase)
        % TESTGET Tests the DataONE get() API call to a Member Node
        
            fprintf('\nIn test get() ...\n');
            
            import org.dataone.client.v2.MemberNode;
            
            % Create a fake run
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
            
            
            % Get a MNode matlab instance to the member node
            % mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            matlab_mn_node = MemberNode('urn:node:mnDevUCSB2');
            
            % Download a single D1 object
            object_list = matlab_mn_node.node.listObjects([], [], [], [], [], [], [], []);
            
            objList = object_list.getObjectInfoList();
            for i=1:length(objList)
                pid = char(objList.get(i).getIdentifier().getValue());
                if ( ~isempty(pid) )
                    break;
                end
            end
            
            import org.dataone.client.v2.Session;
            session = Session();
            % Call MemberNode.get()
            object = matlab_mn_node.get(session, pid);
            
            item_size = ...
                matlab_mn_node.getSystemMetadata(session, pid).size;
            % Verify if get() call is successful
            assertEqual(testCase, length(object), item_size);
            
            % Verify if the execution_input_ids contains one pid
            size = length(testCase.mgr.execution.execution_input_ids);
            assertEqual(testCase, size, 1);
            
            % Clear runtime input/output sources
            testCase.mgr.execution.execution_input_ids = {};
            testCase.mgr.execution.execution_output_ids = {};
            all_keys = keys(testCase.mgr.execution.execution_objects);
            remove(testCase.mgr.execution.execution_objects, all_keys);
        end
        
        function testUpdateSystemMetadata(testCase)
            fprintf('\nIn test Member Node updateSystemMetadata() ...\n');
            
            import org.dataone.client.v2.MemberNode;
            import org.dataone.service.types.v1.util.ChecksumUtil;
            import org.apache.commons.io.IOUtils;
                
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src/test/resources/testData.csv');
            full_file_path = which(testCase.filename);
            if isempty(full_file_path)
                [status, struc] = fileattrib(testCase.filename);
                full_file_path = struc.Name;
            end
                        
            % Get a MNode matlab instance to the member node
            % mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            mn = MemberNode('urn:node:mnDevUCSB2');
            
            pid = char(java.util.UUID.randomUUID().toString());
            
            % Get the data as bytes
            fileId = fopen(full_file_path, 'r');
            data = int8(fread(fileId));

            try
                import org.dataone.client.v2.SystemMetadata;
                sysmeta = SystemMetadata();
                
                % Set the identifier
                set(sysmeta, 'identifier', pid);
                
                % Add the object format id
                set(sysmeta, 'formatId', 'text/csv');
                
                % Add the file size
                fileInfo = dir(full_file_path);
                fileSize = fileInfo.bytes;
                set(sysmeta, 'size', fileSize);
                
                % Add the checksum
                checksum = ChecksumUtil.checksum(data, 'SHA-1');
                chksum.value = char(checksum.getValue());
                chksum.algorithm = char(checksum.getAlgorithm());
                set(sysmeta, 'checksum', chksum);
                
                % Set the file name
                set(sysmeta, 'fileName', full_file_path);
                
                % Set the access policy
                accessPolicy.rules = ...
                    containers.Map('KeyType', 'char', 'ValueType', 'char');
                accessPolicy.rules('public') = 'read';
                set(sysmeta, 'accessPolicy', accessPolicy);

                % Get a session
                import org.dataone.client.v2.Session;
                session = Session();
                                
                % Set the submitter (required)
                set(sysmeta, 'submitter', session.account_subject);
                set(sysmeta, 'rightsHolder', session.account_subject);
                
                % Set the node fields (required)
                set(sysmeta, 'originMemberNode', 'urn:node:mnDevUCSB2');
                set(sysmeta, 'authoritativeMemberNode', 'urn:node:mnDevUCSB2');

                % Call MemberNode.create()
                returned_pid = mn.create(session, pid, data, sysmeta);
                
                % Then update the system metadata
                mn_sysmeta = mn.getSystemMetadata(session, pid);
                
                set(mn_sysmeta, 'seriesId', ['series_' pid]);
                
                updated = mn.updateSystemMetadata(session, pid, mn_sysmeta);
                
                assertEqual(testCase, updated, true);

                % Clear runtime input/output sources
                testCase.mgr.execution.execution_input_ids = {};
                testCase.mgr.execution.execution_output_ids = {};
                all_keys = keys(testCase.mgr.execution.execution_objects);
                remove(testCase.mgr.execution.execution_objects, all_keys);

            catch Error
                rethrow(Error);
                
            end
        end
        
        function testCreate(testCase)
        % TESTCREATE Tests the DataONE create() API call to a Member Node
        
            fprintf('\nIn test create() ...\n');
            
            import org.dataone.client.v2.MemberNode;
            import org.dataone.service.types.v1.util.ChecksumUtil;
            import org.apache.commons.io.IOUtils;
                
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src/test/resources/testData.csv');
            full_file_path = which(testCase.filename);
            if isempty(full_file_path)
                [status, struc] = fileattrib(testCase.filename);
                full_file_path = struc.Name;
                
            end
                        
            % Get a MNode matlab instance to the member node
            % mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            mn = MemberNode('urn:node:mnDevUCSB2');
            
            % Get a session
            import org.dataone.client.v2.Session;
            session = Session();
            
            % Create a fake run
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
            
            pid = char(java.util.UUID.randomUUID().toString());
            
            % Get the data as bytes
            fileId = fopen(full_file_path, 'r');
            data = int8(fread(fileId));
            
            try
                import org.dataone.client.v2.SystemMetadata;
                sysmeta = SystemMetadata();
                
                % Set the identifier
                set(sysmeta, 'identifier', pid);
                
                % Add the object format id
                set(sysmeta, 'formatId', 'text/csv');
                
                % Add the file size
                fileInfo = dir(full_file_path);
                fileSize = fileInfo.bytes;
                set(sysmeta, 'size', fileSize);
                
                % Add the checksum
                checksum = ChecksumUtil.checksum(data, 'SHA-1');
                chksum.value = char(checksum.getValue());
                chksum.algorithm = char(checksum.getAlgorithm());
                set(sysmeta, 'checksum', chksum);
                
                % Set the file name
                set(sysmeta, 'fileName', full_file_path);
                
                % Set the access policy
                accessPolicy.rules = ...
                    containers.Map('KeyType', 'char', 'ValueType', 'char');
                accessPolicy.rules('public') = 'read';
                set(sysmeta, 'accessPolicy', accessPolicy);
                
                % Set the submitter (required)
                set(sysmeta, 'submitter', session.account_subject);
                set(sysmeta, 'rightsHolder', session.account_subject);
                
                % Set the node fields (required)
                set(sysmeta, 'originMemberNode', 'urn:node:mnDevUCSB2');
                set(sysmeta, 'authoritativeMemberNode', 'urn:node:mnDevUCSB2');

                % Call MemberNode.create()
                returned_pid = mn.create(session, pid, data, sysmeta);
                
                % Verify if create() call is successful
                assertEqual(testCase, returned_pid, pid);
                
                % Verify if the execution_output_ids contains one pid
                size = length(testCase.mgr.execution.execution_output_ids);
                assertEqual(testCase, size, 1);
                
                % Clear runtime input/output sources
                testCase.mgr.execution.execution_input_ids = {};
                testCase.mgr.execution.execution_output_ids = {};
                all_keys = keys(testCase.mgr.execution.execution_objects);
                remove(testCase.mgr.execution.execution_objects, all_keys);
                
            catch Error
                rethrow(Error);
            end
        end
        
        function testUpdate(testCase)
        % TESTGET Tests the DataONE update() API call to a Member Node
        
            fprintf('\nIn test update() ...\n');
            
            import org.dataone.client.v2.MemberNode;
            import org.dataone.client.v2.Session;
            import org.dataone.client.v2.SystemMetadata;
            import org.dataone.service.types.v1.util.ChecksumUtil;
            import org.apache.commons.io.IOUtils;
            
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src/test/resources/testData.csv');
            full_file_path = which(testCase.filename);
            if isempty(full_file_path)
                [status, struc] = fileattrib(testCase.filename);
                full_file_path = struc.Name;
            end
                        
            % Get a session
            session = Session();
            
            % Get a MNode matlab instance to the member node
            % mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            mn = MemberNode('urn:node:mnDevUCSB2');
            
            % Create a faked run
            import org.dataone.client.run.Execution;
            run3 = Execution();
            set(run3, 'tag', 'test_MN_Update');
            testCase.mgr.execution = run3;
            
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
            
            pid = char(java.util.UUID.randomUUID().toString());
            
            % Get the data as bytes
            fileId = fopen(full_file_path, 'r');
            data = int8(fread(fileId));
            
            try
                
                sysmeta = SystemMetadata();
                
                % Set the identifier
                set(sysmeta, 'identifier', pid);
                
                % Add the object format id
                set(sysmeta, 'formatId', 'text/csv');
                
                % Add the file size
                fileInfo = dir(full_file_path);
                fileSize = fileInfo.bytes;
                set(sysmeta, 'size', fileSize);

                % Add the checksum
                checksum = ChecksumUtil.checksum(data, 'SHA-1');
                chksum.value = char(checksum.getValue());
                chksum.algorithm = char(checksum.getAlgorithm());
                set(sysmeta, 'checksum', chksum);
                
                % Set the file name
                set(sysmeta, 'fileName', full_file_path);
                
                % Set the submitter (required)
                set(sysmeta, 'submitter', session.account_subject);
                set(sysmeta, 'rightsHolder', session.account_subject);

                % Set the access policy
                accessPolicy.rules = ...
                    containers.Map('KeyType', 'char', 'ValueType', 'char');
                accessPolicy.rules('public') = 'read';
                set(sysmeta, 'accessPolicy', accessPolicy);
                
                % Set the node fields (required)
                set(sysmeta, 'originMemberNode', 'urn:node:mnDevUCSB2');
                set(sysmeta, 'authoritativeMemberNode', 'urn:node:mnDevUCSB2');

                % Call MemberNode.create()
                returned_pid = mn.create(session, pid, data, sysmeta);
                
                % Call MemberNode.get()
                uploaded_object = mn.get(session, returned_pid);
                
                % For testing
                % d2ObjString = IOUtils.toString(obj_inputstream, StandardCharsets.UTF_8.name());
                % d2ObjString
                
                % Call MultipartMNode.getSystemMetadata() by making a java call
                sysmeta = mn.getSystemMetadata(session, returned_pid );
                
                % Generate a new pid
                new_pid = char(java.util.UUID.randomUUID().toString());
                set(sysmeta, 'identifier', new_pid);
                
                % Call MemberNode.update()
                updated_pid = mn.update(session, returned_pid, uploaded_object, new_pid, sysmeta);
                
                % Verify if update() call is successful
                assertEqual(testCase, updated_pid, new_pid);
                
                % Verify if the execution_output_ids contains two pids
                size1 = length(testCase.mgr.execution.execution_output_ids);
                assertEqual(testCase, size1, 2); 
                
                % Verify if the execution_input_ids contains one pids
                size2 = length(testCase.mgr.execution.execution_input_ids);
                assertEqual(testCase, size2, 1);
                
                % Clear runtime input/output sources
                testCase.mgr.execution.execution_input_ids = {};
                testCase.mgr.execution.execution_output_ids = {};
                all_keys = keys(testCase.mgr.execution.execution_objects);
                remove(testCase.mgr.execution.execution_objects, all_keys);
            
            catch Error
                rethrow(Error);
                
            end
        end
        
        function testListObjects(testCase)
            fprintf('\nIn test listObjects ...\n');
            
            import org.dataone.client.v2.MemberNode;
            import org.dataone.client.v2.Session;
            
            % Get a Session
            session = Session();
            
            % Get a MNode matlab instance to the member node
            % mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            mn = MemberNode('urn:node:mnDevUCSB2');
            
            % Use matlab wrapper function 
            [ol1, start1, count1, total1] = ...
                mn.listObjects(session, [], [], [], [], [], [], []);
            assertEqual(testCase, start1, 0);
            
            % Use matlab wrapper function
            [ol2, start2, count2, total2] = ...
                mn.listObjects(session, [], [], [], [], [], '100', '50');
            assertEqual(testCase, start2, 100);
            assertEqual(testCase, count2, 50);
            
            assertEqual(testCase, total1, total2);
            
            [ol3, start3, count3, total3] = ...
                mn.listObjects(session, [], [], [], [], [], '0', 50000);
            assertEqual(testCase, count3, length(ol3));

        end
        
        function testGetChecksum(testCase)
            fprintf('\nIn test getChecksum ...\n');
            
            import org.dataone.client.v2.MemberNode;
            
            % Get a MNode matlab instance to the member node
            % mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            mn = MemberNode('urn:node:mnDevUCSB2');
            
            import org.dataone.client.v2.Session;
            session = Session();
            
            % Get an identifier of a D1 object from the member node
            object_list = mn.node.listObjects([], [], [], [], [], [], [], []);
            objList = object_list.getObjectInfoList();
            for i=1:length(objList)
                pid = char(objList.get(i-1).getIdentifier().getValue());
                if ( ~isempty(pid) )
                    break;
                    
                end
            end
            
            algorithm = 'SHA-1';
            checksum = mn.getChecksum(session, pid, algorithm);
            
            assert(~isempty(checksum.value));
            assert(~isempty(checksum.algorithm));
            
        end
        
        function testArchive(testCase)
           
            fprintf('\nIn test archive() ...\n');
            
            import org.dataone.client.v2.MemberNode;
            import org.dataone.client.v2.Session;
            import org.dataone.client.v2.SystemMetadata;
            import org.dataone.client.v2.Session;
            import org.dataone.service.types.v1.util.ChecksumUtil;
                
            testCase.filename = ...
                fullfile( ...
                    testCase.mgr.configuration.matlab_dataone_toolbox_directory, ...
                    'src/test/resources/testData.csv');
            full_file_path = which(testCase.filename);
            if isempty(full_file_path)
                [status, struc] = fileattrib(testCase.filename);
                full_file_path = struc.Name;
            end
            
            % Get a session
            session = Session();
            
            % Get a MNode matlab instance to the member node
            mn = MemberNode('urn:node:mnDevUCSB2');
            
            pid = char(java.util.UUID.randomUUID().toString());
            
            % Get the data as bytes
            fileId = fopen(full_file_path, 'r');
            data = int8(fread(fileId));
            
            try
                sysmeta = SystemMetadata();
                
                % Set the identifier
                set(sysmeta, 'identifier', pid);
                
                % Add the object format id
                set(sysmeta, 'formatId', 'text/csv');
                
                % Add the file size
                fileInfo = dir(full_file_path);
                fileSize = fileInfo.bytes;
                set(sysmeta, 'size', fileSize);

                checksum = ChecksumUtil.checksum(data, 'SHA-1');
                chksum.value = char(checksum.getValue());
                chksum.algorithm = char(checksum.getAlgorithm());
                set(sysmeta, 'checksum', chksum);
                
                % Set the file name
                set(sysmeta, 'fileName', full_file_path);
                
                % Set the access policy
                accessPolicy.rules = ...
                    containers.Map('KeyType', 'char', 'ValueType', 'char');
                accessPolicy.rules('public') = 'read';
                set(sysmeta, 'accessPolicy', accessPolicy);
                                
                % Set the submitter (required)
                set(sysmeta, 'submitter', session.account_subject);
                set(sysmeta, 'rightsHolder', session.account_subject);
                
                % Set the node fields (required)
                set(sysmeta, 'originMemberNode', 'urn:node:mnDevUCSB2');
                set(sysmeta, 'authoritativeMemberNode', 'urn:node:mnDevUCSB2');

                % Call MemberNode.create()
                pid = mn.create(session, pid, data, sysmeta);
                
                % Call MemberNode.archive()
                pid2 = mn.archive(session, pid);
                
                assertEqual(testCase, pid2, pid);
                
                % Clear runtime input/output sources
                testCase.mgr.execution.execution_input_ids = {};
                testCase.mgr.execution.execution_output_ids = {};
                all_keys = keys(testCase.mgr.execution.execution_objects);
                remove(testCase.mgr.execution.execution_objects, all_keys);
                
            catch Error
                rethrow(Error);
            end
        end
                
        function testGenerateIdentifier(testCase)
            
            fprintf('\nIn test Member Node generateIdentifier() ...\n');
            
            % Todo: need to implement
        end
                
        function testGetCapabilities(testCase)
            
            fprintf('\nIn test Member Node getCapabilities() ...\n');
            
            import org.dataone.client.v2.MemberNode;
            
            % Get a MNode matlab instance to the member node
            matlab_mn_node = MemberNode('urn:node:mnDevUCSB2');
            
            node_description = matlab_mn_node.getCapabilities();
            
            assert(~isempty(node_description));
        end
               
        function testPing(testCase)
            
            fprintf('\nIn test Member Node ping() ...\n');
            
            import org.dataone.client.v2.MemberNode;
            
            % Get a MNode matlab instance to the member node
            matlab_mn_node = MemberNode('urn:node:mnDevUCSB2');
            
            date = matlab_mn_node.ping();
            
            assert(~isempty(date));
        end
        
        function testIsAuthorized(testCase)
        % TESTISAUTHORIZED Tests the DataONE isAuthorized() API call to a Member Node
            
            import org.dataone.client.v2.DataONEClient;
            import org.dataone.client.v2.Session;
            
            session = Session();
            
            mn = DataONEClient.getMN('urn:node:mnDevUCSB2');
            pid = 'dv.test.006';
            
            authorized = mn.isAuthorized(session, pid, 'read');
            
            assertEqual(testCase, authorized, true);
            
        end
    end
    
    methods (Access = 'private')
        
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