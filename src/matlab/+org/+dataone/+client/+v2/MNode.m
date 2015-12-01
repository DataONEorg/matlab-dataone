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

classdef MNode < hgsetget
    properties
        
    end
    
    methods (Static)
        function mnode = getMN(mnBaseUrl)
            import org.dataone.client.v2.itk.D1Client;
            
            mnode = D1Client.getMN(mnBaseUrl);
        end
    end
    
    methods      
        
        function inputStream = get(mnode, pid)
            % GET Get a D1Objet instance with the givien identifier from
            % the given member node
            
            import org.dataone.client.v2.impl;
            import org.dataone.client.run.RunManager;
            import org.dataone.service.types.v2.SystemMetadata;
                      
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug)
                disp('Called the java version mnode.get() wrapper function.');
            end

            % Call the Java function with the same name to retrieve the
            % DataONE object and get system metadata for this d1 object.
            % The formatId information is obtained from the system metadata
            inputStream = mnode.get(pid);  
            sysMetaData = mnode.getSystemMetadata(null, pid);
            formatId = sysMetaData.getFormatId().getValue;
         
            % Identifiy the D1Object being used and add a prov:used statement
            % in the RunManager DataPackage instance            
            if ( runManager.configuration.capture_file_reads )
                % Record the DataONE resolve service endpoint + pid for the object of the RDF triple
                % Decode the URL that will eventually be added to the
                % resource map
                
                % Get the base URL of the DataONE coordinating node server
                D1_Resolve_pid = ...
                    [char(runManager.configuration.coordinating_node_base_url) '/' pid];
   
                import org.dataone.client.v2.D1Object;
  
                existing_id = runManager.execution.getIdByFullFilePath( ...
                     D1_Resolve_pid );
                                
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map
                    d1Object = D1Object(pid, formatId, D1_Resolve_pid);
                    % Set the system metadata downloaded from the given
                    % mnode for the current d1Object
                    set(d1Object, 'system_metadata', sysMetaData);
                    runManager.execution.execution_objects(d1Object.identifier) = ...
                        d1Object;
                else
                    % Update the existing map entry with a new D1Object
                    pid = existing_id;
                    d1Object = D1Object(pid, formatId, D1_Resolve_pid);
                    runManager.execution.execution_objects(d1Object.identifier) = ...
                        d1Object;
                end
                
                runManager.execution.execution_input_ids{end+1} = pid;
            end
            
        end
        
        
        %function inputStream = get(mnode, session, pid)          
        %end
                
        function identifier = create(mnode, session, pid, objectInputStream, sysmeta)
            % CREATE Creates a D1Objet instance with the given identifier
            % at the given member node
            
            import org.dataone.client.v2.impl;
            import org.dataone.client.run.RunManager;
            import org.dataone.service.types.v2.SystemMetadata;
            
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug )
                disp('Called the java version mnode.create() wrapper function.');
            end
            
            % Call the Java function with the same name to create the
            % DataONE object 
            identifier = mnode.create(session, pid, objectInputStream, sysmeta);
          
            % Identifiy the file being used and add a prov:wasGeneratedBy statement
            % in the RunManager DataPackage instance
            if ( runManager.configuration.capture_file_writes )
                % Record the DataONE resolve service endpoint + pid for the object of the RDF triple
                % Decode the URL that will eventually be added to the
                % resource map
                
                % Get the base URL of the DataONE coordinating node server
                D1_Resolve_pid = ...
                    [char(runManager.configuration.coordinating_node_base_url) '/' pid];
                
                import org.dataone.client.v2.D1Object;
                
                formatId = sysmeta.getFormatId().getValue; % get the d1 object formatId from its system metadata
               
                existing_id = runManager.execution.getIdByFullFilePath( ...
                    D1_Resolve_pid );
                
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map                  
                    d1Object = D1Object(pid, formatId, D1_Resolve_pid);
                    % Set the system metadata for the current d1Object
                    set(d1Object, 'system_metadata', sysmeta);
                    runManager.execution.execution_objects(d1Object.identifier) = ...
                        d1Object;
                else
                    % Update the existing map entry with a new D1Object
                    pid = existing_id;
                    d1Object = D1Object(pid, formatId, D1_Resolve_pid);
                    runManager.execution.execution_objects(d1Object.identifier) = ...
                        d1Object;
                end
                
                runManager.execution.execution_output_ids{end+1} = pid; 
            end
        end
        
        
        function identifier = update(mnode, session, pid, objectInputStream, newPid, sysmeta)
            % UPDATE Updates a D1Objet instance with a new identifier
            % at the given member node
            % Assume: only pid is changed. Need verify with Chris
            
            import org.dataone.client.v2.impl;
            import org.dataone.client.run.RunManager;
            import org.dataone.service.types.v2.SystemMetadata;
            
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug )
                disp('Called the java version mnode.update() wrapper function.');
            end
            
            % Call the Java function with the same name to update a
            % DataONE object 
            identifier = mnode.update(session, pid, objectInputStream, newPid, sysmeta);
          
            % Identifiy the file being used and add a prov:wasGeneratedBy statement
            % in the RunManager DataPackage instance
            if ( runManager.configuration.capture_file_writes )
                % Record the DataONE resolve service endpoint + pid for the object of the RDF triple
                % Decode the URL that will eventually be added to the
                % resource map
                
                % Get the base URL of the DataONE coordinating node server
                old_D1_Resolve_pid = ...
                    [char(runManager.configuration.coordinating_node_base_url) '/' pid];
                D1_Resolve_pid = ...
                    [char(runManager.configuration.coordinating_node_base_url) '/' newPid];
                
                import org.dataone.client.v2.D1Object;
                
                formatId = sysmeta.getFormatId().getValue; % get the d1 object formatId from its system metadata
               
                existing_id = runManager.execution.getIdByFullFilePath( ...
                    old_D1_Resolve_pid );
                
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map                  
                    d1Object = D1Object(newPid, formatId, D1_Resolve_pid);
                    % Set the system metadata for the current d1Object
                    set(d1Object, 'system_metadata', sysmeta);
                    runManager.execution.execution_objects(d1Object.identifier) = ...
                        d1Object;
                else
                    % Update the existing map entry with a new D1Object
                    pid = existing_id;
                    d1Object = D1Object(newPid, formatId, D1_Resolve_pid);
                    runManager.execution.execution_objects(d1Object.identifier) = ...
                        d1Object;
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
