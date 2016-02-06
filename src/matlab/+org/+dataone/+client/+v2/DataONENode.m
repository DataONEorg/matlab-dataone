% DATAONENODE A class that represents a DataONE Node
%   This is a superclass to the MemberNode and CoordinatingNode classes,
%   providing shared DataONE API functions.
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2009-2016 DataONE

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

classdef DataONENode < hgsetget
    
    properties
        
        % The DataONE base url with version, used to construct REST endpoints for the node
        node_base_service_url;

        % The DataONE identifier for the node 
        node_id;
        
        % The DataONE node type (either 'cn' or 'mn')
        node_type;
        
        % The underlying java Node instance
        node;
    end
    
    properties (Access = 'private')
                
    end
    
    methods
        
        function date = ping(self)
        % PING Determines if the DataONE Node is reachable
        %   The ping() function sends an HTTP request to the Node.
        %   A successful respone will return a date timestamp as a string.
        %   A failure returns an empty string    
            date = '';
            
            date_obj = self.node.ping(); % make a Java call
            
            % Convert Java Date type to matlab char type
            date = char(date_obj.toString());
        end
        
        function log = getLogRecords(session, fromDate, toDate, ...
            event, pidFilter, start, count) 
        % GETLOGRECORDS Retrieves log records from the Member Node
        %   Using the fromDate, toDate, event, and pidFilter filter 
        %   parameters, get a subset or all of the log
        %   records available from the Node based on the credentials
        %   provided in the session object.  Use the start and count
        %   parameters to page through the log records of a node.
        %   Returns the following log structured array
        %   log.entryId
        %   log.identifier
        %   log.ipAddress
        %   log.userAgent
        %   log.subject
        %   log.event
        %   log.dateLogged
        %   log.nodeIdentifier
        %
        % See https://purl.dataone.org/architecturev2/apis/Types.html#Types.LogEntry
        
            log(1).entryId = NaN;
            log(1).identifier = '';
            log(1).ipAddress = '';
            log(1).userAgent = '';
            log(1).subject = '';
            log(1).event = '';
            log(1).dateLogged = '';
            log(1).nodeIdentifier = '';
            
            % Iterate throught the Log object returned from the Java call
            % and poulate the log struct
            
        end

        function node = getCapabilities(self) 
        % GETCAPABILITIES Returns the capabilities of the DataONE Node
        %   The Node document that describes the DataONE node is returned
        %   as an XML string.
        %   import org.dataone.client.v2.DataONEClient;
        %   mn = DataONEClient.getMN('urn:node:KNB');
        %   node = mn.getCapabilities() returns
        %   the Node XML string of the configured DataONE node (repository).  
        %
        %   See also org.dataone.client.v2.DataONEClient,
        %   org.dataone.client.v2.MemberNode,
        %   org.dataone.client.v2.CoordinatingNode
        import org.dataone.service.util.TypeMarshaller;
        import java.io.ByteArrayOutputStream;
            
            node = ''; 
        
            node_obj = self.node.getCapabilities(); % Make a Java Call
            
            % Serialize the Java Node return type to XML and return it
            baos = ByteArrayOutputStream();
            TypeMarshaller.marshalTypeToOutputStream(node_obj, baos); 
            node = char(baos.toString());
        end
        
        function object = get(self, session, pid)        
        % GET Returns the bytes of the object as a int8 array
        %   import org.dataone.client.v2.DataONEClient;
        %   mn = DataONEClient.getMN('urn:node:KNB')
        %   object = mn.get([], 'the-object-id') returns the bytes of
        %   the object (file) from the configured DataONE node (repository)

            import org.dataone.client.run.RunManager;
            import org.apache.commons.io.IOUtils;
            import java.io.File;
            import java.io.FileInputStream;
            import org.apache.commons.io.FileUtils;
            import org.dataone.service.types.v1.Identifier;
            
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug )
                disp('Called the Java version of DataONENode.get().');
            end

            if ( ~ ischar(pid) )
                msg = ['The given ''pid'' parameter must be an ' ...
                    'string object.' ...
                    char(10) ...
                    'Please create a string identifier ' ...
                    'before calling the ''get()'' function.'];
                error(msg);
            else
                j_pid = Identifier();
                j_pid.setValue(pid);
                
            end
            
            % Do we have a session object?
            if ( ~ isa(session, 'org.dataone.client.v2.Session') )
                import org.dataone.client.v2.Session;
                session = Session(); % Create a potentially empty session
               
            end
            
            % Get the Java session obect
            j_session = session.getJavaSession();
            
            % Call the Java function with the same name to retrieve the
            % DataONE object and get system metadata for this d1 object.
            % The formatId information is obtained from the system metadata
            inputStream = self.node.get(j_session, j_pid);  
            
            j_sysmeta = self.node.getSystemMetadata(j_session, j_pid);
            formatId = j_sysmeta.getFormatId().getValue();
            
            % Get filename from d1 object system metadata; otherwise, 
            % a UUID string is used as the filename of the local copy of the d1 object
            d1FileName = j_sysmeta.getFileName();
            if isempty(d1FileName)
                d1FileName = char(java.util.UUID.randomUUID());
                j_sysmeta.setFileName(d1FileName);
                
            end
            
            % Create a local copy for the d1 object under the execution
            % directory
            [path, name, ext] = fileparts(char(d1FileName));
            obj_name = [name ext];
            d1FileFullPath = ...
                fullfile(runManager.configuration.provenance_storage_directory, ...
                'runs', runManager.execution.execution_id, obj_name);
            targetFile = File(d1FileFullPath);
            FileUtils.copyInputStreamToFile(inputStream, targetFile);          
            object = int8(FileUtils.readFileToByteArray(targetFile)); % Return the byte array
            
            % Identify the DataObject being used and add a prov:used statement
            % in the RunManager DataPackage instance            
            if ( runManager.configuration.capture_file_reads )
                % Record the full path to the local copy of the downloaded object
                % that will eventually be added to the resource map
                
                import org.dataone.client.v2.DataObject;
  
                existing_id = runManager.execution.getIdByFullFilePath( ...
                     d1FileFullPath );
                                
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map
                    dataObject = ...
                        DataObject(char(j_pid.getValue()), char(formatId), d1FileFullPath);
                    % Set the system metadata downloaded from the given
                    % mnode for the current dataObject
                    set(dataObject, 'system_metadata', j_sysmeta);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                     runManager.execution.execution_input_ids{end + 1} = ...
                         char(j_pid.getValue());
                     
                else
                    % Update the existing map entry with a new DataObject
                    pid = existing_id;
                    dataObject = DataObject(pid, formatId, d1FileFullPath);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                end               
            end
            
        end
        
        function system_metadata = getSystemMetadata(self, session, pid)
            % GETSYSTEMMETADATA Returns the DataONE system metadata for 
            %   the given object identifier
            %
            %   import org.dataone.client.v2.DataONEClient;
            %   mn = DataONEClient.getMN('urn:node:KNB');
            %   object = mn.getSystemMetadata([], 'the-object-id') returns 
            %   the SystemMetadata of the object (file) from the 
            %   configured DataONE node (repository).  An empty array for
            %   the session parameter uses an anonymous session. 
            %
            % See also org.dataone.client.v2.SystemMetadata,
            %   org.dataone.client.v2.Session
            
            import org.dataone.client.v2.SystemMetadata;
            import org.dataone.service.types.v1.Identifier;
            j_pid = Identifier();
            j_pid.setValue(pid);
            
            % Do we have a session?
            if ( ~ isa(session, 'org.dataone.client.v2.Session') )
                import org.dataone.client.v2.Session;
                session = Session();
                
            end
            
            j_session = session.getJavaSession();
            
            system_metadata = SystemMetadata();
            
            % Convert the Java SystemMetadata object to a 
            % Matlab SystemMetadata object
            if ( ~ isempty(self.node) )
                try
                    j_system_metadata = self.node.getSystemMetadata(j_session, j_pid);
                    
                catch baseException
                    msg = ['The system metadata for the object ' ...
                        'could not be retrieved because: '];
                    
                    if ( isa(baseException.ExceptionObject, ...
                            'org.dataone.service.exceptions.NotFound') )
                        msg = [msg 'The object with id ''' id ''' couldn''t be found.'];
                        
                    elseif ( isa(baseException.ExceptionObject, ...
                            'org.dataone.service.exceptions.NotAuthorized') )
                        msg = [msg 'You don''t have permission to access ' ...
                            'the object with id ''' id '''.'];
                        
                    else
                        msg = [msg baseException.message];
                        
                    end
                    error(msg);
                end
                
                system_metadata = SystemMetadata.fromJavaSysMetaV2( ...
                    j_system_metadata);
            end
            
        end

        % function changed = systemMetadataChanged(session, id, ...
        %   serialVersion, dateSystemMetadataLastModified)
        %
        %   TODO: Implement later?
        %
        % end
        
        function description = describe(self, session, id)
        % DESCRIBE Returns a limited description of the object 
        %   Given the identifier, return a struct with minimal metadata
        %   about the object, including:
        %   description.formatId
        %   description.contentLength
        %   description.lastModified
        %   description.checksum
        %   description.serialVersion
        %
        % See https://purl.dataone.org/architecturev2/apis/Types.html#Types.DescribeResponse
                
            % Convert the Java DescribeResponse into the structured array
            import org.dataone.service.types.v1.DescribeResponse;
            import org.dataone.service.types.v1.Identifier;
            
            if ( isempty(session) )
                import org.dataone.client.v2.Session;
                session = Session();
                
            end
            
            j_session = session.getJavaSession();
            
            pid = Identifier();
            pid.setValue(id);
            describe_response = self.node.describe(j_session, pid);
            
            description.contentLength = ...
                describe_response.getContent_Length().doubleValue();
            
            description.formatId = ...
                char(describe_response.getDataONE_ObjectFormatIdentifier().getValue());
            
            j_formatter = java.text.SimpleDateFormat('yyyy-MM-dd''T''HH:mm:ss.SSSZ');
            j_formatter.setTimeZone(java.util.TimeZone.getTimeZone('UTC'));
            description.lastModified = ...
                char(j_formatter.format(describe_response.getLast_Modified()));
            
            description.checksum = ...
                char(describe_response.getDataONE_Checksum().getValue());
            
            description.checksumAlgorithm = ...
                char(describe_response.getDataONE_Checksum().getAlgorithm());
            
            description.serialVersion = ...
                describe_response.getSerialVersion().doubleValue();
            
        end
    
        function authorized = isAuthorized(self, session, id, action)
        % ISAUTHORIZED Returns whether the action is pemissible for the object
        %   Given the session credentials and the object id, determine 
        %   if the action (permission) on the object is allowed
        %
        %   import org.dataone.client.v2.DataONEClient;
        %   mn = DataONEClient.getMN('urn:node:KNB')
        %   authorized = mn.isAuthorized(session, 'the-object-id', 'read')
        %      returns a logical true if the credentials of the
        %      user in the given Session object is authorized to
        %      perform the action on the given object. Note that
        %      the action parameter is limited to 'read',
        %      'write', and 'changePermission' strings.
        
            authorized = false;
            
            if ( isempty(session) )
                import org.dataone.client.v2.Session;
                session = Session();
                
            end
            
            % Do we have a session?
            if ( ~ isa(session, 'org.dataone.client.v2.Session') )
                import org.dataone.client.v2.Session;
                session = Session();
                
            end
            
            j_session = session.getJavaSession();
            
            % Do we have a string identifier?
            if ( ~ ischar(id) )
                msg = ['The given ''id'' parameter must be a ' ...
                    'string object.' ...
                    char(10) ...
                    'Please provide a string identifier ' ...
                    'while calling the ''isAuthorized()'' function.'];
                error(msg);
                
            end
            
            % Do we have a correct permission string?
            if ( ~ isempty(action) )
                if ( ~ ismember(action, {'read', 'write', 'changePermission'}) )
                    msg = ['The given ''action'' parameter must be a ' ...
                        'string object.' ...
                        char(10) ...
                        'Please use a ''read'', ''write'', or ''changePermission'' ' ...
                        char(10) ...
                        'action while calling the ''isAuthorized()'' function.'];
                    error(msg);
                    
                end
            end
            
            import org.dataone.service.types.v1.Identifier;
            j_pid = Identifier();
            j_pid.setValue(id);
            
            if ( ~ ischar(action) || ...
                 ~ ismember(action, {'read', 'write', 'changePermission'}) )
                msg = ['The given ''action'' parameter must be a ' ...
                    'string object.' ...
                    char(10) ...
                    'Please use a ''read'', ''write'', or ''changePermission'' ' ...
                    char(10) ...
                    'action while calling the ''isAuthorized()'' function.'];
                error(msg);
            end
            import org.dataone.service.types.v1.Permission;
            j_action = Permission.convert(action);
            %Convert the Java response to logical true or false
            
            try
                authorized = ...
                    self.node.isAuthorized(j_session, j_pid, j_action);
                
            catch baseException
                if ( isprop(baseException, 'ExceptionObject') )
                    if ( isa(baseException.ExceptionObject, ...
                            'org.dataone.service.exceptions.NotFound') )
                        msg = ['The object with id ''' id ...
                               ''' could not be not found. '];
                           
                    elseif ( isa(baseException.ExceptionObject, ...
                            'org.dataone.service.exceptions.NotAuthorized') )
                        authorized = false;
                            
                    end
                    
                else
                    rethrow(baseException)
                    
                end
                error(msg);
            end
            
        end

    end   
end