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
                
                import org.dataone.client.configure.Configuration;
                config = Configuration.loadConfig('');
                set(config, 'coordinating_node_base_url', 'https://cn-dev-2.test.dataone.org/cn');
                
                import org.dataone.configuration.Settings;
                Settings.getConfiguration().setProperty('D1Client.CN_URL', ...
                    config.coordinating_node_base_url);
                                
                coordinatingNode.node = D1Client.getCN(config.coordinating_node_base_url);
                
                coordinatingNode.node_base_service_url = char(cnode_base_service_url);
                coordinatingNode.node_type = 'cn';
                coordinatingNode.node_id = '';
            end
        end
        
        function ping(coordinatingNode)
        % PING Determines if the DataONE Node is reachable
        %   The ping() function sends an HTTP request to the Node. A
        %   successful respone will return a date timestamp as a string. A
        %   failure returns an empty string
        
        
        end
        
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
        
        
        function objects = listObjects(coordinatingNode, session, fromDate, ...
                toDate, formatid, identifier, start, count, nodeid)
            % ListObjects Retrieves the list of objects present on the CN that
            % match the calling parameters. At a minimum, this method should be
            % able to return a list of objects that match:
            
            objects(1).identifier = '';
            objects(1).formatId = '';
            objects(1).checksum = '';
            objects(1).checksumAlgorithm = '';
            objects(1).dateSysMetadataModified = '';
            objects(1).size = NaN;
            
            
        end
        
    end
    
end

