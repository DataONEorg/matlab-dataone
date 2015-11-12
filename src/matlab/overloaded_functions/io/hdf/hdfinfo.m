function fileinfo = hdfinfo(varargin)
%HDFINFO Information about HDF 4 or HDF-EOS 2 file
%
%   FILEINFO = HDFINFO(FILENAME) returns a structure whose fields contain
%   information about the contents an HDF or HDF-EOS file.  FILENAME is a
%   string that specifies the name of the HDF file. HDF-EOS files are
%   described as HDF files.
%
%   FILEINFO = HDFINFO(FILENAME,MODE) reads the file as an HDF file if MODE
%   is 'hdf', or as an HDF-EOS file if MODE is 'eos'.  If MODE is 'eos',
%   only HDF-EOS data objects are queried.  To retrieve information on the
%   entire contents of a hybrid HDF-EOS file, MODE must be 'hdf' (default).
%   
%   The set of fields in FILEINFO depends on the individual file.  Fields
%   that may be present in the FILEINFO structure are:
%
%   HDF objects:
%   
%   Filename   A string containing the name of the file
%   
%   Vgroup     An array of structures describing the Vgroups
%   
%   SDS        An array of structures describing the Scientific Data Sets
%   
%   Vdata      An array of structures describing the Vdata sets
%   
%   Raster8    An array of structures describing the 8-bit Raster Images
%   
%   Raster24   An array of structures describing the 24-bit Raster Images
%   
%   HDF-EOS objects:
%
%   Point      An array of structures describing HDF-EOS Point data
%   
%   Grid       An array of structures describing HDF-EOS Grid data
%   
%   Swath      An array of structures describing HDF-EOS Swath data
%   
%   The data set structures above share some common fields.  They are (note,
%   not all structures will have all these fields):
%   
%   Filename          A string containing the name of the file
%                     
%   Type              A string describing the type of HDF object 
%   	              
%   Name              A string containing the name of the data set
%                     
%   Attributes        An array of structures with fields 'Name' and 'Value'
%                     describing the name and value of the attributes of the
%                     data set
%                     
%   Rank              A number specifying the number of dimensions of the
%                     data set
%
%   Ref               The reference number of the data set
%
%   Label             A cell array containing an Annotation label
%
%   Description       A cell array containing an Annotation description
%
%   Fields specific to each structure are:
%   
%   Vgroup:
%   
%      Class      A string containing the class name of the data set
%
%      Vgroup     An array of structures describing Vgroups
%                 
%      SDS        An array of structures describing Scientific Data sets
%                 
%      Vdata      An array of structures describing Vdata sets
%                 
%      Raster24   An array of structures describing 24-bit raster images  
%                 
%      Raster8    An array of structures describing 8-bit raster images
%                 
%      Tag        The tag of this Vgroup
%                 
%   SDS:
%              
%      Dims       An array of structures with fields 'Name', 'DataType',
%                 'Size', 'Scale', and 'Attributes'.  Describing the
%                 dimensions of the data set.  'Scale' is an array of numbers
%                 to place along the dimension and demarcate intervals in
%                 the data set.
%              
%      DataType   A string specifying the precision of the data
%              
%
%      Index      Number indicating the index of the SDS
%   
%   Vdata:
%   
%      DataAttributes    An array of structures with fields 'Name' and 'Value'
%                        describing the name and value of the attributes of the
%                        entire data set
%   
%      Class             A string containing the class name of the data set
%		      
%      Fields            An array of structures with fields 'Name' and
%                        'Attributes' describing the fields of the Vdata
%                        
%      NumRecords        A number specifying the number of records of the data
%                        set   
%                        
%      IsAttribute       1 if the Vdata is an attribute, 0 otherwise
%      
%   Raster8 and Raster24:
%
%      Name           A string containing the name of the image
%   
%      Width          An integer indicating the width of the image
%                     in pixels
%      
%      Height         An integer indicating the height of the image
%                     in pixels
%      
%      HasPalette     1 if the image has an associated palette, 0 otherwise
%                     (8-bit only)
%      
%      Interlace      A string describing the interlace mode of the image
%                     (24-bit only)
%
%   Point:
%
%      Level          A structure with fields 'Name', 'NumRecords',
%                     'FieldNames', 'DataType' and 'Index'.  This structure
%                     describes each level of the Point
%      
%   Grid:
%     
%      UpperLeft      A number specifying the upper left corner location
%                     in meters
%      
%      LowerRight     A number specifying the lower right corner location
%                     in meters
%      
%      Rows           An integer specifying the number of rows in the Grid
%      
%      Columns        An integer specifying the number of columns in the Grid
%      
%      DataFields     An array of structures with fields 'Name', 'Rank', 'Dims',
%                     'NumberType', 'FillValue', and 'TileDims'. Each structure
%                     describes a data field in the Grid fields in the Grid
%      
%      Projection     A structure with fields 'ProjCode', 'ZoneCode',
%                     'SphereCode', and 'ProjParam' describing the Projection
%                     Code, Zone Code, Sphere Code and projection parameters of
%                     the Grid
%      
%      Origin Code    A number specifying the origin code for the Grid
%      
%      PixRegCode     A number specifying the pixel registration code
%      
%   Swath:
%		       
%      DataFields         An array of structures with fields 'Name', 'Rank', 'Dims',
%                         'NumberType', and 'FillValue'.  Each structure
%                         describes a Data field in the Swath 
%
%      GeolocationFields  An array of structures with fields 'Name', 'Rank', 'Dims',
%                         'NumberType', and 'FillValue'.  Each structure
%                         describes a Geolocation field in the Swath 
%   
%      MapInfo            A structure with fields 'Map', 'Offset', and
%                         'Increment' describing the relationship between the
%                         data and geolocation fields. 
%   
%      IdxMapInfo         A structure with 'Map' and 'Size' describing the
%                         relationship between the indexed elements of the
%                         geolocation mapping
%   
% 
%   Example:  
%             % Retrieve info about example.hdf
%             fileinfo = hdfinfo('example.hdf');
%             % Retrieve info about Scientific Data Set in example
%             data_set_info = fileinfo.SDS;
%	     
%   Please read the file hdf4copyright.txt for more information.
%
%   See also HDFTOOL, HDFREAD, HDF.  
  
%   Copyright 1984-2013 The MathWorks, Inc.

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
        disp('Called the hdfinfo wrapper function.');
    end
    
    % Remove wrapper hdfinfo from the Matlab path
    overloadedFunctPath = which('hdfinfo');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug )
        disp('remove the path of the overloaded hdfinfo function.');  
    end
     
    % Call hdfinfo 
    fileinfo = hdfinfo( varargin{:} ); % fileinfo is a struct
    
    % Add the wrapper hdfinfo back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded hdfinfo function back.');
    end
    
    % Identifiy the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_reads )
        formatId = 'application/octet-stream'; % Todo: what is the correct object format for common data format (cdf). 
                                         % Temporary to borrow: Network Common Data Format
        import org.dataone.client.v2.D1Object;

        if ~isempty(fileinfo) % HDFINFO(filenaame, ...)
            file_name = fileinfo.Filename;              
            fullSourcePath = which(file_name);
          
            if isempty(fullSourcePath)
                [status, struc] = fileattrib(source);
                fullSourcePath = struc.Name;
            end
            
            existing_id = runManager.execution.getIdByFullFilePath( ...
                fullSourcePath);
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
            
            runManager.execution.execution_input_ids{end+1} = pid;
        end
    end

end