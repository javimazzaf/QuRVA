function [bckgAve, bckgStd] = getRobustLocalBackground(rawImage, thisMask)

oSize = size(rawImage);

scl = 0.25;

rawImage = imresize(rawImage,scl);
thisMask = imresize(thisMask,size(rawImage));

% Prepare raw data
rawImage = rawImage.*uint8(thisMask);
rawImageNorm = mat2gray(double(rawImage));

%% Computes typical brightness of healthy vasculature locally
% Enhance healthy (thin) vesses using a band-pass filter
bandPass = max(0,imgaussfilt(rawImageNorm,1*scl) - imgaussfilt(rawImageNorm,3*scl));

vesselMask = imbinarize(bandPass, adaptthresh(bandPass.*thisMask, 'NeighborhoodSize',1+2*round([50 50]*scl/2)));

vesselMask2 = bwareaopen(vesselMask,round(50*scl));

bckgMask = ~vesselMask2;

bckgMask = imerode(bckgMask,strel('disk',round(4*scl)));

bckgMask2 = bckgMask & (rawImageNorm < 0.5);

ker = fspecial('disk',round(25*scl)) > 0;
bckSum   = filter2(ker, rawImageNorm .* bckgMask2,'same');
bckSum2  = filter2(ker, rawImageNorm.^2 .* bckgMask2,'same');
bckNum   = filter2(ker, bckgMask2,'same');

bckgAve = bckSum ./ bckNum;
bckgStd = sqrt(bckSum2 ./ bckNum - bckgAve.^2);

bckgAve(bckNum < 1) = NaN;
bckgStd(bckNum < 1) = NaN;

[r,c] = find(bckNum >= 1);
stats = regionprops(bckNum < 1,'PixelIdxList','Centroid');


for k = 1:numel(stats)
    centroid = stats(k).Centroid;
    d2 = (r-centroid(2)).^2 + (c - centroid(1)).^2;
    [~,ix] = min(d2);
    bkg = bckgAve(r(ix),c(ix));
    stdBck = bckgStd(r(ix),c(ix));
    
    bckgAve(stats(k).PixelIdxList) = bkg;
    bckgStd(stats(k).PixelIdxList) = stdBck;
end

bckgAve = imresize(bckgAve,oSize);
bckgStd = imresize(bckgStd,oSize);








