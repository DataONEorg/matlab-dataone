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
            
            emailElement = documentNode.createElement('electronicMailAddress');
            emailElement.appendChild(documentNode.createTextNode('YOUR_EMAIL'));

            creatorElement.appendChild(individualElement);
            creatorElement.appendChild(emailElement);

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

