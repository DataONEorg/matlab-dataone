% SESSION A class used to set configuration options for the DataONE Toolbox
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2009-2014 DataONE
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

classdef Session < hgsetget %& dynamicprops 
    % SESSION A class that stores configuration settings for script runs managed through the RunManager 
    
    properties
        
        debug = true; % A boolean property that enables or disables debugging  
        
        % Operating system config
        account_name = ''; % The OS account username
      
        % Science metadata config
        scimeta_template_path = ''; % The file system path to a science metadata template file
        scimeta_title = ''; % The title of the dataset being described
        sciemta_abstract = ''; % The abstract of the dataset being described
               
        % DataONE config
        member_node_base_url = ''; % The base URL of the DataONE member node server used to store and retrieve files
        coordinating_node_base_url = ''; % The base URL of the DataONE coordinating node server
        format_id = 'application/octet-stream'; % The default object format identifier when creating system metadata and uploading files to a member node. 
        submitter = ''; % The DataONE subject DN string of account uploading the file to the member node
        rights_holder = ''; % The DataONE subject DN string of account with read/write/change permissions for the file being uploaded
        public_read_allowed = true; % allow public read access to uploaded fiels (default: true)
        replication_allowed = ''; % allow replicattion of files to preserve the integrity of the data file over time
        number_of_replicas = 0; % The desired number of replicas of each file uploaded to the DataONE network
        preferred_replica_node_list = ''; % A comma-separated list of member node identifiers that are preferred for replica storage
        blocked_replica_node_list = ''; % A comma-separated list of member node identifiers that are blocked from replica storage
                
        % Identity config
        orcid_identifier = ''; % The researcher's ORCID
        subject_dn = ''; % The researcher's DataONE subject as a distinguished name string
        certificate_path = ''; %The absolute file system path to the X509 certificate downloaded from https://cilogon.org
        foaf_name = ''; % The friend of a friend 'name' vocabulary term
               
        % Provenance capture config
        provenance_storage_directory = '~/.d1/provenance'; % The directory used to store per execution provenance information
        capture_file_reads = true; % A flag indicating whether to trigger provenance capture for file read
        capture_file_writes = true; % A flag indicating whether to trigger provenance capture for file write
        capture_dataone_reads = true; % A flag indicating whether to trigger provenance capture for reading from DataONe MNRead.get()
        capture_dataone_writes = true; % A flag indicating whether to trigger provenance capture for writing with DataONE MNStorage.create() or MNStorage.update()
        capture_yesworkflow_comments = true; % A flag indicating whether to trigger provenance capture for YesWorkflow inline comments
                     
    end

    methods
        
        function self = Session()
            % SESSION A class used to set configuration options for the DataONE Toolbox  
        end
        
        function obj = set(obj, name, value)
            % SET A method used to set multiple properties at the same time
            paraName = strtrim((name));
            switch paraName
                case {'member_node_base_url', 'coordinating_node_base_url'}
                    try
                        url = java.net.URL(paraName) % Store or save the URL contents here                           
                    catch ME
                        ME
                    end
                    
                    obj.(name) = value;
                    
                otherwise
                    obj.(name) = value;
            end
        end
        
        function val = get(obj,name)
            % GET A method used to get the value of multiple properties
            val = obj.(name);            
        end
        
    end
    
end
