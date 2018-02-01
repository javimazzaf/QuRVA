function outMask=createCircularMask(numRow, numCol, r0, c0, radius)

[rr cc] = meshgrid(1:numCol, 1:numRow);
outMask = sqrt((rr-r0).^2+(cc-c0).^2)<=radius;
