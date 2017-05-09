function features = computeImageFeatures(inIm, mask,trueInd,falsInd)

readConfig

features = [];

[or, oc] = size(inIm);

vascMask = imbinarize(imresize(mat2gray(bpass(inIm,1,5)),tufts.resampleScale));

ker        = fspecial('gaussian', ceil(tufts.denoiseFilterSize * 6) * [1 1] , tufts.denoiseFilterSize);
smoothedIm = max(filter2(ker,inIm,'same'),0);

resizedIm = imresize(smoothedIm,tufts.resampleScale);

[localInt, szMax] = localBrightness(smoothedIm, mask);

maxInt = max(double(smoothedIm(mask)));
minInt = min(double(smoothedIm(mask)));

% 1: Locally Normalized intensity
locallyNormIm = smoothedIm ./ localInt;
locallyNormIm(~mask) = 0;
features = getFeatures(locallyNormIm,trueInd,falsInd,features);

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
features = getFeatures(log60,trueInd,falsInd,features);

% 3: Normalized log filter scale 
sz = szMax / 30;
sgm = sz / sqrt(2) * tufts.resampleScale;
ker  = - fspecial('log', ceil(sgm * 8) * [1 1] , sgm);
log30 = max(filter2(ker,resizedIm,'same'),0);
log30 = imresize(log30, [or, oc]) ./ localInt;
log30(~mask & localInt == 0) = 0;
features = getFeatures(log30,trueInd,falsInd,features);

% % Pixels above thresh
% mskIntens = resizedIm >= double(median(resizedIm(vascMask)));
% ker =   fspecial('disk', round(sgm * 0.75)) > 0;
% mskMoreThanPerc = filter2(ker,mskIntens,'same') / sum(ker(:));
% mskMoreThanPerc = imresize(mskMoreThanPerc, [or, oc]);
% features = getFeatures(mskMoreThanPerc,trueInd,falsInd,features);

end

function allFeat = getFeatures(imFeat,trueInd,falsInd,allFeat)
  featData = [imFeat(trueInd);imFeat(falsInd)];
  allFeat = [allFeat, featData];
end
