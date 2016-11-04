

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
        % The path to the location of the archived file Oct-25-2016
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
        
        function [archiveRelDir, archivedRelFilePath, status] = archiveFile(fullFilePath)
            % ARCHIVEDRELFILEPATH  Searches the relative file path for the
            % archived file copy in the filemeta table to see if the file
            % has already been archived.
            % fullFilePath - a full path for a traced file object
            
            if ~exist(fullFilePath, 'file')
                archivedRelFilePath = [];
                message('Cannot copy file %s, it does not exist\n', fullFilePath);
                status = -1;
                return;
            end
            
            % Compute the SHA-256 checksum
            import java.io.File;
            import java.io.FileInputStream;
            import org.apache.commons.io.IOUtils;
            import java.security.MessageDigest;
            import javax.xml.bind.DatatypeConverter;
            import org.dataone.client.run.RunManager;
            
            objectFile = File(fullFilePath);
            fileInputStream = FileInputStream(objectFile);
            data = IOUtils.toString(fileInputStream, 'UTF-8');
            
            persistent digest;
                        
            if isempty(digest)
                digest = MessageDigest.getInstance('SHA-256');
            end
            hash = digest.digest(java.lang.String(data).getBytes('UTF-8'));
            content_hash_value =  char(DatatypeConverter.printHexBinary(hash));
%             content_hash_value = FileMetadata.getSHA256Hash(data);
            
            % First check if a file with the same sha256 has been accessed
            % before. If it has, then don't archive this file again, and
            % return the archived location of the previously archived file.
            select_filemeta_query = sprintf('select * from %s fm where fm.sha256="%s"', 'filemeta', content_hash_value);
            runManager = RunManager.getInstance();   
            existed_fm = runManager.provenanceDB.execute(select_filemeta_query, 'filemeta');
            if ~isempty(existed_fm)
                archivedRelFilePath = existed_fm{1,11}; % get the relative path for the archived file copy
                status = 0;
                return;
            end
            
            % The archived directory is specified relative to the recordr
            % root directory, so that if the provenance root directory has
            % to be moved, the database entries for archived directories
            % does not have to be updated. The archive directory is named
            % simple for today's date. The data directory is put at the top
            % of the archive directory, just so that directory file limits
            % aren't exceeded. Directories on ext3 filesystems a directory
            % can contain 32,000 entries. So this simple scheme should not
            % run into any OS limits. Also, these directories will not be
            % searched because the filepaths are contains in a database, so
            % directory lookup performance is not an issue.
            archiveRelDir = sprintf('archive/%s', char(datetime('today'))); % date format like "01-Nov-2016"
            archivedRelFilePath = sprintf('%s/%s', archiveRelDir, char(java.util.UUID.randomUUID()));
            status = 1;
            return;
        end
        
        function sha256hash = getSHA256Hash(data)
            % getSHA256Hash Converts a string to a 64 char hex hash string (256 bit hash)
            % data - a string
            % sha256hash - a 64 character string, encoding the 256 bit SHA hash of string
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
            sha256hash =  char(DatatypeConverter.printHexBinary(hash));
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
                    this.sha256= this.getSHA256Hash(data);
                   
                    % Set the access mode {'read','write', 'execute'}
                    this.access = varargin{3};
                                   
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
                
                row_filePath = filemetaObj.get('filePath');
                if isempty(row_filePath) ~= 1
                    if isempty(where_clause)
                        where_clause = sprintf('where filePath="%s"', row_filePath);
                    else
                        where_clause = sprintf( '%s and filePath="%s"', where_clause, row_filePath);
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
                                
                row_user = filemetaObj.get('user');
                if isempty(row_user) ~= 1
                    if isempty(where_clause)
                        where_clause = sprintf('where user="%s"', row_user);
                    else
                        where_clause = sprintf( '%s and user="%s"', where_clause, row_user);
                    end
                end
                
                row_modifyTime = filemetaObj.get('modifyTime');
                if isempty(row_modifyTime) ~= 1
                    if isempty(where_clause)
                        where_clause = sprintf('where modifyTime="%s"', row_modifyTime);
                    else
                        where_clause = sprintf('%s and modifyTime="%s"', where_clause, row_modifyTime);
                    end
                end
                
                row_createTime = filemetaObj.get('createTime');
                if isempty(row_createTime) ~= 1
                    if isempty(where_clause)
                        where_clause = sprintf('where createTime="%s"', row_createTime);
                    else
                        where_clause = sprintf('%s and createTime="%s"', where_clause, row_createTime);
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
                
                row_archivedFilePath = filemetaObj.get('archivedFilePath');
                if isempty(row_archivedFilePath) ~= 1
                    if isempty(where_clause)
                        where_clause = sprintf('where archivedFilePath="%s"', row_archivedFilePath);
                    else
                        where_clause = sprintf( '%s and archivedFilePath="%s"', where_clause, row_archivedFilePath);
                    end
                end
            end
            
            % Retrieve records that match search criteria
            select_statement = sprintf('%s %s %s;', select_statement, where_clause, order_by_clause);
            readQuery = select_statement;            
        end
          
    end
end
