function [vesselSkelMask, brchPts, smoothVessels, endPts] = getVacularNetwork(thisMask, myImage)
% Computes the skeleton of the vasculature, the brainching points, a mask
% of the vasculature, and the end point of the skeleton

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

% Segment vessels
vessels = imbinarize(myImage.*uint8(thisMask), adaptthresh(myImage.*uint8(thisMask), 'NeighborhoodSize', vascNet.ThreshNeighborSize));

% Remove isolated small clusters
vesselsClean = bwareaopen(vessels, vascNet.OpeningSize);

% Dilates the mask
smoothVessels = imdilate(vesselsClean, strel('disk', vascNet.DilatingRadius));

% Gets the skeleton
vesselSkelMask = bwmorph(smoothVessels, 'thin', Inf);

% Remove the egde of the retina, since it is not a real vessel
maskEdge = imdilate(bwperim(thisMask), strel('disk',5));
vesselSkelMask(logical(maskEdge)) = 0;
vesselSkelMask = vesselSkelMask .* smoothVessels;

% Gets preliminary branching points of the skeleton
brchPts = bwmorph(vesselSkelMask, 'branchpoints');

% Removes very short branches to avoid computing accessory branching points
choppedSkeleton   = vesselSkelMask - brchPts;
choppedSkeleton   = bwareaopen(choppedSkeleton, vascNet.smallestSkeletonBranchSize);
vesselSkelMaskNew = bwareaopen(choppedSkeleton + brchPts,1);

% Gets final branching points of the skeleton
brchPts           = bwmorph(vesselSkelMaskNew, 'branchpoints');

% Gets end points of the skeleton
endPts            = bwmorph(vesselSkelMaskNew, 'endpoints');

end
