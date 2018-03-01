function msk = blocksToMask(sz, ind, blocks, offSet)
% Creates a mask with true values within the rectangles specified by blocks
% and ind. The resulting image size is sz.

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

aux      = size(ind);
bSz      = aux(1:2);
nBlocks  = aux(3:4);

msk = zeros(bSz.*nBlocks + offSet);

for k = 1:size(blocks,1)
   msk(ind(:,:,blocks(k,1),blocks(k,2))) = true;
end

msk = msk(1:sz(1),1:sz(2));

end