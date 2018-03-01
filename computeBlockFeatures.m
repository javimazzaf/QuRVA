function blockFeatures = computeBlockFeatures(inIm, maskNoCenter, thisMask, blocksInd,trueBlocks,falseBlocks, offSet, center)
% Compute features on each rectangle specified by the coordinates in trueBlocks and falseBlocks,
% referring to rectangles in the blocksInd array. The features are measured
% on the image inIm.

% *************************************************************************
% Copyright (C) 2018 Javier Mazzaferri and Santiago Costantino 
% <javier.mazzaferri@gmail.com>
% <santiago.costantino@umontreal.ca>
% Hopital Maisonneuve-Rosemont, 
% Centre de Recherche
% www.biophotonics.ca
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% *************************************************************************

readConfig

% Creates a valid mask where to compute features.
mask = maskNoCenter & thisMask;

% Initialize output array
blockFeatures = [];

[or, oc] = size(inIm);

% Smooths the input image
ker        = fspecial('gaussian', ceil(tufts.denoiseFilterSize * 6) * [1 1] , tufts.denoiseFilterSize);
smoothedIm = max(filter2(ker,inIm,'same'),0);

% Resize image to accelerate computation
resizedIm = imresize(smoothedIm,tufts.resampleScale);

% Compute the local brightness of the image. This is a very smoothed image
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

% Compute LBPs 1 and 10 in each rectangle
tolRng = range(smoothedIm(logical(maskNoCenter))) * tufts.lbpTolPercentage / 100; % The tolerance for LPBs is 5% of total image range within valid mask
R = 1;
P = 8;
blockFeatures = [blockFeatures,computeLBP_M_FeaturesOnBlocks(smoothedIm,R,P,blocksInd,[trueBlocks;falseBlocks],offSet,tolRng)];

end

