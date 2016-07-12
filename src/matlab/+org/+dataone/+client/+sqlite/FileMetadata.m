

classdef FileMetadata < hgsetget
    
    properties
        % The unique identifier for the file entry
        fileId;
        % The identifier associated with the file entry
        executionId;
        % The location of the file
        filePath;
        % The checksum of the file
        sha256;
        % The size of the file
        size;
        % The user associated with the file entry
        user;
        % The file creation time
        createTime;
        % The file modification time
        modifyTime;
        % The type of access made to the file
        access;
        % The file format
        format;
        % The location of the archived file
        archivedFilePath;
        
        % A database wrapper class
        dbObj; 
    
        % Database name
        dbname = 'prov.db';
    end
    
    methods (Static)
        
        function hash = string2hash(string)
            % STRING2HASH Converts a string to a 64 char hex hash string (256 bit hash)
            % string - a string
            % hash - a 64 character string, encoding the 256 bit SHA hash of string
            %        in hexadecimal.
            
            persistent md;
            
            if isempty(md)
                md = java.security.MessageDigest.getInstance('SHA-256');
            end
            hash = sprintf('%2.2x', typecast(md.digest(uint8(string)), 'uint8')');
        end
        
    end
    
    
    methods
        function fileMetadata = FileMetadata( varargin )
            % FILEMETADATA Constructor: initializes a file metadata object
            % varargin - the input arguments could be a dataObject or a
            % list of arguments describing a file metadata
            
            import java.io.File;
            import javax.activation.FileDataSource;

            persistent filemetaParser;
            if isempty(filemetaParser)
                filemetaParser = inputParser;
                
                addParameter(filemetaParser, 'dataObject', '', @(x)isa(x, org.dataone.client.v2.DataObject));
                addParameter(filemetaParser, 'executionId', '', @ischar);
                addParameter(filemetaParser, 'fileId', '', @ischar);
                addParameter(filemetaParser, 'filePath', '', @ischar);
                addParameter(filemetaParser, 'sha256', '', @ischar);
                addParameter(filemetaParser, 'size', '', @isnumeric);
                addParameter(filemetaParser, 'user', '', @ischar);
                addParameter(filemetaParser, 'createTime', '', @ischar);
                addParameter(filemetaParser, 'modifyTime', '', @ischar);
                addParameter(filemetaParser, 'access', '', @ischar);
                addParameter(filemetaParser, 'format', '', @ischar);
                addParameter(filemetaParser, 'archivedFilePath', '', @ischar);                
            end
            
            parse(filemetaParser, varargin{:});

            dataObject = filemetaParser.Results.dataObject;
            execution_id = filemetaParser.Results.executionId;
            file_id = filemetaParser.Results.fileId;
            file_path = filemetaParser.Results.filePath;
            sha256_str = filemetaParser.Results.sha256;
            size_num = filemetaParser.Results.size;
            user_str = filemetaParser.Results.user;
            createTime_str = filemetaParser.Results.createTime;
            modifyTime_str = filemetaParser.Results.modifyTime;
            access_str = filemetaParser.Results.access;
            format_str = filemetaParser.Results.format;
            archivedFilePath_str = filemetaParser.Results.archivedFilePath;
            
            if isempty(execution_id)
                fileMetadata.executionId = execution_id;
            end
            
            import org.dataone.client.sqlite.SqliteHelper;
            
            fileMetadata.dbObj = SqliteHelper('prov.db');
            
            if isempty(dataObject) ~= 1
                % Input is an instance of DataObject and get information
                % from the input dataObject argument (Todo: need to test this condition)
                if exist(dataObject.full_file_path, 'file')
                    % File exists.
                    
                    fileMetadata.fileId = dataObject.identifier;
                    fileMetadata.filePath = dataObject.full_file_path;
                    fileMetadata.format = dataObject.format_id;
                    
                    dataObj_sysmeta = dataObject.system_metadata;
                    
                    fileMetadata.size = dataObj_sysmeta.size;
                    fileMetadata.user = dataObj_sysmeta.submitter;
                    
                    fileInfo = dir(dataObject.full_file_path);
                    last_modified = fileInfo.date;
                    fileMetadata.modifyTime = last_modified;
                    
                    % Add the SHA-256 checksum
                    import org.apache.commons.io.IOUtils;
                    
                    objectFile = File(full_file_path);
                    fileInputStream = FileInputStream(objectFile);
                    data = IOUtils.toString(fileInputStream, 'UTF-8');
                    sha256_hash_value = FileMetadata.string2hash(data);
                    fileMetadata.sha256 = sha256_hash_value;
                    
                    % Archived file path
                    
                else
                    % File does not exist.
                    warningMessage =['Warning: file does not exist:\n%s', dataObject.full_file_path];
                    disp(warningMessage);
                    
                end
            else
                % Input is a list of arguments (tested)
                
                if isempty(execution_id) ~= 1
                   fileMetadata.executionId = execution_id;
                end
                
                if isempty(file_id) ~= 1
                    fileMetadata.fileId = file_id;
                end
                                
                if isempty(file_path) ~= 1
                    fileMetadata.filePath = file_path;
                end
                
                if isempty(sha256_str) ~= 1
                    fileMetadata.sha256 = sha256_str;
                end
                
                if isempty(size_num) ~= 1
                    fileMetadata.size = size_num;
                end
                
                if isempty(user_str) ~= 1
                    fileMetadata.user = user_str;
                end
                
                if isempty(createTime_str) ~= 1
                    fileMetadata.createTime = createTime_str;
                end
                
                if isempty(modifyTime_str) ~= 1
                    fileMetadata.modifyTime = modifyTime_str;
                end
                
                if isempty(access_str) ~= 1
                    fileMetadata.access = access_str;
                end
                
                if isempty(format_str) ~= 1
                    fileMetadata.format = format_str;
                end
                
                if isempty(archivedFilePath_str) ~= 1
                    fileMetadata.archivedFilePath = archivedFilePath_str;
                end
                     
            end
            
        end
                     
        
        function createFileMetadataTable(fileMetadata)
            % CREATEFILEMETADATATABLE Creates a file metadata table
            % fileMetadata - ?
            
            db_conn = fileMetadata.dbObj.openDBConnection();
                     
            create_table_statement = ['create table filemeta' ...
                '(' ...
                'fileId TEXT PRIMARY KEY,' ...
                'executionId TEXT not null,' ...
                'filePath TEXT not null,' ...
                'sha256 TEXT not null,' ...
                'size INTEGER not null,' ...
                'user TEXT not null,' ...
                'modifyTime TEXT not null,' ...
                'createTime TEXT not null,' ...
                'access TEXT not null,' ...
                'format TEXT,' ...
                'archivedFilePath TEXT,' ...
                'foreign key(executionId) references execmeta(executionId),' ...
                'unique(fileId));'];
            
            if isempty(db_conn) ~= 1
                curs = exec(db_conn, create_table_statement); 
                close(curs);
                close(db_conn);                
            end
            
        end
        
        function status = writeFileMeta(fileMetadata)
            % WRITEFILEMETA Saves metadata for a single file
            % fileMetadata - a filemetadata object to be added to the
            % filemetadata table
            
            import org.dataone.client.sqlite.SqliteHelper;
            
            
            % Check if the connection to the database is still working
            db_conn = fileMetadata.dbObj.openDBConnection();
            if isempty(db_conn) ~= 1
                                                
                % Get the database connection and check if the filemeta table
                % exists
                get_table_sql_statement = ['SELECT count(*) FROM sqlite_master' ...
                    ' WHERE type=', '"table"', ' AND name="filemeta"'];
                
                import org.dataone.client.sqlite.SqliteHelper;
                db_obj = fileMetadata.dbObj;
                curs = db_obj.getTable(get_table_sql_statement);
                curs = fetch(curs);
                count = rows(curs);
                
                if count >= 1                   
                    % Get values from the input argument 'fileMetadata' record
                    filemeta_colnames = {'fileId', 'executionId', 'filePath', 'sha256',...
                        'size', 'user', 'modifyTime', 'createTime', 'access', 'format', 'archivedFilePath'};
                                      
                    data_row = cell(1, length(filemeta_colnames));
                    for i = 1:length(filemeta_colnames)
                        data_row{i} = fileMetadata.get(filemeta_colnames{i});
                    end
                    
                    % Insert the current data record to the filemeta table                  
                    insert(db_conn,'filemeta',filemeta_colnames, data_row);
                                        
                    % Disconnect the data base connection
                    close(curs);
                    close(db_conn);
                    % Interpret result status and set true or false
                    status = true;
                else
                   % First create a filemeta table
                   
                end
                
            else
                status = false;
            end
        end
        
%         function status = writeFileMeta(varargin)
%             % WRITEFILEMETA Save metadata for a single file
%             % fileMetadata_struct - a filemetadata struct to be added to the
%             % filemetadata table
%         end
                
        function result = readFileMeta(fileMetadata, metaObj, orderBy, sortOrder, delete)
            % READFILEMETA Retrieves saved file metadata for one or more
            % files
            % fileMetadata - a fileMetadata object or struct to be retrieved
            
            % Check if the connection to the database is still working
            db_conn = fileMetadata.dbObj.openDBConnection();
            if isempty(db_conn) ~= 1
                                
                % If the 'execmeta' table doesn's exist yet, then there is no
                % exec metadata for this executionId, so just return a blank
                % data record (Todo: do we need this step?)
                get_table_sql_statement = ['SELECT count(*) FROM sqlite_master' ...
                    ' WHERE type=', '"table"', ' AND name="execemeta"'];
                curs = fileMetadata.dbObj.getTable(get_table_sql_statement);
                curs = fetch(curs);
                count = rows(curs);
                if count < 1
                    result = [];
                    return;
                end
                
                % Construct a SELECT statement to retrieve the runs that match
                % the specified search criteria
                select_statement = 'SELECT * FROM filemeta ';
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
                                
%                 fileMetadataProps = properties(fileMetadata);
%                 for i = 1:length(fileMetadataProps)
%                     pvals{i} = fileMetadata.get(fileMetadataProps{i});
%                 end

                % Process the fileMetadata object and construct the WHERE clause 
                if isempty(metaObj) ~= 1
                    row_fileId =  metaObj.get('fileId');
                    if isempty(row_fileId) ~= 1
                        if isempty(where_clause)
                            where_clause = ['where fileId=', row_fileId];
                        else
                            where_clause = [where_clause, ' and fileId = ', row_fileId];
                        end
                    end
                    
                    row_executionId =  metaObj.get('executionId');
                    if isempty(row_executionId) ~= 1
                        if isempty(where_clause)
                            where_clause = ['where executionId=', row_executionId];
                        else
                            where_clause = [where_clause, ' and executionId = ', row_executionId];
                        end
                    end
                    
                    row_sha256 =  metaObj.get('sha256');
                    if isempty(row_sha256) ~= 1
                        if isempty(where_clause)
                            where_clause = ['where sha256=', row_sha256];
                        else
                            where_clause = [where_clause, ' and sha256 = ', row_sha256];
                        end
                    end
                    
                    row_filePath =  metaObj.get('filePath');
                    if isempty(row_filePath) ~= 1
                        if isempty(where_clause)
                            where_clause = ['where filePath=', row_filePath];
                        else
                            where_clause = [where_clause, ' and filePath = ', row_filePath];
                        end
                    end
                    
                    row_user =  metaObj.get('user');
                    if isempty(row_user) ~= 1
                        if isempty(where_clause)
                            where_clause = ['where user=', row_user];
                        else
                            where_clause = [where_clause, ' and user = ', row_user];
                        end
                    end
                    
                    row_access =  metaObj.get('access');
                    if isempty(row_access) ~= 1
                        if isempty(where_clause)
                            where_clause = ['where access=', row_access];
                        else
                            where_clause = [where_clause, ' and access = ', row_access];
                        end
                    end
                    
                    row_format =  metaObj.get('format');
                    if isempty(row_format) ~= 1
                        if isempty(where_clause)
                            where_clause = ['where format=', row_format];
                        else
                            where_clause = [where_clause, ' and format = ', row_format];
                        end
                    end
                    
                end
                
                % If the user specified 'delete=TRUE', so first fetch the
                % matching records, then delete them.
                
                
                % Retrieve records that match search criteria
                select_statement = [select_statement, where_clause, order_by_clause];
                curs = exec(db_conn, select_statement); 
                curs = fetch(curs);
                result = curs.Data;
                
                % Now delete records if requested
                
                
                % Disconnect the database connection
                close(curs);
                close(db_conn);
                
            else
                % not yet connected to database 
            end
                         
        end
        
    end
end
