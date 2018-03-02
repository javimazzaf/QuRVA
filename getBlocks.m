function [blocks, ind] = getBlocks(im, bSz, offSet)
% Divide the image "im" in recangles sized bSz, and shifted from 1,1 on
% offset pixels.
%
% blocks is a 4-dimensional array blocks(a,b,c,d) where the 4 coordinates are
%  a: row of the pixels within the rectangle
%  b: column of the pixels within the rectangle
%  c: row of the rectangle within the image
%  d: column of the rectangle within the image
%
% ind has the same dimension of blocks but holds the linear index of each
% pixel.
%

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

sz = size(im);

% Pad the image to contain an integer number of blocks
nBlocks = ceil(sz ./ bSz);
padSz   = nBlocks .* bSz - sz + offSet;
im      = padarray(im,padSz,0,'post');

% Initializes both output arrays
blocks = zeros([bSz nBlocks]);
ind    = zeros([bSz nBlocks],'double');

% creates the coordinates of the rectangles within the whole image
rgR = 1:bSz(1);
rgC = 1:bSz(2);

% Creates an array the same size of "im" that holds the linear index of
% each pixel
ix = double(im);
ix(:) = 1:numel(ix);

% Fills the output arrays with the information from the image and from the
% linear indexes.
for r = 1:nBlocks(1)
    for c = 1:nBlocks(2)
        blocks(:,:,r,c) = im((r-1) * bSz(1) + rgR + offSet(1),(c-1) * bSz(2) + rgC + offSet(2));
        ind(:,:,r,c)    = ix((r-1) * bSz(1) + rgR + offSet(1),(c-1) * bSz(2) + rgC + offSet(2));
    end
end

end