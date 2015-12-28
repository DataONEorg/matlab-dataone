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
        
        
        function [objects, start, count, total] = listObjects(coordinatingNode, session, fromDate, ...
                toDate, formatid, nodeid, identifier, start, count)
            % ListObjects Retrieves the list of objects present on the CN that
            % match the calling parameters. At a minimum, this method should be
            % able to return a list of objects that match:
            
            import java.util.Date;
            import org.dataone.service.types.v1.ObjectFormatIdentifier;
            import org.dataone.service.types.v1.Identifier;
            import java.lang.Integer;
            import org.dataone.service.types.v1.NodeReference;
            
            objects(1).identifier = '';
            objects(1).formatId = '';
            objects(1).checksum = '';
            objects(1).checksumAlgorithm = '';
            objects(1).dateSysMetadataModified = '';
            objects(1).size = NaN;
            
            
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
            
            mnodeRef = NodeReference();
            mnodeRef.setValue(nodeid);
            
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
            
            objectList = coordinatingNode.node.listObjects(session, fromDateObj, toDateObj, formatidObj, ...
                mnodeRef, identifierObj, startObj, countObj);
            
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
        
    end
    
end

