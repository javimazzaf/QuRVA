function blockFeatures = computeBlockFeatures(inIm, mask, blocksInd,trueBlocks,falseBlocks, offSet)

readConfig

blockFeatures = [];

[or, oc] = size(inIm);

ker        = fspecial('gaussian', ceil(tufts.denoiseFilterSize * 6) * [1 1] , tufts.denoiseFilterSize);
smoothedIm = max(filter2(ker,inIm,'same'),0);

resizedIm = imresize(smoothedIm,tufts.resampleScale);

[localInt, szMax] = localBrightness(smoothedIm, mask);

maxInt = max(double(smoothedIm(mask)));
minInt = min(double(smoothedIm(mask)));

% 1: Locally Normalized intensity
locallyNormIm = smoothedIm ./ localInt;
locallyNormIm(~mask) = 0;
blockFeatures = [blockFeatures,computeAvgWithinBlocks(locallyNormIm,blocksInd,[trueBlocks;falseBlocks], offSet)];

% % 2: Globally Normalized intensity
% globallyNormIm = smoothedIm ./ (maxInt - minInt);
% globallyNormIm(~mask) = 0;
% blockFeatures = [blockFeatures,computeAvgWithinBlocks(globallyNormIm,blocksInd,[trueBlocks;falseBlocks])];

% % 1: Normalized log filter scale
% sz = szMax / 120;
% sgm = sz / sqrt(2) * tufts.resampleScale;
% ker  = - fspecial('log', ceil(sgm * 8) * [1 1] , sgm);
% log120 = max(filter2(ker,resizedIm,'same'),0);
% log120 = imresize(log120, [or, oc]) ./ (maxInt - minInt);
% log120(~mask) = 0;
% features = getFeatures(log120,trueInd,falsInd,features);

% 2: Normalized log filter scale 
sz = szMax / 60;
sgm = sz / sqrt(2) * tufts.resampleScale;
ker  = - fspecial('log', ceil(sgm * 8) * [1 1] , sgm);
log60 = max(filter2(ker,resizedIm,'same'),0);
log60 = imresize(log60, [or, oc]) ./ (maxInt - minInt);
log60(~mask) = 0;
blockFeatures = [blockFeatures,computeAvgWithinBlocks(log60,blocksInd,[trueBlocks;falseBlocks],offSet)];

% LBPs
blockFeatures = [blockFeatures,computeLBPFeaturesOnBlocks(smoothedIm,1,8,blocksInd,[trueBlocks;falseBlocks],offSet)];

end

