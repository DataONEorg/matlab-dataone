function [parseResult,p] = xmlread(source,varargin)
%XMLREAD  Parse an XML document and return a Document Object Model node.
%   DOMNODE = XMLREAD(FILENAME) reads a URL or file name in the 
%   string input argument FILENAME.  The function returns DOMNODE,
%   a Document Object Model (DOM) node representing the parsed document.  
%   The node can be manipulated by using standard DOM functions.
%
%   Note: A properly parsed document will display to the screen as
%
%     >> xDoc = xmlread(...)
%
%     xDoc =
%
%     [#document: null]
%
%   Example 1: All XML files have a single root element.  Some XML
%   files declare a preferred schema file as an attribute of this element.
%
%     xDoc = xmlread(fullfile(matlabroot,'toolbox/matlab/general/info.xml'));
%     xRoot = xDoc.getDocumentElement;
%     schemaURL = char(xRoot.getAttribute('xsi:noNamespaceSchemaLocation'))
%
%   Example 2: Each info.xml file on the MATLAB path contains
%   several <listitem> elements with a <label> and <callback> element. This
%   script finds the callback that corresponds to the label 'Plot Tools'.
%
%     infoLabel = 'Plot Tools';  infoCbk = '';  itemFound = false;
%     xDoc = xmlread(fullfile(matlabroot,'toolbox/matlab/general/info.xml'));
%
%     % Find a deep list of all <listitem> elements.
%     allListItems = xDoc.getElementsByTagName('listitem');
%
%     %Note that the item list index is zero-based.
%     for i=0:allListItems.getLength-1
%         thisListItem = allListItems.item(i);
%         childNode = thisListItem.getFirstChild;
%
%         while ~isempty(childNode)
%             %Filter out text, comments, and processing instructions.
%             if childNode.getNodeType == childNode.ELEMENT_NODE
%                 %Assume that each element has a single org.w3c.dom.Text child
%                 childText = char(childNode.getFirstChild.getData);
%                 switch char(childNode.getTagName)
%                     case 'label' ; itemFound = strcmp(childText,infoLabel);
%                     case 'callback' ; infoCbk = childText;
%                 end
%             end
%             childNode = childNode.getNextSibling;
%         end
%         if itemFound break; else infoCbk = ''; end
%     end
%     disp(sprintf('Item "%s" has a callback of "%s".',infoLabel,infoCbk))
%
%   See also XMLWRITE, XSLT.

%   Copyright 1984-2006 The MathWorks, Inc.

% Advanced use:
%   Note that FILENAME can also be an InputSource, File, or InputStream object
%   DOMNODE = XMLREAD(FILENAME,...,P,...) where P is a DocumentBuilder object
%   DOMNODE = XMLREAD(FILENAME,...,'-validating',...) will create a validating
%             parser if one was not provided.
%   DOMNODE = XMLREAD(FILENAME,...,ER,...) where ER is an EntityResolver will
%             will set the EntityResolver before parsing
%   DOMNODE = XMLREAD(FILENAME,...,EH,...) where EH is an ErrorHandler will
%             will set the ErrorHandler before parsing
%   [DOMNODE,P] = XMLREAD(FILENAME,...) will return a parser suitable for passing
%             back to XMLREAD for future parses.
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

    import org.dataone.client.run.RunManager;
    
    runManager = RunManager.getInstance();   
 
    if ( runManager.configuration.debug)
        disp('Called the xmlread wrapper function.');
    end
    
    % Remove wrapper xmlread from the Matlab path
    overloadedFunctPath = which('xmlread');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded xmlread function.');  
    end
     
    % Call xmlread 
    [parseResult,p] = xmlread( source, varargin{:} );
    
    % Add the wrapper xmlread back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded xmlread function back.');
    end
    
    % Identifiy the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_reads )
        formatId = 'text/xml';
        import org.dataone.client.v2.DataObject;

        if ischar(source) % xmlread(filename, ...) filename can be an InputSource, File, or InputStream object
                               
            if ~strncmp(source, 'file:', 5)
                
                fullSourcePath = which(source);
                if isempty(fullSourcePath)
                    [status, struc] = fileattrib(source);
                    fullSourcePath = struc.Name;
                end
                
                existing_id = runManager.execution.getIdByFullFilePath( ...
                    fullSourcePath);
                if ( isempty(existing_id) )
                    % Add this object to the execution objects map
                    pid = char(java.util.UUID.randomUUID()); % generate an id
                    dataObject = DataObject(pid, formatId, fullSourcePath);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                else
                    % Update the existing map entry with a new DataObject
                    pid = existing_id;
                    dataObject = DataObject(pid, formatId, fullSourcePath);
                    runManager.execution.execution_objects(dataObject.identifier) = ...
                        dataObject;
                end
                
                runManager.execution.execution_input_ids{end+1} = pid;
            else
                % Todo: need to find an example for xmlread('file://....')
            end
            
        end
    end

end
