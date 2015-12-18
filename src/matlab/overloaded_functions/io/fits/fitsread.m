function data = fitsread(varargin)
%FITSREAD Read data from FITS file
%
%   DATA = FITSREAD(FILENAME) reads data from the primary data of the FITS
%   (Flexible Image Transport System) file FILENAME.  Undefined data values
%   will be replaced by NaN.  Numeric data will be scaled by the slope and
%   intercept values and is always returned in double precision.
%
%   DATA = FITSREAD(FILENAME,OPTIONS) reads data from a FITS file according
%   to the options specified in OPTIONS.  Valid options are:
%
%   EXTNAME      EXTNAME can be either 'primary', 'asciitable', 'binarytable',
%                'image', or 'unknown' for reading data from the primary
%                data array, ASCII table extension, Binary table extension,
%                Image extension or an unknown extension respectively. Only
%                one extension should be supplied. DATA for ASCII and
%                Binary table extensions is a 1-D cell array. The contents
%                of a FITS file can be located in the Contents field of the
%                structure returned by FITSINFO.
%
%   EXTNAME,IDX  Same as EXTNAME except if there is more than one of the
%                specified extension type, the IDX'th one is read.
%
%   'Raw'        DATA read from the file will not be scaled and undefined
%                values will not be replaced by NaN.  DATA will be the same
%                class as it is stored in the file.
%
%   'Info',INFO  When reading from a FITS file multiple times, passing
%                the output of FITSINFO with the 'Info' parameter helps
%                FITSREAD locate the data in the file more quickly.
%
%   'PixelRegion',{ROWS, COLS, ..., N_DIM}  
%                FITSREAD returns the sub-image specified by the boundaries
%                for an N dimensional image. ROWS, COLS, ..., N_DIM are
%                each vectors of 1-based indices given either as START,
%                [START STOP] or [START INCREMENT STOP] selecting the
%                sub-image region for the corresponding dimension. This
%                parameter is valid only for primary or image extensions.
%
%   'TableColumns',COLUMNS
%                COLUMNS is a vector with 1-based indices selecting the
%                columns to read from the ASCII or Binary table extension.
%                This vector should contain unique and valid indices into
%                the table data specified in increasing order. This
%                parameter is valid only for ASCII or Binary extensions.
%
%   'TableRows',ROWS
%                ROWS is a vector with 1-based indices selecting the rows
%                to read from the ASCII or Binary table extension. This
%                vector should contain unique and valid indices into the
%                table data specified in increasing order. This parameter
%                is valid only for ASCII or Binary extensions.
%                
%            
%   Example: Read primary data from file.
%      data = fitsread('tst0012.fits');
%
%   Example: Inspect available extensions, read 'image' extension using the
%   EXTNAME option.
%      info      = fitsinfo('tst0012.fits');
%      % List of contents, includes any extensions if present.
%      disp(info.Contents);
%      imageData = fitsread('tst0012.fits','image');
%
%   Example: Subsample the fifth plane of 'image' extension by 2.
%      info        = fitsinfo('tst0012.fits');
%      rowend      = info.Image.Size(1);
%      colend      = info.Image.Size(2);
%      primaryData = fitsread('tst0012.fits','image',...
%                     'Info', info,...
%                     'PixelRegion',{[1 2 rowend], [1 2 colend], 5 });
%
%   Example: Read every other row from a ASCII table data.
%      info      = fitsinfo('tst0012.fits');
%      rowend    = info.AsciiTable.Rows; 
%      tableData = fitsread('tst0012.fits','asciitable',...
%                   'Info',info,...
%                   'TableRows',[1:2:rowend]);
%
%   Example: Read all data for the first, second and fifth column of the
%   Binary table.
%      info      = fitsinfo('tst0012.fits');
%      rowend    = info.BinaryTable.Rows;       
%      tableData = fitsread('tst0012.fits','binarytable',...
%                   'Info',info,...
%                   'TableColumns',[1 2 5]);
%
%
%   See also FITSWRITE, FITSINFO, FITSDISP, MATLAB.IO.FITS.

%   Copyright 2001-2013 The MathWorks, Inc.

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
    disp('Called the fitsread wrapper function.');
end

% Remove wrapper fitsread from the Matlab path
overloadedFunctPath = which('fitsread');
[overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
rmpath(overloaded_func_path);

if ( runManager.configuration.debug)
    disp('remove the path of the overloaded fitsread function.');
end

% Call fitsread
data = fitsread( varargin{:} );

% Add the wrapper fitsread back to the Matlab path
addpath(overloaded_func_path, '-begin');

if ( runManager.configuration.debug)
    disp('add the path of the overloaded fitsread function back.');
end

% Identifiy the file being used and add a prov:used statement
% in the RunManager DataPackage instance
if ( runManager.configuration.capture_file_reads )
    formatId = 'application/octet-stream';
    
    import org.dataone.client.v2.DataObject;
    
    source = varargin{1};
    
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
        
        runManager.execution.execution_input_ids{end+1} = pid; % Only add to the collection for the first time (Dec-7-2015)
    else
        % Update the existing map entry with a new DataObject
        pid = existing_id;
        dataObject = DataObject(pid, formatId, fullSourcePath);
        runManager.execution.execution_objects(dataObject.identifier) = ...
            dataObject;
    end
    
    % runManager.execution.execution_input_ids{end+1} = pid;
end

end
