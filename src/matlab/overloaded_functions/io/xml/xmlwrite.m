function varargout = xmlwrite(varargin)
%XMLWRITE  Serialize an XML Document Object Model node.
%   XMLWRITE(FILENAME,DOMNODE) serializes the DOMNODE to file FILENAME.
%
%   S = XMLWRITE(DOMNODE) returns the node tree as a string.
%
%   Example:
%   % Create a sample XML document.
%   docNode = com.mathworks.xml.XMLUtils.createDocument('root_element')
%   docRootNode = docNode.getDocumentElement;
%   docRootNode.setAttribute('attribute','attribute_value');
%   for i=1:20
%      thisElement = docNode.createElement('child_node');
%      thisElement.appendChild(docNode.createTextNode(sprintf('%i',i)));
%      docRootNode.appendChild(thisElement);
%   end
%   docNode.appendChild(docNode.createComment('this is a comment'));
%
%   % Save the sample XML document.
%   xmlFileName = [tempname,'.xml'];
%   xmlwrite(xmlFileName,docNode);
%   edit(xmlFileName);
%
%   See also XMLREAD, XSLT.

%   Copyright 1984-2006 The MathWorks, Inc.

%    Advanced use:
%       FILENAME can also be a URN, java.io.OutputStream or
%                java.io.Writer object
%       SOURCE can also be a SAX InputSource, JAXP Source,
%              InputStream, or Reader object

% This is the XML that the help example creates:
% <?xml version="1.0" encoding="UTF-8"?>
% <root_element>
%     <child_node>1</child_node>
%     <child_node>2</child_node>
%     <child_node>3</child_node>
%     <child_node>4</child_node>
%     ...
%     <child_node>18</child_node>
%     <child_node>19</child_node>
%     <child_node>20</child_node>
% </root_element>
% <!--this is a comment-->

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
        disp('Called the xmlwrite wrapper function.');
    end
    
    % Remove wrapper xmlwrite from the Matlab path
    overloadedFunctPath = which('xmlwrite');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded xmlwrite function.');  
    end
     
    % Call xmlwrite
    [varargout{1:nargout}] = xmlwrite( varargin{:} );
   
    % Add the wrapper xmlwrite back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded xmlwrite function back.');
    end
    
    % Identifiy the file being used and add a prov:wasGeneratedBy statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_writes )
        formatId = 'text/xml';
        import org.dataone.client.v2.DataObject;
        
        if length(varargin) == 1
            source = varargin{1};
        else
            result = varargin{1};
            if ischar(result)
                source = result;
            end
        end
        
        if ischar(source) % For instance documentStr = xmlwrite(eml.document)
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
            
            runManager.execution.execution_output_ids{end+1} = pid;
        end
    end
end