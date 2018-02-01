function tuftsMask = getTufts(redImage, maskNoCenter, thisMask, thisONCenter, retinaDiam, model)

readConfig

blockSize = ceil(retinaDiam * tufts.blockSizeFraction) * [1 1];

[~, indBlocks] = getBlocks(redImage, blockSize, [0 0]);

candidateBlocks  = getBlocksInMask(indBlocks, maskNoCenter & thisMask, tufts.blocksInMaskPercentage, [0 0]);

blockFeatures = computeBlockFeatures(redImage, maskNoCenter, thisMask, indBlocks, candidateBlocks,[],[0 0],thisONCenter);

y = predict(model, blockFeatures);

goodBlocks = candidateBlocks(y > 0.5,:);

tuftsMask = blocksToMask(size(redImage), indBlocks, goodBlocks, [0 0]);

tuftsMask = bwareaopen(tuftsMask,prod(blockSize) + 1);

%% Quality control based on Robust Background
normIm = overSaturate(redImage);

[bckgAve, bckgStd] = getRobustLocalBackground(normIm, thisMask);

normIm = mat2gray(normIm);

mskAbove = double(normIm > (bckgAve + 3*bckgStd));

countAbovePixels = filter2(ones(tufts.QC.squareSize),mskAbove,'same') / tufts.QC.squareSize^2;

tuftsMask = tuftsMask & (countAbovePixels >= tufts.QC.threshold);

end






