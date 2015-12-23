% SYSTEMMETADATA A class representing DataONE sytem metadata associated
% with an object.
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

classdef SystemMetadata < hgsetget
    % SYSTEMMETADATA A class representing DataONE sytem metadata associated
    % with an object.
    
    properties
       
        % A serial number maintained by the coordinating node to indicate when changes have occurred
        serialVersion;
        
        % A unique Unicode string that is used to canonically name and identify the object 
        identifier;
        
        % A designation of the standard or format used to interpret the contents of the object
        formatId;
        
        % The size of the object in octets (8-bit bytes)
        size;
        
        % A calculated hash value used to validate object integrity 
        checksum;
        
        % The subject who submitted the associated object to the DataONE Member Node
        submitter;
        
        % The subject that has ultimate authority for the object
        rightsHolder;
        
        % The accessPolicy determines which Subjects are allowed to view or make changes to an object
        accessPolicy;
        
        % A controlled list of policy choices that determine how many replicas should be maintained for a given object
        replicationPolicy;
        
        % The Identifier of an object that is a prior version of the object
        obsoletes;
        
        % The Identifier of an object that is a subsequent version of the object
        obsoletedBy;
        
        % A boolean flag, set to true if the object has been classified as archived
        archived;
        
        % Date and time (UTC) that the object was uploaded to the DataONE Member Node
        dateUploaded;
        
        % Date and time (UTC) that this system metadata record was last modified
        dateSysMetadataModified;
        
        % A reference to the Member Node that originally uploaded the associated object
        originMemberNode;
        
        % A reference to the Member Node that acts as the authoritative source for an object
        authoritativeMemberNode;
        
        % A container field used to repeatedly provide several metadata fields about each object replica that exists
        replica;
        
        % An optional, unique Unicode string that identifies an object revision chain
        seriesId;
        
        % Indicates the IANA Media Type (aka MIME-Type) of the object
        mediaType;
        
        % Optional though recommended value providing a suggested file name for the object
        fileName;
        
    end
    
    properties (Access = 'private')
        
        % The backing Java system metadata object
        systemMetadata;
        
    end
    
    methods
        
        function sysmeta = SystemMetadata()
        % SYSTEMMETADATA Constructs a new SystemMetadata object
        
            % Pull in user-defined configuration options
            import org.dataone.client.configure.Configuration;
            config = Configuration.loadConfig('');
            
            % Initialize properties
            sysmeta.serialVersion = 0;
            sysmeta.identifier = '';
            sysmeta.formatId = '';
            sysmeta.size = NaN;
            sysmeta.checksum(1).value = '';
            sysmeta.checksum(1).algorithm = 'SHA-1';
            sysmeta.submitter = '';
            sysmeta.rightsHolder = '';
            sysmeta.accessPolicy(1).subject = '';
            sysmeta.accessPolicy(1).permission = '';
            sysmeta.replicationPolicy.replicationAllowed = true;
            sysmeta.replicationPolicy.numberReplicas = 2;
            sysmeta.replicationPolicy.preferredNodes = {};
            sysmeta.replicationPolicy.blockedNodes = {};
            sysmeta.obsoletes = '';
            sysmeta.obsoletedBy = '';
            sysmeta.archived = '';
            sysmeta.dateUploaded = '';
            sysmeta.dateSysMetadataModified = '';
            sysmeta.originMemberNode = '';
            sysmeta.authoritativeMemberNode = '';
            % sysmeta.replica = ;
            sysmeta.seriesId = '';
            sysmeta.mediaType = '';
            sysmeta.fileName = '';

            sysmeta.systemMetadata = org.dataone.service.types.v2.SystemMetadata();
        end
        
        function addAccessRule(subject, permission)
        % ADDACCESSRULE Adds a rule to the access policy for the given subject and permission    
        
        end
        
        function removeAccessRule(subject, permission)
        % REMOVEACCESSRULE Removes a rule to from access policy matching the given subject and permission    
    
        end
                
        function addPreferredNode(sysmeta, node_id)
        % ADDPREFERREDNODE Adds a node id to the list of preferred nodes
        
        end
        
        function removePreferredNode(sysmeta, node_id)
        % REMOVEPREFERREDNODE Removes a node id from the list of preferred nodes
        end
        
        function addBlockedNode(sysmeta, node_id)
        % ADDBLOCKEDNODE Adds a node id to the list of blocked nodes
        
        end
        
        function removeBlockedNode(sysmeta, node_id)
        % REMOVEBLOCKEDNODE Removes a node id from the list of blocked nodes
        
            end
        
    end
    
    methods (Access = 'private')
        
        function updateSystemMetadata()
            
        end
        
    end
    
end

