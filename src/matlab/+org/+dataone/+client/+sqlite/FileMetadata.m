

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
               
        function create_table_statement = createFileMetadataTable(tableName)
            % CREATEFILEMETADATATABLE Creates a file metadata table
            create_table_statement = ['create table if not exists ' tableName '('];
            create_table_statement = [create_table_statement ...
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
        
        function sha256hash = getSHA256Hash(data)
            % getSHA256Hash Converts a string to a 64 char hex hash string (256 bit hash)
            % data - a string
            % hash - a 64 character string, encoding the 256 bit SHA hash of string
            %        in hexadecimal.
            
            persistent digest;
            
            import java.security.MessageDigest;
            import javax.xml.bind.DatatypeConverter;
            
            if isempty(digest)
                digest = MessageDigest.getInstance('SHA-256');
            end
            hash = digest.digest(java.lang.String(data).getBytes('UTF-8'));
            % Use javax.xml.bind.DatatypeConverter class in JDK to convert
            % byte array to a hexadecimal string. Note that this generated
            % hexadecimal in upper case
            sha256hash =  DatatypeConverter.printHexBinary(hash);
        end
    end
    
    methods
        function this = FileMetadata( varargin )
            % FILEMETADATA Constructor: initializes a file metadata object
            % varargin - the input arguments could be a dataObject or a
            % list of arguments describing a file metadata
            
            import java.io.File;
            import java.io.FileInputStream;
            import org.apache.commons.io.IOUtils;
            
            switch nargin
                case 3
                    % The arguments order is defined as: dataObject, executionId,
                    % access
                    this.fileId = varargin{1}.identifier;
                    this.filePath = varargin{1}.full_file_path;
                    this.format = varargin{1}.format_id;
                    
                    dataObj_sysmeta = varargin{1}.system_metadata;
                    
                    this.size = dataObj_sysmeta.getSize().longValue();
                    
                    if ~isempty(dataObj_sysmeta.getSubmitter())
                        this.user = dataObj_sysmeta.getSubmitter().getValue();
                    end
                    
                    fileInfo = dir(varargin{1}.full_file_path);
                    last_modified = fileInfo.date;
                    this.modifyTime = last_modified;
                    
                    this.executionId = varargin{2};
                                        
                    % Compute the SHA-256 checksum
                    objectFile = File(this.filePath);
                    fileInputStream = FileInputStream(objectFile);
                    data = IOUtils.toString(fileInputStream, 'UTF-8');
                    this.sha256= FileMetadata.getSHA256Hash(data);
                   
                    % Set the access mode {'read','write', 'execute'}
                    this.access = varargin{3};
                    
                    % Todo: Archived file path
                    this.archivedFilePath = '';
                    
                    % Todo: get the create time of a file
                                    
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
                        where_clause = sprintf('where fileId="%s"', row_fileId);
                    else
                        where_clause = sprintf('%s and fileId="%s" ', where_clause, row_fileId);
                    end
                end
                
                row_executionId = filemetaObj.get('executionId');
                if isempty(row_executionId) ~= 1
                    if isempty(where_clause)
                        where_clause = sprintf('where executionId="%s"', row_executionId);
                    else
                        where_clause = sprintf('%s and executionId="%s"', where_clause, row_executionId);
                    end
                end
                
                row_sha256 = filemetaObj.get('sha256');
                if isempty(row_sha256) ~= 1
                    if isempty(where_clause)
                        where_clause = sprintf('where sha256="%s"', row_sha256);
                    else
                        where_clause = sprintf('%s and sha256="%s"', where_clause, row_sha256);
                    end
                end
                
                row_filePath = filemetaObj.get('filePath');
                if isempty(row_filePath) ~= 1
                    if isempty(where_clause)
                        where_clause = sprintf('where filePath="%s"', row_filePath);
                    else
                        where_clause = sprintf( '%s and filePath="%s"', where_clause, row_filePath);
                    end
                end
                
                row_user = filemetaObj.get('user');
                if isempty(row_user) ~= 1
                    if isempty(where_clause)
                        where_clause = sprintf('where user="%s"', row_user);
                    else
                        where_clause = sprintf( '%s and user="%s"', where_clause, row_user);
                    end
                end
                
                row_access = filemetaObj.get('access');
                if isempty(row_access) ~= 1
                    if isempty(where_clause)
                        where_clause = sprintf('where access="%s"', row_access);
                    else
                        where_clause = sprintf('%s and access="%s"', where_clause, row_access);
                    end
                end
                
                row_format = filemetaObj.get('format');
                if isempty(row_format) ~= 1
                    if isempty(where_clause)
                        where_clause = sprintf('where format="%s"', row_format);
                    else
                        where_clause = sprintf('%s and format="%s"', where_clause, row_format);
                    end
                end
                
            end
            
            % Retrieve records that match search criteria
            select_statement = sprintf('%s %s %s;', select_statement, where_clause, order_by_clause);
            readQuery = select_statement;            
        end
                

    end
end
