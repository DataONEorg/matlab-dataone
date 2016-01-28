function cdfwrite(source, varcell, varargin)
%CDFWRITE Write data to a CDF file.
%   CDFWRITE is not recommended.  Use CDFLIB instead.
% 
%   CDFWRITE(FILE, VARIABLELIST) writes out a CDF file whose name
%   is specified by FILE.  VARIABLELIST is a cell array of ordered
%   pairs, which are comprised of a CDF variable name (a string) and
%   the corresponding CDF variable value.  To write out multiple records
%   for a variable, put the variable values in a cell array, where each
%   element in the cell array represents a record.
%
%   CDFWRITE(..., 'PadValues', PADVALS) writes out pad values for given
%   variable names.  PADVALS is a cell array of ordered pairs, which
%   are comprised of a variable name (a string) and a corresponding 
%   pad value.  Pad values are the default value associated with the
%   variable when an out-of-bounds record is accessed.  Variable names
%   that appear in PADVALS must appear in VARIABLELIST.
%
%   CDFWRITE(..., 'GlobalAttributes', GATTRIB) writes the structure
%   GATTRIB as global meta-data for the CDF.  Each field of the
%   struct is the name of a global attribute.  The value of each
%   field contains the value of the attribute.  To write out
%   multiple values for an attribute, the field value should be a
%   cell array.
%
%   In order to specify a global attribute name that is illegal in
%   MATLAB, create a field called "CDFAttributeRename" in the 
%   attribute struct.  The "CDFAttribute Rename" field must have a value
%   which is a cell array of ordered pairs.  The ordered pair consists
%   of the name of the original attribute, as listed in the 
%   GlobalAttributes struct and the corresponding name of the attribute
%   to be written to the CDF.
%
%   CDFWRITE(..., 'VariableAttributes', VATTRIB) writes the
%   structure VATTRIB as variable meta-data for the CDF.  Each
%   field of the struct is the name of a variable attribute.  The
%   value of each field should be an mx2 cell array where m is the
%   number of variables with attributes.  The first element in the
%   cell array should be the name of the variable and the second
%   element should be the value of the attribute for that variable.
%
%   In order to specify a variable attribute name that is illegal in
%   MATLAB, create a field called "CDFAttributeRename" in the 
%   attribute struct.  The "CDFAttribute Rename" field must have a value
%   which is a cell array of ordered pairs.  The ordered pair consists
%   of the name of the original attribute, as listed in the 
%   VariableAttributes struct and the corresponding name of the attribute
%   to be written to the CDF.   If you are specifying a variable attribute
%   of a CDF variable that you are re-naming, the name of the variable in
%   the VariableAttributes struct must be the same as the re-named variable.
%
%   CDFWRITE(..., 'WriteMode', MODE) where MODE is either 'overwrite'
%   or 'append' indicates whether or not the specified variables or 
%   should be appended to the CDF if the file already exists.  The 
%   default is 'overwrite', indicating that CDFWRITE will not append
%   variables and attributes.
%
%   CDFWRITE(..., 'Format', FORMAT) where FORMAT is either 'multifile'
%   or 'singlefile' indicates whether or not the data is written out
%   as a multi-file CDF.  In a multi-file CDF, each variable is stored
%   in a *.vN file where N is the number of the variable that is
%   written out to the CDF.  The default is 'singlefile', which indicates
%   that CDFWRITE will write out a single file CDF.  When the 'WriteMode'
%   is set to 'Append', the 'Format' option is ignored, and the format
%   of the pre-existing CDF is used.
%
%   CDFWRITE(..., 'Version', VERSION) where VERSION is a string which 
%   specifies the version of the CDF library to use in writing the file.
%   The default option is to use the latest version of the library 
%   (which is currently version 3.1), and may be specified '3.0'.  The 
%   other available version is version 2.7 ('2.7').  Note that 
%   versions of MATLAB before R2006b will not be able to read files 
%   which were written with CDF versions greater than 3.0.
%
%
%   Notes:
%
%     CDFWRITE creates temporary files when writing CDF files.  Both the
%     target directory for the file and the current working directory
%     must be writeable.
%
%     CDFWRITE performance can be noticeably influenced by the file 
%     validation done by default by the CDF library.  Please consult
%     the CDFLIB package documentation for information on controlling
%     the validation process.
%
%
%   Examples:
%
%   % Write out a file 'example.cdf' containing a variable 'Longitude'
%   % with the value [0:360]:
%
%   cdfwrite('example', {'Longitude', 0:360});
%
%   % Write out a file 'example.cdf' containing variables 'Longitude'
%   % and 'Latitude' with the variable 'Latitude' having a pad value
%   % of 10 for all out-of-bounds records that are accessed:
%
%   cdfwrite('example', {'Longitude', 0:360, 'Latitude', 10:20}, ...
%            'PadValues', {'Latitude', 10});
%
%   % Write out a file 'example.cdf', containing a variable 'Longitude'
%   % with the value [0:360], and with a variable attribute of
%   % 'validmin' with the value 10:
%
%   varAttribStruct.validmin = {'Longitude' [10]};
%   cdfwrite('example', {'Longitude' 0:360}, ...
%            'VariableAttributes', varAttribStruct);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also CDFLIB, CDFREAD, CDFINFO, CDFEPOCH.

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
        disp('Called the cdfwrite wrapper function.');
    end
    
    % Remove wrapper cdfwrite from the Matlab path
    overloadedFunctPath = which('cdfwrite');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded cdfwrite function.');  
    end
     
    % Call cdfwrite
    cdfwrite( source, varcell, varargin{:} );
   
    % Add the wrapper cdfwrite back to the Matlab path
    warning off MATLAB:dispatcher:nameConflict;
    addpath(overloaded_func_path, '-begin');
    warning on MATLAB:dispatcher:nameConflict;
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded cdfwrite function back.');
    end
    
    % Identifiy the file being used and add a prov:wasGeneratedBy statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_writes )
        formatId = 'application/octet-stream'; % Todo: what is the correct object format for common data format (cdf). 
                                         % Temporary to borrow: Network Common Data Format
        import org.dataone.client.v2.DataObject;
        
        [pathstr, name, ext] = fileparts(source);
        if isempty(ext)
            source = [source '.cdf']; % When source has no extension, we need to add the file extension to the source name.
                                      % Eg: cdfwrite('example', {'Longitude', 0:360}); generated file name "example.cdf"
        end
                
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
     
        if ( ~ ismember(pid, runManager.execution.execution_output_ids) )
            runManager.execution.execution_output_ids{end+1} = pid;
        end
    end

end
