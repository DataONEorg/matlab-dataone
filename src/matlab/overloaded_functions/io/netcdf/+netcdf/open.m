function varargout = open(source, varargin)
% netcdf.open Open NetCDF source.
%   ncid = netcdf.open(filename) opens an existing file in read-only mode.
%   ncid = netcdf.open(opendapURL) opens an OPeNDAP NetCDF data source in
%   read-only mode.
%
%   ncid = netcdf.open(filename, mode) opens a NetCDF file and returns a
%   netCDF ID in ncid. The type of access is described by the mode
%   parameter,  which can be 'WRITE' for read-write access, 'SHARE' for
%   synchronous file updates, or 'NOWRITE' for read-only access.  The mode
%   may also be a numeric value that can be retrieved via
%   netcdf.getConstant.  The mode may also be a bitwise-or of numeric mode
%   values.
%
%   [chosen_chunksize, ncid] = netcdf.open(filename, mode, chunksize)
%   is similar to the above, but makes use of an additional
%   performance tuning parameter, chunksize, which can affect I/O
%   performance.  The actual value chosen by the netCDF library may
%   not correspond to the input value.
%
%   This function corresponds to the "nc_open" and "nc__open" functions in
%   the netCDF library C API.
%
%   Example:
%       ncid = netcdf.open('example.nc','NOWRITE');
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for
%   more information.
%
%   See also netcdf, netcdf.close, netcdf.getConstant.
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
    import org.dataone.client.v2.D1Object;

    runManager = RunManager.getInstance(); 
    
    if ( runManager.configuration.debug )
        disp('Called the netcdf.open wrapper function.');
    end
    
    % Remove wrapper netcdf.open from the Matlab path
    overloadedFunctPath = which('netcdf.open');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    
    % Get the parent path of the package of +netcdf and the first ?+? is useful, 
    % because the parent directory to it is really the toolbox directory that we want to add to the path
    pos = strfind(overloaded_func_path,'+'); % returns an index array
    pkgParentPath = overloaded_func_path(1:pos(1)-1);
       
    rmpath(pkgParentPath); 
    
    if ( runManager.configuration.debug)
        disp('remove the parent path of the overloaded netcdf.open function.');  
    end
    
    % Call netcdf.open
    varargout = cell(1,nargout);
    [varargout{:}] = netcdf.open(source, varargin{:});
  
    % Add the parent directory of netcdf.open back to the Matlab path
    addpath(pkgParentPath, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the parent path of the overloaded netcdf.open function back.');
    end
    
    % Identifiy the file being created/used and add a prov:used/prov:wasGeneratedBy statements 
    % in the RunManager DataPackage instance
    formatId = 'netCDF-3';
    
    switch nargin
        case 1
            startIndex = regexp( char(source),'http' ); 
           
            if isempty(startIndex)
                % local file
                if ( runManager.configuration.debug)
                    disp('local file');
                end
                
                fullSourcePath = which(source);
                if isempty(fullSourcePath)
                    [status, struc] = fileattrib(source);
                    fullSourcePath = struc.Name;
                end

                if ( runManager.configuration.capture_file_reads )
                    existing_id = runManager.execution.getIdByFullFilePath( ...
                        fullSourcePath);
                    if ( isempty(existing_id) )
                        % Add this object to the execution objects map
                        pid = char(java.util.UUID.randomUUID()); % generate an id
                        d1Object = D1Object(pid, formatId, fullSourcePath);
                        runManager.execution.execution_objects(d1Object.identifier) = ...
                            d1Object;
                    else
                        d1Object = ...
                            runManager.execution.execution_objects(existing_id);
                    end
                    runManager.execution.execution_input_ids{ ...
                        end + 1} = ...
                        d1Object.identifier;

                end
            else
                % url
                if ( runManager.configuration.debug)
                    disp('url');
                end
                
                if ( runManager.configuration.capture_file_reads )
                    % TODO: download the URL contents, cache in the execution
                    % directory, and then create a D1Object from that file and add
                    % it to the execution objects map:
                    % pid = char(java.util.UUID.randomUUID()); % generate an id
                    % d1Object = D1Object(pid, formatId, source);
                    % runManager.execution.execution_objects(d1Object.identifier) = ...
                    %     d1Object;
                    %    d1Object.identifier) = d1Object;

                    runManager.execution.execution_input_ids{ ...
                        end + 1)} = ...
                        source;
                end
            end
     
        otherwise           
            if strcmp(varargin{1}, 'WRITE') ~= 0
                % Read-write access                
                if ( runManager.configuration.debug)
                    disp('> > > mode: WRITE !');
                end
                
                fullSourcePath = which(source);
                if isempty(fullSourcePath)
                    [status, struc] = fileattrib(source);
                    fullSourcePath = struc.Name;
                end
                
                existing_id = runManager.execution.getIdByFullFilePath( ...
                    fullSourcePath);
                
                if ( runManager.configuration.capture_file_reads )
                    if ( isempty(existing_id) )
                        % Add this object to the execution objects map
                        pid = char(java.util.UUID.randomUUID()); % generate an id
                        d1Object = D1Object(pid, formatId, fullSourcePath);
                        runManager.execution.execution_objects(d1Object.identifier) = ...
                            d1Object;
                    else
                        d1Object = ...
                            runManager.execution.execution_objects(existing_id);
                    end

                    runManager.execution.execution_input_ids{ ...
                        end + 1} = d1Object.identifier;
                end
                
                if ( runManager.configuration.capture_file_writes )
                    if ( isempty(existing_id) )
                        % Add this object to the execution objects map
                        pid = char(java.util.UUID.randomUUID()); % generate an id
                        d1Object = D1Object(pid, formatId, fullSourcePath);
                        runManager.execution.execution_objects(d1Object.identifier) = ...
                            d1Object;
                    else
                        % Update the existing map entry with a new D1Object
                        pid = existing_id;
                        d1Object = D1Object(pid, formatId, fullSourcePath);
                        runManager.execution.execution_objects(d1Object.identifier) = ...
                            d1Object;
                    end
                    runManager.execution.execution_output_ids{ ...
                        end + 1} = d1Object.identifier;
                end
                
            elseif any(strcmp(varargin{1}, {'NOWRITE', 'NC_NOWRITE'})) ~= 0
                % Read-only access (Default)
                if ( runManager.configuration.debug)
                    disp('> > > mode: NOWRITE/NC_NOWRITE !');
                end
                
                fullSourcePath = which(source);
                if isempty(fullSourcePath)
                    [status, struc] = fileattrib(source);
                    fullSourcePath = struc.Name;
                end
                
                if ( runManager.configuration.capture_file_reads )
                    existing_id = runManager.execution.getIdByFullFilePath( ...
                        fullSourcePath);
                    if ( isempty(existing_id) )
                        % Add this object to the execution objects map
                        pid = char(java.util.UUID.randomUUID()); % generate an id
                        d1Object = D1Object(pid, formatId, fullSourcePath);
                        runManager.execution.execution_objects(d1Object.identifier) = ...
                            d1Object;
                    else
                        d1Object = ...
                            runManager.execution.execution_objects(existing_id);
                    end
                    
                    runManager.execution.execution_input_ids{ ...
                        end + 1} = d1Object.identifier;
                end
            else
                % 'SHARE' Synchronous file updates
            end
    end

end
