X = imread('ngc6543a.jpg');
R = X(:,:,1);  G = X(:,:,2);  B = X(:,:,3);
fitswrite(R,'myfile.fits');
fitswrite(G,'myfile.fits','writemode','append');
fitswrite(B,'myfile.fits','writemode','append');
fitsdisp('myfile.fits');

delete('myfile.fits');