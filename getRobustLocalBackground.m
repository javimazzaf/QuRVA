function [bckgAve, bckgStd] = getRobustLocalBackground(rawImage, thisMask)

oSize = size(rawImage);

scl = 0.25;

rawImage = imresize(rawImage,scl);
thisMask = imresize(thisMask,size(rawImage));

rawImage(~thisMask) = 0;
rawImageNorm = mat2gray(rawImage);

qN = 10; 

qImage = imquantize(rawImageNorm,(1:1:qN)/qN) / qN;

bckgMask2 = imregionalmin(qImage) & thisMask;

stats = regionprops(bckgMask2,'PixelIdxList','area','Centroid');
weights = zeros(size(bckgMask2));
mxArea = max([stats(:).Area]);

for k = 1:numel(stats)
   weights(stats(k).PixelIdxList)       = double(stats(k).Area) / mxArea;
end

ker = fspecial('disk',round(100*scl)) > 0;

bckSum    = filter2(ker, rawImageNorm .* weights,'same');
bck2Sum   = filter2(ker, rawImageNorm.^2 .* weights,'same');
bckWsum   = filter2(ker, weights,'same');

bckgAve = bckSum ./ bckWsum;
bckgStd = sqrt(bck2Sum ./ bckWsum - bckgAve.^2);

% Remove outliers
invMsk = rawImageNorm > (bckgAve + 3 * bckgStd);
weights(invMsk) = 0;

bckSum    = filter2(ker, rawImageNorm .* weights,'same');
bck2Sum   = filter2(ker, rawImageNorm.^2 .* weights,'same');
bckWsum   = filter2(ker, weights,'same');

bckgAve = bckSum ./ bckWsum;
bckgStd = real(sqrt(bck2Sum ./ bckWsum - bckgAve.^2));


[r,c] = find(weights > 0);

ix = sub2ind(size(weights),r,c);

vM = bckgAve(ix);
fM = fit([r, c],vM,'cubicinterp');

vS = bckgStd(ix);
fS = fit([r, c],vS,'cubicinterp');

[r,c] = find(thisMask > 0);

ave = zeros(size(thisMask));
sd  = ave;

ave(thisMask(:)) = fM(r,c);
sd(thisMask(:)) = fS(r,c);

bckgAve = real(imresize(ave .* thisMask,oSize));
bckgStd = real(imresize(sd .* thisMask,oSize));

