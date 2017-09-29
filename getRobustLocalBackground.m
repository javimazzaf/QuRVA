function [bckgAve, bckgStd] = getRobustLocalBackground(rawImage, thisMask)

oSize = size(rawImage);

scl = 0.25;

rawImage = imresize(rawImage,scl);
thisMask = imresize(thisMask,size(rawImage));

% Prepare raw data
rawImage = rawImage .* thisMask;
rawImageNorm = mat2gray(double(rawImage));

% %% Testing
% N = 10; 
% 
% test = rawImageNorm;
% test = imquantize(rawImageNorm,(1:1:N)/N) / N;
% 
% blockSize = ceil(max(size(test)) / 20) * [1 1];
% 
% [blk, indBlocks] = getBlocks(test, blockSize, [0 0]);
% 
% sz       = size(indBlocks);
% bSz      = sz(1:2);
% nBlocks  = sz(3:4);
% 
% padSz   = nBlocks .* bSz - size(test);
% 
% test = padarray(test,padSz,0,'post');
% 
% msk  = test > 0.01;
% test(~msk) = 0;
% 
% inBlocks  = getBlocksInMask(indBlocks, msk, 10, [0 0]);
% 
% b = zeros(size(test));
% 
% for k = 1:size(inBlocks,1)
%     ix = indBlocks(:,:,inBlocks(k,1),inBlocks(k,2));
%     aux = test(ix);
%     mask = msk(ix);
%     
%     [N,edges] = histcounts(aux(mask),0:1/30:1);
%     [~,pkIx] = max(N .* (edges(1:end-1) < 0.5));
%     md = edges(pkIx);
%     
%     b(ix) = md * mask;
% %     if md > 0.3, figure; imshow(aux,[]); end
%     figure(k);bar(edges(1:end-1),N), title(num2str(md))
% end
% 
% b = b(1:size(rawImageNorm,1),1:size(rawImageNorm,2));
% figure; imshow(test,[])
% figure; imshow(b,[])

%% Computes typical brightness of healthy vasculature locally
% Enhance healthy (thin) vesses using a band-pass filter
% bandPass = max(0,imgaussfilt(rawImageNorm,1*scl) - imgaussfilt(rawImageNorm,3*scl));
% 
% vesselMask = imbinarize(bandPass, adaptthresh(bandPass.*thisMask, 'NeighborhoodSize',1+2*round([50 50]*scl/2)));
% 
% vesselMask2 = bwareaopen(vesselMask,round(50*scl));
% 
% bckgMask = ~vesselMask2;
% 
% bckgMask = imerode(bckgMask,strel('disk',round(4*scl)));
% 
% bckgMask2 = bckgMask & (rawImageNorm < 0.5);
% 
% bckgMask2 = bwareaopen(bckgMask2,round(400*scl));
% 
% bckgMask2 = bckgMask2 & thisMask;

qN = 10; 

qImage = imquantize(rawImageNorm,(1:1:qN)/qN) / qN;

bckgMask2 = imregionalmin(qImage) & thisMask;

stats = regionprops(bckgMask2,'PixelIdxList','area','Centroid');
weights = zeros(size(bckgMask2));
averageBlocks = zeros(size(bckgMask2));
stdBlocks     = zeros(size(bckgMask2));
mxArea = max([stats(:).Area]);
for k = 1:numel(stats)
   
%    if stats(k).Area < 4, continue, end
%    
%    centroid = stats(k).Centroid; 
%    
%    aux = rawImageNorm(stats(k).PixelIdxList);
   
%    md = median(aux(:));
%    
%    if md > 0.5, continue, end
   
%    averageBlocks(centroid(2),centroid(1)) = md;
%    stdBlocks(centroid(2),centroid(1))     = std(aux(:));
   
   weights(stats(k).PixelIdxList)       = double(stats(k).Area) / mxArea;
%    averageBlocks(stats(k).PixelIdxList) = md;
%    stdBlocks(stats(k).PixelIdxList)     = std(aux(:));
end

%%

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
bckgStd = sqrt(bck2Sum ./ bckWsum - bckgAve.^2);


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

% count = rawImageNorm > (ave + 3 * sd);

bckgAve = real(imresize(ave .* thisMask,oSize));
bckgStd = real(imresize(sd .* thisMask,oSize));

%%

% ker = fspecial('disk',round(100*scl)) > 0;
% 
% bckSum    = filter2(ker, rawImageNorm .* weights,'same');
% bck2Sum   = filter2(ker, rawImageNorm.^2 .* weights,'same');
% bckWsum   = filter2(ker, weights,'same');
% 
% bckgAve = bckSum ./ bckWsum;
% bckgStd = sqrt(bck2Sum ./ bckWsum - bckgAve.^2);
% 
% % bckSum   = filter2(ker, rawImageNorm .* bckgMask2,'same');
% % bckSum2  = filter2(ker, rawImageNorm.^2 .* bckgMask2,'same');
% % bckNum   = filter2(ker, bckgMask2,'same');
% % 
% % bckgAve = bckSum ./ bckNum;
% % bckgStd = sqrt(bckSum2 ./ bckNum - bckgAve.^2);
% % 
% % bckgAve(bckNum < 1) = NaN;
% % bckgStd(bckNum < 1) = NaN;
% 
% % [r,c] = find(bckWsum ~= 0);
% % stats = regionprops(bckWsum == 0,'PixelIdxList','Centroid');
% % 
% % 
% % for k = 1:numel(stats)
% %     centroid = stats(k).Centroid;
% %     d2 = (r-centroid(2)).^2 + (c - centroid(1)).^2;
% %     [~,ix] = min(d2);
% %     bkg = bckgAve(r(ix),c(ix));
% %     stdBck = bckgStd(r(ix),c(ix));
% %     
% %     bckgAve(stats(k).PixelIdxList) = bkg;
% %     bckgStd(stats(k).PixelIdxList) = stdBck;
% % end
% % 
% % bckgAve = real(imresize(bckgAve,oSize));
% % bckgStd = real(imresize(bckgStd,oSize));
% 
% 
% 
% 
% 
% 
% 
% 
