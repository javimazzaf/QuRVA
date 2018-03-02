function niceImage = makeNiceVascularImage(myImage, myAVascZone, mySkeleton, myBrchPts)
% Make an image to show the avascular region.

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

diskSize = round(max(size(myImage)) * avasc.figureDilatingFactor);

% Makes each channel half the graylevel
redChannel   = myImage/2;
greenChannel = myImage/2;
blueChannel  = myImage/2;

% Dilates skeleton and branching points, and makes them logical
myBrchPts   = logical(imdilate(myBrchPts,  strel('disk', diskSize)));
mySkeleton  = logical(imdilate(mySkeleton, strel('disk', diskSize)));
myAVascZone = logical(myAVascZone);

redChannel(mySkeleton)   = 255;
greenChannel(myBrchPts)  = 255;
blueChannel(myAVascZone) = 255;

niceImage = cat(3, redChannel, greenChannel, blueChannel);

end
