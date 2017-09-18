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

end






