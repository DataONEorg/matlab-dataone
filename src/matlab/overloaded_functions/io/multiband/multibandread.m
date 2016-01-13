function im = multibandread(source,dims,precision,...
    offset,interleave,byteOrder,varargin)
%MULTIBANDREAD Read band interleaved data from a binary file
%   X = MULTIBANDREAD(FILENAME,SIZE,PRECISION,
%                      OFFSET,INTERLEAVE,BYTEORDER)
%   reads band-sequential (BSQ), band-interleaved-by-line (BIL), or
%   band-interleaved-by-pixel (BIP) data from a binary file, FILENAME.  X is
%   a 2-D array if only one band is read, otherwise it is 3-D. X is returned
%   as an array of data type double by default.  Use the PRECISION argument
%   to map the data to a different data type.
%
%   X = MULTIBANDREAD(FILENAME,SIZE,PRECISION,OFFSET,INTERLEAVE,
%                    BYTEORDER,SUBSET,SUBSET,SUBSET)
%   reads a subset of the data in the file. Up to 3 SUBSET parameters may be
%   used to subset independently along the Row, Column, and Band dimensions.
%
%   In addition to BSQ, BIL, and BIP files, multiband imagery may be stored 
%   using the TIFF file format.  In that case, the data should be imported
%   with IMREAD.
%
%   Parameters:
%
%     FILENAME: A string containing the name of the file to be read.
%
%     DIMS: A 3 element vector of integers consisting of
%     [HEIGHT, WIDTH, N]. HEIGHT is the total number of rows, WIDTH is
%     the total number of elements in each row, and N is the total number
%     of bands. This will be the dimensions of the data if it read in its
%     entirety.
%
%     PRECISION: A string to specify the format of the data to be read. For
%     example, 'uint8', 'double', 'integer*4'. By default X is returned as
%     an array of class double. Use the PRECISION parameter to format the
%     data to a different class.  For example, a precision of
%     'uint8=>uint8' (or '*uint8') will return the data as a UINT8 array.
%     'uint8=>single' will read each 8 bit pixel and store it in MATLAB in
%     single precision.  MULTIBANDREAD will attempt to use the efficient
%     MEMMAPFILE function if the precision string corresponds to a native
%     MATLAB type.  See the help for FREAD for a more complete description
%     of PRECISION.
%
%     OFFSET: The zero-based location of the first data element in the file.
%     This value represents number of bytes from the beginning of the file
%     to where the data begins.
%
%     INTERLEAVE: The format in which the data is stored.  This can be
%     either 'bsq','bil', or 'bip' for Band-Sequential,
%     Band-Interleaved-by-Line or Band-Interleaved-by-Pixel respectively.
%
%     BYTEORDER: The byte ordering (machine format) in which the data is
%     stored. This can be 'ieee-le' for little-endian or 'ieee-be' for
%     big-endian.  All other machine formats described in the help for FOPEN
%     are also valid values for BYTEORDER.
%
%     SUBSET: (optional) A cell array containing either {DIM,INDEX} or
%     {DIM,METHOD,INDEX}. DIM is one of three strings: 'Column', 'Row', or
%     'Band' specifying which dimension to subset along.  METHOD is 'Direct'
%     or 'Range'. If METHOD is omitted, then the default is 'Direct'. If
%     using 'Direct' subsetting, INDEX is a vector specifying the indices to
%     read along the Band dimension.  If METHOD is 'Range', INDEX is a 2 or
%     3 element vector of [START, INCREMENT, STOP] specifying the range and
%     step size to read along the dimension. If INDEX is 2 elements, then
%     INCREMENT is assumed to be one.
%
%   Examples:
%
%   % Setup initial parameters for a dataset.
%   rows=3; cols=3; bands=5;
%   filename = tempname;
%
%   % Define the dataset.
%   fid = fopen(filename, 'w', 'ieee-le');
%   fwrite(fid, 1:rows*cols*bands, 'double');
%   fclose(fid);
%
%   % Read the every other band of the data using the Band-Sequential format.
%   im1 = multibandread(filename, [rows cols bands], ...
%             'double', 0, 'bsq', 'ieee-le', ...
%             {'Band', 'Range', [1 2 bands]} )
%
%   % Read the first two rows and columns of data using
%   % Band-Interleaved-by-Pixel format.
%   im2 = multibandread(filename, [rows cols bands], ...
%             'double', 0, 'bip', 'ieee-le', ...
%             {'Row', 'Range', [1 2]}, ...
%             {'Column', 'Range', [1 2]} )
%
%   % Read the data using Band-Interleaved-by-Line format.
%   im3 = multibandread(filename, [rows cols bands], ...
%             'double', 0, 'bil', 'ieee-le')
%
%   % Delete the file that we created.
%        delete(filename);
%
%   % The FITS file 'tst0012.fits' contains int16 BIL data starting at
%   % byte 74880.
%   im4 = multibandread( 'tst0012.fits', [31 73 5], ...
%             'int16', 74880, 'bil', 'ieee-be', ...
%             {'Band', 'Range', [1 3]} );
%   im5 = double(im4)/max(max(max(im4)));
%   imagesc(im5);
%
%   See also FREAD, FWRITE, IMREAD, MEMMAPFILE, MULTIBANDWRITE.

%   Copyright 2001-2014 The MathWorks, Inc.

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
        disp('Called the multibandread wrapper function.');
    end
    
    % Remove wrapper multibandread from the Matlab path
    overloadedFunctPath = which('multibandread');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded multibandread function.');  
    end
     
    % Call multibandread 
    im = multibandread(source,dims,precision,...
        offset,interleave,byteOrder,varargin{:});
    
    % Add the wrapper multibandread back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded multibandread function back.');
    end
    
    % Identifiy the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_reads )
        formatId = 'application/octet-stream';
        
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
