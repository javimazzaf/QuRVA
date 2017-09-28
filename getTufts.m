function tuftsMask = getTufts(redImage, maskNoCenter, thisMask, thisONCenter, retinaDiam, model)

readConfig

blockSize = ceil(retinaDiam * tufts.blockSizeFraction) * [1 1];

[~, indBlocks] = getBlocks(redImage, blockSize, [0 0]);

candidateBlocks  = getBlocksInMask(indBlocks, maskNoCenter & thisMask, tufts.blocksInMaskPercentage, [0 0]);

blockFeatures = computeBlockFeatures(redImage, maskNoCenter, thisMask, indBlocks, candidateBlocks,[],[0 0],thisONCenter);

y = predict(model, blockFeatures);

% goodBlocks = candidateBlocks((y > 0.5) & (blockFeatures(:,6) > 0.5),:);
goodBlocks = candidateBlocks(y > 0.5,:);

% [bgMean,bgStd] = getRobustLocalBackground(mat2gray(redImage), thisMask);
% countAbovePixels = filter2(ones(50),double(mat2gray(redImage) > (bgMean + 3*bgStd)),'same') / 50^2;

% hdisk = fspecial('disk',5) > 0;
% mn = filter2(hdisk,mat2gray(redImage)) / sum(hdisk(:)) .* thisMask;
% mn2 = filter2(hdisk,mat2gray(redImage).^2) / sum(hdisk(:)) .* thisMask;
% 
% sd = sqrt(mn2 - mn.^2) .* thisMask;
% contrast = sd ./ mn;

tuftsMask = blocksToMask(size(redImage), indBlocks, goodBlocks, [0 0]);

tuftsMask = bwareaopen(tuftsMask,prod(blockSize) + 1);

end






