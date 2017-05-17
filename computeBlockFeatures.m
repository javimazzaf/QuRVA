function blockFeatures = computeBlockFeatures(inIm, mask, blocksInd,trueBlocks,falseBlocks)

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
blockFeatures = [blockFeatures,computeAvgWithinBlocks(locallyNormIm,blocksInd,[trueBlocks;falseBlocks])];

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
blockFeatures = [blockFeatures,computeAvgWithinBlocks(log60,blocksInd,[trueBlocks;falseBlocks])];

% % 3: Normalized log filter scale 
% sz = szMax / 30;
% sgm = sz / sqrt(2) * tufts.resampleScale;
% ker  = - fspecial('log', ceil(sgm * 8) * [1 1] , sgm);
% log30 = max(filter2(ker,resizedIm,'same'),0);
% log30 = imresize(log30, [or, oc]) ./ localInt;
% log30(~mask & localInt == 0) = 0;
% blockFeatures = [blockFeatures,computeAvgWithinBlocks(log30,blocksInd,[trueBlocks;falseBlocks])];

% 4: LBP, rotational-invariant uniform 2
% mapping = getmapping(8,'riu2');
% [CLBP_S,CLBP_M,CLBP_C, CLBP_V,CLBP_SN] = clbp(smoothedIm,1,8,mapping,'i');
% aux = max(double(CLBP_S(:))) - double(CLBP_S);
% lbps = zeros(size(aux));
% lbps(ismember(aux,0:8)) = aux(ismember(aux,0:8)) + 1;
% lbps(ismember(aux,9)) = 0;

blockFeatures = [blockFeatures,computeLBPFeaturesOnBlocks(smoothedIm,1,8,blocksInd,[trueBlocks;falseBlocks])];

% blockFeatures = getFeatures(lbps,trueInd,falsInd,blockFeatures);


end

% function allFeat = getFeatures(imFeat,trueInd,falsInd,allFeat)
%   featData = [imFeat(trueInd);imFeat(falsInd)];
%   allFeat = [allFeat, featData];
% end