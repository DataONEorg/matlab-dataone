
classdef ExecMetadata < hgsetget
    
    properties
        % A simple integer value associated with this execution Oct-20-2016
        seq;
        % The unique identifier for this execution
        executionId;
        % The unique identifier for the associated metadata object
        metadataId;       
        % The text string associated with this execution
        tag;         
        % The unique identifier for this execution that is meaningful for a user
        datapackageId;
        % The user name who ran this execution
        user;
        % The user identity who uploaded the package
        subject;
        % The host identifier to which the package was uploaded
        hostId;
        % The starting time of this execution
        startTime;
        % The operating system name 
        operatingSystem;
        % ???
        runtime;
        % ???
        softwareApplication;
        % The modules information used by the software application
        moduleDependencies;
        % The ending time of this execution
        endTime;
        % The error message captured during this execution
        errorMessage;
        % The timestamp that the data package for this execution was
        % uploaded to a repository
        publishTime;
        % The node name that the execution was published to
        publishNodeId;
        % The identifier for the uploaded data package
        publishId;
        % A logical variable that indicates whether this was a console
        % session
        console;
        % The execmetadata table name
        execTableName = 'execmeta';
        % The tags table name
        tagsTableName = 'tags';
    end
    
    methods (Static)
        
        function create_table_statement = createExecMetaTable(tableName)
            % CREATEEXECMETATABLE Creates an execution metadata table
            
            create_table_statement = ['create table if not exists ' tableName '('];
            create_table_statement = [create_table_statement ...
                'seq INTEGER PRIMARY KEY,' ...
                'executionId TEXT not null,' ...
                'metadataId TEXT,' ...
                'datapackageId TEXT,' ...
                'user TEXT,' ...
                'subject TEXT,' ...
                'hostId TEXT,' ...
                'startTime TEXT,' ...
                'operatingSystem TEXT,' ...
                'runtime TEXT,' ...
                'softwareApplication TEXT,' ...
                'moduleDependencies TEXT,' ...
                'endTime TEXT,' ...
                'errorMessage TEXT,' ...
                'publishTime TEXT,' ...
                'publishNodeId TEXT,' ...
                'publishId TEXT,' ...
                'console INTEGER,' ...
                'unique(executionId));']; 
        end
        
        function create_tag_table_statement = createTagTable(tableName)
            % Create a separate tag table 123116
            create_tag_table_statement = ['create table tags (' ...
                'seq INTEGER PRIMARY KEY,' ...
                'executionId TEXT not NULL,' ...
                'tag TEXT not NULL,' ...
                'unique(executionId, tag) ON CONFLICT IGNORE,' ...
                'foreign key (executionId) references execmeta(executionId) on delete cascade);'];
        end
        
        function readQuery = readExecMeta(execmetaObj, orderBy, sortOrder)
            % READEXECMETA Retrieves saved execution metadata
            % execmetaObj - a fileMetadata object or struct to be retrieved
            
            if isempty(execmetaObj) == 1
                % If the 'execmetaObj' doesn't exist yet, then there is
                % no execmetadata for read, so just return a blank string
                readQuery = [];
                return;
            end
            
            % Construct a SELECT statement to retrieve the runs that match
            % the specified search criteria
            select_statement = sprintf('SELECT * FROM %s e ', execmetaObj.tableName);
            where_clause = '';
            order_by_clause = '';
            
            % Process the orderBy clause
            if isempty(orderBy) ~= 1
                if ismember(lower(sortOrder), {'descending', 'desc'})
                    sortOrder = 'DESC';
                else
                    sortOrder = 'ASC';
                end
                order_by_clause = [' order by ', orderBy, sortOrder];
            end
            
            % Process the execMetadata object and construct the WHERE clause
            if isempty(execmetaObj) ~= 1
                
                row_executionId = execmetaObj.get('executionId');
                
                row_seq = execmetaObj.get('seq');
                if isempty(row_seq) ~= 1
                    match_clause = 'e.seq= ';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_seq);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_seq);
                    end
                end
                
                if isempty(row_executionId) ~= 1
                    match_clause = 'e.executionId=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_executionId);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_executionId);
                    end
                end
                
                row_metadataId = execmetaObj.get('metadataId');
                if isempty(row_metadataId) ~= 1
                    match_clause = 'e.metadataId=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_metadataId);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_metadataId);
                    end
                end
                                
                row_datapackageId = execmetaObj.get('datapackageId');
                if isempty(row_datapackageId) ~= 1
                    match_clause = 'e.datapackageId LIKE ';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_datapackageId);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_datapackageId);
                    end
                end
                
                row_user = execmetaObj.get('user');
                if isempty(row_user) ~= 1
                    match_clause = 'e.user=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_user);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_user);
                    end
                end
                
                row_subject = execmetaObj.get('subject');
                if isempty(row_subject) ~= 1
                    match_clause = 'e.subject=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_subject);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_subject);
                    end
                end
                
                row_hostId = execmetaObj.get('hostId');
                if isempty(row_hostId) ~= 1
                    match_clause = 'e.hostId=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_hostId);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_hostId);
                    end
                end
                
                row_startTime = execmetaObj.get('startTime');
                if isempty(row_startTime) ~= 1
                    match_clause = 'e.startTime=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_startTime);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_startTime);
                    end
                end
                
                row_operatingSystem = execmetaObj.get('operatingSystem');
                if isempty(row_operatingSystem) ~= 1
                    match_clause = 'e.operatingSystem=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_operatingSystem);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_operatingSystem);
                    end
                end
                
                row_runtime = execmetaObj.get('runtime');
                if isempty(row_runtime) ~= 1
                    match_clause = 'e.runtime=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_runtime);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_runtime);
                    end
                end
                
                row_softwareApplication = execmetaObj.get('softwareApplication');
                if isempty(row_softwareApplication) ~= 1
                    match_clause = 'e.softwareApplication=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_softwareApplication);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_softwareApplication);
                    end
                end
                
                row_moduleDependencies = execmetaObj.get('moduleDependencies');
                if isempty(row_moduleDependencies) ~= 1
                    match_clause = 'e.moduleDependencies=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_moduleDependencies);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_moduleDependencies);
                    end
                end
                
                row_endTime = execmetaObj.get('endTime');
                if isempty(row_endTime) ~= 1
                    match_clause = 'e.endTime=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_endTime);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_endTime);
                    end
                end
                
                row_errorMessage = execmetaObj.get('errorMessage');
                if isempty(row_errorMessage) ~= 1
                    match_clause = 'e.errorMessage=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_errorMessage);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_errorMessage);
                    end
                end
                
                row_publishTime = execmetaObj.get('publishTime');
                if isempty(row_publishTime) ~= 1
                    match_clause = 'e.publishTime=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_publishTime);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_publishTime);
                    end
                end
                
                row_publishNodeId = execmetaObj.get('publishNodeId');
                if isempty(row_publishNodeId) ~= 1
                    match_clause = 'e.publishNodeId=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_publishNodeId);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_publishNodeId);
                    end
                end
                
                row_publishId = execmetaObj.get('publishId');
                if isempty(row_publishId) ~= 1
                    match_clause = 'e.publishId=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%s" ', match_clause, row_publishId);
                    else
                        where_clause = sprintf('%s and %s "%s" ', where_clause, match_clause, row_publishId);
                    end
                end
                
                row_console = execmetaObj.get('console');
                if isempty(row_console) ~= 1
                    match_clause = 'e.console=';
                    if isempty(where_clause)
                        where_clause = sprintf('where %s "%d" ', match_clause, row_console);
                    else
                        where_clause = sprintf('%s and %s "%d" ', where_clause, match_clause, row_console);
                    end
                end
            end
            
            % Retrieve records that match search criteria
            select_statement = [select_statement, where_clause, order_by_clause, ';'];
            readQuery = select_statement;
        end
        
    end
    
    
    methods
        function this = ExecMetadata(varargin)
            % EXECMETADATA Constructor Initializes an execution metadata object
                        
            switch nargin
                case 1
                    this.seq = varargin{1}.execution_id
                    this.executionId = varargin{1}.execution_id;
                    this.metadataId = varargin{1}.metadata_id;
                    this.tag = varargin{1}.tag;
                    this.datapackageId = varargin{1}.datapackage_id;
                    this.user = varargin{1}.user;
                    this.subject = varargin{1}.subject;
                    this.hostId = varargin{1}.host_id;
                    this.startTime = varargin{1}.start_time;
                    this.operatingSystem = varargin{1}.operating_system;
                    this.runtime = varargin{1}.run_time;
                    this.softwareApplication = varargin{1}.software_application;
                    this.moduleDependencies = varargin{1}.module_dependencies;
                    this.endTime = varargin{1}.end_time;
                    this.errorMessage = varargin{1}.error_message;
                    this.publishTime = varargin{1}.publish_time;
                    this.publishNodeId = varargin{1}.publish_node_id;
                    this.publishId = varargin{1}.publish_id;
                    this.console = varargin{1}.console;
                    
                case 18
                    this.executionId = varargin{1};
                    this.metadataId = varargin{2};
                    this.tag = varargin{3};
                    this.datapackageId = varargin{4};
                    this.user = varargin{5};
                    this.subject = varargin{6};
                    this.hostId = varargin{7};
                    this.startTime = varargin{8};
                    this.operatingSystem = varargin{9};
                    this.runtime = varargin{10};
                    this.softwareApplication = varargin{11};
                    this.moduleDependencies = varargin{12};
                    this.endTime = varargin{13};
                    this.errorMessage = varargin{14};
                    this.publishTime = varargin{15};
                    this.publishNodeId = varargin{16};
                    this.publishId = varargin{17};
                    this.console = varargin{18};
                otherwise
                    throw(MException('ExecMetadata:error', 'invalid options'));
            end
        end
        
        function [insertExecQuery, insertTagQuery] = writeExecMeta(execMetadata)
            % WRITEEXECMETA Saves a single execution metadata
            
            execemeta_colnames = {'executionId', 'metadataId', ...
                'datapackageId', 'user', 'subject', 'hostId', 'startTime', ...
                'operatingSystem', 'runtime', 'softwareApplication', 'moduleDependencies', ...
                'endTime', 'errorMessage', 'publishTime', 'publishNodeId', 'publishId', 'console'};
            
            % **Updated to remove tag column 103116
            % Construct a SQL INSERT statement for fast insert to the
            % execmeta table
            data_row = cell(1, length(execemeta_colnames));
            for i = 1:length(execemeta_colnames)
                data_row{i} = execMetadata.get(execemeta_colnames{i});
            end
            
            insertExecMetaQuery = sprintf('insert into %s (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) values ', execMetadata.execTableName, execemeta_colnames{:});
            insertExecMetaQueryData = sprintf('("%s","%s","%s","%s","%s","%s","%s","%s","%s","%s","%s","%s","%s","%s","%s","%s",%d);', data_row{:});
            insertExecQuery = [insertExecMetaQuery, insertExecMetaQueryData];   
            
            % Construct a SQL INSERT statement for fast insert to the
            % tags table 103116
            tag_colnames = {'executionId', 'tag'};
            tag_data_row = cell(1, length(tag_colnames));
            for j = 1:length(tag_colnames)
                tag_data_row{j} = execMetadata.get(tag_colnames{j});
            end    
            
            insertTagQuery = sprintf('insert into %s (%s,%s) values ',  execMetadata.tagsTableName, tag_colnames{:});
            insertTagQueryData = sprintf('("%s","%s");', tag_data_row{:});
            insertTagQuery = [insertTagQuery, insertTagQueryData];
        end
         
        function updateQuery = updateExecMeta(this, varargin)
            % UPDATEEXECMETA Updates a single execution metadata object
            
            persistent updateExecMetaParser;
            if isempty(updateExecMetaParser)
                updateExecMetaParser = inputParser;
                
                addParameter(updateExecMetaParser,'executionId', '', @(x)(~isempty(x)&&ischar(x)));
                addParameter(updateExecMetaParser,'subject', '', @ischar);
                addParameter(updateExecMetaParser,'endTime', '', @ischar);
                addParameter(updateExecMetaParser,'errorMessage', '', @ischar);
                addParameter(updateExecMetaParser,'publishTime', '', @ischar);
                addParameter(updateExecMetaParser,'publishNodeId', '', @ischar);
                addParameter(updateExecMetaParser,'publishId', '', @ischar);
            end
            parse(updateExecMetaParser,varargin{:})
            
            row_executionId = updateExecMetaParser.Results.executionId;
            row_subject = updateExecMetaParser.Results.subject;
            row_endTime = updateExecMetaParser.Results.endTime;
            row_errorMessage = updateExecMetaParser.Results.errorMessage;
            row_publishTime = updateExecMetaParser.Results.publishTime;
            row_publishNodeId = updateExecMetaParser.Results.publishNodeId;
            row_publishId = updateExecMetaParser.Results.publishId;
                        
            % Construct an Update statement to update the execution metadata
            % entry for a specific run
            update_clause = sprintf('UPDATE %s', this.tableName); 
            set_clause = '';
            where_clause = sprintf('WHERE executionId=%s;', row_executionId);
            
            if isempty(row_subject) ~= 1
                if isempty(set_clause) ~= 1
                    set_clause = sprintf('%s, subject="%s"', set_clause, row_subject);
                else
                    set_clause = sprintf('SET subject="%s"', row_subject);
                end
            end
            
            if isempty(row_endTime) ~= 1
                if isempty(set_clause) ~= 1
                    set_clause = sprintf('%s, endTime="%s"', set_clause, row_endTime);
                else
                    set_clause = sprintf('SET endTime="%s"', row_endTime);
                end
            end
            
            if isempty(row_errorMessage) ~= 1
                if isempty(set_clause) ~= 1
                    set_clause = sprintf('%s, errorMessage="%s"', set_clause, row_errorMessage);
                else
                    set_clause = sprintf('SET errorMessage="%s"', row_errorMessage);
                end
            end
            
            if isempty(row_publishTime) ~= 1
                if isempty(set_clause) ~= 1
                    set_clause = sprintf('%s, publishTime=%s', set_clause, row_publishTime);
                else
                    set_clause = sprintf('SET publishTime="%s"', row_publishTime);
                end
            end
            
            if isempty(row_publishNodeId) ~= 1
                if isempty(set_clause) ~= 1
                    set_clause = sprintf('%s, publishNodeId=%s', set_clause, row_publishNodeId);
                else
                    set_clause = sprintf('SET publishNodeId="%s"', row_publishNodeId);
                end
            end
            
            if isempty(row_publishId) ~= 1
                if isempty(set_clause) ~= 1
                    set_clause = sprintf('%s, publishId=%s', set_clause, row_publishId);
                else
                    set_clause = sprintf('SET publishId="%s"', row_publishId);
                end
            end
            
            updateQuery = sprintf('%s %s %s', update_clause, set_clause, where_clause);          
        end
    end
    
end