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
    
    methods % class methods (function and operator definitions)    
        
        function memberNode = MemberNode(mnode_id) % class constructor method
            % MNODE Constructs an MNode object instance with the given
            % member node base url
            
            import org.dataone.client.v2.itk.D1Client;
            import org.dataone.client.v2.impl.MultipartMNode;
            import org.dataone.service.types.v1.NodeReference;
            
            if ~isempty(mnode_id)
                
                import org.dataone.client.configure.Configuration;
                config = Configuration.loadConfig('');
                
                import org.dataone.configuration.Settings;
                Settings.getConfiguration().setProperty('D1Client.CN_URL', ...
                    config.coordinating_node_base_url);
                
                node_ref = NodeReference();
                node_ref.setValue(mnode_id);
                          
                memberNode.node = D1Client.getMN(node_ref);
                
                memberNode.node_base_service_url = char(memberNode.node.getNodeBaseServiceUrl());
                memberNode.node_type = 'mn';
                memberNode.node_id = mnode_id;
            end
        end
        
        function getMN(memberNode, mnBaseUrl)
            % GETMN Returns a Member Node using the base service URL for the node 
        end
  
        function targetStream  = get(memberNode, session, pid)
            % GET Get a D1Objet instance with the givien identifier from
            % the given member node
            
            import org.dataone.client.v2.impl.MultipartMNode;
            import org.dataone.client.run.RunManager;
            import org.dataone.service.types.v2.SystemMetadata;
            import org.apache.commons.io.IOUtils;
            import java.io.File;
            import java.io.FileInputStream;
            import org.apache.commons.io.FileUtils;
            
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug )
                disp('Called the java version mnode.get() wrapper function.');
            end

            % Call the Java function with the same name to retrieve the
            % DataONE object and get system metadata for this d1 object.
            % The formatId information is obtained from the system metadata
            inputStream = memberNode.node.get(session, pid);  
            
            sysMetaData = memberNode.node.getSystemMetadata(session, pid);
            formatId = sysMetaData.getFormatId().getValue;
            
            % Get filename from d1 object system metadata; otherwise, 
            % a UUID string is used as the filename of the local copy of the d1 object
            d1FileName = sysMetaData.getFileName;
            if isempty(d1FileName)
                d1FileName = char(java.util.UUID.randomUUID());
            end
            
            % Create a local copy for the d1 object under the execution
            % directory
            [path, name, ext] = fileparts(char(d1FileName));
            obj_name = [name ext];
            d1FileFullPath = fullfile(runManager.configuration.provenance_storage_directory, 'runs', runManager.execution.execution_id, obj_name);
            targetFile = File(d1FileFullPath);
            FileUtils.copyInputStreamToFile(inputStream, targetFile);          
            targetStream = FileInputStream(targetFile); % Return an inputStream as results
       
            % Identifiy the DataObject being used and add a prov:used statement
            % in the RunManager DataPackage instance            
            if ( runManager.configuration.capture_file_reads )
                % Record the full path to the local copy of the downloaded object
                % that will eventually be added to the resource map
                
                import org.dataone.client.v2.DataObject;
  
                existing_id = runManager.execution.getIdByFullFilePath( ...
                     d1FileFullPath );
                                
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map
                    dataObject = DataObject(char(pid.getValue()), formatId, d1FileFullPath);
                    % Set the system metadata downloaded from the given
                    % mnode for the current dataObject
                    set(dataObject, 'system_metadata', sysMetaData);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                     runManager.execution.execution_input_ids{end+1} = char(pid.getValue());
                else
                    % Update the existing map entry with a new DataObject
                    pid = existing_id;
                    dataObject = DataObject(pid, formatId, d1FileFullPath);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                end               
            end
            
        end
        
        function identifier = create(memberNode, session, pid_obj, objectInputStream, sysmeta)
            % CREATE Creates a D1Objet instance with the given identifier
            % at the given member node
            
            import org.dataone.client.v2.impl.MultipartMNode;
            import org.dataone.client.run.RunManager;
            import org.dataone.service.types.v2.SystemMetadata;
            import org.apache.commons.io.IOUtils;
            import java.io.File;
            import org.apache.commons.io.FileUtils;
            
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug )
                disp('Called the java version mnode.create() wrapper function.');
            end
            
            % Call the Java function with the same name to create the
            % DataONE object 
            identifier = memberNode.node.create(session, pid_obj, objectInputStream, sysmeta);
          
            % Get filename from d1 object system metadata; otherwise,
            % a UUID string is used as the filename of the local copy of the d1 object
            d1FileName = char(sysmeta.getFileName); % full_file_path
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
            FileUtils.copyInputStreamToFile(objectInputStream, targetFile);       
            
            % Identifiy the file being used and add a prov:wasGeneratedBy statement
            % in the RunManager DataPackage instance
            if ( runManager.configuration.capture_file_writes )
                % Record the full path to the local copy of the downloaded object
                % that will eventually be added to the resource map
                
                import org.dataone.client.v2.DataObject;
                
                formatId = sysmeta.getFormatId().getValue; % get the d1 object formatId from its system metadata
               
                existing_id = runManager.execution.getIdByFullFilePath( ...
                    d1FileName);
                
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map 
                    pid = char(pid_obj.getValue());
                    dataObject = DataObject(pid, formatId, d1FileName);
                    % Set the system metadata for the current dataObject
                    set(dataObject, 'system_metadata', sysmeta);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                     runManager.execution.execution_output_ids{end+1} = pid; 
                else
                    % Update the existing map entry with a new DataObject
                    pid = existing_id;
                    dataObject = DataObject(pid, formatId, d1FileName);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                end    
            end

        end
        
        function identifier = update(memberNode, session, pid, objectInputStream, newPid, sysmeta)
            % UPDATE Updates a D1Objet instance with a new identifier
            % at the given member node. The last three parameters have new
            % information
            
            import org.dataone.client.v2.impl.MultipartMNode;
            import org.dataone.client.run.RunManager;
            import org.dataone.service.types.v2.SystemMetadata;
            import org.apache.commons.io.IOUtils;
            import java.io.File;
            import org.apache.commons.io.FileUtils;
              
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug )
                disp('Called the java version mnode.update() wrapper function.');
            end
            
            % Call the Java function with the same name to update a
            % DataONE object 
            identifier = memberNode.node.update(session, pid, objectInputStream, newPid, sysmeta);
          
            % Get filename from d1 object system metadata; otherwise,
            % a UUID string is used as the filename of the local copy of the d1 object
            d1FileName = sysmeta.getFileName; % ? ? ?
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
            FileUtils.copyInputStreamToFile(objectInputStream, targetFile);
       
            % Identifiy the file being used and add a prov:wasGeneratedBy statement
            % in the RunManager DataPackage instance
            if ( runManager.configuration.capture_file_writes )
                % Record the full path to the local copy of the downloaded object
                % that will eventually be added to the resource map
                
                import org.dataone.client.v2.DataObject;
                
                formatId = sysmeta.getFormatId().getValue; % get the d1 object formatId from its system metadata
               
                existing_id = runManager.execution.getIdByFullFilePath( ...
                    d1FileFullPath ); 
                
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map    
                    new_pid = char(newPid.getValue());
                    dataObject = DataObject(new_pid, formatId, d1FileFullPath);
                    % Set the system metadata for the current dataObject
                    set(dataObject, 'system_metadata', sysmeta);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                    runManager.execution.execution_output_ids{end+1} = new_pid;
                else
                    % Update the existing map entry with a new DataObject
                    new_pid = char(newPid.getValue());
                    dataObject = DataObject(new_pid, formatId, d1FileFullPath);
                    % Set the system metadata for the current dataObject
                    set(dataObject, 'system_metadata', sysmeta);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                    runManager.execution.execution_output_ids{end+1} = new_pid;
                end
            end 
   
        end

        
        function [checksum, checksumAlgorithm] = getChecksum(memberNode, session, ...
                pid, checksumAlgorithm)
            % GETCHECKSUM Returns the checksum of the object given the algorithm
            
            import org.dataone.service.types.v1.Checksum;
            import org.dataone.service.types.v1.Identifier;
            
            checksum = '';
            checksumAlgorithm = '';
                      
            obj_pid = Identifier();
            obj_pid.setValue(pid);
                    
            objCheckSum = memberNode.node.getChecksum(session, obj_pid, checksumAlgorithm); % Make a Java call
            
            % Convert the Java Checksum object returned into the above
            % array
            checksum = char(objCheckSum.getValue());
            checksumAlgorithm = char(objCheckSum.getAlgorithm());
        end
        
        
        function [objects, start, count, total] = listObjects(memberNode, session, fromDate, toDate, ...
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
            %   objects.checksum
            %   objects.checksumAlgorithm
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
            objects(1).checksum = '';
            objects(1).checksumAlgorithm = '';
            objects(1).dateSysMetadataModified = '';
            objects(1).size = NaN;
            
            % Todo: do the pattern matching for date string         
            % Eg: '2015-12-31T02:00:00.000';
            
            if (~isempty(fromDate))
                fromDateObj = Date(fromDate);
            else
                fromDateObj = [];
            end
            
            if (~isempty(toDate))
                toDateObj = Date(toDate);
            else
                toDateObj = []; 
            end
            
            formatidObj = ObjectFormatIdentifier();
            formatidObj.setValue(formatid);
         
            identifierObj = Identifier();
            identifierObj.setValue(identifier);
            
            if (~isempty(start))
                startObj = Integer(start);
            else
                startObj = [];
            end
            
            if(~isempty(count))
                countObj = Integer(count);
            else
                countObj = [];
            end
            
            objectList = memberNode.node.listObjects(session, fromDateObj, toDateObj, ...
                formatidObj, identifierObj, replicaStatus, startObj, countObj); % Make a Java call
            
            % Covert the Java ObjectList into the above structured array
            objectInfoList = objectList.getObjectInfoList();
            for i = 1:size(objectInfoList)
               anObj = objectInfoList.get(i-1);
               objects(i).identifier = char(anObj.getIdentifier().getValue());
               objects(i).formatId = char(anObj.getFormatId().getValue());
               objects(i).checksum = char(anObj.getChecksum().getValue());
               objects(i).checksumAlgorithm = char(anObj.getChecksum().getAlgorithm());
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
        %   TODO: Won't implement
        %
        % end

        % function object = getReplica(session, pid)
        %
        %   TODO: Won't implement
        %
        % end

        function updated = updateSystemMetadata(session, pid, sysmeta)
            % UPDATESYSTEMMETADATA updates the object's system metadata
            %   Given the object identified by the pid, update the object's
            %   system metadata stored on the Member Node.
            
            updated = false;
            
            % Convert the Java boolean response to a logical true/false
            
        end
        
        % function identifier = delete(session, id)
        % DELETE removes the object from the Member Node
        %
        % TODO: Won't implement administrative method? (use archive)
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
        % TODO: Won't implement (is a CN admin function)
        %
        % end

    end
end
