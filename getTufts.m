function tuftsMask = getTufts(redImage, maskNoCenter, thisMask, thisONCenter, retinaDiam, model)

readConfig

blockSize = ceil(retinaDiam * tufts.blockSizeFraction) * [1 1];

[~, indBlocks] = getBlocks(redImage, blockSize, [0 0]);

candidateBlocks  = getBlocksInMask(indBlocks, maskNoCenter & thisMask, tufts.blocksInMaskPercentage, [0 0]);

blockFeatures = computeBlockFeatures(redImage, maskNoCenter, thisMask, indBlocks, candidateBlocks,[],[0 0],thisONCenter);

y = predict(model, blockFeatures);

% goodBlocks = candidateBlocks((y > 0.5) & (blockFeatures(:,6) > 0.5),:);
goodBlocks = candidateBlocks(y > 0.5,:);

% hdisk = fspecial('disk',5) > 0;
% mn = filter2(hdisk,mat2gray(redImage)) / sum(hdisk(:)) .* thisMask;
% mn2 = filter2(hdisk,mat2gray(redImage).^2) / sum(hdisk(:)) .* thisMask;
% 
% sd = sqrt(mn2 - mn.^2) .* thisMask;
% contrast = sd ./ mn;

tuftsMask = blocksToMask(size(redImage), indBlocks, goodBlocks, [0 0]);

tuftsMask = bwareaopen(tuftsMask,prod(blockSize) + 1);

%% QC
normIm = overSaturate(redImage);

[bckgAve, bckgStd] = getRobustLocalBackground(normIm, thisMask);

normIm = mat2gray(normIm);

mskAbove = double(normIm > (bckgAve + 3*bckgStd));

countAbovePixels = filter2(ones(30),mskAbove,'same') / 30^2;

tuftsMask = tuftsMask & (countAbovePixels >= 0.8);

%% QC
% [bckgAve, bckgStd] = getRobustLocalBackground(double(redImage), thisMask);
% normIm = mat2gray(redImage);
% 
% countAbovePixels = filter2(ones(30),double(normIm > (bckgAve + 3*bckgStd)),'same') / 30^2;
% 
% tuftsMask = tuftsMask & (countAbovePixels >= 0.8);

end






