

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
        % The table name
        tableName = 'filemeta';
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
        
        function create_table_statement = createFileMetadataTable()
            % CREATEFILEMETADATATABLE Creates a file metadata table
            
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
            
        end
        
        function readQuery = readFileMeta(filemetaObj, orderBy, sortOrder)
            % READFILEMETA Retrieves saved file metadata for one or more
            % files
            % filemetaObj - a fileMetadata object or struct to be retrieved
            
            if isempty(filemetaObj) == 1
                % If the 'filemetaObj' doesn't exist yet, then there is
                % no filemetadata for read, so just return a blank string
                readQuery = [];
                return;
            end
           
            % Construct a SELECT statement to retrieve the runs that match
            % the specified search criteria
            select_statement = sprintf('SELECT * FROM %s ', filemetaObj.tableName);
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
            
            % Process the fileMetadata object and construct the WHERE clause
            if isempty(filemetaObj) ~= 1
                row_fileId = filemetaObj.get('fileId');
                if isempty(row_fileId) ~= 1
                    if isempty(where_clause)
                        where_clause = ['where fileId=', row_fileId];
                    else
                        where_clause = [where_clause, ' and fileId = ', row_fileId];
                    end
                end
                
                row_executionId = filemetaObj.get('executionId');
                if isempty(row_executionId) ~= 1
                    if isempty(where_clause)
                        where_clause = ['where executionId=', row_executionId];
                    else
                        where_clause = [where_clause, ' and executionId = ', row_executionId];
                    end
                end
                
                row_sha256 = filemetaObj.get('sha256');
                if isempty(row_sha256) ~= 1
                    if isempty(where_clause)
                        where_clause = ['where sha256=', row_sha256];
                    else
                        where_clause = [where_clause, ' and sha256 = ', row_sha256];
                    end
                end
                
                row_filePath = filemetaObj.get('filePath');
                if isempty(row_filePath) ~= 1
                    if isempty(where_clause)
                        where_clause = ['where filePath=', row_filePath];
                    else
                        where_clause = [where_clause, ' and filePath = ', row_filePath];
                    end
                end
                
                row_user = filemetaObj.get('user');
                if isempty(row_user) ~= 1
                    if isempty(where_clause)
                        where_clause = ['where user=', row_user];
                    else
                        where_clause = [where_clause, ' and user = ', row_user];
                    end
                end
                
                row_access = filemetaObj.get('access');
                if isempty(row_access) ~= 1
                    if isempty(where_clause)
                        where_clause = ['where access=', row_access];
                    else
                        where_clause = [where_clause, ' and access = ', row_access];
                    end
                end
                
                row_format = filemetaObj.get('format');
                if isempty(row_format) ~= 1
                    if isempty(where_clause)
                        where_clause = ['where format=', row_format];
                    else
                        where_clause = [where_clause, ' and format = ', row_format];
                    end
                end
                
            end
                        
            % Retrieve records that match search criteria
            select_statement = [select_statement, where_clause, order_by_clause, ';'];
            readQuery = select_statement;
                        
        end
    end
    
    methods
        function this = FileMetadata( varargin )
            % FILEMETADATA Constructor: initializes a file metadata object
            % varargin - the input arguments could be a dataObject or a
            % list of arguments describing a file metadata
            
            import java.io.File;
            import javax.activation.FileDataSource;
                        
            switch nargin
                case 2
                    this.fileId = varargin{1}.identifier;
                    this.filePath = varargin{1}.full_file_path;
                    this.format = varargin{1}.format_id;
                    
                    dataObj_sysmeta = varargin{1}.system_metadata;
                    
                    this.size = dataObj_sysmeta.size;
                    this.user = dataObj_sysmeta.submitter;
                    
                    fileInfo = dir(varargin{1}.full_file_path);
                    last_modified = fileInfo.date;
                    this.modifyTime = last_modified;
                    
                    % Add the SHA-256 checksum
                    import org.apache.commons.io.IOUtils;
                    
                    objectFile = File(full_file_path);
                    fileInputStream = FileInputStream(objectFile);
                    data = IOUtils.toString(fileInputStream, 'UTF-8');
                    sha256_hash_value = FileMetadata.string2hash(data);
                    this.sha256 = sha256_hash_value;
                    
                    this.executionId = varargin{2};
                    
                     % Archived file path
                     
                     % createTime
                     
                     % access
                                          
                case 11
                    this.fileId = varargin{1};
                    this.executionId = varargin{2};
                    this.filePath = varargin{3};
                    this.sha256 = varargin{4};
                    this.size = varargin{5};
                    this.user = varargin{6};
                    this.modifyTime = varargin{7};
                    this.createTime = varargin{8};
                    this.access = varargin{9};
                    this.format = varargin{10};
                    this.archivedFilePath = varargin{11};
                    
                otherwise
                    throw(MException('FileMetadata:error', 'invalid options'));
            end
                     
        end
        
        
        function insertQuery = writeFileMeta(fileMetadata)
            % WRITEFILEMETA Saves metadata for a single file
            % fileMetadata - a filemetadata object to be added to the
            % filemetadata table
            
            import org.dataone.client.sqlite.SqliteDatabase;
            

            filemeta_colnames = {'fileId', 'executionId', 'filePath', 'sha256',...
                'size', 'user', 'modifyTime', 'createTime', 'access', 'format', 'archivedFilePath'};
            
            data_row = cell(1, length(filemeta_colnames));
            for i = 1:length(filemeta_colnames)
                data_row{i} = fileMetadata.get(filemeta_colnames{i});
            end
            
            % construct a SQL INSERT statement for fast insert
            insertQuery = sprintf('insert into %s (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) values ', fileMetadata.tableName, filemeta_colnames{:});
            insertQueryData = sprintf('("%s","%s","%s","%s",%d,"%s","%s","%s","%s","%s","%s");', data_row{:});
            insertQuery = [insertQuery , insertQueryData];
        end
      
    end
end
