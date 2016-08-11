function m = csvread(source, varargin)
% CSVREAD Read a comma separated value file.
%   M = CSVREAD('FILENAME') reads a comma separated value formatted file
%   FILENAME.  The result is returned in M.  The file can only contain
%   numeric values.
%
%   M = CSVREAD('FILENAME',R,C) reads data from the comma separated value
%   formatted file starting at row R and column C.  R and C are zero-
%   based so that R=0 and C=0 specifies the first value in the file.
%
%   M = CSVREAD('FILENAME',R,C,RNG) reads only the range specified
%   by RNG = [R1 C1 R2 C2] where (R1,C1) is the upper-left corner of
%   the data to be read and (R2,C2) is the lower-right corner.  RNG
%   can also be specified using spreadsheet notation as in RNG = 'A1..B7'.
%
%   CSVREAD fills empty delimited fields with zero.  Data files where
%   the lines end with a comma will produce a result with an extra last 
%   column filled with zeros.
%
%   See also CSVWRITE, DLMREAD, DLMWRITE, LOAD, TEXTSCAN.

% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2016 DataONE
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
        disp('Called the csvread wrapper function.');
    end
    
    % Remove wrapper csvread from the Matlab path
    overloadedFunctPath = which('csvread');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded csvread function.');  
    end
        
    % Call csvread 
    m = csvread( source, varargin{:} );
    
    % Generate the access timestamp
    t = datetime('now');
    access_time = datestr(t);
    
    % Add the wrapper csvread back to the Matlab path
    warning off MATLAB:dispatcher:nameConflict;
    addpath(overloaded_func_path, '-begin');
    warning on MATLAB:dispatcher:nameConflict;
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded csvread function back.');
    end
    
    % Identifiy the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_reads )
        formatId = 'text/csv';
        
        import org.dataone.client.v2.DataObject;
        import org.dataone.client.sqlite.FileMetadata;
        import org.dataone.client.sqlite.ArchiveMetadata;

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
        existing_file_id = runManager.provenanceDB.execute(select_filemeta_query, 'archivemeta');
                       
        if ( isempty(existing_file_id) )
            % Add this object to the filemeta table 
            pid = char(java.util.UUID.randomUUID()); % generate an id
            dataObject = DataObject(pid, formatId, fullSourcePath);
            
            % Add a new record to the filemeta table for the current run
            file_meta_obj = FileMetadata(dataObject, runManager.execution.execution_id, 'read');
            file_meta_obj.archivedFilePath = archive_file_path; % update the archive path 
            write_query = file_meta_obj.writeFileMeta;
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
            update_filemeta_query = sprintf('update %s set sha256="%s" where fileId="%s"', 'filemeta', content_hash_value, existing_file_id);
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
                copyfile(fullSourcePath, archive_file_path);
            end
        end

    end
end