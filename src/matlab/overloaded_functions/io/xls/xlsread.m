function varargout = xlsread(varargin)

% XLSREAD Read Microsoft Excel spreadsheet file.
%   [NUM,TXT,RAW]=XLSREAD(FILE) reads data from the first worksheet in
%   the Microsoft Excel spreadsheet file named FILE and returns the numeric
%   data in array NUM. Optionally, returns the text fields in cell array
%   TXT, and the unprocessed data (numbers and text) in cell array RAW.
%
%   [NUM,TXT,RAW]=XLSREAD(FILE,SHEET) reads the specified worksheet.
%
%   [NUM,TXT,RAW]=XLSREAD(FILE,SHEET,RANGE) reads from the specified SHEET
%   and RANGE. Specify RANGE using the syntax 'C1:C2', where C1 and C2 are
%   opposing corners of the region. Not supported for XLS files in BASIC
%   mode.
%
%   [NUM,TXT,RAW]=XLSREAD(FILE,SHEET,RANGE,'basic') reads from the
%   spreadsheet in BASIC mode, the default on systems without Excel
%   for Windows. RANGE is supported for XLSX files only.
%
%   [NUM,TXT,RAW]=XLSREAD(FILE,RANGE) reads data from the specified RANGE
%   of the first worksheet in the file. Not supported for XLS files in
%   BASIC mode.
%
%   The following syntaxes are supported only on Windows systems with Excel
%   software:
%
%   [NUM,TXT,RAW]=XLSREAD(FILE,-1) opens an Excel window to select data
%   interactively.
%
%   [NUM,TXT,RAW,CUSTOM]=XLSREAD(FILE,SHEET,RANGE,'',FUNCTIONHANDLE)
%   reads from the spreadsheet, executes the function associated with
%   FUNCTIONHANDLE on the data, and returns the final results. Optionally,
%   returns additional CUSTOM output, which is the second output from the
%   function. XLSREAD does not change the data stored in the spreadsheet.
%
%   Input Arguments:
%
%   FILE    String that specifies the name of the file to read.
%   SHEET   Worksheet to read. One of the following:
%           * String that contains the worksheet name.
%           * Positive, integer-valued scalar indicating the worksheet
%             index.
%   RANGE   String that specifies a rectangular portion of the worksheet to
%           read. Not case sensitive. Use Excel A1 reference style.
%           If you do not specify a SHEET, RANGE must include both corners
%           and a colon character (:), even for a single cell (such as
%           'D2:D2').
%   'basic' Flag to request reading in BASIC mode, which is the default for
%           systems without Excel for Windows.  In BASIC mode, XLSREAD:
%           * Only reads XLS or XLSX files.
%           * For XLS files, imports the entire active range of the worksheet.
%           * For XLS files, requires a string to specify the SHEET, and the
%             name is case sensitive.
%           * Does not support function handle inputs.
%   -1      Flag to open an interactive Excel window for selecting data.
%           Select the worksheet, drag and drop the mouse over the range
%           you want, and click OK. Supported only on Windows systems with
%           Excel software.
%   FUNCTIONHANDLE
%           Handle to your custom function.  When XLSREAD calls your
%           function, it passes a range interface from Excel to provide
%           access to the data. Your function must include this interface
%           (of type 'Interface.Microsoft_Excel_5.0_Object_Library.Range',
%           for example) both as an input and output argument.
%
%   Notes:
%
%   * On Windows systems with Excel software, XLSREAD reads any file
%     format recognized by your version of Excel, including XLS, XLSX,
%     XLSB, XLSM, and HTML-based formats.
%
%   * If your system does not have Excel for Windows, XLSREAD operates in
%     BASIC mode (see Input Arguments).
%
%   * XLSREAD imports formatted dates as strings (such as '10/31/96'),
%     except in BASIC mode. In BASIC mode, XLSREAD imports all dates as
%     serial date numbers. Serial date numbers in Excel use different
%     reference dates than date numbers in MATLAB. For information on
%     converting dates, see the documentation on importing spreadsheets.
%
%   Examples:
%
%   % Create data for use in the examples that follow:
%   values = {1, 2, 3 ; 4, 5, 'x' ; 7, 8, 9};
%   headers = {'First', 'Second', 'Third'};
%   xlswrite('myExample.xls', [headers; values]);
%   moreValues = rand(5);
%   xlswrite('myExample.xls', moreValues, 'MySheet');
%
%   % Read data from the first worksheet into a numeric array:
%   A = xlsread('myExample.xls')
%
%   % Read a specific range of data:
%   subsetA = xlsread('myExample.xls', 1, 'B2:C3')
%
%   % Read from a named worksheet:
%   B = xlsread('myExample.xls', 'MySheet')
%
%   % Request the numeric data, text, and a copy of the unprocessed (raw)
%   % data from the first worksheet:
%   [ndata, text, alldata] = xlsread('myExample.xls')
%
%   See also XLSWRITE, XLSFINFO, DLMREAD, IMPORTDATA, TEXTSCAN.

%   Copyright 1984-2011 The MathWorks, Inc.

% This work was created by participants in the DataONE project, and is
% jointly copyrighted by participating institutions in DataONE. For
% more information on DataONE, see our web site at http://dataone.org.
%
%   Copyright 2016 DataONE
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
        disp('Called the xlsread wrapper function.');
    end
    
    % Remove wrapper xlsread from the Matlab path
    overloadedFunctPath = which('xlsread');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded xlsread function.');  
    end
     
    % Call xlsread 
    source = varargin{1};
    [varargout{1:nargout}] = xlsread( varargin{:} );
    
    % Add the wrapper xlsread back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded xlsread function back.');
    end
    
    % Identifiy the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_reads )
        formatId = 'application/vnd.ms-excel';
        
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
            d1Object = DataObject(pid, formatId, fullSourcePath);
            runManager.execution.execution_objects(d1Object.identifier) = ...
                d1Object;
        else
            % Update the existing map entry with a new D1Object
            pid = existing_id;
            d1Object = DataObject(pid, formatId, fullSourcePath);
            runManager.execution.execution_objects(d1Object.identifier) = ...
                d1Object;
        end
        
        if ( ~ ismember(pid, runManager.execution.execution_input_ids) )
            runManager.execution.execution_input_ids{end+1} = pid;
        end
    end
    
end
