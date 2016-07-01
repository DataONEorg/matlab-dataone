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
        
    end
    
    properties (Access = private)
        
    end
    
    
    methods (Access = private)
        
    end
    
    
    methods
        function fileMetadata = FileMetadata(varargin)
            % INITIALIZE Initialize a file metadata object
            
        end
        
        function createFileMetadataTable()
            % CREATEFILEMETADATATABLE Create a file metadata table
            
            conn = database('prov.db', '', '', 'org.sqlite.JDBC', 'jdbc:sqlite:/Users/syc/Documents/matlab-dataone/prov.db');
            
            create_statement = ['create table filemeta' ...
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
            
            curs=exec(conn, create_statement);
            
            close(conn);
        end
        
        function result = writeFileMeta(varargin)
            % WRITEFILEMETA Save metadata for a single file
            
        end
        
        function result = readFileMeta(varargin)
            % READFILEMETA Retrieve saved file metadata for one or more
            % files
            
        end
    end
end
