% RUNMANAGER A class used to manage per-run outputs and products
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
        % The instance of the Configure class used to provide configuration
        % details for this RunManager
        configuration;
        
    end

    methods
        
        function self = RunManager(configuration)
        % RUNMANAGER Constructor: creates an instance of the RunManager class
        %   The RunManager class manages outputs of a script based on the
        %   settings in the given configuuration instance passed in.
        
        end
        
        function record(self)
    end
    
end