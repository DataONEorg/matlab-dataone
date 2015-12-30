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
    
    properties (SetAccess = 'private')
       
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
        replicas;
        
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
        
        % The configuration set by the user
        config;
    end
    
    methods
        
        function sysmeta = SystemMetadata()
        % SYSTEMMETADATA Constructs a new SystemMetadata object
            sysmeta.systemMetadata = ...
                org.dataone.service.types.v2.SystemMetadata();
            
        end
        
        function sysmeta = set(sysmeta, name, value)
            % Overload the hgsetget set() function to customize setting properties
            
            property = strtrim(name);
            
            if strcmp(property, 'serialVersion')
                % Validate the serialVersion as an integer
                if ( ischar(value) )
                    value = str2num(value); % Ensure we have a number
                    
                end
                
                if ( ~ mod(value, 1) == 0 )
                    error(['The SystemMetadata.serialVersion property ' ...
                           'must be 0 or a whole positive number.']);
                       
                end
                sysmeta.serialVersion = value;
                import java.math.BigInteger;
                serialVersionBigInt = BigInteger(num2str(sysmeta.serialVersion));
                sysmeta.systemMetadata.setSerialVersion(serialVersionBigInt);
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
                
                if ( isempty(value) || any(isnan(value)))
                    error(['The SystemMetadata.identifier property ' ...
                           'must an 800 character or less string.']);
                    
                end
                sysmeta.identifier = value;
                import org.dataone.service.types.v1.Identifier;
                obsoletesId = Identifier();
                obsoletesId.setValue(value);
                sysmeta.systemMetadata.setIdentifier(obsoletesId);
                
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
                import org.dataone.service.types.v1.ObjectFormatIdentifier;
                fmtId = ObjectFormatIdentifier();
                fmtId.setValue(value);
                sysmeta.systemMetadata.setFormatId(fmtId);
                
            end

            if strcmp(property, 'size')
                % Validate the size
                if ( ischar(value) )
                    value = str2num(value); % Ensure we have a number
                    
                end
                
                if ( mod(value, 1) ~= 0 )
                    error(['The SystemMetadata.size property ' ...
                           'must be a whole positive number ']);
                    
                end
                sysmeta.size = value;
                import java.math.BigInteger;
                sizeBigInt = BigInteger(num2str(sysmeta.size));
                sysmeta.systemMetadata.setSize(sizeBigInt);
                
            end

            if strcmp(property, 'checksum')
                % Validate the checksum structure
                if ( ~ isstruct(value) )
                    error(['The SystemMetadata.checksum property ' ...
                           'must be a struct with two fields: ' ...
                           char(10) ...
                           'value and algorithm.']);
                end
                
                if ( ~ strcmp(value.algorithm, 'MD5') && ...
                     ~ strcmp(value.algorithm, 'SHA-1') )
                    error(['The SystemMetadata.checksum.algorithm ' ...
                           'must be either "MD5" or "SHA-1".']);
                       
                end
                if ( ~ ischar(value.value) )
                    error(['The SystemMetadata.checksum.value ' ...
                        'must be a valid SHA-1 or MD5 checksum value.']);
                end
                sysmeta.checksum = value;
                import org.dataone.service.types.v1.Checksum;
                chksum = Checksum();
                chksum.setValue(sysmeta.checksum.value);
                chksum.setAlgorithm(sysmeta.checksum.algorithm);
                sysmeta.systemMetadata.setChecksum(chksum);
                
            end

            if strcmp(property, 'submitter')
                % Validate the submitter
                if ( ~ ischar(value) || isempty(value))
                    error(['The SystemMetadata.submitter property ' ...
                        'must be a string.']);
                    
                end
                sysmeta.submitter = value;
                import org.dataone.service.types.v1.Subject;
                subject = Subject();
                subject.setValue(sysmeta.submitter);
                sysmeta.systemMetadata.setSubmitter(subject);
                
            end

            if strcmp(property, 'rightsHolder')
                % Validate the rightsHolder
                if ( ~ ischar(value) )
                    error(['The SystemMetadata.rightsHolder property ' ...
                        'must be a string.']);
                    
                end
                sysmeta.rightsHolder = value;
                import org.dataone.service.types.v1.Subject;
                subject = Subject();
                subject.setValue(sysmeta.rightsHolder);
                sysmeta.systemMetadata.setRightsHolder(subject);
                
            end

            if strcmp(property, 'accessPolicy')
                % Validate the access policy
                msg = ['The SystemMetadata.accessPolicy property ' ...
                        'must be a struct with a ''rules'' field ' ...
                        char(10) ...
                        'that is a containers.Map object. The map ' ...
                        'must contain a ''subject'' key and a ' ...
                        char(10) ...
                        '''permission'' value, both as strings. ' ...
                        'For example: ' ...
                        char(10) ...
                        'accessPolicy.rules = containers.Map' ...
                        '(''KeyType'', ''char'', ''ValueType'', ''char'');' ...
                        char(10) ...
                        'accessPolicy.rules(''public'') = ''read'';' ...
                        char(10) ...
                        'set(sysmeta, ''accessPolicy'', accessPolicy);'
                       ];
                
                if ( ~ isstruct(value) ) % must be a struct
                    error(msg);
                    
                end
                
                if ( ~ any(ismember('rules', fieldnames(value))) ) % rules field
                    error(msg);
                    
                end
                
                if ( ~ isa(value.rules, 'containers.Map') ) % rules map
                    error(msg);
                    
                end
                
                sysmeta.accessPolicy = value;
                import org.dataone.service.types.v1.AccessPolicy;
                import org.dataone.service.types.v1.AccessRule;
                import org.dataone.service.types.v1.Permission;
                import org.dataone.service.types.v1.Subject;
                policy = AccessPolicy();
                
                % Create access rules
                accessSubjects = keys(sysmeta.accessPolicy.rules);
                for i = 1:length(accessSubjects)
                    subj = accessSubjects{i};
                    subject = Subject();
                    subject.setValue(subj);
                    perm = sysmeta.accessPolicy.rules(subj);
                    % What level of permission do we have?
                    switch perm
                        case {'read', 'READ', 'Read'}
                            permission = Permission.READ;
                            
                        case {'write', 'WRITE', 'Write'}
                            permission = Permission.WRITE;

                        case {'changePermission', 'CHANGEPERMISSION', 'ChangePermission'}
                            permission = Permission.CHANGE_PERMISSION;
                            
                        otherwise
                            error(msg);
                            
                    end
                    accessRule = AccessRule();
                    accessRule.addSubject(subject);
                    accessRule.addPermission(permission);
                    policy.addAllow(accessRule);
                    
                end
                sysmeta.systemMetadata.setAccessPolicy(policy);
                
                
            end

            if strcmp(property, 'replicationPolicy')
                 % Validate the replication policy
                 msg = ['The SystemMetadata.replicationPolicy property ' ...
                     'must be a struct with a boolean ''replicationAllowed'' ' ...
                     char(10) ...
                     'field and a numberOfReplicas integer field. ' ...
                     'Other optional fields include the preferredNodes list ' ...
                     char(10) ...
                     'and the blockedNodes list, both of which are cell ' ...
                     'arrays of node identifier strings. ' ...
                     'For example: ' ...
                     char(10) ...
                     'replicationPolicy.replicationAllowed = true;' ...
                     char(10) ...
                     'replicationPolicy.numberOfReplicas = 2;' ...
                     char(10) ...
                     'replicationPolicy.preferredNodes = {''urn:node:FASTNODE'', ''urn:node:FRIENDNODE''};' ...
                     char(10) ...
                     'replicationPolicy.blockedNodes = {''urn:node:SLOWNODE'', ''urn:node:FOENODE''};' ...
                     char(10) ...
                     'set(sysmeta, ''replicationPolicy'', replicationPolicy);'
                     ];
                
                 if ( ~ isstruct(value) ) % must be a struct
                    error(msg);
                    
                end
                
                if ( ~ any(ismember('replicationAllowed', fieldnames(value))) ) % allowed field
                    error(msg);
                    
                end
                
                if ( ~ any(ismember('numberOfReplicas', fieldnames(value))) ) % number field
                    error(msg);
                    
                end
                
                if ( any(ismember('preferredNodes', fieldnames(value))) ) % preferred field
                    if ( ~ iscellstr(value.preferredNodes) ) % cell array of strings
                        error(msg);
                    
                    end
                                        
                end
                
                if ( any(ismember('blockedNodes', fieldnames(value))) ) % blocked field
                    if ( ~ iscellstr(value.blockedNodes) ) % cell array of strings
                        error(msg);
                    
                    end
                                        
                end
                sysmeta.replicationPolicy = value;
                import org.dataone.service.types.v1.ReplicationPolicy;
                import org.dataone.service.types.v1.NodeReference;
                import java.lang.Integer;
                import java.lang.Boolean;
                
                if ( ~ isempty(sysmeta.replicationPolicy) )
                    policy = ReplicationPolicy();
                    policy.setReplicationAllowed( ...
                        Boolean(sysmeta.replicationPolicy.replicationAllowed));
                    policy.setNumberReplicas(Integer( ... 
                        sysmeta.replicationPolicy.numberOfReplicas));
                    
                    % Add any preferred MNs
                    if ( any(ismember('preferredNodes', ...
                            fieldnames(sysmeta.replicationPolicy))) )
                        for i = 1:length(sysmeta.replicationPolicy.preferredNodes)
                            nodeId = NodeReference();
                            nodeId.setValue( ...
                                sysmeta.replicationPolicy.preferredNodes{i});
                            policy.addPreferredMemberNode(nodeId);
                            
                        end
                    end
                    
                    % Add any blocked MNs
                    if ( any(ismember('blockedNodes', ...
                            fieldnames(sysmeta.replicationPolicy))) )
                        for i = 1:length(sysmeta.replicationPolicy.blockedNodes)
                            nodeId = NodeReference();
                            nodeId.setValue( ...
                                sysmeta.replicationPolicy.blockedNodes{i});
                            policy.addBlockedMemberNode(nodeId);
                            
                        end
                    end
                    sysmeta.systemMetadata.setReplicationPolicy(policy);
                    
                end

            end

            if strcmp(property, 'obsoletes')
                % Validate the obsoletes string
                if ( any(isspace(value)) )
                    error(['The SystemMetadata.obsoletes property ' ...
                           'can not contain whitespace characters.']);
                end
                
                if ( length(value) > 800 )
                    error(['The SystemMetadata.obsoletes property ' ...
                           'must be less than 800 characters.']);
                       
                end
                
                if ( isempty(value) || any(isnan(value)))
                    error(['The SystemMetadata.obsoletes property ' ...
                           'must an 800 character or less string.']);
                    
                end
                sysmeta.obsoletes = value;
                import org.dataone.service.types.v1.Identifier;
                obsoletesId = Identifier();
                obsoletesId.setValue(sysmeta.obsoletes);
                sysmeta.systemMetadata.setObsoletes(obsoletesId);
                
            end

            if strcmp(property, 'obsoletedBy')
                % Validate the obsoletedBy string
                if ( any(isspace(value)) )
                    error(['The SystemMetadata.obsoletedBy property ' ...
                           'can not contain whitespace characters.']);
                end
                
                if ( length(value) > 800 )
                    error(['The SystemMetadata.obsoletedBy property ' ...
                           'must be less than 800 characters.']);
                       
                end
                
                if ( isempty(value) || any(isnan(value)))
                    error(['The SystemMetadata.obsoletedBy property ' ...
                           'must an 800 character or less string.']);
                    
                end
                sysmeta.obsoletedBy = value;
                import org.dataone.service.types.v1.Identifier;
                obsoletedById = Identifier();
                obsoletedById.setValue(sysmeta.obsoletedBy);
                sysmeta.systemMetadata.setObsoletedBy(obsoletedById);
                
            end

            if strcmp(property, 'archived')
                % Validate the archived flag
                if ( ~ islogical(value) )
                    error(['The SystemMetadata.archived property ' ...
                        'must be a logical true or false value.']);
                    
                end
                sysmeta.archived = value;
                import java.lang.Boolean;
                sysmeta.systemMetadata.setArchived(Boolean(sysmeta.archived));
                
            end

            if strcmp(property, 'dateUploaded')
                % Validate the dateUploaded date
                if ( ~ isa(value, 'datetime') )
                    error(['The SystemMetadata.dateUploaded property ' ...
                        'must be a Matlab datetime type.']);
                    
                end
                sysmeta.dateUploaded = value;
                import java.util.Date;
                millisSinceEpoch = round(86400000 * ... % millis in a day
                    (datenum(sysmeta.dateUploaded) - ... % datetime to numeric
                     datenum('1970', 'yyyy'))); % Unix epoch
                jDate = Date(millisSinceEpoch);
                sysmeta.systemMetadata.setDateUploaded(jDate);
                
            end

            if strcmp(property, 'dateSysMetadataModified')
                % Validate the dateSysMetadataModified date
                if ( ~ isa(value, 'datetime') )
                    error(['The SystemMetadata.dateSysMetadataModified property ' ...
                        'must be a Matlab datetime type.']);
                    
                end
                sysmeta.dateSysMetadataModified = value;
                import java.util.Date;
                millisSinceEpoch = round(86400000 * ... % millis in a day
                    (datenum(sysmeta.dateSysMetadataModified) - ... % datetime to numeric
                     datenum('1970', 'yyyy'))); % Unix epoch
                jDate = Date(millisSinceEpoch);
                sysmeta.systemMetadata.setDateSysMetadataModified(jDate);
                
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
                import org.dataone.service.types.v1.NodeReference;
                nodeId = NodeReference();
                nodeId.setValue(sysmeta.originMemberNode);
                sysmeta.systemMetadata.setOriginMemberNode(nodeId);

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
                import org.dataone.service.types.v1.NodeReference;
                nodeId = NodeReference();
                nodeId.setValue(sysmeta.authoritativeMemberNode);
                sysmeta.systemMetadata.setAuthoritativeMemberNode(nodeId);
                
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
                import org.dataone.service.types.v1.Identifier;
                seriesId = Identifier();
                seriesId.setValue(sysmeta.seriesId);
                sysmeta.systemMetadata.setSeriesId(seriesId);
                
            end

            if strcmp(property, 'mediaType')
                % Validate the mediaType property
                msg = ['The SystemMetadata.mediaType property ' ...
                        'must be a struct with a ''name'' field. ' ...
                        char(10) ...
                        'An optional ''properties'' field can be added ' ...
                        'that is a containers.Map object. The map ' ...
                        char(10) ...
                        'must contain the property name as a key and a ' ...
                        'property value as a value, both as strings. ' ...
                        'For example: ' ...
                        char(10) ...
                        'mediaType.name = ''text/plain'';' ...
                        char(10) ...
                        'mediaType.properties = containers.Map(''KeyType'', ''char'', ''ValueType'', ''char'');' ...
                        char(10) ...
                        'mediaType.properties(''my-prop-1'') = ''my-val-1'';' ...
                        char(10) ...
                        'mediaType.properties(''my-prop-2'') = ''my-val-2'';' ...
                        char(10) ...
                        'set(sysmeta, ''mediaType'', mediaType);' ...
                       ];
                
                if ( ~ isstruct(value) ) % must be a struct
                    error(msg);
                    
                end
                
                if ( ~ any(ismember('name', fieldnames(value))) ) % name field
                    error(msg); 
                end
                
                if ( any(ismember('properties', fieldnames(value))) ) % properties field
                    if ( ~ isa(value.properties, 'containers.Map') ) % properties map
                        error(msg);
                    
                    end
                    
                    % must be string name/value pairs
                    if ( ~ strcmp(value.properties.KeyType, 'char') || ... 
                         ~ strcmp(value.properties.ValueType, 'char') )
                        error(msg);
                        
                    end
                end
                sysmeta.mediaType = value;
                import org.dataone.service.types.v2.MediaType;
                import org.dataone.service.types.v2.MediaTypeProperty;
                mType = MediaType();
                mType.setName(char(sysmeta.mediaType.name));
                
                if ( any(ismember('properties', fieldnames(value))) ) % any properties?
                    propKeys = keys(sysmeta.mediaType.properties);
                    for i = 1:length(propKeys)
                        mTypeProperty = MediaTypeProperty();
                        mTypeProperty.setName(char(propKeys(i)));
                        mTypeProperty.setValue( ...
                            sysmeta.mediaType.properties(char(propKeys(i))));
                        mType.addProperty(mTypeProperty);
                    end
                end
                
                sysmeta.systemMetadata.setMediaType(mType);
            end

            if strcmp(property, 'fileName')
                % Validate the fileName string
                if ( ~ ischar(value) || isempty(value))
                    error(['The SystemMetadata.fileName property ' ...
                        'must be a string.']);
                end
                sysmeta.fileName = value;
                sysmeta.systemMetadata.setFileName(sysmeta.fileName);
                
            end

        end
       
        function xml = toXML(sysmeta)
            % TOXML serializes the system metadata to XML
            import org.dataone.service.util.TypeMarshaller;
            import java.io.ByteArrayOutputStream;
            import java.nio.charset.StandardCharsets;
            baos = ByteArrayOutputStream;
            TypeMarshaller.marshalTypeToOutputStream(sysmeta.systemMetadata, baos);
            xml = char(baos.toString(StandardCharsets.UTF_8.toString()));
            
        end

        function java_system_metadata = toJavaSysMetaV2(sysmeta)
            % Returns the system metadata as a Java SystemMetadata V2
            % object
            
            java_system_metadata = sysmeta.systemMetadata;
            
        end
    end
 
    methods (Static)
        
        function sysmeta = fromJavaSysMetaV2(systemMetadataV2)
            % FROMSYSMETAV2 converts a Java SystemMetadata V2 object to Matlab
            
            import org.dataone.client.v2.SystemMetadata;
            sysmeta = SystemMetadata();
            
            % Set the serialVersion from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getSerialVersion()) )
                set(sysmeta, 'serialVersion', ...
                    systemMetadataV2.getSerialVersion().doubleValue());
                
            end
            
            % Set the identifier property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getIdentifier()) )
                set(sysmeta, 'identifier', char(systemMetadataV2.getIdentifier().getValue()));
                
            end
            
            % Set the formatId property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getFormatId()) )
                set(sysmeta, 'formatId', ...
                    char(systemMetadataV2.getFormatId().getValue()));
                
            end
            
            % Set the size property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getSize()) )
                set(sysmeta, 'size', systemMetadataV2.getSize().doubleValue());
                
            end
            
            % Set the checksum property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getChecksum()) )
                if ( ~ isempty(systemMetadataV2.getChecksum().getValue()) && ...
                     ~ isempty(systemMetadataV2.getChecksum().getAlgorithm())   )
                    chksum.value = char(systemMetadataV2.getChecksum().getValue());
                    chksum.algorithm = char(systemMetadataV2.getChecksum().getAlgorithm());
                    set(sysmeta, 'checksum', chksum);
                    
                end
            end
            
            % Set the submitter property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getSubmitter()) )
                set(sysmeta, 'submitter', ...
                    char(systemMetadataV2.getSubmitter().getValue()));
                
            end
            
            % Set the rightsHolder property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getRightsHolder()) )
                set(sysmeta, 'rightsHolder', ...
                    char(systemMetadataV2.getRightsHolder().getValue()));
                
            end
            
            % Set the accessPolicy property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getAccessPolicy()) )
                
                % The map used to store the access policy rules in matlab
                mAccessPolicy.rules = containers.Map('KeyType', 'char', 'ValueType', 'char');
                
                jPolicy = systemMetadataV2.getAccessPolicy();
                if ( double(jPolicy.sizeAllowList()) > 0 )
                    % For each access rule
                    for i = 0:double(jPolicy.sizeAllowList() - 1)
                        jRule = jPolicy.getAllow(i);
                        
                        % For each subject in the rule
                        for j = 0:double(jRule.sizeSubjectList() - 1)
                            subj = char(jRule.getSubject(j).getValue());
                            
                            % For each permission in the rule
                            for k = 0:double(jRule.sizePermissionList() - 1)
                                perm = char(jRule.getPermission(k));
                                
                                % Populate the Matlab access policy rules map
                                mAccessPolicy.rules(subj) = perm;
                                
                            end
                        end
                    end
                end
                set(sysmeta, 'accessPolicy', mAccessPolicy);
            
            end
            
            % Set the accessPolicy from the Java SystemMetadata V2 object
            replPolicy = systemMetadataV2.getReplicationPolicy();
            if ( ~ isempty(replPolicy) )
                
                % Replicas allowed?
                if ( ~ isempty(replPolicy().getReplicationAllowed()) )
                    replicationPolicy.replicationAllowed = ...
                        replPolicy().getReplicationAllowed().booleanValue();

                end
                
                % How many?
                if ( ~ isempty(replPolicy().getNumberReplicas()) )
                    replicationPolicy.numberOfReplicas  = ...
                        replPolicy().getNumberReplicas().intValue();
                    
                end
                
                % Any preferred nodes?
                if ( replPolicy().sizePreferredMemberNodeList() > 0 )
                    for i = 0:replPolicy().sizePreferredMemberNodeList() - 1
                        node_id = char(replPolicy.getPreferredMemberNode(i).getValue);
                        replicationPolicy.preferredNodes{i + 1} = node_id;
                        
                    end
                end
                
                % Any blocked nodes?
                if ( replPolicy().sizeBlockedMemberNodeList() > 0 )
                    for i = 0:replPolicy().sizeBlockedMemberNodeList() - 1
                        node_id = char(replPolicy.getBlockedMemberNode(i).getValue);
                        replicationPolicy.blockedNodes{i + 1} = node_id;
                        
                    end
                end
                set(sysmeta, 'replicationPolicy', replicationPolicy);

            end
            
            
            % Set the obsoletes property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getObsoletes()) )
                set(sysmeta, 'obsoletes', ....
                    char(systemMetadataV2.getObsoletes().getValue()));
                
            end
            
            % Set the obsoletedBy property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getObsoletedBy()) )
                set(sysmeta, 'obsoletedBy', ...
                    char(systemMetadataV2.getObsoletedBy().getValue()));
                
            end
            
            % Set the archived property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getArchived()) )
                set(sysmeta, 'archived', ...
                    systemMetadataV2.getArchived().booleanValue());
                
            end
            
            % Set the dateUploaded property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getDateUploaded()) )
                j_formatter = java.text.SimpleDateFormat('yyyy-MM-dd HH:mm:ss.SSSZ');
                j_formatter.setTimeZone(java.util.TimeZone.getTimeZone('UTC'));
                date_uploaded_str = ...
                    char(j_formatter.format(systemMetadataV2.getDateUploaded()));
                date_uploaded = datetime( ...
                    date_uploaded_str, ...
                    'TimeZone', 'UTC', ...
                    'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSZ');
                set(sysmeta, 'dateUploaded', date_uploaded);
            end
            
            % Set the dateSysMetadataModified property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getDateSysMetadataModified()) )
                j_formatter = java.text.SimpleDateFormat('yyyy-MM-dd HH:mm:ss.SSSZ');
                j_formatter.setTimeZone(java.util.TimeZone.getTimeZone('UTC'));
                date_modified_str = ...
                    char(j_formatter.format(systemMetadataV2.getDateSysMetadataModified()));
                date_modified = datetime( ...
                    date_modified_str, ...
                    'TimeZone', 'UTC', ...
                    'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSSZ');
                set(sysmeta, 'dateSysMetadataModified', date_modified);
            end
            
            % Set the originMemberNode property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getOriginMemberNode()) )
                set(sysmeta, 'originMemberNode', ...
                    char(systemMetadataV2.getOriginMemberNode().getValue()));
            end
            
            % Set the authoritativeMemberNode property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getAuthoritativeMemberNode()) )
                set(sysmeta, 'authoritativeMemberNode', ...
                    char(systemMetadataV2.getAuthoritativeMemberNode().getValue()));
            end
                        
            % Set the replica property from the Java SystemMetadata V2 object
            % set(sysmeta, 'replica', char(systemMetadataV2.getSerialVersion));
            
            % Set the seriesId property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getSeriesId()) )
                set(sysmeta, 'seriesId', char(systemMetadataV2.getSeriesId()));
                
            end
            
            % Set the mediaType property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getMediaType()) )
                j_media_type = systemMetadataV2.getMediaType();
                mediaType.name = char(j_media_type.getName());
                
                % Any media type properties?
                if ( j_media_type.sizePropertyList() > 0 )
                    mediaType.properties = ...
                        containers.Map('KeyType', 'char', 'ValueType', 'char');
                    for i = 0:j_media_type.sizePropertyList() - 1
                        prop_name = char(j_media_type.getProperty(i).getName());
                        prop_value = char(j_media_type.getProperty(i).getValue());
                        mediaType.properties(prop_name) = prop_value;
                    end
                end
                set(sysmeta, 'mediaType', mediaType);
                
            end
            
            % Set the fileName property from the Java SystemMetadata V2 object
            if ( ~ isempty(systemMetadataV2.getFileName()) )
                set(sysmeta, 'fileName', char(systemMetadataV2.getFileName()));
                
            end
            
        end
        
    end
    
    methods (Access = 'private')
        
        function sysmeta = populateFromConfig(sysmeta)
            % POPULATEFROMCONFIG updates the system metadata object from
            % the user configuration
            
            % Pull in user-defined configuration options
            import org.dataone.client.configure.Configuration;
            sysmeta.config = Configuration.loadConfig('');
            
            if ( ~ isempty(sysmeta.config.target_member_node_id) )
                % Set the MN value in system metadata
                set(sysmeta, 'originMemberNode', ...
                    sysmeta.config.target_member_node_id);
                set(sysmeta, 'authoritativeMemberNode', ...
                    sysmeta.config.target_member_node_id);
                
            end
            
            if ( ~ isempty(sysmeta.config.format_id) )
                % Set the format id value in system metadata
                set(sysmeta, 'formatId', sysmeta.config.format_id);
                
            end
            
            if ( ~ isempty(sysmeta.config.submitter) )
                % Set the submitter value in system metadata
                set(sysmeta, 'submitter', sysmeta.config.submitter);
                
            end
            
            if ( ~ isempty(sysmeta.config.rights_holder) )
                % Set the rights holder value in system metadata
                set(sysmeta, 'rightsHolder', sysmeta.config.submitter);
            end
            
            if ( ~ isempty(sysmeta.config.public_read_allowed) )
                % Set the value in system metadata
                accessPolicy.rules = ...
                    containers.Map('KeyType', 'char', 'ValueType', 'char');
                accessPolicy.rules('public') = 'read';
                set(sysmeta, 'accessPolicy', accessPolicy);
                
            end
            
            if ( ~ isempty(sysmeta.config.replication_allowed) && ...
                 ~ isempty(sysmeta.config.number_of_replicas) && ...
                 sysmeta.config.replication_allowed )
                % Set the replication policy value in system metadata
                replicationPolicy.replicationAllowed = ...
                    sysmeta.config.replication_allowed;
                replicationPolicy.numberOfReplicas = ...
                    sysmeta.config.number_of_replicas;
                
                if ( ~ isempty(sysmeta.config.preferred_replica_node_list) && ...
                        iscellstr(sysmeta.config.preferred_replica_node_list) )
                    % Set the preferred MN listvalue in system metadata
                    replicationPolicy.preferredNodes = ...
                        sysmeta.config.preferred_replica_node_list;
                    
                end
                
                if ( ~ isempty(sysmeta.config.blocked_replica_node_list) && ...
                        iscellstr(sysmeta.config.blocked_replica_node_list) )
                    % Set the value in system metadata
                    replicationPolicy.blockedNodes = ...
                        sysmeta.config.blocked_replica_node_list;
                    
                end
                
                set(sysmeta, 'replicationPolicy', replicationPolicy);
                
            end
                                    
            if ( ~ isempty(sysmeta.config.certificate_path) )
                % Set the submitter and rights holder value in system metadata
                import org.dataone.client.auth.CertificateManager;
                import javax.servlet.http.HttpServletRequest;
                
                x509Cert = CertificateManager.getInstance().loadCertificateFromFile( ...
                    sysmeta.config.certificate_path);
                dn = CertificateManager.getInstance().getSubjectDN(x509Cert);
                set(sysmeta, 'submitter', char(dn));
                set(sysmeta, 'rightsHolder', char(dn));
                
            end
        end
    end
end

