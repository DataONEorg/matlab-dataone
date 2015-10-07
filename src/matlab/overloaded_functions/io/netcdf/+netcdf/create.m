function varargout = create(source, mode, varargin)
%netcdf.create Create new netCDF file.
%   ncid = netcdf.create(filename, mode) creates a new netCDF file 
%   according to the file creation mode.  The return value is a file
%   ID.  
%   
%   The type of access is described by the mode parameter, which could
%   be one of the following string values or a bitwise-or of numeric mode
%   values:
%
%       'CLOBBER'       - overwrite existing files
%       'NOCLOBBER'     - do not overwrite existing files
%       'SHARE'         - allow for synchronous file updates
%       '64BIT_OFFSET'  - allow the creation of 64-bit files instead of
%                         the classic format
%       'NETCDF4'       - create a netCDF-4/HDF5 file
%       'CLASSIC_MODEL' - enforce classic model, has no effect unless used
%                         in a bitwise-or with 'NETCDF4'
%
%   [chunksize_out, ncid]=netcdf.create(filename,mode,initsz,chunksize) 
%   creates a new netCDF file with additional performance tuning 
%   parameters.  initsz sets the initial size of the file.  
%   chunksize can affect I/O performance.  The actual value chosen by 
%   the netCDF library may not correspond to the input value.
%
%   This function corresponds to the "nc_create" and "nc__create" functions 
%   in the netCDF library C API.
%
%   Example:  create a netCDF file that overwrites any existing file by the
%   same name.
%       ncid = netcdf.create('myfile.nc','CLOBBER');
%       netcdf.close(ncid);
%
%   Example:  create a netCDF-4 file that uses the classic model.
%       mode = netcdf.getConstant('NETCDF4');
%       mode = bitor(mode,netcdf.getConstant('CLASSIC_MODEL'));
%       ncid = netcdf.create('myfile.nc',mode);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
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
        disp('Called the netcdf.create wrapper function.');
    end
    
    % Remove wrapper netcdf.create from the Matlab path
    overloadedFunctPath = which('netcdf.create');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    
    % Get the parent path of the package of +netcdf and the first ?+? is useful, 
    % because the parent directory to it is really the toolbox directory that we want to add to the path
    pos = strfind(overloaded_func_path,'+'); % returns an index array
    pkgParentPath = overloaded_func_path(1:pos(1)-1);
       
    rmpath(pkgParentPath); 
    
    if ( runManager.configuration.debug)
        disp('remove the parent path of the overloaded netcdf.open function.');  
    end
    
    % Call netcdf.create
    varargout = cell(1,nargout);
    [varargout{:}] = netcdf.create(source, mode, varargin{:});
  
    % Add the parent directory of netcdf.create back to the Matlab path
    addpath(pkgParentPath, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the parent path of the overloaded netcdf.open function back.');
    end
    
    % Identifiy the file being created/used and add a prov:wasGeneratedBy statements 
    % in the RunManager DataPackage instance   
    if ( (runManager.configuration.capture_file_writes || runManager.configuration.capture_dataone_writes)  )
        exec_output_id_list = runManager.getExecOutputIds();

        fullSourcePath = which(source);
        if isempty(fullSourcePath)
            [status, struc] = fileattrib(source);
            fullSourcePath = struc.Name;
        end
                
        exec_output_id_list.put(fullSourcePath, 'application/netcdf');
    end
end