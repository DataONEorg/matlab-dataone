function h5write(source,Dataset,Data,varargin)
%H5WRITE Write to HDF5 dataset.  
%   H5WRITE(FILENAME,DATASETNAME,DATA) writes to an entire dataset. 
%
%   H5WRITE(FILENAME,DATASETNAME,DATA,START,COUNT) writes a subset of
%   data.  START is the index of the first element to be written and is
%   one-based.  COUNT defines how many elements to write along each
%   dimension.  An extendible dataset will be extended along any unlimited
%   dimensions if necessary.
%
%   H5WRITE(FILENAME,DATASETNAME,DATA,START,COUNT,STRIDE) writes a
%   hyperslab of data.  STRIDE is the inter-element spacing along each
%   dimension.   STRIDE always defaults to a vector of ones if not
%   supplied.  
%
%   Only floating point and integer datasets are supported.  To write to
%   string datasets, you must use the H5D package.
%
%   Example:  Write to an entire dataset.
%       h5create('myfile.h5','/DS1',[10 20]);
%       h5disp('myfile.h5');
%       mydata = rand(10,20);
%       h5write('myfile.h5', '/DS1', mydata);
%
%   Example:  Write a hyperslab to the last 5-by-7 block of a dataset.
%       h5create('myfile.h5','/DS2',[10 20]);
%       h5disp('myfile.h5');
%       mydata = rand(5,7);
%       h5write('myfile.h5','/DS2',mydata,[6 14],[5 7]);
%
%   Example:  Append to an unlimited dataset.
%       h5create('myfile.h5','/DS3',[20 Inf],'ChunkSize',[5 5]);
%       h5disp('myfile.h5');
%       for j = 1:10
%            data = j*ones(20,1);
%            start = [1 j];
%            count = [20 1];
%            h5write('myfile.h5','/DS3',data,start,count);
%       end
%       h5disp('myfile.h5');
%   
%   See also H5CREATE, H5DISP, H5READ, H5WRITEATT, H5D.create, H5D.write.

%   Copyright 2010-2013 The MathWorks, Inc.

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
        disp('Called the h5write wrapper function.');
    end
    
    % Remove wrapper h5write from the Matlab path
    overloadedFunctPath = which('h5write');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded h5write function.');  
    end
     
    % Call h5write
    h5write( source, Dataset, Data, varargin{:} );
   
    % Add the wrapper h5write back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded h5write function back.');
    end
    
    % Identifiy the file being used and add a prov:wasGeneratedBy statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_writes )
        formatId = 'text/csv';
        import org.dataone.client.v2.DataObject;
        
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
     
        if ( ~ ismember(pid, runManager.execution.execution_output_ids) )
            runManager.execution.execution_output_ids{end+1} = pid;
        end
    end
    
end
