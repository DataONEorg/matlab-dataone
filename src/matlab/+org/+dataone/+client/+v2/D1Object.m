% D1OBJECT A class that represents a data object with DataONE properties
%   The D1Object class provides properties about a data object including
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

classdef D1Object < hgsetget
% D1OBJECT A class that represents a data object with DataONE properties
%   The D1Object class provides properties about a data object including
%   its storage location, as well as DataONE-specific properties like the
%   SystemMetadata associated with the object.
    
    properties
        
        % The identifier string for the object
        identifier = '';
        
        % The full path to the location of the object on disk
        full_file_path = '';
        
        % The DataONE system metadata associated with the object
        system_metadata;
        
    end
    
    methods
        
        function d1Object = D1Object(identifier) 
        % D1Object constructs an D1Object instance with the given identifier
            
            d1Object.identifier = identifier;
        
            import org.dataone.service.types.v1.Identifier;
            import org.dataone.service.types.v2.SystemMetadata;
            
            d1Object.system_metadata = SystemMetadata();
            pid = Identifier();
            pid.setValue(d1Object.identifier);
            d1Object.system_metadata.setIdentifier(pid);
            
        end
    end
    
end

