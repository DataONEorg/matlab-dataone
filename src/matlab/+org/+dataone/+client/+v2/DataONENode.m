% DATAONENODE A class that represents a DataONE Node
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
        
            import org.dataone.service.util.TypeMarshaller;
            import java.io.ByteArrayOutputStream;
            
            node = ''; 
        
            node_obj = self.node.getCapabilities(); % Make a Java Call
            
            % Serialize the Java Node return type to XML and return it
            baos = ByteArrayOutputStream();
            TypeMarshaller.marshalTypeToOutputStream(node_obj, baos); 
            node = char(baos.toString());
        end
        
        function object  = get(self, session, pid)        
            % GET Returns the bytes of the object as a uint8 array

            import org.dataone.client.v2.impl.MultipartMNode;
            import org.dataone.client.run.RunManager;
            import org.dataone.service.types.v2.SystemMetadata;
            import org.apache.commons.io.IOUtils;
            import java.io.File;
            import java.io.FileInputStream;
            import org.apache.commons.io.FileUtils;
            
            runManager = RunManager.getInstance();
            
            if ( runManager.configuration.debug )
                disp('Called the Java version of DataONENode.get().');
            end

            % Call the Java function with the same name to retrieve the
            % DataONE object and get system metadata for this d1 object.
            % The formatId information is obtained from the system metadata
            inputStream = self.node.get(session, pid);  
            
            sysMetaData = self.node.getSystemMetadata(session, pid);
            formatId = sysMetaData.getFormatId().getValue();
            
            % Get filename from d1 object system metadata; otherwise, 
            % a UUID string is used as the filename of the local copy of the d1 object
            d1FileName = sysMetaData.getFileName();
            if isempty(d1FileName)
                d1FileName = char(java.util.UUID.randomUUID());
                
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
            object = uint8(FileUtils.readFileToByteArray(targetFile)); % Return the byte array
            
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
                        DataObject(char(pid.getValue()), formatId, d1FileFullPath);
                    % Set the system metadata downloaded from the given
                    % mnode for the current dataObject
                    set(dataObject, 'system_metadata', sysMetaData);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                     runManager.execution.execution_input_ids{end + 1} = ...
                         char(pid.getValue());
                     
                else
                    % Update the existing map entry with a new DataObject
                    pid = existing_id;
                    dataObject = DataObject(pid, formatId, d1FileFullPath);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                end               
            end
            
        end
        
        function system_metadata = getSystemMetadata(self, session, id)
        % GETSYSTEMMETADATA Returns the DataONE system metadata for the
        % given object identifier
        
            import org.dataone.client.v2.SystemMetadata;
            import org.dataone.service.types.v1.Identifier;
            pid = Identifier();
            pid.setValue(id);
            % session = this.getSession();
            system_metadata = SystemMetadata();
            
            % Convert the Java SystemMetadata object to a 
            % Matlab SystemMetadata object
            if ( ~ isempty(self.node) )
                try
                    j_system_metadata = self.node.getSystemMetadata(session, pid);
                    
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
        
        function description = describe(session, id)
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
        
            description(1).formatId = '';
            description(1).contentLength = NaN;
            description(1).lastModified = '';
            description(1).checksum = '';
            description(1).checksumAlgorithm = '';
            description(1).serialVersion = NaN;
        
            % Convert the Java DescribeResponse into the structured array
            
        end
    
        function authorized = isAuthorized(session, id, action)
        % ISAUTHORIZED Returns whether the action is pemissible for the object
        %   Given the session credentials and the object id, determine 
        %   if the action (permission) on the object is allowed
        
            authorized = false;
            
            %Convert the Java response to logical true or false
    
        end

    end
    
    methods (Access = 'protected')
        
        function session = getSession()
            % GETSESSION returns a DataONE Java Session object using
            % Configuration settings
            import org.dataone.client.auth.CertificateManager;
            import java.security.cert.X509Certificate;
            import org.dataone.service.types.v1.Session;
            
            session = Session(); % start an empty session by default

            % Get an authentication token or X509 certificate
            config = Configuration.loadConfig('');
            auth_token = config.get('authentication_token');
            cert_path = config.get('certificate_path');
                        
            % Use auth tokens preferentially
            if ( ~isempty(auth_token) )
                import org.dataone.client.auth.AuthTokenSession;
                session = AuthTokenSession(auth_token);
                
            % Otherwise use the X509 certificate
            elseif ( ~ isempty(cert_path) )
                CertificateManager.getInstance().setCertificateLocation(cert_path);
                
            end
        end
    end
end