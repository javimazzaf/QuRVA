function aVascZone = getAvacularZone(originalMask, vesselSkelMask, retinaDiam, thisONCenter)
% Compute the mask for the avascular region in the center of the retina

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

% Erodes the edges of the retina to avoid getting avascular regions near
% the edges.
retinaMask   = imerode(originalMask,strel('disk',round(retinaDiam / 2 * avasc.erodeFraction)));

% Compute the distance from each pixel to the vasculature
dist2vessels = bwdist(vesselSkelMask) .* retinaMask;

% Creates mask in the center where to avoid computing the avascular region
maskNoEdge   = createCircularMask(size(retinaMask, 1), size(retinaMask, 2),...
                                  thisONCenter(1), thisONCenter(2),...
                                  retinaDiam / 2 * avasc.validRadiusFraction);

% Get the biggest objects                              
emptyLbl     = bwlabel(imbinarize(imerode(dist2vessels.*maskNoEdge,strel('disk',6))));

% Get properties for the regions
emptyProps   = regionprops('table', emptyLbl, dist2vessels, 'MaxIntensity', 'PixelIdxList', 'Area');

% Find the regions where the maximum distance to a vessel is more than 5 times 
% the SD above the mean value.
mostEmptyLbL = find(emptyProps.MaxIntensity>5*std(emptyProps.MaxIntensity)+mean(emptyProps.MaxIntensity));

% Initialize the result matrix with zeros
mostEmptyIm  = zeros(size(retinaMask));

% Creates the mask object by object
for itEmpty=1:numel(mostEmptyLbL)
    mostEmptyIm(emptyProps.PixelIdxList{mostEmptyLbL(itEmpty)}) = true;
end

% Morphological closing to glue together different objects
aVascZone = logical(imclose(mostEmptyIm, strel('disk', avasc.closingSize)));

% Fill holes
aVascZone = imfill(aVascZone, 'holes');

end