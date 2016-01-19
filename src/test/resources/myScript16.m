A = rand(50);
imwrite(A,'tests/myGray.png')
load clown.mat
imwrite(X,map,'tests/myclown.png')



x = 0:0.01:1;
figure
filename = 'tests/testAnimated.gif';

for n = 1:0.5:5
y = x.^n;
plot(x,y)
drawnow
frame = getframe(1);
im = frame2im(frame);
[A,map] = rgb2ind(im,256); 
	if n == 1;
		imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
	else
		imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
	end
end

fclose('all');

delete('tests/myGray.png');
delete('tests/myclown.png');
delete(filename);