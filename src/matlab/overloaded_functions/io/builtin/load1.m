function S = load( source, varargin )
% LOAD Load data from MAT-file into workspace.
%   S = LOAD(FILENAME) loads the variables from a MAT-file into a structure
%   array, or data from an ASCII file into a double-precision array.
%
%   S = LOAD(FILENAME, VARIABLES) loads only the specified variables from a
%   MAT-file.  VARIABLES use one of the following forms:
%
%       VAR1, VAR2, ...          Load the listed variables.  Use the '*'
%                                wildcard to match patterns.  For
%                                example, load('A*') loads all variables
%                                that start with A.
%       '-regexp', EXPRESSIONS   Load only the variables that match the
%                                specified regular expressions.  For more
%                                information on regular expressions, type
%                                "doc regexp" at the command prompt.
%
%   S = LOAD(FILENAME, '-mat', VARIABLES) forces LOAD to treat the file as
%   a MAT-file, regardless of the extension.  Specifying VARIABLES is
%   optional.
%
%   S = LOAD(FILENAME, '-ascii') forces LOAD to treat the file as an ASCII
%   file, regardless of the extension.
%
%   LOAD(...) loads without combining MAT-file variables into a structure
%   array.
%
%   LOAD ... is the command form of the syntax, for convenient loading from
%   the command line. With command syntax, you do not need to enclose input
%   strings in single quotation marks. Separate inputs with spaces instead 
%   of commas. Do not use command syntax if FILENAME is a variable.
%   
%   Notes:
%
%   If you do not specify FILENAME, the LOAD function searches for a file
%   named matlab.mat.
%
%   ASCII files must contain a rectangular table of numbers, with an equal
%   number of elements in each row.  The file delimiter (character between
%   each element in a row) can be a blank, comma, semicolon, or tab.  The
%   file can contain MATLAB comments.
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

    import org.dataone.client.run.RunManager;
    
    runManager = RunManager.getInstance();
 
    if ( runManager.configuration.debug )
        disp('Called the load wrapper function.');
    end
    
    % Remove wrapper load from the Matlab path
    overloadedFunctPath = which('load');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded load function.');  
    end
    
    % Call builtin load function
    S = builtin('load', source, varargin{:} );
    % varargout = builtin('load', source, varargin{:} );
    % varargout = load( source, varargin{:} );
    % S = varargout;
    
    %S = varargout;
    
    % Add the wrapper load back to the Matlab path
    warning off MATLAB:dispatcher:nameConflict;
    addpath(overloaded_func_path, '-begin');
    warning on MATLAB:dispatcher:nameConflict;
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded load function back.');
    end
    
    % Identifiy the file being used and add a prov:used statement 
    % in the RunManager DataPackage instance    
    if ( runManager.configuration.capture_file_reads )
        exec_input_id_list = runManager.getExecInputIds();
    
        fullSourcePath = which(source);
        if isempty(fullSourcePath)
            [status, struc] = fileattrib(source);
            if status ~= 0
                fullSourcePath = struc.Name;
            end
        end
    
        if ~isempty(fullSourcePath)
            exec_input_id_list.put(fullSourcePath, 'text/plain');
        end
    end
end