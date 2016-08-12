
classdef ArchiveMetadata < hgsetget
    
    properties
        % The content hash of the file to be archived
        content_sha256_hash;
        % The identifier associated with the archived file entry
        execution_id;
        % The actual full file path 
        full_file_path;
        % The archived location of the file
        archive_file_path;
        % The access timestamp 
        access_timestamp;
        % The table name
        tableName = 'archivemeta';
    end
    
    methods (Static)
               
        function create_table_statement = createArchiveMetadataTable(tableName)
            % CREATEFILEMETADATATABLE Creates a file metadata table
            create_table_statement = ['create table if not exists ' tableName '('];
            create_table_statement = [create_table_statement ...
                'content_sha256_hash TEXT,' ...
                'execution_id TEXT,' ...
                'full_file_path TEXT,' ...
                'archive_file_path TEXT not null,' ...
                'access_timestamp TEXT,' ...
                'PRIMARY KEY (content_sha256_hash, full_file_path)' ...
                'foreign key(content_sha256_hash) references filemeta(sha256) on delete cascade,' ...
                'foreign key(full_file_path) references filemeta(filePath) on delete cascade);' ];           
        end           
    end
    
    methods
        function this = ArchiveMetadata( varargin )
            % ARCHIVEMETADATA Constructor: initializes an archive metadata object
            % varargin - the input arguments could be a dataObject or a
            % list of arguments describing an archived file metadata
            
            if  nargin == 5
                this.content_sha256_hash = varargin{1};
                this.execution_id = varargin{2};
                this.full_file_path = varargin{3};
                this.archive_file_path = varargin{4};
                this.access_timestamp = varargin{5};
            else
                throw(MException('FileMetadata:error', 'invalid options'));
            end            
        end
                
        function insertQuery = writeArchiveMeta(archiveMetadata)
            % WRITEARCHIVEMETA Saves metadata for a single file
            % archiveMetadata - a archiveMetadata object to be added to the
            % archive_metadata table
                        
            archivemeta_colnames = {'content_sha256_hash', 'execution_id', 'full_file_path', 'archive_file_path', 'access_timestamp'};
               
            data_row = cell(1, length(archivemeta_colnames));
            for i = 1:length(archivemeta_colnames)
                data_row{i} = archiveMetadata.get(archivemeta_colnames{i});
            end
            
            % construct a SQL INSERT statement for fast insert
            insertQuery = sprintf('insert into %s (%s,%s,%s,%s,%s) values ', archiveMetadata.tableName, archivemeta_colnames{:});
            insertQueryData = sprintf('("%s","%s","%s","%s","%s");', data_row{:});
            insertQuery = [insertQuery , insertQueryData];
        end
        
        function readQuery = readArchiveMeta(archivemetaObj, orderBy, sortOrder)
            % READARCHIVEMETA Retrieves saved archive metadata for one or more
            % archived files 
            % archivemetataObj - a archiveMetadata object or struct to be retrieved
                       
        end               
    end
end
