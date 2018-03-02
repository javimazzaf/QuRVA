function [outImage, scaleFactor] = resetScale(inImage)
% Resize image for standardizing

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

sz = size(inImage);

[~,ix] = max(sz);

newSize = [NaN NaN];
newSize(ix) = imageStandardSize;

layer1   = imresize(inImage(:,:,1),newSize);

if numel(sz) == 3
    
    outImage = zeros([size(layer1) sz(3)]);
    outImage(:,:,1) = layer1;
    
    for k = 2:sz(3)
        outImage(:,:,k) = imresize(inImage(:,:,k),newSize);
    end
    
else
    
    outImage = layer1;
    
end

outSz=size(layer1);
scaleFactor=sz(1)/outSz(1);

end