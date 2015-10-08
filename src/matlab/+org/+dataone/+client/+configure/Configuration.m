% CONFIGURATION A class used to set configuration options for the DataONE Toolbox
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

classdef Configuration < hgsetget & dynamicprops 
    % CONFIGURATION A class that stores configuration settings for script runs managed through the RunManager 
    
    properties     
        % The Operating System account username
        account_name = '';
      
        % The source member node identifier
        source_member_node_id  = 'urn:node:XXXX';
        
        % The target member node identifier
        target_member_node_id = 'urn:node:XXXX';
        
        % The default object format identifier when creating system metadata and uploading files to a member node. 
        format_id = 'application/octet-stream';
        
        % The DataONE subject DN string of account uploading the file to the member node
        submitter = '';
        
        % The DataONE subject DN string of account with read/write/change permissions for the file being uploaded
        rights_holder = '';
        
        % Allow public read access to uploaded fiels (default: true)
        public_read_allowed = true;
        
        % Allow replicattion of files to preserve the integrity of the data file over time
        replication_allowed = true;
        
        % The desired number of replicas of each file uploaded to the DataONE network
        number_of_replicas = 2;
        
        % A comma-separated list of member node identifiers that are preferred for replica storage
        preferred_replica_node_list = '';
        
        % A comma-separated list of member node identifiers that are blocked from replica storage
        blocked_replica_node_list = '';
        
        % The base URL of the DataONE coordinating node server
        coordinating_node_base_url = 'https://cn-dev.test.dataone.org/cn';
        
        % The researcher's ORCID
        orcid_identifier = '';
        
        % The researcher's DataONE subject as a distinguished name string
        subject_dn = '';
        
        % The absolute file system path to the X509 certificate downloaded from https://cilogon.org
        certificate_path = '';
        
        % The friend of a friend 'name' vocabulary term
        foaf_name = '';
               
        % The directory used to store per execution provenance information
        provenance_storage_directory = '~/.d1/provenance';
        
        % A flag indicating whether to trigger provenance capture for file read
        capture_file_reads = true;
        
        % A flag indicating whether to trigger provenance capture for file write
        capture_file_writes = true;
                
        % A flag indicating whether to trigger provenance capture for YesWorkflow inline comments
        capture_yesworkflow_comments = true;
        
        % The directory used to store persistent configuration file Eg: $HOME/.d1/configuration.json
        persistent_configuration_file_name = '';
        
        % YesWorkflow configuration
        
        % A flag indicating whether to generate the graphic
        generate_workflow_graphic = true;
        
        % A flag indicating whether to include the workflow graphic as an object in the DataPackage
        include_workflow_graphic = true;
        
        % A script base name will be used to name yesWorkflow artifacts.
        script_base_name = '';
        
        % A token string used to store authentication information (to be verified with Chris May-31-2015)
        authentication_token = '';
        
        % The science metadata template file location
        science_metadata_template_file = '';
     
        % The science metadata configuration instance for the run
        science_metadata_config;

        % The directory of the installed Matlab DataONE Toolbox
        matlab_dataone_toolbox_directory = '';
                
        % A boolean property that enables or disables debugging 
        debug = false; 
    end
    
    methods
        
        function configuration = Configuration()
            % CONFIGURATION A class used to set configuration options for the DataONE Toolbox  
            
            setMatlabDataONEToolboxDirectory(configuration);
            setCoordinatingNodeURL(configuration);
            setPersistentConfigFile(configuration);
            setAccountName(configuration);
            setMetadataTemplateFile(configuration);
            
        end
        
        function configuration = set(configuration, name, value)
            % SET A method used to set one property at a time
            paraName = strtrim((name));
            
            % Validate the value of number_of_replicas field
            if strcmp(paraName, 'number_of_replicas') && mod(value,1) ~= 0
                sprintf('Value must be an integer for %s', paraName);
                error('ConfigurationError:IntegerRequired', 'number_of_replicas value must be integer.');
            end                
                     
            if strcmp(paraName, 'source_member_node_id') || strcmp(paraName, 'target_member_node_id')
                if ~strncmpi(value, 'urn:node:', 9)
                    error('ConfigurationError:mnIdentifier', 'identifier for member node must start with urn:node:');
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
                        error('ConfigurationError:provenance_storage_directory', 'provenance storage directory must be $home/.d1/provenance');
                    end 
                else
                    if ~strcmp(absolute_prov_storage_dir, value)
                       error('ConfigurationError:provenance_storage_directory', 'provenance storage directory must be $home/.d1/provenance'); 
                    end
                end
                
                provenance_storage_directory = absolute_prov_storage_dir;
            end           
            
            % Validate the value of format_id
            if strcmp(paraName, 'format_id')
               
                import org.dataone.client.v2.formats.ObjectFormatCache;
                import org.dataone.service.types.v1.ObjectFormatIdentifier;
           
                objFmtId = ObjectFormatIdentifier();
                objFmtId.setValue(value);
                                
                ofc = ObjectFormatCache.getInstance();
                objFmt = ofc.getFormat(objFmtId);
                if isempty(objFmt) == 1
                   error('ConfigurationError:format_id', 'format_id should use ObjectFormat.');
                end
                
                size = ofc.listFormats().sizeObjectFormatList();
                if configuration.debug
                    disp(configuration.debug);
                    fprintf('objectFormatList.size=%d\n', size);
                end
            end
            
            if strcmp(paraName, 'authentication_token')
                warning('Configuration:SecurityReminder', ...
                    ['Your authentication token has been set in your configuration file. \n' ...
                    'Please be careful to safeguard this token.\n' ...
                    'Anyone with access to it can call operations as you. \n' ...
                    'Be careful to not add this token to any published scripts, \n' ...
                    'but rather set it only using a command prompt. This \n' ...
                    'token will expire at {add the expiration time from the token here}.\n' ...
                    'Please log in again and set the token again after it expires.']);
            end
            
            % Set value of a field
            configuration.(paraName) = value;            
            configuration.saveConfig();
        end
        
        function val = get(configuration,name)
            % GET A method used to get the value of a property
            paraName = strtrim((name));
            val = configuration.(paraName);            
        end
        
        function configuration = saveConfig(configuration)
            % SAVECONFIG Saves the configuration properties to a JSON file
            
            % Convert configuration object to configuration struct
            configurationProps = properties(configuration); % displays the names of the public properties for the class of configuration
            
            pvals = cell(1, length(configurationProps));
            for i = 1:length(configurationProps)
               % To do: check the type of configurationProps{i}
               pvals{i} = configuration.get(configurationProps{i});
            end
 
            arglist = {configurationProps{:};pvals{:}};
            configurationStruct = struct(arglist{:});
            
         %  savejson('configuration', configurationStruct, configuration.persistent_configuration_file_name);   
            savejson('', configurationStruct, configuration.persistent_configuration_file_name);
        end
        
        function configuration = loadConfig(configuration, filename)
            % LOADCONFIG  
            
            % Get persistent configuration file path
            if strcmp(filename, '')
                % Create a default persistent configuration directory if one isn't
                % passed in
                if ispc
                    default_configuration_storage_directory = getenv('userprofile');
                elseif isunix
                    default_configuration_storage_directory = getenv('HOME');                  
                else
                    error('Current platform not supported.');
                end
                
                % Check if .d1 directory exists; create it if not 
                if exist(fullfile(default_configuration_storage_directory, strcat(filesep, '.d1')), 'dir') == 0
                    cd(default_configuration_storage_directory);
                    [status, message, message_id] = mkdir('.d1');
                    
                    if ( status ~= 1 )
                        error(message_id, [ 'The directory .d1' ...
                              ' could not be created. The error message' ...
                              ' was: ' message]);
                    end                        
                end
                
                % Check if configuration.json file exists under $HOME/.d1 directory 
                % (for linux) or $userprofile/.d1 directory (for windows); create it if not
                configuration_file_absolute_path = ...
                    fullfile(default_configuration_storage_directory, ...
                             filesep, '.d1', filesep, 'configuration.json');
               
                if exist(configuration_file_absolute_path, 'file') == 0
                    % The configuration.json does not exist under the default directory
                    % Create an empty configuration.json here.             
                    if configuration.debug == 1
                        fprintf('\nCreate a new and empty configuration.json at %s.', ...
                            configuration_file_absolute_path);
                    end
                    
                    % Save default configuration object in configuration.json 
                    % Not necessary to explicit an empty file.
                    configuration.saveConfig();
                    return;
                else
                    % The configuration.json exists under the default directory
                    configurationStruct = loadjson(configuration.persistent_configuration_file_name);
                    
                    % Convert configuration struct to configuration object ***
                    fnames = fieldnames(configurationStruct);                    
                    for i = 1:size(fnames)                       
                       val =  getfield(configurationStruct,fnames{i});
                       
                       try
                           % assign instance property value directy and not call set()
                           configuration.(fnames{i}) = val;
                       catch noPublicfieldError
                           if ( configuration.debug )
                               warning(noPublicfieldError.message)
                           end
                           
                           % Add an instance property instead
                           addprop(configuration, fnames{i});
                           configuration.(fnames{i}) = val;
                       end
                    end               
                end
            else
                % The configuration.json exists under the user-specified directory
                configuration.persistent_configuration_file_name = filename;
                % Load configuration data from one's specified path 
                configurationStruct = loadjson(configuration.persistent_configuration_file_name); %???  populate obj using objStruct
                
                 % Convert configuration struct to configuration object
                fnames = fieldnames(configurationStruct);
                for i = 1:size(fnames)                       
                    val =  getfield(configurationStruct,fnames{i});
                   %configuration.set(fnames{i}, val);
                   configuration.(fnames{i}) = val; % assign instance property value directy and not call set()
                end
                
                % Save the configuration to the user-specified location
                configuration.saveConfig();

            end
                                    
            % Save configuration object to disk in a JSON format
          % savejson('configuration', configurationStruct, configuration.persistent_configuration_file_name); % double check the file path location ??
            savejson('', configurationStruct, configuration.persistent_configuration_file_name); 
         end    
        
        function listConfig(configuration, varargin)
            % LISTCONFIG  lists configuration properties and their values
            
            % Get each property name
            configurationProps = properties(configuration);
            
            % find the max legth of the longest property name
            for i = 1:length(configurationProps)
                propLengths(i) = length(char(configurationProps(i)));
            end            
            maxLength = max(propLengths);
            
            format = ['%' num2str(maxLength) 's: %s\n'];

            propName = '';
            propValue = '';
            
            % Print a list of all properties
            for i = 1:length(configurationProps)
                propName = char(configurationProps{i});
                if ( ~isempty(configuration.get(configurationProps{i})) )
                    propValue = configuration.get(configurationProps{i});
                    if ( isnumeric(propValue) )
                        propValue = num2str(propValue);
                    end
                end
                fprintf(format, propName, propValue);
                propName = ''; propValue = '';
            end            
        end      
    end  
    
    methods (Access='private')
        
        function setPersistentConfigFile(configuration)
        % SETPERSISTENTCONFIGFILE set the path to the persistent configuration file.
                        % Find path for persistent_configuration_file_name
            if ispc
                configuration.persistent_configuration_file_name = ...
                    fullfile(getenv('userprofile'), filesep, ...
                    '.d1', filesep, 'configuration.json');  
            elseif isunix
                configuration.persistent_configuration_file_name = ...
                    fullfile(getenv('HOME'), filesep, '.d1', ...
                    filesep, 'configuration.json');
            else
                error('Current platform not supported.');
            end
            
            % Call loadConfig() with the default path location to the
            % configuration file on disk
            loadConfig(configuration,'');
            
        end
        
        function setMetadataTemplateFile(configuration)
        % SETMETADATATEMPLATEFILE sets the path to the science metadata template file.

            shipped_template_file_path = ...
                fullfile(configuration.matlab_dataone_toolbox_directory, ...
                    'lib', 'xml', 'templates', 'eml211', 'eml211-template.xml');
            default_template_file_path = ...
                fullfile(configuration.provenance_storage_directory, ...
                    'science_metadata_template.xml');
        
            % If the field is not set, set it and copy the default file
            if ( isempty(configuration.science_metadata_template_file) )                
                configuration.science_metadata_template_file = ...
                    default_template_file_path;
                
            end  
            
            % Now copy the template to the default location, backing up the original
            if ( exist(configuration.science_metadata_template_file, 'file') )
                copyfile(default_template_file_path, ...
                    [default_template_file_path '.bak']);
            end
            
            try
                copyfile(shipped_template_file_path, ...
                    configuration.science_metadata_template_file);
                if ( configuration.debug )
                    disp(['Copied ' shipped_template_file_path ' to ' ...
                        configuration.science_metadata_template_file]);
                end
                
            catch IOError
                error('Configuration:setMetadataTemplateFile', ...
                    ['Could not copy the science metadata template ' ...
                    'file from \n' shipped_template_file_path ' to \n' ...
                    configuration.science_metadata_template_file ...
                    '\nPlease check that the file exists and is readable.']);
            end

        end
        
        function setAccountName(configuration)
        % SETACCOUNTNAME sets the system account name in the configuration
            
            if ( isempty(configuration.account_name) )
                try
                    if ( ispc)
                        configuration.account_name = getenv('USERNAME');
                        
                    elseif ( isunix )
                        configuration.account_name = getenv('USER');
                        
                    end
                catch configurationError
                    if ( configuration.debug )
                        warn(['Could not set the user account name from ' ...
                             'the system environment variables: ' ...
                             configurationError.message]); 
                    end
                end
            end
        end
        
        function setCoordinatingNodeURL(configuration)
        % SETCOORDINATINGNODEURL sets the URL of the DataONE Coordinating Node
            
            import org.dataone.configuration.Settings;
            if ( ~isempty(configuration.coordinating_node_base_url) )
            Settings.getConfiguration().setProperty('D1Client.CN_URL', ...
                configuration.coordinating_node_base_url);
            else
                if ( configuration.debug )
                    warn(['The DataONE Coordinating Node configuration ' ...
                          'parameter is not set and is needed by the ' ...
                          'publish() function. Defaulting it to ' ...
                          'https://cn-dev.test.dataone.org/cn']);
                end

                configuration.coordinating_node_base_url = ...
                    'https://cn-dev.test.dataone.org/cn';
                Settings.getConfiguration().setProperty('D1Client.CN_URL', ...
                configuration.coordinating_node_base_url);

            end
        end
        
        function setMatlabDataONEToolboxDirectory(configuration)
        % SETMATLABDATAONETOOLBOXDIRECTORY sets the Matlab DataONE Toolbox directory path
            
            mpath = path;
            mpaths = strsplit(mpath, ':');
            indxs = strfind(mpaths, 'matlab-dataone');
            configuration.matlab_dataone_toolbox_directory = ...
                mpath(1:indxs{1} + 13); % Add the rest of the 'matlab-dataone' string
        end
    end
end
