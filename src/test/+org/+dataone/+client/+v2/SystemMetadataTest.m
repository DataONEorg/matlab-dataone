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
            
        end
        
        function testSet(testCase)
            % TESTSET tests the set() function for correctness
            
            import org.dataone.client.v2.SystemMetadata;
            sysmeta = SystemMetadata();
            
            set(sysmeta, 'serialVersion', 0);
            assertEqual(testCase, sysmeta.serialVersion, 0);
            
            set(sysmeta, 'identifier', 'my-very-unique-id.1.1');
            assertEqual(testCase, sysmeta.identifier, 'my-very-unique-id.1.1');
            
            set(sysmeta, 'formatId', 'text/plain');
            assertEqual(testCase, sysmeta.formatId, 'text/plain');
            
            set(sysmeta, 'size', 1234567890);
            assertEqual(testCase, sysmeta.size, 1234567890);
            
            checksum(1).value = 'ba74468f570cc85df03e87b098c07d048e2f19c1';
            checksum(1).algorithm = 'SHA-1';
            set(sysmeta, 'checksum', checksum);
            assertEqual(testCase, sysmeta.checksum.value, ...
                'ba74468f570cc85df03e87b098c07d048e2f19c1');
            assertEqual(testCase, sysmeta.checksum.algorithm, 'SHA-1');

            set(sysmeta, 'submitter', ...
                'CN=Christopher Jones A2108, O=Google, C=US, DC=cilogon, DC=org');
            assertEqual(testCase, sysmeta.submitter, ...
                'CN=Christopher Jones A2108, O=Google, C=US, DC=cilogon, DC=org');
            
            set(sysmeta, 'rightsHolder', 'CN=Christopher Jones A2108, O=Google, C=US, DC=cilogon, DC=org');
            assertEqual(testCase, sysmeta.rightsHolder, ...
                'CN=Christopher Jones A2108, O=Google, C=US, DC=cilogon, DC=org');
            
            accessPolicy.rules = containers.Map('KeyType', 'char', 'ValueType', 'char');
            accessPolicy.rules('public') = 'read';
            set(sysmeta, 'accessPolicy', accessPolicy);
            kys = keys(sysmeta.accessPolicy.rules);
            vals = values(sysmeta.accessPolicy.rules);
            assertEqual(testCase, kys{1}, 'public');
            assertEqual(testCase, vals{1}, 'read');
            
            replicationPolicy.replicationAllowed = true;
            replicationPolicy.numberOfReplicas = 2;
            replicationPolicy.preferredNodes = {'urn:node:FASTNODE', 'urn:node:FRIENDNODE'};
            replicationPolicy.blockedNodes = {'urn:node:SLOWNODE', 'urn:node:FOENODE'};
            set(sysmeta, 'replicationPolicy', replicationPolicy);
            assertTrue(testCase, sysmeta.replicationPolicy.replicationAllowed);
            assertEqual(testCase, sysmeta.replicationPolicy.numberOfReplicas, 2);
            assertEqual(testCase, sysmeta.replicationPolicy.preferredNodes, ...
                {'urn:node:FASTNODE', 'urn:node:FRIENDNODE'});
            assertEqual(testCase, sysmeta.replicationPolicy.blockedNodes, ...
                {'urn:node:SLOWNODE', 'urn:node:FOENODE'});

            set(sysmeta, 'obsoletes', 'my-very-unique-id.0.1');
            assertEqual(testCase, sysmeta.obsoletes, 'my-very-unique-id.0.1');

            set(sysmeta, 'obsoletedBy', 'my-very-unique-id.2.1');
            assertEqual(testCase, sysmeta.obsoletedBy, 'my-very-unique-id.2.1');

            set(sysmeta, 'archived', false);
            assertFalse(testCase, sysmeta.archived);
            
            new_date = datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSSZ');
            set(sysmeta, 'dateUploaded', new_date);
            assertEqual(testCase, sysmeta.dateUploaded, new_date);
            
            set(sysmeta, 'dateSysMetadataModified', new_date);
            assertEqual(testCase, sysmeta.dateSysMetadataModified, new_date);

            set(sysmeta, 'originMemberNode', 'urn:node:MYNODE');
            assertEqual(testCase, sysmeta.originMemberNode, 'urn:node:MYNODE');

            set(sysmeta, 'authoritativeMemberNode', 'urn:node:MYNODE');
            assertEqual(testCase, sysmeta.authoritativeMemberNode, 'urn:node:MYNODE');

            % sysmeta.replica = ;
            
            set(sysmeta, 'seriesId', 'doi:10.5063/F12W3B8Z');
            assertEqual(testCase, sysmeta.seriesId, 'doi:10.5063/F12W3B8Z');
            
            mediaType.name = 'text/plain';
            mediaType.properties = containers.Map('KeyType', 'char', 'ValueType', 'char');
            mediaType.properties('my-prop-1') = 'my-val-1';
            mediaType.properties('my-prop-2') = 'my-val-2';
            set(sysmeta, 'mediaType', mediaType);
            assertEqual(testCase, sysmeta.mediaType.name, 'text/plain');
            mkeys = keys(sysmeta.mediaType.properties);
            mvals = values(sysmeta.mediaType.properties);
            assertEqual(testCase, mkeys{1}, 'my-prop-1');
            assertEqual(testCase, mkeys{2}, 'my-prop-2');
            assertEqual(testCase, mvals{1}, 'my-val-1');
            assertEqual(testCase, mvals{2}, 'my-val-2');
            
            set(sysmeta, 'fileName', 'my-file-name.txt');
            assertEqual(testCase, sysmeta.fileName, 'my-file-name.txt');
            
            xml = sysmeta.toXML();
            
            % import org.dataone.service.util.TypeMarshaller;
            % import java.io.ByteArrayInputStream;
            % import java.nio.charset.StandardCharsets;
            % import java.lang.String;
            %
            % jXML = String(xml);
            % bais = ByteArrayInputStream(jXML.getBytes(StandardCharsets.UTF_8));
            % responseSysMeta = TypeMarshaller.unmarshalTypeFromStream( ...
            %     org.dataone.service.types.v2.SystemMetadata.class, bais);
            % responseSysMeta.getIdentifier().getValue()
        end
        
        function testFromJavaSysMetaV2(testCase)
            % TESTFROMJAVASYSMETAV2 tests converting a Java V2 system
            % metadata object to matlab V2 system metadata.
            
            import org.dataone.client.v2.itk.D1Client;
            import org.dataone.configuration.Settings;
            import org.dataone.service.types.v1.Session;
            import org.dataone.service.types.v1.Identifier;
            import org.dataone.service.types.v1.NodeReference;
            import org.dataone.client.v2.SystemMetadata;
            
            Settings.getConfiguration().setProperty('D1Client.CN_URL', ...
                'https://cn-dev-2.test.dataone.org/cn');
            mn = D1Client.getMN('https://mn-dev-ucsb-2.test.dataone.org/metacat/d1/mn');
            
            session = Session();
            pid = Identifier();
            pid.setValue('dv.test.006');
            j_sysmeta = mn.getSystemMetadata(session, pid);
            
            % Enhance the repl policy to test the conversion
            fast_node = NodeReference();
            fast_node.setValue('urn:node:FASTNODE');

            slow_node = NodeReference();
            slow_node.setValue('urn:node:SLOWNODE');

            friend_node = NodeReference();
            friend_node.setValue('urn:node:FRIENDNODE');

            foe_node = NodeReference();
            foe_node.setValue('urn:node:FOENODE');
            
            repl_policy = j_sysmeta.getReplicationPolicy();
            repl_policy.addPreferredMemberNode(fast_node);
            repl_policy.addBlockedMemberNode(slow_node);
            repl_policy.addPreferredMemberNode(friend_node);
            repl_policy.addBlockedMemberNode(foe_node);

            j_sysmeta.setReplicationPolicy(repl_policy);
            
            % Add a media type for testing
            import org.dataone.service.types.v2.MediaType;
            import org.dataone.service.types.v2.MediaTypeProperty;
            prop_1 = MediaTypeProperty();
            prop_1.setName('my-prop-1');
            prop_1.setValue('my-val-1');
            
            prop_2 = MediaTypeProperty();
            prop_2.setName('my-prop-2');
            prop_2.setValue('my-val-2');
            
            media_type = MediaType();
            media_type.setName('text/plain');
            media_type.addProperty(prop_1);
            media_type.addProperty(prop_2);
            j_sysmeta.setMediaType(media_type);
            
            sysmeta = SystemMetadata.fromJavaSysMetaV2(j_sysmeta);
            
            % TODO: Validate system metadata fields
        end
    end
    
end