% RUNMANAGER A class used to track information about program runs.
%   The RunManager class provides functions to manage script runs in terms
%   of the known file inputs and the derived file outputs. It keeps track
%   of the provenance (history) relationships between these inputs and outputs.
%
% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2009-2014 DataONE
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

classdef RunManager < hgsetget
    
    properties
       
        % The instance of the Session class used to provide settings 
        % details for this RunManager
        session;
    end

    methods
        
        function runManager = RunManager(session)
            % RUNMANAGER Constructor: creates an instance of the RunManager class
            %   The RunManager class manages outputs of a script based on the
            %   settings in the given configuuration instance passed in.
        
            runManager.session = session
        end
        
        function data_package = record(runManager)
            % RECORD Records provenance relationships between data and scripts
            % When record() is called, data input files, dataoutput files,
            % and programs (scripts and classes) are tracked during an
            % execution of the program, and a graph of their relationships
            % is produced using the W3C PROV ontology standard 
            % (<http://www.w3.org/TR/prov-o/>) and the
            % DataONE ProvONE model(<https://purl.dataone.org/provone-v1-dev>).
            
        end
        
        function startRecord(runManager, tag)
            % STARTRECORD Starts recording provenance relationships (see
            % record()).

        end
        
        function data_package = endRecord(runManager)
            % ENDRECORD Ends the recording of an execution (run).
        end
        
        function runs = listRuns(runManager, quiet, startDate, endDate, tags)
            % LISTRUNS Lists prior executions (runs) and information about them.
        end
        
        function deleted_list = deleteRuns(runIdList, startDate, endDate, tags)
            % DELETERUNS Deletes prior executions (runs) from the stored
            % list.
            
        end
        
        function package_id = view(runManager, packageId)
            % VIEW Displays detailed information about a data package that
            % is the result of an execution (run).
            
        end
        
        function package_id = publish(runManager, packageId)
            % PUBLISH Uploads a data package produced by an execution (run)
            % to the configured DataONE Member Node server.
            
        end
    end
    
end