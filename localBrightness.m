function [localMean, szMax] = localBrightness(inIm, mask)

[r,c] = find(mask > 0.5);

szMax = max(range(r),range(c));

sz = round(szMax / 8);

ker = fspecial('average', sz) > 0;

sumBrightness = filter2(ker,double(inIm) .* double(mask));
sumPixels     = filter2(int32(ker),int32(mask));

localMean = sumBrightness ./ double(sumPixels);

%Avoid division by zero problems
localMean(sumPixels < 0.5) = 0;

localMean = localMean .* mask;

end