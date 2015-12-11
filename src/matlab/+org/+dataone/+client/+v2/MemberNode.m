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

classdef MemberNode < hgsetget
    
    properties
        % A base url for a member node
        mn_base_url = '';
        
        % A Java object representing a member node
        mnode;
    end
    
    
    methods % class methods (function and operator definitions)    
        
        function memberNode = MemberNode(mnBaseUrl) % class constructor method
            % MNODE Constructs an MNode object instance with the given
            % member node base url
            import org.dataone.client.v2.itk.D1Client;
            
            if ~isempty(mnBaseUrl)
                memberNode.mn_base_url = mnBaseUrl;
                memberNode.mnode = D1Client.getMN(mnBaseUrl);
            end
        end
        
        
        function getMN(memberNode, mnBaseUrl)
            % GETMN Returns a Member Node using the base service URL for the node 
        end
        
        
        function inputStream = get(memberNode, session, pid)
            % GET Get a D1Objet instance with the givien identifier from
            % the given member node
            
            import org.dataone.client.v2.impl.MultipartMNode;
            import org.dataone.client.run.RunManager;
            import org.dataone.service.types.v2.SystemMetadata;
            import org.apache.commons.io.IOUtils;
            import java.nio.charset.StandardCharsets;
            
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug )
                disp('Called the java version mnode.get() wrapper function.');
            end

            % Call the Java function with the same name to retrieve the
            % DataONE object and get system metadata for this d1 object.
            % The formatId information is obtained from the system metadata
            inputStream = memberNode.mnode.get(session, pid);  
            sysMetaData = memberNode.mnode.getSystemMetadata(session, pid);
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
            fw = fopen(d1FileFullPath, 'w');
            if fw == -1, error('Cannot write "%s%".',d1FileFullPath); end
            d1ObjString = IOUtils.toString(inputStream, StandardCharsets.UTF_8.name()); % Question: correct convert inputStream to String?
            fprintf(fw, '%s', char(d1ObjString));
            fclose(fw);
            
            %system(['open ' d1FileFullPath]); % for test
            
            % Identifiy the D1Object being used and add a prov:used statement
            % in the RunManager DataPackage instance            
            if ( runManager.configuration.capture_file_reads )
                % Record the full path to the local copy of the downloaded object
                % that will eventually be added to the resource map
                
                import org.dataone.client.v2.D1Object;
  
                existing_id = runManager.execution.getIdByFullFilePath( ...
                     d1FileFullPath );
                                
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map
                    d1Object = D1Object(char(pid.getValue()), formatId, d1FileFullPath);
                    % Set the system metadata downloaded from the given
                    % mnode for the current d1Object
                    set(d1Object, 'system_metadata', sysMetaData);
                    runManager.execution.execution_objects(d1Object.identifier) = ...
                        d1Object;
                     runManager.execution.execution_input_ids{end+1} = pid;
                else
                    % Update the existing map entry with a new D1Object
                    pid = existing_id;
                    d1Object = D1Object(pid, formatId, d1FileFullPath);
                    runManager.execution.execution_objects(d1Object.identifier) = ...
                        d1Object;
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
            
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug )
                disp('Called the java version mnode.create() wrapper function.');
            end
            
            % Call the Java function with the same name to create the
            % DataONE object 
            identifier = memberNode.mnode.create(session, pid_obj, objectInputStream, sysmeta);
          
            % Get filename from d1 object system metadata; otherwise,
            % a UUID string is used as the filename of the local copy of the d1 object
            d1FileName = char(sysmeta.getFileName); % full_file_path
            if isempty(d1FileName)
                d1FileName = char(java.util.UUID.randomUUID());
            end
                                 
            % Identifiy the file being used and add a prov:wasGeneratedBy statement
            % in the RunManager DataPackage instance
            if ( runManager.configuration.capture_file_writes )
                % Record the full path to the local copy of the downloaded object
                % that will eventually be added to the resource map
                
                import org.dataone.client.v2.D1Object;
                
                formatId = sysmeta.getFormatId().getValue; % get the d1 object formatId from its system metadata
               
                existing_id = runManager.execution.getIdByFullFilePath( ...
                    d1FileName);
                
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map 
                    pid = char(pid_obj.getValue());
                    d1Object = D1Object(pid, formatId, d1FileName);
                    % Set the system metadata for the current d1Object
                    set(d1Object, 'system_metadata', sysmeta);
                    runManager.execution.execution_objects(d1Object.identifier) = ...
                        d1Object;
                     runManager.execution.execution_output_ids{end+1} = pid; 
                else
                    % Update the existing map entry with a new D1Object
                    pid = existing_id;
                    d1Object = D1Object(pid, formatId, d1FileName);
                    runManager.execution.execution_objects(d1Object.identifier) = ...
                        d1Object;
                end               
            end
            
            % Todo: create a local copy for the d1 object under the execution
            % directory
        end
        
        
        function identifier = update(memberNode, session, pid, objectInputStream, newPid, sysmeta)
            % UPDATE Updates a D1Objet instance with a new identifier
            % at the given member node. The last three parameters have new
            % information
                 
            import org.dataone.client.v2.impl.MultipartMNode;
            import org.dataone.client.run.RunManager;
            import org.dataone.service.types.v2.SystemMetadata;
            import org.apache.commons.io.IOUtils;
            
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug )
                disp('Called the java version mnode.update() wrapper function.');
            end
            
            % Call the Java function with the same name to update a
            % DataONE object 
            identifier = memberNode.mnode.update(session, pid, objectInputStream, newPid, sysmeta);
          
            % Get filename from d1 object system metadata; otherwise,
            % a UUID string is used as the filename of the local copy of the d1 object
            d1FileName = sysmeta.getFileName;
            if isempty(d1FileName)
                d1FileName = char(java.util.UUID.randomUUID());
            end
            
            % Create a local copy for the d1 object under the execution
            % directory
            d1FileFullPath = fullfile( ...
                runManager.configuration.provenance_storage_directory, ...
                'runs', ...
                runManager.execution.execution_id, ...
                d1FileName);
            fw = fopen(d1FileFullPath, 'w');
            if fw == -1, error('Cannot write "%s%".',d1FileFullPath); end
            d1ObjString = IOUtils.toString(objectInputStream, StandardCharsets.UTF_8.name());
            fprintf(fw, '%s', d1ObjString);
            fclose(fw);           
            
            % Identifiy the file being used and add a prov:wasGeneratedBy statement
            % in the RunManager DataPackage instance
            if ( runManager.configuration.capture_file_writes )
                % Record the DataONE resolve service endpoint + pid for the object of the RDF triple
                % Decode the URL that will eventually be added to the
                % resource map
                
                import org.dataone.client.v2.D1Object;
                
                formatId = sysmeta.getFormatId().getValue; % get the d1 object formatId from its system metadata
               
                existing_id = runManager.execution.getIdByFullFilePath( ...
                    d1FileFullPath );
                
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map                  
                    d1Object = D1Object(newPid, formatId, d1FileFullPath);
                    % Set the system metadata for the current d1Object
                    set(d1Object, 'system_metadata', sysmeta);
                    runManager.execution.execution_objects(d1Object.identifier) = ...
                        d1Object;
                else
                    % Update the existing map entry with a new D1Object
                    pid = existing_id;
                    d1Object = D1Object(newPid, formatId, d1FileFullPath);
                    % Set the system metadata for the current d1Object
                    set(d1Object, 'system_metadata', sysmeta);
                    runManager.execution.execution_objects(d1Object.identifier) = ...
                        d1Object; 
                    % Remove the d1 object with the old "pid" identifier from the exeuciton_objects map 
                    oldKeySet = {pid};
                    remove(runManager.execution.execution_objects, oldKeySet);
                end
                
                % Replace the old "pid" with "newPid" in execution_output_ids array
                for i=1:length(runManager.execution.execution_output_ids)
                    value = runManager.execution.execution_output_ids{i};
                    if strcmp(pid, value)
                        runManager.execution.execution_output_ids{i} = newPid;
                        break;
                    end                    
                end
            end          
        end
        
    end   
end
