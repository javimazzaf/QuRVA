function blockFeatures = computeBlockFeatures(inIm, maskNoCenter, thisMask, blocksInd,trueBlocks,falseBlocks, offSet, center)

readConfig

mask = maskNoCenter & thisMask;

blockFeatures = [];

[or, oc] = size(inIm);

ker        = fspecial('gaussian', ceil(tufts.denoiseFilterSize * 6) * [1 1] , tufts.denoiseFilterSize);
smoothedIm = max(filter2(ker,inIm,'same'),0);

resizedIm = imresize(smoothedIm,tufts.resampleScale);

[localInt, szMax] = localBrightness(smoothedIm, mask, center);

maxInt = max(double(smoothedIm(mask)));
minInt = min(double(smoothedIm(mask)));

% 1: Locally Normalized intensity
locallyNormIm = smoothedIm ./ localInt;
locallyNormIm(~mask) = 0;
blockFeatures = [blockFeatures,computeAvgWithinBlocks(locallyNormIm,blocksInd,[trueBlocks;falseBlocks], offSet)];

% 2: Globally Normalized intensity
globallyNormIm = (smoothedIm - minInt) ./ (maxInt - minInt);
globallyNormIm(~mask) = 0;
blockFeatures = [blockFeatures,computeAvgWithinBlocks(globallyNormIm,blocksInd,[trueBlocks;falseBlocks], offSet)];

% 3: Normalized log filter scale 
sz = szMax / 60;
sgm = sz / sqrt(2) * tufts.resampleScale;
ker  = - fspecial('log', ceil(sgm * 8) * [1 1] , sgm);
log60 = max(filter2(ker,resizedIm,'same'),0);
log60 = imresize(log60, [or, oc]) ./ (maxInt - minInt);
log60(~mask) = 0;
blockFeatures = [blockFeatures,computeAvgWithinBlocks(log60,blocksInd,[trueBlocks;falseBlocks],offSet)];

% LBPs
tolRng = range(smoothedIm(logical(maskNoCenter))) * tufts.lbpTolPercentage / 100; % The tolerance for LPBs is 5% of total image range within valid mask
R = 1;
P = 8;
blockFeatures = [blockFeatures,computeLBP_M_FeaturesOnBlocks(smoothedIm,R,P,blocksInd,[trueBlocks;falseBlocks],offSet,tolRng)];

% Pixels above local background
[bgMean,bgStd] = getRobustLocalBackground(globallyNormIm, thisMask);
countAbovePixels = filter2(ones(50),double(globallyNormIm > (bgMean + 3*bgStd)),'same') / 50^2;

blockFeatures = [blockFeatures,computeAvgWithinBlocks(countAbovePixels,blocksInd,[trueBlocks;falseBlocks], offSet)];

end

