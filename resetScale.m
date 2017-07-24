function [outImage, scaleFactor] = resetScale(inImage)

sz = size(inImage);

[~,ix] = max(sz);

newSize = [NaN NaN];
newSize(ix) = 4096;

outImage = imresize(inImage,newSize);

outSz=size(outImage);
scaleFactor=sz(1)/outSz(1);

end