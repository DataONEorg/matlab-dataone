function varargout = textread(varargin)
%TEXTREAD Read formatted data from text file.
%    A = TEXTREAD('FILENAME')
%    A = TEXTREAD('FILENAME','',N)
%    A = TEXTREAD('FILENAME','',param,value, ...)
%    A = TEXTREAD('FILENAME','',N,param,value, ...) reads numeric data from
%    the file FILENAME into a single variable.  If the file contains any
%    text data, an error is produced.
%
%    [A,B,C, ...] = TEXTREAD('FILENAME','FORMAT')
%    [A,B,C, ...] = TEXTREAD('FILENAME','FORMAT',N)
%    [A,B,C, ...] = TEXTREAD('FILENAME','FORMAT',param,value, ...)
%    [A,B,C, ...] = TEXTREAD('FILENAME','FORMAT',N,param,value, ...) reads
%    data from the file FILENAME into the variables A,B,C,etc.  The type of
%    each return argument is given by the FORMAT string.  The number of
%    return arguments must match the number of conversion specifiers in the
%    FORMAT string.  If there are fewer fields in the file than in the
%    format string, an error is produced.  See FORMAT STRINGS below for
%    more information.
%
%    If N is specified, the format string is reused N times.  If N is -1 (or
%    not specified) TEXTREAD reads the entire file.
%
%    If param,value pairs are supplied, user configurable options customize
%    the behavior of TEXTREAD.  See USER CONFIGURABLE OPTIONS below.
%
%    TEXTREAD works by matching and converting groups of characters from the
%    file. An input field is defined as a string of non-whitespace
%    characters extending to the next whitespace or delimiter character
%    or until the field width is exhausted.  Repeated delimiter characters
%    are significant while repeated whitespace characters are treated as
%    one.
%
%    FORMAT STRINGS
%
%    If the FORMAT string is empty, TEXTREAD will only numeric data.
%
%    The FORMAT string can contain whitespace characters (which are
%    ignored), ordinary characters (which are expected to match the next
%    non-whitespace character in the input), or conversion specifications.
%
%    Supported conversion specifications:
%        %n - read a number - float or integer (returns double array)
%             %5n reads up to 5 digits or until next delimiter
%        %d - read a signed integer value (returns double array)
%             %5d reads up to 5 digits or until next delimiter
%        %u - read an integer value (returns double array)
%             %5u reads up to 5 digits or until next delimiter
%        %f - read a floating point value (returns double array)
%             %5f reads up to 5 digits or until next delimiter
%        %s - read a whitespace separated string (returns cellstr)
%             %5s reads up to 5 characters or until whitespace
%        %q - read a double-quoted string, ignoring the quotes (returns cellstr)
%             %5q reads up to 5 non-quote characters or until whitespace
%        %c - read character or whitespace (returns char array)
%             %5c reads up to 5 characters including whitespace
%        %[...]  - reads characters matching characters between the
%                  brackets until first non-matching character or
%                  whitespace (returns cellstr)
%                  use %[]...] to include ]
%             %5[...] reads up to 5 characters
%        %[^...] - reads characters not matching characters between the
%                  brackets until first matching character or whitespace
%                  (returns cellstr)
%                  use %[^]...] to exclude ]
%             %5[^...] reads up to 5 characters
%
%    Note: Format strings are interpreted as with sprintf before parsing.
%    For example, textread('mydata.dat','%s\t') will search for a tab not
%    the character '\' followed by the character 't'.  See the Language
%    Reference Guide or a C manual for complete details.
%
%    Using %* instead of % in a conversion causes TEXTREAD to skip the
%    matching characters in the input (and no output is created for this
%    conversion).
%
%    The % can be followed by an optional field width to handle fixed 
%    width fields. For example %5d reads a 5 digit integer. In
%    addition the %f format supports the form %<width>.<prec>f.
%
%    USER CONFIGURABLE OPTIONS
%
%    Possible param/value options are:
%         'bufsize'      - maximum string length in bytes (default is 4095)
%         'commentstyle' - one of 
%              'matlab'  -- characters after % are ignored
%              'shell'   -- characters after # are ignored
%              'c'       -- characters between /* and */ are ignored
%              'c++'    -- characters after // are ignored
%         'delimiter'    - delimiter characters (default is none)
%         'emptyvalue'   - empty cell value in delimited files (default is 0)
%         'endofline'    - end of line character (default determined from file)
%         'expchars'     - exponent characters (default is 'eEdD')
%         'headerlines'  - number of lines at beginning of file to skip
%         'whitespace'   - whitespace characters (default is ' \b\t')
%    
%    TEXTREAD is useful for reading text files with a known format.  Both
%    fixed and free format files can be handled.
%
%    Examples:
%     Suppose the text file mydata.dat contains data in the following form:
%        Sally    Type1 12.34 45 Yes
%        Joe      Type2 23.54 60 No
%        Bill     Type1 34.90 12 No
%          
%     Read each column into a variable
%       [names,types,x,y,answer] = textread('mydata.dat','%s%s%f%d%s');
%
%     Read first column into a cell array (skipping rest of line)
%       [names]=textread('mydata.dat','%s%*[^\n]')
%
%     Read first character into char array (skipping rest of line)
%       [initials]=textread('mydata.dat','%c%*[^\n]')
%
%     Read file as a fixed format file while skipping the doubles
%       [names,types,y,answer] = textread('mydata.dat','%9c%5s%*f%2d%3s');
%
%     Read file and match Type literal
%       [names,typenum,x,y,answer]=textread('mydata.dat','%sType%d%f%d%s');
%
%     Read MATLAB file into cell array of strings
%       file = textread('fft.m','%s','delimiter','\n','whitespace','');
%
%     To read all numeric data from a delimited text file, use a single output
%     argument, empty format string, and the appropriate delimiter. For 
%     example, suppose data.csv contains:
%       1,2,3,4
%       5,6,7,8
%       9,10,11,12
%
%     Read the whole matrix into a single variable:
%       [data] = textread('data.csv','','delimiter',',');
%
%     Read the first two columns into two variables:
%       [col1, col2] = textread('data.csv','%n%n%*[^\n]','delimiter',',');
%
%     For files with empty cells, use the emptyvalue parameter.  Suppose
%     data.csv contains:
%       1,2,3,4,,6
%       7,8,9,,11,12
%
%     Read the file like this, using NaN in empty cells:
%       [data] = textread('data.csv','','delimiter',',','emptyvalue',NaN);
%
%   TEXTREAD is not recommended. Use TEXTSCAN instead.
%
%   See also TEXTSCAN, STRREAD, DLMREAD, LOAD, SSCANF, XLSREAD.

%   Copyright 1984-2011 The MathWorks, Inc.

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
        disp('Called the textread wrapper function.');
    end
    
    % Remove wrapper textread from the Matlab path
    overloadedFunctPath = which('textread');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded textread function.');  
    end
     
    % Call textread 
    [varargout{1:nargout}] = textread( varargin{:} );
    
    % Add the wrapper textread back to the Matlab path
    warning off MATLAB:dispatcher:nameConflict;
    addpath(overloaded_func_path, '-begin');
    warning on MATLAB:dispatcher:nameConflict;
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded textread function back.');
    end
    
    % Identifiy the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_reads )
        formatId = 'text/csv';
        import org.dataone.client.v2.DataObject;

        if ischar(varargin{1}) % textread('filename', ...)
            file_name = varargin{1};            
            fullSourcePath = which(file_name);
            
            if isempty(fullSourcePath)
                [status, struc] = fileattrib(file_name);
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
end