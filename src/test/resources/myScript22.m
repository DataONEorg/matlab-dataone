info      = fitsinfo('tst0012.fits');
rowend    = info.AsciiTable.Rows;
tableData = fitsread('tst0012.fits','asciitable',...
    'Info',info,...
    'TableRows',[1:2:rowend]);

info      = fitsinfo('tst0012.fits');
% List of contents, includes any extensions if present.
disp(info.Contents);
imageData = fitsread('tst0012.fits','image');

info        = fitsinfo('tst0012.fits');
rowend      = info.Image.Size(1);
colend      = info.Image.Size(2);
primaryData = fitsread('tst0012.fits','image',...
    'Info', info,...
    'PixelRegion',{[1 2 rowend], [1 2 colend], 5 });

info      = fitsinfo('tst0012.fits');
rowend    = info.BinaryTable.Rows;
tableData = fitsread('tst0012.fits','binarytable',...
    'Info',info,...
    'TableColumns',[1 2 5]);
