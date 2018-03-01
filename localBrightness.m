function [localMean, szMax] = localBrightness(inIm, mask, center)
% Compute the mean value of the intensity within a rectangular region of size 
% tufts.localBrightnessWindowsSizeFraction

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

szMax = computeRetinaSize(mask, center);

sz = round(szMax * tufts.localBrightnessWindowsSizeFraction);

ker = fspecial('average', sz) > 0;

% Compute the sum of pixels in a square neighborhood
sumBrightness = filter2(ker,double(inIm) .* double(mask));

% Compute the number of pixels in the same square neighborhood
sumPixels     = filter2(int32(ker),int32(mask));

% Compute the mean
localMean = sumBrightness ./ double(sumPixels);

%Avoid division by zero problems
localMean(sumPixels < 0.5) = 0;

localMean = localMean .* mask;

end