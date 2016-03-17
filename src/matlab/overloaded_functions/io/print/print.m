function varargout = print( varargin )
    %PRINT Print figure or model. Save to disk as image or MATLAB file.
    %   SYNTAX:
    %     print
    %       PRINT alone sends the current figure to your current printer.
    %       The size and position of the printed output depends on the figure's
    %       PaperPosition[mode] properties and your default print command
    %       as specified in your PRINTOPT.M file.
    %
    %     print -s
    %       Same as above but prints the current Simulink model.
    %
    %     print -device -options
    %       You can optionally specify a print device (i.e., an output format such
    %       as tiff or PostScript or a print driver that controls what is sent to
    %       your printer) and options that control various characteristics  of the
    %       printed file (i.e., the resolution, the figure to print
    %       etc.). Available devices and options are described below.
    %
    %     print -device -options filename
    %       If you specify a filename, MATLAB directs output to a file instead of
    %       a printer. PRINT adds the appropriate file extension if you do not
    %       specify one.
    %
    %     print( ... )
    %       Same as above but this calls PRINT as a MATLAB function instead of
    %       a MATLAB command. The difference is only in the parenthesized argument
    %       list. It allows the passing of variables for any of the input
    %       arguments and is especially useful for passing the handles
    %       of figures and/or models to print and filenames.
    %
    %     Note: PRINT will produce a warning when printing a figure with a
    %     ResizeFcn.  To avoid the warning, set the PaperPositionMode to 'auto'
    %     or match figure screen size in the PageSetup dialog.
    %
    %   BATCH PROCESSING:
    %       You can use the function form of PRINT, which is useful for batch
    %       printing. For example, you can use a for loop to create different
    %       graphs and print a series of files whose names are stored in an array:
    %
    %       for i=1:length(fnames)
    %           print('-dpsc','-r200',fnames(i))
    %       end
    %
    %   SPECIFYING THE WINDOW TO PRINT
    %       -f<handle>   % Handle Graphics handle of figure to print
    %       -s<name>     % Name of an open Simulink model to print
    %       h            % Figure or model handle when using function form of PRINT
    %
    %     Examples:
    %       print -f2    % Both commands print Figure 2 using the default driver
    %       print( 2 )   % and operating system command specified in PRINTOPT.
    %
    %       print -svdp  % prints the open Simulink model named vdp
    %
    %   SPECIFYING THE OUTPUT FILE:
    %       <filename>   % String on the command line
    %       '<filename>' % String passed in when using function form of PRINT
    %
    %     Examples:
    %       print -dps foo
    %       fn = 'foo'; print( gcf, '-dps', fn )
    %       Both save the current figure to a file named 'foo.ps' in the current
    %       working directory. This file can now be printed to a
    %       PostScript-compatible printer.
    %
    %   COMMON DEVICE DRIVERS
    %       Output format is specified by the device driver input argument. This
    %       argument always starts with '-d' and falls into one of several
    %       categories:
    %     Microsoft Windows system device driver options:
    %       -dwin      % Send figure to current printer in monochrome
    %       -dwinc     % Send figure to current printer in color
    %       -dmeta     % Send figure to clipboard (or file) in Metafile format
    %       -dbitmap   % Send figure to clipboard (or file) in bitmap format
    %       -v         % Verbose mode, bring up the Print dialog box
    %                    which is normally suppressed.
    %
    %     Built-in MATLAB Drivers:
    %       -dps       % PostScript for black and white printers
    %       -dpsc      % PostScript for color printers
    %       -dps2      % Level 2 PostScript for black and white printers
    %       -dpsc2     % Level 2 PostScript for color printers
    %
    %       -deps      % Encapsulated PostScript
    %       -depsc     % Encapsulated Color PostScript
    %       -deps2     % Encapsulated Level 2 PostScript
    %       -depsc2    % Encapsulated Level 2 Color PostScript
    %
    %       -dpdf      % Color PDF file format
    %       -dsvg      % Scalable Vector Graphics
    %
    %       -djpeg<nn> % JPEG image, quality level of nn (figures only)
    %                    E.g., -djpeg90 gives a quality level of 90.
    %                    Quality level defaults to 75 if nn is omitted.
    %       -dtiff     % TIFF with packbits (lossless run-length encoding)
    %                    compression (figures only)
    %       -dtiffnocompression % TIFF without compression (figures only)
    %       -dpng      % Portable Network Graphic 24-bit truecolor image
    %                    (figures only)
    %       -dbmpmono  % Monochrome .BMP file format
    %       -dbmp256   % 8-bit (256-color) .BMP file format
    %       -dbmp16m   % 24-bit .BMP file format
    %       -dpcxmono  % Monochrome PCX file format
    %       -dpcx16    % Older color PCX file format (EGA/VGA, 16-color)
    %       -dpcx256   % Newer color PCX file format (256-color)
    %       -dpcx24b   % 24-bit color PCX file format, 3 8-bit planes
    %       -dpbm      % Portable Bitmap (plain format)
    %       -dpbmraw   % Portable Bitmap (raw format)
    %       -dpgm      % Portable Graymap (plain format)
    %       -dpgmraw   % Portable Graymap (raw format)
    %       -dppm      % Portable Pixmap (plain format)
    %       -dppmraw   % Portable Pixmap (raw format)
    %
    %     Examples:
    %       print -dwinc  % Prints current Figure to current printer in color
    %       print( h, '-djpeg', 'foo') % Prints Figure/model h to foo.jpg
    %
    %   PRINTING OPTIONS
    %     Options only for use with PostScript and GhostScript drivers:
    %       -loose     % Use Figure's PaperPosition as PostScript BoundingBox
    %       -append    % Append, not overwrite, the graph to PostScript file
    %       -tiff      % Add TIFF preview, EPS files only (implies -loose)
    %       -cmyk      % Use CMYK colors instead of RGB
    %
    %     Options for PostScript, GhostScript, Tiff, Jpeg, and Metafile:
    %       -r<number> % Dots-per-inch resolution. Defaults to 90 for Simulink,
    %                    150 for figures in image formats and when
    %                    printing in Z-buffer or OpenGL mode,  screen
    %                    resolution for Metafiles and 864 otherwise.
    %                    Use -r0 to specify screen resolution.
    %     Example:
    %       print -depsc -tiff -r300 matilda
    %       Saves current figure at 300 dpi in color EPS to matilda.eps
    %       with a TIFF preview (at 72 dpi for Simulink models and 150 dpi
    %       for figures). This TIFF preview will show up on screen if
    %       matilda.eps is inserted as a Picture in a Word document, but
    %       the EPS will be used if the Word document is printed on a
    %       PostScript printer.
    %
    %     Other options for figure windows:
    %       -Pprinter  % Specify the printer. On Windows and Unix.
    %       -noui      % Do not print UI control objects
    %       -painters  % Rendering for printing to be done in Painters mode
    %       -opengl    % Rendering for printing to be done in OpenGL mode
    %
    %   See the Using MATLAB Graphics manual for more information on printing.
    %
    %   See also PRINTOPT, PRINTDLG, ORIENT, IMWRITE, HGSAVE, SAVEAS.
    
    %   Copyright 1984-2014 The MathWorks, Inc.
    
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
    disp('Called the print wrapper function.');
