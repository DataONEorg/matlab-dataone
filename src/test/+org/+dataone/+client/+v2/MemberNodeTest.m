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
            
            test_config_directory = fullfile(home_dir, '.d1test');
            
            % for unit testing, set the D1 directory to a test location
            config = Configuration( ...
                'configuration_directory', test_config_directory);
            testCase.mgr = RunManager.getInstance(config);
            
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
            
            mn = DataONEClient.getMN('urn:node:mnDevUCSB2');
            pid = 'dv.test.006';
            
            sysmeta = mn.getSystemMetadata([], pid);
            assertEqual(testCase, sysmeta.identifier, pid);
            
        end
        
        function testMNodeGet(testCase)
        % TESTMNODEGET Tests the DataONE get() API call to a Member Node
        
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
            
            % Get a MNode matlab instance to the member node
            % mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            matlab_mn_node = MemberNode('urn:node:mnDevUCSB2');
            
            % Download a single D1 object
            object_list = matlab_mn_node.node.listObjects([], [], [], [], [], [], [], []);
            
            objList = object_list.getObjectInfoList();
            for i=1:length(objList)
                obj_pid = objList.get(i).getIdentifier().getValue();
                if ~isempty(obj_pid)
                    break;
                end
            end
            
            % Call MemberNode.get()
            pid = Identifier();
            pid.setValue(obj_pid);
            item = matlab_mn_node.get([], pid);
            
            item_size = matlab_mn_node.getSystemMetadata([], char(obj_pid)).size;
            % Verify if get() call is successful
            assertEqual(testCase, length(item), item_size);
            
            % Verify if the execution_input_ids contains one pid
            size = length(testCase.mgr.execution.execution_input_ids);
            assertEqual(testCase, size, 1);
            
            % Clear runtime input/output sources
            testCase.mgr.execution.execution_input_ids = {};
            testCase.mgr.execution.execution_output_ids = {};
            all_keys = keys(testCase.mgr.execution.execution_objects);
            remove(testCase.mgr.execution.execution_objects, all_keys);
        end
        
        function testMNodeCreate(testCase)
        % TESTMNODECREATE Tests the DataONE create() API call to a Member Node
        
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
            import org.dataone.service.types.v1.NodeReference;
            import org.dataone.client.auth.CertificateManager;
            import java.security.cert.X509Certificate;
                
            testCase.filename = 'src/test/resources/testData.csv';
            full_file_path = which(testCase.filename);
            if isempty(full_file_path)
                [status, struc] = fileattrib(testCase.filename);
                full_file_path = struc.Name;
            end
            
            % Set the Node ID
            mnodeRef = NodeReference();
            mnodeRef.setValue('urn:node:mnDevUCSB2');
            
            % Get a MNode matlab instance to the member node
            % mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            matlab_mn_node = MemberNode('urn:node:mnDevUCSB2');
            
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
                
                % Get a certificate for the Root CA
                certificate = CertificateManager.getInstance().loadCertificate();
                if ~isempty(certificate)
                    dn = CertificateManager.getInstance().getSubjectDN(certificate).toString();
                    standardizedName = char(CertificateManager.getInstance().standardizeDN(dn)); % convert java string to char nov-2-2015
                else
                    standardizedName = '';
                end
                
                % Set the submitter (required)
                submitter = Subject();
                submitter.setValue(standardizedName);
                sysmeta.setSubmitter(submitter);
                sysmeta.setRightsHolder(submitter);
                
                % Set the node filelds (required)
                sysmeta.setOriginMemberNode(mnodeRef);
                sysmeta.setAuthoritativeMemberNode(mnodeRef);
                
                % Call MemberNode.create()
                returned_pid = matlab_mn_node.create([], obj_pid, data.getInputStream(), sysmeta);
                
                % Verify if create() call is successful
                assertEqual(testCase, char(returned_pid.getValue()), char(obj_pid.getValue()));
                
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
        
        function testMNodeUpdate(testCase)
        % TESTMNODEGET Tests the DataONE update() API call to a Member Node
        
            % Certificate x509up_u501 is requried to run this unit test. Dec-11-2015
            fprintf('\nIn test Member Node Update() ...\n');
            
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
            import org.dataone.service.types.v1.NodeReference;
            import org.apache.commons.io.IOUtils;
            import java.nio.charset.StandardCharsets;
            import org.dataone.service.util.TypeMarshaller;
            
            testCase.filename = 'src/test/resources/testData.csv';
            full_file_path = which(testCase.filename);
            if isempty(full_file_path)
                [status, struc] = fileattrib(testCase.filename);
                full_file_path = struc.Name;
            end
            
            % Set the Node ID
            mnodeRef = NodeReference();
            mnodeRef.setValue('urn:node:mnDevUCSB2');
            
            % Get a MNode matlab instance to the member node
            % mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            matlab_mn_node = MemberNode('urn:node:mnDevUCSB2');
            
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
            
            obj_pid = Identifier();
            obj_pid.setValue(java.util.UUID.randomUUID().toString());
            
            objectFile = File(full_file_path);
            data = FileDataSource(objectFile);
            
            try
                % Gets a certificate
                import org.dataone.client.auth.CertificateManager;
                import java.security.cert.X509Certificate;
                
                % Get a certificate for the Root CA
                certificate = CertificateManager.getInstance().loadCertificate();
                if ~isempty(certificate)
                    dn = CertificateManager.getInstance().getSubjectDN(certificate).toString();
                    standardizedName = char(CertificateManager.getInstance().standardizeDN(dn)); % convert java string to char nov-2-2015
                else
                    standardizedName = '';
                end
                
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
                
                % Set the submitter (required)
                submitter = Subject();
                submitter.setValue(standardizedName);
                sysmeta.setSubmitter(submitter);
                sysmeta.setRightsHolder(submitter);
                
                % Set the access policy
                strArray = javaArray('java.lang.String', 1);
                permsArray = javaArray('org.dataone.service.types.v1.Permission', 1);
                strArray(1,1) = String('public');
                permsArray(1,1) = Permission.READ;
                ap = AccessUtil.createSingleRuleAccessPolicy(strArray, permsArray);
                sysmeta.setAccessPolicy(ap);
                
                % Set the node filelds (required)
                sysmeta.setOriginMemberNode(mnodeRef);
                sysmeta.setAuthoritativeMemberNode(mnodeRef);
                
                % Call MemberNode.create()
                returned_pid = matlab_mn_node.create([], obj_pid, data.getInputStream(), sysmeta);
                
                % Call MemberNode.get()
                obj_inputstream = matlab_mn_node.get([], returned_pid);
                
                % For testing
                % d2ObjString = IOUtils.toString(obj_inputstream, StandardCharsets.UTF_8.name());
                % d2ObjString
                
                % Call MultipartMNode.getSystemMetadata() by making a java call
                sysmeta = matlab_mn_node.node.getSystemMetadata( [], returned_pid );
                
                % Generate a new pid
                new_pid = Identifier();
                new_pid.setValue(java.util.UUID.randomUUID().toString());
                sysmeta.setIdentifier(new_pid);
                
                % Call MemberNode.update()
                returned_pid = matlab_mn_node.update([], returned_pid, obj_inputstream, new_pid, sysmeta);
                
                % Verify if update() call is successful
                assertEqual(testCase, char(returned_pid.getValue()), char(new_pid.getValue()));
                
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
        
        function testMNodeListObjects(testCase)
            % Certificate x509up_u501 is requried to run this unit test. Dec-10-2015
            fprintf('\nIn test Member Node listObjects ...\n');
            
            import org.dataone.client.v2.MemberNode;
            import org.dataone.service.types.v1.Identifier;
            
            % Get a MNode matlab instance to the member node
            % mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            matlab_mn_node = MemberNode('urn:node:mnDevUCSB2');
            
            % Use matlab wrapper function 
            [ol1, start1, count1, total1] = matlab_mn_node.listObjects([], [], [], [], [], [], [], []);
            assertEqual(testCase, start1, 0);
            
            % Use matlab wrapper function
            [ol2, start2, count2, total2] = matlab_mn_node.listObjects([], [], [], [], [], [], '100', '50');
            assertEqual(testCase, start2, 100);
            assertEqual(testCase, count2, 50);
            
            assertEqual(testCase, total1, total2);
            
            [ol3, start3, count3, total3] = matlab_mn_node.listObjects([], [], [], [], [], [], '0', 50000);
            assertEqual(testCase, count3, length(ol3));
            
        end
        
        function testMNodeGetChecksum(testCase)
            % Certificate x509up_u501 is requried to run this unit test. Dec-10-2015
            fprintf('\nIn test Member Node getChecksum ...\n');
            
            import org.dataone.client.v2.MemberNode;
            import org.dataone.service.types.v1.Identifier;
            
            % Get a MNode matlab instance to the member node
            % mn_base_url = 'https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn';
            matlab_mn_node = MemberNode('urn:node:mnDevUCSB2');
            
            % Get an identifier of a D1 object from the member node
            object_list = matlab_mn_node.node.listObjects([], [], [], [], [], [], [], []);
            objList = object_list.getObjectInfoList();
            for i=1:length(objList)
                pid_value = objList.get(i-1).getIdentifier().getValue();
                if ~isempty(pid_value)
                    break;
                end
            end
            
            checkAlg = 'SHA-1';
            [checksum, checksumAlgorithm] = matlab_mn_node.getChecksum([], pid_value, checkAlg);
            
            assert(~isempty(checksum));
            assert(~isempty(checksumAlgorithm));
        end
        
        function testMNodeArchive(testCase)
           
            % Certificate x509up_u501 is requried to run this unit test. 
            fprintf('\nIn test Member Node archive() ...\n');
            
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
            import org.dataone.service.types.v1.NodeReference;
            import org.dataone.client.auth.CertificateManager;
            import java.security.cert.X509Certificate;
                
            testCase.filename = 'src/test/resources/testData.csv';
            full_file_path = which(testCase.filename);
            if isempty(full_file_path)
                [status, struc] = fileattrib(testCase.filename);
                full_file_path = struc.Name;
            end
            
            % Set the Node ID
            mnodeRef = NodeReference();
            mnodeRef.setValue('urn:node:mnDevUCSB2');
            
            % Get a MNode matlab instance to the member node
            matlab_mn_node = MemberNode('urn:node:mnDevUCSB2');
            
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
                sysmeta.setFileName(full_file_path); 
                
                % Set the access policy
                strArray = javaArray('java.lang.String', 1);
                permsArrary = javaArray('org.dataone.service.types.v1.Permission', 1);
                strArray(1,1) = String('public');
                permsArray(1,1) = Permission.READ;
                ap = AccessUtil.createSingleRuleAccessPolicy(strArray, permsArray);
                sysmeta.setAccessPolicy(ap);
                
                % Get a certificate for the Root CA
                certificate = CertificateManager.getInstance().loadCertificate();
                if ~isempty(certificate)
                    dn = CertificateManager.getInstance().getSubjectDN(certificate).toString();
                    standardizedName = char(CertificateManager.getInstance().standardizeDN(dn)); % convert java string to char nov-2-2015
                else
                    standardizedName = '';
                end
                
                % Set the submitter (required)
                submitter = Subject();
                submitter.setValue(standardizedName);
                sysmeta.setSubmitter(submitter);
                sysmeta.setRightsHolder(submitter);
                
                % Set the node filelds (required)
                sysmeta.setOriginMemberNode(mnodeRef);
                sysmeta.setAuthoritativeMemberNode(mnodeRef);
                
                % Make a Java create() call
                pid = matlab_mn_node.node.create([], obj_pid, data.getInputStream(), sysmeta);
                
                % Make a Matlab archive() call
                pid_value = char(pid.getValue());
                pid2 = matlab_mn_node.archive([], pid_value);
                
                assertEqual(testCase, pid2, pid_value);
                
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