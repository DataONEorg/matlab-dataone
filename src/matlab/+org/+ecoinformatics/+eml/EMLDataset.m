% EMLDataset A class used to model an Ecological Metadata Language Dataset.
%   The EMLDataset class provides static functions to manage EML Dataset
%   module instances.
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

classdef EMLDataset < org.ecoinformatics.eml.EML
    % EMLDataset A class used to model an Ecological Metadata Language Dataset.
    %   The EMLDataset class provides static functions to manage EML Dataset
    %   module instances.
    
    properties
    end
    
    methods
        
        function emlDataset = EMLDataset()
        % EMLDATASET Creates a new, minimally valid instance of the EMLDataset class
            
            % Get the top level EML document from the superclass
            emlDataset@org.ecoinformatics.eml.EML();
            
            % Build the miminimal ./dataset/{title,abstract,creator,contact}
            emlDataset = emlDataset.buildMinimalEMLDataset();
            
        end
    
        function emlDataset = appendOtherEntity(self, entityName, ...
            entityDescription, objectName, size, formatName, entityType)
            % APPENDOTHERENTITY Adds an OtherEntity element to the EMLDataset
            %   As a first pass, only support externallyDefinedFormat
            %   entitites.
            
            if ( isempty(entityName) || ...
                 isempty(objectName) || ...
                 isempty(formatName) || ...
                 isempty(entityType) )
                msg = ['The entityName, objectName, formatName, and entityType ' ...
                    'parameters can''t be empty.'];
                error('EMLDataset:appendOtherEntity:missingParameters', msg);
                
            end
            
            % Find the correct location for the otherEntity element
            contactElements = self.document.getElementsByTagName('contact');
            contactElement = contactElements.item(length(contactElements) - 1);
            publisherElements = self.document.getElementsByTagName('publisher');
            publisherElement = publisherElements.item(length(publisherElements) - 1);
            pubPlaceElements = self.document.getElementsByTagName('pubPlace');
            pubPlaceElement = pubPlaceElements.item(length(pubPlaceElements) - 1);
            methodsElements = self.document.getElementsByTagName('methods');
            methodsElement = methodsElements.item(length(methodsElements) - 1);
            projectElements = self.document.getElementsByTagName('project');
            projectElement = projectElements.item(length(projectElements) - 1);
            
            if ( ~ isempty(projectElement) )
                currentElement = projectElement;
                
            elseif ( ~ isempty(methodsElement) )
                currentElement = methodsElement;
                
            elseif ( ~ isempty(pubPlaceElement) )
                currentElement = pubPlaceElement;
                
            elseif ( ~ isempty(publisherElement) )
                currentElement = publisherElement;
                
            elseif ( ~ isempty(contactElement) )
                currentElement = contactElement;
                
            end
            
            % Add the otherEntity element
            otherEntityElement = self.document.createElement('otherEntity');
            currentElement.getParentNode().insertBefore(...
                otherEntityElement, currentElement.getNextSibling());
            
            % Add the entityName element
            entityNameElement = self.document.createElement('entityName');
            entityNameElement.appendChild(self.document.createTextNode(entityName));
            otherEntityElement.appendChild(entityNameElement);
            
            % Add the entityDescription element
            if ( ~ isempty(entityDescription) )
                entityDescriptionElement = ...
                    self.document.createElement('entityName');
                entityDescriptionElement.appendChild( ...
                    self.document.createTextNode(entityName));
                otherEntityElement.appendChild(entityDescriptionElement);
            end
            
            % Add the objectName element
            if ( ~ isempty(objectName) )
                physicalElement = ...
                    self.document.createElement('physical');
                objectNameElement = ...
                    self.document.createElement('objectName');
                objectNameElement.appendChild( ...
                    self.document.createTextNode(objectName));
                physicalElement.appendChild(objectNameElement);
            end
            
            % Add the size element
            if ( ~ isempty(size) )
                if ( isnumeric(size) )
                    size = num2str(size);
                    
                end
                
                sizeElement = ...
                    self.document.createElement('size');
                sizeElement.appendChild( ...
                    self.document.createTextNode(num2str(size)));
                physicalElement.appendChild(sizeElement);
            end
            
            % Add the formatName element
            if ( ~ isempty(formatName) )
                dataFormatElement = ...
                    self.document.createElement('dataFormat');
                extDefinedFormatElement = ...
                    self.document.createElement('externallyDefinedFormat');
                formatNameElement = ...
                    self.document.createElement('formatName');
                extDefinedFormatElement.appendChild(formatNameElement);
                formatNameElement.appendChild( ...
                    self.document.createTextNode(formatName));
                dataFormatElement.appendChild(extDefinedFormatElement);
                physicalElement.appendChild(dataFormatElement);
            end

            otherEntityElement.appendChild(physicalElement);
            
            % Add the entityType element
            if ( ~ isempty(entityType) )
                entityTypeElement = ...
                    self.document.createElement('entityType');
                entityTypeElement.appendChild( ...
                    self.document.createTextNode(entityType));
                otherEntityElement.appendChild(entityTypeElement);
                
            end
            
            emlDataset = self;

        end
    end
    
    methods (Access = 'private')
        
        function emlDataset = buildMinimalEMLDataset(self)
            % BUILDMINIMALEMLDATASET returns a minimally valid EML dataset
            % document
            
            emlRootElement = self.document.getDocumentElement();

            % Create and add the dataset element
            datasetElement = self.document.createElement('dataset');
            emlRootElement.appendChild(datasetElement);

            % Create and add the 'title' element
            titleElement = self.document.createElement('title');
            titleElement.appendChild(self.document.createTextNode('YOUR_TITLE'));
            datasetElement.appendChild(titleElement);
            
            % Create and add the creator element
            creatorElement = self.document.createElement('creator');
            
            creatorElement.setAttribute('id', 'creator');
            individualElement = self.document.createElement('individualName');

            salutationElement = self.document.createElement('salutation');
            salutationElement.appendChild(self.document.createTextNode('YOUR_SALUTATION'));
            individualElement.appendChild(salutationElement);

            givenNameElement = self.document.createElement('givenName');
            givenNameElement.appendChild(self.document.createTextNode('YOUR_GIVEN_NAME'));
            individualElement.appendChild(givenNameElement);
            
            surNameElement = self.document.createElement('surName');
            surNameElement.appendChild(self.document.createTextNode('YOUR_SURNAME'));
            individualElement.appendChild(surNameElement);
            
            creatorElement.appendChild(individualElement);

            datasetElement.appendChild(creatorElement);

            % Create and add the abstract
            abstractElement = self.document.createElement('abstract');
            paraElement = self.document.createElement('para');
            paraElement.appendChild(self.document.createTextNode('YOUR_ABSTRACT'));
            abstractElement.appendChild(paraElement);
            datasetElement.appendChild(abstractElement);
            
            % Create and add the contact element
            contactElement = self.document.createElement('contact');
            
            refsElement = self.document.createElement('references');
            refsElement.appendChild(self.document.createTextNode('creator'));
            contactElement.appendChild(refsElement);
                        
            datasetElement.appendChild(contactElement);
            
            emlDataset = self;
        end
    end
end

