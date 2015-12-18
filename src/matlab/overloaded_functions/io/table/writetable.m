function writetable(T,source,varargin)
%WRITETABLE Write a table to a file.
%   WRITETABLE(T) writes the table T to a comma-delimited text file.  The file name
%   is the workspace name of the table T, appended with '.txt'.  If WRITETABLE cannot
%   construct the file name from the table input, it writes to the file
%   'table.txt'.  WRITETABLE overwrites any existing file.
%
%   WRITETABLE(T,FILENAME) writes the table T to the file FILENAME as column-oriented
%   data.  WRITETABLE determines the file format from its extension.  The extension
%   must be one of those listed below.
%
%   WRITETABLE(T,FILENAME,'FileType',FILETYPE) specifies the file type, where
%   FILETYPE is one of 'text' or 'spreadsheet'.
%
%   WRITETABLE writes data to different file types as follows:
%
%   .txt, .dat, .csv:  Delimited text file (comma-delimited by default).
%
%          WRITETABLE creates a column-oriented text file, i.e., each column of
%          each variable in T is written out as a column in the file.  T's
%          variable names are written out as column headings in the first line
%          of the file.
%
%          Use the following optional parameter name/value pairs to control how
%          data are written to a delimited text file:
%
%          'Delimiter'      The delimiter used in the file.  Can be any of ' ',
%                           '\t', ',', ';', '|' or their corresponding string
%                           names 'space', 'tab', 'comma', 'semi', or 'bar'.
%                           Default is ','.
%
%          'WriteVariableNames'  A logical value that specifies whether or not
%                           T's variable names are written out as column headings.
%                           Default is true.
%
%          'WriteRowNames'  A logical value that specifies whether or not T's
%                           row names are written out as first column of the
%                           file.  Default is false.  If the 'WriteVariableNames'
%                           and 'WriteRowNames' parameter values are both true,
%                           T's first dimension name is written out as the column
%                           heading for the first column of the file.
%
%          'QuoteStrings'   A logical value that specifies whether to write strings
%                           out enclosed in double quotes ("..."). If 'QuoteStrings'
%                           is true, any double quote characters that appear as part
%                           of a string are replaced by two double quote characters.
%
%   .xls, .xlsx, .xlsb, .xlsm:  Spreadsheet file.
%
%          WRITETABLE creates a column-oriented spreadsheet file, i.e., each
%          column of each variable in T is written out as a column in the file.
%          T's variable names are written out as column headings in the first
%          row of the file.
%
%          Use the following optional parameter name/value pairs to control how
%          data are written to a spreadsheet file:
%
%          'WriteVariableNames'  A logical value that specifies whether or not
%                           T's variable names are written out as column headings.
%                           Default is true.
%
%          'WriteRowNames'  A logical value that specifies whether or not T's row
%                           names are written out as first column of the specified
%                           region of the file.  Default is false.  If the
%                           'WriteVariableNames' and 'WriteRowNames' parameter values
%                           are both true, T's first dimension name is written out as
%                           the column heading for the first column.
%
%          'Sheet'          The sheet to write, specified as a string that contains
%                           the worksheet name, or a positive integer indicating the
%                           worksheet index.
%
%          'Range'          A string that specifies a rectangular portion of the
%                           worksheet to write, using the Excel A1 reference style.
%
%   In some cases, WRITETABLE creates a file that does not represent T exactly,
%   as described below.  If you use TABLE(FILENAME) to read that file back in
%   and create a new table, the result may not have exactly the same format or
%   contents as the original table.
%
%   *  WRITETABLE writes out numeric variables using long g format, and
%      categorical or character variables as unquoted strings.
%   *  For non-character variables that have more than one column, WRITETABLE
%      writes out multiple delimiter-separated fields on each line, and
%      constructs suitable column headings for the first line of the file.
%   *  WRITETABLE writes out variables that have more than two dimensions as two
%      dimensional variables, with trailing dimensions collapsed.
%   *  For cell-valued variables, WRITE writes out the contents of each cell
%      as a single row, in multiple delimiter-separated fields, when the
%      contents are numeric, logical, character, or categorical, and writes
%      out a single empty field otherwise.
%
%   Save T as a mat file if you need to import it again as a table.
%
%   See also TABLE, READTABLE.

%   Copyright 2012-2014 The MathWorks, Inc.
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
        disp('Called the writetable wrapper function.');
    end

    % Remove wrapper writetable from the Matlab path
    overloadedFunctPath = which('writetable');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);

    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded writetable function.');
    end

    % Call writetable
    writetable( T, source, varargin{:} );

    % Add the wrapper writetable back to the Matlab path
    addpath(overloaded_func_path, '-begin');

    if ( runManager.configuration.debug)
        disp('add the path of the overloaded writetable function back.');
    end

    % Identifiy the file being used and add a prov:wasGeneratedBy statement
    % in the RunManager DataPackage instance
    if ( runManager.configuration.capture_file_writes )
        formatId = 'text/csv';
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
    
        runManager.execution.execution_output_ids{end+1} = pid;
    end

end
