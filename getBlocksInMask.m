function selBlocks = getBlocksInMask(ix, msk, percTol, offSet)
% Select the blocks that containts at least percTol percentage of true
% pixels in the msk array.

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

selBlocks = [];
sz        = size(ix);
bSz       = sz(1:2);
nBlocks   = sz(3:4);

% Pad msk array to hold an integer number of rectangles
padSz = nBlocks .* bSz - size(msk) + offSet;
msk   = padarray(msk,padSz,0,'post');

% Stores the row and column coordintes of the selected rectangles as two
% columns of an array. There is one row in selBlocks for each selected
% rectangle

for r = 1:nBlocks(1)
    for c = 1:nBlocks(2)
        if sum(sum(msk(ix(:,:,r,c))))/bSz(1)/bSz(2) >= (percTol / 100)
           selBlocks = [selBlocks;r c]; 
        end
    end
end

end