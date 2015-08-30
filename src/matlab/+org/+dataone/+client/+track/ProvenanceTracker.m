classdef (Abstract) ProvenanceTracker
    %PROVENANCETRACKER defines the interface for tracking provenance
    %   ProvenanceTracker provides an interface for tracking provenance
    %   information about objects.  Subclasses may track objects at the
    %   file level, the variable level, etc.
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
    
    properties (Abstract)
        
    end
    
    methods (Abstract)
        
        identifier = track(object)
            % TRACK tracks provenance information about a referenced object
            % Given a referenced object, register the object with a
            % data package during an execution, and return the identifier
            % generated for the object that was tracked.  
            
    end
    
end

