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
        sqlite_db_helper = SqliteHelper();
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
        
        function createFileMetadataTable(fileMetadata)
            % CREATEFILEMETADATATABLE Create a file metadata table
            
            if isempty(fileMetadata.sqlite_db_helper.db_conn)               
                prov_db_name_str = 'prov.db';
                db_conn = fileMetadata.sqlite_db_helper.openDBConnection(prov_db_name_str);
            end
         
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
            
            if isemtpy(db_conn) ~= 1
                curs = exec(db_conn, create_table_statement);                
                close(db_conn);                
            end
            
        end
        
        function status = writeFileMeta(fileMetadata)
            % WRITEFILEMETA Save metadata for a single file
            
            % Check if the connection to the database is still working
            if isempty(fileMetadata.sqlite_db_helper.db_conn) ~= 1
                db_conn = fileMetadata.sqlite_db_helper.db_conn;
                                
                % Get the database connection and check if the filemeta table
                % exists
                get_table_sql_statement = ['SELECT count(*) FROM sqlite_master' ...
                    ' WHERE type=', '"table"', ' AND name="filemeta"'];
                curs = fileMetadata.sqlite_db_helper.getTable(get_table_sql_statement);
                curs = fetch(curs);
                count =rows(curs);
                
                if count >= 1                   
                    % Get values from the input argument 'fileMetadata' record
                    filemeta_colnames = {'fileId', 'executionId', 'filePath', 'sha256',...
                        'size', 'user', 'modifyTime', 'createTime', 'access', 'format'};
                                      
                    data_row = cell(1, length(filemeta_colnames));
                    for i = 1:length(filemeta_colnames)
                        data_row{i} = fileMetadata.get(filemeta_colnames{i});
                    end
                    
                    % Insert the current data record to the filemeta table                  
                    insert(db_conn,'filemeta',filemeta_colnames, data_row);
                    curs = exec(db_conn, insert_sql_statement); 
                    
                    % Disconnect the data base connection
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
%             
%         end
                
        function result = readFileMeta(fileMetadata)
            % READFILEMETA Retrieve saved file metadata for one or more
            % files
            
            % Check if the connection to the database is still working
            
            % If the 'execmeta' table doesn's exist yet, then there is no
            % exec metadata for this executionId, so just return a blank
            % data record
            
            % Construct a SELECT statement to retrieve the runs that match
            % the specified search criteria
            
            % If the user specified 'delete=TRUE', so first fetch the
            % matching records, then delete them.
            
            % Retrieve records taht match search criteria
            
            % Now delete records if requested
            
            % Disconnect the database connection
            
            
        end
    end
end
