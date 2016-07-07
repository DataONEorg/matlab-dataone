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
        %STRING2HASH Convert a string to a 64 char hex hash string (256 bit hash)
        %
        %   hash = string2hash(string)
        %
        %IN:
        %   string - a string!
        %
        %OUT:
        %   hash - a 64 character string, encoding the 256 bit SHA hash of string
        %          in hexadecimal.
        function hash = string2hash(string)
            persistent md
            if isempty(md)
                md = java.security.MessageDigest.getInstance('SHA-256');
            end
            hash = sprintf('%2.2x', typecast(md.digest(uint8(string)), 'uint8')');
        end
        
    end
    
    
    methods
        function fileMetadata = FileMetadata(execution_id, dataObject)
            % INITIALIZE Initialize a file metadata object
            
            import java.io.File;
            import javax.activation.FileDataSource;

            fileMetadata.executionId = execution_id;
            
            % Get information for this file
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
                sha256_hash_value = string2hash(data);
                fileMetadata.sha256 = sha256_hash_value;
                
                % Archived file path
                
            else
                % File does not exist.
                warningMessage =['Warning: file does not exist:\n%s', dataObject.full_file_path];
                disp(warningMessage);
               
            end

            
        end
        
        function createFileMetadataTable()
            % CREATEFILEMETADATATABLE Create a file metadata table
            
            db_conn = database('prov.db', '', '', 'org.sqlite.JDBC', 'jdbc:sqlite:/Users/syc/Documents/matlab-dataone/prov.db');
            
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
            
            curs = exec(db_conn, create_statement);
            
            close(db_conn);
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
