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
        
        function sysmeta = set(sysmeta, name, value)
            % Overload the hgsetget set() function to customize setting properties
            
            property = strtrim(name);
            
            if strcmp(property, 'serialVersion')
                % Validate the serialVersion as an integer
                if mod(value, 1) == 0
                    sysmeta.serialVersion = value;
                else
                    error(['The SystemMetadata.serialVersion property ' ...
                           'must be 0 or a whole positive number.']);
                       
                end
                
            end

            if strcmp(property, 'identifier')
                % Validate the identifier string
                if ( any(isspace(value)) )
                    error(['The SystemMetadata.identifier property ' ...
                           'can not contain whitespace characters.']);
                end
                
                if ( length(value) > 800 )
                    error(['The SystemMetadata.identifier property ' ...
                           'must be less than 800 characters.']);
                       
                end
                
                if ( value == '' || isempty(value) || isnan(value))
                    error(['The SystemMetadata.identifier property ' ...
                           'must an 800 character or less string.']);
                    
                end
                sysmeta.identifier = value;
                
            end

            if strcmp(property, 'formatId')
                % Validate the formatId
                if ( ~ ischar(value) )
                    error(['The SystemMetadata.formatId property ' ...
                           'must a recognized Object Format Identifer ' ...
                           char(10) ...
                           'in the DataONE Format Registry. ' ...
                           'The format ids can be seen at ' ...
                           char(10) ...
                           'https://cn/dataone.org/cn/v2/formats.']);
                    
                end
                sysmeta.formatId = value;
                
            end

            if strcmp(property, 'size')
                % Validate the size
                if ( mod(value, 1) ~= 0 )
                    error(['The SystemMetadata.size property ' ...
                           'must be a whole positive number ']);
                    
                end
                sysmeta.size = value;
                
            end

            if strcmp(property, 'checksum')
                % Validate the checksum structure
                if ( ~ isstruct(value) )
                    error(['The SystemMetadata.checksum property ' ...
                           'must be a struct with two fields: ' ...
                           char(10) ...
                           'value and algorithm.']);
                end
                
                if ( ~ strcmp(value.algorithm, 'MD5') || ...
                     ~ strcmp(value.algorithm, 'SHA-1') )
                    error(['The SystemMetadata.checksum.algorithm ' ...
                           'must be either "MD5" or "SHA-1".']);
                       
                end
                chksum = value;
                if ( ~ ischar(chksum.value) )
                    error(['The SystemMetadata.checksum.value ' ...
                        'must be a valid SHA-1 or MD5 checsum value.']);
                end
                sysmeta.checksum = value;
                
            end

            if strcmp(property, 'submitter')
                % Validate the submitter
                if ( ~ ischar(value) || isempty(value))
                    error(['The SystemMetadata.submitter property ' ...
                        'must be a string.']);
                    
                end
                sysmeta.submitter = value;
                
            end

            if strcmp(property, 'rightsHolder')
                % Validate the rightsHolder
                if ( ~ ischar(value) || isempty(value))
                    error(['The SystemMetadata.rightsHolder property ' ...
                        'must be a string.']);
                    
                end
                sysmeta.submitter = value;
            end

            % if strcmp(property, 'accessPolicy')
            %     
            % end

            %if strcmp(property, 'replicationPolicy')
            %     
            %end

            % if strcmp(property, 'obsoletes')
            %
            % end

            % if strcmp(property, 'obsoletedBy')
            %
            % end

            if strcmp(property, 'archived')
                % Validate the archived flag
                if ( ~ islogical(value) )
                    error(['The SystemMetadata.archived property ' ...
                        'must be a logical true or false value.']);
                    
                end
                sysmeta.archived = value;
                
            end

            if strcmp(property, 'dateUploaded')
                % Validate the dateUploaded date
                if ( ~ isa(value, 'datetime') )
                    error(['The SystemMetadata.dateUploaded property ' ...
                        'must be a Matlab datetime type.']);
                    
                end
                sysmeta.dateUploaded = value;
                
            end

            if strcmp(property, 'dateSysMetadataModified')
                % Validate the dateSysMetadataModified date
                if ( ~ isa(value, 'datetime') )
                    error(['The SystemMetadata.dateSysMetadataModified property ' ...
                        'must be a Matlab datetime type.']);
                    
                end
                sysmeta.dateSysMetadataModified = value;
            end

            if strcmp(property, 'originMemberNode')
                % Validate the origin member node string
                if ( isempty(value) || ...
                     strcmp(value, 'urn:node:XXXX') || ...
                     length(value) > 25 || ...
                     strfind(value, 'urn:node:') ~= 1 )
                    error(['The SystemMetadata.originMemberNode property ' ...
                        'must be a 25 character or less string ' ...
                        char(10) ...
                        'starting with ''' 'urn:node:' '''']);
                    
                end
                sysmeta.originMemberNode = value;
                
            end

            if strcmp(property, 'authoritativeMemberNode')
                % Validate the authoritative member node string
                if ( isempty(value) || ...
                     strcmp(value, 'urn:node:XXXX') || ...
                     length(value) > 25 || ...
                     strfind(value, 'urn:node:') ~= 1 )
                    error(['The SystemMetadata.authoritativeMemberNode property ' ...
                        'must be a 25 character or less string ' ...
                        char(10) ...
                        'starting with ''' 'urn:node:' '''']);
                    
                end
                sysmeta.authoritativeMemberNode = value;
                
            end

            % if strcmp(property, 'replica')
            %
            % end

            if strcmp(property, 'seriesId')
                % Validate the seriesId string
                if ( ~ ischar(value) || isempty(value))
                    error(['The SystemMetadata.seriesId property ' ...
                        'must be a string.']);
                end
                sysmeta.seriesId = value;
                
            end

            if strcmp(property, 'mediaType')
                % Validate the mediaType property
                if ( ~ isa(value, 'containers.Map') )
                    error(['The SystemMetadata.mediaType property ' ...
                        'must be a containers.Map data type.']);
                    
                else
                    if ( strcmp(value.KeyType, 'char') || ...
                         strcmp(value.ValueType, 'char') )
                        error(['The SystemMetadata.mediaType property ' ...
                            char(10) ...
                            'must have both a KeyType and ValueType of ' ...
                            '''char''']);
                    end
                    sysmeta.mediaType = value;
                    
                end
            end

            if strcmp(property, 'fileName')
                % Validate the fileName string
                if ( ~ ischar(value) || isempty(value))
                    error(['The SystemMetadata.fileName property ' ...
                        'must be a string.']);
                end
                sysmeta.fileName = value;
            end

            
        end
        
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

