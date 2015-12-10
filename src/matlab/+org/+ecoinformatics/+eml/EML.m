% EML A class used to model an Ecological Metadata Language document.
%   The EML class provides static functions to manage EML document
%   instances.
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
% Unless required by applicable law or agreed to in writing, dataset
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

classdef EML
    %EML A class used to model an Ecological Metadata Language document.
    %   The EML class provides static functions to manage EML document
    %   instances.
    
    properties
        
        % The EML document as a DOM model
        document;
        
    end

    methods
        function eml = EML()
        % EML Creates a new, empty instance of the EML class
            eml.document = eml.buildValidEmptyEMLDocument();
        
        end

        function eml = update(eml, configuration, execution)
            
            import org.dataone.client.run.Execution;
            import org.dataone.client.configure.Configuration;
            import org.dataone.client.configure.ScienceMetadataConfig;
            cfg = configuration;
            exec = execution;
            
            datasetElements = eml.document.getElementsByTagName('dataset');
            datasetNode = datasetElements.item(0);
            
            % Update the packageId
            emlElement = eml.document.getDocumentElement();
            emlElement.setAttribute('packageId', ...
                exec.execution_id);
            
            % Update the title
            title_str = '';
            if ( ~ isempty(cfg.science_metadata_config.title_prefix) )
                title_str = cfg.science_metadata_config.title_prefix;
                
            end
            
            [file_path, file_name, ext] = fileparts( ...
                exec.software_application);
            script_name = [file_name ext];
            run_str = ['Run of ' script_name ' on ' exec.start_time];
            title_str = [title_str run_str];
            
            if ( ~ isempty(cfg.science_metadata_config.title_suffix) )
                title_str = [title_str cfg.science_metadata_config.title_suffix];
                
            end
            
            titleElements = eml.document.getElementsByTagName('title');
            titleNode = titleElements.item(0).getFirstChild();
            if ( strcmp(char(titleNode.getNodeValue()), 'YOUR_TITLE') )
                titleNode.setNodeValue(title_str);
                
            end
            
            % Update the primary creator
            creatorElements = eml.document.getElementsByTagName('creator');
            creatorNode = creatorElements.item(0);
            individualNode = creatorNode.getFirstChild();
            salutationNode = individualNode.getFirstChild();
            salutationTextNode = salutationNode.getFirstChild();
            
            % Update or remove the salutation
            if ( ~ isempty(cfg.science_metadata_config.primary_creator_salutation) ) 
                
                if ( strcmp(char(salutationTextNode.getNodeValue()), 'YOUR_SALUTATION') )
                    salutationTextNode.setNodeValue( ...
                        cfg.science_metadata_config.primary_creator_salutation);
                    
                end
                
            else
                individualNode.removeChild(salutationNode);
            end
            
            % Update or remove the givenname
            givenNameNode = eml.document.getElementsByTagName('givenName').item(0);
            givenNameTextNode = givenNameNode.getFirstChild();
            if ( ~ isempty(cfg.science_metadata_config.primary_creator_givenname) ) 
                
                if ( strcmp(char(givenNameTextNode.getNodeValue()), 'YOUR_GIVEN_NAME') )
                    givenNameTextNode.setNodeValue( ...
                        cfg.science_metadata_config.primary_creator_givenname);
                    
                end
                
            else
                individualNode.removeChild(givenNameNode);
            end
            
            % Update the surname
            surNameNode = eml.document.getElementsByTagName('surName').item(0);
            surNameTextNode = surNameNode.getFirstChild();
            if ( ~ isempty(cfg.science_metadata_config.primary_creator_surname) ) 
                
                if ( strcmp(char(surNameTextNode.getNodeValue()), 'YOUR_SURNAME') )
                    surNameTextNode.setNodeValue( ...
                        cfg.science_metadata_config.primary_creator_surname);
                    
                end                
            end
            
            % Insert or remove primary_creator_address1
            if ( ~ isempty(cfg.science_metadata_config.primary_creator_address1) )
                addressElement = eml.document.createElement('address');
                deliveryPoint1Element = eml.document.createElement('deliveryPoint');
                deliveryPoint1Element.setTextContent( ...
                    cfg.science_metadata_config.primary_creator_address1);
                addressNode = creatorNode.appendChild(addressElement);
                addressNode.appendChild(deliveryPoint1Element);
                
            end
            
            % Insert or remove primary_creator_address2
            if ( ~ isempty(cfg.science_metadata_config.primary_creator_address2) )
                deliveryPoint2Element = eml.document.createElement('deliveryPoint');
                deliveryPoint2Element.setTextContent( ...
                    cfg.science_metadata_config.primary_creator_address2);
                addressNode.appendChild(deliveryPoint2Element);
                
            end

            % Insert or remove primary_creator_city
            if ( ~ isempty(cfg.science_metadata_config.primary_creator_city) )
                cityElement = eml.document.createElement('city');
                cityElement.setTextContent( ...
                    cfg.science_metadata_config.primary_creator_city);
                addressNode.appendChild(cityElement);
                
            end

            % Insert or remove primary_creator_state
            if ( ~ isempty(cfg.science_metadata_config.primary_creator_state) )
                stateElement = eml.document.createElement('administrativeArea');
                stateElement.setTextContent( ...
                    cfg.science_metadata_config.primary_creator_state);
                addressNode.appendChild(stateElement);
                
            end
            
            % Insert or remove primary_creator_zipcode
            if ( ~ isempty(cfg.science_metadata_config.primary_creator_zipcode) )
                zipElement = eml.document.createElement('postalCode');
                zipElement.setTextContent( ...
                    cfg.science_metadata_config.primary_creator_zipcode);
                addressNode.appendChild(zipElement);
                
            end
            
            % Insert or remove primary_creator_country
            if ( ~ isempty(cfg.science_metadata_config.primary_creator_country) )
                countryElement = eml.document.createElement('country');
                countryElement.setTextContent( ...
                    cfg.science_metadata_config.primary_creator_country);
                addressNode.appendChild(countryElement);
                
            end
            
            % Insert or remove primary_creator_email
            if ( ~ isempty(cfg.science_metadata_config.primary_creator_email) )
                emailElement = eml.document.createElement('electronicMailAddress');
                emailElement.setTextContent( ...
                    cfg.science_metadata_config.primary_creator_email);
                creatorNode.appendChild(emailElement);
                
            end            
           
            % Update or insert  language
            if ( ~ isempty(cfg.science_metadata_config.language) )
                languageElement = eml.document.createElement('language');
                languageElement.setTextContent( ...
                    cfg.science_metadata_config.language);
                
                abstractElements = eml.document.getElementsByTagName('abstract');
                abstractElement = abstractElements.item(0);
                abstractElement.getParentNode().insertBefore( ...
                    languageElement, abstractElement);
                
            end            
                       
            % Update abstract
            abstractElement = eml.document.getElementsByTagName('abstract').item(0);
            paraElement = abstractElement.getFirstChild();
            paraElementTextNode = paraElement.getFirstChild();
            paraElementText = char(paraElementTextNode.getNodeValue());
            
            if ( ~ isempty(cfg.science_metadata_config.abstract) )
                if ( strcmp(paraElementText, 'YOUR_ABSTRACT') )
                    paraElementTextNode.setNodeValue( ...
                        cfg.science_metadata_config.abstract);
                    
                end
            end
            
            % Update keywords
            contactElement = eml.document.getElementsByTagName('contact').item(0);            
            keywordSetElement = eml.document.createElement('keywordSet');
            keywordSetElement = ...
                contactElement.getParentNode().insertBefore( ...
                keywordSetElement, contactElement);
            
            % Keyword 1
            keywordElement1 = eml.document.createElement('keyword');
            
            if ( ~ isempty(cfg.science_metadata_config.keyword1) )
                keywordElement1.setTextContent( ...
                    cfg.science_metadata_config.keyword1);
                keywordSetElement.appendChild(keywordElement1);
                
            end
            
            % Keyword 2
            keywordElement2 = eml.document.createElement('keyword');
            
            if ( ~ isempty(cfg.science_metadata_config.keyword2) )
                keywordElement2.setTextContent( ...
                    cfg.science_metadata_config.keyword2);
                keywordSetElement.appendChild(keywordElement2);
                
            end
            
            % Keyword 3
            keywordElement3 = eml.document.createElement('keyword');
            
            if ( ~ isempty(cfg.science_metadata_config.keyword3) )
                keywordElement3.setTextContent( ...
                    cfg.science_metadata_config.keyword3);
                keywordSetElement.appendChild(keywordElement3);
                
            end
            
            % Keyword 4
            keywordElement4 = eml.document.createElement('keyword');
            
            if ( ~ isempty(cfg.science_metadata_config.keyword4) )
                keywordElement4.setTextContent( ...
                    cfg.science_metadata_config.keyword4);
                keywordSetElement.appendChild(keywordElement4);
                
            end
            
            % Keyword 5
            keywordElement5 = eml.document.createElement('keyword');
            
            if ( ~ isempty(cfg.science_metadata_config.keyword5) )
                keywordElement5.setTextContent( ...
                    cfg.science_metadata_config.keyword5);
                keywordSetElement.appendChild(keywordElement5);
                
            end
            
            % Update intellectual rights
            
            rightsElement = eml.document.createElement('intellectualRights');
            rightsParaElement = eml.document.createElement('para');
            
            if ( ~ isempty(cfg.science_metadata_config.intellectual_rights) )
                rightsParaElement.setTextContent( ...
                    cfg.science_metadata_config.intellectual_rights);
                rightsElement.appendChild(rightsParaElement);
                contactElement.getParentNode().insertBefore( ...
                    rightsElement, contactElement);
                
            end
            
            % TODO: Update contact
            
        end
        
        function documentStr = toXML(eml)
        % TOXML serializes the EML document to a string representation
            
            try
                documentStr = xmlwrite(eml.document);
                
            catch IOError
                rethrow(IOError);
                
            end
            
        end

    end
    
    methods (Static)
        
        function eml = loadDocument(emlFilePath)
        % LOADDOCUMENT Loads an EML document as a Document Object Model
        %   Returns an EML object with the document as its property
         
           try
               import org.ecoinformatics.eml.EML;
               eml = EML();
               if exist(emlFilePath, 'file')
                   % load the XML document into the DOM
                   eml.document = xmlread(emlFilePath);
                    
               else
                   % default to an empty document
                   eml.document = eml.buildEmptyEMLDocument();
                   mexception = MException('EML:fileNotFound', ...
                   ['The EML file named ' emlFilePath ...
                   ' could not be found.']);
                   throw(mexception);
               end
                
            catch IOError
                rethrow(IOError);
                
            end
        end
        
    end

    methods (Access = 'private')
        
        function documentNode = buildValidEmptyEMLDocument(eml)
        % BUILDEMPTYEMLDOCUMENT builds an empty EML document as a DOM
        
            % Create the 'eml' element
            documentNode = com.mathworks.xml.XMLUtils.createDocument('eml:eml');
            emlRootElement = documentNode.getDocumentElement();
            emlRootElement.setAttribute('scope', 'system');
            emlRootElement.setAttribute('system', 'knb');
            emlRootElement.setAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
            emlRootElement.setAttribute('xmlns:eml', 'eml://ecoinformatics.org/eml-2.0.1');
            emlRootElement.setAttribute('xsi:schemaLocation', 'eml://ecoinformatics.org/eml-2.1.1 eml.xsd');
            
            % Create and add the packageId attribute
            emlRootElement.setAttribute('packageId', 'YOUR_PACKAGE_ID');
            
            % Create and add the dataset element
            datasetElement = documentNode.createElement('dataset');
            emlRootElement.appendChild(datasetElement);

            % Create and add the 'title' element
            titleElement = documentNode.createElement('title');
            titleElement.appendChild(documentNode.createTextNode('YOUR_TITLE'));
            datasetElement.appendChild(titleElement);
            
            % Create and add the creator element
            creatorElement = documentNode.createElement('creator');
            
            creatorElement.setAttribute('id', 'creator');
            individualElement = documentNode.createElement('individualName');

            salutationElement = documentNode.createElement('salutation');
            salutationElement.appendChild(documentNode.createTextNode('YOUR_SALUTATION'));
            individualElement.appendChild(salutationElement);

            givenNameElement = documentNode.createElement('givenName');
            givenNameElement.appendChild(documentNode.createTextNode('YOUR_GIVEN_NAME'));
            individualElement.appendChild(givenNameElement);
            
            surNameElement = documentNode.createElement('surName');
            surNameElement.appendChild(documentNode.createTextNode('YOUR_SURNAME'));
            individualElement.appendChild(surNameElement);
            
            creatorElement.appendChild(individualElement);

            datasetElement.appendChild(creatorElement);
            
            % Create and add the abstract
            abstractElement = documentNode.createElement('abstract');
            paraElement = documentNode.createElement('para');
            paraElement.appendChild(documentNode.createTextNode('YOUR_ABSTRACT'));
            abstractElement.appendChild(paraElement);
            datasetElement.appendChild(abstractElement);
            
            % Create and add the contact element
            contactElement = documentNode.createElement('contact');
            
            refsElement = documentNode.createElement('references');
            refsElement.appendChild(documentNode.createTextNode('creator'));
            contactElement.appendChild(refsElement);
                        
            datasetElement.appendChild(contactElement);

        end
    end
end

