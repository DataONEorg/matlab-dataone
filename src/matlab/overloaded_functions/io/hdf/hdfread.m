function varargout = hdfread(varargin)
%HDFREAD extract data from HDF file
%   
%   HDFREAD reads data from a data set in an HDF or HDF-EOS file.  If the
%   name of the data set is known, then HDFREAD searches the file for the
%   data.  Otherwise, use HDFINFO to obtain a structure describing the
%   contents of the file. The fields of the structure returned by HDFINFO are
%   structures describing the data sets contained in the file.  A structure
%   describing a data set may be extracted and passed directly to HDFREAD.
%   These options are described in detail below.
%   
%   DATA = HDFREAD(FILENAME,DATASETNAME) returns in the variable DATA all 
%   data from the file FILENAME for the data set named DATASETNAME.  
%   
%   DATA = HDFREAD(HINFO) returns in the variable DATA all data from the
%   file for the particular data set described by HINFO.  HINFO is a
%   structure extracted from the output structure of HDFINFO.
%   
%   [DATA,MAP] = HDFREAD(...) returns the image data and the colormap for an
%   8-bit raster image.
%   
%   DATA = HDFREAD(...,PARAMETER,VALUE,PARAMETER2,VALUE2...) subsets the
%   data according to the string PARAMETER which specifies the type of
%   subsetting, and the values VALUE.  The table below outlines the valid
%   subsetting parameters for each type of data set.  Parameters marked as
%   "required" must be used to read data stored in that type of data set.
%   Parameters marked "exclusive" may not be used with any other subsetting
%   parameter, except any required parameters.  When a parameter requires
%   multiple values, the values must be stored in a cell array.  Note that
%   the number of values for a parameter may vary for the type of data set.
%   These differences are mentioned in the description of the parameter.
%
%   DATA = HDFREAD(FILENAME,EOSNAME,PARAMETER,VALUE,PARAMETER2,VALUE2...) 
%   subsets the data field from the HDF-EOS point, grid, or swath specified 
%   by EOSNAME.  
%
%   Table of available subsetting parameters
%
%
%           Data Set          |   Subsetting Parameters
%          ========================================
%           HDF Data          |
%                             |
%             SDS             |   'Index'
%                             |
%             Vdata           |   'Fields'
%                             |   'NumRecords'
%                             |   'FirstRecord'
%          ___________________|____________________
%           HDF-EOS Data      |   
%                             |
%             Grid            |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Tile'           (exclusive)
%                             |   'Interpolate'    (exclusive)
%                             |   'Pixels'         (exclusive)
%                             |   'Box'
%                             |   'Time'
%                             |   'Vertical'
%                             |
%             Swath           |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Time'           (exclusive)
%                             |   'Box'
%                             |   'Vertical'
%                             |
%             Point           |   'Level'          (required)
%                             |   'Fields'         (required)
%                             |   'RecordNumbers'  (exclusive)
%                             |   'Box'            (exclusive)
%                             |   'Time'           (exclusive)
%
%    There are no subsetting parameters for Raster Images
%
%
%   Valid parameters and their values are:
%
%   'Index' 
%
%     Three-element cell array {START,STRIDE,EDGE}, specifying the location
%     of the data to be read from the data set.  START, STRIDE and EDGE
%     must be arrays the same size as the number of dimensions.  START
%     specifies the location in the data set to begin reading.  Each number
%     in START must be smaller than its corresponding dimension.  STRIDE is
%     an array specifying the interval between the values to read.  EDGE is
%     an array specifying the length of each dimension to read.  The region
%     specified by START, STRIDE and EDGE must be within the dimensions of
%     the data set.  If either START, STRIDE, or EDGE is empty, then
%     default values are calculated assuming: starting at the first element
%     of each dimension, a stride of one, and EDGE to read the from the
%     starting point to the end of the dimension.  The defaults are all
%     ones for START and STRIDE, and EDGE is an array containing the
%     lengths of the corresponding dimensions.  START,STRIDE and EDGE are
%     one based.
%
%   'Fields'
%
%      Text string or cell array specifying the names of the fields to be
%      read.  For Grid and Swath data sets, only one field may be
%      specified.
%
%   'Box'
%
%     For Grid or Point data sets, Box is a two-element cell array, 
%     {LON, LAT}, specifying the longitude and latitude coordinates that
%     define a region.  LON and LAT are each two-element vectors specifying
%     the opposite corners of the box.  For Swath data sets, Box is a
%     three-element cell array {LON,LAT,MODE}, where MODE defines the
%     criterion for the inclusion of a cross track in a region. The cross
%     track in within a region if its midpoint is within the box, either
%     endpoint is within the box or any point is within the box. Therefore
%     MODE can have values of 'midpoint', 'endpoint', or 'anypoint'.
%
%   'Time'
%
%     For Grid or Point data sets, Time is a two-element cell array,
%     {STARTTIME,STOPTIME} where STARTTIME and STOPTIME specify a period of
%     time.  For Swath data sets, Time is a three-element cell array,
%     {STARTTIME,STOPTIME,MODE}, where  MODE defines the criterion for the
%     inclusion of a cross track in a region. The cross track in within a
%     region if its midpoint is within the box, or if either endpoint is
%     within the box.  Therefore MODE can have values of 'midpoint' or
%     'endpoint'.
%
%   'Vertical'
%
%     Two-element cell array, {DIMENSION, RANGE}, where RANGE is a vector
%     specifying the min and max range for the subset, and DIMENSION is the
%     name of the field or dimension to subset by.  If DIMENSION is a
%     dimension, then the RANGE specifies the range of elements to extract
%     (1 based).  If DIMENSION is the field, then RANGE specifies the range
%     of values to extract. Vertical subsetting may be used in conjunction
%     with 'Box' and/or 'Time'.  To subset a region along multiple
%     dimensions, vertical subsetting may be used up to 8 times in one call
%     to HDFREAD.
%
%   'Pixels'
%
%     Two-element cell array {LON, LAT}, where LON and LAT are numbers
%     that specify opposite corners of a latitude/longitude region.  The
%     longitude/latitude region will be converted into pixel rows and
%     columns with the origin in the upper left-hand corner of the grid.
%     This is the pixel equivalent of reading a 'Box' region.
%
%   'RecordNumbers'
%
%     A one-based vector specifying the record numbers to read. 
%
%   'Level'
%   
%     A string representing the name of the level to read or a one
%     based number specifying the index of the level to read from an
%     HDF-EOS Point data set.
%
%   'NumRecords'
%
%     A number specifying the total number of records to read.
%
%   'FirstRecord'
%
%     A one-based number specifying the first record from which to begin
%     reading.
%
%   'Tile'
%
%     A vector specifying the tile coordinates to read.  The elements are
%     one-based numbers.
%
%   'Interpolate'
%
%     Two-element cell array {LON, LAT}, where LON and LAT are vectors
%     specifying points for bilinear interpolation.
%
%    Example:  Read data set named 'Example SDS'.
%        data1 = hdfread('example.hdf','Example SDS');
%
%    Example:  Read data from HDF-EOS global grid field 'TbOceanRain'.
%        data = hdfread('example.hdf','MonthlyRain','Fields','TbOceanRain');
%      
%    Example:  Read data for the northern hemisphere for the same field.
%        data = hdfread('example.hdf','MonthlyRain', ...
%                       'Fields','TbOceanRain', ...
%                       'Box', {[0 360], [0 90]});
%
%    Example:  Retrieve info about example.hdf.
%        fileinfo = hdfinfo('example.hdf');
%        %  Retrieve info about Scientific Data Set in example.hdf
%        data_set_info = fileinfo.SDS;
%        %  Check the size
%        data_set_info.Dims.Size
%        % Read a subset of the data using info structure
%        data2 = hdfread(data_set_info, 'Index',{[3 3],[],[10 2 ]});
%
%    Example:  Access data in Fields of Vdata.
%        s = hdfinfo('example.hdf') 
%        data3 = hdfread(s.Vdata, 'Fields', {'Idx', 'Temp', 'Dewpt'}) 
%        data3{1} 
%        data3{2} 
%        data3{3}
%
%   Please read the file hdf4copyright.txt for more information.
%
%   See also HDFTOOL, HDFINFO, HDF.  
  
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
        disp('Called the hdfread wrapper function.');
    end
    
    % Remove wrapper hdfread from the Matlab path
    overloadedFunctPath = which('hdfread');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug )
        disp('remove the path of the overloaded hdfread function.');  
    end
     
    % Call hdfread 
    [varargout{1:nargout}] = hdfread( varargin{:} );
    
    % Add the wrapper hdfread back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded hdfread function back.');
    end
    
    % Identifiy the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_reads )
        formatId = 'application/octet-stream'; % Todo: what is the correct object format for common data format (cdf). 
                                         % Temporary to borrow: Network Common Data Format
        import org.dataone.client.v2.D1Object;

        if ischar(varargin{1}) % HDFREAD(FILENAME, DATASETNAME ...)
            file_name = varargin{1};              
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
