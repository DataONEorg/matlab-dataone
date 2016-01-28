function data = h5read(source,varargin)
%H5READ  Read data from HDF5 dataset.
%   DATA = H5READ(FILENAME,DATASETNAME) retrieves all of the data from the
%   HDF5 dataset DATASETNAME in the file FILENAME.
%
%   DATA = H5READ(FILENAME,DATASETNAME,START,COUNT) reads a subset of
%   data.  START is the one-based index of the first element to be read.
%   COUNT defines how many elements to read along each dimension.  If a
%   particular element of COUNT is Inf, data is read until the end of the
%   corresponding dimension.
%
%   DATA = H5READ(FILENAME,DATASETNAME,START,COUNT,STRIDE) reads a
%   strided subset of data.  STRIDE is the inter-element spacing along each
%   data set extent and defaults to one along each extent.
%
% 
%   Example: Read an entire data set.
%       h5disp('example.h5','/g4/lat');
%       data = h5read('example.h5','/g4/lat');
%
%   Example:  Read the first 5-by-3 subset of a data set.
%       h5disp('example.h5','/g4/world');
%       data = h5read('example.h5','/g4/world',[1 1],[5 3]);
%
%   Example:  Read a data set of references to other datasets.
%       h5disp('example.h5','/g3/reference');
%       data = h5read('example.h5','/g3/reference');
%
%   See also H5DISP, H5READATT, H5WRITE, H5WRITEATT.

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
        disp('Called the h5read wrapper function.');
    end
    
    % Remove wrapper h5read from the Matlab path
    overloadedFunctPath = which('h5read');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug )
        disp('remove the path of the overloaded h5read function.');  
    end
     
    % Call h5read 
    data = h5read( source, varargin{:} );
    
    % Add the wrapper h5read back to the Matlab path
    warning off MATLAB:dispatcher:nameConflict;
    addpath(overloaded_func_path, '-begin');
    warning on MATLAB:dispatcher:nameConflict;
     
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded h5read function back.');
    end
    
    % Identifiy the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_reads )
        formatId = 'application/netcdf'; % Todo: what is the correct object format for hdf?
                                       
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
        
        if ( ~ ismember(pid, runManager.execution.execution_input_ids) )
            runManager.execution.execution_input_ids{end+1} = pid;
        end
    end

end
