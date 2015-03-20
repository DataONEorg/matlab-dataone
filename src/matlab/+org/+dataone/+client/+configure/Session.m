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
        source_member_node_id  = 'urn:node:'; % The source member node identifier
        target_member_node_id = 'urn:node:'; % The target member node identifier
        format_id = 'application/octet-stream'; % The default object format identifier when creating system metadata and uploading files to a member node. 
        submitter = ''; % The DataONE subject DN string of account uploading the file to the member node
        rights_holder = ''; % The DataONE subject DN string of account with read/write/change permissions for the file being uploaded
        public_read_allowed = true; % allow public read access to uploaded fiels (default: true)
        replication_allowed = ''; % allow replicattion of files to preserve the integrity of the data file over time
        number_of_replicas = 0; % The desired number of replicas of each file uploaded to the DataONE network
        preferred_replica_node_list = ''; % A comma-separated list of member node identifiers that are preferred for replica storage
        blocked_replica_node_list = ''; % A comma-separated list of member node identifiers that are blocked from replica storage
        coordinating_node_base_url = 'https://cn-sandbox-2.test.dataone.org/cn'; % The base URL of the DataONE coordinating node server
        
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
        
        % Session storage config
        persistent_session_file_name = ''; % The directory used to store persistent session file Eg: $HOME/.d1/session.json
    end

    methods(Static)
        
    end
    
    methods
        
        function session = Session()
            % SESSION A class used to set configuration options for the DataONE Toolbox  
            
            % Find path for persistent_session_file_name
            if ispc
                session.persistent_session_file_name = fullfile(getenv('userprofile'), filesep, '.d1', filesep, 'session.json');  
                if session.debug  
                    disp(session.persistent_session_file_name);
                end
            elseif isunix
                session.persistent_session_file_name = strcat(getenv('HOME'), filesep, '.d1', filesep, 'session.json');
                if session.debug  % self.debug ??
                    disp(session.persistent_session_file_name);
                end
            else
                error('Current platform not supported.');
            end
            
            % Call loadSession() with the default path location to the
            % session file on disk
            loadSession(session,'');
            
        end
        
        %-------------------------------------------------------------------------------------------
        function session = set(session, name, value)
            % SET A method used to set one property at a time
            paraName = strtrim((name));
            
            % Validate the value of number_of_replicas field
            if strcmp(paraName, 'number_of_replicas') && mod(value,1) ~= 0
                sprintf('Value must be an integer for %s', paraName);
                error('SessionError:IntegerRequired', 'number_of_replicas value must be integer.');
            end                
                     
            if strcmp(paraName, 'source_member_node_id') || strcmp(paraName, 'target_member_node_id')
                if ~strncmpi(value, 'urn:node:', 9)
                    error('SessionError:mnIdentifier', 'identifier for member node must start with urn:node:');
                end
            end
            
            % Validate the value of provenance_storage_directory
            if strcmp(paraName, 'provenance_storage_directory')
                if ispc
                    home_dir = getenv('userfrofile');
                elseif isunix
                    home_dir = getenv('HOME');
                else
                    error('Current platform not supported.');
                end
                
                absolute_prov_storage_dir = strcat(home_dir, filesep, '.d1', filesep, 'provenance');
                
                if isunix && strncmpi(value, '~/', 2)
                    translate_absolute_path = strcat(home_dir ,value(2:end));
                    if ~strcmp(absolute_prov_storage_dir, translate_absolute_path)
                        error('SessionError:provenance_storage_directory', 'provenance storage directory must be $home/.d1/provenance');
                    end 
                else
                    if ~strcmp(absolute_prov_storage_dir, value)
                       error('SessionError:provenance_storage_directory', 'provenance storage directory must be $home/.d1/provenance'); 
                    end
                end
            end           
            
            % Validate the value of format_id
            if strcmp(paraName, 'format_id')
               
                import org.dataone.client.v2.formats.ObjectFormatCache;
                import org.dataone.configuration.Settings;
                
                cn_base_url = 'https://cn-sandbox-2.test.dataone.org/cn';
                Settings.getConfiguration.setProperty('D1Client.CN_URL', cn_base_url);
                fmtList = ObjectFormatCache.getInstance.listFormats;
                size = fmtList.getObjectFormatList.size;
                
                found = false;
                for i = 1:size
                    fmt = fmtList.getObjectFormatList.get(i-1);
                    if strcmp(value, char(fmt.getFormatId.getValue))
                        found = true;
                        break;
                    end                    
                end 
                
                if found ~= 1
                    error('SessionError:format_id', 'format_id should use ObjectFormat.');
                end
            
                if session.debug  
                    % to display each element in the format list                    
                    fprintf('\nLength=%d \n', size);
                    for i = 1:size
                        fmt = fmtList.getObjectFormatList.get(i-1);
               
                        fprintf('%s %s %s \n',char(fmt.getFormatType), char(fmt.getFormatId.getValue), char(fmt.getFormatName));
                        i = i+1;
                    end    
                end    
            end
            
            % Set value of a field
            session.(paraName) = value;
            session.saveSession();
        end
        
        %-------------------------------------------------------------------------------------------
        function val = get(session,name)
            % GET A method used to get the value of a property
            paraName = strtrim((name));
            val = session.(paraName);            
        end
        
        %-------------------------------------------------------------------------------------------
        function session = saveSession(session)
            % SAVESESSION 
           
            % Convert session object to session struct
            sessionProps = properties(session); % displays the names of the public properties for the class of session
            
            pvals = cell(1, length(sessionProps));
            for i = 1:length(sessionProps)
               % To do: check the type of sessionProps{i}
               pvals{i} = session.get(sessionProps{i});
            end
 
            arglist = {sessionProps{:};pvals{:}};
            sessionStruct = struct(arglist{:});
            
         %  savejson('session', sessionStruct, session.persistent_session_file_name);   
            savejson('', sessionStruct, session.persistent_session_file_name);
        end
        
        %-------------------------------------------------------------------------------------------
        function session = loadSession(session, filename)
            % LOADSESSION  
            
            % Get persistent session file path
            if strcmp(filename, '')
                % Create a default persistent session directory if one isn't
                % passed in
                if ispc
                    default_session_storage_directory = getenv('userprofile');
                elseif isunix
                    default_session_storage_directory = getenv('HOME');                  
                else
                    error('Current platform not supported.');
                end
                
                % Check if .d1 directory exists; create it if not 
                if exist(fullfile(default_session_storage_directory, strcat(filesep, '.d1')), 'dir') == 0
                    cd(default_session_storage_directory);
                    [status, message, message_id] = mkdir('.d1');
                    
                    if ( status ~= 1 )
                        error(message_id, [ 'The directory .d1' ...
                              ' could not be created. The error message' ...
                              ' was: ' message]);
                    end                        
                end
                
                % Check if session.json file exists under $HOME/.d1 directory 
                % (for linux) or $userprofile/.d1 directory (for windows); create it if not
                session_file_absolute_path = fullfile(default_session_storage_directory, filesep, '.d1', filesep, 'session.json');
               
                if exist(session_file_absolute_path, 'file') == 0
                    % The session.json does not exist under the default directory
                    % Create an empty session.json here. 
                    fid = fopen(session_file_absolute_path, 'w'); % fclose() after use it no memory leak
                    
                    if session.debug 
                        fprintf('\nCreate a new and empty session.json %s\n\n', session_file_absolute_path);
                    end
                    
                    % Save defaul session object in session.json 
                    session.saveSession();
                    
                    % To do: close file ?
                    fclose(fid);
                    
                    return;
                else
                    % The session.json exists under the default directory
                    sessionStruct = loadjson(session.persistent_session_file_name); %?? populate obj using objStruct
                    
                    % Convert session struct to session object
                    fnames = fieldnames(sessionStruct);                    
                    for i = 1:size(fnames)                       
                       val =  getfield(sessionStruct,fnames{i});
                       session.set(fnames{i}, val);
                    end               
                end
            else
                % The session.json exists under the user-specified directory
                session.persistent_session_file_name = filename;
                % Load session data from one's specified path 
                sessionStruct = loadjson(session.persistent_session_file_name); %???  populate obj using objStruct
                
                 % Convert session struct to session object
                fnames = fieldnames(sessionStruct);
                for i = 1:size(fnames)                       
                    val =  getfield(sessionStruct,fnames{i});
                    session.set(fnames{i}, val);
                end             
            end
                                    
            % Save session object to disk in a JSON format
          % savejson('session', sessionStruct, session.persistent_session_file_name); % double check the file path location ??
            savejson('', sessionStruct, session.persistent_session_file_name); 
         end    
        
        %-------------------------------------------------------------------------------------------
        function listSession()
            % LISTSESSION  
        end
       
    end
    
end
