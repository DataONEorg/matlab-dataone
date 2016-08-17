function csvwrite(source, varargin)
% CSVWRITE Write a comma-separated value file.
%   CSVWRITE(FILENAME,M) writes matrix M into FILENAME as 
%   comma-separated values.
%
%   CSVWRITE(FILENAME,M,R,C) writes matrix M starting at offset 
%   row R, and column C in the file.  R and C are zero-based, so that
%   R=0 and C=0 specifies first number in the file.
%
%   Notes:
%   
%   * CSVWRITE terminates each line with a line feed character and no
%     carriage return.
%
%   * CSVWRITE writes a maximum of five significant digits.  For greater
%     precision, call DLMWRITE with a precision argument.
%
%   * CSVWRITE does not accept cell arrays for the input matrix M. To
%     export cell arrays to a text file, use low-level functions such as
%     FPRINTF.
%
%   See also CSVREAD, DLMREAD, DLMWRITE.

% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2015 DataONE
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
    
    import org.dataone.client.run.RunManager;
    
    runManager = RunManager.getInstance();   
    
    if ( runManager.configuration.debug)
        disp('Called the csvwrite wrapper function.');
    end
    
    % Remove wrapper csvwrite from the Matlab path
    overloadedFunctPath = which('csvwrite');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded csvwrite function.');  
    end
     
    % Call csvwrite
    csvwrite( source, varargin{:} );
    
    % Generate the access timestamp
    t = datetime('now');
    access_time = datestr(t);
    
    % Add the wrapper csvwrite back to the Matlab path
    warning off MATLAB:dispatcher:nameConflict;
    addpath(overloaded_func_path, '-begin');
    warning on MATLAB:dispatcher:nameConflict;
     
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded csvwrite function back.');
    end
    
    % Identifiy the file being used and add a prov:wasGeneratedBy statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_writes )
               
        import org.dataone.client.v2.DataObject;
        import org.dataone.client.sqlite.FileMetadata;
        import org.dataone.client.sqlite.ArchiveMetadata;
        
        formatId = 'text/csv';
         
        fullSourcePath = which(source);
        if isempty(fullSourcePath)
            [status, struc] = fileattrib(source);
            fullSourcePath = struc.Name;
        end
        
        % Compute the SHA-256 checksum
        import java.io.File;
        import java.io.FileInputStream;
        import org.apache.commons.io.IOUtils;
        
        objectFile = File(fullSourcePath);
        fileInputStream = FileInputStream(objectFile);
        data = IOUtils.toString(fileInputStream, 'UTF-8');
        content_hash_value = FileMetadata.getSHA256Hash(data);
        
        % Get the archive file path
        archive_dir = sprintf('%s/archive', runManager.configuration.provenance_storage_directory);
        [path, copy_file_name, ext] = fileparts(fullSourcePath);
        archive_file_path = sprintf('%s/%s', archive_dir, [copy_file_name, ext]);
        
        % Check if the file has already been seen in the current run from
        % the filemeta table
        select_filemeta_query = sprintf('select fm.fileId from %s fm where fm.filePath="%s" and fm.executionId="%s";', 'filemeta', fullSourcePath, runManager.execution.execution_id);
        existing_file_id = runManager.provenanceDB.execute(select_filemeta_query, 'filemeta');
        
        if ( isempty(existing_file_id) )
            % Add this object to the execution objects map
            pid = char(java.util.UUID.randomUUID()); % generate an id
            dataObject = DataObject(pid, formatId, fullSourcePath);
            
            % Add a new record to the filemeta table for the current run
            file_meta_obj = FileMetadata(dataObject, runManager.execution.execution_id, 'write');
            write_query = file_meta_obj.writeFileMeta();
            status = runManager.provenanceDB.execute(write_query, file_meta_obj.tableName);
            if status == -1
                message = 'DBError: insert a new record to the filemeta table.';
                error(message);
            end
            
            % Add to the archivemeta table only when there is no record for
            % the combination of (content_hash_value, full_file_path)
            select_archivemeta_query = sprintf('select * from %s am where am.content_sha256_hash="%s" and am.full_file_path="%s"', 'archivemeta', content_hash_value, fullSourcePath);
            existing_archive_copy = runManager.provenanceDB.execute(select_archivemeta_query, 'archivemeta');
            
            if isempty(existing_archive_copy)
                % Add a new record to the archivemeta table
                am = ArchiveMetadata(content_hash_value, runManager.execution.execution_id, fullSourcePath, archive_file_path, access_time);
                insert_am_query = am.writeArchiveMeta();
                status = runManager.provenanceDB.execute(insert_am_query, am.tableName);
                if status == -1
                    message = 'DBError: insert a new record to the archivemeta table.';
                    error(message);
                end
                
                % Copy this file to the archive directory
                copyfile(fullSourcePath, archive_file_path, 'f');
            end            
        else
            % Update this record in the filemeta table with the new
            % content_hash256 value
            % Notes: is it always true that the file content are changed if
            % this file object was seens more than once ?
            update_filemeta_query = sprintf('update %s set sha256="%s" where fileId="%s"', 'filemeta', content_hash_value, existing_file_id{1,1});
            status = runManager.provenanceDB.execute(update_filemeta_query, 'filemeta');
            if status == -1
                message = 'DBError: update a new record to the filemeta table.';
                error(message);
            end
            
            % Add to the archivemeta table only when there is no record for
            % the combination of (content_hash_value, full_file_path)
            select_archivemeta_query = sprintf('select * from %s am where am.content_sha256_hash="%s" and am.full_file_path="%s"', 'archivemeta', content_hash_value, fullSourcePath);
            existing_archive_copy = runManager.provenanceDB.execute(select_archivemeta_query, 'archivemeta');
            
            if isempty(existing_archive_copy)
                % Add a new record to the archivemeta table
                am = ArchiveMetadata(content_hash_value, runManager.execution.execution_id, fullSourcePath, archive_file_path, access_time);
                insert_am_query = am.writeArchiveMeta();
                status = runManager.provenanceDB.execute(insert_am_query, am.tableName);
                if status == -1
                    message = 'DBError: insert a new record to the archivemeta table.';
                    error(message);
                end
                
                % Copy this file to the archive directory
                copyfile(fullSourcePath, archive_file_path, 'f');
            end
            
        end
        
        
%         existing_id = runManager.execution.getIdByFullFilePath( ...
%             fullSourcePath);
%         if ( isempty(existing_id) )
%             % Add this object to the execution objects map
%             pid = char(java.util.UUID.randomUUID()); % generate an id
%             dataObject = DataObject(pid, formatId, fullSourcePath);
%             runManager.execution.execution_objects(dataObject.identifier) = ...
%                 dataObject;           
%         else
            % Update the existing map entry with a new DataObject
%             pid = existing_id;
%             dataObject = DataObject(pid, formatId, fullSourcePath);
%             runManager.execution.execution_objects(dataObject.identifier) = ...
%                 dataObject;       
%         end
%         if ( ~ ismember(pid, runManager.execution.execution_output_ids) )
%             runManager.execution.execution_output_ids{end+1} = pid;           
%         end

    end
end