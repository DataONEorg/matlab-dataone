% COORDINATINGNODE A class that represents a DataONE Coordinating Node
%   The CoordinatingNode class provides functions to interact with a
%   DataONE Coordinating Node.
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

classdef CoordinatingNode < org.dataone.client.v2.DataONENode
    %COORDINATINGNODE A class representing a DataONE Coordinating Node
    
    properties
        
    end
    
    methods
        
        function coordinatingNode = CoordinatingNode(cnode_base_service_url) % class constructor method
            % CoordinatingNode Constructs an CoordinatingNode object instance with the given
            % coordinating node base url
            
            import org.dataone.client.v2.itk.D1Client;
            import org.dataone.client.v2.impl.MultipartCNode;
                      
            if ~isempty(cnode_base_service_url)
                
                % Question: do we need to set the property of configuration
                % instance here?
                import org.dataone.client.configure.Configuration;
                config = Configuration.loadConfig('');
                set(config, 'coordinating_node_base_url', cnode_base_service_url);
                
                % Question: same question as above
                import org.dataone.configuration.Settings;
                Settings.getConfiguration().setProperty('D1Client.CN_URL', ...
                    config.coordinating_node_base_url);
                                
                coordinatingNode.node = D1Client.getCN(config.coordinating_node_base_url);
                
                coordinatingNode.node_base_service_url = char(cnode_base_service_url);
                coordinatingNode.node_type = 'cn';
                coordinatingNode.node_id = char(coordinatingNode.node.getNodeId()); % value is ''?
             
            end
        end
         
%         function ping(coordinatingNode)
%         % PING Determines if the DataONE Node is reachable
%         %   The ping() function sends an HTTP request to the Node. A
%         %   successful respone will return a date timestamp as a string. A
%         %   failure returns an empty string
%         
%         
%         end
        
        function objectFormatList = listFormats(coordinatingNode)
        % ListFormats Returns a list of all object formats registered in
        % the DataONE Object Format Vocabulary.
            
        end
        
        function objectFormat = getFormat(coordinatingNode, formatid)
        % GetFormat Returns the object format registered in the DataONE
        % Object Format Vocabulary for the given format identifier.
            
            objectFormat.mediaType = '';
            objectFormat.extension = '';
          
            
        end
        
        function nodeList = listNodes(coordinatingNode)
        % ListNodes Returns a list of nodes that have been registered with
        % the DataONE infrastructure.
            
        
        end
        
        
        function [objects, start, count, total] = ...
                listObjects(coordinatingNode, session, fromDate, ...
                toDate, formatid, nodeid, identifier, start, count)
            % ListObjects Retrieves the list of objects present on the CN that
            % match the calling parameters.
            
            import java.util.Date;
            import org.dataone.service.types.v1.ObjectFormatIdentifier;
            import org.dataone.service.types.v1.Identifier;
            import java.lang.Integer;
            import org.dataone.service.types.v1.NodeReference;
            
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
            
            if ( ~ isa(session, 'org.dataone.client.v2.Session') )
                msg = ['The ''session'' parameter must be ' ...
                    'an ''org.dataone.client.v2.Session'' object. '
                    char(10) ...
                    'Please use the Session class when calling ' ...
                    'the listObjects() function.'];
                error(msg);
                
            end
            
            j_session = session.getJavaSession();

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
         
            j_nodeid = [];
            if ( ~ isempty(nodeid) )
                j_nodeid = NodeReference();
                j_nodeid.setValue(nodeid);
                
            end
            
            j_identifier = [];
            if ( ~isempty(identifier) )
                j_identifier = Identifier();
                j_identifier.setValue(identifier);
            end
                        
            j_start = [];
            if ( ~isempty(start) )
                j_start = Integer(start);
                
            end
            
            j_count = [];
            if( ~isempty(count) )
                j_count = Integer(count);
                
            end
            
            objectList = coordinatingNode.node.listObjects( ...
                j_session, j_fromDate, j_toDate, j_formatid, ...
                j_nodeid, j_identifier, j_start, j_count);
            
            % Covert the Java ObjectList into the above structured array
            objectInfoList = objectList.getObjectInfoList();
            for i = 1:size(objectInfoList)
                anObj = objectInfoList.get(i-1);
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
        
    end
    
end

