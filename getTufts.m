function tuftsMask = getTufts(redImage, maskNoCenter, thisMask, thisONCenter, retinaDiam, model)
% Computes a mask where there are tufts

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

% Compute the size of the rectangles where to assess features
blockSize = ceil(retinaDiam * tufts.blockSizeFraction) * [1 1];

% Separate the image in rectangles
[~, indBlocks] = getBlocks(redImage, blockSize, [0 0]);

% Select the rectangles that are inside the retinal mask
candidateBlocks = getBlocksInMask(indBlocks, maskNoCenter & thisMask, tufts.blocksInMaskPercentage, [0 0]);

% Compute several feature for each selected rectangle in candidateBlocks
blockFeatures = computeBlockFeatures(redImage, maskNoCenter, thisMask, indBlocks, candidateBlocks,[],[0 0],thisONCenter);

% Classifies using the trained model
y = predict(model, blockFeatures);

% Gets the selected blocks
goodBlocks = candidateBlocks(y > 0.5,:);

% Builds a mask with the selected blocks
tuftsMask = blocksToMask(size(redImage), indBlocks, goodBlocks, [0 0]);

% Eliminates all objects smaller than a rectangle
tuftsMask = bwareaopen(tuftsMask,prod(blockSize) + 1);

% Quality control based on Robust Background
normIm = overSaturate(redImage);

[bckgAve, bckgStd] = getRobustLocalBackground(normIm, thisMask);

normIm = mat2gray(normIm);

mskAbove = double(normIm > (bckgAve + 3*bckgStd));

countAbovePixels = filter2(ones(tufts.QC.squareSize),mskAbove,'same') / tufts.QC.squareSize^2;

tuftsMask = tuftsMask & (countAbovePixels >= tufts.QC.threshold);

end






