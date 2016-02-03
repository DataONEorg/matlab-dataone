% SCIENCEMETADATACONFIG A class used to set science metadata configuration options for the DataONE Toolbox
%   When the RunManager.publish() method is called, it uses a science
%   metadata template file to generate a per-run science metadata
%   document that will be published along with the script, its inputs,
%   and outputs.  The properties in this class are used to replace
%   default values in the template file before being published.

% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2009-2016 DataONE

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

classdef ScienceMetadataConfig < hgsetget & dynamicprops
    
    properties
        % A string prepended to the title field for each run
        title_prefix = '';
        % A string appended to the title field for each run
        title_suffix = '';
        % The salutation for the primary creator of the run (Dr., Ms., Mr. etc.)
        primary_creator_salutation = '';
        % The given name of the primary creator of the run
        primary_creator_givenname = '';
        % The surname of the primary creator of the run
        primary_creator_surname = '';
        % The first address line of the primary creator of the run
        primary_creator_address1 = '';
        % The second address line of the primary creator of the run
        primary_creator_address2 = '';
        % The city of the primary creator of the run
        primary_creator_city = '';
        % The state or province of the primary creator of the run
        primary_creator_state = '';
        % The zip or postal code of the primary creator of the run
        primary_creator_zipcode = '';
        % The country of the primary creator of the run
        primary_creator_country = '';
        % The email address of the primary creator of the run
        primary_creator_email = '';
        % The language of the metadata records for the run
        language = '';
        % The abstract paragraph describing the run
        abstract = '';
        % The first keyword describing the run
        keyword1 = '';
        % The second keyword describing the run
        keyword2 = '';
        % The third keyword describing the run
        keyword3 = '';
        % The fourth keyword describing the run
        keyword4 = '';
        % The fifth keyword describing the run
        keyword5 = '';
        % The intellectual rights statement defining use of the data or software used in the run
        intellectual_rights = '';
        % The salutation for the primary contact of the run (Dr., Ms., Mr. etc.)
        primary_contact_salutation = '';
        % The given name of the primary contact of the run
        primary_contact_givenname = '';
        % The surname of the primary contact of the run
        primary_contact_surname = '';
        % The first address line of the primary contact of the run
        primary_contact_address1 = '';
        % The second address line of the primary contact of the run
        primary_contact_address2 = '';
        % The city of the primary contact of the run
        primary_contact_city = '';
        % The state or province of the primary contact of the run
        primary_contact_state = '';
        % The zip or postal code of the primary contact of the run
        primary_contact_zipcode = '';
        % The country of the primary contact of the run
        primary_contact_country = '';
        % The email address of the primary contact of the run
        primary_contact_email = '';
        
    end
    
    methods
    end
    
end

