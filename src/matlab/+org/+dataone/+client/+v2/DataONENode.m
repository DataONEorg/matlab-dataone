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
        
        % The DataONE node type (either 'cn' of 'mn')
        node_type;
        
        % The underlying java Node instance
        node;
    end
    
    properties (Access = 'private')
                
    end
    
    methods
        
        function date = ping()
        % PING Determines if the DataONE Node is reachable
        %   The ping() function sends an HTTP request to the Node.
        %   A successful respone will return a date timestamp as a string.
        %   A failure returns an empty string    
            date = '';
            
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

        function node = getCapabilities() 
        % GETCAPABILITIES Returns the capabilities of the DataONE Node
        %   The Node document that describes the DataONE node is returned
        %   as an XML string.
        
            node = ''; 
        
            % Serialize the Java Node return type to XML and return it
        end
        
        function object = get(session, id)
        % GET Returns the bytes of the object as a uint8 array
        
            object = zeros(1,1, 'uint8');
            
            % Convert the bytes from the Java InputStream and add them to
            % the object array
            
        end

        function system_metadata = getSystemMetadata(session, id)
        % GETSYSTEMMETADATA Returns the DataONE system metadata for the
        % given object identifier as an XML string
        
            system_metadata = '';
            
            % Serialize the Java SystemMetadata object to XML and return it
            
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
        
            % Convert the Java DescribeResponse into the structured aray
            
        end
    
        function authorized = isAuthorized(session, id, action)
        % ISAUTHORIZED Returns whether the action is pemissible for the object
        %   Given the session credentials and the object id, determine 
        %   if the action (permission) on the object is allowed
        
            authorized = false;
            
            %Convert the Java response to logical true or false
    
        end

    end
    
    methods (Access = 'private')
        
    end
end