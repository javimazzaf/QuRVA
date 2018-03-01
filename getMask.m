function msk = getMask(im)

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

im(im(:) >= 0.99 * max(im(:))) = 0;

oSize = size(im);

scl = 500 / max(oSize);

% Scale down to speed up the processing
im = imresize(double(im), scl);

sz = round(max(size(im)) * maskParams.smoothingSizeFraction);

imLP   = mat2gray(filter2(fspecial('gaussian',[sz sz], sz/6),im));

thresh = getThreshold(imLP(:));
if isempty(thresh)
    msk = zeros(size(im),'logical');
    return
end

msk    = imbinarize(imLP,thresh);
[msk, cHull] = getBigestObject(msk);

% Refine binarization
thresh = getThreshold(imLP(cHull));

if isempty(thresh)
    msk    = imfill(msk,'holes');
    msk    = logical(imresize(msk, oSize));
    return
end

msk    = imbinarize(imLP,thresh);
[msk, ~] = getBigestObject(msk);

msk    = imfill(msk,'holes');

% Back to original size
msk    = logical(imresize(msk, oSize));

end