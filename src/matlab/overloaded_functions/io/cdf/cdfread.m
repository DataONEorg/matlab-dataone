function [data, info] = cdfread(source, varargin)
%CDFREAD Read the data from a CDF file.
%   DATA = CDFREAD(FILE) reads all of the variables from each record of
%   FILE.  DATA is a cell array, where each row is a record and each
%   column a variable.  Every piece of data from the CDF file is read 
%   and returned.   
%
%   Note:  When working with large data files, use of the 
%   'ConvertEpochToDatenum' and 'CombineRecords' options can 
%   significantly improve performance.
% 
%   DATA = CDFREAD(FILE, 'Records', RECNUMS, ...) reads particular
%   records from a CDF file.  RECNUMS is a vector of one or more
%   zero-based record numbers to read.  DATA is a cell array with
%   length(RECNUM) number of rows.  There are as many columns as
%   variables.
% 
%   DATA = CDFREAD(FILE, 'Variables', VARNAMES, ...) reads the variables
%   in the cell array VARNAMES from a CDF file.  DATA is a cell array
%   with length(VARNAMES) number of columns.  There is a row for each
%   record requested.
% 
%   DATA = CDFREAD(FILE, 'Slices', DIMENSIONVALUES, ...) reads specified
%   values from one variable in the CDF file.  The matrix DIMENSIONVALUES
%   is an m-by-3 array of "start", "interval", and "count" values.  The
%   "start" values are zero-based.
%
%   The number of rows in DIMENSIONVALUES must be less than or equal to
%   the number dimensions of the variable.  Unspecified rows are filled
%   with the values [0 1 N] to read every value from those dimensions.
% 
%   When using the 'Slices' parameter, only one variable can be read at a
%   time, so the 'Variables' parameter must be used.
% 
%   DATA = CDFREAD(FILE, 'ConvertEpochToDatenum', TF, ...) converts epoch
%   datatypes to MATLAB datenum values if TF is true.  If TF is false
%   (the default), epoch values are wrapped in CDFEPOCH objects, which
%   can hurt performance for large datasets.
%
%   DATA = CDFREAD(FILE, 'CombineRecords', TF, ...) combines all of the
%   records into a cell array with only one row if TF is true.  Because
%   variables in CDF files can contain nonscalar data, the default value
%   (false) causes the data to be read into an M-by-N cell array, where M
%   is the number of records and N is the number of variables requested.
%
%   When TF is true, all records for each variable are combined into one
%   cell in the output cell array.  The data of scalar variables is
%   imported into a column array.  Importing nonscalar and string data
%   extends the dimensionality of the imported variable.  For example,
%   importing 1000 records of a 1-byte variable with dimensions 20-by-30
%   yields a cell containing a 1000-by-20-by-30 UINT8 array.
%
%   When using the 'Variables' parameters to read one variable, if the
%   'CombineRecords' parameter is true, the result is an M-by-N numeric
%   or character array; the data is not put into a cell array. 
%
%   Specifying the 'CombineRecords' parameter with a true value of TF can
%   greatly improve the speed of importing large CDF datasets and reduce
%   the size of the MATLAB cell array containing the data.
%
%   [DATA, INF0] = CDFREAD(FILE, ...) also returns details about the CDF
%   file in the INFO structure.
%
%   Notes:
%
%     CDFREAD creates temporary files when accessing CDF files.  The
%     current working directory must be writeable.
%
%     To maximize performance, provide the 'ConvertEpochToDatenum' and
%     'CombineRecords' parameters with true (nonzero) values.
%
%     It is currently not possible to provide a set of records to read
%     (using the 'Records' parameter) and to combine records (using the
%     'CombineRecords' parameter).
%
%     CDFREAD performance can be noticeably influenced by the file 
%     validation done by default by the CDF library.  Please consult
%     the CDFLIB package documentation for information on controlling
%     the validation process.
%
%   Examples:
%
%   % Read all of the data from the file.
%
%   data = cdfread('example.cdf');
%
%   % Read just the data from variable "Time".
%
%   data = cdfread('example.cdf', ...
%                    'Variables', {'Time'});
%
%   % Read the first value in the first dimension, the second value in
%   % the second dimension, the first and third values in the third
%   % dimension, and all of the values in the remaining dimension of
%   % the variable "multidimensional".  
%
%   data = cdfread('example.cdf', ...
%                  'Variables', {'multidimensional'}, ...
%                  'Slices', [0 1 1; 1 1 1; 0 2 2]);
%
%   % The example above is analogous to reading the whole variable 
%   % into a variable called "data" and then using matrix indexing, 
%   % as follows:
%
%   data = cdfread('example.cdf', ...
%                  'Variables', {'multidimensional'});
%   data{1}(1, 2, [1 3], :)
%
%   % Collapse the records from a dataset and convert CDF epoch datatypes
%   % to MATLAB datenums.
%
%   data = cdfread('example.cdf', ...
%                  'CombineRecords', true, ...
%                  'ConvertEpochToDatenum', true);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also CDFEPOCH, CDFINFO, CDFWRITE, CDFLIB.GETVALIDATE, 
%   CDFLIB.SETVALIDATE.

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
        disp('Called the cdfread wrapper function.');
    end
    
    % Remove wrapper cdfread from the Matlab path
    overloadedFunctPath = which('cdfread');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug )
        disp('remove the path of the overloaded cdfread function.');  
    end
     
    % Call cdfread 
    [data, info] = cdfread( source, varargin{:} );
    
    % Add the wrapper cdfread back to the Matlab path
    warning off MATLAB:dispatcher:nameConflict;
    addpath(overloaded_func_path, '-begin');
    warning on MATLAB:dispatcher:nameConflict;
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded cdfread function back.');
    end
    
    % Identifiy the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_reads )
        formatId = 'application/octet-stream'; % Todo: what is the correct object format for common data format (cdf). 
                                         % Temporary to borrow: Network Common Data Format
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
