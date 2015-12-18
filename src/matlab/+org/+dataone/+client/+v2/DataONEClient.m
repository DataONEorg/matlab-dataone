% D1CLIENT A class used to communicate with nodes in the DataONE network
%   The D1Client class provides functions to communicate with nodes in the
%   DataONE network, particularly Member Nodes and Coordinating Nodes, using
%   the DataONE Service API
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

classdef DataONEClient < hgsetget
    
    properties
        
    end

    methods (Static)
        
        function memberNode = getMN(node_id)
        % GETMN Returns a MemberNode instance used to communicate with the node
            
            import org.dataone.client.v2.MNode;
            import org.dataone.client.v2.itk.D1Client;
            import org.dataone.service.types.v1.NodeReference;
            
            if ( ~ strcmp(node_id, 'urn:node:') )
                error('The node_id must begin with "urn:node:"');
                
            end
            
            node_ref = NodeReference();
            node_ref.setValue(node_id);
            
            mn = D1Client.getMN(node_ref);
            
            import org.dataone.client.v2.MemberNode;
            url = str(mn.getNodeBaseServiceURL());
            memberNode = MemberNode(url);
            memberNode.mnode = mn;
            
        end
        
        function coordinating_node = getCN(d1_client)
        % GETCN Returns a CoordinatingNode instance for the environment
        
            import org.dataone.client.v2.CNode;
            import org.dataone.client.v2.itk.D1Client;
            
            import org.dataone.client.v2.CoordinatingNode;
            coordinating_node = CoordinatingNode();
            import org.dataone.client.configure.Configuration;
            config = Configuration(); % Use client's saved configuration
            
            % The list of known coordinating nodes
            coordinating_nodes = { ...
                'https://cn.dataone.org/cn', ...
                'https://cn-dev.test.dataone.org/cn', ...
                'https://cn-dev-2.test.dataone.org/cn', ...
                'https://cn-sandbox.test.dataone.org/cn', ...
                'https://cn-sandbox-2.test.dataone.org/cn', ...
                'https://cn-stage.test.dataone.org/cn', ...
                'https://cn-stage-2.test.dataone.org/cn', ...
            };
    

            % Do we have a configured CN?
            if ( ~isempty(config.coordinating_node_base_url) )
                
                % Is it valid?
                if ( ismember( ...
                        config.coordinating_node_base_url, ...
                        coordinating_nodes) )
                    
                    cn = D1Client.getCN(config.coordinating_node_base_url);
                    set(coordinating_node, 'cnode', cn);
                    set(coordinating_node, 'node_id', char(cn.getNodeId()));
                    set(coordinating_node, 'node_type', 'cn');
                    set(coordinating_node, 'node_base_service_url', char(cn.getNodeBaseServiceUrl()));
                    
                else
                    error(['The Coordinating Node base URL: ' ...
                        config.coordinating_node_base_url ...
                        ' is not valid. Please set the ' ...
                        'Configuration.coordinating_node_base_url ' ...
                        'property to one of: ' coordinating_nodes]);
                end
            end
            
        end
    end   
end
