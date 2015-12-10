[X,map] = imread('corn.tif');
if ~isempty(map)
Im = ind2rgb(X,map);
end
A = imread('corn.tif','PixelRegion',{[1,2],[2,5]});