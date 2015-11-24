   % Setup initial parameters for a dataset.
    rows=3; cols=3; bands=5;
    filename = tempname;
 
    % Define the dataset.
    fid = fopen(filename, 'w', 'ieee-le');
    fwrite(fid, 1:rows*cols*bands, 'double');
    fclose(fid);
 
    % Read the every other band of the data using the Band-Sequential format.
    im1 = multibandread(filename, [rows cols bands], ...
              'double', 0, 'bsq', 'ieee-le', ...
              {'Band', 'Range', [1 2 bands]} )
 
    % Read the first two rows and columns of data using
    % Band-Interleaved-by-Pixel format.
    im2 = multibandread(filename, [rows cols bands], ...
              'double', 0, 'bip', 'ieee-le', ...
              {'Row', 'Range', [1 2]}, ...
              {'Column', 'Range', [1 2]} )
 
    % Read the data using Band-Interleaved-by-Line format.
    im3 = multibandread(filename, [rows cols bands], ...
              'double', 0, 'bil', 'ieee-le')
 
    % Delete the file that we created.
         delete(filename);
 
    % The FITS file 'tst0012.fits' contains int16 BIL data starting at
    % byte 74880.
    im4 = multibandread( 'tst0012.fits', [31 73 5], ...
              'int16', 74880, 'bil', 'ieee-be', ...
              {'Band', 'Range', [1 3]} );
    im5 = double(im4)/max(max(max(im4)));
    imagesc(im5);