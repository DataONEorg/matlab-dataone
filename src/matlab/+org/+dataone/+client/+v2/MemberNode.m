% MNode A class that represents a DataONE member node properties
%   The MNode class overloads any calls to the Java class of the same name
%   and provides implementations for all of the public API methods found in the 
%   Java MNode class, and wrap them with Matlab-based equivalents. This class records 
%   provenance statemetns for each method called. 
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

classdef MemberNode < org.dataone.client.v2.DataONENode
    
    properties
                
    end
    
    methods 
        
        function memberNode = MemberNode(mnode_id) % class constructor method
            % MEMBERNODE Constructs an MemberNode object instance with the given
            % member node identifier
            
            import org.dataone.client.v2.itk.D1Client;
            import org.dataone.service.types.v1.NodeReference;
            
            if ~isempty(mnode_id)
                
                import org.dataone.client.configure.Configuration;
                config = Configuration.loadConfig('');
                
                import org.dataone.configuration.Settings;
                Settings.getConfiguration().setProperty('D1Client.CN_URL', ...
                    config.coordinating_node_base_url);
                
                node_ref = NodeReference();
                node_ref.setValue(java.lang.String(mnode_id));
                          
                mnode = D1Client.getMN(node_ref);
                memberNode.node = mnode;
                
                memberNode.node_base_service_url = ...
                    char(memberNode.node.getNodeBaseServiceUrl());
                memberNode.node_type = 'mn';
                memberNode.node_id = mnode_id;
            end
        end
        
        function identifier = create(memberNode, session, ...
                 pid, object, sysmeta)
            % CREATE Creates an object with the given identifier at the given member node
            
            import org.dataone.client.run.RunManager;
            import org.dataone.service.types.v1.Identifier;
            import java.io.File;
            import java.io.ByteArrayInputStream;
            import org.apache.commons.io.FileUtils;
            
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug )
                disp('Called the java version mnode.create() wrapper function.');
            end
            
            % Do we have a session object?
            if ( ~ isa(session, 'org.dataone.client.v2.Session') )
                msg = ['The given ''session'' parameter must be an ' ...
                    'org.dataone.client.v2.Session object.' ...
                    char(10) ...
                    'Please create a session ' ...
                    'before calling the ''create()'' function.'];
                error(msg);
                
            end
            
            % Without a valid session, throw an error
            if (  ~ session.isValid() )
                
                msg = ['Your session expired on ' ...
                    char(session.expiration_date) '.' ...
                    char(10) ...
                    ' Please renew your ' ...
                    session.type ...
                    char(10) ...
                    ' before calling the ''create()'' function.'];
                error(msg);
                
            end
            
            % Without a valid byte array, throw an error
            if ( ~ isa(object, 'int8') )
                msg = ['The given ''object'' parameter must be a ' ...
                    'int8 byte array.' ...
                    char(10) ...
                    'Please convert your object to this data type ' ...
                    char(10) ...
                    'before calling the ''create()'' function.'];
                error(msg);
                
            end
            
            % Without a valid system metadata object, throw an error
            if ( ~ isa(sysmeta, 'org.dataone.client.v2.SystemMetadata') )
                msg = ['The given ''sysmeta'' parameter must be an ' ...
                    'org.dataone.client.v2.SystemMetadata object.' ...
                    char(10) ...
                    'Please convert your object to this data type ' ...
                    char(10) ...
                    'before calling the ''create()'' function.'];
                error(msg);
                
            end
            
            % get the Java session
            j_session = session.getJavaSession();
            
            % Create a Java Identifier
            j_pid = Identifier();
            j_pid.setValue(pid);
            
            % Get the Java system metadata
            j_sysmeta = sysmeta.toJavaSysMetaV2();
            
            % Build an input stream from the object bytes
            input_stream = ByteArrayInputStream(object);
            
            % Call the Java function with the same name to create the
            % DataONE object
            try
                j_identifier = ...
                    memberNode.node.create(j_session, j_pid, input_stream, j_sysmeta);
                identifier = char(j_identifier.getValue());
                
            catch baseException
                rethrow(baseException);
                
            end
          
            % Get filename from d1 object system metadata; otherwise,
            % a UUID string is used as the filename of the local copy of the d1 object
            d1FileName = sysmeta.fileName; % full_file_path
            if isempty(d1FileName)
                d1FileName = char(java.util.UUID.randomUUID());
            end
            
            [path, name, ext] = fileparts(char(d1FileName));
            obj_name = [name ext];
            d1FileFullPath = fullfile(...
                runManager.configuration.provenance_storage_directory, ...
                'runs', ...
                runManager.execution.execution_id, ...
                obj_name);
            targetFile = File(d1FileFullPath);
            input_stream = ByteArrayInputStream(object);
            FileUtils.copyInputStreamToFile(input_stream, targetFile);       
            
            % Identifiy the file being used and add a prov:wasGeneratedBy statement
            % in the RunManager DataPackage instance
            if ( runManager.configuration.capture_file_writes )
                % Record the full path to the local copy of the downloaded object
                % that will eventually be added to the resource map
                
                import org.dataone.client.v2.DataObject;
                
                formatId = sysmeta.formatId; % get the d1 object formatId from its system metadata
               
                existing_id = ...
                    runManager.execution.getIdByFullFilePath(d1FileName);
                
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map 
                    dataObject = DataObject(pid, formatId, d1FileName);
                    % Set the system metadata for the current dataObject
                    set(dataObject, 'system_metadata', sysmeta.toJavaSysMetaV2());
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                     runManager.execution.execution_output_ids{end + 1} = pid; 
                else
                    % Update the existing map entry with a new DataObject
                    pid = existing_id;
                    dataObject = DataObject(pid, formatId, d1FileName);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                end    
            end

        end
        
        function identifier = update(memberNode, session, pid, ...
                object, newPid, sysmeta)
            % UPDATE Updates an object with a new identifier at the given member node.
            
            import org.dataone.client.run.RunManager;
            import org.dataone.service.types.v1.Identifier;
            import org.dataone.service.types.v2.SystemMetadata;
            import org.apache.commons.io.IOUtils;
            import java.io.File;
            import java.io.ByteArrayInputStream;
            import org.apache.commons.io.FileUtils;
              
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug )
                disp('Called the java version mnode.update() wrapper function.');
            end
            
            % Do we have a session object?
            if ( ~ isa(session, 'org.dataone.client.v2.Session') )
                msg = ['The given ''session'' parameter must be an ' ...
                    'org.dataone.client.v2.Session object.' ...
                    char(10) ...
                    'Please create a session ' ...
                    'before calling the ''update()'' function.'];
                error(msg);
                
            end
            
            % Without a valid session, throw an error
            if (  ~ session.isValid() )
                
                msg = ['Your session expired on ' ...
                    char(session.expiration_date) '.' ...
                    char(10) ...
                    ' Please renew your ' ...
                    session.type ...
                    char(10) ...
                    ' before calling the ''update()'' function.'];
                error(msg);
                
            end
            
            % Without a valid byte array, throw an error
            if ( ~ isa(object, 'int8') )
                msg = ['The given ''object'' parameter must be a ' ...
                    'int8 byte array.' ...
                    char(10) ...
                    'Please convert your object to this data type ' ...
                    char(10) ...
                    'before calling the ''update()'' function.'];
                error(msg);
                
            end
            
            % Without a valid system metadata object, throw an error
            if ( ~ isa(sysmeta, 'org.dataone.client.v2.SystemMetadata') )
                msg = ['The given ''sysmeta'' parameter must be an ' ...
                    'org.dataone.client.v2.SystemMetadata object.' ...
                    char(10) ...
                    'Please convert your object to this data type ' ...
                    char(10) ...
                    'before calling the ''update()'' function.'];
                error(msg);
                
            end
            
            % get the Java session
            j_session = session.getJavaSession();
            
            % Create a Java Identifier
            j_pid = Identifier();
            j_pid.setValue(pid);

            % Create a new Java Identifier
            j_newPid = Identifier();
            j_newPid.setValue(newPid);
            
            % Get the Java system metadata
            j_sysmeta = sysmeta.toJavaSysMetaV2();
            
            % Build an input stream from the object bytes
            input_stream = ByteArrayInputStream(object);
            % Call the Java function with the same name to update a
            % DataONE object
            try
                j_identifier = memberNode.node.update(j_session, j_pid, input_stream, j_newPid, j_sysmeta);
                identifier = char(j_identifier.getValue());
                
            catch baseException
                rethrow(baseException);

            end
            
            % Get filename from d1 object system metadata; otherwise,
            % a UUID string is used as the filename of the local copy of the d1 object
            d1FileName = sysmeta.fileName; 
            if isempty(d1FileName)
                d1FileName = char(java.util.UUID.randomUUID());
            end
            
            % Create a local copy for the d1 object under the execution
            % directory
            [path, name, ext] = fileparts(char(d1FileName));
            obj_name = [name ext];
            d1FileFullPath = fullfile(...
                runManager.configuration.provenance_storage_directory, ...
                'runs', runManager.execution.execution_id, obj_name);
            targetFile = File(d1FileFullPath);
            input_stream = ByteArrayInputStream(object);
            FileUtils.copyInputStreamToFile(input_stream, targetFile);
       
            % Identifiy the file being used and add a prov:wasGeneratedBy statement
            % in the RunManager DataPackage instance
            if ( runManager.configuration.capture_file_writes )
                % Record the full path to the local copy of the downloaded object
                % that will eventually be added to the resource map
                
                import org.dataone.client.v2.DataObject;
                
                formatId = sysmeta.formatId; % get the d1 object formatId from its system metadata
               
                existing_id = runManager.execution.getIdByFullFilePath( ...
                    d1FileFullPath ); 
                
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map    
                    dataObject = DataObject(identifier, formatId, d1FileFullPath);
                    % Set the system metadata for the current dataObject
                    set(dataObject, 'system_metadata', sysmeta.toJavaSysMetaV2());
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                    runManager.execution.execution_output_ids{end + 1} = identifier;
                else
                    % Update the existing map entry with a new DataObject
                    dataObject = DataObject(identifier, formatId, d1FileFullPath);
                    % Set the system metadata for the current dataObject
                    set(dataObject, 'system_metadata', sysmeta.toJavaSysMetaV2());
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                    runManager.execution.execution_output_ids{end + 1} = identifier;
                end
            end 
   
        end

        function checksum = getChecksum(memberNode, session, ...
                pid, checksumAlgorithm)
            % GETCHECKSUM Returns the checksum of the object given the algorithm
            
            import org.dataone.service.types.v1.Checksum;
            import org.dataone.service.types.v1.Identifier;
            
            % Do we have a session?
            if ( ~ isa(session, 'org.dataone.client.v2.Session') )
                import org.dataone.client.v2.Session;
                session = Session();
                
            end
            
            checksum.value = '';
            checksum.algorithm = '';
                      
            j_pid = Identifier();
            j_pid.setValue(pid);
            
            j_session = session.getJavaSession();
                    
            j_checksum = ...
                memberNode.node.getChecksum(j_session, j_pid, checksumAlgorithm); % Make a Java call
            
            % Convert the Java Checksum object returned into the above
            % array
            checksum.value = char(j_checksum.getValue());
            checksum.algorithm = char(j_checksum.getAlgorithm());
            
        end
        
        function [objects, start, count, total] = ...
                listObjects(memberNode, session, fromDate, toDate, ...
                formatid, identifier, replicaStatus, start, count)
            % LISTOBJECTS Returns the list of objects from the node
            %   Filter the returned list with the fromDate, toDate, formatId,
            %   identifier, or replicaStatus parameters.  Use the start and
            %   count parameters to page through the results
            %   [objects, start, count, total] = listObjects() returns:
            %
            %   objects - the list of objects as a struct, with:
            %   objects.identifier
            %   objects.formatId
            %   objects.checksum.value
            %   objects.checksum.algorithm
            %   objects.dateSysMetadataModified
            %   objects.size
            %
            %   start - the starting index requested (start at nth object)
            %   count - the number of returned objects requested
            %   total - the total number of objects on the Node
            %
            %   See https://purl.dataone.org/architecturev2/apis/Types.html#Types.ObjectList
            
            import java.util.Date;
            import org.dataone.service.types.v1.ObjectFormatIdentifier;
            import org.dataone.service.types.v1.Identifier;
            import java.lang.Integer;
            
            objects(1).identifier = '';
            objects(1).formatId = '';
            objects(1).checksum.value = '';
            objects(1).checksum.algorithm = '';
            objects(1).dateSysMetadataModified = '';
            objects(1).size = NaN;
            
            % Do we have a session?
            if ( isempty(session) )
                session = Session();
            end
            
            j_session = session.getJavaSession();
            
            import java.text.SimpleDateFormat;
            import java.util.TimeZone;
            import java.util.Date;
            
            j_fromDate = [];
            if ( ~isempty(fromDate) )
                if ( ischar(fromDate) )
                    try
                        % Handle yyyy-MM-dd''T''HH:mm:ss.SSSZ
                        formatter = ...
                            SimpleDateFormat( ...
                                'yyyy-MM-dd''T''HH:mm:ss.SSSZ');
                        tz = TimeZone.getTimeZone('UTC');
                        formatter.setTimeZone(tz);
                        j_fromDate = formatter.parse(fromDate);
                        
                    catch exception
                        try
                            % Handle yyyy-MM-dd''T''HH:mm:ss.SSS
                            formatter = ...
                                SimpleDateFormat( ...
                                'yyyy-MM-dd''T''HH:mm:ss.SSS');
                            tz = TimeZone.getTimeZone('UTC');
                            formatter.setTimeZone(tz);
                            j_fromDate = formatter.parse(fromDate);
                        catch exception2
                            try
                                % Handle yyyy-MM-dd''T''HH:mm:ss
                                formatter = ...
                                    SimpleDateFormat( ...
                                    'yyyy-MM-dd''T''HH:mm:ss');
                                tz = TimeZone.getTimeZone('UTC');
                                formatter.setTimeZone(tz);
                                j_fromDate = formatter.parse(fromDate);
                                
                            catch exception3
                                % Couldn't parse the string. Throw an error
                                msg = ['The date string ' fromDate ...
                                char(10) ...
                                'Couldn''t be parsed. Please provide ' ...
                                'the ''fromDate'' parameter ' ...
                                char(10) ...
                                'in one of the following string formats: ' ...
                                char(10) ...
                                'yyyy-MM-dd''T''HH:mm:ss.SSSZ' ...
                                char(10) ...
                                'yyyy-MM-dd''T''HH:mm:ss.SSS' ...
                                char(10) ...
                                'yyyy-MM-dd''T''HH:mm:ss' ...
                                char(10) ... 
                                'For instance: ' ...
                                char(10) ...
                                '2016-01-01T01:01:01.001+0000' ...
                                char(10) ...
                                '2016-01-01T01:01:01.001' ...
                                char(10) ...
                                '2016-01-01T01:01:01' ...
                                ];
                                error(msg);
                            end
                        end
                    end
                end
            end
            
            j_toDate = [];
            if (~isempty(toDate))
                if ( ischar(toDate) )
                    try
                        % Handle yyyy-MM-dd''T''HH:mm:ss.SSSZ
                        formatter = ...
                            SimpleDateFormat( ...
                                'yyyy-MM-dd''T''HH:mm:ss.SSSZ');
                        tz = TimeZone.getTimeZone('UTC');
                        formatter.setTimeZone(tz);
                        j_toDate = formatter.parse(toDate);
                        
                    catch exception
                        try
                            % Handle yyyy-MM-dd''T''HH:mm:ss.SSS
                            formatter = ...
                                SimpleDateFormat( ...
                                'yyyy-MM-dd''T''HH:mm:ss.SSS');
                            tz = TimeZone.getTimeZone('UTC');
                            formatter.setTimeZone(tz);
                            j_toDate = formatter.parse(toDate);
                        catch exception2
                            try
                                % Handle yyyy-MM-dd''T''HH:mm:ss
                                formatter = ...
                                    SimpleDateFormat( ...
                                    'yyyy-MM-dd''T''HH:mm:ss');
                                tz = TimeZone.getTimeZone('UTC');
                                formatter.setTimeZone(tz);
                                j_toDate = formatter.parse(toDate);
                                
                            catch exception3
                                % Couldn't parse the string. Throw an error
                                msg = ['The date string ' toDate ...
                                char(10) ...
                                'Couldn''t be parsed. Please provide ' ...
                                'the ''toDate'' parameter ' ...
                                char(10) ...
                                'in one of the following string formats: ' ...
                                char(10) ...
                                'yyyy-MM-dd''T''HH:mm:ss.SSSZ' ...
                                char(10) ...
                                'yyyy-MM-dd''T''HH:mm:ss.SSS' ...
                                char(10) ...
                                'yyyy-MM-dd''T''HH:mm:ss' ...
                                char(10) ... 
                                'For instance: ' ...
                                char(10) ...
                                '2016-01-01T01:01:01.001+0000' ...
                                char(10) ...
                                '2016-01-01T01:01:01.001' ...
                                char(10) ...
                                '2016-01-01T01:01:01' ...
                                ];
                                error(msg);
                                
                            end
                        end
                    end
                end
            end
            
            j_formatid = [];
            if ( ~ isempty(formatid) )
                j_formatid = ObjectFormatIdentifier();
                j_formatid.setValue(formatid);
                
            end
         
            j_identifier = Identifier();
            j_identifier.setValue(identifier);
            
            j_replicaStatus = [];
            if ( ~ isempty(replicaStatus) )
                if ( islogical(replicaStatus) )
                    j_replicaStatus = java.lang.Boolean(replicaStatus);
                    
                else
                    msg = ['The replicaStatus parameter' char(replicaStatus) ...
                    'couldn''t be parsed.' ...
                    char(10) ...
                    'Please provide it as a true or false logical value.'];
                    error(msg);
                    
                end
            end
            
            j_start = [];
            if ( ~isempty(start) )
                j_start = Integer(start);
                
            end
            
            j_count = [];
            if( ~isempty(count) )
                j_count = Integer(count);
                
            end
            
            objectList = ...
                memberNode.node.listObjects( ...
                    j_session, j_fromDate, j_toDate, ...
                    j_formatid, j_identifier, replicaStatus, j_start, j_count);
            
            % Convert the Java ObjectList into the above structured array
            objectInfoList = objectList.getObjectInfoList();
            for i = 1:size(objectInfoList)
               anObj = objectInfoList.get(i - 1);
               objects(i).identifier = char(anObj.getIdentifier().getValue());
               objects(i).formatId = char(anObj.getFormatId().getValue());
               objects(i).checksum.value = char(anObj.getChecksum().getValue());
               objects(i).checksum.algorithm = char(anObj.getChecksum().getAlgorithm());
               objects(i).dateSysMetadataModified = char(anObj.getDateSysMetadataModified().toString());
               objects(i).size = char(anObj.getSize().toString());
            end
    
            % Get the 'start' value
            start = objectList.getStart();
            
            % Get the 'count' attribute value. The number of entries in the slice.
            count = objectList.getCount(); 
            
            % Get the 'total' attribute value
            total = objectList.getTotal();
        end
        
        % function failed = synchronizationFailed(session, message)
        %
        %   TODO: Won't implement, not a client API method
        %
        % end

        % function object = getReplica(session, pid)
        %
        %   TODO: Won't implement, not a client API method
        %
        % end

        function updated = updateSystemMetadata(self, session, pid, sysmeta)
            % UPDATESYSTEMMETADATA updates the object's system metadata
            %   Given the object identified by the pid, update the object's
            %   system metadata stored on the Member Node.
            
            import org.dataone.service.types.v1.Identifier;
            import org.dataone.client.configure.Configuration;
            import org.dataone.client.v2.Session;
            
            updated = false;
            
            if ( isempty(session) )
                session = Session();
                
            end
            j_session = session.getJavaSession();
            
            identifier = Identifier();
            identifier.setValue(pid);
            
            j_sysmeta = sysmeta.toJavaSysMetaV2();
            
            % Convert the Java boolean response to a logical true/false
            try
                j_updated = self.node.updateSystemMetadata( ...
                    j_session, ...
                    identifier, j_sysmeta);
                updated = j_updated.booleanValue();
                
            catch exception
                disp('There was a problem updating the system metadata: ');
                rethrow(exception);
                
            end
        end
        
        % function identifier = delete(session, id)
        % DELETE removes the object from the Member Node
        %
        %   TODO: Won't implement, not a client API method (use archive)
        %
        % end
        
        function identifier = archive(memberNode, session, id)
            % ARCHIVE Renders the object undiscoverable but available given the id
            %   An archived object is not deleted from the Member Node, but
            %   is rather 'hidden' from searches. It remains available through
            %   get() for archival purposes (for instance, when cited in a
            %   journal article), but only with the object id itself
            %
            %   See https://purl.dataone.org/architecturev2/apis/MN_APIs.html#MNStorage.archive
            
            import org.dataone.service.types.v1.Identifier;
            
            identifier = '';
            
            obj_pid = Identifier();
            obj_pid.setValue(id);
                      
            returned_identifier = memberNode.node.archive(session, obj_pid); % Make a Java call
            
            % Convert the Java returned identifier to a string
            identifier = char(returned_identifier.getValue());
        end
        
        function identifier = generateIdentifier(memberNode, session, scheme, fragment)
            % GENERATEIDENTIFIER Generates a unique identifier given the scheme and fragment
            %
            %   See MN_APIs.html#MNStorage.generateIdentifier
            
            identifier = '';
            
            returned_identifier = memberNode.node.generateIdentifier(session, scheme, fragment); % Make a Java call
            
            % Convert the returned Java identifier to a string
            identifier = char(returned_identifier.getValue());
        end

        % function replicated = replicate(session, sysmeta, sourceNode)
        % 
        %   TODO: Won't implement, not a client API method (is a CN admin function)
        %
        % end

    end
end
