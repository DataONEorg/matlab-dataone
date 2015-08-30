classdef FileTracker < ProvenanceTracker
    %FILETRACKER tracks file-level input/output information
    %   FileTracker tracks information about file-level input and output
    %   operations, and registers the provenance information with a
    %   RunManager.  It will relate file reads to an executed script as a
    %   prov:used event, and file writes to an executed script as a
    %   prov:wasGeneratedBy event. See www.w3.org/TR/prov-o/
    %
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
    
    
    properties
    end
    
    methods
        function identifier = track(object)
            
        end
    end
    
end

