% DATAOBJECT A class that represents a data object with DataONE properties
%   The DataObject class provides properties about a data object including
%   its storage location, as well as DataONE-specific properties like the
%   SystemMetadata associated with the object.
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2009-2015 DataONE
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

classdef DataObject < hgsetget
% DATAOBJECT A class that represents a data object with DataONE properties
%   The DataObject class provides properties about a data object including
%   its storage location, as well as DataONE-specific properties like the
%   SystemMetadata associated with the object.
    
    properties
        
        % The identifier string for the object
        identifier = '';
        
        % The full path to the location of the object on disk
        full_file_path = '';
        
        % The DataONE object format identifier for the object type
        format_id = 'application/octet-stream';
        
        % The DataONE system metadata associated with the object
        system_metadata;
        
    end
    
    methods
        
        function dataObject = DataObject(identifier, format_id, full_file_path) 
        % DataObject constructs an DataObject instance with the given identifier
            
            dataObject.identifier = identifier;
            dataObject.format_id = format_id;
            dataObject.full_file_path = full_file_path;
            
            import org.dataone.service.types.v1.Identifier;
            import org.dataone.service.types.v1.ObjectFormatIdentifier;
            import org.dataone.service.types.v2.SystemMetadata;
            import org.dataone.service.types.v1.util.ChecksumUtil;
            import org.dataone.service.types.v1.util.AccessUtil;
            import java.io.InputStream;
            import java.io.FileInputStream;
            import java.io.File;
            import java.math.BigInteger;

            try
                sysmeta = SystemMetadata();
                
                % Set the identifier
                pid = Identifier();
                pid.setValue(dataObject.identifier);
                sysmeta.setIdentifier(pid);

                % Add the object format id
                fmtid = ObjectFormatIdentifier();
                fmtid.setValue(dataObject.format_id);
                sysmeta.setFormatId(fmtid);
            
                % Add the file size
                fileInfo = dir(full_file_path);
                fileSize = fileInfo.bytes;
                sizeBigInt = BigInteger.valueOf(fileSize);
                sysmeta.setSize(sizeBigInt);

                % Add the checksum
                objectFile = File(full_file_path);
                fileInputStream = FileInputStream(objectFile);
                checksum = ChecksumUtil.checksum(fileInputStream, 'SHA1');
                sysmeta.setChecksum(checksum);

                % Set the file name
                [path, name, ext] = fileparts(dataObject.full_file_path);
                sysmeta.setFileName([name ext]);
                
            catch Error
                % TODO: Decide what to do here
                rethrow(Error);

            end
            
            dataObject.system_metadata = sysmeta;

        end
    end
    
end

