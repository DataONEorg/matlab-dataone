% MNode A class that represents a DataONE member node properties
%   The MNode class overloads any calls to the Java class of the same name
%   and provides implementations for all of the public API methods found in the 
%   Java MNode class, and wrap them with Matlab-based equivalents. This class records 
%   provenance statemetns for each method called. 
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
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

classdef MNode < hgsetget
    properties
        
    end
    
    methods
        
        function mnode = getMN(mnBaseUrl)
            import org.dataone.client.v2.itk.D1Client;
            
            mnode = D1Client.getMN(mnBaseUrl);
        end
        
        function inputStream = get(mnode, pid)
            % Call the Java function with the same name to retrieve the DataONE object
            
            % Write provenance information for this object to the
            % DataPackage object
            
                % Identifiy the D1object being used and add a prov:used statement 
                % in the RunManager DataPackage instance 
                
                % Record the DataONE resolve service endpoint + pid for the object of the RDF triple
                
                
                % Decode the URL that will eventually be added to the
                % resource map
                
               
                % Add this object to the execution objects map
                
                
                % Else, update the existing map entry with a new D1Object
        end
        
        
        function inputStream = get(mnode, session, pid)
            
        end
        
        
        function identifier = create(mnode, session, pid, object, sysmeta)
            
        end
        
        
        function identifier = update(mnode, session, pid, object, newPid, sysmeta)
            
            
        end
    end
    
end
