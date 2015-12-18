function fitswrite(imagedata,source,varargin)
%FITSWRITE Write image to FITS file.
%   fitswrite(IMAGEDATA,FILENAME) writes IMAGEDATA to the FITS file
%   specified by FILENAME.  If FILENAME does not exist, it is created as a
%   simple FITS file.  If FILENAME does exist, it is either overwritten or
%   the image is appended to the end of the file.
%
%   fitswrite(...,'PARAM','VALUE') writes IMAGEDATA to the FITS file
%   according to the specified parameter value pairs.  The parameter names
%   are as follows:
%
%       'WriteMode'    One of these strings: 'overwrite' (the default)
%                      or 'append'. 
%
%       'Compression'  One of these strings: 'none' (the default), 'gzip', 
%                      'gzip2', 'rice', 'hcompress', or 'plio'.
%
%   Please read the file cfitsiocopyright.txt for more information.
%
%   Example:  Create a FITS file the red channel of an RGB image.
%       X = imread('ngc6543a.jpg');
%       R = X(:,:,1); 
%       fitswrite(R,'myfile.fits');
%       fitsdisp('myfile.fits');
%
%   Example:  Create a FITS file with three images constructed from the
%   channels of an RGB image.
%       X = imread('ngc6543a.jpg');
%       R = X(:,:,1);  G = X(:,:,2);  B = X(:,:,3);
%       fitswrite(R,'myfile.fits');
%       fitswrite(G,'myfile.fits','writemode','append');
%       fitswrite(B,'myfile.fits','writemode','append');
%       fitsdisp('myfile.fits');
%
%   See also FITSREAD, FITSINFO, MATLAB.IO.FITS.

%   Copyright 2011-2013 The MathWorks, Inc.

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
        disp('Called the fitswrite wrapper function.');
    end
    
    % Remove wrapper fitswrite from the Matlab path
    overloadedFunctPath = which('fitswrite');
    [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
    rmpath(overloaded_func_path);    
    
    if ( runManager.configuration.debug)
        disp('remove the path of the overloaded fitswrite function.');  
    end
     
    % Call fitswrite
    fitswrite( imagedata,source,varargin{:} );
   
    % Add the wrapper fitswrite back to the Matlab path
    addpath(overloaded_func_path, '-begin');
    
    if ( runManager.configuration.debug)
        disp('add the path of the overloaded fitswrite function back.');
    end
    
    % Identifiy the file being used and add a prov:wasGeneratedBy statement 
    % in the RunManager DataPackage instance  
    if ( runManager.configuration.capture_file_writes )
        
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
     
        runManager.execution.execution_output_ids{end+1} = pid;    
       
    end
    
end
