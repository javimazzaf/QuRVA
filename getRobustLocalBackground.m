function [bckgAve, bckgStd] = getRobustLocalBackground(rawImage, thisMask)

oSize = size(rawImage);

scl = 0.25;

rawImage = imresize(rawImage,scl);
thisMask = imresize(thisMask,size(rawImage));

% Prepare raw data
rawImage = rawImage .* thisMask;
rawImageNorm = mat2gray(double(rawImage));

%% Computes typical brightness of healthy vasculature locally
% Enhance healthy (thin) vesses using a band-pass filter
bandPass = max(0,imgaussfilt(rawImageNorm,1*scl) - imgaussfilt(rawImageNorm,3*scl));

vesselMask = imbinarize(bandPass, adaptthresh(bandPass.*thisMask, 'NeighborhoodSize',1+2*round([50 50]*scl/2)));

vesselMask2 = bwareaopen(vesselMask,round(50*scl));

bckgMask = ~vesselMask2;

bckgMask = imerode(bckgMask,strel('disk',round(4*scl)));

bckgMask2 = bckgMask & (rawImageNorm < 0.5);

bckgMask2 = bwareaopen(bckgMask2,round(400*scl));

bckgMask2 = bckgMask2 & thisMask;

stats = regionprops(bckgMask2,'PixelIdxList','area');
weights = zeros(size(bckgMask2));
averageBlocks = zeros(size(bckgMask2));
stdBlocks     = zeros(size(bckgMask2));
mxArea = max([stats(:).Area]);
for k = 1:numel(stats)
   weights(stats(k).PixelIdxList) = double(stats(k).Area) / mxArea;
   averageBlocks(stats(k).PixelIdxList) = mean(rawImageNorm(stats(k).PixelIdxList));
   stdBlocks(stats(k).PixelIdxList)     = std(rawImageNorm(stats(k).PixelIdxList));
end

ker = fspecial('disk',round(100*scl)) > 0;

bckSum    = filter2(ker, averageBlocks .* weights,'same');
bckSTD    = filter2(ker, stdBlocks .* weights,'same');
bckWsum   = filter2(ker, weights,'same');

bckgAve = bckSum ./ bckWsum;
bckgStd = bckSTD ./ bckWsum;

% bckSum   = filter2(ker, rawImageNorm .* bckgMask2,'same');
% bckSum2  = filter2(ker, rawImageNorm.^2 .* bckgMask2,'same');
% bckNum   = filter2(ker, bckgMask2,'same');
% 
% bckgAve = bckSum ./ bckNum;
% bckgStd = sqrt(bckSum2 ./ bckNum - bckgAve.^2);
% 
% bckgAve(bckNum < 1) = NaN;
% bckgStd(bckNum < 1) = NaN;

[r,c] = find(bckWsum >= 1);
stats = regionprops(bckWsum < 1,'PixelIdxList','Centroid');


for k = 1:numel(stats)
    centroid = stats(k).Centroid;
    d2 = (r-centroid(2)).^2 + (c - centroid(1)).^2;
    [~,ix] = min(d2);
    bkg = bckgAve(r(ix),c(ix));
    stdBck = bckgStd(r(ix),c(ix));
    
    bckgAve(stats(k).PixelIdxList) = bkg;
    bckgStd(stats(k).PixelIdxList) = stdBck;
end

bckgAve = real(imresize(bckgAve,oSize));
bckgStd = real(imresize(bckgStd,oSize));








