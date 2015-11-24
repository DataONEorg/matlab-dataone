function multibandwrite(data,source,interleave,varargin)
%MULTIBANDWRITE write multiband data to a file
%
%   MULTIBANDWRITE writes a three dimensional data set to a binary file. All the
%   data may be written to the file with one function call or MULTIBANDWRITE may
%   be called repeatedly to write pieces of the complete data set to the file.
%
%   The following two syntaxes are ways to use MULTIBANDWRITE to write the
%   entire data set to the file with one function call.  The optional
%   parameter/value pairs described at the below can also be used with these
%   syntaxes.
%
%     MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE) writes DATA, the 2 or
%     3-dimensional array of any numeric or logical type, to the binary file
%     FILENAME.  The bands are written to the file in the form specified by
%     INTERLEAVE. The length of the third dimension of DATA is equal to the
%     number of bands.  By default the data is written to the file in the same
%     precision as it is stored in MATLAB (the same as the class of DATA).
%     INTERLEAVE is a string specifying the method of interleaving the bands
%     written to the file.  Valid strings are 'bil', 'bip', 'bsq', representing
%     band-interleaved-by-line, band-interleaved-by-pixel, and band-sequential
%     respectively. INTERLEAVE is irrelevant if DATA is 2-dimensional. If
%     FILENAME already exists, it will be overwritten unless the optional OFFSET
%     parameter has been specified.
%     
%   The complete data set may be written to the file in smaller chunks by
%   making multiple calls to MULTIBANDWRITE using the following syntax.
%
%     MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE,START,TOTALSIZE) writes
%     the data to the binary file piece by piece. DATA is a subset of the
%     complete data set.  MULTIBANDWRITE will be called multiple times to write
%     all the data to the file. A complete file will be written during the
%     first function call and populated with fill values outside the subset
%     provided in the first call and subsequent calls will overwrite all or
%     some of the fill values. The parameters FILENAME, INTERLEAVE, OFFSET
%     and TOTALSIZE should remain constant throughout the writing of the
%     file.
%
%      START == [firstrow firstcolumn firstband] is 1-by-3 where firstrow
%      and firstcolumn gives the image pixel location of the upper left
%      pixel in the box and firstband gives the index of the first band to
%      write.  DATA contains some of the data for some of the bands.
%      DATA(I,J,K) contains the data for the pixel at [firstrow + I - 1,
%      firstcolumn + J - 1] in the (firstband + K - 1)-th band.
%
%      TOTALSIZE == [totalrows,totalcolumns,totalbands] gives the full
%      three-dimensional size of the complete data set to be contained in
%      the file.
%
%   Any number and combination these optional parameter/value pairs may be
%   added to the end of any of the above syntaxes.
%
%   MULTIBANDWRITE(DATA,FILENAME,INTERLEAVE,...,PARAM,VALUE,...) 
%
%     Parameter Value Pairs:
%     
%     PRECISION is a string to control the form and size of each element
%     written to the file.  See the help for FWRITE for a list of valid
%     values for PRECISION.  The default precision is the class of the data.
%
%     OFFSET is the number of bytes to skip before the first data element. If
%     the file does not already exist, ASCII null values will be written to fill
%     the space by default. This option is useful when writing a header to the
%     file before or after writing the data. When writing the header after the
%     data is written, the file should be opened with FOPEN using 'r+'
%     permission.
%
%     MACHFMT is a string to control the format in which the data
%     is written to the file. Typical values are 'ieee-le' for little endian
%     and 'ieee-be' for big endian however all values for MACHINEFORMAT as
%     documented in FOPEN are valid.  See FOPEN for a complete list.  The
%     default machine format is the local machine format.
%     
%     FILLVALUE is a number specifying the value for missing data. FILLVALUE
%     may be a single number, specifying the fill value for all missing data
%     or FILLVALUE may be a 1-by-number of bands vector of numbers
%     specifying the fill value for each band.  This value will be used to
%     fill space when data is written in chunks.
%
%   Examples:
%
%   % 1.  Write all data (interleaved by line) to the file in one call.
%
%   data = reshape(uint16(1:600), [10 20 3]);
%   multibandwrite(data,'data.bil','bil');
%  
%   % 2.  Write a single-band tiled image with one call for each tile.
%   %     This is useful if only a subset of each band is available
%   %     at each call to MULTIBANDWRITE.
%
%   numBands = 1;
%   dataDims = [1024 1024 numBands];
%   data = reshape(uint32(1:(1024 * 1024 * numBands)), dataDims);
%
%   for band = 1:numBands
%       for row = 1:2
%          for col = 1:2
%   
%              subsetRows = ((row - 1) * 512 + 1):(row * 512);
%              subsetCols = ((col - 1) * 512 + 1):(col * 512);
%              
%              upperLeft = [subsetRows(1), subsetCols(1), band];
%              multibandwrite(data(subsetRows, subsetCols, band), ...
%                             'banddata.bsq', 'bsq', upperLeft, dataDims);
%              
%          end
%       end
%   end
%
%   See also MULTIBANDREAD, FWRITE, FREAD 

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
        disp('Called the multibandwrite wrapper function.');
    end
    
    % Remove wrapper multibandwrite from the Matlab path
    overloadedFunctPath = which('multibandwrite');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded multibandwrite function.');  
    end
     
    % Call multibandwrite
    multibandwrite( data, source, interleave, varargin{:} );
   
    % Add the wrapper multibandwrite back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded multibandwrite function back.');
    end
    
    % Identifiy the file being used and add a prov:wasGeneratedBy statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_writes )
        
        formatId = 'application/octet-stream';
        
        import org.dataone.client.v2.D1Object;
       
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
     
        runManager.execution.execution_output_ids{end+1} = pid;    
       
    end
end
