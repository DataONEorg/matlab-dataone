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

    disp('Called the netcdf.open wrapper function.');
    
    % Remove wrapper netcdf.open from the Matlab path
    overloadedFunctPath = which('netcdf.open');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    
    % Get the parent path of the package of +netcdf and the first ?+? is useful, 
    % because the parent directory to it is really the toolbox directory that we want to add to the path
    pos = strfind(overloaded_func_path,'+'); % returns an index array
    pkgParentPath = overloaded_func_path(1:pos(1)-1);
       
    rmpath(pkgParentPath); 
    disp('remove the parent path of the overloaded netcdf.open function.');  

    % Call netcdf.open
    varargout = cell(1,nargout);
    [varargout{:}] = netcdf.open(source, varargin{:});
  
    % Add the parent directory of netcdf.open back to the Matlab path
    addpath(pkgParentPath, '-begin');
    disp('add the parent path of the overloaded netcdf.open function back.');
    
    % Identifiy the file being created/used and add a prov:used/prov:wasGeneratedBy statements 
    % in the RunManager DataPackage instance    
    import org.dataone.client.run.RunManager;
    import java.net.URI;
    
    runManager = RunManager.getInstance();   
    
    exec_input_id_list = runManager.getExecInputIds();
    exec_output_id_list = runManager.getExecOutputIds();
    
    switch nargin
        case 1
            startIndex = regexp( char(source),'http' ); 
           
            if isempty(startIndex)
                % local file
                disp('local file');
                fullSourcePath = which(source);
                exec_input_id_list.put(fullSourcePath, 'application/netcdf');
            else
                % url
                disp('url');
                exec_input_id_list.put(source, 'application/netcdf');
            end
     
        otherwise           
            if strcmp(varargin{1}, 'WRITE') ~= 0
                % Read-write access
                
                disp('> > > mode: WRITE !');
                
                %fullSourcePath = [pwd(), filesep, source];
                fullSourcePath = which(source);
                exec_input_id_list.put(fullSourcePath, 'application/netcdf');
                exec_output_id_list.put(fullSourcePath, 'application/netcdf');
            
            elseif any(strcmp(varargin{1}, {'NOWRITE', 'NC_NOWRITE'})) ~= 0
                % Read-only access (Default)
                
                disp('> > > mode: NOWRITE/NC_NOWRITE !');
                
                %fullSourcePath = [pwd(), filesep, source];
                fullSourcePath = which(source);
                exec_input_id_list.put(fullSourcePath, 'application/netcdf');
            else
                % 'SHARE' Synchronous file updates
            end        
    end

end