end
    
for i=1:nargin
    x = varargin{i};
    if ischar(x) && isempty(regexp(x, '^-', 'ONCE'))
        % A filename is identified       
        
        [pathstr, name, ext] = fileparts(x);
        
        if ~isempty(ext)
            source = x;
        else
            % Decide the file format from formattype
            format_type_set = {'-dps', '-dsvg', '-djpeg', '-dpng', '-dbmp', '-dtiff'};
            for j = 1:length(varargin)
                if ischar(varargin{j})
                    matched = ismember(varargin{j}, format_type_set);
                    
                    if matched 
                        matched_format_type = varargin{j};
                        
                        if strcmp(matched_format_type, '-dbmp')
                            file_ext = 'bmp';
                        elseif strcmp(matched_format_type, '-djpeg')
                            file_ext = 'jpeg';
                        elseif strcmp(matched_format_type, '-dpng')
                            file_ext = 'png';
                        elseif strcmp(matched_format_type, '-dsvg')
                            file_ext = 'svg';
                        elseif strcmp(matched_format_type, '-dtiff')
                            file_ext = 'tiff';
                        end
                        source = [name '.' file_ext ];
                        break;
                    end
                end
            end
            if isempty(matched_format_type)
                break;
            end
            
        end
                
        % Remove wrapper print from the Matlab path
        overloadedFunctPath = which('print');
        [overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
        rmpath(overloaded_func_path);
        
        if ( runManager.configuration.debug)
            disp('remove the path of the overloaded print function.');
        end
        
        % Call print
        [varargout{1:nargout}] = print( varargin{:} );
        
        % Identifiy the file being used and add a prov:wasGeneratedBy statement
        % in the RunManager DataPackage instance
        if ( runManager.configuration.capture_file_writes )
            if strcmp(file_ext, 'bmp')
                formatId = 'image/bmp';
            elseif strcmp(file_ext, 'jpeg')
                formatId = 'image/jpeg';
            elseif strcmp(file_ext, 'png')
                formatId = 'image/png';
            elseif strcmp(file_ext, 'svg')
                formatId = 'image/svg xml';
            elseif strcmp(file_ext, 'tiff')
                formatId = 'image/tiff';
            else
                formatId = 'application/octet-stream';
            end
            
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
            
            if ( ~ ismember(pid, runManager.execution.execution_output_ids) )
                runManager.execution.execution_output_ids{end+1} = pid;
                
            end
            
        end
        
        % Add the wrapper print back to the Matlab path
        warning off MATLAB:dispatcher:nameConflict;
        addpath(overloaded_func_path, '-begin');
        warning on MATLAB:dispatcher:nameConflict;
        
        return;
        
    end
end

% For the case when no filename is found

% Remove wrapper print from the Matlab path
overloadedFunctPath = which('print');
[overloaded_func_path, func_name, ext] = fileparts(overloadedFunctPath);
rmpath(overloaded_func_path);

if ( runManager.configuration.debug)
    disp('remove the path of the overloaded print function.');
end

[varargout{1:nargout}] = print( varargin{:} );

% Add the wrapper print back to the Matlab path
warning off MATLAB:dispatcher:nameConflict;
addpath(overloaded_func_path, '-begin');
warning on MATLAB:dispatcher:nameConflict;

end
