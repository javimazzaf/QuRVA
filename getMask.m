function msk = getMask(im)

im = mat2gray(im);

sz = 100;

imLP   = mat2gray(filter2(fspecial('gaussian',[sz sz], sz/6),im));

thresh = graythresh(imLP(:));

msk    = imbinarize(imLP,thresh);

msk  = imfill(msk,'holes');

perim = bwperim(msk);

[y,x] = find(perim);

dt = delaunayTriangulation(x,y);

k = convexHull(dt);

chCol = dt.Points(k,1);
chRow = dt.Points(k,2);

% [xq,yq] = meshgrid(1:size(msk,2),1:size(msk,1)); 

BW = poly2mask(chCol,chRow,size(msk,1),size(msk,2));

% poly = inpolygon(xq,yq,chCol,chRow);
% 
% bw = activecontour(A,mask)

end