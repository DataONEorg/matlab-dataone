function dlmwrite(source, m, varargin)
%DLMWRITE Write ASCII delimited file.
%
%   DLMWRITE('FILENAME',M) writes matrix M into FILENAME using ',' as the
%   delimiter to separate matrix elements.
%
%   DLMWRITE('FILENAME',M,'DLM') writes matrix M into FILENAME using the
%   character DLM as the delimiter.
%
%   DLMWRITE('FILENAME',M,'DLM',R,C) writes matrix M starting at
%   offset row R, and offset column C in the file.  R and C are zero-based,
%   so that R=C=0 specifies the first value in the file.
%
%   DLMWRITE('FILENAME',M,'ATTRIBUTE1','VALUE1','ATTRIBUTE2','VALUE2'...)
%   An alternative calling syntax that uses attribute value pairs for
%   specifying optional arguments to DLMWRITE. The order of the
%   attribute-value pairs does not matter, as long as an appropriate value
%   follows each attribute tag. 
%
%	DLMWRITE('FILENAME',M,'-append')  appends the matrix to the file.
%	without the flag, DLMWRITE overwrites any existing file.
%
%	DLMWRITE('FILENAME',M,'-append','ATTRIBUTE1','VALUE1',...)  
%	Is the same as the previous syntax, but accepts attribute value pairs,
%	as well as the '-append' flag.  The flag can be placed in the argument
%	list anywhere between attribute value pairs, but not between an
%	attribute and its value.
%
%   USER CONFIGURABLE OPTIONS
%
%   ATTRIBUTE : a quoted string defining an Attribute tag. The following 
%               attribute tags are valid -
%       'delimiter' =>  Delimiter string to be used in separating matrix
%                       elements.
%       'newline'   =>  'pc' Use CR/LF as line terminator
%                       'unix' Use LF as line terminator
%       'roffset'   =>  Zero-based offset, in rows, from the top of the
%                       destination file to where the data it to be
%                       written.                       
%       'coffset'   =>  Zero-based offset, in columns, from the left side
%                       of the destination file to where the data is to be
%                       written.
%       'precision' =>  Numeric precision to use in writing data to the
%                       file, as significant digits or a C-style format
%                       string, starting with '%', such as '%10.5f'.  Note
%                       that this uses the operating system standard
%                       library to truncate the number.
%
%
%   EXAMPLES:
%
%   DLMWRITE('abc.dat',M,'delimiter',';','roffset',5,'coffset',6,...
%   'precision',4) writes matrix M to row offset 5, column offset 6, in
%   file abc.dat using ; as the delimiter between matrix elements.  The
%   numeric precision is of the data is set to 4 significant decimal
%   digits.
%
%   DLMWRITE('example.dat',M,'-append') appends matrix M to the end of 
%   the file example.dat. By default append mode is off, i.e. DLMWRITE
%   overwrites the existing file.
%
%   DLMWRITE('data.dat',M,'delimiter','\t','precision',6) writes M to file
%   'data.dat' with elements delimited by the tab character, using a precision
%   of 6 significant digits.
%   
%   DLMWRITE('file.txt',M,'delimiter','\t','precision','%.6f') writes M
%   to file file.txt with elements delimited by the tab character, using a
%   precision of 6 decimal places. 
%
%   DLMWRITE('example2.dat',M,'newline','pc') writes M to file
%   example2.dat, using the conventional line terminator for the PC
%   platform.
%
%   See also DLMREAD, CSVWRITE, NUM2STR, SPRINTF.

%   Brian M. Bourgault 10/22/93
%   Modified: JP Barnard, 26 September 2002.
%             Michael Theriault, 6 November 2003 
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

    disp('Called the dlmwrite wrapper function.');

    % Remove wrapper dlmwrite from the Matlab path
    overloadedFunctPath = which('dlmwrite');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    disp('remove the path of the overloaded dlmwrite function.');  
    
    % Call dlmwrite
    dlmwrite( source, m, varargin{:} );
   
    % Add the wrapper dlmwrite back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    disp('add the path of the overloaded dlmwrite function back.');
    
    % Identifiy the file being used and add a prov:wasGeneratedBy statement 
    % in the RunManager DataPackage instance

    import org.dataone.client.run.RunManager;
    import java.net.URI;
    
    runManager = RunManager.getInstance();   
   
    exec_output_id_list = runManager.getExecOutputIds();
    
    fullSourcePath = which(source);
    if isempty(fullSourcePath)
        [status, struc] = fileattrib(source);
        fullSourcePath = struc.Name;
    end
    
    % Todo: determine the object format for dlmwrite type
    exec_output_id_list.put(fullSourcePath, 'text/plain');
end