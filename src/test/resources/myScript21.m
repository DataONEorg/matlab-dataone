X = imread('ngc6543a.jpg');
R = X(:,:,1);  G = X(:,:,2);  B = X(:,:,3);
fitswrite(R,'tests/myfile.fits');
fitswrite(G,'tests/myfile.fits','writemode','append');
fitswrite(B,'tests/myfile.fits','writemode','append');
fitsdisp('tests/myfile.fits');

